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
   // let contextServiceReport = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedSeviceReport: ServiceReportCD?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NewServiceButton: UIButton!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    @IBAction func settingButtonPressed(_ sender: UIBarButtonItem) {
        //edit user settings here
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        // log out and return to firestore here.
        // unwind to home page
    }
    
    
    var serviceReports: [ServiceReportCD]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()

        print("viewDidLoad")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        // register custom cell .xib in table view
        tableView.register(UINib(nibName: "ServiceCell", bundle: nil), forCellReuseIdentifier: "ServiceCellIdentifier")
       
        
        // Get items from core data
        fetchReports()

    }
    
    func setUpElements() {
        
        // style the elements
        Utilities.styleFilledButton(NewServiceButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        fetchReports()
    }
    
    func fetchReports() {
        
        print("fetching reports from core data")
        
        // fetch the data from core data to display in the tableView
        do {
            
            let request = ServiceReportCD.fetchRequest() as NSFetchRequest<ServiceReportCD>
            
            // set the filtering and sorting on the request
            //let pred = NSPredicate(format: <#T##String#>)
            //request.predicate = pred
            
            // sort
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            
            self.serviceReports = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                print("reloadData")
            }
        } catch {
            print("error retrieving reports from core data")
        }
    }
 
    
    @IBAction func NewServicePressed(_ sender: UIButton) {
        
        // create a new service here
//        var newServiceReport = ServiceReport(context: context)
//        newServiceReport.name = "ServiceReportName"
//        newServiceReport.date = Date()
        
        //create a new service object
        var newServiceReport = ServiceReport()
        newServiceReport.name = "get a name"
        newServiceReport.date = Date()
        
        performSegue(withIdentifier: "MenuVCToAutoFillAddressVC", sender: self)
    }
    
    
    

}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("items to be reloaded = \(self.serviceReports?.count)")
        return self.serviceReports?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCellIdentifier", for: indexPath) as! ServiceCell
        
        let serviceReport = self.serviceReports![indexPath.row]
        
        // fill cell details
        
        //TODO:- Handel when properties are not, if they ever will be null.
        cell.lblName.text = serviceReport.name ?? "No Name"
       // cell.lblAddress.text = serviceReport.houseAddress?.line1 ?? "No Address"
        cell.lblAddress.text = serviceReport.houseAddress?.postcode
        cell.lblDate.text = serviceReport.date?.as_ddmmyyyy_hhmmss() ?? "Date Unkownand"
        cell.faultIndicator.backgroundColor = getFaultColour(str: "amber")
        
   //     cell.lblAddress.text = houseReport.houseAddress?.postcode
//        print("deviceReport.deviceType = \(deviceReport.deviceType)")
//        if deviceReport.deviceType == "CO" {
//
   //         cell.imgView.image = UIImage(named: "Firehawk_CO7B10Y.png")
//
//        } else if deviceReport.deviceType == "X10"{
//
//            cell.imgView.image = UIImage(named: "Firehawk_FHB10_smoke_alarm")
//
//        } else if deviceReport.deviceType == "H10"{
//
//            cell.imgView.image = UIImage(named: "Firehawk_FHH10_heat_alarm")
//
//        } else {
//            cell.imgView.image = nil
//        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //Which report to remove
            let reportToRemove = self.serviceReports![indexPath.row] as ServiceReportCD
            
                // Remove the report
                self.context.delete(reportToRemove)
                
                // save the data
                do {
                    try self.context.save()
                } catch {
                    print(error)
                    print("error saving data to core data db")
                }
                
            
            // re-fetch the data
            self.fetchReports()
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    @IBAction func unwindToMainViewController(_ sender: UIStoryboardSegue) {}

    func getFaultColour(str : String) -> UIColor {
        
        switch str {
        case "green":
            return UIColor(rgb: 0x9EC042)
        case "amber":
            return UIColor(rgb: 0xD86437)
        case "red":
            return UIColor(rgb: 0xEA4748)
        default:
            return .lightGray
        }
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get selected report.
        self.selectedSeviceReport = self.serviceReports![indexPath.row]
        
        //self.i = indexPath.row
        performSegue(withIdentifier: "MainVCToReportSummaryVC", sender: self)
        
        print( "did selected row \(indexPath.row) ")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "MainVCToReportSummaryVC" {
            let ReportVC = segue.destination as! OldServiceSummaryViewController
                
            
            ReportVC.serviceReport = self.selectedSeviceReport

        } else if segue.identifier == "MenuVCToAutoFillAddressVC" {
    
    }
    
    
}
}
