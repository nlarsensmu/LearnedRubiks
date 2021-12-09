//
//  SolverLLWedgePositons.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit
import CoreMotion

class SolverLLWedgePossitions: SolverBase {
    var stepString: String = "Solve Last Layer Wedge Postions"
    
    var cube: RubiksCube
    var steps = 0
    /*
     There are three cases.
     1) The edges are correct
     2) Two edges need to be swapped, two next to each other are correct
        Detect by notince R is not opposite O or G is not opposite B
     3) Two edges need to be swapped, two correct are not next to each other
     */
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    let wedgeRotateAlg = [Turn.R, Turn.U, Turn.RN, Turn.U, Turn.R, Turn.U2, Turn.RN]
    
    init(cube:RubiksCube) {
        self.cube = cube
        cube.printCube()
        steps = determineCase()
        cube.printCube()
    }
    
    func nameOfStep() -> String {
        if steps == 3 {
            return "Two correct Wedges opposite each other"
        } else if steps == 2 {
            return "Two correct Wedges next to each other"
        } else {
            return "Completed Cross"
        }
    }
    
    func getNextStep(emphasis:Bool) -> SolvingStep {
        
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        if (steps == 3) {
            let case3 = solveCase3(emphasis: emphasis)
            actions.append(contentsOf: case3.0)
            turns.append(contentsOf: case3.1)
        } else if (steps == 2) {
            let case2 = solveCase2(emphasis: emphasis)
            actions.append(contentsOf: case2.0)
            turns.append(contentsOf: case2.1)
        } else if (steps == 1) { // They are solved in some way
            let case1 = solveCase1()
            actions.append(contentsOf: case1.0)
            turns.append(contentsOf: case1.1)
        }
        
        
        return SolvingStep(description: nameOfStep(), actions: actions, steps:turns)
    }
    
    func hasNextStep() -> Bool{
        if steps == 1{
            return false
        }
        return true
    }
    
    func solveCase1() -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        var sum = sumCorrectWedges()
        
        if sum == 92 {
            // solved
            return (actions, turns)
        }
        
        // Try one up turn.
        let _ = cube.getTurnActions(turns: [.U])
        sum = sumCorrectWedges()
        if sum == 92 {
            let _ = cube.getTurnActions(turns: [.UN])
            turns.append(.U)
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
            return (actions, turns)
        }
        
        // Try another up turn.
        let _ = cube.getTurnActions(turns: [.U])
        if sum == 92 {
            let _ = cube.getTurnActions(turns: [.U2])
            turns.append(.U2)
            actions.append(contentsOf: cube.getTurnActions(turns: [.U2]))
            return (actions, turns)
        }
        
        // Try another up turn.
        let _ = cube.getTurnActions(turns: [.U])
        if sum == 92 {
            let _ = cube.getTurnActions(turns: [.U])
            turns.append(.U)
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
            return (actions, turns)
        }
        
        return (actions, turns)
    }
    
    // This function will perform turns, but undo them. The actions will not be run
    func determineCase() -> Int {
        
        var sum = sumCorrectWedges()
        var count = 0
        while true {
            sum = sumCorrectWedges()
            if sum < 42 { // One or less is correct
                let _ = cube.upTurn(direction: 1)
                count += 1
            } else if sum == 46 { // case 3
                for _ in 0..<count { // 2 opposite each other
                    let _ = cube.upTurn(direction: -1)
                }
                return 3
            } else if sum == 92 { // cross
                for _ in 0..<count {
                    let _ = cube.upTurn(direction: -1)
                }
                return 1
            } else { // 42, 44, 48, 50 // case 2
                for _ in 0..<count { // two next to each other
                    let _ = cube.upTurn(direction: -1)
                }
                return 2
            }
        }
    }
    
    // We will sum up all the wedges that are
    func sumCorrectWedges() -> Int {
        var sum = 0
        if cube.cublet(at: 20).leftRight == cube.cublet(at: 11).leftRight {
            sum += 20
        }
        if cube.cublet(at: 22).frontBack == cube.cublet(at: 13).frontBack {
            sum += 22
        }
        if cube.cublet(at: 24).frontBack == cube.cublet(at: 15).frontBack {
            sum += 24
        }
        if cube.cublet(at: 26).leftRight == cube.cublet(at: 17).leftRight {
            sum += 26
        }
        
        return sum
    }
    
    // To solve this we will perform the alg at any position and it will get us to case 2
    func solveCase3(emphasis:Bool) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        // Position the two wedges in the front and back
        
        var sum = sumCorrectWedges()
        
        while sum != 46 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
            turns.append(.U)
            sum = sumCorrectWedges()
        }
        
        // if the right or left wedge is correct we need to rotate the cube
        if cube.cublet(at: 20).leftRight == cube.cublet(at: 11).leftRight {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            turns.append(.Y)
        }
        
        if emphasis { actions.append(cube.empasize(poses: [22,24], asGroup: true)) }
        actions.append(contentsOf: cube.getTurnActions(turns: wedgeRotateAlg))
        turns.append(contentsOf: wedgeRotateAlg)
        
        actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
        turns.append(.YN)
        
        steps = 2
        return (actions, turns)
    }
    
    func solveCase2(emphasis:Bool) -> ([SCNAction], [Turn]) {
        var actions:[SCNAction] = []
        var turns:[Turn] = []
        
        var sum = sumCorrectWedges()
        
        while ![42, 44, 48, 50].contains(sum) {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
            turns.append(.U)
            sum = sumCorrectWedges()
        }
        
        if sum == 50 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            turns.append(.Y)
        } else if sum == 48 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            turns.append(.Y2)
        } else if sum == 42 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            turns.append(.YN)
        }
        
        if emphasis { actions.append(cube.empasize(poses: [24,20], asGroup: true)) }
        actions.append(contentsOf: cube.getTurnActions(turns: wedgeRotateAlg))
        turns.append(contentsOf: wedgeRotateAlg)
        actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
        turns.append(.U)
        
        steps = 1
        return (actions, turns)
    }
}
