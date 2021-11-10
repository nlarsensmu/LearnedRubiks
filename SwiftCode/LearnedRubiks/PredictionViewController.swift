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
        print("(\(self.cubes[0].position.x), \(self.cubes[0].position.y), \(self.cubes[0].position.z)), ROT:\(cubes[0].rotation)")
        self.rotateAllZ(direction:1)
    }
    // MARK: variables
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // for nice animations on the text
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = convertToCATransitionType(animationKey)
        animation.duration = 0.5
        sceneView.frame = self.view.frame
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
    private func rotateAllX(direction:Int){
        let angle:Float = .pi/2
        for cube in self.cubes{
            let rot = SCNMatrix4MakeRotation(Float(direction) * (.pi/2), 0, 1, 0)
            let rot2 = SCNMatrix4Mult(cube.transform, rot)
            cube.transform = rot2
        }
    }
    private func rotateAllY(direction:Int){
        let angle:Float = .pi/2
        for cube in self.cubes{
            let rot = SCNMatrix4MakeRotation(Float(direction) * (.pi/2), 1, 0, 0)
            let rot2 = SCNMatrix4Mult(cube.transform, rot)
            cube.transform = rot2
        }
    }
    private func rotateAllZ(direction:Int){
        let angle:Float = .pi/2
        for cube in self.cubes{
            let rot = SCNMatrix4MakeRotation(Float(direction) * (.pi/2), 0, 0, 1)
            let rot2 = SCNMatrix4Mult(cube.transform, rot)
            cube.transform = rot2
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

