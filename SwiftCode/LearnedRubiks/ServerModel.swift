//
//  ServerModel.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.
//

import Foundation

class ServerModel: NSObject, URLSessionDelegate {
    
    let SERVER_URL = "http://192.168.1.221:8001"  // just hard coded for now
    
    public static var sharedInstance:ServerModel? = {
        var sharedInstance:ServerModel? = nil
        
        if(sharedInstance == nil) {
            sharedInstance = ServerModel()
        }
        
        return sharedInstance
    }()
    
    
    // MARK: Class Properties
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    let operationQueue = OperationQueue()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    
    var ringBuffer = RingBuffer()
    
    // MARK: comm with Server
    
    func getAllDsIds(outContoller:DatasetsTableView){
        let baseURL = "\(SERVER_URL)/GetAllDatasetIds"
        let getUrl = URL(string: "\(baseURL)")
        
        let request: URLRequest = URLRequest(url: getUrl!)
        
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
              completionHandler:{(data, response, error) in
                // handle error!
                if (error != nil) {
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    if let dsids = jsonDictionary["dsids"]{
                        print(dsids)
                        let list = dsids as! [Any]
                        outContoller.dsids = list
                        DispatchQueue.main.async {
                            outContoller.tableView.reloadData()
                        }
                    }
                }
                                                                    
        })
        
        dataTask.resume() // start the task
    }
    
    func getDsIdCount(outController: DeleteDatasetViewController) {
        
        //http://192.168.1.221:8000/GetDatasetCount?dsid=1
        
        let baseURL = "\(SERVER_URL)/GetDatasetCount"
        let args = "\(outController.dsid)"
        let getUrl = URL(string: "\(baseURL)?dsid=\(args)")
        
        let request: URLRequest = URLRequest(url: getUrl!)
        
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
              completionHandler:{(data, response, error) in
                // handle error!
                if (error != nil) {
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    if let data = jsonDictionary["count"]{
                        print(data)
                        let dsCount = data as! Int
                        DispatchQueue.main.async {
                            outController.samplesLabel.text = "\(dsCount)"
                            
                        }
                    }
                }
        })
        
        dataTask.resume() // start the task
    }
    
    func deleteDsIdRecords(outController: DeleteDatasetViewController) {
        
        //http://192.168.1.221:8000/DeleteADsId?dsid=2
        
        let baseURL = "\(SERVER_URL)/DeleteADsId"
        let args = "\(outController.dsid)"
        let getUrl = URL(string: "\(baseURL)?dsid=\(args)")
        
        let request: URLRequest = URLRequest(url: getUrl!)
        
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
              completionHandler:{(data, response, error) in
                // handle error!
                if (error != nil) {
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        outController.deleteButton.isEnabled = false
                    }
                }
        })
        
        dataTask.resume()
        
    }
    
    func getPrediction(_ array:[Double], outController: LearningViewController){
        let baseURL = "\(SERVER_URL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array, "dsid":outController.dsid]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res)
                            }
                        }
                        else{ // no error we are aware of
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            if let labelResponse = jsonDictionary["prediction"] {
                                print(labelResponse)
                                outController.displayLabelResponse(labelResponse as! String)
                            } else {
                                print("No model yet!")
                            }

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    typealias CompletionHandler = (String) -> Void
    func getPrediction(_ array:[Double], dsid:Int,completionHandler: @escaping CompletionHandler ){
        let baseURL = "\(SERVER_URL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array, "dsid":dsid]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res)
                            }
                        }
                        else{ // no error we are aware of
                            let url = response?.url
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            if let labelResponse = jsonDictionary["prediction"] {
                                print(labelResponse)
                                completionHandler(labelResponse as! String)
                            } else {
                                print("No model yet!")
                            }
                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    //MARK: JSON Conversion Functions DUPLUCATIED
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }

}
