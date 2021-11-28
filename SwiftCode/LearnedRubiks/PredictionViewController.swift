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
            let actions = cube.scramble(turnsCount: 30)
            self.animationRunning = true
            scene.rootNode.runAction(SCNAction.sequence(actions)) {
                self.animationRunning = false
<<<<<<< HEAD
                self.solverIndex = 0
                self.solver = SolverCross(c: cube)
                self.step = "Solve Cross"
                DispatchQueue.main.async {
                    self.solveButtonOutlet.titleLabel?.text = "beggining"
                }
=======
                self.Cube?.printCube()
            }
            step = 0
            DispatchQueue.main.async {
                self.solveButtonOutlet.titleLabel?.text = self.steps[self.step]
>>>>>>> master
            }
        }
        
    }
    
    @IBOutlet weak var solveButtonOutlet: UIButton!
    @IBAction func solveButton(_ sender: Any) {
        if let s = solver{
            let actions = s.getNextStep().steps
            sceneView.scene?.rootNode.runAction(SCNAction.sequence(actions))
            DispatchQueue.main.async {
                print(s.nameOfStep())
                self.solveButtonOutlet.titleLabel?.text = s.nameOfStep()
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
    }
    
    func runSolver(solver:SolverBase) {
        let step = solver.getNextStep()
        self.animationRunning = true
        scene.rootNode.runAction(SCNAction.sequence(step.steps)) {
            self.animationRunning = false
        }
    }
    func disableEnableButtons() {
        DispatchQueue.main.async {
            self.scrambleButton.isEnabled = !self.scrambleButton.isEnabled
            self.solveButtonOutlet.isEnabled = !self.solveButtonOutlet.isEnabled
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
    var currentSteps:[SolvingStep] = []
    var currentStepIndex = 0 {
        didSet{
            //TODO: update the insturction label
            if currentStepIndex == currentSteps.count{
                currentStepIndex = 0
                //TODO: update the self.currentSteps
                //TODO: update the Step label
            }
        }
    }
    var step = "Solved"{
        didSet{
            DispatchQueue.main.async {
                self.stepText.text = self.step
            }
        }
    }
    // While we are running an animation prevent more
    var _animationRunning:Bool = false
    var animationRunning:Bool {
        get {
            return _animationRunning
        }
        set {
            _animationRunning = newValue
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.backgroundColor = .black
        addCubes()
    }
    //Force the app to be portait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
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


