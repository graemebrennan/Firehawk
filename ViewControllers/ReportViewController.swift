//
//  ReportStatusViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import CoreData

class ReportViewController: UIViewController {
    
    
    var scan: String?
    var deviceReport: DeviceReportCD?
    var newReport: ScanAnalysis?
    
    var propertyReport = ServiceReportOP()
    var newScanAnalysis: ScanAnalysis?
    
    @IBOutlet weak var deviceInformationTitle: SectionTitle!
    
    @IBOutlet weak var faultsTitle: SectionTitle!
    @IBOutlet weak var alarmsTitle: SectionTitle!
    @IBOutlet weak var aditionalInfoTitle: SectionTitle!
    
    @IBOutlet weak var AlarmsTableView: UITableView!
    @IBOutlet weak var FaultTableView: UITableView!
    @IBOutlet weak var GeneralInfoTableView: UITableView!
    
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var manufactureDate: UILabel!

    @IBOutlet weak var productCard: ProductCard!
    
    @IBOutlet weak var commentsTV: UITextView!
    @IBOutlet weak var bgCommentsView: UIView!
    
    static func route() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "ReportStatusViewController") as? ReportViewController else {
            return UIViewController()
        }
        return vc
    }
    
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
        
        self.newScanAnalysis = ScanAnalysis(scan: (self.deviceReport!.scan!))
        
        
        serialNumberLabel.text = "Serial Number: \(newScanAnalysis!.deviceSerialNumber!)"
        manufactureDate.text = "Manufacture Date: \( dateFormat(date: newScanAnalysis!.snManufactureDate!) )"
        
        
       
      deviceInformationTitle.lblTitle.text = "Device Information"
      faultsTitle.lblTitle.text = "Device Faults"
        alarmsTitle.lblTitle.text = "Alarms"
        aditionalInfoTitle.lblTitle.text = "Additional Information"
        commentsTV.text = deviceReport?.note
        
        commentsTV.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        
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
        productCard.lblNote.alpha = 0
  }
    
}

extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    
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
                
                cell.date.text = "Product Expiration Date: \( dateFormat(date: newScanAnalysis!.snManufactureExpiaryDate!) )"
                
                
            case 1: // Plate Removals
                
                cell.title.text = "Device Removals"
                cell.count.text = "Removal Count: \(String(self.newScanAnalysis!.plateRemovals!))"
                
                if self.newScanAnalysis!.plateRemovals == 0 {
                    cell.date.text = " - "
                    cell.note.text = "Device has never been removed"
                } else {
                    
                    cell.date.text = "Last Removal Date: \( dateFormat(date: self.newScanAnalysis!.lastPlateRemovalDate!) )"
                    
                    if self.newScanAnalysis!.plateRemovalsFaultIndicator == "amber" {
                        cell.note.text = "Device has been removed in past year"
                    } else if self.newScanAnalysis!.plateRemovalsFaultIndicator == "red"{
                        cell.note.text = "Device has been removed in past 6 months"
                    } else {
                        cell.note.text = " - "
                    }
               
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newScanAnalysis!.plateRemovalsFaultIndicator)
                
            case 2: // Device Test History
                
                cell.title.text = "Device Test"
                cell.count.text = "Test Count: \(self.newScanAnalysis!.deviceTestCount!)"
                
                if self.newScanAnalysis!.deviceTestCount == 0 {
                    cell.date.text = " Device never tested"
                } else {
                    cell.date.text = "Last Test Date: \(dateFormat(date: self.newScanAnalysis!.deviceLastTestDate!) )"
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
                
                cell.title.text = "Battery Fault        \(newScanAnalysis!.batteryVoltage!)V"
                
                if newScanAnalysis?.batteryFault == true {
                    cell.date.text = "Last Occured \(newScanAnalysis!.batteryFaultDate!)"
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
                    cell.date.text = "Last Occured  \(newScanAnalysis?.deviceFaultDate)"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0xEA4748)
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No Fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0x9EC042)
                }

            case 2:
                
                cell.title.text = "End Of Life Fault"
                
                if newScanAnalysis?.eol_Fault == true {
                    cell.note.text = "eol_Fault"
                    cell.date.text = "Last Occured \(newScanAnalysis?.eol_FaultDate)"
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
            return "No Alarms detected"
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
