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
        self.turnsImage.image = UIImage(named: "turn")
        self.algorithmImage.image = UIImage(named: "algorithms")
        
        self.turnsImage.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(turnsImageTapped))
        self.turnsImage.addGestureRecognizer(tapRecognizer)
        
        self.algorithmImage.isUserInteractionEnabled = true
            let tapRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(algorithmImageTapped))
        self.algorithmImage.addGestureRecognizer(tapRecognizer2)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typeOfTurns = false
    }
    @IBOutlet weak var turnsImage: UIImageView!
    @IBOutlet weak var algorithmImage: UIImageView!
    
    var typeOfTurns = false
    @objc func turnsImageTapped(_ sender: Any) {
        typeOfTurns = true
        self.performSegue(withIdentifier: "teachingCubeSegue", sender: self)
    }
    
    @objc func algorithmImageTapped(_ sender: Any) {
        typeOfTurns = true
        self.performSegue(withIdentifier: "algorithmCubeSegue", sender: self)
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
