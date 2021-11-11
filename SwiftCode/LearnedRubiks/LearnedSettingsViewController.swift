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
            
        }
    }
    

}
