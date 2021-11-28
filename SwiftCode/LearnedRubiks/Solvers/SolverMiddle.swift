//
//  SolverMiddle.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit

class SolverMiddle: SolverBase {
    var cube: RubiksCube
    var step = 0
    let leftHanded = [Turn.UN, Turn.LN, Turn.U, Turn.L, Turn.U, Turn.F, Turn.UN, Turn.FN]
    let rightHanded = [Turn.U, Turn.R, Turn.UN, Turn.RN, Turn.UN, Turn.FN, Turn.U, Turn.F]
    
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func nameOfStep() -> String {
        return "Solve Middle"
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
    
    func solve() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        actions.append(contentsOf: cube.getTurnActions(turns: [.X2]))
        
        if !checkWedgeCorrect(c1: .red, c2: .green) {
            actions.append(contentsOf: getWedgeToTopFront(c1: .red, c2: .green))
            actions.append(contentsOf: getWedgeToCorrectFace())
            actions.append(contentsOf: positionWedge())
        }
        if !checkWedgeCorrect(c1: .red, c2: .blue) {
            actions.append(contentsOf: getWedgeToTopFront(c1: .red, c2: .blue))
            actions.append(contentsOf: getWedgeToCorrectFace())
            actions.append(contentsOf: positionWedge())
        }
        if !checkWedgeCorrect(c1: .orange, c2: .green) {
            actions.append(contentsOf: getWedgeToTopFront(c1: .orange, c2: .green))
            actions.append(contentsOf: getWedgeToCorrectFace())
            actions.append(contentsOf: positionWedge())
        }
        if !checkWedgeCorrect(c1: .orange, c2: .blue) {
            actions.append(contentsOf: getWedgeToTopFront(c1: .orange, c2: .blue))
            actions.append(contentsOf: getWedgeToCorrectFace())
            actions.append(contentsOf: positionWedge())
        }
        
//        cube.scene.rootNode.runAction(SCNAction.sequence(actions))
        return actions
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
    func getWedgeToTopFront(c1:CubletColor, c2:CubletColor) -> [SCNAction] {
        var actions:[SCNAction] = []
        
        let pos = getCubletPosition(c1: c1, c2: c2, c3: .noColor)
        
        if pos == 10 {
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
        } else if pos == 12 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
        } else if pos == 16 {
            actions.append(contentsOf: cube.getTurnActions(turns: leftHanded))
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
        } else if pos == 18 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
        } else if pos == 20 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
        } else if pos == 24 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
        } else if pos == 26 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
        }
        
        return actions
    }
    
    // Assume the wedge is at 22, get it to the correct front face.
    func getWedgeToCorrectFace() -> [SCNAction]{
        var actions:[SCNAction] = []
        
        let frontColor = cube.cublet(at: 22).frontBack
        let pos = getCubletPosition(c1: frontColor, c2: .noColor, c3: .noColor)
        
        if pos == 11 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.UN, .Y]))
        } else if pos == 17 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U, .YN]))
        } else if pos == 15 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U2, .Y2]))
        }
        // we don't need to do anything for 13
        
        return actions
    }
    
    // Assume the wedge is correctly in position 22, and belongs to the right or left positon 10 or 16
    func positionWedge() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        let upColor = cube.cublet(at: 22).upDown
        
        let pos = getCubletPosition(c1: upColor, c2: .noColor, c3: .noColor)
        
        if pos == 11 {
            actions.append(contentsOf: cube.getTurnActions(turns: rightHanded))
        } else if pos == 17 {
            actions.append(contentsOf: cube.getTurnActions(turns: leftHanded))
        }
        
        return actions
    }
}
