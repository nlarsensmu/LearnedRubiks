#!/usr/bin/python
from builtins import FileNotFoundError

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

import turicreate as tc
import pickle
from bson.binary import Binary
import json
import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split


class PrintHandlers(BaseHandler):
    def get(self):
        """Write out to screen the handlers used
        This is a nice debugging example!
        """
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),', '),\n'))


class UploadLabeledDatapointHandler(BaseHandler):
    def post(self):
        """Save data point and class label to database
        decode the body as strings
        convert from json to a dictionary
        """
        data = json.loads(self.request.body.decode("utf-8"))

        vals = data['feature']
        fvals = [float(val) for val in vals]
        label = data['label']
        sess = data['dsid']

        dbid = self.db.labeledinstances.insert(
            {"feature": fvals, "label": label, "dsid": sess}
        );
        self.write_json({"id": str(dbid),
                         "feature": [str(len(fvals)) + " Points Received",
                                     "min of: " + str(min(fvals)),
                                     "max of: " + str(max(fvals))],
                         "label": label})


class RequestNewDatasetId(BaseHandler):
    def get(self):
        """Get a new dataset ID for building a new dataset
        Gets the largest dsid and the give +1 of that number to get a new one
        """
        a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
        if a == None:
            newSessionId = 1
        else:
            newSessionId = float(a['dsid']) + 1
        self.write_json({"dsid": newSessionId})


class GetLearnedModelData(BaseHandler):
    def get(self):
        dsid = self.get_int_arg("dsid", default=0)
        find = {"dsid": dsid}
        doc = self.db.trainedmodels.find_one(find)

        print(doc)

        count = doc["count"]
        acc_mlp = float(doc["acc_mlp"])
        acc_turi = float(doc["acc_turi"])

        d = dict()
        d["dsid"] = dsid
        d["acc_mlp"] = float(acc_mlp)
        d["acc_turi"] = float(acc_turi)
        d["count"] = count

        self.write_json( d )


class DeleteADsId(BaseHandler):
    def get(self):
        dsid = self.get_int_arg("dsid", default=0)
        find = {"dsid": dsid}

        output = self.db.labeledinstances.delete_many(find)

        print(output)


class RequestAllDatasetIds(BaseHandler):
    def get(self):
        dsids = self.db.labeledinstances.find().distinct('dsid')
        self.write_json({"dsids": dsids})


