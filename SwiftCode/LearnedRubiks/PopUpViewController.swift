//
//  PopUpViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 12/10/21.
//

import UIKit

class PopUpViewController: UIViewController {

    weak var readVC:ReadCubeViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let vc = readVC {
            vc.disableEnableButtons(true)
            vc.disableEnbableSaveButton(false)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let readVC = segue.destination as? ReadCubeViewController {
            DispatchQueue.main.async {
                readVC.disableEnableButtons(true)
            }
        }
    }*/ 
}
