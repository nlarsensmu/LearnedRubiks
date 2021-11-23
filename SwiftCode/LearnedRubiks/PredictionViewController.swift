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
    
    @IBOutlet weak var scrambleButton: UIButton!
    @IBAction func scrambleCube(_ sender: Any) {
        print("Scramble")
        if let cube = Cube {
            let actions = cube.scramble()
            self.animationRunning = true
            scene.rootNode.runAction(SCNAction.sequence(actions)) {
                self.animationRunning = false
                self.Cube?.printCube()
            }
            step = 0
            DispatchQueue.main.async {
                self.solveButtonOutlet.titleLabel?.text = self.steps[self.step]
            }
        }
        
    }
    
    @IBOutlet weak var solveButtonOutlet: UIButton!
    @IBAction func solveButton(_ sender: Any) {
        
        if step == 0 {
            let crossSolver = SolverCross(c: self.Cube!)
            runSolver(solver: crossSolver)
        }
        
        if step == 1 {
            let cornerSolver = SolverFirstCorners(cube: self.Cube!)
            runSolver(solver: cornerSolver)
        }
        if step == 2 {
            let middleSolver = SolverMiddle(cube: self.Cube!)
            runSolver(solver: middleSolver)
        }
        if step == 3 {
            let lastSolver = SolverLastCrossBB(cube: self.Cube!)
            runSolver(solver: lastSolver)
        }
        if step == 4 {
            let solver = SolverLLWedgePossitions(cube:self.Cube!)
            runSolver(solver: solver)
        }
        if step == 5 {
            let solver = SolverBeginnerLLCornersPosition(cube:self.Cube!)
            runSolver(solver: solver)
        }
        if step == 6 {
            let solver = SolverBeginnerLLCornersOrientation(cube:self.Cube!)
            runSolver(solver: solver)
        }
        
        step = (step + 1) % steps.count
        DispatchQueue.main.async {
            self.solveButtonOutlet.setTitle(self.steps[self.step], for: .normal)
        }
    }
    
    func runSolver(solver:SolverBase) {
        let actions = solver.solve()
        self.animationRunning = true
        scene.rootNode.runAction(SCNAction.sequence(actions)) {
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
    
    var step = 0
    let steps = ["Solve Cross", "Solve Corners", "Solve Middle", "Solve Last Cross",
                 "Position Wedges", "Solver Position Last Corners", "Rotate Last Corners"]

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
            return .portraitUpsideDown
        }
    }
    //To be called on init.  This will populate self.cubes which will contain all the inforatiom about the cube, and cubelets for the graphic
    func addCubes(){
        guard let sceneView = sceneView else {
            return
        }
        
        let right:[CubletColor] = [.blue,.yellow,.white,.green,.red,.red,.yellow,.red,.green]
        let left:[CubletColor] =  [.green,.white,.blue,.white,.orange,.blue,.orange,.white,.white]
        let front:[CubletColor] = [.red,.yellow,.red,.orange,.yellow,.orange,.orange,.blue,.blue]
        let back:[CubletColor] =  [.blue,.red,.orange,.blue,.white,.yellow,.red,.yellow,.green]
        let up:[CubletColor] =    [.green,.white,.white,.orange,.green,.red,.yellow,.blue,.orange]
        let down:[CubletColor] =  [.yellow,.green,.red,.orange,.blue,.green,.yellow,.green,.white]
        self.Cube = RubiksCube(front: front, left: left, right: right, up: up, down:down, back: back)
        self.Cube?.printCube()
        //				self.Cube = RubiksCube()
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


