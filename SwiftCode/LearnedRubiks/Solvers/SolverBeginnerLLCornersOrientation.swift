//
//  SolverBeginnerLLCorners.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit
import AVFAudio

class SolverBeginnerLLCornersOrientation: SolverBase {
    var stepString: String = """
Solve Last Layer Corner
Orientation
"""
    
    var cube: RubiksCube
    var steps = 1
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
    
    func getNextStep(emphasis:Bool) -> SolvingStep {
        steps += 1
        
        var result = orientateCorner19(emphasis:  emphasis)
        result.0.append(contentsOf: cube.getTurnActions(turns: [.U]))
        result.1.append(.U)
        return SolvingStep(description: nameOfStep(), actions: result.0, steps: result.1)
    }
    
    func hasNextStep() -> Bool{
        if steps >= 4{
            return false
        }
        return true
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
    
    func orientateCorner19(emphasis:Bool) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        var frontRightCornerCorrect = checkFrontRightUpCornerOrientation()
        if emphasis { actions.append(cube.empasize(poses: [19], asGroup: true)) }
        
        var ranAtLeastOnce:Bool = false
        while !frontRightCornerCorrect {
            ranAtLeastOnce = true
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
            turns.append(contentsOf: cornerAlg)
            frontRightCornerCorrect = checkFrontRightUpCornerOrientation()
        }
        if ranAtLeastOnce && emphasis {
            actions.append(cube.empasize(poses: [19], asGroup: true))
        }
        
        return (actions, turns)
    }
}

