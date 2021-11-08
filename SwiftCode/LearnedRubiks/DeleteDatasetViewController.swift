//
//  DeleteDatasetViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.
//

import UIKit

class DeleteDatasetViewController: UIViewController {

    var dsid = 0
    
    weak private var serverModel:ServerModel? = ServerModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.dsidLabel.text = "\(self.dsid)"
        }
        
        serverModel?.getDsIdCount(outController: self)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteAllRecordsPressed(_ sender: Any) {
        serverModel?.deleteDsIdRecords(outController: self)
    }
    @IBOutlet weak var dsidLabel: UILabel!
    @IBOutlet weak var samplesLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("leaving")
    }
    

}
