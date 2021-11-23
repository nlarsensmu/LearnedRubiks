//
//  SolverBeginnerLLCorners.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/19/21.
//

import Foundation
import SceneKit

class SolverBeginnerLLCornersPosition: SolverBase {    
    
    var cube: RubiksCube
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    let rotate3CornersAlg = [Turn.U, Turn.R, Turn.UN, Turn.LN, Turn.U, Turn.RN, Turn.UN, Turn.L]
    let cornerAlg = [Turn.RN, Turn.DN, Turn.R, Turn.D]
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func solve() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        actions.append(contentsOf: positionCorner())
        
//        cube.scene.rootNode.runAction(SCNAction.sequence(actions))
        return actions
    }
    
    // MARK: position the conrners
    func countCorectCorners() -> Int {
        
        var count = 0
        
        let frontRightUp = hashColorDict[cube.cublet(at: 13).frontBack]! | hashColorDict[cube.cublet(at: 11).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 19)) == frontRightUp {
            count += 1
        }
        
        let frontLeftUp = hashColorDict[cube.cublet(at: 13).frontBack]! | hashColorDict[cube.cublet(at: 17).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 25)) == frontLeftUp {
            count += 1
        }
        
        let backRightUp = hashColorDict[cube.cublet(at: 15).frontBack]! | hashColorDict[cube.cublet(at: 11).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 21)) == backRightUp {
            count += 1
        }
        
        let backLeftUp = hashColorDict[cube.cublet(at: 15).frontBack]! | hashColorDict[cube.cublet(at: 17).leftRight]! | hashColorDict[cube.cublet(at: 23).upDown]!
        if hashColor(cublet: cube.cublet(at: 27)) == backLeftUp {
            count += 1
        }
        
        return count
    }
    
    func positionCorner() -> [SCNAction] {
        var actions:[SCNAction] = []
        
        var count = countCorectCorners()
        
        // if count is 0, we need to do rotation once to get one that is right.
        if count == 0 {
            actions.append(contentsOf: cube.getTurnActions(turns: rotate3CornersAlg))
            count = 1
        }
        
        if count == 1 {
            
            // Check if we are already correct
            let frontRightCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 11).leftRight]!
                | hashColorDict[cube.cublet(at: 13).frontBack]!
            
            let frontRightCornerCorrect = frontRightCorner == hashColor(cublet: cube.cublet(at: 19))
            
            // we are done.
            if frontRightCornerCorrect {
            }
            
            // Check the RightBack
            let rightBackCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 11).leftRight]!
                | hashColorDict[cube.cublet(at: 15).frontBack]!
            let backRightCornerCorrect = rightBackCorner == hashColor(cublet: cube.cublet(at: 21))
            
            // Turn it to pos 19
            if backRightCornerCorrect {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            }
            
            // Check the LeftBack
            let leftBackCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 17).leftRight]!
                | hashColorDict[cube.cublet(at: 15).frontBack]!
            let backLeftCornerCorrect = leftBackCorner == hashColor(cublet: cube.cublet(at: 27))
            
            // Turn it to pos 19
            if backLeftCornerCorrect {
                actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            }
            
            // Check the leftFront
            let leftFrontCorner = hashColorDict[cube.cublet(at: 23).upDown]!
                | hashColorDict[cube.cublet(at: 17).leftRight]!
                | hashColorDict[cube.cublet(at: 13).frontBack]!
            let frontLeftCornerCorrect = leftFrontCorner == hashColor(cublet: cube.cublet(at: 25))
            
            // Turn it to pos 19
            if frontLeftCornerCorrect {
                actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            }
            // Perform
            while countCorectCorners() != 4 {
                actions.append(contentsOf: cube.getTurnActions(turns: rotate3CornersAlg))
            }
        }
        
        return actions
    }
    
    // MARK: Oreintate the corners
    
    // This checks if the corner has the right color UP
    func checkFrontRightUpCornerOrientation() -> Bool {
        let frontRightUp = cube.cublet(at: 19)
        
        let upCenter = cube.cublet(at: 23)
        
        let frontRightCornerCorrect = frontRightUp.upDown == upCenter.upDown
        
        return frontRightCornerCorrect
    }
    
    func orientateCorners() -> [SCNAction] {
        var actions:[SCNAction] = []
        for _ in 0..<4 { // For each corner
            
            
            var frontRightCornerCorrect = checkFrontRightUpCornerOrientation()
            
            while !frontRightCornerCorrect {
                actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
                frontRightCornerCorrect = checkFrontRightUpCornerOrientation()
            }
            
            actions.append(contentsOf: cube.getTurnActions(turns: [.U]))
        }
        
        return actions
    }
}
