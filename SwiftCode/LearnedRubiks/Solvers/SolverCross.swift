//
//  SolveCross.swift
//  LearnedRubiks
//  This is one of the solving methods in the process to solving the cube
//  It will solve the WHITE cross.
//  Created by Nicholas Larsen on 11/17/21.
//

import Foundation
import SceneKit
import CoreMotion

class SolverCross : SolverBase {
    var stepString: String
    
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    
    var cube:RubiksCube
    var protectedFaces:[Turn] = []
    var steps:Int = 0
    public init(c:RubiksCube) {
        cube = c
        self.stepString = ""
    }
    
    func nameOfStep() -> String {
        if steps == 0 {
            return "White on Top"
        }
        else if steps == 1 {
            return "Fix Position of Wedges"
        }
        else if steps == 2 {
            return "Fix Orientation of Wedges"
        }
        else{
            return "Solve Corners"
        }
    }
    
    func getNextStep() -> SolvingStep {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        if steps == 0 {
            let whiteOnTop = whiteOnTop()
            actions = whiteOnTop.0
            turns = whiteOnTop.1
        }
        else if steps == 1{
            let solveWedgePositions = solveWedgePositions()
            actions = solveWedgePositions.0
            turns = solveWedgePositions.1
        }
        else if steps == 2{
            let fixOrientation = fixOrientation()
            actions = fixOrientation.0
            turns = fixOrientation.1
        }
        steps += 1
        return SolvingStep(description: nameOfStep(), actions:actions, steps:turns)
    }
    
    func hasNextStep() -> Bool{
        if steps >= 3 {
            return false
        }
        return true
    }
    
    func whiteOnTop() -> ([SCNAction], [Turn]){
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        // white is on the right
        if cube.cublet(at: 11).leftRight == CubletColor.white {
            turns.append(.ZN)
            actions.append(contentsOf: cube.getTurnActions(turns: [.ZN]))
        } else if (cube.cublet(at: 17).leftRight == CubletColor.white) {
            turns.append(.Z)
            actions.append(contentsOf: cube.getTurnActions(turns: [.Z]))
        } else if (cube.cublet(at: 13).frontBack == CubletColor.white) {
            turns.append(.X)
            actions.append(contentsOf: cube.getTurnActions(turns: [.X]))
        }
        else if (cube.cublet(at: 15).frontBack == CubletColor.white) {
            turns.append(.XN)
            actions.append(contentsOf: cube.getTurnActions(turns: [.XN]))
        }
        else if (cube.cublet(at: 5).upDown == CubletColor.white) {
            turns.append(contentsOf: [.X, .X])
            actions.append(contentsOf: cube.getTurnActions(turns: [.X, .X]))
        }
        //actions.append(cube.empasize(poses: [23], asGroup: false))
        return (actions, turns)
    }
    
    func solveWedgePositions() -> ([SCNAction], [Turn]){
        
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        // White Green wedge
        var pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.green, c3:CubletColor.noColor)
        var result = turnWedgeToBottom(pos:pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        var centerPos = getCubletPosition(c1: CubletColor.green, c2: CubletColor.noColor, c3: CubletColor.noColor)
        var turnWedgeUp = turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos)
        actions.append(contentsOf: turnWedgeUp.0)
        turns.append(contentsOf: turnWedgeUp.1)
        addPosToProtected(pos: centerPos)
        
