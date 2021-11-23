//
//  SolverLastLayerBeginner.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit

class SolverLastCrossBB: SolverBase {
    
    
    var cube: RubiksCube
    
    let crossTurns = [Turn.F, Turn.R, Turn.U, Turn.RN, Turn.UN, Turn.FN]
    
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func solve() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        actions.append(contentsOf: solveCross())
        
//        cube.scene.rootNode.runAction(SCNAction.sequence(actions))
        return actions
    }
    
    // MARK: Functions for solving cross
    
    func solveCross() -> [SCNAction]{
        var actions:[SCNAction] = []
        
        // sum the cublets on the top to get what state we are in
        
        // 92 means cross, 50 44 42 are L, and 46 and 48 are lines
        var sum = sumUpWedges()
        actions.append(contentsOf:processDot(sum: sum))
        
        sum = sumUpWedges()
        actions.append(contentsOf: processL(sum: sum))

        sum = sumUpWedges()
        actions.append(contentsOf: processLine(sum: sum))
        
        return actions
    }
    
    func sumUpWedges() -> Int {
        var sum = 0
        if cube.cublet(at: 22).upDown == .yellow { sum += 22}
        if cube.cublet(at: 20).upDown == .yellow { sum += 20}
        if cube.cublet(at: 24).upDown == .yellow { sum += 24}
        if cube.cublet(at: 26).upDown == .yellow { sum += 26}
        return sum
    }
    
    func processDot(sum:Int) -> [SCNAction] {
        var actions:[SCNAction] = []
        
        if sum == 0 {
            // All cubes are down, must be a dot
            if cube.cublet(at: 22).upDown != .white && cube.cublet(at: 20).upDown != .white && cube.cublet(at: 24).upDown != .white && cube.cublet(at: 26).upDown != .white {
                actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            }
        }
        return actions
    }
    
    func processL(sum:Int) -> [SCNAction] {
        var actions:[SCNAction] = []
        
        if [42, 44, 48, 50].contains(sum){
            if sum == 42 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            } else if sum == 44 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            } else if sum == 48 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            }
            actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
        }
        
        return actions
    }
    
    func processLine(sum:Int) -> [SCNAction] {
        var actions:[SCNAction] = []
        
        if sum == 46 {
            if cube.cublet(at: 22).upDown == .yellow {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            }
            actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
        }
        
        return actions
    }
}
