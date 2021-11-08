//
//  DebugPredViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.

// Only for debuggin purposes, should be removed later
//

import UIKit

class DebugPredViewController: UIViewController {
    
    var dsid = 1 {
        didSet {
            DispatchQueue.main.async {
                self.dsidLabel.text = "DSID:\(self.dsid)"
            }
        }
    }
    
    weak private var serverModel:ServerModel? = ServerModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = 0.5
        // Do any additional setup after loading the view.
    }
    
    let animation = CATransition()
    func setAsCalibrating(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.backgroundColor = UIColor.red
    }
    
    func setAsNormal(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.backgroundColor = UIColor.white
    }

    @IBOutlet weak var dsidLabel: UILabel!
    @IBAction func didStep(_ sender: UIStepper) {
        dsid = Int(sender.value)
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
