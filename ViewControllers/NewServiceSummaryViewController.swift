//
//  NewServiceSummaryViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import CoreData

class NewServiceSummaryViewController: UIViewController, UITableViewDataSource {
  

    var newReport: DeviceReport?
    var deviceReportList: [DeviceReportCD]? = []
    
    //coredata
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var serviceReports: [ServiceReportCD]? = []
    var latestRecord: ServiceReportCD?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanNewButton: UIButton!
    
  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "NewServiceSummaryViewController") as? NewServiceSummaryViewController else {
      return UIViewController()
    }
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "DeviceCellIdentifier")
    tableView.dataSource = self
    
    
    fetchLatestServiceReport()
    
    if let allDeviceReports = latestRecord?.deviceReports?.allObjects as? [DeviceReportCD] {
        self.deviceReportList = allDeviceReports
    }
    
    setUpElements()
  }
    
    func setUpElements() {
        
        
        Utilities.styleFilledButton(scanNewButton)
        
    }
    
    func fetchLatestServiceReport() {

        // fetch all the ServiceReports in core data
        do {

            let request = ServiceReportCD.fetchRequest() as NSFetchRequest<ServiceReportCD>

            self.serviceReports = try context.fetch(request)
            let count = self.serviceReports!.count - 1
            
            self.latestRecord = serviceReports![count]
            
            print("self.latestRecord?.deviceReports[0].name = \((self.latestRecord?.deviceReports)!)")
           // tableView.reloadData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {

        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        // segue back to main menu scren
        
    }
    
    
    
    
    @IBAction func onPress(_ sender: Any) {
    navigationController?.popViewController(animated: true)
    
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.deviceReportList?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCellIdentifier", for: indexPath) as! DeviceCell
    
    cell.lblName.text = self.deviceReportList?[indexPath.row].title
    cell.lblDate.text =  self.deviceReportList?[indexPath.row].date?.as_ddmmyyyy_hhmmss()
//        //self.serviceReports?[indexPath.row].date?.as_ddmmyyyy_hhmmss()
    
    // add device image
    if self.deviceReportList?[indexPath.row].deviceType == "X10" {
        
        
        cell.imageView?.image = UIImage(named: "Firehawk_FHB10_smoke_alarm.png")

    } else if self.deviceReportList?[indexPath.row].deviceType == "CO" {

        cell.imageView?.image = UIImage(named: "Firehawk_CO7B10Y.png")
        
    } else if self.deviceReportList?[indexPath.row].deviceType == "H10"{

        cell.imageView?.image = UIImage(named: "Firehawk_FHH10_heat_alarm.png")

    } else {
        print ("Error, devicetype not recognised")
    }
    
    
    return cell
  }
    

    @IBAction func scanNewDevicePressed(_ sender: UIButton) {
        
    }
    
}
