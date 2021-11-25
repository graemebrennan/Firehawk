//
//  NewServiceSummaryViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

// notes
// good core data tutorial Sam Meech-Ward you tube

import UIKit
import CoreData

class NewServiceSummaryViewController: UIViewController, UITableViewDataSource {
    
    var newReport: DeviceReportOP?
    var propertyDetails = PropertyDetails()
    var scanCount: Int?
    
    //coredata
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var serviceReports: [ServiceReportCD]? = []
    var latestRecord: ServiceReportCD?
    var deviceReportList: [DeviceReportCD]? = []
    var houseAddress: AddressCD?
    
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
        
        if self.scanCount == nil {
            // creat a new service report and save to core data
            createNewServiceReport()
            self.scanCount = 1
        } else {
            self.scanCount! += 1
        }
        
        fetchLatestServiceReport()
        
        addNewReport()
        
        setUpElements()
        
    }
    
    func setUpElements() {
        
        Utilities.styleFilledButton(scanNewButton)
        
    }
    
    func addNewReport() {
        
        let newDeviceReport = DeviceReportCD(context: self.context)
        newDeviceReport.serviceReport = self.latestRecord
        newDeviceReport.title = newReport?.title
        newDeviceReport.date = newReport?.date
        newDeviceReport.scan = newReport?.scan
        newDeviceReport.healthIndicator = newReport?.healthIndicator
        newDeviceReport.note = newReport?.note
        newDeviceReport.serialNumber = newReport?.serialNumber
        newDeviceReport.deviceType = newReport?.deviceType
        
        latestRecord?.addToDeviceReports(newDeviceReport)
        
        // save the date to core
        do {
            try self.context.save()
        }
        catch {
            print("error adding new reports. ")
        }
        
        DispatchQueue.main.async {
            
            self.deviceReportList = self.latestRecord?.deviceReports?.allObjects as? [DeviceReportCD]
            
            self.tableView.reloadData()
        }
        
    }
    
    func fetchLatestServiceReport() {
        
        // fetch all the ServiceReports in core data
        do {
            
            let request = ServiceReportCD.fetchRequest() as NSFetchRequest<ServiceReportCD>
            
            self.serviceReports = try context.fetch(request)
            let count = self.serviceReports!.count - 1
            
            self.latestRecord = serviceReports![count]
            
            
        }
        catch {
            
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        // segue back to main menu scren
        print("Unwinding save new report here")
    }
    
    
    
    
    @IBAction func onPress(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.deviceReportList?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCellIdentifier", for: indexPath) as! DeviceCell
        
        cell.lblName.text = self.deviceReportList?[indexPath.row].title
        cell.lblSerialNumber.text = self.deviceReportList?[indexPath.row].serialNumber
        cell.lblDate.text =  "Date: \(dateFormat(date: (self.deviceReportList?[indexPath.row].date!)!))"
        cell.FaultIndicatorView.backgroundColor = getFaultColour(str: (self.deviceReportList?[indexPath.row].healthIndicator)!)
        
        
        if self.deviceReportList?[indexPath.row].healthIndicator == "green" {
            
            cell.lblNote.text = "Device in good helth"
        } else if self.deviceReportList?[indexPath.row].healthIndicator == "amber" {
            cell.lblNote.text = "There may be an issue with this device"
        } else {
            cell.lblNote.text = "There is a fault with this device"
        }
        
        // add device image
        if self.deviceReportList?[indexPath.row].deviceType == "X10" {
            
            cell.imageView?.image = UIImage(named: "Firehawk_FHB10_smoke_alarm.png")
            
        } else if self.deviceReportList?[indexPath.row].deviceType == "CO7B 10Y" {
            
            cell.imageView?.image = UIImage(named: "Firehawk_CO7B10Y.png")
            
        } else if self.deviceReportList?[indexPath.row].deviceType == "H10"{
            
            cell.imageView?.image = UIImage(named: "Firehawk_FHH10_heat_alarm.png")
            
        } else {
            print ("Error, devicetype not recognised")
        }
        
        return cell
    }
    
    func createNewServiceReport() {
        
        let newServiceReport = ServiceReportCD(context: self.context)
        
        newServiceReport.name = self.propertyDetails.name
        newServiceReport.date = self.propertyDetails.date
        
        newServiceReport.faultIndicator = self.propertyDetails.faultIndicator
        
        let newHouseAddress = AddressCD(context: self.context)
        
        newHouseAddress.line1 = self.propertyDetails.line1
        newHouseAddress.line2 = self.propertyDetails.line2
        newHouseAddress.postcode = self.propertyDetails.postcode
        newHouseAddress.townCity = self.propertyDetails.townCity
  
        newServiceReport.houseAddress = newHouseAddress
        

        // save the date to core
        do {
            try self.context.save()
        }
        catch {
            print("error adding new reports. ")
        }
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
        if segue.identifier == "UnwindToScanner" {
            let ScannerVC = segue.destination as! ScannerViewController
            ScannerVC.scanCount = self.scanCount
            
        } else {
            print("other segue identifier")
        }
        
    }
    
    func dateFormat(date: Date) -> String {

        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short//"dd/mm/yyyy"
        
        
        let str = formatter1.string(from: date)
        return str
    }
}