        // White Red Wedge
        pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.red, c3: CubletColor.noColor)
        result = turnWedgeToBottom(pos: pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        centerPos = getCubletPosition(c1: CubletColor.red, c2: CubletColor.noColor, c3: CubletColor.noColor)
        turnWedgeUp = turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos)
        actions.append(contentsOf: turnWedgeUp.0)
        turns.append(contentsOf: turnWedgeUp.1)
        addPosToProtected(pos: centerPos)
        
        // White Blue Wedge
        pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.blue, c3: CubletColor.noColor)
        result = turnWedgeToBottom(pos: pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        centerPos = getCubletPosition(c1: CubletColor.blue, c2: CubletColor.noColor, c3: CubletColor.noColor)
        turnWedgeUp = turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos)
        actions.append(contentsOf: turnWedgeUp.0)
        turns.append(contentsOf: turnWedgeUp.1)
        addPosToProtected(pos: centerPos)
        
        // White Orange Wedge
        pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.orange, c3: CubletColor.noColor)
        result = turnWedgeToBottom(pos: pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        centerPos = getCubletPosition(c1: CubletColor.orange, c2: CubletColor.noColor, c3: CubletColor.noColor)
        turnWedgeUp = turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos)
        actions.append(contentsOf: turnWedgeUp.0)
        turns.append(contentsOf: turnWedgeUp.1)
        
        return (actions,turns)
    }
    
    func turnWedgeToBottom(pos:Int) -> (Int, [SCNAction], [Turn]) {
        // Wedge in the middle.
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        if pos == 10 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.RN]))
            turns.append(.RN)
            var newPos = 2
            if protectedFaces.contains(.R) {
                newPos = 6
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .R]))
                turns.append(contentsOf:[.D, .R])
            }
            return (newPos, actions, turns)
        } else if pos == 12 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.R]))
            turns.append(.R)
            var newPos = 2
            if protectedFaces.contains(.R) {
                newPos = 6
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .RN]))
                turns.append(contentsOf: [.D,.RN])
            }
            return (newPos, actions, turns)
        } else if pos == 16 {
            var newPos = 8
            actions.append(contentsOf: cube.getTurnActions(turns: [.L]))
            turns.append(.L)
            if protectedFaces.contains(.L) {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .LN]))
                turns.append(contentsOf: [.D,.LN])
                newPos = 4
            }
            return (newPos, actions, turns)
        } else if pos == 18 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.LN]))
            turns.append(contentsOf: [.LN])
            var newPos = 8
            if protectedFaces.contains(.L) {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .L]))
                turns.append(contentsOf: [.D,.L])
                newPos = 4
            }
            return (newPos, actions, turns)
        }
        
        // Wedge on the top, these can't be protected
        else if pos == 20 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.R2]))
            turns.append(.R2)
            return (2, actions, turns)
        } else if pos == 22 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.F2]))
            turns.append(.F2)
            return (4, actions, turns)
        } else if pos == 24 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.B2]))
            turns.append(.B2)
            return (6, actions, turns)
        } else if pos == 26 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.L2]))
            turns.append(.L2)
            return (8, actions, turns)
        }
        
        return (pos, actions, turns)
    }
    
    func turnWedgeOnBottomUp(wedgePos:Int, centerPos:Int) -> ([SCNAction],[Turn]) {
        
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        // WedgePos is in the front.
        if wedgePos == 4 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.F, .F]))
                turns.append(contentsOf: [.F,.F])
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .R2]))
                turns.append(contentsOf: [.D,.R2])
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .L2]))
                turns.append(contentsOf: [.DN,.L2])
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .B2]))
                turns.append(contentsOf: [.D2,.B2])
            }
        } else if wedgePos == 2 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .F2]))
                turns.append(contentsOf: [.DN,.F2])
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.R2]))
                turns.append(contentsOf: [.R2])
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .L2]))
                turns.append(contentsOf: [.D2,.L2])
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .B2]))
                turns.append(contentsOf: [.D,.B2])
            }
        } else if wedgePos == 6 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .F2]))
                turns.append(contentsOf: [.D2,.F2])
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .R2]))
                turns.append(contentsOf: [.DN,.R2])
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .L2]))
                turns.append(contentsOf: [.D,.L2])
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.B2]))
                turns.append(contentsOf: [.B2])
            }
        } else if wedgePos == 8 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .F2]))
                turns.append(contentsOf: [.D,.F2])
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .R2]))
                turns.append(contentsOf: [.D2,.R2])
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.L2]))
                turns.append(contentsOf: [.L2])
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .B2]))
                turns.append(contentsOf: [.DN,.B2])
            }
        }
        return (actions, turns)
    }
    
    // Once all wedges are fixed flip the ones that need it.
    func fixOrientation() -> ([SCNAction], [Turn]) {
        
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        // For each wedge on the top
        for _ in 0..<4 {
            //actions.append(cube.empasize(poses: [22], asGroup: false))
            if cube.cublet(at: 22).upDown != CubletColor.white {
                actions.append(contentsOf: cube.getTurnActions(turns:[.F, .UN, .R, .U]))
                turns.append(contentsOf: [.F,.UN,.R,.U])
            }
            turns.append(.Y)
            actions.append(contentsOf: cube.getTurnActions(turns:[.Y]))
        }
        
        return (actions,turns)
    }
    
    // After a wedge is in the right place add it to the protected faces.
    // pos is the center pos representing that face
    func addPosToProtected(pos:Int) {
        if pos == 11 {
            protectedFaces.append(.R)
        } else if pos == 17 {
            protectedFaces.append(.L)
        } else if pos == 13 {
            protectedFaces.append(.F)
        } else if pos == 15 {
            protectedFaces.append(.B)
        }
    }
}
