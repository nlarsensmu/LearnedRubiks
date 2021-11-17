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
    private let downPosition = [1, 2, 3, 4, 5, 6, 7, 8, 9 ]
    private let upPositions     = [19,20,21,22,23,24,25,26,27]
    private let rightPositions  = [1, 2, 3, 10,11,12,19,20,21]
    private let leftPositions   = [7, 8, 9, 16,17,18,25,26,27]
    private let frontPositions  = [1, 4, 7, 10,13,16,19,22,25]
    private let backPositions   = [3, 6, 9, 12,15,18,21,24,27]
    private let mPositions =      [4, 5, 6, 13,14,15,22,23,24]
    private let sPositions =      [2, 5, 8, 11,14,17,20,23,26]
    private let ePositions =      [10,11,12,13,14,15,16,17,18]
    private let allPositions = Array.init(1...27)
    //Rotation Array.  These will store the new pos at the index of the old pos
    //original positions    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
    private let ZRotationPositive = [0, 7, 8, 9,16,17,18,25,26,27,4 ,5 , 6,13,14,15,22,23,24, 1, 2, 3,10,11,12,19,20,21]
    private let ZRotationNegative = [0,19,20,21,10,11,12, 1, 2, 3,22,23,24,13,14,15, 4, 5, 6,25,26,27,16,17,18, 7, 8, 9]
    private let YRotationPositive = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3,16,13,10,17,14,11,18,15,12,25,22,19,26,23,20,27,24,21]
    private let YRotationNegative = [0, 3, 6, 9, 2, 5, 8, 1, 4, 7,12,15,18,11,14,17,10,13,16,21,24,27,20,23,26,19,22,25]
    private let XRotationPositive = [0,19,10, 1,22,13, 4,25,16, 7,20,11, 2,23,14, 5,26,17, 8,21,12, 3,24,15, 6,27,18, 9]
    private let XRotationNegative = [0, 3,12,21, 6,15,24, 9,18,27, 2,11,20, 5,14,23, 8,17,26, 1,10,19, 4,13,22, 7,16,25]
    
    //MARK: Setup functions
    public init(){
        self.addSolvedCube()
        // Setup camera position from existing scene
        cameraNode = cubes.rootNode.childNode(withName: "camera1", recursively: true)!
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func cublet(at position:Int) -> Cublet {
        for c in cubelets {
            if c.pos == position {
                return c
            }
        }
        return self.cubelets[1]
    }
    
    public func printCube(){
        print("        ")
        var s = cublet(at: 9).getColor(t: .B) + cublet(at: 6).getColor(t: .B) + cublet(at: 3).getColor(t: .B)
        print("    " + s + " ")
        s = cublet(at: 18).getColor(t: .B) + cublet(at: 15).getColor(t: .B) + cublet(at: 12).getColor(t: .B)
        print("    " + s + " ")
        s = cublet(at: 27).getColor(t: .B) + cublet(at: 24).getColor(t: .B) + cublet(at: 21).getColor(t: .B)
        print("    " + s + " ")
        
        s = cublet(at: 9).getColor(t: .L) + cublet(at: 18).getColor(t: .L) + cublet(at: 27).getColor(t: .L) + " "
        s += cublet(at: 27).getColor(t: .U) + cublet(at: 24).getColor(t: .U) + cublet(at: 21).getColor(t: .U) + " "
        s += cublet(at: 21).getColor(t: .R) + cublet(at: 12).getColor(t: .R) + cublet(at: 3).getColor(t: .R)
        print(s)
        s = cublet(at: 8).getColor(t: .L) + cublet(at: 17).getColor(t: .L) + cublet(at: 26).getColor(t: .L) + " "
        s += cublet(at: 26).getColor(t: .U) + cublet(at: 23).getColor(t: .U) + cublet(at: 20).getColor(t: .U) + " "
        s += cublet(at: 20).getColor(t: .R) + cublet(at: 11).getColor(t: .R) + cublet(at: 2).getColor(t: .R)
        print(s)
        s = cublet(at: 7).getColor(t: .L) + cublet(at: 16).getColor(t: .L) + cublet(at: 25).getColor(t: .L) + " "
        s += cublet(at: 25).getColor(t: .U) + cublet(at: 22).getColor(t: .U) + cublet(at: 19).getColor(t: .U) + " "
        s += cublet(at: 19).getColor(t: .R) + cublet(at: 10).getColor(t: .R) + cublet(at: 1).getColor(t: .R)
        print(s)
        s = cublet(at: 25).getColor(t: .F) + cublet(at: 22).getColor(t: .F) + cublet(at: 19).getColor(t: .F)
        print("    " + s + " ")
        s = cublet(at: 16).getColor(t: .F) + cublet(at: 13).getColor(t: .F) + cublet(at: 10).getColor(t: .F)
        print("    " + s + " ")
        s = cublet(at: 7).getColor(t: .F) + cublet(at: 4).getColor(t: .F) + cublet(at: 1).getColor(t: .F)
        print("    " + s + " ")
        
        s = cublet(at: 7).getColor(t: .D) + cublet(at: 4).getColor(t: .D) + cublet(at: 1).getColor(t: .D)
        print("    " + s + " ")
        s = cublet(at: 8).getColor(t: .D) + cublet(at: 5).getColor(t: .D) + cublet(at: 2).getColor(t: .D)
        print("    " + s + " ")
        s = cublet(at: 9).getColor(t: .D) + cublet(at: 6).getColor(t: .D) + cublet(at: 3).getColor(t: .D)
        print("    " + s + " ")
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
    
    // MARK: public Cube Manipulation Functions
    public func rightTurn(direction:Int) {
        let _ = rotateXAxis(positions: rightPositions, direction: direction)
    }
    public func leftTurn(direction:Int) {
        // The left face turns are the opposite of cube rotations about the X.
        let oppositeDirection = direction * -1
        let _ = rotateXAxis(positions: leftPositions, direction: oppositeDirection)
    }
    public func mTurn(direction:Int) {
        let _ = rotateXAxis(positions: mPositions, direction: direction)
    }
    
    public func upTurn(direction:Int) {
        let _ = rotateYAxis(positions: upPositions, direction: direction)
    }
    public func downTurn(direction:Int) {
        let oppositeDirection = direction * -1
        let _ = rotateYAxis(positions: downPosition, direction: oppositeDirection)
    }
    public func eTurn(direction:Int) {
        let _ = rotateYAxis(positions: ePositions, direction: direction)
    }
    public func frontTurn(direction:Int) {
        let _ = rotateZAxis(positions: frontPositions, direction: direction)
    }
    public func backTurn(direction:Int) {
        let oppositeDirection = direction * -1
        let _ = rotateZAxis(positions: backPositions, direction: oppositeDirection)
    }
    public func sTurn(direction:Int) {
        let _ = rotateZAxis(positions: sPositions, direction: direction)
    }
    
    public func scramble(turnsCount:Int = 30) {
        let turns = [Turn.D, Turn.DN, Turn.F, Turn.FN, Turn.R, Turn.RN,
                     Turn.L, Turn.LN, Turn.U, Turn.UN, Turn.B, Turn.BN,
                     Turn.L2, Turn.R2, Turn.B2, Turn.F2, Turn.U2, Turn.D2]
        
        for _ in 0..<turnsCount {
            let turn = turns.randomElement()
            if let t = turn {
                turnFromEnum(turn: t)
            }
        }
    }
    
    // MARK: private turn set functions
    private func turnFromEnum(turn:Turn) {
        switch turn {
        case Turn.D:
            downTurn(direction: 1)
            break
        case Turn.DN:
            downTurn(direction: -1)
            break
        case Turn.D2:
            downTurn(direction: 1)
            downTurn(direction: 1)
            break
        case Turn.U:
            upTurn(direction: 1)
            break
        case Turn.UN:
            upTurn(direction: -1)
            break
        case Turn.U2:
            upTurn(direction: 1)
            upTurn(direction: 1)
            break
        case Turn.R:
            rightTurn(direction: 1)
            break
        case Turn.RN:
            rightTurn(direction: -1)
            break
        case Turn.R2:
            rightTurn(direction: 1)
            rightTurn(direction: 1)
            break
        case Turn.L:
            leftTurn(direction: 1)
            break
        case Turn.LN:
            leftTurn(direction: -1)
            break
        case Turn.L2:
            leftTurn(direction: 1)
            leftTurn(direction: 1)
            break
        case Turn.F:
            frontTurn(direction: 1)
            break
        case Turn.FN:
            frontTurn(direction: -1)
            break
        case Turn.F2:
            frontTurn(direction: 1)
            frontTurn(direction: 1)
            break
        case Turn.B:
            backTurn(direction: 1)
            break
        case Turn.BN:
            backTurn(direction: -1)
            break
        case Turn.B2:
            backTurn(direction: 1)
            backTurn(direction: 1)
            break
        default:
            break
        }
        
    }
    // Turn R, M, L
    private func rotateXAxis(positions:[Int], direction:Int, angle:Float = .pi/2) -> Bool{
        
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
        
        //Go through every cube
        for cube in self.cubelets{
            
            // Skip cubes not in the current face.
            if !(positions.contains(cube.pos)) {
                continue
            }
            
            // Turn the physical cube
            cube.node.runAction(rotationAction)
            
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
        return true
    }
    
    // Turn U, E, D
    private func rotateYAxis(positions:[Int], direction:Int, angle:Float = .pi/2){
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
        
        //update the position
        for cube in self.cubelets{
            
            // Skip cubes not in the current face.
            if !(positions.contains(cube.pos)) {
                continue
            }
            
            // Physical cube
            cube.node.runAction(rotationAction)
            
            //Logic Code
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
    
    // F, S, B turns
    public func rotateZAxis(positions:[Int], direction:Int, angle:Float = .pi/2){
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
        
        //update the position
        for cube in self.cubelets{
            
            // Skip cubes not in the current face.
            if !(positions.contains(cube.pos)) {
                continue
            }
            
            // Physical Cube
            cube.node.runAction(rotationAction)
            
            //Logic Code
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
    
    //MARK: Whole cube rotations
    //Roate the cube angle amount in the X direction
    //NOTE direction should be -1 or 1 for positive X or negative X
    public func rotateAllX(direction:Int, angle:Float = .pi/2){
        let _ = rotateXAxis(positions: allPositions, direction: direction, angle: angle)
    }
    
    //Roate the cube angle amount in the Y direction
    //NOTE direction should be -1 or 1 for positive Y or negative Y
    public func rotateAllY(direction:Int, angle:Float = .pi/2){
        let _ = rotateYAxis(positions: allPositions, direction: direction, angle: angle)
    }
    
    //Roate the cube angle amount in the Y direction
    //NOTE direction should be -1 or 1 for positive Y or negative Y
    public func rotateAllZ(direction:Int, angle:Float = .pi/2){
        let _ = rotateZAxis(positions: allPositions, direction: direction, angle: angle)
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
            if self.downPosition.contains(cube.pos){
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
    
    public func getColor(t:Turn) -> String {
        if t == Turn.F || t == Turn.B {
            return colorToString(color: frontBack)
        }
        if t == Turn.R || t == Turn.L {
            return colorToString(color: leftRight)
        }
        if t == Turn.U || t == Turn.D {
            return colorToString(color: upDown)
        }
        return ""
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
enum Turn {
    case U
    case UN
    case D
    case DN
    case R
    case RN
    case L
    case LN
    case F
    case FN
    case B
    case BN
    case M
    case MN
    case S
    case SN
    case E
    case EN
    case U2
    case D2
    case F2
    case B2
    case L2
    case R2
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
