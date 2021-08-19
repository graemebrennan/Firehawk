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
    var propertyReport: ServiceReportOP?
    
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
    
    
    //fetchLatestServiceReport()
    
//    if let allDeviceReports = latestRecord?.deviceReports?.allObjects as? [DeviceReportCD] {
//        self.deviceReportList = allDeviceReports
//    }
//
    setUpElements()
  }
    
    func setUpElements() {
        
        
        Utilities.styleFilledButton(scanNewButton)
        
    }
    
//    func fetchLatestServiceReport() {
//
//        // fetch all the ServiceReports in core data
//        do {
//
//            let request = ServiceReportCD.fetchRequest() as NSFetchRequest<ServiceReportCD>
//
//            self.serviceReports = try context.fetch(request)
//            let count = self.serviceReports!.count - 1
//
//            self.latestRecord = serviceReports![count]
//
//            print("self.latestRecord?.deviceReports[0].name = \((self.latestRecord?.deviceReports)!)")
//           // tableView.reloadData()
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//        catch {
//
//        }
//    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        // segue back to main menu scren
        print("Unwinding save new report here")
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
    
    return self.propertyReport?.deviceReport?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCellIdentifier", for: indexPath) as! DeviceCell
    
    cell.lblName.text = self.propertyReport?.deviceReport![indexPath.row].title
    cell.lblDate.text =  self.propertyReport?.deviceReport![indexPath.row].date?.as_ddmmyyyy_hhmmss()
    cell.FaultIndicatorView.backgroundColor = getFaultColour(str: (self.propertyReport?.deviceReport![indexPath.row].healthIndicator)!)
    
    // add device image
    if self.propertyReport?.deviceReport![indexPath.row].deviceType == "X10" {
        
        
        cell.imageView?.image = UIImage(named: "Firehawk_FHB10_smoke_alarm.png")

    } else if self.propertyReport?.deviceReport![indexPath.row].deviceType == "CO" {

        cell.imageView?.image = UIImage(named: "Firehawk_CO7B10Y.png")
        
    } else if self.propertyReport?.deviceReport![indexPath.row].deviceType == "H10"{

        cell.imageView?.image = UIImage(named: "Firehawk_FHH10_heat_alarm.png")

    } else {
        print ("Error, devicetype not recognised")
    }
    
    
    return cell
  }
    
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
    
    @IBAction func scanNewDevicePressed(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepair for segue before unwinding")
        
        // save current service report to CD here
        
        // create report
        var newServiceReport = ServiceReportCD(context: self.context)
        newServiceReport.name = newPropertyDetails.name
        newServiceReport.date = newPropertyDetails.date

        var newServiceAddress = Address(CD(context: self.context))
        newServiceAddress.serviceReport = newServiceReport
        newServiceAddress.line1 = newPropertyDetails.line1
        newServiceAddress.line2 = newPropertyDetails.line2
        newServiceAddress.postcode = newPropertyDetails.postcode
        newServiceAddress.townCity = newPropertyDetails.townCity
        
        // save the date to core
        do {
            try self.context.save()
        }
        catch {
            print("error in storing new service report on core date. ")
        }
        
    }
}
