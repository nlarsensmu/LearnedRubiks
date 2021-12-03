//
//  SolverBeginnerLLCorners.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit

class SolverBeginnerLLCornersPosition: SolverBase {
    var stepString: String = "Solve Last Layer Corner Positions"
    
    var cube: RubiksCube
    var steps = 0
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    let rotate3CornersAlg = [Turn.U, Turn.R, Turn.UN, Turn.LN, Turn.U, Turn.RN, Turn.UN, Turn.L]
    let cornerAlg = [Turn.RN, Turn.DN, Turn.R, Turn.D]
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func nameOfStep() -> String {
        return "Solve Corner Posistions"
    }
    
    func getNextStep() -> SolvingStep {
        steps += 1
        let result = solve()
        return SolvingStep(description: nameOfStep(), actions: result.0, steps:result.1)
    }
    
    func hasNextStep() -> Bool{
        if steps >= 1{
            return false
        }
        return true
    }
    
    func solve() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        let result = positionCorner()
        actions.append(contentsOf: result.0)
        turns.append(contentsOf: result.1)
        
        return (actions, turns)
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
    
    func positionCorner() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        var count = countCorectCorners()
        
        // if count is 0, we need to do rotation once to get one that is right.
        if count == 0 {
            actions.append(cube.empasize(poses: [19,21,25,27], asGroup: true))
            actions.append(contentsOf: cube.getTurnActions(turns: rotate3CornersAlg))
            turns.append(contentsOf: rotate3CornersAlg)
            count = 1
        }
        
        if count == 1 {
            
            // Check if we are already correct
            let frontRightCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 11).leftRight]!
                | hashColorDict[cube.cublet(at: 13).frontBack]!
            
            let frontRightCornerCorrect = frontRightCorner == hashColor(cublet: cube.cublet(at: 19))
            
            // we are done.
            if frontRightCornerCorrect {
            }
            
            // Check the RightBack
            let rightBackCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 11).leftRight]!
                | hashColorDict[cube.cublet(at: 15).frontBack]!
            let backRightCornerCorrect = rightBackCorner == hashColor(cublet: cube.cublet(at: 21))
            
            // Turn it to pos 19
            if backRightCornerCorrect {
                turns.append(.Y)
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            }
            
            // Check the LeftBack
            let leftBackCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 17).leftRight]!
                | hashColorDict[cube.cublet(at: 15).frontBack]!
            let backLeftCornerCorrect = leftBackCorner == hashColor(cublet: cube.cublet(at: 27))
            
            // Turn it to pos 19
            if backLeftCornerCorrect {
                turns.append(.Y2)
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            }
            
            // Check the leftFront
            let leftFrontCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 17).leftRight]!
                | hashColorDict[cube.cublet(at: 13).frontBack]!
            let frontLeftCornerCorrect = leftFrontCorner == hashColor(cublet: cube.cublet(at: 25))
            
            // Turn it to pos 19
            if frontLeftCornerCorrect {
                turns.append(.YN)
                actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            }
            
            
            actions.append(cube.empasize(poses: [19], asGroup: true))
            // Perform
            while countCorectCorners() != 4 {
                turns.append(contentsOf: rotate3CornersAlg)
                actions.append(contentsOf: cube.getTurnActions(turns: rotate3CornersAlg))
            }
        }
        
        return (actions, turns)
    }
}
