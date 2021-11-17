//
//  DeviceReportViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import CoreData

class DeviceReportViewController: UIViewController {
    
    // recieve from other VC's
    var newScan: String?
    var propertyDetails = PropertyDetails() // valid only on first scan
    var scanCount: Int?
    var testScan = "75a01003000c080002000f000201ffff03ffff05ffff07ffffffffffffffffffff0000ffb2a388"
    var testScan2 = "75a0000300510800020010000c00ffff00ffff00ffff020000002500100048ffff000004b6a2dc"
    var testScan3 = "75a00005ff151eff150016ff1504ff1502ff1501000909ff15ff150001ff15ffff000804aca260"
    // build here
    var propertyReport = ServiceReportOP()
    var newScanAnalysis: ScanAnalysis?
    var newReport: DeviceReportOP?
    var packet: Packet?
    //coredata
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func route() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "DeviceReportViewController") as? DeviceReportViewController else {
            return UIViewController()
        }
        return vc
    }
    
    
    
    
    @IBOutlet weak var deviceInformationTitle: SectionTitle!
    
    //@IBOutlet var view: UIView!
    
    @IBOutlet weak var faultsTitle: SectionTitle!
    @IBOutlet weak var alarmsTitle: SectionTitle!
    @IBOutlet weak var aditionalInfoTitle: SectionTitle!
    
    @IBOutlet weak var AlarmsTableView: UITableView!
    @IBOutlet weak var FaultTableView: UITableView!
    @IBOutlet weak var GeneralInfoTableView: UITableView!
    
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var manufactureDate: UILabel!
    @IBOutlet weak var peakCOLabel: UILabel!
    
    @IBOutlet weak var productCard: ProductCard!
    
    @IBOutlet weak var commentsTV: UITextView!
    @IBOutlet weak var bgCommentsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Alarms Table View
        AlarmsTableView.delegate = self
        AlarmsTableView.dataSource = self
        AlarmsTableView.register(UINib(nibName: "AlarmInfoCell", bundle: nil), forCellReuseIdentifier: "AlarmInfoCellIdentifier")
        
        FaultTableView.delegate = self
        FaultTableView.dataSource = self
        FaultTableView.register(UINib(nibName: "FaultInfoCell", bundle: nil), forCellReuseIdentifier: "FaultInfoCellIdentifier")
        
        GeneralInfoTableView.delegate = self
        GeneralInfoTableView.dataSource = self
        GeneralInfoTableView.register(UINib(nibName: "AlarmInfoCell", bundle: nil), forCellReuseIdentifier: "AlarmInfoCellIdentifier")
        // Unpack the scan data
        
      self.newScanAnalysis = ScanAnalysis(scan: newScan!)
