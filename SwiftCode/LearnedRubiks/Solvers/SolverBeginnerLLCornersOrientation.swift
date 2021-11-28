//
//  SolverBeginnerLLCorners.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit

class SolverBeginnerLLCornersOrientation: SolverBase {
    
    var cube: RubiksCube
    var step = 0
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    let rotate3CornersAlg = [Turn.U, Turn.R, Turn.UN, Turn.LN, Turn.U, Turn.RN, Turn.UN, Turn.L]
    let cornerAlg = [Turn.RN, Turn.DN, Turn.R, Turn.D]
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func nameOfStep() -> String {
        return "Solve Corner Orientation"
    }
    
    func getNextStep() -> SolvingStep {
        step += 1
        return SolvingStep(description: nameOfStep(), steps: solve())
    }
    
    func hasNextStep() -> Bool{
        if step >= 1{
            return false
        }
        return true
    }
    
    func solve() -> [SCNAction]{
        var actions:[SCNAction] = []
        
        actions.append(contentsOf: orientateCorners())
        
//        cube.scene.rootNode.runAction(SCNAction.sequence(actions))
        return actions
    }
    
    // MARK: position the conrners
    func countCorectCorners() -> Int {
        
        var count = 0
        
        let frontRightUp = hashColorDict[cube.cublet(at: 13).frontBack]! | hashColorDict[cube.cublet(at: 11).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 19)) == frontRightUp {
            count += 1
        }
        
        let frontLeftUp = hashColorDict[cube.cublet(at: 13).frontBack]! | hashColorDict[cube.cublet(at: 17).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 25)) == frontLeftUp {
            count += 1
        }
        
        let backRightUp = hashColorDict[cube.cublet(at: 15).frontBack]! | hashColorDict[cube.cublet(at: 11).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 21)) == backRightUp {
            count += 1
        }
        
        let backLeftUp = hashColorDict[cube.cublet(at: 15).frontBack]! | hashColorDict[cube.cublet(at: 17).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 27)) == backLeftUp {
            count += 1
        }
        
        return count
    }
    
    // MARK: Oreintate the corners
    
    // This checks if the corner has the right color UP
    func checkFrontRightUpCornerOrientation() -> Bool {
        let frontRightUp = cube.cublet(at: 19)
        
        let upCenter = cube.cublet(at: 23)
        
        let frontRightCornerCorrect = frontRightUp.upDown == upCenter.upDown
        
        return frontRightCornerCorrect
    }
    
    func orientateCorners() -> [SCNAction] {
        var actions:[SCNAction] = []
        for _ in 0..<4 { // For each corner
            
            
            var frontRightCornerCorrect = checkFrontRightUpCornerOrientation()
            
            while !frontRightCornerCorrect {
                actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
                frontRightCornerCorrect = checkFrontRightUpCornerOrientation()
            }
            
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
        }
        
        return actions
    }
}

