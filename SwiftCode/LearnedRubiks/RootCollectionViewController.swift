//
//  RootCollectionViewController.swift
//  LearnedRubiks
//
//  Created by Steven Larsen on 12/1/21.
//

import UIKit

private let reuseIdentifier = "CollectCell"

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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    lazy var imageModel = {
        return ImageModel.sharedInstance()
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}

