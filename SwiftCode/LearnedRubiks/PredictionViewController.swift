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
    // MARK: variables
    var cubes:[SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // for nice animations on the text
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = convertToCATransitionType(animationKey)
        animation.duration = 0.5
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.backgroundColor = .black
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
        scene = SCNScene()
        let boxNode = createBox()
        scene.rootNode.addChildNode(boxNode)
        self.cubes[0]		 = boxNode

        sceneView.scene = scene
        sceneView.scene = scene
    }
    func createBox() -> SCNNode {
        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        material.specular.contents = UIColor(white: 0.6, alpha: 1.0)

        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.geometry?.materials = [material]

        return boxNode;
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

