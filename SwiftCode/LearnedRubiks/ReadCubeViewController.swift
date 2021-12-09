//
//  ReadCubeViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/22/21.
//

import UIKit
import AVFoundation
import CoreML
import SceneKit
import CoreMotion

class ReadCubeViewController: UIViewController {
    
    // MARK: Class Properties
    
    lazy var colorModel:colors = {
        do{
            let config = MLModelConfiguration()
            return try colors(configuration: config)
        }catch{
            print(error)
            fatalError("Could not load ModelDsId4")
        }
    }()
    
    var videoManager:VideoAnalgesic! = nil
    let bridge = OpenCVBridge()
    var detector:CIDetector! = nil
    
    let instructions = ["Top: White Front: Blue",
                        "Top: Orange Front: Blue",
                        "Top: Yellow Front: Blue",
                        "Top: Red Front: Blue",
                        "Top: Blue Front: Orange",
                        "Top: Green Front: Red"]
    let instructionsCenterString = ["white",
                                    "orange",
                                    "yellow",
                                    "red",
                                    "blue",
                                    "green"]
    let instructionFaces:[CubletColor] = [.white, .orange, .yellow, .red, .blue, .green]
    var faces:[[CubletColor]] = Array.init(repeating: [], count: 6)
    var currentFace:[(String,Int)] = []
    func faceForBridge() -> [String]{
        var face:[String] = []
        for i in 0..<currentFace.count{
            face.append(self.currentFace[i].0)
        }
        return face
    }
    var instruction:Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.instructionLabel.text = self.instructions[self.instruction]
            }
        }
    }
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBAction func resetFace(_ sender: Any) {
        self.bridge.resetCublets()
        let colors = Array.init(repeating: "", count: 9)
        self.currentFace = []
        self.bridge.setProcessedColors(colors)
    }
    //Delete these later when we figure out the transform
    let x0 = 76.0
    let x4 = 365.0
    let y0 = 165.5
    let y4 = 480.5
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        let clickedPoint = sender.location(in: self.view)
        let x = clickedPoint.x
        let y = clickedPoint.y
        
        let w = (x4 - x0) / 3
        let h = (y4 - y0) / 3
        
        var cubeNumber = 0
        if x0 < x && x < x4 && y0 < y && y < y4 {
            if x0 < x && x < x0 + w {
                cubeNumber = cubeNumber + 0
            }
            else if x0 + w < x && x < x0 + 2*w {
                cubeNumber = cubeNumber + 1
            }else {
                cubeNumber = cubeNumber + 2
            }
            if y0 < y && y < y0 + h {
                cubeNumber = cubeNumber + 0
            }
            else if y0 + h < y && y < y0 + 2*h {
                cubeNumber = cubeNumber + 3
            }else {
                cubeNumber = cubeNumber + 6
            }
            self.moveToNextPrediction(index: cubeNumber)
            self.bridge.setProcessedColors(self.faceForBridge())
        }
        print(cubeNumber)
    }
    func moveToNextPrediction(index:Int){
        guard let p = self.currentPredictions[index] else {
            return
        }
        let currentPer = p.targetProbability[self.currentFace[index].0]!
        var nextProb = 0.0
        var nextPred = "noColor"
        for prob in p.targetProbability{
            if currentPer > prob.value && prob.value > nextProb{
                nextProb = prob.value
                nextPred = prob.key
            }
        }
        if nextPred == "noColor"{
            self.currentFace[index] = (p.target, 0)
        }
        else{
            self.currentFace[index] = (nextPred, currentFace[index].1 + 1 % 9)
        }
    }
    func cubletColorToString(color:CubletColor) -> String {
        var c = "noColor"
        switch color {
        case .red:
            c =  "red"
        case .blue:
            c =  "blue"
        case .yellow:
            c =  "yellow"
        case .white:
            c =  "white"
        case .orange:
            c =  "orange"
        case .green:
            c =  "green"
        case .noColor:
            c =  "noColor"
        }
        return c
    }
    
    func getColor(red:Double, green:Double, blue: Double) ->CubletColor {
        
        if red > 150 && green > 150 && blue > 150 {
            return .white
        } else if red > 180 && green > 180 && blue < 100{
            return .yellow
        } else if red > 130 && green < 100 && blue < 100 {
            return .red
        } else if red > 180 && green > 90 && blue < 100 {
            return .orange
        } else if red < 150 && green > 150  && blue < 150 {
            return .green
        } else if red < 100 && green > 100 && blue > 100 {
            return .blue
        }
        
        return .noColor
    }
    @IBAction func save(_ sender: Any) {
        
//        let result = performClassifier()
        self.bridge.resetCublets()
        
        var face:[CubletColor] = []
        for c in currentFace {
            face.append(stringToColor(color: c.0))
        }
        currentFace.removeAll()
        
        faces[instruction] = getFaceOrientation(colors: face)
        
        if instruction == 5 {
            self.cube =  RubiksCube(front: faces[2], left: faces[1], right: faces[3], up: faces[5], down: faces[4], back: faces[0])
            self.performSegue(withIdentifier: "inputToPredictionViewController", sender: self)
        }
        
        instruction = (instruction + 1) % instructions.count
    }
    var currentPredictions:[colorsOutput?] = [nil,nil,nil,nil,nil,nil,nil,nil,nil]
    func performClassifier() -> [CubletColor] {
        var colors:[CubletColor] = []
        for i in 0..<self.currentFace.count {
            let color = self.currentFace[i]
            if i == 4 {
                colors.append(instructionFaces[instruction])
            } else {
                colors.append(stringToColor(color: color.0))
            }
        }
        return (colors)
    }
    
    func getFaceOrientation(colors:[CubletColor]) -> [CubletColor] {
        
        if colors[4] == .blue {
            return colors
        } else if colors[4] == .green {
            return [colors[6], colors[7], colors[8],
                    colors[3], colors[4], colors[5],
                    colors[0], colors[1], colors[2]]
        } else if colors[4] == .red {
            return [colors[6], colors[7], colors[8],
                    colors[3], colors[4], colors[5],
                    colors[0], colors[1], colors[2]]
        } else if colors[4] == .orange {
            return colors.reversed()
        } else if colors[4] == .white {
            return [colors[6], colors[7], colors[8],
                    colors[3], colors[4], colors[5],
                    colors[0], colors[1], colors[2]]
        } else if colors[4] == .yellow {
            return colors.reversed()
        }
        return []
    }
    @IBAction func captureSquares(_ sender: Any) {
        self.bridge.setCapture(true)
    }
    func checkSquares() {
        let culetsColors = self.bridge.getCublets()
        
        if let items = (culetsColors as NSArray?) as? [Double] {
            self.currentFace = []
            self.currentPredictions = []
            for i in 0..<items.count/3 {
                var color = "noColor"
                do {
                    let input = colorsInput(red: items[i*3], green: items[i*3 + 1], blue: items[i*3 + 2])
                    let pred = try colorModel.prediction(input: input)
                    self.currentPredictions.append(pred)
                    color = pred.target
                } catch _{
                    print("Failed Predicting")
                }
                //hardcoding the center, since we are 100% what it is
                if i == 4 {
                    self.currentFace.append((self.instructionsCenterString[self.instruction],0))
                }
                else{
                    self.currentFace.append((color,0))
                }
            }
        }
        self.bridge.setProcessedColors(self.faceForBridge())
    }
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        // setup the OpenCV bridge nose detector, from file
        
        self.videoManager = VideoAnalgesic(mainView: self.view)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these properties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImageSwift)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        self.bridge.processType = 9
        self.instruction = 0
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let _ = self.videoManager.turnOnFlashwithLevel(0.001)
        self.videoManager.start()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoManager.turnOffFlash()
        self.videoManager.stop()
    }
    
    var imageRect = CGRect()
    var fullImageRect = CGRect()
    //MARK: Process image output
    func processImageSwift(inputImage:CIImage) -> CIImage{
        
        let _ = self.videoManager.turnOnFlashwithLevel(0.001)
        
        var retImage = inputImage
        fullImageRect = CGRect(x: retImage.extent.minX, y: retImage.extent.minY, width: retImage.extent.width, height: retImage.extent.height)
        
        let width = retImage.extent.width/2
        let imageWidth = retImage.extent.width
        let imageHeight = retImage.extent.height
        let rect = CGRect(x: imageWidth/2 - width/2, y: imageHeight/2 - width/2, width: width, height: width)
        imageRect = rect
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: rect,
                             andContext: self.videoManager.getCIContext())
        
        
        self.bridge.processImage()
        
        retImage = self.bridge.getImageComposite()
        
        let p = CGPoint(x: imageWidth/2 - width/2, y:imageHeight/2 - width/2)
        let rectTest = CGRect(origin: p, size: CGSize(width: 0.0, height: 0.0))
        print(rect)
        print(rect.applying(self.videoManager.transform))
        print(self.bridge.getRectTransformation(rect))
        
        if self.bridge.getCaptured() && self.currentFace.count == 0{ // we have performed a capture label the prediciton.
            checkSquares()
        }
        
        return retImage
    }

    //MARK: Setup Face Detection
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "inputToPredictionViewController"){
                let displayVC = segue.destination as! CubeController
            displayVC.Cube = self.cube
            displayVC.solver = SolverCross(c: displayVC.Cube!)
            displayVC.nextStep = displayVC.solver!.getNextStep()
            displayVC.displayStep = stepsToString(steps: displayVC.nextStep.steps)
            displayVC.solveOnly = true
        }
    }
    var cube:RubiksCube? = nil
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let c = cube else {
            return false
        }
        if c.isValid() && c.isParady() {
            return true
        }
        return false
    }
}
