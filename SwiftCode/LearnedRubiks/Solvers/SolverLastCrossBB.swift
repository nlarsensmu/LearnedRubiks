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
        let sum = sumUpWedges()
        if sum == 0 { // dot
            steps = 0
        } else if [42, 44, 48, 50].contains(sum) { // Case L
            steps = 1
        } else if sum == 46 { // case line
            steps = 2
        } else {
            steps = 3
        }
    }
    
    let stepNames:[String] = ["Case: Dot", "Case L", "Case Line", "You're Done!"]
    func nameOfStep() -> String {
        let sum = sumUpWedges()
        if sum == 0 { // dot
            return "Case: Dot"
        } else if [42, 44, 48, 50].contains(sum) { // Case L
            return "Case L"
        } else if sum == 46 { // case line
            return "Case Line"
        } else {
            return "Solved Cross"
        }
    }
    
    func getNextStep(emphasis:Bool) -> SolvingStep {
        
        let sum = sumUpWedges()
        var result:([SCNAction], [Turn]) = ([], [])
        let stepName = nameOfStep()
        
        if sum == 0 { // dot
            steps = 0
            result = processDot(sum: sum, emphasis: emphasis)
        } else if [42, 44, 48, 50].contains(sum) { // L
            steps = 1
            result = processL(sum: sum, emphasis: emphasis)
        } else if sum == 46 { // line case
            steps = 2
            result = processLine(sum: sum, emphasis: emphasis)
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
    
    func sumUpWedges() -> Int {
        var sum = 0
        if cube.cublet(at: 22).upDown == .yellow { sum += 22}
        if cube.cublet(at: 20).upDown == .yellow { sum += 20}
        if cube.cublet(at: 24).upDown == .yellow { sum += 24}
        if cube.cublet(at: 26).upDown == .yellow { sum += 26}
        return sum
    }
    
    func processDot(sum:Int, emphasis:Bool) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if sum == 0 {
            // All cubes are down, must be a dot
            if cube.cublet(at: 22).upDown != .white && cube.cublet(at: 20).upDown != .white && cube.cublet(at: 24).upDown != .white && cube.cublet(at: 26).upDown != .white {
                
                if emphasis { actions.append(cube.empasize(poses: [23], asGroup: true)) }
                actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
                turns.append(contentsOf: crossTurns)
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
                turns.append(.Y2)
            }
        }
        return (actions, turns)
    }
    
    func processL(sum:Int, emphasis:Bool) -> ([SCNAction], [Turn]) {
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
            
            if emphasis { actions.append(cube.empasize(poses: [23, 24, 26], asGroup: true)) }
            actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
            turns.append(contentsOf: crossTurns)
        }
        
        return (actions, turns)
    }
    
    func processLine(sum:Int, emphasis:Bool) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if sum == 46 {
            if cube.cublet(at: 22).upDown == .yellow {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
                turns.append(.Y)
            }
            if emphasis { actions.append(cube.empasize(poses: [20, 23, 26], asGroup: true)) }
            actions.append(contentsOf: cube.getTurnActions(turns: crossTurns))
            turns.append(contentsOf: crossTurns)
        }
        
        return (actions, turns)
    }
}
