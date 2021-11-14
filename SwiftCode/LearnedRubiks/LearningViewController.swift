//
//  ViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.
//

import UIKit

let SERVER_URL = "http://192.168.1.221:8001"  // just hard coded for now

import UIKit
import CoreMotion
import CoreML

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
    lazy var loadedModel:ModelDsId4 = {
        do{
            let config = MLModelConfiguration()
            return try ModelDsId4(configuration: config)
        }catch{
            print(error)
            fatalError("Could not load ModelDsId4")
        }
    }()
    //Motion and motion data variables
    let operationQueue = OperationQueue()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    var ringBuffer = RingBuffer()
    let animation = CATransition()
    let motion = CMMotionManager()
    //UI variables
    var magValue = 0.1  // Just hard coded for now
    var isCalibrating = false
    var isWaitingForMotionData = false
    var usedStages:[CalibrationStage] = []
    var dsid = 1 {
        didSet {
            DispatchQueue.main.async {
                self.dsidLabel.text = String(format: "DSID: %d", self.dsid)
            }
        }
    }
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
                    self.hintLabel.text = "right face clockwise"
                }
                break
            case .xNeg90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "X' 90"
                    self.hintLabel.text = "right face counter-clockwise"
                }
                break
            case .x180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "X 180"
                    self.hintLabel.text = "right face clockwise twice"
                }
                break
            case .xNeg180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "X' 180"
                    self.hintLabel.text = "right face counter-clockwise twice"
                }
                break
            case .y90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y 90"
                    self.hintLabel.text = "top face clockwise"
                }
                break
            case .yNeg90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y' 90"
                    self.hintLabel.text = "top face counter-clockwise"
                }
                break
            case .y180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y 180"
                    self.hintLabel.text = "top face clockwise twice"
                }
                break
            case .yNeg180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Y' 180"
                    self.hintLabel.text = "top face counter-clockwise twice"
                }
                break
            case .z90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z 90"
                    self.hintLabel.text = "front face clockwise"
                }
                break
            case .zNeg90:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z' 90"
                    self.hintLabel.text = "front face counter-clockwise"
                }
                break
            case .z180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z 180"
                    self.hintLabel.text = "front face clockwise twice"
                }
                break
            case .zNeg180:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.calibrationLabel.text = "Z' 180"
                    self.hintLabel.text = "front face counter-clockwise twice"
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
    //MARK: Outlets
    @IBOutlet weak var largeMotionMagnitude: UIProgressView!
    @IBOutlet weak var calibrationLabel: UILabel!
    @IBOutlet weak var dsidLabel: UILabel!
    @IBOutlet weak var guessingLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var modelSegmented: UISegmentedControl!
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        startMotionUpdates()
        self.setDelayedWaitingToTrue(watingTime)
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.motion.stopGyroUpdates()
        self.motion.stopMagnetometerUpdates()
        self.motion.stopAccelerometerUpdates()
        self.motion.stopDeviceMotionUpdates()
    }
    // MARK: Core Motion Updates
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 1.0/200
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion )
        }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.calibrationOperationQueue.addOperation {
                        // something large enough happened to warrant
                        self.largeMotionEventOccurred()
                    }
                })
            }
        }
    }
    //MARK: Actions
    @IBAction func didStep(_ sender: UIStepper) {
        self.dsid = Int(sender.value)
    }
    @IBAction func calibrateOnce(_ sender: Any) {
        self.isWaitingForMotionData = false
        nextCalibrationStage()
        // Turn off guessin label
        DispatchQueue.main.async {
            self.setAsNormal(self.guessingLabel)
        }
    }
    @IBAction func magnitudeChagned(_ sender: UISlider) {
        self.magValue = Double(sender.value)
    }
    @IBAction func makeModel(_ sender: Any) {
        // create a GET request for server to update the ML model with current data
        serverModel?.makeModel(dsid: dsid)  { (acc) in
            print("Resubstitution Accuracy is", acc)
        }
    }
    //MARK: Calibration/Prediction
    func largeMotionEventOccurred(){
        if(self.isCalibrating){
            //send a labeled example
            if(self.calibrationStage != .notCalibrating && self.isWaitingForMotionData)
            {
                self.isWaitingForMotionData = false
                
                // send data to the server with label
                sendFeatures(self.ringBuffer.getDataAsVector(),
                             withLabel: self.calibrationStage)
                
                DispatchQueue.main.async {
                    self.setAsCalibrating(self.calibrationLabel)
                }
                self.nextCalibrationStage()
            }
        }
        else
        {
            if(self.isWaitingForMotionData)
            {
                self.isWaitingForMotionData = false
                self.setDelayedWaitingToTrue(0.5)
                var model = ""
                if let m = self.modelSegmented.titleForSegment(at: self.modelSegmented.selectedSegmentIndex)  {
                    model = m
                } else {
                    model = "MLP"
                }
                if model != "Loaded" {
                    serverModel?.getPrediction(self.ringBuffer.getDataAsVector(),
                                               dsid: self.dsid,
                                               model: model) {
                        resp in
                        DispatchQueue.main.async {
                            self.setAsCalibrating(self.guessingLabel)
                            self.displayLabelResponse(resp)
                        }
                    }
                }
                else {
                    do {
                        let array = try MLMultiArray(self.ringBuffer.getDataAsVector())
                        let input = ModelDsId4Input(sequence: array)
                        let ret = try loadedModel.prediction(input: input)
                        DispatchQueue.main.async {
                            self.setAsCalibrating(self.guessingLabel)
                            self.displayLabelResponse(ret.target)
                        }
                    } catch _{
                        print("failed to classify")
                    }
                }
            }
        }
    }
    func displayLabelResponse(_ response:String) {
        DispatchQueue.main.async {
            self.guessingLabel.text = "Guessing: \(response)"
        }
    }
    let watingTime = 1.25
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
            DispatchQueue.main.async {
                self.setAsNormal(self.calibrationLabel)
            }
            break
        }
    }
    func setAsCalibrating(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.backgroundColor = UIColor.red
    }
    func setAsNormal(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.backgroundColor = UIColor.white
    }
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
            if self.calibrationStage == .notCalibrating {
                self.setAsNormal(self.guessingLabel)
            } else {
                self.setAsNormal(self.calibrationLabel)
            }
        })
    }
    func sendFeatures(_ array:[Double], withLabel label:CalibrationStage){
        serverModel?.sendFeatures(array: array, label: label, dsid: dsid){
            print("sent features")
        }
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

