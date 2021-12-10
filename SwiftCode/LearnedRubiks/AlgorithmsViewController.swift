//
//  AlgorithmsViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 12/3/21.
//

import UIKit
import SceneKit

class AlgorithmsViewController: UIViewController {
    
    // MARK: Properties
    var Cube:RubiksCube? = nil
    var scene : SCNScene!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var algorithmDescription: UILabel!
    
    var cases:Dictionary<String, RubiksCube> = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.frame = self.view.frame
        // Set up segemet Contorller
        self.secondLevelSegmentOutlet.selectedSegmentIndex  = UISegmentedControl.noSegment
        var layer = ""
        if let l = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex) {
            layer = l
        }

        
        // Create a dictionary of cubes to load and unload.
        cases["Solved"] = RubiksCube()
        cases["Flip Wedge"] = RubiksCube(front: [.yellow, .green, .white, .blue, .blue, .red, .white, .white, .yellow],
                                          left: [.blue, .red, .white, .blue, .red, .blue, .red, .red, .yellow],
                                          right: [.blue, .green, .yellow, .yellow, .orange, .red, .orange, .orange, .white],
                                          up: [.green, .white, .red, .blue, .white, .white, .blue, .white, .green],
                                          down:  [.orange, .orange, .red, .yellow, .yellow, .orange, .orange, .green, .blue],
                                          back: [.green, .yellow, .red, .yellow, .green, .orange, .green, .green, .orange])
        
        cases["Corner Placement"] = RubiksCube(front: [.white, .red, .white, .red, .orange, .green, .white, .orange, .blue],
                                               left: [.red, .yellow, .yellow, .orange, .blue, .red, .white, .blue, .blue],
                                               right: [.green, .green, .blue, .blue, .green, .orange, .green, .green, .orange],
                                               up: [.red, .white, .green, .white, .white, .white, .orange, .white, .yellow],
                                               down: [.orange, .yellow, .red, .green, .yellow, .yellow, .blue, .orange, .green],
                                               back: [.yellow, .blue, .red, .blue, .red, .yellow, .yellow, .red, .orange])
        cases["Right Wedge Place"] = RubiksCube(front: [.green, .green, .green, .blue, .green, .green, .orange, .green, .red],
                                               left: [.red, .red, .red, .red, .red, .red, .blue, .red, .orange],
                                               right: [.orange, .orange, .orange, .orange, .orange, .green, .blue, .blue, .red],
                                               up: [.yellow, .yellow, .yellow, .orange, .yellow, .orange, .yellow, .yellow, .yellow],
                                               down: [.white, .white, .white, .white, .white, .white, .white, .white, .white],
                                               back: [.blue, .blue, .blue, .yellow, .blue, .blue, .green, .yellow, .green])
        cases["Left Wedge Place"] = RubiksCube(front: [.orange, .orange, .orange, .green, .orange, .orange, .yellow, .orange, .yellow],
                                               left: [.green, .green, .green, .yellow, .green, .green, .green, .yellow, .orange],
                                               right: [.blue, .blue, .blue, .yellow, .blue, .blue, .orange, .blue, .blue],
                                               up: [.blue, .orange, .yellow, .green, .yellow, .yellow, .red , .blue, .yellow],
                                               down: [.white, .white, .white, .white, .white, .white, .white, .white, .white],
                                               back: [.red, .red, .red, .red, .red, .red, .red, .red, .green])
        cases["Solving Cross"] = RubiksCube(front: [.red, .red, .red, .red, .red, .red, .yellow, .yellow, .green],
                                           left: [.blue, .blue, .blue, .blue, .blue, .blue, .red, .green, .orange],
                                           right: [.green, .green, .green, .green, .green, .green, .blue, .yellow, .yellow],
                                           up: [.red, .blue, .orange, .red, .yellow, .yellow, .yellow, .yellow, .blue],
                                           down: [.white, .white, .white, .white, .white, .white, .white, .white, .white, ],
                                           back: [.orange, .orange, .orange, .orange, .orange, .orange, .green, .orange, .yellow])
        
        cases["Place Wedges"] = RubiksCube(front: [.red, .red, .red, .red, .red, .red, .blue, .red, .yellow],
                                           left: [.blue, .blue, .blue, .blue, .blue, .blue, .orange, .orange, .red],
                                           right: [.green, .green, .green, .green, .green, .green, .green, .green, .yellow],
                                           up: [.orange, .yellow, .red, .yellow, .yellow, .yellow, .green, .yellow, .yellow],
                                           down: [.white, .white, .white, .white, .white, .white, .white, .white, .white],
                                           back: [.orange, .orange, .orange, .orange, .orange, .orange, .yellow, .blue, .blue])
        // TODO: Change to a real case
        cases["Place Corners"] = RubiksCube(front: [.red, .red, .red, .red, .red, .red, .yellow, .red, .orange],
                                            left: [.blue, .blue, .blue, .blue, .blue, .blue, .green, .blue, .yellow],
                                            right: [.green, .green, .green, .green, .green, .green, .red, .green, .orange],
                                            up: [.green, .yellow, .yellow, .yellow, .yellow, .yellow, .yellow, .yellow, .blue],
                                            down: [.white, .white, .white, .white, .white, .white, .white, .white, .white],
                                            back: [.orange, .orange, .orange, .orange, .orange, .orange, .blue, .orange, .red])
        cases["Orientate Corners"] = RubiksCube(front: [.red, .red, .red, .red, .red, .red, .yellow, .red, .blue],
                                                left: [.blue, .blue, .blue, .blue, .blue, .blue, .yellow, .blue, .yellow],
                                                right: [.green, .green, .green, .green, .green, .green, .red, .green, .orange],
                                                up: [.green, .yellow, .green, .yellow, .yellow, .yellow, .red, .yellow, .orange],
                                                down: [.white, .white, .white, .white, .white, .white, .white, .white, .white],
                                                back: [.orange, .orange, .orange, .orange, .orange, .orange, .yellow, .orange, .blue])
        
        let fistLayerAlgs:Dictionary<String, Algorithm> = [
            "1 Flip Wedge"        :   Algorithm(flipWedge, [.F, .UN, .R, .U], [.F, .UN, .R, .U], cases["Flip Wedge"]!),
            "2 Corner Placement"  :   Algorithm(cornerPlacement, [.RN, .DN, .R, .D],
                                              [.RN, .DN, .R, .D, .RN, .DN, .R, .D, .RN, .DN, .R, .D, .RN, .DN, .R, .D, .RN, .DN, .R, .D, ], cases["Corner Placement"]!)
        ]
        let secondLayerAlgs:Dictionary<String, Algorithm> = [
            "1 Right Wedge Place":    Algorithm(rightWedgePlace, [.U, .R, .UN, .RN, .UN, .FN, .U, .F], [.U, .R, .UN, .RN, .UN, .FN, .U, .F], cases["Right Wedge Place"]!),
            "2 Left Wedge Place":     Algorithm(leftWedgePlace, [.UN, .LN, .U, .L, .U, .F, .UN, .FN], [.UN, .LN, .U, .L, .U, .F, .UN, .FN, .YN], cases["Left Wedge Place"]!)
        ]
        let lastLayerAlgs:Dictionary<String, Algorithm> = [
            "1 Solving Cross":        Algorithm(solvingCross, [.F, .R, .U, .RN, .UN, .FN], [.F, .R, .U, .RN, .UN, .FN, .F, .R, .U, .RN, .UN, .FN], cases["Solving Cross"]!),
            "2 Place Wedges":         Algorithm(placeWedges, [.YN, .R, .U, .RN, .U, .R, .U2, .RN], [.YN, .R, .U, .RN, .U, .R, .U2, .RN, .U], cases["Place Wedges"]!),
            "3 Place Corners":        Algorithm(placeCorners, [.U, .R, .UN, .LN, .U, .RN, .UN, .L], [.U, .R, .UN, .LN, .U, .RN, .UN, .L, .Y2, .Y2], cases["Place Corners"]!),
            "4 Orientate Corners":    Algorithm(orientateCorners, [.RN, .DN, .R, .D],
                                              [.RN,.DN,.R,.D,.RN,.DN,.R,.D,.RN,.DN,.R,.D,.RN,.DN,.R,.D,.U,
                                               .RN,.DN,.R,.D,.RN,.DN,.R,.D,.U,
                                               .RN,.DN,.R,.D,.RN,.DN,.R,.D,.U,
                                               .RN,.DN,.R,.D,.RN,.DN,.R,.D,.RN,.DN,.R,.D,.RN,.DN,.R,.D,.U,
                                              ],
                                              cases["Orientate Corners"]!)
        ]
        allAlgs["First Layer"] = fistLayerAlgs
        allAlgs["Second Layer"] = secondLayerAlgs
        allAlgs["Last Layer"] = lastLayerAlgs
        
        
        if let currentAlgs = allAlgs[layer] {
            self.secondLevelSegmentOutlet.removeAllSegments()
            for k in currentAlgs.keys.sorted() {
                self.secondLevelSegmentOutlet.insertSegment(withTitle: k,
                                                            at: self.secondLevelSegmentOutlet.numberOfSegments,
                                                            animated: true)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.backgroundColor = .black
        addCubes()
        self.Cube?.duration = 1.0
    }
    
    
    // Cube manipulation
    func addCubes(){
        guard let sceneView = sceneView else {
            return
        }
        
        if Cube == nil {
            self.Cube = RubiksCube()
        }
        
        scene = Cube?.getScene()
        sceneView.scene = scene
    }
    
    // MARK: Segment Controls
    @IBOutlet weak var turnsLabel: UILabel!
    @IBOutlet weak var topLevelSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var secondLevelSegmentOutlet: UISegmentedControl!
    
    func setSecnario(_ c:String) {
        if let scenario = cases[c] {
            self.Cube?.removeAllCublets()
            self.Cube?.addScenario(newCube: scenario)
        }
    }
    
    var descriptionsCurrent = ["1 Flip Wedge":flipWedge, "2 Corner Placement":cornerPlacement]
    @IBAction func topLevelSegment(_ sender: Any) {
        
        var layer = ""
        if let l = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex) {
            layer = l
        }
        
        if let currentAlgs = allAlgs[layer] {
            self.secondLevelSegmentOutlet.removeAllSegments()
            for k in currentAlgs.keys.sorted() {
                self.secondLevelSegmentOutlet.insertSegment(withTitle: k,
                                                            at: self.secondLevelSegmentOutlet.numberOfSegments,
                                                            animated: true)
            }
            setSecnario("Solved")
        }
        DispatchQueue.main.async {
            self.algorithmDescription.text = ""
            self.runAlgorithmButton.isEnabled = false
            self.turnsLabel.text = ""
        }
    }
    @IBAction func secondLevelSegemt(_ sender: Any) {
            
        if let layer = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex),
           let alg = secondLevelSegmentOutlet.titleForSegment(at: secondLevelSegmentOutlet.selectedSegmentIndex),
           let d = allAlgs[layer], let algorithm = d[alg] {
            
            self.Cube?.removeAllCublets()
            self.Cube?.addScenario(newCube: algorithm.cube)
            DispatchQueue.main.async
            {
                self.algorithmDescription.text = algorithm.description
                self.runAlgorithmButton.isEnabled = true
                self.turnsLabel.text = self.stepsToString(steps: algorithm.turnsDisplay)
                self.runAlgorithmButton.setTitle(alg, for: .normal)
            }
        }
    
    }
    
    var animationRunning:Bool = false {
        didSet {
            disableEnableUI()
        }
    }
    func disableEnableUI() {
        DispatchQueue.main.async {
            self.topLevelSegmentOutlet.isEnabled = !self.topLevelSegmentOutlet.isEnabled
            self.secondLevelSegmentOutlet.isEnabled = !self.secondLevelSegmentOutlet.isEnabled
            self.runAlgorithmButton.isEnabled = !self.runAlgorithmButton.isEnabled
        }
    }
    
    @IBOutlet weak var runAlgorithmButton: UIButton!
    @IBAction func runAlgorithm(_ sender: Any) {
        
        // unfold segments into the turns
        if let layer = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex),
           let alg = secondLevelSegmentOutlet.titleForSegment(at: secondLevelSegmentOutlet.selectedSegmentIndex),
           let d = allAlgs[layer], let algorithm = d[alg] {
            Cube?.duration = 1.0
            var actions:[SCNAction] = []
            actions.append(contentsOf: Cube!.getTurnActions(turns: algorithm.turnsToRun))
            animationRunning = true
            scene.rootNode.runAction(SCNAction.sequence(actions)) {
                DispatchQueue.main.async {
                    self.undoAlgorithm(turns: algorithm.turnsToRun)
                }
            }
        }
    }
    
    // MARK: Turn LIist helpers
    func undoAlgorithm(turns:([Turn])) {
        
        self.Cube?.duration = 0.1
        var actions:[SCNAction] = []
        actions.append(contentsOf: self.Cube!.getTurnActions(turns: negateTurns(turns.reversed())))
        self.scene.rootNode.runAction(SCNAction.sequence(actions)) {
            self.animationRunning = false
        }
    }
    func negateTurns(_ turns:[Turn]) -> [Turn]{
        var negatedTurns:[Turn] = []
        
        for turn in turns {
            switch turn {
            case .U:
                negatedTurns.append(.UN)
                break
            case .UN:
                negatedTurns.append(.U)
                break
            case .D:
                negatedTurns.append(.DN)
                break
            case .DN:
                negatedTurns.append(.D)
                break
            case .R:
                negatedTurns.append(.RN)
                break
            case .RN:
                negatedTurns.append(.R)
                break
            case .L:
                negatedTurns.append(.LN)
                break
            case .LN:
                negatedTurns.append(.L)
                break
            case .F:
                negatedTurns.append(.FN)
                break
            case .FN:
                negatedTurns.append(.F)
                break
            case .B:
                negatedTurns.append(.BN)
                break
            case .BN:
                negatedTurns.append(.B)
                break
            case .U2:
                negatedTurns.append(.U2)
                break
            case .D2:
                negatedTurns.append(.D2)
                break
            case .F2:
                negatedTurns.append(.F2)
                break
            case .B2:
                negatedTurns.append(.B2)
                break
            case .L2:
                negatedTurns.append(.L2)
                break
            case .R2:
                negatedTurns.append(.R2)
                break
            case .Y:
                negatedTurns.append(.YN)
                break
            case .YN:
                negatedTurns.append(.Y)
            default:
                break
            }
        }
        return negatedTurns
    }
    
    var  allAlgs:Dictionary<String, Dictionary<String, Algorithm>> = [:]
    
    
    
    func stepsToString(steps:[Turn]) -> String {
        var stepsString = ""
        for i in 0..<steps.count {
            let step = steps[i]
            switch step {
            case .U:
                stepsString += "U"
                break;
            case .UN:
                stepsString += "U'"
                break;
            case .D:
                stepsString += "D"
                break;
            case .DN:
                stepsString += "D'"
                break;
            case .R:
                stepsString += "R"
                break;
            case .RN:
                stepsString += "R'"
                break;
            case .L:
                stepsString += "L"
                break;
            case .LN:
                stepsString += "L'"
                break;
            case .F:
                stepsString += "F"
                break;
            case .FN:
                stepsString += "F'"
                break;
            case .B:
                stepsString += "B"
                break;
            case .BN:
                stepsString += "B'"
                break;
            case .M:
                stepsString += "M"
                break;
            case .MN:
                stepsString += "M'"
                break;
            case .S:
                stepsString += "S"
                break;
            case .SN:
                stepsString += "S'"
                break;
            case .E:
                stepsString += "E"
                break;
            case .EN:
                stepsString += "E'"
                break;
            case .U2:
                stepsString += "U2"
                break;
            case .D2:
                stepsString += "D2"
                break;
            case .F2:
                stepsString += "F2"
                break;
            case .B2:
                stepsString += "B2"
                break;
            case .L2:
                stepsString += "L2"
                break;
            case .R2:
                stepsString += "R2"
                break;
            case .M2:
                stepsString += "M2"
                break;
            case .E2:
                stepsString += "E2"
                break;
            case .S2:
                stepsString += "S2"
                break;
            case .X:
                stepsString += "X"
                break;
            case .XN:
                stepsString += "X'"
                break;
            case .X2:
                stepsString += "X2"
                break;
            case .Y:
                stepsString += "Y"
                break;
            case .YN:
                stepsString += "Y'"
                break;
            case .Y2:
                stepsString += "Y2"
                break;
            case .Z:
                stepsString += "Z"
                break;
            case .ZN:
                stepsString += "Z'"
                break;
            case .Z2:
                stepsString += "Z2"
                break;
            }
            if i != steps.count-1 {
                stepsString += ","
            }
        }
        return stepsString
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: Alg Descriptions
var flipWedge = """
The goal of this algorithim is to flip
the orientition of a wedge
on the first layer
that is already in the right poistion
"""
var cornerPlacement = """
The goal of this algorithm is to solve
all the white corners.
Once a corner is in the right place
(wrong orientation) or is in the corner
below it's target, excute R' D' R D until correct
"""

var leftWedgePlace = """
The goal of this algorithm is to position
a wedge into the second layer.
Once a wedge is above the corresponding
center and the target location is on the left
execute the algorithm once.
"""
var rightWedgePlace = """
The goal of this algorithm is to position
a wedge into the second layer.
Once a wedge is above the corresponding
center and the target location is on the right
execute the algorithm once.
"""
var placeCorners = """
The goal of this algorithm is to place all
the corners in the right place.
They won't all have the right orientation though.
Find a correct corner, rotate the cube so that
corner is in the right most spot
and execute the algorithm once or twice .
If no corners are correct, execute the alogrithm
once and start again.
"""
var placeWedges = """
The goal of this alg is to place all the cross
pieces in the right places. You can always make
at least two wedges in the correct place but
performing some up turns. If your two wedges
are next to each other put them in the right
and back face and perform this algorthim.
If they are opposite each other, put them
in the front and back face, perform the
algorithm and then they will the previous case.
"""
var solvingCross = """
The goal of this algorithm is to turn up all the
correct colors of the cross on the last layer.
If there are no correct peices excetue the alg.
If you see an L position both wedges away
from you exectue the algorithm twice
If you see a line positon the line not pointing at
you and execute the alg
"""
var orientateCorners = """
Perform the corner algorithm from the frist layer,
until the front right up corner is in the correct
orientation.
Then do a up turn and repeat the process.
After all corners are orientated,
since you have run the corner algorithm a
muliple of 6 times, the bottom half
of the cube will remain solved.
"""

// MARK: Algotithm Class
class Algorithm {
    var description:String
    var turnsDisplay:[Turn]
    var turnsToRun:[Turn]
    var cube:RubiksCube
    init(_ desctiption:String, _ turnsDisplay:[Turn], _ turnsToRun:[Turn], _ cube:RubiksCube) {
        self.description = desctiption
        self.turnsDisplay = turnsDisplay
        self.turnsToRun = turnsToRun
        self.cube = cube
    }
}
