//
//  SolverMiddle.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit

class SolverMiddle: SolverBase {
    var stepString: String = "Solve Middle Layer"
    
    var cube: RubiksCube
    var steps = 0
    let leftHanded = [Turn.UN, Turn.LN, Turn.U, Turn.L, Turn.U, Turn.F, Turn.UN, Turn.FN]
    let rightHanded = [Turn.U, Turn.R, Turn.UN, Turn.RN, Turn.UN, Turn.FN, Turn.U, Turn.F]
    
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    let wedgeOrder:[(CubletColor, CubletColor)] =
        [(.red, .green), (.red, .blue), (.orange, .green), (.orange, .blue)]
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func nameOfStep() -> String {
        if steps == 0 { return "Solve the Red Green Wedge" }
        else if steps == 1 { return "Solve the Red Blue Wedge" }
        else if steps == 2 { return "Solve the Orange Green Wedge" }
        else if steps == 3 { return "Solve the Orange Blue Wedge" }
        return ""
    }
    
    func getNextStep() -> SolvingStep {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if steps == 0 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.X2]))
            turns.append(contentsOf: [.X2])
        }
        
        if steps < 4 {
            let actionsTurns = solveWedge(c1: wedgeOrder[steps].0, c2: wedgeOrder[steps].1)
            actions.append(contentsOf: actionsTurns.0)
            turns.append(contentsOf: actionsTurns.1)
        }
        
        steps += 1
        return SolvingStep(description: nameOfStep(), actions: actions, steps:turns)
    }
    
    func hasNextStep() -> Bool{
        if steps >= 4 {
            return false
        }
        return true
    }
    
    func solveWedge(c1:CubletColor, c2:CubletColor) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        let wedgeToTop = getWedgeToTopFront(c1: c1, c2: c2)
        actions.append(contentsOf: wedgeToTop.0)
        turns.append(contentsOf: wedgeToTop.1)
        
        let wedgeToCorectFace = getWedgeToCorrectFace()
        actions.append(contentsOf: wedgeToCorectFace.0)
        turns.append(contentsOf: wedgeToCorectFace.1)
        
        actions.append(cube.empasize(poses: [13, 22], asGroup: true))
        
        let positionWedge = positionWedge()
        actions.append(contentsOf: positionWedge.0)
        turns.append(contentsOf: positionWedge.1)
        
        return (actions, turns)
    }
    
    func checkWedgeCorrect(c1:CubletColor, c2:CubletColor) -> Bool {
        
        let pos1 = getCubletPosition(c1: c1, c2: .noColor, c3: .noColor)
        let pos2 = getCubletPosition(c1: c2, c2: .noColor, c3: .noColor)
        
        // Possible center positions are 13, 11 or 17,13 or 11,15 or 15,17
        // all have unique sums so we will use that to case off this step
        
        if pos1 + pos2 == 24 { // 13 and 11
            let wedge = cube.cublet(at: 10)
            let center1 = cube.cublet(at: 13)
            let center2 = cube.cublet(at: 11)
            if wedge.frontBack == center1.frontBack && wedge.leftRight == center2.leftRight {
                return true
            }
        } else if pos1 + pos2 == 26 { // 11 and 15
            let wedge = cube.cublet(at: 12)
            let center1 = cube.cublet(at: 15)
            let center2 = cube.cublet(at: 11)
            if wedge.frontBack == center1.frontBack && wedge.leftRight == center2.leftRight {
                return true
            }
        } else if pos1 + pos2 == 30 { // 13 and 17
            let wedge = cube.cublet(at: 16)
            let center1 = cube.cublet(at: 13)
            let center2 = cube.cublet(at: 17)
            if wedge.frontBack == center1.frontBack && wedge.leftRight == center2.leftRight {
                return true
            }
        } else if pos1 + pos2 == 32 { // 13 and 17
            let wedge = cube.cublet(at: 18)
            let center1 = cube.cublet(at: 15)
            let center2 = cube.cublet(at: 17)
            if wedge.frontBack == center1.frontBack && wedge.leftRight == center2.leftRight {
                return true
            }
        }
        
        return false
    }
    
    // Look for the wedge in the middle, if it is pull it to the top
    func getWedgeToTopFront(c1:CubletColor, c2:CubletColor) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        var pos = getCubletPosition(c1: c1, c2: c2, c3: .noColor)
        
        // We cannot see this wedge
        if pos == 18 {
            actions.append(contentsOf: cube.getTurnActions(turns:[.Y]))
            turns.append(.Y)
            pos = 12
        }
        
        actions.append(cube.empasize(poses: [pos], asGroup: true))
        
        if pos == 10 {
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
            turns.append(contentsOf: rightHanded)
            
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
        } else if pos == 12 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            turns.append(.Y)
            
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
            turns.append(contentsOf: rightHanded)
            
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
            
        } else if pos == 16 {
            actions.append(contentsOf: cube.getTurnActions(turns: leftHanded))
            turns.append(contentsOf: leftHanded)
            
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
        } else if pos == 18 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
            
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
            turns.append(contentsOf: rightHanded)
            
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
        } else if pos == 20 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            turns.append(.Y)
        } else if pos == 24 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
        } else if pos == 26 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            turns.append(.YN)
        }
        
        return (actions, turns)
    }
    
    // Assume the wedge is at 22, get it to the correct front face.
    func getWedgeToCorrectFace() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        let frontColor = cube.cublet(at: 22).frontBack
        let pos = getCubletPosition(c1: frontColor, c2: .noColor, c3: .noColor)
        
        if pos == 11 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.UN, .Y]))
            turns.append(contentsOf: [.UN, .Y])
        } else if pos == 17 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U, .YN]))
            turns.append(contentsOf: [.U, .YN])
        } else if pos == 15 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U2, .Y2]))
            turns.append(contentsOf: [.U2, .Y2])
        }
        // we don't need to do anything for 13
        
        return (actions, turns)
    }
    
    // Assume the wedge is correctly in position 22, and belongs to the right or left positon 10 or 16
    func positionWedge() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        let upColor = cube.cublet(at: 22).upDown
        
        let pos = getCubletPosition(c1: upColor, c2: .noColor, c3: .noColor)
        
        if pos == 11 {
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
            turns.append(contentsOf: rightHanded)
        } else if pos == 17 {
            actions.append(contentsOf: cube.getTurnActions(turns: leftHanded))
            turns.append(contentsOf: leftHanded)
        }
        
        return (actions, turns)
    }
}
