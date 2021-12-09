//
//  PredictionViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.
//

import UIKit
import SceneKit
import CoreMotion
import CoreML

class CubeController: UIViewController {
    
    lazy var loadedModel:ModelDsId4 = {
        do{
            let config = MLModelConfiguration()
            return try ModelDsId4(configuration: config)
        }catch{
            print(error)
            fatalError("Could not load ModelDsId4")
        }
    }()
    // MARK: Outlets
    @IBOutlet weak var sceneView: SCNView!
    //Button Outlets
    @IBOutlet weak var uNegButton: UIButton!
    @IBOutlet weak var uButton: UIButton!
    @IBOutlet weak var dNegButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var rNegButton: UIButton!
    @IBOutlet weak var rButton: UIButton!
    @IBOutlet weak var lNegButton: UIButton!
    @IBOutlet weak var lButton: UIButton!
    @IBOutlet weak var bNegButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var fNegButton: UIButton!
    @IBOutlet weak var fButton: UIButton!
    // Full cube
    @IBOutlet weak var xOutlet: UIButton!
    @IBAction func xRotate(_ sender: Any) {
        if let cube = Cube{
            self.animationRunning = true
            scene.rootNode.runAction(cube.rotateAllX(direction:1)) {
                self.animationRunning = false
            }
        }
    }
    @IBOutlet weak var xNegOutlet: UIButton!
    @IBAction func xRotateNeg(_ sender: Any) {
        if let cube = Cube{
            self.animationRunning = true
            scene.rootNode.runAction(cube.rotateAllX(direction:-1)) {
                self.animationRunning = false
            }
        }
    }
    @IBOutlet weak var yOutlet: UIButton!
    @IBAction func yRotate(_ sender: Any) {
        if let cube = Cube{
            self.animationRunning = true
            scene.rootNode.runAction(cube.rotateAllY(direction:1)) {
                self.animationRunning = false
            }
        }
    }
    @IBOutlet weak var yNegOutlet: UIButton!
    @IBAction func yRotateNeg(_ sender: Any) {
        if let cube = Cube{
            self.animationRunning = true
            scene.rootNode.runAction(cube.rotateAllY(direction:-1)) {
                self.animationRunning = false
            }
        }
    }
    @IBOutlet weak var zOutlet: UIButton!
    @IBAction func zRotate(_ sender: Any) {
        if let cube = Cube{
            self.animationRunning = true
            scene.rootNode.runAction(cube.rotateAllZ(direction:1)) {
                self.animationRunning = false
            }
        }
    }
    @IBOutlet weak var zNegOutlet: UIButton!
    @IBAction func zRotateNeg(_ sender: Any) {
        if let cube = Cube{
            self.animationRunning = true
            scene.rootNode.runAction(cube.rotateAllZ(direction:-1)) {
                self.animationRunning = false
            }
        }
    }
    
