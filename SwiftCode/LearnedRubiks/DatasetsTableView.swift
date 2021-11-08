//
//  DatasetsViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/7/21.
//

import UIKit

class DatasetsTableView: UITableViewController {

    
    weak private var serverModel:ServerModel? = ServerModel.sharedInstance
    
    var dsids:[Any] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table is loaded in View Will Appear, needs to be reloaded when 'back'
        // Do any additional setup after loading the view.
    }
    
    

   // MARK: - Table view data source

   override func numberOfSections(in tableView: UITableView) -> Int {
       // #warning Incomplete implementation, return the number of sections
       return 1
   }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // #warning Incomplete implementation, return the number of rows
       return self.dsids.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
       let cellID = "dsidCell"
       
       let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
       // Configure the cell...
       
       cell.textLabel?.text = "\(dsids[indexPath.row])"

       return cell
   }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? DeleteDatasetViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = self.tableView.indexPath(for: cell),
           let dsid = self.dsids[indexPath.row] as? Int {
            vc.dsid = dsid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // update the Table view
        serverModel?.getAllDsIds(outContoller: self)
    }
    

}
