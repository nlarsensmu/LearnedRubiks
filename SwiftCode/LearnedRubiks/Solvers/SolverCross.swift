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
        if steps == 0{
            actions = whiteOnTop()
        }
        else if steps == 1{
            actions = solveWedgePositions()
        }
        else if steps == 2{
            actions = fixOrientation()
        }
        steps += 1
        return SolvingStep(description: nameOfStep(), steps: actions)
    }
    
    func hasNextStep() -> Bool{
        if steps >= 3 {
            return false
        }
        return true
    }
    func solve() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        actions.append(contentsOf: whiteOnTop())
        actions.append(contentsOf: solveWedgePositions())
        actions.append(contentsOf: fixOrientation())
        
        return actions
    }
    
    func whiteOnTop() -> [SCNAction]{
        var actions:[SCNAction] = []
        // white is on the right
        if cube.cublet(at: 11).leftRight == CubletColor.white {
            actions.append(contentsOf: cube.getTurnActions(turns: [.ZN]))
        } else if (cube.cublet(at: 17).leftRight == CubletColor.white) {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Z]))
        } else if (cube.cublet(at: 13).frontBack == CubletColor.white) {
            actions.append(contentsOf: cube.getTurnActions(turns: [.X]))
        }
        else if (cube.cublet(at: 15).frontBack == CubletColor.white) {
            actions.append(contentsOf: cube.getTurnActions(turns: [.XN]))
        }
        else if (cube.cublet(at: 5).upDown == CubletColor.white) {
            actions.append(contentsOf: cube.getTurnActions(turns: [.X, .X]))
        }
        //actions.append(cube.empasize(poses: [23], asGroup: false))
        return actions
    }
    
    func solveWedgePositions() -> [SCNAction]{
        
        var actions:[SCNAction] = []
        // White Green wedge
        var pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.green, c3:CubletColor.noColor)
        var result = turnWedgeToBottom(pos:pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        var centerPos = getCubletPosition(c1: CubletColor.green, c2: CubletColor.noColor, c3: CubletColor.noColor)
        actions.append(contentsOf: turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos))
        addPosToProtected(pos: centerPos)
        
        // White Red Wedge
        pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.red, c3: CubletColor.noColor)
        result = turnWedgeToBottom(pos: pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        centerPos = getCubletPosition(c1: CubletColor.red, c2: CubletColor.noColor, c3: CubletColor.noColor)
        actions.append(contentsOf: turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos))
        addPosToProtected(pos: centerPos)
        
        // White Blue Wedge
        pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.blue, c3: CubletColor.noColor)
        result = turnWedgeToBottom(pos: pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        centerPos = getCubletPosition(c1: CubletColor.blue, c2: CubletColor.noColor, c3: CubletColor.noColor)
        actions.append(contentsOf: turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos))
        addPosToProtected(pos: centerPos)
        
        // White Orange Wedge
        pos = getCubletPosition(c1: CubletColor.white, c2: CubletColor.orange, c3: CubletColor.noColor)
        result = turnWedgeToBottom(pos: pos)
        pos = result.0
        actions.append(contentsOf: result.1)
        centerPos = getCubletPosition(c1: CubletColor.orange, c2: CubletColor.noColor, c3: CubletColor.noColor)
        actions.append(contentsOf: turnWedgeOnBottomUp(wedgePos: pos, centerPos: centerPos))
        
        return actions
    }
    
    func turnWedgeToBottom(pos:Int) -> (Int, [SCNAction]) {
        // Wedge in the middle.
        var actions:[SCNAction] = []
        if pos == 10 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.RN]))
            var newPos = 2
            if protectedFaces.contains(.R) {
                newPos = 6
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .R]))
            }
            return (newPos, actions)
        } else if pos == 12 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.R]))
            var newPos = 2
            if protectedFaces.contains(.R) {
                newPos = 6
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .RN]))
            }
            return (newPos, actions)
        } else if pos == 16 {
            var newPos = 8
            actions.append(contentsOf: cube.getTurnActions(turns: [.L]))
            if protectedFaces.contains(.L) {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .LN]))
                newPos = 4
            }
            return (newPos, actions)
        } else if pos == 18 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.LN]))
            var newPos = 8
            if protectedFaces.contains(.L) {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .L]))
                newPos = 4
            }
            return (newPos, actions)
        }
        
        // Wedge on the top, these can't be protected
        else if pos == 20 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.R2]))
            return (2, actions)
        } else if pos == 22 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.F2]))
            return (4, actions)
        } else if pos == 24 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.B2]))
            return (6, actions)
        } else if pos == 26 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.L2]))
            return (8, actions)
        }
        
        return (pos, actions)
    }
    
    func turnWedgeOnBottomUp(wedgePos:Int, centerPos:Int) -> [SCNAction] {
        
        var actions:[SCNAction] = []
        
        // WedgePos is in the front.
        if wedgePos == 4 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.F, .F]))
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .R2]))
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .L2]))
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .B2]))
            }
        } else if wedgePos == 2 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .F2]))
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.R2]))
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .L2]))
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .B2]))
            }
        } else if wedgePos == 6 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .F2]))
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .R2]))
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .L2]))
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.B2]))
            }
        } else if wedgePos == 8 {
            if centerPos == 13 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D, .F2]))
            } else if centerPos == 11 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .R2]))
            } else if centerPos == 17 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.L2]))
            } else if centerPos == 15 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .B2]))
            }
        }
        return actions
    }
    
    // Once all wedges are fixed flip the ones that need it.
    func fixOrientation() -> [SCNAction] {
        
        var actions:[SCNAction] = []
        
        // For each wedge on the top
        for _ in 0..<4 {
            //actions.append(cube.empasize(poses: [22], asGroup: false))
            if cube.cublet(at: 22).upDown != CubletColor.white {
                actions.append(contentsOf: cube.getTurnActions(turns:[.F, .UN, .R, .U]))
            }
            actions.append(contentsOf: cube.getTurnActions(turns:[.Y]))
        }
        
        return actions
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