//        self.newScanAnalysis = ScanAnalysis(scan: testScan3)
        
        serialNumberLabel.text = "  Serial Number: \(newScanAnalysis!.deviceSerialNumber!)"
        manufactureDate.text = "  Manufacture Date: \(dateFormat( date: newScanAnalysis!.snManufactureDate!))"
        peakCOLabel.text = "  Peak CO Reading: \(newScanAnalysis!.peakCO!) PPM"
        
        // lblWarning.alpha = 1
        deviceInformationTitle.lblTitle.text = "Device Information"
        faultsTitle.lblTitle.text = "Device Faults"
        alarmsTitle.lblTitle.text = "Alarms"
        aditionalInfoTitle.lblTitle.text = "Additional Information"
        

        
        for i in stride(from: 0, to: self.newScan!.count, by: 2) {
            
        }
        
        commentsTV.text = """
                          1: \(self.packet!.rawData[0]!.HexVal!)
                          2: \(self.packet!.rawData[1]!.HexVal!)
                          3: \(self.packet!.rawData[2]!.HexVal!)
                          4: \(self.packet!.rawData[3]!.HexVal!)
                          5: \(self.packet!.rawData[4]!.HexVal!)
                          6: \(self.packet!.rawData[5]!.HexVal!)
                          7: \(self.packet!.rawData[6]!.HexVal!)
                          8: \(self.packet!.rawData[7]!.HexVal!)
                          9: \(self.packet!.rawData[8]!.HexVal!)
                          10: \(self.packet!.rawData[9]!.HexVal!)
                          11: \(self.packet!.rawData[10]!.HexVal!)
                          12: \(self.packet!.rawData[11]!.HexVal!)
                          13: \(self.packet!.rawData[12]!.HexVal!)
                          14: \(self.packet!.rawData[13]!.HexVal!)
                          15: \(self.packet!.rawData[14]!.HexVal!)
                          16: \(self.packet!.rawData[15]!.HexVal!)
                          17: \(self.packet!.rawData[16]!.HexVal!)
                          18: \(self.packet!.rawData[17]!.HexVal!)
                          19: \(self.packet!.rawData[18]!.HexVal!)
                          20: \(self.packet!.rawData[19]!.HexVal!)
                          21: \(self.packet!.rawData[20]!.HexVal!)
                          22: \(self.packet!.rawData[21]!.HexVal!)
                          23: \(self.packet!.rawData[22]!.HexVal!)
                          24: \(self.packet!.rawData[23]!.HexVal!)
                          25: \(self.packet!.rawData[24]!.HexVal!)
                          26: \(self.packet!.rawData[25]!.HexVal!)
                          27: \(self.packet!.rawData[26]!.HexVal!)
                          28: \(self.packet!.rawData[27]!.HexVal!)
                          29: \(self.packet!.rawData[28]!.HexVal!)
                          30: \(self.packet!.rawData[29]!.HexVal!)
                          31: \(self.packet!.rawData[30]!.HexVal!)
                          32: \(self.packet!.rawData[31]!.HexVal!)
                          33: \(self.packet!.rawData[32]!.HexVal!)
                          34: \(self.packet!.rawData[33]!.HexVal!)
                          35: \(self.packet!.rawData[34]!.HexVal!)
                          36: \(self.packet!.rawData[35]!.HexVal!)
                          37: \(self.packet!.rawData[36]!.HexVal!)
                          38: \(self.packet!.rawData[37]!.HexVal!)
                          39: \(self.packet!.rawData[38]!.HexVal!)
                          """
        
        commentsTV.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        // AdditionalInfo.lableInputtf.text = "enter text here"
        // vHeader.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        commentsTV.translatesAutoresizingMaskIntoConstraints = false
        [
            commentsTV.topAnchor.constraint(equalTo: bgCommentsView.topAnchor),
            commentsTV.leadingAnchor.constraint(equalTo: bgCommentsView.leadingAnchor),
            bgCommentsView.trailingAnchor.constraint(equalTo: bgCommentsView.trailingAnchor),
            commentsTV.heightAnchor.constraint(equalTo: bgCommentsView.heightAnchor)
        ].forEach{ $0.isActive = true}
        
        
        // fill information
        
        if newScanAnalysis?.deviceType == "X10" {
            
            //  SmokeAlarmInformation(newReport: newReport!)
            
        } else if newScanAnalysis?.deviceType == "CO7B 10Y" {
            
            COAlarmInformation(newReport: newScanAnalysis!)
            
        } else if newScanAnalysis?.deviceType == "H10"{
            
            //   HeatAlarmInformation(newReport: newReport!)
            
        } else {
            print ("Error, devicetype not recognised")
        }
        
        
    }
    
    func COAlarmInformation(newReport: ScanAnalysis) {
        
        // General Info
        
        productCard.imgView.image = UIImage(named: "Firehawk_CO7B10Y.png")
        productCard.lblTitle.text = newReport.deviceType
        
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        
        // add the report to the database here then segue to the main menue, the refference for the bellow code with alert was from code with chris
        // https://www.youtube.com/watch?v=O7u9nYWjvKk
        
        // Create alert
        let alert = UIAlertController(title: "Report Title", message: "please enter a title for the device report", preferredStyle: .alert)
        
        alert.addTextField()
        
        // Configure button handler
        let completeServiceButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            // Get the textfield for the alert
            let textfield = alert.textFields![0]
            
            // Create a New device report object
            self.newReport = DeviceReportOP(scan: self.newScan)
            self.newReport?.scan = self.newScan
            self.newReport?.title = textfield.text
            self.newReport?.date = Date()
            self.newReport?.deviceType = self.newScanAnalysis?.deviceType
            self.newReport?.serialNumber = self.newScanAnalysis?.deviceSerialNumber
            self.newReport?.note = self.commentsTV.text
            self.newReport?.healthIndicator = self.newScanAnalysis?.deviceFaultIndicator
            
            
            // self.moveToMainScreen()
            self.moveToNewServiceSummary()
        }
        
        
        // Add button
        alert.addAction(completeServiceButton)
        
        // show alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func moveToNewServiceSummary() {
        
        // perform segue to main
        performSegue(withIdentifier: "NewDeviceReportToNewServiceSummary", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewDeviceReportToNewServiceSummary" {
            
            let NewServiceSummaryVC = segue.destination as! NewServiceSummaryViewController
            
            NewServiceSummaryVC.newReport = self.newReport
            NewServiceSummaryVC.propertyDetails = self.propertyDetails
            NewServiceSummaryVC.scanCount = self.scanCount
        }
    }
    
    
    func moveToMainScreen() {
        
        // perform segue to main
        performSegue(withIdentifier: "DeviceReportToMain", sender: self)
    }
    
    
    func moveToScanScreen() {
        
        // perform segue to main
        performSegue(withIdentifier: "deviceReportVCtoScan", sender: self)
        
    }
}

