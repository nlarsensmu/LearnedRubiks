//
//  ManualCubeEntryViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 12/6/21.
//

import UIKit

class ManualCubeEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var colorPicker: UIPickerView!
    
    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    var cube:RubiksCube? = nil
    
    let instructions = ["Top: White Front: Blue",
                        "Top: Orange Front: Blue",
                        "Top: Yellow Front: Blue",
                        "Top: Red Front: Blue",
                        "Top: Blue Front: Orange",
                        "Top: Green Front: Red",
                        "Done Loading"]
    var faces:[[CubletColor]] = Array.init(repeating: [], count: 6)
    var instruction:Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.instructionLabel.text = self.instructions[self.instruction]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.delegate = self
        colorPicker.dataSource = self
        instruction = 0
        self.nextStepButton.isEnabled = false
        
    }
    var titles = ["red", "orange", "green", "blue", "white", "yellow"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titles[row]
    }
    @IBOutlet var cubeltButtons: [UIButton]!
    @IBAction func cubletPressed(_ sender: UIButton) {
        let imageName = "\(titles[self.colorPicker.selectedRow(inComponent: 0)]).png"
        if let image = UIImage(named: imageName) {
            sender.setImage(image, for: .normal)
        }
        
        var allColors = true
        for button in cubeltButtons {
            if button.currentImage == UIImage(named: "noColor.png") {
                allColors = false
                return
            }
        }
        if allColors { self.nextStepButton.isEnabled = true }
    }
    @IBAction func nextStep(_ sender: Any) {
        
        var colors:[CubletColor] = []
        
        for cubletButton in cubeltButtons {
            if cubletButton.currentImage == UIImage(named: "red.png") {
                colors.append(.red)
            }
            if cubletButton.currentImage == UIImage(named: "orange.png") {
                colors.append(.orange)
            }
            if cubletButton.currentImage == UIImage(named: "blue.png") {
                colors.append(.blue)
            }
            if cubletButton.currentImage == UIImage(named: "green.png") {
                colors.append(.green)
            }
            if cubletButton.currentImage == UIImage(named: "white.png") {
                colors.append(.white)
            }
            if cubletButton.currentImage == UIImage(named: "yellow.png") {
                colors.append(.yellow)
            }
            if let image = UIImage(named: "noColor.png") {
                cubletButton.setImage(image, for: .normal)
            }
        }
        
        if colors.count == 9 {
            print(colors)
            faces[instruction] = getFaceOrientation(colors: colors)
            instruction += 1
        }
        
        if instruction == 6 {
            self.cube =  RubiksCube(front: faces[2], left: faces[1], right: faces[3], up: faces[5], down: faces[4], back: faces[0])
            self.performSegue(withIdentifier: "toCubeControllerFromManual", sender: self)
        }
        
        print(colors)
        self.nextStepButton.isEnabled = false
    }
    
    func getFaceOrientation(colors:[CubletColor]) -> [CubletColor] {
        
        if colors[4] == .blue {
            return colors
        } else if colors[4] == .green {
            return [colors[6], colors[7], colors[8],
                    colors[3], colors[4], colors[5],
                    colors[0], colors[1], colors[2]]
        } else if colors[4] == .red {
            return [colors[6], colors[7], colors[8],
                    colors[3], colors[4], colors[5],
                    colors[0], colors[1], colors[2]]
        } else if colors[4] == .orange {
            return colors.reversed()
        } else if colors[4] == .white {
            return [colors[6], colors[7], colors[8],
                    colors[3], colors[4], colors[5],
                    colors[0], colors[1], colors[2]]
        } else if colors[4] == .yellow {
            return colors.reversed()
        }
        return []
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "toCubeControllerFromManual"){
                let displayVC = segue.destination as! CubeController
            displayVC.Cube = self.cube
            displayVC.solver = SolverCross(c: displayVC.Cube!)
            displayVC.nextStep = displayVC.solver!.getNextStep()
            displayVC.displayStep = stepsToString(steps: displayVC.nextStep.steps)
            displayVC.solveOnly = true
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let c = cube else {
            return false
        }
        if c.isValid() && c.isParady() {
            return true
        }
        return false
    }
    

}
