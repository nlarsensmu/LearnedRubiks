//
//  SolverBase.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/17/21.
//

import Foundation

protocol SolverBase {
    var cube:RubiksCube { get }
    var hashColorDict:Dictionary<CubletColor, Int> { get }
    func solve()
}

extension SolverBase {
    
    func getHashColor() -> Dictionary<CubletColor, Int> {
        let dict:Dictionary<CubletColor, Int> = [
            CubletColor.green:  0b0000001,
            CubletColor.blue:   0b0000010,
            CubletColor.white:  0b0000100,
            CubletColor.yellow: 0b0001000,
            CubletColor.red:    0b0100000,
            CubletColor.orange: 0b1000000,
            CubletColor.noColor:0b0000000
        ]
        return dict
    }
    
    // Find the pos of a certian colored piece
    func getCubletPosition(c1:CubletColor, c2:CubletColor, c3:CubletColor) -> Int {
        let target = hashColorDict[c1]! | hashColorDict[c2]! | hashColorDict[c3]!
        for cublet in cube.cubelets {
            if hashColor(cublet: cublet) == target {
                return cublet.pos
            }
        }
        return 0
    }
    
    func hashColor(cublet:Cublet) -> Int {
        return hashColorDict[cublet.upDown]! | hashColorDict[cublet.leftRight]! | hashColorDict[cublet.frontBack]!
    }
    
    
}
