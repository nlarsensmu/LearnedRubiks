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
        
        serverModel?.getLearnedModelData(from: self.dsid) { dict in
            var count = 0
            var mlp_acc:Double = 0.0
            var turi_acc:Double = 0.0
            
            let countExists = dict["count"] != nil
            if countExists {
                if let c = dict["count"] as? Int { count = c }
            }
            
            let mlpExists = dict["acc_mlp"] != nil
            if mlpExists{
                if let acc = dict["acc_mlp"] as? Double {
                    mlp_acc = acc
                }
            }
            
            let turiExists = dict["acc_turi"] != nil
            if turiExists {
                if let acc = dict["acc_turi"] as? Double {
                    turi_acc = acc
                }
            }
            
            DispatchQueue.main.async {
                self.dsidLabel.text = "\(self.dsid)"
                self.samplesLabel.text = String(format: "%d", count)
                self.mlpAcc.text = String(format: "%.4lf%%", mlp_acc*100)
                self.turiAcc.text = String(format: "%.4lf%%", turi_acc*100)
            }
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteAllRecordsPressed(_ sender: Any) {
        serverModel?.deleteDsIdRecords(outController: self)
    }
    @IBOutlet weak var dsidLabel: UILabel!
    @IBOutlet weak var samplesLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mlpAcc: UILabel!
    @IBOutlet weak var turiAcc: UILabel!
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("leaving")
    }
    

}
