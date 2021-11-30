//
//  SovlerFirstCorners.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/18/21.
//

import Foundation
import SceneKit
import AVFoundation

class SolverFirstCorners: SolverBase {
    var stepString: String = "Solve First Layer Corners"
    
    var cube: RubiksCube
    var steps:Int = 0
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    let cornerOrder:[(CubletColor, CubletColor)] =
        [(.red, .green), (.red, .blue), (.orange, .green), (.orange, .blue)]
    
    let cornerAlg = [Turn.RN, Turn.DN, Turn.R, Turn.D]
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func nameOfStep() -> String {
        if steps == 0 { return "Solve Red Green White Corner" }
        else if steps == 1 { return "Solve Red Blue White Corner"}
        else if steps == 2 { return "Solve Orange Green White Corner"}
        else if steps == 3 { return "Solve Orange Blue White Corner"}
        
        return ""
    }
    
    func getNextStep() -> SolvingStep {
        let result = solveCorner(c1: cornerOrder[steps].0, c2: cornerOrder[steps].1)
        let step = SolvingStep(description: nameOfStep(), actions: result.0, steps:result.1)
        steps += 1
        return step
    }
    
    func hasNextStep() -> Bool{
        if steps >= 4{
            return false
        }
        return true
    }
    
    func solveCorner(c1:CubletColor, c2:CubletColor) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        let resultDown = getCornerDown(c1: c1, c2: c2, c3: CubletColor.white)
        actions.append(contentsOf: resultDown.0)
        turns.append(contentsOf: resultDown.1)
        let resultOnBottom = positionConerOnBottom(c1: c1, c2: c2)
        actions.append(contentsOf: resultOnBottom.0)
        turns.append(contentsOf: resultOnBottom.1)
        let resultRepeatCorner = reapeatCornerAlg()
        actions.append(contentsOf: resultRepeatCorner.0)
        turns.append(contentsOf: resultRepeatCorner.1)
        return (actions, turns)
    }
    
    func solve() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        let greenRed = solveCorner(c1: .red, c2: .green)
        actions.append(contentsOf: greenRed.0)
        turns.append(contentsOf: greenRed.1)
        let redBlue = solveCorner(c1: .red, c2: .blue)
        actions.append(contentsOf: redBlue.0)
        turns.append(contentsOf: redBlue.1)
        let orangeGreen = solveCorner(c1: .orange, c2: .green)
        actions.append(contentsOf: orangeGreen.0)
        turns.append(contentsOf: orangeGreen.1)
        let orangeBlue = solveCorner(c1: .orange, c2: .blue)
        actions.append(contentsOf: orangeBlue.0)
        turns.append(contentsOf: orangeBlue.1)
        
        return (actions, turns)
    }
    
    func getCornerDown(c1:CubletColor, c2:CubletColor, c3:CubletColor) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        let pos = getCubletPosition(c1: c1, c2: c2, c3: c3)
        
        if pos == 21 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
            turns.append(.Y)
            turns.append(contentsOf: cornerAlg)
        } else if pos == 27 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
            turns.append(.Y2)
            turns.append(contentsOf: cornerAlg)
        } else if pos == 25 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
            turns.append(.YN)
            turns.append(contentsOf: cornerAlg)
        } else if pos == 19 {
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
            turns.append(contentsOf: cornerAlg)
        } else if pos == 3 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            turns.append(.Y)
        } else if pos == 9 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
        } else if pos == 7 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            turns.append(.YN)
        }
        return (actions, turns)
    }
    
    // Assume the corner we are positioning is in location 1
    func positionConerOnBottom(c1:CubletColor, c2:CubletColor) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction]  = []
        var turns:[Turn] = []
        
        let toPos = getCornerBottomLocation(c1: c1, c2: c2)
        
        if toPos == 3 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.D, .Y]))
            turns.append(contentsOf: [.D, .Y])
        } else if toPos == 9 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .Y2]))
            turns.append(contentsOf: [.D2, .Y2])
        } else if toPos == 7 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .YN]))
            turns.append(contentsOf: [.DN, .YN])
        }
        
        return (actions, turns)
    }
    
    // Get the bottom layer corner position a corner with c1 and c2 should be in.
    func getCornerBottomLocation(c1:CubletColor, c2:CubletColor) -> Int {
        let pos1 = getCubletPosition(c1: c1, c2: .noColor, c3: .noColor)
        let pos2 = getCubletPosition(c1: c2, c2: .noColor, c3: .noColor)
        
        // pos1 is 13.
        if pos1 == 13 && pos2 == 11 {
            return 1
        } else if pos1 == 13 && pos2 == 17 {
            return 7
        }
        // pos1 == 11
        else if pos1 == 11 && pos2 == 13 {
            return 1
        } else if pos1 == 11 && pos2 == 15 {
            return 3
        }
        // pos1 15
        else if pos1 == 15 && pos2 == 11 {
            return 3
        } else if pos1 == 15 && pos2 == 17 {
            return 9
        }
        // pos1 == 17
        else if pos1 == 17 && pos2 == 13 {
            return 7
        } else if pos1 == 17 && pos2 == 15 {
            return 9
        }
        
        return 0
    }
    
    // we assume that the cube is turned such that the corner is below
    // where it is supposed to go and is on the right face.
    func reapeatCornerAlg() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction]  = []
        var turns:[Turn] = []
        
        // check that the cublet at pos 1 is in below where it belongs
        
        // current color
        let currentColor = hashColorDict[cube.cublet(at: 13).frontBack]! | hashColorDict[cube.cublet(at: 23).upDown]! | hashColorDict[cube.cublet(at: 11).leftRight]!
        if !(hashColor(cublet: cube.cublet(at: 1)) == currentColor) {
            // If we get here something went wrong.
            return (actions, turns)
        }
        
        while cube.cublet(at: 19).upDown != cube.cublet(at: 23).upDown ||
            cube.cublet(at: 19).leftRight != cube.cublet(at: 20).leftRight ||
            cube.cublet(at: 19).frontBack != cube.cublet(at: 22).frontBack {
            
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
            turns.append(contentsOf: cornerAlg)
        }
        
        return (actions, turns)
    }
}
