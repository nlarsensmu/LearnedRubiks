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
    public var cubelets:[Cublet] = []
    var scene = SCNScene()
    let cubes = SCNScene(named: "Cube.scn")!
    var cameraNode : SCNNode!
    public let downPosition = [1, 2, 3, 4, 5, 6, 7, 8, 9 ]
    public let upPositions     = [19,20,21,22,23,24,25,26,27]
    public let rightPositions  = [1, 2, 3, 10,11,12,19,20,21]
    public let leftPositions   = [7, 8, 9, 16,17,18,25,26,27]
    public let frontPositions  = [1, 4, 7, 10,13,16,19,22,25]
    public let backPositions   = [3, 6, 9, 12,15,18,21,24,27]
    public let mPositions =      [4, 5, 6, 13,14,15,22,23,24]
    public let sPositions =      [2, 5, 8, 11,14,17,20,23,26]
    public let ePositions =      [10,11,12,13,14,15,16,17,18]
    public let allPositions = Array.init(1...27)
    //Rotation Array.  These will store the new pos at the index of the old pos
    //original positions    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
    private let ZRotationPositive = [0, 7, 8, 9,16,17,18,25,26,27,4 ,5 , 6,13,14,15,22,23,24, 1, 2, 3,10,11,12,19,20,21]
    private let ZRotationNegative = [0,19,20,21,10,11,12, 1, 2, 3,22,23,24,13,14,15, 4, 5, 6,25,26,27,16,17,18, 7, 8, 9]
    private let YRotationPositive = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3,16,13,10,17,14,11,18,15,12,25,22,19,26,23,20,27,24,21]
    private let YRotationNegative = [0, 3, 6, 9, 2, 5, 8, 1, 4, 7,12,15,18,11,14,17,10,13,16,21,24,27,20,23,26,19,22,25]
    private let XRotationPositive = [0,19,10, 1,22,13, 4,25,16, 7,20,11, 2,23,14, 5,26,17, 8,21,12, 3,24,15, 6,27,18, 9]
    private let XRotationNegative = [0, 3,12,21, 6,15,24, 9,18,27, 2,11,20, 5,14,23, 8,17,26, 1,10,19, 4,13,22, 7,16,25]
    //posisitions visible to the user
    private let visiblePoses = [1,2,3,4,7,10,11,12,13,16,19,20,21,22,23,24,25,26,27]
    var duration: Double = 1.0
    var emphaziseDuration: Double = 0.1
    //MARK: Setup functions
    public init(){
        self.addSolvedCube()
        cameraNode = cubes.rootNode.childNode(withName: "camera1", recursively: true)!
        scene.rootNode.addChildNode(cameraNode)
    }
    //Sorry for the eye sore... This had to be hardcoded We will try and think of a better way
    public init(front:[CubletColor], left:[CubletColor], right:[CubletColor], up:[CubletColor], down:[CubletColor], back:[CubletColor]){
        self.addCublet(pos:1,upDown:  down[0],  leftRight: right[0], frontBack: front[0], colors:  [right[0], .noColor,.noColor,front[0],.noColor,down[0] ])
        self.addCublet(pos:2,upDown:  down[1],  leftRight: right[1], frontBack: .noColor, colors:  [right[1], .noColor,.noColor,.noColor,.noColor,down[1] ])
        self.addCublet(pos:3,upDown:  down[2],  leftRight: right[2], frontBack: back[0] , colors:  [right[2], back[0] ,.noColor,.noColor,.noColor,down[2] ])
        self.addCublet(pos:4,upDown:  down[3],  leftRight: .noColor, frontBack: front[1], colors:  [.noColor, .noColor,.noColor,front[1],.noColor,down[3] ])
        self.addCublet(pos:5,upDown:  down[4],  leftRight: .noColor, frontBack: .noColor, colors:  [.noColor, .noColor,.noColor,.noColor,.noColor,down[4] ])
        self.addCublet(pos:6,upDown:  down[5],  leftRight: .noColor, frontBack: back[1] , colors:  [.noColor, back[1] ,.noColor,.noColor,.noColor,down[5] ])
        self.addCublet(pos:7,upDown:  down[6],  leftRight: left[0] , frontBack: front[2], colors:  [.noColor, .noColor,left[0] ,front[2],.noColor,down[6] ])
        self.addCublet(pos:8,upDown:  down[7],  leftRight: left[1] , frontBack: .noColor, colors:  [.noColor, .noColor,left[1] ,.noColor,.noColor,down[7] ])
        self.addCublet(pos:9,upDown:  down[8],  leftRight: left[2] , frontBack: back[2] , colors:  [.noColor, back[2] ,left[2] ,.noColor,.noColor,down[8] ])
        self.addCublet(pos:10,upDown: .noColor, leftRight: right[3], frontBack: front[3], colors:  [right[3], .noColor,.noColor,front[3],.noColor,.noColor])
        self.addCublet(pos:11,upDown: .noColor, leftRight: right[4], frontBack: .noColor, colors:  [right[4], .noColor,.noColor,.noColor,.noColor,.noColor])
        self.addCublet(pos:12,upDown: .noColor, leftRight: right[5], frontBack: back[3] , colors:  [right[5], back[3] ,.noColor,.noColor,.noColor,.noColor])
        self.addCublet(pos:13,upDown: .noColor, leftRight: .noColor, frontBack: front[4], colors:  [.noColor, .noColor,.noColor,front[4],.noColor,.noColor])
        self.addCublet(pos:14,upDown: .noColor, leftRight: .noColor, frontBack: .noColor, colors:  [.noColor, .noColor,.noColor,.noColor,.noColor,.noColor])
        self.addCublet(pos:15,upDown: .noColor, leftRight: .noColor, frontBack: back[4] , colors:  [.noColor, back[4] ,.noColor,.noColor,.noColor,.noColor])
        self.addCublet(pos:16,upDown: .noColor, leftRight: left[3] , frontBack: front[5], colors:  [.noColor, .noColor,left[3] ,front[5],.noColor,.noColor])
        self.addCublet(pos:17,upDown: .noColor, leftRight: left[4] , frontBack: .noColor, colors:  [.noColor, .noColor,left[4] ,.noColor,.noColor,.noColor])
        self.addCublet(pos:18,upDown: .noColor, leftRight: left[5] , frontBack: back[5] , colors:  [.noColor, back[5] ,left[5] ,.noColor,.noColor,.noColor])
        self.addCublet(pos:19,upDown: up[0]   , leftRight: right[6], frontBack: front[6], colors:  [right[6], .noColor,.noColor,front[6],up[0]   ,.noColor])
        self.addCublet(pos:20,upDown: up[1]   , leftRight: right[7], frontBack: .noColor, colors:  [right[7], .noColor,.noColor,.noColor,up[1]   ,.noColor])
        self.addCublet(pos:21,upDown: up[2]   , leftRight: right[8], frontBack: back[6] , colors:  [right[8], back[6] ,.noColor,.noColor,up[2]   ,.noColor])
        self.addCublet(pos:22,upDown: up[3]   , leftRight: .noColor, frontBack: front[7], colors:  [.noColor, .noColor,.noColor,front[7],up[3]   ,.noColor])
        self.addCublet(pos:23,upDown: up[4]   , leftRight: .noColor, frontBack: .noColor, colors:  [.noColor, .noColor,.noColor,.noColor,up[4]   ,.noColor])
        self.addCublet(pos:24,upDown: up[5]   , leftRight: .noColor, frontBack: back[7] , colors:  [.noColor, back[7] ,.noColor,.noColor,up[5]   ,.noColor])
        self.addCublet(pos:25,upDown: up[6]   , leftRight: left[6] , frontBack: front[8], colors:  [.noColor, .noColor,left[6] ,front[8],up[6]   ,.noColor])
        self.addCublet(pos:26,upDown: up[7]   , leftRight: left[7] , frontBack: .noColor, colors:  [.noColor, .noColor,left[7] ,.noColor,up[7]   ,.noColor])
        self.addCublet(pos:27,upDown: up[8]   , leftRight: left[8] , frontBack: back[8] , colors:  [.noColor, back[8] ,left[8] ,.noColor,up[8]   ,.noColor])
        // Setup camera position from existing scene
        cameraNode = cubes.rootNode.childNode(withName: "camera1", recursively: true)!
        scene.rootNode.addChildNode(cameraNode)
    }
    //default cube creation
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
    private func addCublet(pos:Int, upDown:CubletColor, leftRight:CubletColor, frontBack:CubletColor){
        let node = cubes.rootNode.childNode(withName: "cube\(pos)", recursively: true)!
        scene.rootNode.addChildNode(node)
        cubelets.append(Cublet(node:node, pos:pos,upDown: upDown,leftRight: leftRight, frontBack: frontBack))
    }
    private func addCublet(pos:Int, upDown:CubletColor, leftRight:CubletColor, frontBack:CubletColor, colors: [CubletColor]){
        let node = cubes.rootNode.childNode(withName: "cube\(pos)", recursively: true)!
        let materials =  toMaterials(from: colors.map { mat -> UIColor in
            return cubletColor(from: mat)
        })
        node.geometry?.materials = materials
        scene.rootNode.addChildNode(node)
        cubelets.append(Cublet(node:node, pos:pos,upDown: upDown,leftRight: leftRight, frontBack: frontBack))
    }
    private func toMaterials(from colors:[UIColor]) -> [SCNMaterial]{
        return colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
    }
    //MARK: Accessing methods
    public func cublet(at position:Int) -> Cublet {
        for c in cubelets {
            if c.pos == position {
                return c
            }
        }
        return self.cubelets[0]
    }
    public func isCubletVisible(pos:Int) -> Bool {
        return self.visiblePoses.contains(pos)
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
    public func getScene() -> SCNScene{
        return scene
    }
    // MARK: public Cube Manipulation Functions
    public func runTurn(direction:Int, operation: (Int) -> SCNAction) {
        scene.rootNode.runAction(operation(direction))
    }
    public func rightTurn(direction:Int) -> SCNAction {
        return rotateXAxis(positions: rightPositions, direction: direction)
    }
    public func leftTurn(direction:Int) -> SCNAction  {
        // The left face turns are the opposite of cube rotations about the X.
        let oppositeDirection = direction * -1
        return rotateXAxis(positions: leftPositions, direction: oppositeDirection)
    }
    public func mTurn(direction:Int) -> SCNAction  {
        return rotateXAxis(positions: mPositions, direction: direction)
    }
    
    public func upTurn(direction:Int) -> SCNAction  {
        return rotateYAxis(positions: upPositions, direction: direction)
    }
    public func downTurn(direction:Int) -> SCNAction  {
        let oppositeDirection = direction * -1
        return rotateYAxis(positions: downPosition, direction: oppositeDirection)
    }
    public func eTurn(direction:Int) -> SCNAction  {
        return rotateYAxis(positions: ePositions, direction: direction)
    }
    public func frontTurn(direction:Int) -> SCNAction  {
        return rotateZAxis(positions: frontPositions, direction: direction)
    }
    public func backTurn(direction:Int) -> SCNAction  {
        let oppositeDirection = direction * -1
        return rotateZAxis(positions: backPositions, direction: oppositeDirection)
    }
    public func sTurn(direction:Int) -> SCNAction  {
        return rotateZAxis(positions: sPositions, direction: direction)
    }
    public func rotateAllX(direction:Int) -> SCNAction {
        return rotateXAxis(positions: allPositions, direction: direction)
    }
    //Roate the cube angle amount in the Y direction
    public func rotateAllY(direction:Int) -> SCNAction {
        return rotateYAxis(positions: allPositions, direction: direction)
    }
    //Roate the cube angle amount in the Y direction
    public func rotateAllZ(direction:Int) -> SCNAction {
        return rotateZAxis(positions: allPositions, direction: direction)
    }
    //MARK: Private cube rotations... We only need 3
    private func emphasizeAt(pos:Int) -> SCNAction {
        let cube = cublet(at: pos)
        let originalScale = cube.node.scale
        let grownScale = SCNVector3(originalScale.x * 2.0, originalScale.y * 2.0, originalScale.z * 2.0)
        let growthVector = SCNVector3(grownScale.x - originalScale.x,grownScale.y - originalScale.y,grownScale.z - originalScale.z)
        let growAction = SCNAction.customAction(duration: emphaziseDuration) { (node, elapsedTime) -> () in
            
            let percentage:Float = Float((elapsedTime - cube.lastElapsedTime))/Float(self.emphaziseDuration)
            cube.lastElapsedTime = elapsedTime
            cube.node.scale.x = cube.node.scale.x + percentage * growthVector.x
            cube.node.scale.y = cube.node.scale.y + percentage * growthVector.y
            cube.node.scale.z = cube.node.scale.z + percentage * growthVector.z
            if elapsedTime >= self.emphaziseDuration {
                cube.lastElapsedTime = 0.0
            }
        }
        let shrinkAction = SCNAction.customAction(duration: emphaziseDuration) { (node, elapsedTime) -> () in
            
            let percentage:Float = Float((elapsedTime - cube.lastElapsedTime))/Float(self.emphaziseDuration)
            cube.lastElapsedTime = elapsedTime
            cube.node.scale.x = cube.node.scale.x - percentage * growthVector.x
            cube.node.scale.y = cube.node.scale.x - percentage * growthVector.y
            cube.node.scale.z = cube.node.scale.x - percentage * growthVector.z
            if elapsedTime >= self.emphaziseDuration {
                cube.node.scale.x = 0.5
                cube.node.scale.y = 0.5
                cube.node.scale.z = 0.5
                cube.lastElapsedTime = 0.0
            }
        }
        return SCNAction.sequence([growAction, shrinkAction])
    }
    public func empasize(poses:[Int], asGroup:Bool) -> SCNAction{
        var actions:[SCNAction] = []
        for pos in poses{
            actions.append(self.emphasizeAt(pos: pos))
        }
        if asGroup == true{
            return SCNAction.group(actions)
        }
        else{
            return SCNAction.sequence(actions)
        }
    }
    
    // Turn R, M, L
    private func rotateXAxis(positions:[Int], direction:Int) -> SCNAction {
        
        var actions:[SCNAction] = []
        let angle:Float = .pi/2
            
    //Go through every cube
        for cube in self.cubelets {
            // Skip cubes not in the current face.
            if !(positions.contains(cube.pos)) {
                continue
            }
            //Graphics Code
            let rotationAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> () in

                let percentage = (elapsedTime - cube.lastElapsedTime)/self.duration
                cube.lastElapsedTime = elapsedTime
                
                let rot = SCNMatrix4MakeRotation(Float(direction)  * (-1) * (angle) * (Float(percentage)), 0, 0, 1)
                let rot2 = SCNMatrix4Mult(cube.node.transform, rot)
                cube.node.transform = rot2
                
                if elapsedTime >= self.duration {
                    cube.lastElapsedTime = 0.0
                }
            }
            // Turn the physical cube
            actions.append(rotationAction)
            
            rotateXAxisVirtual(cube: cube, direction: direction)
            
        }
        return SCNAction.group(actions)
    }
    private func rotateXAxisVirtual(cube:Cublet, direction:Int) {

        //update the position
        if direction > 0{
            cube.pos = self.XRotationPositive[cube.pos]
        }
        else{
            cube.pos = self.XRotationNegative[cube.pos]
        }
        
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
    // Turn U, E, D
    private func rotateYAxis(positions:[Int], direction:Int) -> SCNAction{
        
        var actions:[SCNAction] = []
        let angle:Float = .pi/2
        //update the position
        for cube in self.cubelets{
            // Skip cubes not in the current face.
            if !(positions.contains(cube.pos)) {
                continue
            }
            let rotationAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> () in

                let percentage = (elapsedTime - cube.lastElapsedTime)/self.duration
                cube.lastElapsedTime = elapsedTime

                let rot = SCNMatrix4MakeRotation(Float(direction) * (-1) * (angle) * (Float(percentage)), 0, 1, 0)
                let rot2 = SCNMatrix4Mult(cube.node.transform, rot)
                cube.node.transform = rot2
                
                if elapsedTime >= self.duration {
                    cube.lastElapsedTime = 0.0
                }
            }
            // Physical cube
            actions.append(rotationAction)
            
            //Logic Code
            rotateYAxisVirtual(cube: cube, direction: direction)
        }
        return SCNAction.group(actions)
    }
    private func rotateYAxisVirtual(cube:Cublet, direction:Int) {
        
        if direction > 0{
            cube.pos = self.YRotationPositive[cube.pos]
        }
        else{
            cube.pos = self.YRotationNegative[cube.pos]
        }
        
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
    
    // F, S, B turns
    private func rotateZAxis(positions:[Int], direction:Int) -> SCNAction {
        
        var actions:[SCNAction] = []
        let angle:Float = .pi/2
        
        //update the position
        for cube in self.cubelets{
            // Skip cubes not in the current face.
            if !(positions.contains(cube.pos)) {
                continue
            }
            //Graphics Code
            let rotationAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> () in

                let percentage = (elapsedTime - cube.lastElapsedTime)/self.duration
                cube.lastElapsedTime = elapsedTime
                
                let rot = SCNMatrix4MakeRotation(Float(direction) * (angle) * (Float(percentage)), 1, 0, 0)
                let rot2 = SCNMatrix4Mult(cube.node.transform, rot)
                cube.node.transform = rot2
                
                if elapsedTime >= self.duration {
                    cube.lastElapsedTime = 0.0
                }
            }
                // Physical Cube
            actions.append(rotationAction)
            
            //Logic Code
            rotateZAxisVirtual(cube: cube, direction: direction)
        }
        return SCNAction.group(actions)
    }
    private func rotateZAxisVirtual(cube:Cublet, direction:Int) {
        
        if direction > 0{
            cube.pos = self.ZRotationPositive[cube.pos]
        }
        else{
            cube.pos = self.ZRotationNegative[cube.pos]
        }
        
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
    //MARK: Cube helper functions
    public func getTurnActions(turns:[Turn]) -> [SCNAction] {
        var actions:[SCNAction] = []
        for t in turns {
            actions.append(turnFromEnum(turn: t))
        }
        return actions
    }
    public func isValid() -> Bool {
        var red = 0
        var blue = 0
        var green = 0
        var yellow = 0
        var white = 0
        var orange = 0
        for cubelet in cubelets {
            if [cubelet.upDown,cubelet.frontBack,cubelet.leftRight].contains(.red){
                red += 1
            }
            if [cubelet.upDown,cubelet.frontBack,cubelet.leftRight].contains(.blue){
                blue += 1
            }
            if [cubelet.upDown,cubelet.frontBack,cubelet.leftRight].contains(.green){
                green += 1
            }
            if [cubelet.upDown,cubelet.frontBack,cubelet.leftRight].contains(.yellow){
                yellow += 1
            }
            if [cubelet.upDown,cubelet.frontBack,cubelet.leftRight].contains(.white){
                white += 1
            }
            if [cubelet.upDown,cubelet.frontBack,cubelet.leftRight].contains(.orange){
                orange += 1
            }
        }
        if red != 9{  return false }
        if blue != 9{  return false }
        if green != 9{  return false }
        if yellow != 9{  return false }
        if white != 9{  return false }
        if orange != 9{  return false }
        return true
    }
    public func isSovled() -> Bool{
        if !checkFaces(poses: self.downPosition, side: .D) { return false }
        if !checkFaces(poses: self.upPositions, side: .U) { return false }
        if !checkFaces(poses: self.leftPositions, side: .L) { return false }
        if !checkFaces(poses: self.rightPositions, side: .R) { return false }
        if !checkFaces(poses: self.frontPositions, side: .F) { return false }
        if !checkFaces(poses: self.backPositions, side: .D) { return false }
        return true
    }
    private func checkFaces(poses:[Int], side:Turn) -> Bool{
        var color:CubletColor = .red
        if [.U,.D].contains(side){
            color = cublet(at: poses[0]).upDown
        } else if [.L,.R].contains(side){
            color = cublet(at: poses[0]).upDown
        } else if [.F,.B].contains(side){
            color = cublet(at: poses[0]).upDown
        }
        for i in  1..<poses.count {
            var checkColor:CubletColor = .red
            if [.U,.D].contains(side) {
                checkColor = cublet(at: poses[i]).upDown
            } else if [.L,.R].contains(side){
                checkColor = cublet(at: poses[i]).upDown
            } else if [.F,.B].contains(side){
                checkColor = cublet(at: poses[i]).upDown
            }
            if color != checkColor{
                return false
            }
        }
        return true
    }
    public func isParady() -> Bool{
        let cube = self.deepCopyCube()
        var solver:SolverBase = SolverCross(c:cube)
        while(solver.hasNextStep()){
            _ = solver.getNextStep()
        }
        solver = SolverFirstCorners(cube:cube)
        while(solver.hasNextStep()){
            _ = solver.getNextStep()
        }
        solver = SolverMiddle(cube:cube)
        while(solver.hasNextStep()){
            _ = solver.getNextStep()
        }
        solver = SolverLLWedgePossitions(cube:cube)
        while(solver.hasNextStep()){
            _ = solver.getNextStep()
        }
        solver = SolverLastCrossBB(cube:cube)
        while(solver.hasNextStep()){
            _ = solver.getNextStep()
        }
        solver = SolverBeginnerLLCornersPosition(cube:cube)
        while(solver.hasNextStep()){
            _ = solver.getNextStep()
        }
        solver = SolverBeginnerLLCornersOrientation(cube:cube)
        var i = 0
        while(solver.hasNextStep() || i > 4){
            _ = solver.getNextStep()
            i += 1
        }
        if cube.isSovled(){
            return true
        }
        return false
    }
    public 	 func deepCopyCube() -> RubiksCube{
        let cube = RubiksCube()
        for i in 0..<cubelets.count{
            cube.cubelets[i] = Cublet(node: SCNNode(),
                                      pos: self.cubelets[i].pos,
                                      upDown: self.cubelets[i].upDown,
                                      leftRight: self.cubelets[i].leftRight,
                                      frontBack: self.cubelets[i].frontBack)
        }
        return cube
    }
    public func scramble(turnsCount:Int = 30) -> [SCNAction] {
        let turns = [Turn.D, Turn.DN, Turn.F, Turn.FN, Turn.R, Turn.RN,
                     Turn.L, Turn.LN, Turn.U, Turn.UN, Turn.B, Turn.BN,
                     Turn.L2, Turn.R2, Turn.B2, Turn.F2, Turn.U2, Turn.D2]
        
        var actions:[SCNAction] = []

        for _ in 0..<turnsCount {
            let turn = turns.randomElement()
            if let t = turn {
                actions.append(turnFromEnum(turn: t))
            }
        }
        return actions
    }
    public func runTurns(turns:[Turn]) {
        scene.rootNode.runAction(SCNAction.sequence(getTurnActions(turns: turns)))
    }
    //If there was an action created and not run, this must be performed before the another action is created.
    public func undoTurns(steps:[Turn]) -> [SCNAction]{
        var turns:[Turn] = []
        for turn in steps.reversed() {
            for _ in 0..<3 {
                turns.append(turn)
            }
        }
        let actions = getTurnActions(turns: turns)
        self.printCube()
        return actions
    }
    // MARK: private turn set functions
    private func turnFromEnum(turn:Turn) -> SCNAction {
        switch turn {
        // Standard Turns
        case Turn.D:
            return downTurn(direction: 1)
        case Turn.DN:
            return downTurn(direction: -1)
        case Turn.D2:
            return SCNAction.sequence([downTurn(direction: 1), downTurn(direction: 1)])
        case Turn.U:
            return upTurn(direction: 1)
        case Turn.UN:
            return upTurn(direction: -1)
        case Turn.U2:
            return SCNAction.sequence([upTurn(direction: 1), upTurn(direction: 1)])
        case Turn.R:
            return rightTurn(direction: 1)
        case Turn.RN:
            return rightTurn(direction: -1)
        case Turn.R2:
            return SCNAction.sequence([rightTurn(direction: 1), rightTurn(direction: 1)])
        case Turn.L:
            return leftTurn(direction: 1)
        case Turn.LN:
            return leftTurn(direction: -1)
        case Turn.L2:
            return SCNAction.sequence([leftTurn(direction: 1), leftTurn(direction: 1)])
        case Turn.F:
            return frontTurn(direction: 1)
        case Turn.FN:
            return frontTurn(direction: -1)
        case Turn.F2:
            return SCNAction.sequence([frontTurn(direction: 1), frontTurn(direction: 1)])
        case Turn.B:
            return backTurn(direction: 1)
        case Turn.BN:
            return backTurn(direction: -1)
        case Turn.B2:
            return SCNAction.sequence([backTurn(direction: 1), backTurn(direction: 1)])
        // Middle layer turns
        case Turn.M:
            return mTurn(direction: 1)
        case Turn.MN:
            return mTurn(direction: -1)
        case Turn.M2:
            return SCNAction.sequence([mTurn(direction: 1), mTurn(direction: 1)])
        case Turn.E:
            return eTurn(direction: 1)
        case Turn.EN:
            return eTurn(direction: -1)
        case Turn.E2:
            return SCNAction.sequence([eTurn(direction: 1), eTurn(direction: 1)])
        case Turn.S:
            return sTurn(direction: 1)
        case Turn.SN:
            return sTurn(direction: -1)
        case Turn.S2:
            return SCNAction.sequence([sTurn(direction: 1), sTurn(direction: 1)])
        case Turn.X:
            return rotateAllX(direction: 1)
        case Turn.XN:
            return rotateAllX(direction: -1)
        case Turn.X2:
            return SCNAction.sequence([rotateAllX(direction: 1), rotateAllX(direction: 1)])
        case Turn.Y:
            return rotateAllY(direction: 1)
        case Turn.YN:
            return rotateAllY(direction: -1)
        case Turn.Y2:
            return SCNAction.sequence([rotateAllY(direction: 1), rotateAllY(direction: 1)])
        case Turn.Z:
            return rotateAllZ(direction: 1)
        case Turn.ZN:
            return rotateAllZ(direction: -1)
        case Turn.Z2:
            return SCNAction.sequence([rotateAllZ(direction: 1), rotateAllZ(direction: 1)])
        }
        
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
public class Cublet{
    var node:SCNNode
    var pos:Int
    var upDown:CubletColor
    var leftRight:CubletColor
    var frontBack:CubletColor
    let type:PieceType
    var lastElapsedTime:Double = 0.0
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
public enum CubletColor {
    case red
    case blue
    case yellow
    case white
    case orange
    case green
    case noColor
}
public func cubletColor(from :CubletColor) -> UIColor {
    switch from{
    case .red:
        return UIColor.red
    case .blue:
        return UIColor.blue
    case .yellow:
        return UIColor.yellow
    case .white:
        return UIColor.white
    case .orange:
        return UIColor.orange
    case .green:
        return UIColor.green
    case .noColor:
        return UIColor.gray
    }
}
enum PieceType {
    case corner
    case wedge
    case center
    case middlePiece
}
public enum Turn {
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
    case M2
    case E2
    case S2
    case X
    case XN
    case X2
    case Y
    case YN
    case Y2
    case Z
    case ZN
    case Z2
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
public func stringToColor(color:String) -> CubletColor{
    
    switch color.lowercased() {
    case "yellow":
        return .yellow
    case "white":
        return .white
    case "red":
        return .red
    case "orange":
        return .orange
    case "blue":
        return .blue
    case "green":
        return .green
    default:
        return .noColor
    }
}
