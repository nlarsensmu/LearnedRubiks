//
//  ViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.
//

import UIKit

let SERVER_URL = "http://192.168.1.221:8000"  // just hard coded for now

import UIKit
import CoreMotion

class LearningViewController: UIViewController, URLSessionDelegate {
    
    
    // MARK: Class Properties
    
    weak private var serverModel:ServerModel? = ServerModel.sharedInstance
    
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
    let animation = CATransition()
    let motion = CMMotionManager()
    
    var magValue = 0.1  // Just hard coded for now
    var isCalibrating = false
    
    var isWaitingForMotionData = false
    
    var dsid = 1 {
        didSet {
            DispatchQueue.main.async {
                self.dsidLabel.text = String(format: "DSID: %d", self.dsid)
            }
        }
    }// think about how we want to change this
    
    // MARK: Class Properties with Observers
    enum CalibrationStage {
        case notCalibrating
        case x90
        case xNeg90
        case x180
        case xNeg180
        case y90
        case yNeg90
        case y180
        case yNeg180
        case z90
        case zNeg90
        case z180
        case zNeg180
    }
    
    var calibrationStage:CalibrationStage = .notCalibrating {
        didSet{
            switch calibrationStage {
            case .x90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "X 90"
                }
                break
            case .xNeg90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "X' 90"
                }
                break
            case .x180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "X 180"
                }
            case .xNeg180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "X' 180"
                }
                break
            case .y90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y 90"
                }
                break
            case .yNeg90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y' 90"
                }
                break
            case .y180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y 180"
                }
            case .yNeg180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y' 180"
                }
                break
            case .z90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z 90"
                }
                break
            case .zNeg90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z' 90"
                }
                break
            case .z180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z 180"
                }
            case .zNeg180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z' 180"
                }
                break
            case .notCalibrating:
                self.isCalibrating = false
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Not Calibrating"
                }
                break
            }
        }
    }
    
    @IBOutlet weak var largeMotionMagnitude: UIProgressView!
    @IBOutlet weak var calibrationLabel: UILabel!
    @IBOutlet weak var dsidLabel: UILabel!
    @IBOutlet weak var guessingLabel: UILabel!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        startMotionUpdates()
        self.setDelayedWaitingToTrue(watingTime)
        // Do any additional setup after loading the view.
    }

    
    
    // MARK: Core Motion Updates
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 1.0/200
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion )
        }
    }
    
    @IBAction func didStep(_ sender: UIStepper) {
        self.dsid = Int(sender.value)
    }
    
    @IBAction func calibrateOnce(_ sender: Any) {
        self.isWaitingForMotionData = false
        nextCalibrationStage()
    }
    
    @IBAction func magnitudeChagned(_ sender: UISlider) {
        self.magValue = Double(sender.value)
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
            let mag = fabs(accel.x)+fabs(accel.y)+fabs(accel.z)
            
            DispatchQueue.main.async{
                //show magnitude via indicator
                self.largeMotionMagnitude.progress = Float(mag)/0.2
            }
            
            if mag > self.magValue {
                // buffer up a bit more data and then notify of occurrence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                    self.calibrationOperationQueue.addOperation {
                        // something large enough happened to warrant
                        self.largeMotionEventOccurred()
                    }
                })
            }
        }
    }
    
    //MARK: Calibration procedure
    func largeMotionEventOccurred(){
        if(self.isCalibrating){
            //send a labeled example
            if(self.calibrationStage != .notCalibrating && self.isWaitingForMotionData)
            {
                self.isWaitingForMotionData = false
                
                // send data to the server with label
                sendFeatures(self.ringBuffer.getDataAsVector(),
                             withLabel: self.calibrationStage)
                
                self.nextCalibrationStage()
            }
        }
        else
        {
            if(self.isWaitingForMotionData)
            {
                self.isWaitingForMotionData = false
                //predict a label
                serverModel?.getPrediction(self.ringBuffer.getDataAsVector(), outController:self)
                // dont predict again for a bit
                setDelayedWaitingToTrue(2.0)

            }
        }
    }
    
    @IBAction func makeModel(_ sender: Any) {
        
        // create a GET request for server to update the ML model with current data
        let baseURL = "\(SERVER_URL)/UpdateModel"
        let query = "?dsid=\(self.dsid)"
        
        let getUrl = URL(string: baseURL+query)
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
                    
                    if let resubAcc = jsonDictionary["resubAccuracy"]{
                        print("Resubstitution Accuracy is", resubAcc)
                    }
                }
                                                                    
        })
        
        dataTask.resume() // start the task
    }
    
    func displayLabelResponse(_ response:String) {
        DispatchQueue.main.async {
            self.guessingLabel.text = "Guessing: \(response)"
        }
    }
    
    let watingTime = 2.0
    func nextCalibrationStage(){
        switch self.calibrationStage {
        case .notCalibrating:
            //start with up arrow
            self.calibrationStage = .x90
            setDelayedWaitingToTrue(watingTime)
            break
        case .x90:
            //start with up arrow
            self.calibrationStage = .xNeg90
            setDelayedWaitingToTrue(watingTime)
            break
        case .xNeg90:
            //start with up arrow
            self.calibrationStage = .x180
            setDelayedWaitingToTrue(watingTime)
            break
        case .x180:
            //start with up arrow
            self.calibrationStage = .xNeg180
            setDelayedWaitingToTrue(watingTime)
            break
        case .xNeg180:
            //start with up arrow
            self.calibrationStage = .y90
            setDelayedWaitingToTrue(watingTime)
            break
        case .y90:
            //start with up arrow
            self.calibrationStage = .yNeg90
            setDelayedWaitingToTrue(watingTime)
            break
        case .yNeg90:
            //start with up arrow
            self.calibrationStage = .y180
            setDelayedWaitingToTrue(watingTime)
            break
        case .y180:
            //start with up arrow
            self.calibrationStage = .yNeg180
            setDelayedWaitingToTrue(watingTime)
            break
        case .yNeg180:
            //start with up arrow
            self.calibrationStage = .z90
            setDelayedWaitingToTrue(watingTime)
            break
        case .z90:
            //start with up arrow
            self.calibrationStage = .zNeg90
            setDelayedWaitingToTrue(watingTime)
            break
        case .zNeg90:
            self.calibrationStage = .z180
            setDelayedWaitingToTrue(watingTime)
            break
        case .z180:
            self.calibrationStage = .zNeg180
            setDelayedWaitingToTrue(watingTime)
            break
        case .zNeg180:
            self.calibrationStage = .notCalibrating
            setDelayedWaitingToTrue(watingTime)
            break
        }
    }
    
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
        })
    }
    
    // TODO Move this to another file so it can be accessed in other classes
    //MARK: Comm with Server
    func sendFeatures(_ array:[Double], withLabel label:CalibrationStage){
        let baseURL = "\(SERVER_URL)/AddDataPoint"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array,
                                       "label":"\(label)",
                                       "dsid":self.dsid]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    print(jsonDictionary["feature"]!)
                    print(jsonDictionary["label"]!)
                }

        })
        
        postTask.resume() // start the task
    }
    
    
    //MARK: JSON Conversion Functions
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

