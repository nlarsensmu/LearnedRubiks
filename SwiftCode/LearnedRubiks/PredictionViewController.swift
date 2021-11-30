//
//  PredictionViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.
//

import UIKit
import SceneKit
import CoreMotion

class PredictionViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var sceneView: SCNView!
    
    // Full cube
    @IBAction func xRotate(_ sender: Any) {
        if let cube = Cube{
            scene.rootNode.runAction(cube.rotateAllX(direction:1))
        }
    }
    @IBAction func xRotateNeg(_ sender: Any) {
        if let cube = Cube{
            scene.rootNode.runAction(cube.rotateAllX(direction:-1))
        }
    }
    @IBAction func yRotate(_ sender: Any) {
        if let cube = Cube{
            scene.rootNode.runAction(cube.rotateAllY(direction:1))
        }
    }
    @IBAction func yRotateNeg(_ sender: Any) {
        if let cube = Cube{
            scene.rootNode.runAction(cube.rotateAllY(direction:-1))
        }
    }
    @IBAction func zRotate(_ sender: Any) {
        if let cube = Cube{
            scene.rootNode.runAction(cube.rotateAllZ(direction:1))
        }
    }
    @IBAction func zRotateNeg(_ sender: Any) {
        if let cube = Cube{
            scene.rootNode.runAction(cube.rotateAllZ(direction:-1))
        }
    }
    // One face
    @IBAction func upTurn(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.upTurn(direction: 1))
        }
    }
    @IBAction func upTurnNeg(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.upTurn(direction: -1))
        }
    }
    @IBAction func downTurn(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.downTurn(direction: 1))
            cube.printCube()
        }
    }
    @IBAction func downTurnNeg(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.downTurn(direction: -1))
        }
    }
    @IBAction func rightTurn(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.rightTurn(direction: 1))
        }
    }
    @IBAction func rightTurnNeg(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.rightTurn(direction: -1))
        }
    }
    @IBAction func leftTurn(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.leftTurn(direction: 1))
        }
    }
    @IBAction func leftTurnNeg(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.leftTurn(direction: -1))
        }
    }
    @IBAction func backTurn(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.backTurn(direction: 1))
        }
    }
    @IBAction func backTurnNeg(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.backTurn(direction: -1))
        }
    }
    @IBAction func frontTurn(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.frontTurn(direction: 1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func frontTurnNeg(_ sender: Any) {
        if let cube = Cube {
            scene.rootNode.runAction(cube.frontTurn(direction: -1))
        }
    }
    
    @IBOutlet weak var stepText: UILabel!
    @IBOutlet weak var scrambleButton: UIButton!
    @IBAction func scrambleCube(_ sender: Any) {
        if let cube = Cube {
            cube.undoTurns(steps: self.nextStep.steps)
            let actions = cube.scramble(turnsCount: 30)
            self.animationRunning = true
            scene.rootNode.runAction(SCNAction.sequence(actions)) {
                self.animationRunning = false
                self.solver = SolverCross(c: cube)
                cube.printCube()
                self.nextStep = self.solver!.getNextStep()
                cube.printCube()
                self.displayStep = stepsToString(steps: self.nextStep.steps)
                self.step = "Solve Cross"
                DispatchQueue.main.async {
                    self.nextStepOutlet.setTitle("White On Top", for: .normal)  
                }
            }
        }
        
    }
    
    var nextStep:SolvingStep = SolvingStep(description: "", actions: [], steps: [])
    @IBOutlet weak var nextSteps: UILabel!
    @IBOutlet weak var nextStepOutlet: UIButton!
    @IBAction func nextStepButton(_ sender: Any) {
        if let s = solver{
            let actions = self.nextStep.actions
            self.animationRunning = true
            sceneView.scene?.rootNode.runAction(SCNAction.sequence(actions)){
                self.animationRunning = false
            }
            if !s.hasNextStep(){
                if s is SolverCross {
                    solver = SolverFirstCorners(cube: Cube!)
                }
                else if s is SolverFirstCorners{
                    solver = SolverMiddle(cube: Cube!)
                }
                else if s is SolverMiddle{
                    solver = SolverLastCrossBB(cube: Cube!)
                }
                else if s is SolverLastCrossBB{
                    solver = SolverLLWedgePossitions(cube: Cube!)
                }
                else if s is SolverLLWedgePossitions{
                    solver = SolverBeginnerLLCornersPosition(cube: Cube!)
                }
                else if s is SolverBeginnerLLCornersPosition{
                    solver = SolverBeginnerLLCornersOrientation(cube: Cube!)
                }
            }
        }
        if let s = solver{
            DispatchQueue.main.async {
                self.nextStepOutlet.setTitle(s.nameOfStep(), for: .normal)
                self.nextStep = s.getNextStep()
                self.displayStep = stepsToString(steps: self.nextStep.steps)
            }
        }
    }
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBAction func durationChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.durationLabel.text = String(format: "%.2f", sender.value)
        }
        self.Cube?.duration = Double(sender.value)
        if var s = solver {
            self.Cube?.undoTurns(steps: self.nextStep.steps)
            self.nextStep = s.reloadSteps()
        }
    }
    
    func disableEnableButtons() {
        DispatchQueue.main.async {
            self.scrambleButton.isEnabled = !self.scrambleButton.isEnabled
            self.nextStepOutlet.isEnabled = !self.nextStepOutlet.isEnabled
        }
    }
    
    // MARK: variables
    //The actual cube in code
    var Cube:RubiksCube? = nil
    // anmations for label
    let animation = CATransition()
    let animationKey = convertFromCATransitionType(CATransitionType.push)
    // Scene
    var scene : SCNScene!
    //Motion
    let motion = CMMotionManager()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    var ringBuffer = RingBuffer()
    var isWaitingForMotionData = false
    var model:Model? = nil
    var step = "Solved"{
        didSet{
            DispatchQueue.main.async {
                self.stepText.text = self.step
            }
        }
    }
    var displayStep = "" {
        didSet{
            DispatchQueue.main.async {
                self.nextSteps.text = self.displayStep
            }
        }
    }
    // While we are running an animation prevent more
    var animationRunning = false {
        didSet {
            disableEnableButtons()
        }
    }
    //server
    weak private var serverModel:ServerModel? = ServerModel.sharedInstance
    
    var solverIndex = 0
    var solver:SolverBase? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // for nice animations on the text
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = convertToCATransitionType(animationKey)
        animation.duration = 0.5
        sceneView.frame = self.view.frame
        //Start Listening to motion updates
        self.startMotionUpdates()
        self.isWaitingForMotionData = true
        
        self.durationLabel.text = String(format: "%.2f", 1.0)
        self.Cube?.duration = 1.0
        
        self.nextStepOutlet.titleLabel?.numberOfLines = 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.backgroundColor = .black
        addCubes()
        self.Cube?.duration = 1.0
    }
    
    //To be called on init.  This will populate self.cubes which will contain all the inforatiom about the cube, and cubelets for the graphic
    func addCubes(){
        guard let sceneView = sceneView else {
            return
        }
        
        if Cube == nil {
            self.Cube = RubiksCube()
        }
        
        scene = Cube?.getScene()
        sceneView.scene = scene
    }
    //MARK: Motion code
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
        })
    }
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 1.0/200
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion )
        }
    }
    //Closure to be used when listening to motion
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
            let mag = fabs(accel.x)+fabs(accel.y)+fabs(accel.z)
            
            if mag > 1 && !animationRunning {
                // buffer up a bit more data and then notify of occurrence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        // something large enough happened to warrant
                        self.largeMotionEventOccurred()
                    
                })
            }
        }
    }
    func largeMotionEventOccurred(){
        if(self.isWaitingForMotionData)
        {
            self.isWaitingForMotionData = false
            //predict a label
            // TODO: Hard coded model, needs to be changed.
            if let cube = Cube{
                var modelString:String = ""
                var dsid:Int = 0
                if let m = self.model{
                    modelString = m.model
                    dsid = m.dsid
                }
                serverModel?.getPrediction(self.ringBuffer.getDataAsVector(), dsid:dsid, model: modelString){
                    resp in
                        if resp == "x90" {
                            self.scene.rootNode.runAction(cube.rotateAllX(direction: 1))
                        }else if resp == "xNeg90" {
                            self.scene.rootNode.runAction(cube.rotateAllX(direction: -1))
                        }else if resp == "y90" {
                            self.scene.rootNode.runAction(cube.rotateAllY(direction: 1))
                        }else if resp == "yNeg90" {
                            self.scene.rootNode.runAction(cube.rotateAllY(direction: -1))
                        }else if resp == "z90" {
                            self.scene.rootNode.runAction(cube.rotateAllZ(direction: 1))
                        }else if resp == "zNeg90" {
                            self.scene.rootNode.runAction(cube.rotateAllZ(direction: -1))
                        }else if resp == "x180" {
                            self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllX(direction: 1), cube.rotateAllX(direction: 1)]))
                        }else if resp == "xNeg180" {
                            self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllX(direction: -1), cube.rotateAllX(direction: -1)]))
                        }else if resp == "y180" {
                            self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllY(direction: 1), cube.rotateAllY(direction: 1)]))
                        }else if resp == "yNeg180" {
                            self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllY(direction: -1), cube.rotateAllY(direction: -1)]))
                        }else if resp == "z180" {
                            self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllZ(direction: 1), cube.rotateAllZ(direction: 1)]))
                        }else if resp == "zNeg180" {
                            self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllZ(direction: -1), cube.rotateAllZ(direction: -1)]))
                        }
                }
            }
            // dont predict again for a bit
            setDelayedWaitingToTrue(0.5)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionType(_ input: CATransitionType) -> String {
    return input.rawValue
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
    return CATransitionType(rawValue: input)
}


