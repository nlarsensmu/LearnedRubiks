//
//  RootCollectionViewController.swift
//  LearnedRubiks
//
//  Created by Steven Larsen on 12/1/21.
//

import UIKit

class RootViewController: UIViewController {
    //MARK: Outlets
    
    
    
    @IBOutlet weak var cube: UIImageView! {
        didSet  {
            cube.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var learning: UIImageView!{
        didSet  {
            learning.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var camera: UIImageView!{
        didSet  {
            camera.isUserInteractionEnabled = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cube.image = UIImage(named: "cube")
        self.learning.image = UIImage(named: "learning")
        self.camera.image = UIImage(named: "camera")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