extension DeviceReportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == AlarmsTableView {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("indexPath =  \(indexPath.row)")
        
        if tableView == AlarmsTableView {
            
            //            cell = tableView.dequeueReusableCell(withIdentifier: "AlarmInfoCellIdentifier", for: indexPath) as! AlarmInfoCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmInfoCellIdentifier", for: indexPath) as! AlarmInfoCell
            
            switch indexPath.row {
            case 0: // High Co Alarm +300PPM
                
                cell.title.text = "High CO Alarm (+300 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newScanAnalysis!.highCOAlarmCount!))"
                
                if self.newScanAnalysis!.highCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    //cell.date.text = "Date of Last Alarm: \(self.newScanAnalysis!.highCOAlarmLastDate!.as_ddmmyyyy())"
                    if self.newScanAnalysis!.highCOAlarmLastDate != nil {
                        cell.date.text = "Date of Last Alarm: \(dateFormat( date: self.newScanAnalysis!.highCOAlarmLastDate!))"
                        
                    } else {
                        cell.date.text = "Date of Last Alarm: No event date"
                    }
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis!.highCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newScanAnalysis!.highCOAlarmFaultIndicator)
                
            case 1: // Medium Co Alarm +300PPM
                
                cell.title.text = "Medium CO Alarm (>100 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newScanAnalysis!.mediumCOAlarmCount!))"
                
                if self.newScanAnalysis!.mediumCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    
                    if self.newScanAnalysis!.mediumCOAlarmLastDate != nil {
                        cell.date.text = "Date of Last Alarm: \(dateFormat( date: self.newScanAnalysis!.mediumCOAlarmLastDate!))"
                        
                    } else {
                        cell.date.text = "Date of Last Alarm: No event date"
                    }
                   // cell.date.text = "Date of Last Alarm: \(self.newScanAnalysis!.mediumCOAlarmLastDate!.as_ddmmyyyy())"
                    
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis!.mediumCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newScanAnalysis!.mediumCOAlarmFaultIndicator)
                
                
            case 2: // Low Co Alarm +300PPM
                
                cell.title.text = "Low CO Alarm (<100 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newScanAnalysis!.lowCOAlarmCount!))"
                
