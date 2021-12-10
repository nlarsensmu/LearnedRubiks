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
import AVFoundation
import CoreML

class SolverCross : SolverBase {
    var stepString: String = "Solve Cross"
    
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    
    var cube:RubiksCube
    var protectedFaces:[Turn] = []
    var steps:Int = 0
    public init(c:RubiksCube) {
        cube = c
    }
    
    func nameOfStep() -> String {
        if steps == 0 {
            return "White on Top"
        }
        else if steps == 1 {
            return "Fix Position of Green White Wedge"
        }
        else if steps == 2 {
            return "Fix Position of Red White Wedge"
        }
        else if steps == 3 {
            return "Fix Position of Blue White Wedge"
        }
        else if steps == 4 {
            return "Fix Position of Orange White Wedge"
        }
        else if steps == 5 {
            return "Fix Orientation of Wedges"
        }
        else{
            return "Solve Corners"
        }
    }
    
    func getNextStep(emphasis:Bool) -> SolvingStep {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        if steps == 0 {
            let whiteOnTop = whiteOnTop()
            actions = whiteOnTop.0
            turns = whiteOnTop.1
        }
        else if steps == 1{
            let solveWedgePositions = solveWedgePosition(c1: CubletColor.green, emphasis: emphasis)
            actions = solveWedgePositions.0
            turns = solveWedgePositions.1
        }
        else if steps == 2 {
            let solveWedgePositions = solveWedgePosition(c1: CubletColor.red, emphasis: emphasis)
            actions = solveWedgePositions.0
            turns = solveWedgePositions.1
        }
        else if steps == 3 {
            let solveWedgePositions = solveWedgePosition(c1: CubletColor.blue, emphasis: emphasis)
            actions = solveWedgePositions.0
            turns = solveWedgePositions.1
        }
        else if steps == 4 {
            let solveWedgePositions = solveWedgePosition(c1: CubletColor.orange, emphasis: emphasis)
            actions = solveWedgePositions.0
            turns = solveWedgePositions.1
        }
        else if steps == 5 {
            let fixOrientation = fixOrientation(emphasis: emphasis)
            actions = fixOrientation.0
            turns = fixOrientation.1
        }
        steps += 1
        return SolvingStep(description: nameOfStep(), actions:actions, steps:turns)
    }
    
