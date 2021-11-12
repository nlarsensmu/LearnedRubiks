//
//  RubiksCube.swift
//  LearnedRubiks
//
//  Created by Steven Larsen on 11/12/21.
//

import Foundation
import SceneKit

public class RubiksCube{
    private var cubelets:[Cublet] = []
    var scene = SCNScene()
    let cubes = SCNScene(named: "Cube.scn")!
    var cameraNode : SCNNode!
    
    //MARK: Setup functions
    public init(){
        for i in 1...27 {
            self.addCublet(number: String(i))
        }
        // Setup camera position from existing scene
        cameraNode = cubes.rootNode.childNode(withName: "camera1", recursively: true)!
        scene.rootNode.addChildNode(cameraNode)
    }
    public func addCublet(number:String){
        let node = cubes.rootNode.childNode(withName: "cube\(number)", recursively: true)!
        scene.rootNode.addChildNode(node)
        cubelets.append(Cublet(n:node))
    }
    public func getScene() -> SCNScene{
        return scene
    }
    
    //MARK: Whole cube rotations
    //Roate the cube angle amount in the X direction
    //NOTE direction should be -1 or 1 for positive X or negative X
    public func rotateAllX(direction:Int, angle:Float = .pi/2){
        var percentage = 0.0
        let rotationAction = SCNAction.customAction(duration: 0.25) { (node, elapsedTime) -> () in
            if percentage == 0.0 {
                percentage = elapsedTime / 0.25
            }
            let rot = SCNMatrix4MakeRotation(Float(direction)  * (-1) * (angle) * (Float(percentage)), 0, 0, 1)
            let rot2 = SCNMatrix4Mult(node.transform, rot)
            node.transform = rot2
        }
        for cube in self.cubelets{
            cube.node.runAction(rotationAction)
        }
    }
    //Roate the cube angle amount in the Y direction
    //NOTE direction should be -1 or 1 for positive Y or negative Y
    public func rotateAllY(direction:Int, angle:Float = .pi/2){
        var percentage = 0.0
        let rotationAction = SCNAction.customAction(duration: 0.25) { (node, elapsedTime) -> () in
            if percentage == 0.0 {
                percentage = elapsedTime / 0.25
            }
            let rot = SCNMatrix4MakeRotation(Float(direction) * (-1) * (angle) * (Float(percentage)), 0, 1, 0)
            let rot2 = SCNMatrix4Mult(node.transform, rot)
            node.transform = rot2
        }
        for cube in self.cubelets{
            cube.node.runAction(rotationAction)
        }
    }
    //Roate the cube angle amount in the Y direction
    //NOTE direction should be -1 or 1 for positive Y or negative Y
    public func rotateAllZ(direction:Int, angle:Float = .pi/2){
        var percentage = 0.0
        let rotationAction = SCNAction.customAction(duration: 0.25) { (node, elapsedTime) -> () in
            if percentage == 0.0 {
                percentage = elapsedTime / 0.25
            }
            let rot = SCNMatrix4MakeRotation(Float(direction) * (angle) * (Float(percentage)), 1, 0, 0)
            let rot2 = SCNMatrix4Mult(node.transform, rot)
            node.transform = rot2
        }
        for cube in self.cubelets{
            cube.node.runAction(rotationAction)
        }
    }
}
private class Cublet{
    var node:SCNNode
    init(n:SCNNode){
        node = n
    }
}