func stepsToString(steps:[Turn]) -> String {
    var stepsString = ""
    for i in 0..<steps.count {
        let step = steps[i]
        switch step {
        case .U:
            stepsString += "U"
            break;
        case .UN:
            stepsString += "UN"
            break;
        case .D:
            stepsString += "D"
            break;
        case .DN:
            stepsString += "DN"
            break;
        case .R:
            stepsString += "R"
            break;
        case .RN:
            stepsString += "RN"
            break;
        case .L:
            stepsString += "L"
            break;
        case .LN:
            stepsString += "LN"
            break;
        case .F:
            stepsString += "F"
            break;
        case .FN:
            stepsString += "FN"
            break;
        case .B:
            stepsString += "B"
            break;
        case .BN:
            stepsString += "BN"
            break;
        case .M:
            stepsString += "M"
            break;
        case .MN:
            stepsString += "MN"
            break;
        case .S:
            stepsString += "S"
            break;
        case .SN:
            stepsString += "SN"
            break;
        case .E:
            stepsString += "E"
            break;
        case .EN:
            stepsString += "EN"
            break;
        case .U2:
            stepsString += "U2"
            break;
        case .D2:
            stepsString += "D2"
            break;
        case .F2:
            stepsString += "F2"
            break;
        case .B2:
            stepsString += "B2"
            break;
        case .L2:
            stepsString += "L2"
            break;
        case .R2:
            stepsString += "R2"
            break;
        case .M2:
            stepsString += "M2"
            break;
        case .E2:
            stepsString += "E2"
            break;
        case .S2:
            stepsString += "S2"
            break;
        case .X:
            stepsString += "X"
            break;
        case .XN:
            stepsString += "XN"
            break;
        case .X2:
            stepsString += "X2"
            break;
        case .Y:
            stepsString += "Y"
            break;
        case .YN:
            stepsString += "YN"
            break;
        case .Y2:
            stepsString += "Y2"
            break;
        case .Z:
            stepsString += "Z"
            break;
        case .ZN:
            stepsString += "ZN"
            break;
        case .Z2:
            stepsString += "Z2"
            break;
        }
        if i != steps.count-1 {
            stepsString += ","
        }
    }
    return stepsString
}