    func hasNextStep() -> Bool{
        if steps >= 6 {
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
    
    func solveWedgePosition(c1:CubletColor, emphasis:Bool) -> ([SCNAction], [Turn]) {
        
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        // White Green wedge
        var pos = getCubletPosition(c1: CubletColor.white, c2: c1, c3:CubletColor.noColor)
        let result = turnWedgeToBottom(pos:pos)
        actions.append(contentsOf: result.0)
        turns.append(contentsOf: result.1)
        
        // Turn correct center to forground
        var centerPos = getCubletPosition(c1: c1, c2: CubletColor.noColor, c3: CubletColor.noColor)
        let foreground = turnCenterToForeground(centerPos: centerPos)
        actions.append(contentsOf: foreground.0)
        turns.append(contentsOf: foreground.1)
        centerPos = getCubletPosition(c1: c1, c2: CubletColor.noColor, c3: CubletColor.noColor)
        if emphasis { actions.append(cube.empasize(poses: [centerPos], asGroup: true)) }
        
        // Turn to the top layer
        pos = getCubletPosition(c1: CubletColor.white, c2: c1, c3: CubletColor.noColor)
        let foregroundWedge = turnWedgeToForeground(pos: pos)
        actions.append(contentsOf: foregroundWedge.0)
        turns.append(contentsOf: foregroundWedge.1)
        
        pos = getCubletPosition(c1: CubletColor.white, c2: c1, c3: CubletColor.noColor)
        if emphasis { actions.append(cube.empasize(poses: [pos], asGroup: true)) }
        centerPos = getCubletPosition(c1: c1, c2: CubletColor.noColor, c3: CubletColor.noColor)
        let turnWedgeUp = turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos)
        actions.append(contentsOf: turnWedgeUp.0)
        turns.append(contentsOf: turnWedgeUp.1)
        addPosToProtected(pos: centerPos)
        
        return (actions, turns)
    }
    
    func turnCenterToForeground(centerPos:Int) -> ([SCNAction], [Turn]) {
        if centerPos == 15 { // Back face
            let actions = cube.getTurnActions(turns: [.Y])
            updateProtectedTurns(turn: .Y)
            return (actions, [.Y])
        } else if centerPos == 17 {
            let actions = cube.getTurnActions(turns: [.YN])
            updateProtectedTurns(turn: .YN)
            return (actions, [.YN])
        }
        let actions:[SCNAction] = []
        let turns:[Turn] = []
        return (actions, turns)
    }
    
    func turnWedgeToForeground(pos:Int) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if pos == 6 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            turns.append(.Y)
            updateProtectedTurns(turn: .Y)
        } else if pos == 8 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            turns.append(.YN)
            updateProtectedTurns(turn: .YN)
        }
        return (actions, turns)
    }
    
    func solveWedgePositions(emphasis: Bool) -> ([SCNAction], [Turn]){
        
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        // White Green wedge
        var actionsTurns = solveWedgePosition(c1: CubletColor.green, emphasis: emphasis)
        actions.append(contentsOf: actionsTurns.0)
        turns.append(contentsOf: actionsTurns.1)
        
        // White Red Wedge
        actionsTurns = solveWedgePosition(c1: CubletColor.red, emphasis: emphasis)
        actions.append(contentsOf: actionsTurns.0)
        turns.append(contentsOf: actionsTurns.1)
        
        
        // White Blue Wedge
        actionsTurns = solveWedgePosition(c1: CubletColor.blue, emphasis: emphasis)
        actions.append(contentsOf: actionsTurns.0)
        turns.append(contentsOf: actionsTurns.1)
        
        // White Orange Wedge
        actionsTurns = solveWedgePosition(c1: CubletColor.orange, emphasis: emphasis)
        actions.append(contentsOf: actionsTurns.0)
        turns.append(contentsOf: actionsTurns.1)
        
        return (actions,turns)
    }
    
    func turnWedgeToBottom(pos:Int) -> ([SCNAction], [Turn]) {
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
            return (actions, turns)
        } else if pos == 12 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.R]))
            turns.append(.R)
            var newPos = 2
            if protectedFaces.contains(.R) {
                newPos = 6
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .RN]))
                turns.append(contentsOf: [.D,.RN])
            }
            return (actions, turns)
        } else if pos == 16 {
            var newPos = 8
            actions.append(contentsOf: cube.getTurnActions(turns: [.L]))
            turns.append(.L)
            if protectedFaces.contains(.L) {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .LN]))
                turns.append(contentsOf: [.D,.LN])
                newPos = 4
            }
            return (actions, turns)
        } else if pos == 18 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.LN]))
            turns.append(contentsOf: [.LN])
            var newPos = 8
            if protectedFaces.contains(.L) {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .L]))
                turns.append(contentsOf: [.D,.L])
                newPos = 4
            }
            return (actions, turns)
        }
        
        // Wedge on the top, these can't be protected
        else if pos == 20 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.R2]))
            turns.append(.R2)
            return (actions, turns)
        } else if pos == 22 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.F2]))
            turns.append(.F2)
            return (actions, turns)
        } else if pos == 24 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.B2]))
            turns.append(.B2)
            return (actions, turns)
        } else if pos == 26 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.L2]))
            turns.append(.L2)
            return (actions, turns)
        }
        
        return (actions, turns)
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
    func fixOrientation(emphasis:Bool) -> ([SCNAction], [Turn]) {
        
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        // For each wedge on the top
        for _ in 0..<4 {
            //actions.append(cube.empasize(poses: [22], asGroup: false))
            if cube.cublet(at: 22).upDown != CubletColor.white {
                if emphasis { actions.append(cube.empasize(poses: [22], asGroup: true)) }
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
    
    func updateProtectedTurns(turn:Turn) {
        
        for i in 0..<protectedFaces.count {
            if protectedFaces[i] == .R {
                if turn == .Y {
                    protectedFaces[i] = .F
                } else if turn == .Y2 {
                    protectedFaces[i] = .L
                } else if turn == .YN {
                    protectedFaces[i] = .B
                }
            } else if protectedFaces[i] == .L {
                if turn == .Y {
                    protectedFaces[i] = .B
                } else if turn == .Y2 {
                    protectedFaces[i] = .L
                } else if turn == .YN {
                    protectedFaces[i] = .F
                }
            } else if protectedFaces[i] == .F {
                if turn == .Y {
                    protectedFaces[i] = .L
                } else if turn == .Y2 {
                    protectedFaces[i] = .B
                } else if turn == .YN {
                    protectedFaces[i] = .R
                }
            } else if protectedFaces[i] == .B {
                if turn == .Y {
                    protectedFaces[i] = .R
                } else if turn == .Y2 {
                    protectedFaces[i] = .B
                } else if turn == .YN {
                    protectedFaces[i] = .L
                }
            }
        }
    }
}
