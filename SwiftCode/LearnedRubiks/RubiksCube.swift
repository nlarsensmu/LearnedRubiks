//
//  RubiksCube.swift
//  LearnedRubiks
//
//  Created by Steven Larsen on 11/12/21.
//

import Foundation
import SceneKit

public class RubiksCube{
    //MARK: Variables
    private var cubelets:[Cublet] = []
    var scene = SCNScene()
    let cubes = SCNScene(named: "Cube.scn")!
    var cameraNode : SCNNode!
    let bottomPositions = [1, 2, 3, 4, 5, 6, 7, 8, 9 ]
    let upPositions     = [19,20,21,22,23,24,25,26,27]
    let rightPositions  = [1, 2, 3, 10,11,12,19,20,21]
    let leftPositions   = [7, 8, 9, 16,17,18,25,26,27]
    let frontPositions  = [1, 4, 7, 10,13,16,19,22,25]
    let backPositions   = [3, 6, 9, 12,15,18,21,24,27]
    //Rotation Array.  These will store the new pos at the index of the old pos
    //original positions    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
    let ZRotationPositive = [0, 7, 8, 9,16,17,18,25,26,27,4 ,5 , 6,13,14,15,22,23,24, 1, 2, 3,10,11,12,19,20,21]
    let ZRotationNegative = [0,19,20,21,10,11,12, 1, 2, 3,22,23,24,13,14,15, 4, 5, 6,25,26,27,16,17,18, 7, 8, 9]
    let YRotationPositive = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3,16,13,10,17,14,11,18,15,12,25,22,19,26,23,20,27,24,21]
    let YRotationNegative = [0, 3, 6, 9, 2, 5, 8, 1, 4, 7,12,15,18,11,14,17,10,13,16,21,24,27,20,23,26,19,22,25]
    let XRotationPositive = [0,19,10, 1,22,13, 4,25,16, 7,20,11, 2,23,14, 5,26,17, 8,21,12, 3,24,15, 6,27,18, 9]
    let XRotationNegative = [0, 3,12,21, 6,15,24, 9,18,27, 2,11,20, 5,14,23, 8,17,26, 1,10,19, 4,13,22, 7,16,25]
    
    //MARK: Setup functions
    public init(){
        self.addSolvedCube()
        // Setup camera position from existing scene
        cameraNode = cubes.rootNode.childNode(withName: "camera1", recursively: true)!
        scene.rootNode.addChildNode(cameraNode)
    }
    public func printCube(){
        print("FRONT")
        print(getFrontFace())
        print("BACK")
        print(getBackFace())
        print("UP")
        print(getUpFace())
        print("BOTTOM")
        print(getBottomFace())
        print("RIGHT")
        print(getRightFace())
        print("LEFT")
        print(getLeftFace())
    }
    public func addSolvedCube(){
        self.addCublet(pos:1,upDown:   .blue, leftRight:    .red    ,frontBack:     .yellow)
        self.addCublet(pos:2,upDown:   .blue, leftRight:    .red, frontBack:        .noColor)
        self.addCublet(pos:3,upDown:   .blue, leftRight:    .red, frontBack:        .white)
        self.addCublet(pos:4,upDown:   .blue, leftRight:    .noColor, frontBack:    .yellow)
        self.addCublet(pos:5,upDown:   .blue, leftRight:    .noColor, frontBack:    .noColor)
        self.addCublet(pos:6,upDown:   .blue, leftRight:    .noColor, frontBack:    .white)
        self.addCublet(pos:7,upDown:   .blue, leftRight:    .orange, frontBack:     .yellow)
        self.addCublet(pos:8,upDown:   .blue, leftRight:    .orange, frontBack:     .noColor)
        self.addCublet(pos:9,upDown:   .blue, leftRight:    .orange, frontBack:     .white)
        self.addCublet(pos:10,upDown:  .noColor, leftRight: .red, frontBack:        .yellow)
        self.addCublet(pos:11,upDown:  .noColor, leftRight: .red, frontBack:        .noColor)
        self.addCublet(pos:12,upDown:  .noColor, leftRight: .red, frontBack:        .white)
        self.addCublet(pos:13,upDown:  .noColor, leftRight: .noColor, frontBack:    .yellow)
        self.addCublet(pos:14,upDown:  .noColor, leftRight: .noColor, frontBack:    .noColor)
        self.addCublet(pos:15,upDown:  .noColor, leftRight: .noColor, frontBack:    .white)
        self.addCublet(pos:16,upDown:  .noColor, leftRight: .orange, frontBack:     .yellow)
        self.addCublet(pos:17,upDown:  .noColor, leftRight: .orange, frontBack:     .noColor)
        self.addCublet(pos:18,upDown:  .noColor, leftRight: .orange, frontBack:     .white)
        self.addCublet(pos:19,upDown:  .green, leftRight:   .red, frontBack:        .yellow)
        self.addCublet(pos:20,upDown:  .green, leftRight:   .red, frontBack:        .noColor)
        self.addCublet(pos:21,upDown:  .green, leftRight:   .red, frontBack:        .white)
        self.addCublet(pos:22,upDown:  .green, leftRight:   .noColor, frontBack:    .yellow)
        self.addCublet(pos:23,upDown:  .green, leftRight:   .noColor, frontBack:    .noColor)
        self.addCublet(pos:24,upDown:  .green, leftRight:   .noColor, frontBack:    .white)
        self.addCublet(pos:25,upDown:  .green, leftRight:   .orange, frontBack:     .yellow)
        self.addCublet(pos:26,upDown:  .green, leftRight:   .orange, frontBack:     .noColor)
        self.addCublet(pos:27,upDown:  .green, leftRight:   .orange, frontBack:     .white)
    }
    public func getScene() -> SCNScene{
        return scene
    }
    //MARK: Whole cube rotations
    //Roate the cube angle amount in the X direction
    //NOTE direction should be -1 or 1 for positive X or negative X
    public func rotateAllX(direction:Int, angle:Float = .pi/2){
        //Graphics Code
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
        //Logic Code
        for cube in self.cubelets{
            //update the position
            if direction > 0{
                cube.pos = self.XRotationPositive[cube.pos]
            }
            else{
                cube.pos = self.XRotationNegative[cube.pos]
            }
            //update the faces if angle does not equal .pi
            if angle != .pi{
                switch cube.type{
                case .corner:
                    cube.updateColors(upDown: cube.frontBack, leftRight: cube.leftRight, frontBack: cube.upDown)
                    break
                case .wedge:
                    cube.updateColors(upDown: cube.frontBack, leftRight: cube.leftRight, frontBack: cube.upDown)
                    break
                case.middlePiece:
                    break
                case.center:
                    cube.updateColors(upDown: cube.frontBack, leftRight: cube.leftRight, frontBack: cube.upDown)
                    break
                }
            }
        }
        
        
        
    }
    //Roate the cube angle amount in the Y direction
    //NOTE direction should be -1 or 1 for positive Y or negative Y
    public func rotateAllY(direction:Int, angle:Float = .pi/2){
        //Grpahics Code
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
        //Logic Code
        //update the position
        for cube in self.cubelets{
            if direction > 0{
                cube.pos = self.YRotationPositive[cube.pos]
            }
            else{
                cube.pos = self.YRotationNegative[cube.pos]
            }
            //update the faces if angle does not equal .pi
            if angle != .pi{
                switch cube.type{
                case .corner:
                    cube.updateColors(upDown: cube.upDown, leftRight: cube.frontBack, frontBack: cube.leftRight)
                    break
                case .wedge:
                    cube.updateColors(upDown: cube.upDown, leftRight: cube.frontBack, frontBack: cube.leftRight)
                    break
                case.middlePiece:
                    break
                case.center:
                    cube.updateColors(upDown: cube.upDown, leftRight: cube.frontBack, frontBack: cube.leftRight)
                    break
                }
            }
        }
    }
    //Roate the cube angle amount in the Y direction
    //NOTE direction should be -1 or 1 for positive Y or negative Y
    public func rotateAllZ(direction:Int, angle:Float = .pi/2){
        //Graphics Code
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
        //Logic Code
        //Logical Code
        //update the position
        for cube in self.cubelets{
            if direction > 0{
                cube.pos = self.ZRotationPositive[cube.pos]
            }
            else{
                cube.pos = self.ZRotationNegative[cube.pos]
            }
            //update the faces if angle does not equal .pi
            if angle != .pi{
                switch cube.type{
                case .corner:
                    cube.updateColors(upDown: cube.leftRight, leftRight: cube.upDown, frontBack: cube.frontBack)
                    break
                case .wedge:
                    cube.updateColors(upDown: cube.leftRight, leftRight: cube.upDown, frontBack: cube.frontBack)
                    break
                case.middlePiece:
                    break
                case.center:
                    cube.updateColors(upDown: cube.leftRight, leftRight: cube.upDown, frontBack: cube.frontBack)
                    break
                }
            }
        }
    }
    private func addCublet(pos:Int, upDown:CubletColor, leftRight:CubletColor, frontBack:CubletColor){
        let node = cubes.rootNode.childNode(withName: "cube\(pos)", recursively: true)!
        scene.rootNode.addChildNode(node)
        cubelets.append(Cublet(node:node, pos:pos,upDown: upDown,leftRight: leftRight, frontBack: frontBack))
    }
    //MARK: Functions to diaply the logical cube
    public func getFrontFace() -> String{
        var s = ""
        var i = 0
        for cube in self.cubelets{
            if self.frontPositions.contains(cube.pos){
                s += "\(colorToString(color:cube.frontBack)) "
                i = i + 1
                if i % 3 == 0{
                    s += "\n"
                }
            }
        }
        return s
    }
    public func getBackFace() -> String{
        var s = ""
        var i = 0
        for cube in self.cubelets{
            if self.backPositions.contains(cube.pos){
                s += "\(colorToString(color:cube.frontBack)) "
                i = i + 1
                if i % 3 == 0{
                    s += "\n"
                }
            }
        }
        return s
    }
    public func getRightFace() -> String{
        var s = ""
        var i = 0
        for cube in self.cubelets{
            if self.rightPositions.contains(cube.pos){
                s += "\(colorToString(color:cube.leftRight)) "
                i = i + 1
                if i % 3 == 0{
                    s += "\n"
                }
            }
        }
        return s
    }
    public func getLeftFace() -> String{
        var s = ""
        var i = 0
        for cube in self.cubelets{
            if self.leftPositions.contains(cube.pos){
                s += "\(colorToString(color:cube.leftRight)) "
                i = i + 1
                if i % 3 == 0{
                    s += "\n"
                }
            }
        }
        return s
    }
    public func getUpFace() -> String{
        var s = ""
        var i = 0
        for cube in self.cubelets{
            if self.upPositions.contains(cube.pos){
                s += "\(colorToString(color:cube.upDown)) "
                i = i + 1
                if i % 3 == 0{
                    s += "\n"
                }
            }
        }
        return s
    }
    public func getBottomFace() -> String{
        var s = ""
        var i = 0
        for cube in self.cubelets{
            if self.bottomPositions.contains(cube.pos){
                s += "\(colorToString(color:cube.upDown)) "
                i = i + 1
                if i % 3 == 0{
                    s += "\n"
                }
            }
        }
        return s
    }
}
//MARK: Cublet Class
//node - the actual SCNNode that diplays this cublet
//upDown, leftRight, frontBack: these represent the colors on that side
//pos is the position of the cube in space.  see docs for descrition.
// --for example up or down could be red
// --types of pieces
// if all three colors are noColor then it is the center-most peice
// if all three colors are colors then it is a corner
// if on is noColor then it is a wedge
// if 2 are noColor than it is a center piece
private class Cublet{
    var node:SCNNode
    var pos:Int
    var upDown:CubletColor
    var leftRight:CubletColor
    var frontBack:CubletColor
    let type:PieceType
    init(node:SCNNode, pos:Int, upDown:CubletColor, leftRight:CubletColor, frontBack:CubletColor){
        self.node = node
        self.pos = pos
        self.upDown = upDown
        self.leftRight = leftRight
        self.frontBack = frontBack
        var noColorCount = 0
        if upDown != .noColor { noColorCount+=1}
        if leftRight != .noColor { noColorCount+=1}
        if frontBack != .noColor { noColorCount+=1}
        switch noColorCount{
        case 0:
            self.type = .middlePiece
        case 1:
            self.type = .center
        case 2:
            self.type = .wedge
        default:
            self.type = .corner
        }
    }
    public func updateColors(upDown:CubletColor, leftRight:CubletColor, frontBack:CubletColor){
        self.upDown = upDown
        self.frontBack = frontBack
        self.leftRight = leftRight
    }
}
enum CubletColor {
    case red
    case blue
    case yellow
    case white
    case orange
    case green
    case noColor
}
enum PieceType {
    case corner
    case wedge
    case center
    case middlePiece
}
private func colorToString(color:CubletColor) -> String{
    switch color{
    case .red:
        return "R"
    case .blue:
        return "B"
    case .yellow:
        return "Y"
    case .white:
        return "W"
    case .orange:
        return "O"
    case .green:
        return "G"
    case .noColor:
        return "X"
    }
}
