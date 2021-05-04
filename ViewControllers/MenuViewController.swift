//
//  HomeViewController.swift
//  FireHawk
//
//  Created by Graeme Brennan on 25/1/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import CoreData


class MenuViewController: UIViewController {

    var i = 0
    
    // Reference to managed core data object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    var items:[DeviceReportCD]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        // register custom cell .xib in table view
        tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "DeviceCellIdentifier")
        
        // Get items from core data
        fetchReports()
    }
    
    func fetchReports() {
        
        print("fetching reports from core data")
        
        // fetch the data from core data to display in the tableView
        do {
            
            let request = DeviceReportCD.fetchRequest() as NSFetchRequest<DeviceReportCD>
            
            // set the filtering and sorting on the request
            //let pred = NSPredicate(format: <#T##String#>)
            //request.predicate = pred
            
            // sort
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                print("reloadData")
            }
        } catch {
            print("error retrieving reports from core data")
        }
    }
 
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
    
            print ("signOutTapped")

                let firebaseAuth = Auth.auth()

            do {
                try firebaseAuth.signOut()

                print ("signOut")
                navigationController?.popToRootViewController(animated: true)

            } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
            }
    }

    
    @IBAction func newServicePressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "menuToServiceLocation", sender: self)
        
    }
    
    

}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("items to be reloaded = \(self.items?.count)")
        return self.items?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCellIdentifier", for: indexPath) as! DeviceCell
        
        let deviceReport = self.items![indexPath.row]
        
        // fill cell details
        cell.lblTitle.text = deviceReport.note
        
        print("deviceReport.deviceType = \(deviceReport.deviceType)")
        if deviceReport.deviceType == "CO" {
            
            cell.imgView.image = UIImage(named: "Firehawk_CO7B10Y.png")
            
        } else if deviceReport.deviceType == "X10"{
            
            cell.imgView.image = UIImage(named: "Firehawk_FHB10_smoke_alarm")
            
        } else if deviceReport.deviceType == "H10"{
            
            cell.imgView.image = UIImage(named: "Firehawk_FHH10_heat_alarm")
            
        } else {
            cell.imgView.image = nil
        }
        
        
        
        
        

        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //Which report to remove
            let reportToRemove = self.items![indexPath.row]
            
            // Remove the report
            self.context.delete(reportToRemove)
            
            // save the data
            do {
                try self.context.save()
            } catch {
                print("error saving data to core data db")
            }
            
            // re-fetch the data
            self.fetchReports()
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.i = indexPath.row
        performSegue(withIdentifier: "menuVCToReport", sender: self)
        
        print( "selected row \(indexPath.row) ")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let ReportVC = segue.destination as? ReportViewController else { return }
            
        ReportVC.scan = self.items![i].scan
        ReportVC.rep = self.items![i]
    
    }
    
    
}
