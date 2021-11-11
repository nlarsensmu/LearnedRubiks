//
//  LearnedSettingsViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/8/21.
//

import UIKit

class LearnedSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var x90: UISwitch!
    @IBOutlet weak var xNeg90: UISwitch!
    @IBOutlet weak var x180: UISwitch!
    @IBOutlet weak var xNeg180: UISwitch!
    @IBOutlet weak var y90: UISwitch!
    @IBOutlet weak var yNeg90: UISwitch!
    @IBOutlet weak var y180: UISwitch!
    @IBOutlet weak var yNeg180: UISwitch!
    @IBOutlet weak var z90: UISwitch!
    @IBOutlet weak var zNeg90: UISwitch!
    @IBOutlet weak var z180: UISwitch!
    @IBOutlet weak var zNeg180: UISwitch!
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? LearningViewController {
            var list:[LearningViewController.CalibrationStage] = []
            if x90.isOn { list.append(LearningViewController.CalibrationStage.x90) }
            if xNeg90.isOn { list.append(LearningViewController.CalibrationStage.xNeg90) }
            if x180.isOn { list.append(LearningViewController.CalibrationStage.x180) }
            if xNeg180.isOn { list.append(LearningViewController.CalibrationStage.xNeg180) }
            if y90.isOn { list.append(LearningViewController.CalibrationStage.y90) }
            if yNeg90.isOn { list.append(LearningViewController.CalibrationStage.yNeg90) }
            if y180.isOn { list.append(LearningViewController.CalibrationStage.y180) }
            if yNeg180.isOn { list.append(LearningViewController.CalibrationStage.yNeg180) }
            if z90.isOn { list.append(LearningViewController.CalibrationStage.z90) }
            if zNeg90.isOn { list.append(LearningViewController.CalibrationStage.zNeg90) }
            if z180.isOn { list.append(LearningViewController.CalibrationStage.z180) }
            if zNeg180.isOn { list.append(LearningViewController.CalibrationStage.zNeg180) }
        }
    }
    

}
