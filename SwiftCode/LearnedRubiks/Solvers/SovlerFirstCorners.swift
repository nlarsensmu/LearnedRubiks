//
//  SovlerFirstCorners.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/18/21.
//

import Foundation
import SceneKit

class SolverFirstCorners: SolverBase {
    var cube: RubiksCube
    
    lazy var hashColorDict: Dictionary<CubletColor, Int> = {
        return getHashColor()
    }()
    
    let cornerAlg = [Turn.RN, Turn.DN, Turn.R, Turn.D]
    
    init(cube:RubiksCube) {
        self.cube = cube
    }
    
    func solve() -> [SCNAction]{
        var actions:[SCNAction] = []
        
        actions.append(contentsOf: getCornerDown(c1: CubletColor.red, c2: CubletColor.green, c3: CubletColor.white))
        actions.append(contentsOf: positionConerOnBottom(c1: .red, c2: .green))
        actions.append(contentsOf: reapeatCornerAlg())

        actions.append(contentsOf: getCornerDown(c1: CubletColor.red, c2: CubletColor.blue, c3: CubletColor.white))
        actions.append(contentsOf: positionConerOnBottom(c1: .red, c2: .blue))
        actions.append(contentsOf: reapeatCornerAlg())

        actions.append(contentsOf: getCornerDown(c1: CubletColor.orange, c2: CubletColor.green, c3: CubletColor.white))
        actions.append(contentsOf: positionConerOnBottom(c1: .orange, c2: .green))
        actions.append(contentsOf: reapeatCornerAlg())

        actions.append(contentsOf: getCornerDown(c1: CubletColor.orange, c2: CubletColor.blue, c3: CubletColor.white))
        actions.append(contentsOf: positionConerOnBottom(c1: .orange, c2: .blue))
        actions.append(contentsOf: reapeatCornerAlg())
        
        
//        cube.scene.rootNode.runAction(SCNAction.sequence(actions))
        return actions
    }
    
    func getCornerDown(c1:CubletColor, c2:CubletColor, c3:CubletColor) -> [SCNAction] {
        var actions:[SCNAction] = []
        
        let pos = getCubletPosition(c1: c1, c2: c2, c3: c3)
        
        if pos == 21 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
        } else if pos == 27 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
        } else if pos == 25 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
        } else if pos == 19 {
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
        } else if pos == 3 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y]))
        } else if pos == 9 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.Y2]))
        } else if pos == 7 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.YN]))
        }
        
        
        return actions
    }
    
    // Assume the corner we are positioning is in location 1
    func positionConerOnBottom(c1:CubletColor, c2:CubletColor) -> [SCNAction] {
        var actions:[SCNAction]  = []
        
        let toPos = getCornerBottomLocation(c1: c1, c2: c2)
        
        if toPos == 3 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.D, .Y]))
        } else if toPos == 9 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.D2, .Y2]))
        } else if toPos == 7 {
            actions.append(contentsOf: cube.getTurnActions(turns: [.DN, .YN]))
        }
        
        return actions
    }
    
    // Get the bottom layer corner position a corner with c1 and c2 should be in.
    func getCornerBottomLocation(c1:CubletColor, c2:CubletColor) -> Int {
        let pos1 = getCubletPosition(c1: c1, c2: .noColor, c3: .noColor)
        let pos2 = getCubletPosition(c1: c2, c2: .noColor, c3: .noColor)
        
        // pos1 is 13.
        if pos1 == 13 && pos2 == 11 {
            return 1
        } else if pos1 == 13 && pos2 == 17 {
            return 7
        }
        // pos1 == 11
        else if pos1 == 11 && pos2 == 13 {
            return 1
        } else if pos1 == 11 && pos2 == 15 {
            return 3
        }
        // pos1 15
        else if pos1 == 15 && pos2 == 11 {
            return 3
        } else if pos1 == 15 && pos2 == 17 {
            return 9
        }
        // pos1 == 17
        else if pos1 == 17 && pos2 == 13 {
            return 7
        } else if pos1 == 17 && pos2 == 15 {
            return 9
        }
        
        return 0
    }
    
    // we assume that the cube is turned such that the corner is below
    // where it is supposed to go and is on the right face.
    func reapeatCornerAlg() -> [SCNAction] {
        var actions:[SCNAction]  = []
        
        // check that the cublet at pos 1 is in below where it belongs
        
        // current color
        let currentColor = hashColorDict[cube.cublet(at: 13).frontBack]! | hashColorDict[cube.cublet(at: 23).upDown]! | hashColorDict[cube.cublet(at: 11).leftRight]!
        if !(hashColor(cublet: cube.cublet(at: 1)) == currentColor) {
            print("incorrect pos")
            cube.printCube()
            return actions
        }
        
        while cube.cublet(at: 19).upDown != cube.cublet(at: 23).upDown ||
            cube.cublet(at: 19).leftRight != cube.cublet(at: 20).leftRight ||
            cube.cublet(at: 19).frontBack != cube.cublet(at: 22).frontBack {
            
            actions.append(contentsOf: cube.getTurnActions(turns: cornerAlg))
        }
        
        return actions
    }
}