                if self.newScanAnalysis!.lowCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    
                    if self.newScanAnalysis!.lowCOAlarmLastDate != nil {
                        cell.date.text = "Date of Last Alarm: \(dateFormat( date: self.newScanAnalysis!.lowCOAlarmLastDate!))"
                        
                    } else {
                        cell.date.text = "Date of Last Alarm: No event date"
                    }
                    //cell.date.text = "Date of Last Alarm: \(self.newScanAnalysis!.lowCOAlarmLastDate!.as_ddmmyyyy())"
                    
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis!.lowCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newScanAnalysis!.lowCOAlarmFaultIndicator)
                
                
            case 3: // Pre Alarm
                
                cell.title.text = "Pre Alarms"
                cell.count.text = "Alarm Count: \(String(describing: newScanAnalysis!.preCOAlarmCount!))"
                
                if self.newScanAnalysis!.preCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    
                    if self.newScanAnalysis!.preCOAlarmLastDate != nil {
                        cell.date.text = "Date of Last Alarm: \(dateFormat( date: self.newScanAnalysis!.preCOAlarmLastDate!))"
                        
                    } else {
                        cell.date.text = "Date of Last Alarm: No event date"
                    }
                   // cell.date.text = "Date of Last Alarm: \(self.newScanAnalysis!.preCOAlarmLastDate!.as_ddmmyyyy())"
                    
                    
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis!.preCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newScanAnalysis!.preCOAlarmFaultIndicator)
                
                
            default:
                print("something went wrong here")
                
                
            }
            
            return cell
            
        } else if tableView == GeneralInfoTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmInfoCellIdentifier", for: indexPath) as! AlarmInfoCell
            
            switch indexPath.row {
            case 0: // Life Remaining
                
                cell.title.text = "Life Remaining"
                
                
                if self.newScanAnalysis!.lifeRemainingFaultIndicator == "green" {
                    // device not in final year of life
                    cell.count.text = "\(String(describing: self.newScanAnalysis!.deviceLifeRemaining_YearsLeft!)) Years Left"
                    cell.note.text = " - "
                    
                } else if self.newScanAnalysis!.lifeRemainingFaultIndicator == "amber" {
                    // the device is in its final year of life
                    cell.count.text = "\(String(describing: self.newScanAnalysis!.deviceLifeRemaining_MonthsLeft!)) Months Left"
                    cell.note.text = "This device will need to be replaced soon"
                } else {
                    // the device is in its final 6 months
                    cell.count.text = "\(String(describing: self.newScanAnalysis!.deviceLifeRemaining_DaysLeft!)) Days Left"
                    cell.note.text = "This device needs to be replaced"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis!.lifeRemainingFaultIndicator)
                
                //cell.date.text = "Product Expiration Date: \( newScanAnalysis!.snManufactureExpiaryDate!.as_ddmmyyyy())"
                //dateFormat( date:
                cell.date.text = "Product Expiration Date: \(dateFormat( date: newScanAnalysis!.snManufactureExpiaryDate!))"
                
            case 1: // Plate Removals
                
                cell.title.text = "Device Removals"
                cell.count.text = "Removal Count: \(String(self.newScanAnalysis!.plateRemovals!))"
                
                if self.newScanAnalysis!.plateRemovals == 0 {
                    cell.date.text = " - "
                    cell.note.text = "Device has never been removed"
                } else {
                    
                    cell.date.text = "Last Removal Date: \(dateFormat( date: self.newScanAnalysis!.lastPlateRemovalDate!))"
                    
                    if self.newScanAnalysis!.plateRemovalsFaultIndicator == "amber" {
                        cell.note.text = "Device has been removed in past year"
                    } else if self.newScanAnalysis!.plateRemovalsFaultIndicator == "red"{
                        cell.note.text = "Device has been removed in past 6 months"
                    } else {
                        cell.note.text = " - "
                    }
                    
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis?.plateRemovalsFaultIndicator ?? "red")
                
            case 2: // Device Test History
                
                cell.title.text = "Device Test"
                cell.count.text = "Test Count: \(self.newScanAnalysis!.deviceTestCount!)"
                
                if self.newScanAnalysis!.deviceTestCount == 0 {
                    cell.date.text = " Device never tested"
                } else {
                    //cell.date.text = "Last Test Date: \(self.newScanAnalysis!.deviceLastTestDate!.as_ddmmyyyy())"
                    cell.date.text = "Last Test Date: \(dateFormat( date: self.newScanAnalysis!.deviceLastTestDate!))"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis!.deviceTestFaultIndicator)
                
                
                
                if self.newScanAnalysis?.deviceTestFaultIndicator == "green" {
                    
                    cell.note.text = "Device tested within past week"
                    
                } else if self.newScanAnalysis?.deviceTestFaultIndicator == "amber" {
                    
                    cell.note.text = "Device has not been tested for more than two weeks"
                    
                } else {
                    
                    cell.note.text = "Device has not been tested for more than a month"
                    
                }
                
            default:
                print("something went wrong here")
                
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaultInfoCellIdentifier", for: indexPath) as! FaultInfoCell
            
            switch indexPath.row {
            case 0:
                
                cell.title.text = "Battery Fault               \(newScanAnalysis!.batteryVoltage!)V"
                
                print("newScanAnalysis?.batteryFault = \(newScanAnalysis?.batteryFault)")
                if newScanAnalysis?.batteryFault == true {
                    if newScanAnalysis?.batteryFaultDate != nil {
                        cell.date.text = "Last Occured \(dateFormat( date: self.newScanAnalysis!.batteryFaultDate!))"
                    } else {
                        cell.date.text = "Event Date Unknown"
                    }
                    
                    cell.note.text = "Battery Fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0xEA4748)
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0x9EC042)
                }
                
            case 1:
                
                cell.title.text = "Device Fault"
                
                if newScanAnalysis?.deviceFault == true {
                    cell.note.text = "Device Fault"
                
                    if newScanAnalysis?.deviceFaultDate != nil {
                        cell.date.text = "Last Occured  \(dateFormat( date: self.newScanAnalysis!.deviceFaultDate!))"
                    } else {
                        cell.date.text = "Event Date Unknown"
                    }
                    
                    
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0xEA4748)
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No Fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0x9EC042)
                }
                
            case 2:
                
                cell.title.text = "End Of Life Fault"
                
                if newScanAnalysis?.eol_Fault == true {
                    cell.note.text = "End of Life Fault"
                    
                    if newScanAnalysis?.eol_FaultDate != nil {
                        cell.date.text = "Last Occured \(dateFormat( date: self.newScanAnalysis!.eol_FaultDate!))"
                    } else {
                        cell.date.text = "Event Date Unknown"
                    }
                    
                    
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0xEA4748)
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No Fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0x9EC042)
                }
                
            default:
                print("Something went wrong")
                
            }
            return cell
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
    
    func getFaultNote(str : String) -> String {
        
        switch str {
        case "green":
            return "No recent alarms detected"
        case "amber":
            return "Alarm within the past year"
        case "red":
            return "Alarm within the past month"
        default:
            return ""
        }
    }
    
    func dateFormat(date: Date) -> String {

        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short//"dd/mm/yyyy"
        
        
        let str = formatter1.string(from: date)
        return str
    }
}
