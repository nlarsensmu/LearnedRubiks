//
//  PopUpViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 12/10/21.
//

import UIKit

class PopUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        if let readVC = subsequentVC as? ReadCubeViewController {
            DispatchQueue.main.async {
                readVC.disableEnableButtons(true)
            }
        }
    }
}
