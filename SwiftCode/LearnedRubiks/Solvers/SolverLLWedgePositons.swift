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
    
    let turns = [Turn.R, Turn.U, Turn.RN, Turn.U, Turn.R, Turn.U2, Turn.RN]
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func nameOfStep() -> String {
        return "Solve Wedges"
    }
    
    func getNextStep() -> SolvingStep {
        steps += 1
        return SolvingStep(description: nameOfStep(), actions: solve(), steps:[])
    }
    
    func hasNextStep() -> Bool{
        if steps >= 1{
            return false
        }
        return true
    }
    
    func solve() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        var wedgeCase = determineCase()
        
        if (wedgeCase == 3) {
            actions.append(contentsOf: solveCase3())
            wedgeCase = 2
        }
        
        if wedgeCase == 2 {
            actions.append(contentsOf: solveCase2())
        }
        
        // Turn U or UN or U2 to make finsih out
        let frontUp = cube.cublet(at: 22)
        let rightCenter = cube.cublet(at: 11)
        let backCetner = cube.cublet(at: 15)
        let leftCenter = cube.cublet(at: 17)
        
        if frontUp.frontBack == leftCenter.leftRight {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
        } else if frontUp.frontBack == backCetner.frontBack {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U2]))
        } else if frontUp.frontBack == rightCenter.leftRight {
            actions.append(contentsOf: cube.getTurnActions(turns: [.UN]))
        }
        
//        cube.scene.rootNode.runAction(SCNAction.sequence(actions))
        return actions
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
                for _ in 0..<count {
                    let _ = cube.upTurn(direction: -1)
                }
                return 3
            } else if sum == 92 {
                for _ in 0..<count {
                    let _ = cube.upTurn(direction: -1)
                }
                return 1
            } else { // 42, 44, 48, 50 // case 2
                for _ in 0..<count {
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
    func solveCase3() -> [SCNAction]{
        var actions:[SCNAction] = []
        
        // Position the two wedges in the front and back
        
        var sum = sumCorrectWedges()
        
        while sum != 46 {
            actions.append(cube.upTurn(direction: 1))
            sum = sumCorrectWedges()
        }
        
        // if the right or left wedge is correct we need to rotate the cube
        if cube.cublet(at: 20).leftRight == cube.cublet(at: 11).leftRight {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
        }
        
        actions.append(contentsOf: cube.getTurnActions(turns: turns))
        
        actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
        
        return actions
    }
    
    func solveCase2() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        var sum = sumCorrectWedges()
        
        while ![42, 44, 48, 50].contains(sum) {
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
            sum = sumCorrectWedges()
        }
        
        if sum == 50 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
        } else if sum == 48 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
        } else if sum == 42 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
        }
        
        actions.append(contentsOf: cube.getTurnActions(turns: turns))
        actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
        
        return actions
    }
}
