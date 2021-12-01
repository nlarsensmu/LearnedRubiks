//
//  SolverLastLayerBeginner.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit

class SolverLastCrossBB: SolverBase {
    var stepString: String = "Solver Last Layer Cross"
    
    
    var cube: RubiksCube
    var steps = 0
    let crossTurns = [Turn.F, Turn.R, Turn.U, Turn.RN, Turn.UN, Turn.FN]
    
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    init(cube:RubiksCube) {
        self.cube = cube
        var sum = sumUpWedges()
        if sum == 0 {
            steps = 0
        } else if [42, 44, 48, 50].contains(sum) {
            steps = 1
        } else if sum == 46 {
            steps = 2
        } else {
            sum = 3
        }
    }
    
    let stepNames:[String] = ["Case: Dot", "Case L", "Case Line", "You're Done!"]
    func nameOfStep() -> String {
        return stepNames[steps]
    }
    
    func getNextStep() -> SolvingStep {
        
        let sum = sumUpWedges()
        var result:([SCNAction], [Turn]) = ([], [])
        let stepName = nameOfStep()
        
        if sum == 0 { // dot
            steps = 0
            result = processDot(sum: sum)
        } else if [42, 44, 48, 50].contains(sum) { // L
            steps = 1
            result = processL(sum: sum)
        } else if sum == 46 { // line case
            steps = 2
            result = processLine(sum: sum)
        } else {
            steps = 3 // Cross!
        }
        
        return SolvingStep(description: stepName, actions: result.0, steps: result.1)
    }
    
    func hasNextStep() -> Bool{
        if steps >= 2{
            return false
        }
        return true
    }
    
    func solve() -> ([SCNAction], [Turn]) {
        let result = solveCross()
        return result
    }
    
    // MARK: Functions for solving cross
    
    func solveCross() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        // sum the cublets on the top to get what state we are in
        
        // 92 means cross, 50 44 42 are L, and 46 and 48 are lines
        var sum = sumUpWedges()
        let dot = processDot(sum: sum)
        actions.append(contentsOf: dot.0)
        turns.append(contentsOf: dot.1)
        
        sum = sumUpWedges()
        let l = processL(sum: sum)
        actions.append(contentsOf: l.0)
        turns.append(contentsOf: l.1)

        sum = sumUpWedges()
        let line = processLine(sum: sum)
        actions.append(contentsOf: line.0)
        turns.append(contentsOf: line.1)
        
        return (actions, turns)
    }
    
    func sumUpWedges() -> Int {
        var sum = 0
        if cube.cublet(at: 22).upDown == .yellow { sum += 22}
        if cube.cublet(at: 20).upDown == .yellow { sum += 20}
        if cube.cublet(at: 24).upDown == .yellow { sum += 24}
        if cube.cublet(at: 26).upDown == .yellow { sum += 26}
        return sum
    }
    
    func processDot(sum:Int) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if sum == 0 {
            // All cubes are down, must be a dot
            if cube.cublet(at: 22).upDown != .white && cube.cublet(at: 20).upDown != .white && cube.cublet(at: 24).upDown != .white && cube.cublet(at: 26).upDown != .white {
                
                actions.append(cube.empasize(poses: [23], asGroup: true))
                actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
                turns.append(contentsOf: crossTurns)
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
                turns.append(.Y2)
            }
        }
        return (actions, turns)
    }
    
    func processL(sum:Int) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if [42, 44, 48, 50].contains(sum){
            if sum == 42 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
                turns.append(.Y2)
            } else if sum == 44 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
                turns.append(.YN)
            } else if sum == 48 {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
                turns.append(.Y)
            }
            
            actions.append(cube.empasize(poses: [23, 24, 26], asGroup: true))
            actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
            turns.append(contentsOf: crossTurns)
        }
        
        return (actions, turns)
    }
    
    func processLine(sum:Int) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if sum == 46 {
            if cube.cublet(at: 22).upDown == .yellow {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
                turns.append(.Y)
            }
            actions.append(cube.empasize(poses: [20, 23, 26], asGroup: true))
            actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
            turns.append(contentsOf: crossTurns)
        }
        
        return (actions, turns)
    }
}
