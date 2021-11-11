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
    // MARK: Class Constants
    var minPoint:Float = -0.55
    var midPoint:Float = 0.0
    var maxPoint:Float = 0.55
    // MARK: Outlets
    var cubes:[SCNNode] = []
    var imageToShow = "texture" // replace this with the image name, in segue to controller
    @IBOutlet weak var sceneView: SCNView!
    @IBAction func xRotate(_ sender: Any) {
        self.rotateAllX(direction:1)
    }
    @IBAction func xRotateNeg(_ sender: Any) {
        self.rotateAllX(direction:-1)
    }
    @IBAction func yRotate(_ sender: Any) {
        self.rotateAllY(direction:1)
    }
    @IBAction func yRotateNeg(_ sender: Any) {
        self.rotateAllY(direction:-1)
    }
    @IBAction func zRotate(_ sender: Any) {
        self.rotateAllZ(direction:1)
    }
    @IBAction func zRotateNeg(_ sender: Any) {
        self.rotateAllZ(direction:-1)
    }
    // MARK: variables
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // for nice animations on the text
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = convertToCATransitionType(animationKey)
        animation.duration = 0.5
        sceneView.frame = self.view.frame
        self.startMotionUpdates()
        self.isWaitingForMotionData = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.backgroundColor = .black
        addCubes()
    }
    // anmations for label
    let animation = CATransition()
    let animationKey = convertFromCATransitionType(CATransitionType.push)
    // SCN setup
    var scene : SCNScene!
    var cameraNode : SCNNode!
    var wallNode: SCNNode!
    var motionManager : CMMotionManager!
    var initialAttitude: (roll: Double, pitch:Double, yaw:Double)?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portraitUpsideDown
        }
    }
    func addCubes(){
        guard let sceneView = sceneView else {
            return
        }
        
        // Setup Original Scene
        scene = SCNScene()
        // load living room model we created in sketchup
        let cubes = SCNScene(named: "Cube.scn")!
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"1"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"2"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"3"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"4"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"5"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"6"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"7"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"8"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"9"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"10"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"11"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"12"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"13"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"14"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"15"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"16"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"17"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"18"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"19"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"20"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"21"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"22"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"23"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"24"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"25"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"26"))
        self.cubes.append(addCube(scene:scene,cubes:cubes, number:"27"))
        // Setup camera position from existing scene
        cameraNode = cubes.rootNode.childNode(withName: "camera1", recursively: true)!
        scene.rootNode.addChildNode(cameraNode)
        
        // make this the scene in the view
        sceneView.scene = scene
        
        //Debugging
        sceneView.showsStatistics = true
    
    }
    func getMaterials(colors:[UIColor]) -> [SCNMaterial]{
        return colors.map { color -> SCNMaterial in
                let material = SCNMaterial()
                material.diffuse.contents = color
            return material
        }
    }
    func addCube(scene:SCNScene, cubes:SCNScene, number:String) -> SCNNode{
        let cube = cubes.rootNode.childNode(withName: "cube\(number)", recursively: true)!
        scene.rootNode.addChildNode(cube)
        return cube
    }
    
    private func rotateAllX(direction:Int, angle:Float = .pi/2){
        var percentage = 0.0
        let rotationAction = SCNAction.customAction(duration: 0.25) { (node, elapsedTime) -> () in
            if percentage == 0.0 {
                percentage = elapsedTime / 0.25
            }
            let rot = SCNMatrix4MakeRotation(Float(direction) * (angle) * (Float(percentage)), 0, 1, 0)
            let rot2 = SCNMatrix4Mult(node.transform, rot)
            node.transform = rot2
        }
        for cube in self.cubes{
            cube.runAction(rotationAction)
        }
    }
    private func rotateAllY(direction:Int, angle:Float = .pi/2){
        var percentage = 0.0
        let rotationAction = SCNAction.customAction(duration: 0.25) { (node, elapsedTime) -> () in
            if percentage == 0.0 {
                percentage = elapsedTime / 0.25
            }
            let rot = SCNMatrix4MakeRotation(Float(direction) * (angle) * (Float(percentage)), 0, 0, 1)
            let rot2 = SCNMatrix4Mult(node.transform, rot)
            node.transform = rot2
        }
        for cube in self.cubes{
            cube.runAction(rotationAction)
        }
    }
    private func rotateAllZ(direction:Int, angle:Float = .pi/2){
        var percentage = 0.0
        let rotationAction = SCNAction.customAction(duration: 0.25) { (node, elapsedTime) -> () in
            if percentage == 0.0 {
                percentage = elapsedTime / 0.25
            }
            let rot = SCNMatrix4MakeRotation(Float(direction) * (angle) * (Float(percentage)), 1, 0, 0)
            let rot2 = SCNMatrix4Mult(node.transform, rot)
            node.transform = rot2
        }
        for cube in self.cubes{
            cube.runAction(rotationAction)
        }
    }
    
    private func xRotateToVector(cube:SCNNode) -> SCNVector3?{
        //All the corner cases
        if cube.position.x == minPoint  && cube.position.z ==  maxPoint {
            return SCNVector3(maxPoint,cube.position.y,maxPoint)
        }
        else if cube.position.x == maxPoint  && cube.position.z ==  maxPoint {
            return SCNVector3(maxPoint,cube.position.y,minPoint)
        }
        else if cube.position.x == maxPoint  && cube.position.z ==  minPoint {
            return SCNVector3(minPoint,cube.position.y,minPoint)
        }
        else if cube.position.x == minPoint  && cube.position.z ==  minPoint {
            return SCNVector3(minPoint,cube.position.y,maxPoint)
        }
        return nil
    }
    
    //MARK: Motion code
    let motion = CMMotionManager()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    var ringBuffer = RingBuffer()
    var isWaitingForMotionData = false
    weak private var serverModel:ServerModel? = ServerModel.sharedInstance
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
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
            let mag = fabs(accel.x)+fabs(accel.y)+fabs(accel.z)
            
            if mag > 1 {
                // buffer up a bit more data and then notify of occurrence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.calibrationOperationQueue.addOperation {
                        // something large enough happened to warrant
                        self.largeMotionEventOccurred()
                    }
                })
            }
        }
    }
    func largeMotionEventOccurred(){
        if(self.isWaitingForMotionData)
        {
            self.isWaitingForMotionData = false
            //predict a label
            serverModel?.getPrediction(self.ringBuffer.getDataAsVector(), dsid:4){
                resp in
                print("Noticed a movement \(resp)")
                if resp == "x90" {
                    self.rotateAllX(direction: 1)
                }else if resp == "xNeg90" {
                    self.rotateAllX(direction: -1)
                }else if resp == "y90" {
                    self.rotateAllY(direction: 1)
                }else if resp == "yNeg90" {
                    self.rotateAllY(direction: -1)
                }else if resp == "z90" {
                    self.rotateAllZ(direction: 1)
                }else if resp == "zNeg90" {
                    self.rotateAllZ(direction: -1)
                }else if resp == "x180" {
                    self.rotateAllX(direction: 1, angle:.pi)
                }else if resp == "xNeg180" {
                    self.rotateAllX(direction: -1, angle:.pi)
                }else if resp == "y180" {
                    self.rotateAllY(direction: 1, angle:.pi)
                }else if resp == "yNeg180" {
                    self.rotateAllY(direction: -1, angle:.pi)
                }else if resp == "z180" {
                    self.rotateAllZ(direction: 1, angle:.pi)
                }else if resp == "zNeg180" {
                    self.rotateAllZ(direction: -1, angle:.pi)
                }
            }
            // dont predict again for a bit
            setDelayedWaitingToTrue(2.0)

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

