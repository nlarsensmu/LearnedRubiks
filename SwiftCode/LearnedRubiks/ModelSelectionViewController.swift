//
//  ModelSelectionViewController.swift
//  LearnedRubiks
//
//  Created by Steven Larsen on 11/13/21.
//

import UIKit

class ModelSelectionViewController: UITableViewController {
    //MARK: Properties
    weak private var serverModel:ServerModel? = ServerModel.sharedInstance
    var dsids:[Int] = []
    var models:[Model] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        serverModel?.getAllDsIds(){
        (dsids) in
            for dsid in dsids{
                if let id = dsid as? Int{
                    self.dsids.append(id)
                    self.getModelData(id:id)
                }
            }
            
        }
    }
    func getModelData(id:Int){
        serverModel?.getLearnedModelData(dsid: id){
            (data) in
            if let dsid =  data["dsid"] as! Int?,
               let count = data["count"] as! Int? {
                 if let mlpAcc = data["acc_mlp"] as! Double? {
                     self.models.append(Model(dsid: dsid, modelName: "MLP-Model", accuracy: mlpAcc, count: count, model: "MLP"))
                 }
                 if let turiAcc = data["acc_turi"] as! Double? {
                     self.models.append(Model(dsid: dsid, modelName: "Turi-Model", accuracy: turiAcc, count: count, model: "TURI"))
                 }
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: Table functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "dsidCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = "\(models[indexPath.row].dsid) : \(models[indexPath.row].modelName) : \(models[indexPath.row].count)"
        cell.detailTextLabel?.text = String(format: "%.2lf%%", models[indexPath.row].accuracy*100)
        return cell
    }
     
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         if let vc = segue.destination as? CubeController,
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell)
         {
             vc.model = self.models[indexPath.row]
         }
     }
}

//MARK: Helper class for the UI
class Model{
    var dsid:Int
    var modelName:String
    var accuracy:Double
    var count:Int
    var model:String
    init(dsid:Int, modelName:String, accuracy:Double, count:Int, model:String){
        self.dsid = dsid
        self.modelName = modelName
        self.accuracy = accuracy
        self.count = count
        self.model = model
    }
}