    // One face
    @IBAction func upTurn(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.upTurn(direction: 1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func upTurnNeg(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.upTurn(direction: -1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func downTurn(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.downTurn(direction: 1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func downTurnNeg(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.downTurn(direction: -1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func rightTurn(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.rightTurn(direction: 1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func rightTurnNeg(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.rightTurn(direction: -1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func leftTurn(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.leftTurn(direction: 1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func leftTurnNeg(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.leftTurn(direction: -1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func backTurn(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.backTurn(direction: 1)) {
                self.animationRunning = false
            }
        }
    }
    @IBAction func backTurnNeg(_ sender: Any) {
        if let cube = Cube {
            self.animationRunning = true
            scene.rootNode.runAction(cube.backTurn(direction: -1)) {
                self.animationRunning = false
            }
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
            self.animationRunning = true
            scene.rootNode.runAction(cube.frontTurn(direction: -1)) {
                self.animationRunning = false
            }
        }
    }
    
    @IBOutlet weak var stepText: UILabel!
    @IBOutlet weak var scrambleButton: UIButton!
    @IBAction func scrambleCube(_ sender: Any) {
        if let cube = Cube {
            let _ = cube.undoTurns(steps: self.nextStep.steps)
            let actions = cube.scramble(turnsCount: 30)
            self.animationRunning = true
            scene.rootNode.runAction(SCNAction.sequence(actions)) {
                self.animationRunning = false
                self.solver = SolverCross(c: cube)
                self.nextStep = self.solver!.getNextStep()
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
            
                if !s.hasNextStep(){
                    if s is SolverCross {
                        self.solver = SolverFirstCorners(cube: self.Cube!)
                    }
                    else if s is SolverFirstCorners{
                        self.solver = SolverMiddle(cube: self.Cube!)
                    }
                    else if s is SolverMiddle{
                        self.solver = SolverLastCrossBB(cube: self.Cube!)
                    }
                    else if s is SolverLastCrossBB{
                        self.solver = SolverLLWedgePossitions(cube: self.Cube!)
                    }
                    else if s is SolverLLWedgePossitions{
                        self.solver = SolverBeginnerLLCornersPosition(cube: self.Cube!)
                    }
                    else if s is SolverBeginnerLLCornersPosition{
                        self.solver = SolverBeginnerLLCornersOrientation(cube: self.Cube!)
                    }
                }
            }
            if let s = self.solver{
                DispatchQueue.main.async {
                    self.nextStepOutlet.setTitle(s.nameOfStep(), for: .normal)
                    self.nextStep = s.getNextStep()
                    self.displayStep = stepsToString(steps: self.nextStep.steps)
                    self.stepText.text = s.stepString
                }
            }
        }
    }
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var durationSlider: UISlider!
    @IBAction func durationChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.durationLabel.text = String(format: "%.2f", sender.value)
        }
        self.Cube?.duration = Double(sender.value)
        if var s = solver {
            let _ = self.Cube?.undoTurns(steps: self.nextStep.steps)
            self.nextStep = s.reloadSteps()
        }
    }
    
    func disableAnimationDependentUI() {
        DispatchQueue.main.async {
            self.scrambleButton.isEnabled = !self.scrambleButton.isEnabled
            self.nextStepOutlet.isEnabled = !self.nextStepOutlet.isEnabled
            self.durationSlider.isEnabled = !self.durationSlider.isEnabled
            self.uButton.isEnabled = !self.uButton.isEnabled
            self.uNegButton.isEnabled = !self.uNegButton.isEnabled
            self.dButton.isEnabled = !self.dButton.isEnabled
            self.dNegButton.isEnabled = !self.dNegButton.isEnabled
            self.rButton.isEnabled = !self.rButton.isEnabled
            self.rNegButton.isEnabled = !self.rNegButton.isEnabled
            self.lButton.isEnabled = !self.lButton.isEnabled
            self.lNegButton.isEnabled = !self.lNegButton.isEnabled
            self.fButton.isEnabled = !self.fButton.isEnabled
            self.fNegButton.isEnabled = !self.fNegButton.isEnabled
            self.bButton.isEnabled = !self.bButton.isEnabled
            self.bNegButton.isEnabled = !self.bNegButton.isEnabled
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
    var hideTurnUI = false
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
            disableAnimationDependentUI()
        }
    }
    
    
    // MARK: View Set up methods
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
        self.toggleHideMovingButtons(setting: true)
        self.nextStepOutlet.titleLabel?.numberOfLines = 2
    }
    func setImageToButton(button:UIButton, image:String){
        DispatchQueue.main.async {
            let i = UIImage(named: image)
            button.setImage(i, for: .normal)
            button.setTitle("", for: .normal)
        }
    }
    func toggleHideMovingButtons(setting:Bool) {
        DispatchQueue.main.async {
            self.fButton.isHidden = setting
            self.fNegButton.isHidden = setting
            self.lButton.isHidden = setting
            self.lNegButton.isHidden = setting
            self.rButton.isHidden = setting
            self.rNegButton.isHidden = setting
            self.bButton.isHidden = setting
            self.bNegButton.isHidden = setting
            self.uButton.isHidden = setting
            self.uNegButton.isHidden = setting
            self.dButton.isHidden = setting
            self.dNegButton.isHidden = setting
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.backgroundColor = .black
        addCubes()
        self.Cube?.duration = 1.0
        DispatchQueue.main.async {
            guard let cube = self.Cube else {
                return
            }
            //fButton
            let point1 = self.sceneView.projectPoint(cube.cublet(at: 1).node.position)
            let fPoint = CGPoint(x:CGFloat(point1.x), y:CGFloat(point1.y) + self.fButton.frame.height*1.5)
            self.fButton.frame.origin = fPoint
            self.setImageToButton(button: self.fButton, image: "f")
            //fNegButton
            let point25 = self.sceneView.projectPoint(cube.cublet(at: 25).node.position)
            let fNegPoint = CGPoint(x:CGFloat(point25.x) - self.fNegButton.frame.width*1, y:CGFloat(point25.y) - self.fNegButton.frame.height*2)
            self.fNegButton.frame.origin = fNegPoint
            self.setImageToButton(button: self.fNegButton, image: "fneg")
            
            //uButton
            let uPoint = CGPoint(x:CGFloat(point25.x) - self.uButton.frame.width*2.1, y:CGFloat(point25.y) - self.uButton.frame.height*0.8)
            self.uButton.frame.origin = uPoint
            self.setImageToButton(button: self.uButton, image: "u")
            //uNegButton
            let point21 = self.sceneView.projectPoint(cube.cublet(at: 21).node.position)
            let uNegPoint = CGPoint(x:CGFloat(point21.x) + self.uNegButton.frame.width, y:CGFloat(point21.y) - self.uButton.frame.height)
            self.uNegButton.frame.origin = uNegPoint
            self.setImageToButton(button: self.uNegButton, image: "uneg")
            
            //dButton
            let point3 = self.sceneView.projectPoint(cube.cublet(at: 3).node.position)
            let dPoint = CGPoint(x:CGFloat(point3.x) + self.dButton.frame.width*1.5, y:CGFloat(point3.y))
            self.dButton.frame.origin = dPoint
            self.setImageToButton(button: self.dButton, image: "d")
            //dNegButton
            let point7 = self.sceneView.projectPoint(cube.cublet(at: 7).node.position)
            let dNegPoint = CGPoint(x:CGFloat(point7.x) - self.dButton.frame.width*2.2, y:CGFloat(point7.y))
            self.dNegButton.frame.origin = dNegPoint
            self.setImageToButton(button: self.dNegButton, image: "dneg")

            
            //rButton
            let rPoint = CGPoint(x:CGFloat(point1.x) - self.rButton.frame.width*1.1, y:CGFloat(point1.y) + self.rButton.frame.height*1.5)
            self.rButton.frame.origin = rPoint
            self.setImageToButton(button: self.rButton, image: "r")
            //rNegButton
            let rNegPoint = CGPoint(x:CGFloat(point21.x), y:CGFloat(point21.y) - self.rNegButton.frame.height*2)
            self.rNegButton.frame.origin = rNegPoint
            self.setImageToButton(button: self.rNegButton, image: "rneg")
            
            //lButton
            let point27 = self.sceneView.projectPoint(cube.cublet(at: 27).node.position)
            let lPoint = CGPoint(x:CGFloat(point27.x) + self.lButton.frame.width*0.1, y:CGFloat(point27.y) - self.lNegButton.frame.height*2)
            self.lButton.frame.origin = lPoint
            self.setImageToButton(button: self.lButton, image: "l")
            //lNegButton
            let lNegPoint = CGPoint(x:CGFloat(point7.x) - self.lNegButton.frame.width, y:CGFloat(point7.y) + self.lNegButton.frame.height)
            self.lNegButton.frame.origin = lNegPoint
            self.setImageToButton(button: self.lNegButton, image: "lneg")
            
            //bButton
            let bPoint = CGPoint(x:CGFloat(point27.x) - self.bButton.frame.width + 2, y:CGFloat(point27.y) - self.bButton.frame.height*2)
            self.bButton.frame.origin = bPoint
            self.setImageToButton(button: self.bButton, image: "b")
            //bNegButton
            let bNegPoint = CGPoint(x:CGFloat(point3.x), y:CGFloat(point3.y) + self.bNegButton.frame.height*1.2)
            self.bNegButton.frame.origin = bNegPoint
            self.setImageToButton(button: self.bNegButton, image: "bneg")
            
            if self.runningThroughTurns {
                self.hideManipluationUIElements()
                self.stepText.text = "\(stepsToString(steps: [self.turnDurations[self.currentTurn]]))"
                self.runNextTurn()
            } else if !self.solveOnly{
                self.toggleHideMovingButtons(setting: false)
            }
        }
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
    
    var runningThroughTurns = false
    var solveOnly = false
    let turnDurations:[Turn] = [.U, .UN, .D, .DN, .R, .RN, .L, .LN, .F, .FN, .B, .BN,
                                .X, .XN, .Y, .YN, .Z, .ZN]
    var currentTurn = 0
    func runNextTurn() {
        let actions = Cube!.getTurnActions(turns: [turnDurations[currentTurn]])
        currentTurn = (currentTurn + 1)%turnDurations.count
        scene.rootNode.runAction(SCNAction.sequence(actions)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.stepText.text = "\(stepsToString(steps: [self.turnDurations[self.currentTurn]]))"
                self.runNextTurn()
            }
        }
    }
    
    func hideManipluationUIElements() {
        runningThroughTurns = true
        DispatchQueue.main.async {
            self.uButton.isHidden = true
            self.uNegButton.isHidden = true
            self.dButton.isHidden = true
            self.dNegButton.isHidden = true
            self.rButton.isHidden = true
            self.rNegButton.isHidden = true
            self.lButton.isHidden = true
            self.lNegButton.isHidden = true
            self.fButton.isHidden = true
            self.fNegButton.isHidden = true
            self.bButton.isHidden = true
            self.bNegButton.isHidden = true
            self.xOutlet.isHidden = true
            self.xNegOutlet.isHidden = true
            self.yOutlet.isHidden = true
            self.yNegOutlet.isHidden = true
            self.zOutlet.isHidden = true
            self.zNegOutlet.isHidden = true
            self.durationSlider.isHidden = true
            self.durationLabel.isHidden = true
            self.scrambleButton.isHidden = true
            self.nextStepOutlet.isHidden = true
        }
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
        if(!self.animationRunning && self.isWaitingForMotionData && !self.runningThroughTurns && !self.solveOnly)
        {
            self.isWaitingForMotionData = false
            //predict a label
            if let cube = Cube{
                do {
                    let array = try MLMultiArray(self.ringBuffer.getDataAsVector())
                    let input = ModelDsId4Input(sequence: array)
                    let ret = try loadedModel.prediction(input: input).target
                    
                    self.animationRunning = true
                    if ret == "x90" {
                        self.scene.rootNode.runAction(cube.rotateAllX(direction: 1)) {
                            self.animationRunning = false
                        }
                    }else if ret == "xNeg90" {
                        self.scene.rootNode.runAction(cube.rotateAllX(direction: -1)) {
                            self.animationRunning = false
                        }
                    }else if ret == "y90" {
                        self.scene.rootNode.runAction(cube.rotateAllY(direction: 1)) {
                            self.animationRunning = false
                        }
                    }else if ret == "yNeg90" {
                        self.scene.rootNode.runAction(cube.rotateAllY(direction: -1)) {
                            self.animationRunning = false
                        }
                    }else if ret == "z90" {
                        self.scene.rootNode.runAction(cube.rotateAllZ(direction: 1)) {
                            self.animationRunning = false
                        }
                    }else if ret == "zNeg90" {
                        self.scene.rootNode.runAction(cube.rotateAllZ(direction: -1)) {
                            self.animationRunning = false
                        }
                    }else if ret == "x180" {
                        self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllX(direction: 1), cube.rotateAllX(direction: 1)])) {
                            self.animationRunning = false
                        }
                    }else if ret == "xNeg180" {
                        self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllX(direction: -1), cube.rotateAllX(direction: -1)])) {
                            self.animationRunning = false
                        }
                    }else if ret == "y180" {
                        self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllY(direction: 1), cube.rotateAllY(direction: 1)])) {
                            self.animationRunning = false
                        }
                    }else if ret == "yNeg180" {
                        self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllY(direction: -1), cube.rotateAllY(direction: -1)])) {
                            self.animationRunning = false
                        }
                    }else if ret == "z180" {
                        self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllZ(direction: 1), cube.rotateAllZ(direction: 1)])) {
                            self.animationRunning = false
                        }
                    }else if ret == "zNeg180" {
                        self.scene.rootNode.runAction(SCNAction.sequence([cube.rotateAllZ(direction: -1), cube.rotateAllZ(direction: -1)])) {
                            self.animationRunning = false
                        }
                    }
                }
                catch _{
                   print("failed to classify")
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
            stepsString += "U'"
            break;
        case .D:
            stepsString += "D"
            break;
        case .DN:
            stepsString += "D'"
            break;
        case .R:
            stepsString += "R"
            break;
        case .RN:
            stepsString += "R'"
            break;
        case .L:
            stepsString += "L"
            break;
        case .LN:
            stepsString += "L'"
            break;
        case .F:
            stepsString += "F"
            break;
        case .FN:
            stepsString += "F'"
            break;
        case .B:
            stepsString += "B"
            break;
        case .BN:
            stepsString += "B'"
            break;
        case .M:
            stepsString += "M"
            break;
        case .MN:
            stepsString += "M'"
            break;
        case .S:
            stepsString += "S"
            break;
        case .SN:
            stepsString += "S'"
            break;
        case .E:
            stepsString += "E"
            break;
        case .EN:
            stepsString += "E'"
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
            stepsString += "X'"
            break;
        case .X2:
            stepsString += "X2"
            break;
        case .Y:
            stepsString += "Y"
            break;
        case .YN:
            stepsString += "Y'"
            break;
        case .Y2:
            stepsString += "Y2"
            break;
        case .Z:
            stepsString += "Z"
            break;
        case .ZN:
            stepsString += "Z'"
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
