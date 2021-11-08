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

class GetDatasetCount(BaseHandler):
    def get(self):
        dsid = self.get_int_arg("dsid", default=0)
        find = {"dsid": dsid}
        doc_count = self.db.labeledinstances.count_documents(find)
        print(doc_count)
        self.write_json({"count": doc_count})

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
    def get(self):
        """Train a new model (or update) for given dataset ID
        """
        dsid = self.get_int_arg("dsid", default=0)

        data = self.get_features_and_labels_as_SFrame(dsid)

        # fit the model to the data
        acc = -1
        best_model = 'unknown'
        if self.clf == []:
            self.clf == {}

        if len(data) > 0:
            model = tc.classifier.create(data, target='target', verbose=0)  # training
            yhat = model.predict(data)  # type: object
            self.clf[dsid] = model
            acc = sum(yhat == data['target']) / float(len(data))
            # save model for use later, if desired
            model.save('../models/turi_model_dsid%d' % (dsid))

        # send back the re substitution accuracy
        # if training takes a while, we are blocking tornado!! No!!
        self.write_json({"resubAccuracy": acc})

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
    def post(self):
        """Predict the class of a sent feature vector
        """
        data = json.loads(self.request.body.decode("utf-8"))
        fvals = self.get_features_as_SFrame(data['feature'])
        dsid = data['dsid']

        # load the model from the database (using pickle)
        # we are blocking tornado!! no!!
        if (self.clf == []):
            self.clf = {}
            print('Loading Model From file')
        #            self.clf = tc.load_model('../models/turi_model_dsid%d' % (dsid))

        model = None
        if dsid in self.clf.keys():
            model = self.clf[dsid]
        else:
            try:
                model = tc.load_model('../models/turi_model_dsid%d' % (dsid))
                self.clf[dsid] = model
            except OSError:
                print("Model has not yet been created")
                raise Exception("Model %d has not yet been created" % (dsid))

        predLabel = model.predict(fvals);
        self.write_json({"prediction": str(predLabel)})

    def get_features_as_SFrame(self, vals):
        # create feature vectors from array input
        # convert to dictionary of arrays for tc

        tmp = [float(val) for val in vals]
        tmp = np.array(tmp)
        tmp = tmp.reshape((1, -1))
        data = {'sequence': tmp}

        # send back the SFrame of the data
        return tc.SFrame(data=data)
