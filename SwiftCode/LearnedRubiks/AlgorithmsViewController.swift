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
        cases["Flip Wedge"] = RubiksCube(front: [.yellow, .green, .white, .blue, .blue, .red, .white, .white, .yellow],
                                          left: [.blue, .red, .white, .blue, .red, .blue, .red, .red, .yellow],
                                          right: [.blue, .green, .yellow, .yellow, .orange, .red, .orange, .orange, .white],
                                          up: [.green, .white, .red, .blue, .white, .white, .blue, .white, .green],
                                          down:  [.orange, .orange, .red, .yellow, .yellow, .orange, .orange, .green, .blue],
                                          back: [.green, .yellow, .red, .yellow, .green, .orange, .green, .green, .orange])
        

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
        }
    }
    @IBAction func secondLevelSegemt(_ sender: Any) {
        if let c = secondLevelSegmentOutlet.titleForSegment(at: secondLevelSegmentOutlet.selectedSegmentIndex) {
            if let scenario = cases[c] {
                self.Cube?.removeAllCublets()
                self.Cube?.addScenario(newCube: scenario)
            }
            
            if let layer = topLevelSegmentOutlet.titleForSegment(at: topLevelSegmentOutlet.selectedSegmentIndex),
               let alg = secondLevelSegmentOutlet.titleForSegment(at: secondLevelSegmentOutlet.selectedSegmentIndex),
               let d = allAlgs[layer], let turns = d[alg] {
                DispatchQueue.main.async {
                    self.turnsLabel.text = self.stepsToString(steps: turns)
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
           let d = allAlgs[layer], let turns = d[alg] {
            Cube?.duration = 1.0
            var actions:[SCNAction] = []
            actions.append(contentsOf: Cube!.getTurnActions(turns: turns))
            animationRunning = true
            scene.rootNode.runAction(SCNAction.sequence(actions)) {
                DispatchQueue.main.async {
                    self.undoAlgorithm(turns: turns)
                }
            }
        }
    }
    
    func undoAlgorithm(turns:[Turn]) {
        
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
            default:
                break
            }
        }
        return negatedTurns
    }
    
    // MARK: Algoritms used
    let fistLayerAlgs:Dictionary<String, [Turn]> = [
        "Flip Wedge"            : [.F, .UN, .R, .U],
        "Corner Placement"      : [.RN, .DN, .R, .D]
    ]
    let secondLayerAlgs:Dictionary<String, [Turn]> = [
        "Right Wedge Place": [.U, .R, .UN, .RN, .UN, .FN, .UN, .F],
        "Left Wedge Place": [.UN, .LN, .U, .L, .U, .F, .UN, .FN]
    ]
    let lastLayerAlgs:Dictionary<String, [Turn]> = [
        "Solving Cross": [.F, .U, .R, .U, .RN, .UN, .FN],
        "Place Wedges": [.R, .U, .RN, .U, .R, .U2, .RN],
        "Place Corners": [.U, .R, .UN, .LN, .U, .RN, .UN, .L]
    ]
    var  allAlgs:Dictionary<String, Dictionary<String, [Turn]>> = [:]
    
    
    
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