class UpdateModelForDatasetId(BaseHandler):

  def get_dataset_data(self, dsid):
      features = []
      labels = []
      
      for a in self.db.labeledinstances.find({"dsid": dsid}):
          features.append([float(val) for val in a['feature']])
          labels.append(a['label'])
          
      data = {'target': labels, 'sequence':np.array(features)}
      
      return data


  def get_dataset_sframe(self, dsid):
      data = get_dataset_data(dsid)
      return tc.SFrame(data=data)

  def get(self):
      """ Train two kinds of models. Our MLP and out of the box
      TURI create. pick the one with the best ACC
      """

      if isinstance(self.clf, list):
          self.clf = {}

      dsid = self.get_int_arg("dsid", default=0)
      (model_mlp, acc_mlp, model_path_mlp, count) = self.create_mlp(dsid)

      (model_turi, acc_turi, model_path_turi) = self.create_turi(dsid)

      # Add the models to the database
      self.db.trainedmodels.update({"dsid": dsid}, 
        {"$set": 
          {"dsid":dsid,
          "acc_mlp": acc_mlp,
          "acc_turi": acc_turi,
          "path_mlp": model_path_mlp,
          "path_turi": model_path_turi,
          "count":count}}, upsert=True)

      self.clf[dsid] = {"MLP": model_mlp,
                       "TURI": model_turi}
      
      self.write_json({"resubAccuracy": acc_mlp})


  def create_mlp(self, dsid):
      """Use Sklearn MLP to create a model
      Save it using pickle
      """

      data = self.get_dataset_data(dsid)

      # fit the model to the data
      acc = -1
      best_model = 'unknown'

      if len(data) > 0:
        model = MLPClassifier(hidden_layer_sizes=(50, 25),
                              activation='relu',  # compare to sigmoid
                              solver='adam',
                              alpha=1e-4,  # L2 penalty
                              batch_size='auto',  # min of 200, num_samples
                              learning_rate='constant',
                              # learning_rate_init=0.2, # only SGD
                              # power_t=0.5,    # only SGD
                              max_iter=100,
                              shuffle=True,
                              random_state=1,
                              tol=1e-9,  # for stopping
                              verbose=False,
                              warm_start=False,
                              momentum=0.9,  # only SGD
                              # nesterovs_momentum=True, # only SGD
                              early_stopping=False,
                              validation_fraction=0.1,  # only if early_stop is true
                              beta_1=0.9,  # adam decay rate of moment
                              beta_2=0.999,  # adam decay rate of moment
                              epsilon=1e-08)  # adam numerical stabilizer

        encode_rotation = {'x90': 0,
                         'xNeg90': 1,
                         'x180': 2,
                         'xNeg180': 3,
                         'y90': 4,
                         'yNeg90': 5,
                         'y180': 6,
                         'yNeg180': 7,
                         'z90': 8,
                         'zNeg90': 9,
                         'z180': 10,
                         'zNeg180': 11}

        y = np.array([encode_rotation[s] for s in data['target']])

        X = data['sequence']
        x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.1, stratify=y)

        model.fit(x_train, y_train)
        yhat = model.predict(x_test)  # type: object
        acc = accuracy_score(yhat,y_test)

        model_path = '../models/mlp_model_dsid%d' % dsid
        pickle.dump(model, open(model_path, 'wb'))


      # send back the re substitution accuracy
      # if training takes a while, we are blocking tornado!! No!!
      return (model, acc, model_path, len(y))


  def create_turi(self, dsid):
      """Use out of the box TURI Create to classify.
      """

      data = self.get_features_and_labels_as_SFrame(dsid)

      # fit the model to the data
      acc = -1

      if len(data) > 0:
          data_train, test_test = data.random_split(.9, seed=5)

          model = tc.classifier.create(data_train, target='target', verbose=0)  # training
          yhat = model.predict(test_test)  # type: object
          acc = sum(yhat == test_test['target']) / float(len(test_test))
          # save model for use later, if desired
          model_path = '../models/turi_model_dsid%d' % (dsid)
          model.save(model_path)

      return (model, acc, model_path)

  def get_features_and_labels_as_SFrame(self, dsid):
      # create feature vectors from database
      features = []
      labels = []
      for a in self.db.labeledinstances.find({"dsid": dsid}):
          features.append([float(val) for val in a['feature']])
          labels.append(a['label'])

      # convert to dictionary for tc
      data = {'target': labels, 'sequence': np.array(features)}

      # send back the SFrame of the data
      return tc.SFrame(data=data)


class PredictOneFromDatasetId(BaseHandler):

    def encode_to_str(self, code):
        encode_rotation = {0: 'x90',
                           1: 'xNeg90',
                           2: 'x180',
                           3: 'xNeg180',
                           4: 'y90',
                           5: 'yNeg90',
                           6: 'y180',
                           7: 'yNeg180',
                           8: 'z90',
                           9: 'zNeg90',
                           10: 'z180',
                           11: 'zNeg180'}

        return encode_rotation[code]

    def post(self):
        """Predict the class of a sent feature vector
        """
        data = json.loads(self.request.body.decode("utf-8"))
        fvals = self.get_features_as_numpy(data['feature'])
        dsid = data['dsid']

        #get the desired model to be used
        model_type = "MLP"
        if "model" in data.keys():
            model_type = data["model"]

        # if clf is a list make it a dictionary
        if (self.clf == []):
            self.clf = {}

        model = None

        if dsid in self.clf.keys():
            model = self.clf[dsid][model_type]
           
        else: # if the model has not been loaded. load it for both
            model_mlp = None
            model_turi = None
            try:
                model_mlp = pickle.load(open('../models/mlp_model_dsid%d' % dsid, 'rb'))
            except OSError:
                print("Could not load MLP model, may not be created")
                raise Exception("Model %d may not be created" % (dsid))
            try:
                model_turi = tc.load_model('../models/turi_model_dsid%d'%(dsid))
            except OSError:
                print("Could not load TURI model, may not be created")
                raise Exception("Model %d may not be created" % (dsid))

            self.clf[dsid] = {"MLP": model_mlp, "TURI": model_turi}

        model = self.clf[dsid][model_type]

        # conver fvals to sframe for turi
        if model_type == "TURI":
            data = {'sequence': fvals}
            fvals = tc.SFrame(data=data)

        predLabel = model.predict(fvals)

        # if the model is MLP get the real label
        if model_type == "MLP":
            predLabel = self.encode_to_str(predLabel[0])
        self.write_json({"prediction": str(predLabel)})

    def get_features_as_numpy(self, vals):
        # create feature vectors from array input
        # convert to dictionary of arrays for tc

        tmp = [float(val) for val in vals]
        tmp = np.array(tmp)
        tmp = tmp.reshape((1, -1))
        return tmp