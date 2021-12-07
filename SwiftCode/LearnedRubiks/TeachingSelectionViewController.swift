//
//  TeachingSelectionViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 12/3/21.
//

import UIKit

class TeachingSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typeOfTurns = false
    }
    
    var typeOfTurns = false
    @IBAction func typeOfTurnsAction(_ sender: Any) {
        typeOfTurns = true
        self.performSegue(withIdentifier: "teachingCubeSegue", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? CubeController {
            vc.hideTurnUI = true
            vc.runningThroughTurns = true
        }
    }
    

}
