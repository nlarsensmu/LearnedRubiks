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
    
    var cases:Dictionary<String, RubiksCube> = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.frame = self.view.frame
        allAlgs["First Layer"] = fistLayerAlgs
        allAlgs["Second Layer"] = secondLayerAlgs
        allAlgs["Last Layer"] = lastLayerAlgs
        
        // Set up segemet Contorller
        self.secondLevelSegmentOutlet.selectedSegmentIndex  = UISegmentedControl.noSegment
        var layer = ""
        if let l = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex) {
            layer = l
        }
        
        if let currentAlgs = allAlgs[layer] {
            self.secondLevelSegmentOutlet.removeAllSegments()
            for k in currentAlgs.keys {
                self.secondLevelSegmentOutlet.insertSegment(withTitle: k,
                                                            at: self.secondLevelSegmentOutlet.numberOfSegments,
                                                            animated: true)
            }
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
        
        // Do any additional setup after loading the view.
        
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
    
    @IBAction func topLevelSegment(_ sender: Any) {
        
        var layer = ""
        if let l = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex) {
            layer = l
        }
        
        if let currentAlgs = allAlgs[layer] {
            self.secondLevelSegmentOutlet.removeAllSegments()
            for k in currentAlgs.keys {
                self.secondLevelSegmentOutlet.insertSegment(withTitle: k,
                                                            at: self.secondLevelSegmentOutlet.numberOfSegments,
                                                            animated: true)
            }
            setSecnario("Solved")
        }
        DispatchQueue.main.async {
            self.runAlgorithmButton.isEnabled = false
            self.turnsLabel.text = ""
        }
    }
    @IBAction func secondLevelSegemt(_ sender: Any) {
        if let c = secondLevelSegmentOutlet.titleForSegment(at: secondLevelSegmentOutlet.selectedSegmentIndex) {
            setSecnario(c)
            
            if let layer = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex),
               let alg = secondLevelSegmentOutlet.titleForSegment(at: secondLevelSegmentOutlet.selectedSegmentIndex),
               let d = allAlgs[layer], let turns = d[alg] {
                DispatchQueue.main.async {
                    self.runAlgorithmButton.isEnabled = true
                    if turns.1 == 1 {
                        self.turnsLabel.text = self.stepsToString(steps: turns.0)
                    } else {
                        self.turnsLabel.text = "(\(self.stepsToString(steps: turns.0))) x\(turns.1)"
                    }
                }
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
           let d = allAlgs[layer], let turnsCount = d[alg] {
            Cube?.duration = 1.0
            var actions:[SCNAction] = []
            for _ in 0..<turnsCount.1 {
                actions.append(contentsOf: Cube!.getTurnActions(turns: turnsCount.0))
            }
            animationRunning = true
            scene.rootNode.runAction(SCNAction.sequence(actions)) {
                DispatchQueue.main.async {
                    self.undoAlgorithm(turns: turnsCount)
                }
            }
        }
    }
    
    func undoAlgorithm(turns:([Turn], Int)) {
        
        self.Cube?.duration = 0.1
        var actions:[SCNAction] = []
        for _ in 0..<turns.1 {
            actions.append(contentsOf: self.Cube!.getTurnActions(turns: negateTurns(turns.0.reversed())))
        }
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
    
    // MARK: Algoritms used
    let fistLayerAlgs:Dictionary<String, ([Turn], Int)> = [
        "Flip Wedge"            : ([.F, .UN, .R, .U], 1),
        "Corner Placement"      : ([.RN, .DN, .R, .D], 5)
    ]
    let secondLayerAlgs:Dictionary<String, ([Turn], Int)> = [
        "Right Wedge Place": ([.U, .R, .UN, .RN, .UN, .FN, .U, .F], 1),
        "Left Wedge Place": ([.UN, .LN, .U, .L, .U, .F, .UN, .FN, .YN], 1)
    ]
    let lastLayerAlgs:Dictionary<String, ([Turn], Int)> = [
        "Solving Cross": ([.F, .R, .U, .RN, .UN, .FN], 2),
        "Place Wedges": ([.YN, .R, .U, .RN, .U, .R, .U2, .RN], 1),
        "Place Corners": ([.U, .R, .UN, .LN, .U, .RN, .UN, .L], 1)
    ]
    var  allAlgs:Dictionary<String, Dictionary<String, ([Turn], Int)>> = [:]
    
    
    
    func stepsToString(steps:[Turn]) -> String {
        var stepsString = ""
        for i in 0..<steps.count {
            let step = steps[i]
            switch step {
            case .U:
                stepsString += "U"
                break;
            case .UN:
                stepsString += "UN"
                break;
            case .D:
                stepsString += "D"
                break;
            case .DN:
                stepsString += "DN"
                break;
            case .R:
                stepsString += "R"
                break;
            case .RN:
                stepsString += "RN"
                break;
            case .L:
                stepsString += "L"
                break;
            case .LN:
                stepsString += "LN"
                break;
            case .F:
                stepsString += "F"
                break;
            case .FN:
                stepsString += "FN"
                break;
            case .B:
                stepsString += "B"
                break;
            case .BN:
                stepsString += "BN"
                break;
            case .M:
                stepsString += "M"
                break;
            case .MN:
                stepsString += "MN"
                break;
            case .S:
                stepsString += "S"
                break;
            case .SN:
                stepsString += "SN"
                break;
            case .E:
                stepsString += "E"
                break;
            case .EN:
                stepsString += "EN"
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
                stepsString += "XN"
                break;
            case .X2:
                stepsString += "X2"
                break;
            case .Y:
                stepsString += "Y"
                break;
            case .YN:
                stepsString += "YN"
                break;
            case .Y2:
                stepsString += "Y2"
                break;
            case .Z:
                stepsString += "Z"
                break;
            case .ZN:
                stepsString += "ZN"
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
