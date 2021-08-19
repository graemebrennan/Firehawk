//
//  DeviceReportViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import Firebase
import CoreData

class DeviceReportViewController: UIViewController {

    // recieve from past VC
    var newScan: String?
    var propertyDetails = PropertyDetails()
    
    // build for bext VC
    var propertyReport = ServiceReportOP()
        
    //coredata
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var newReport: DeviceReport?
    var newRep: DeviceReportOP?

    
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
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var alarmsTitle: SectionTitle!
    @IBOutlet weak var aditionalInfoTitle: SectionTitle!
    
    @IBOutlet weak var AlarmsTableView: UITableView!
    @IBOutlet weak var FaultTableView: UITableView!
    @IBOutlet weak var GeneralInfoTableView: UITableView!
    
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var manufactureDate: UILabel!
    @IBOutlet weak var replacementDate: UILabel!
    
    // @IBOutlet weak var vHeader: UIView!
   // @IBOutlet weak var faultsStack: UIStackView!
//    @IBOutlet weak var AdditionalInformationStack: UIStackView!
    @IBOutlet weak var productCard: ProductCard!
    //@IBOutlet weak var alarmDataStack: UIStackView!
    
    
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
        
        self.newReport = DeviceReport(scan: newScan!)
        
        
        serialNumberLabel.text = "Serial Number: \(newReport!.deviceSerialNumber!)"
        manufactureDate.text = "Manufacture Date: \( newReport!.snManufactureDate!.as_ddmmyyyy())"
        
        
       // lblWarning.alpha = 1
      deviceInformationTitle.lblTitle.text = "Device Information"
      faultsTitle.lblTitle.text = "Device Faults"
        alarmsTitle.lblTitle.text = "Alarms"
        aditionalInfoTitle.lblTitle.text = "Additional Information"

        
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
        
        if newReport?.deviceType == "X10" {
            
          //  SmokeAlarmInformation(newReport: newReport!)

        } else if newReport?.deviceType == "CO" {

            COAlarmInformation(newReport: newReport!)
            
        } else if newReport?.deviceType == "H10"{

         //   HeatAlarmInformation(newReport: newReport!)

        } else {
            print ("Error, devicetype not recognised")
        }

        
    }
    
    func COAlarmInformation(newReport: DeviceReport) {
    
        // General Info
        
        productCard.imgView.image = UIImage(named: "Firehawk_CO7B10Y.png")
        productCard.lblTitle.text = newReport.deviceType
        
  }


  @IBAction func onPressComplete(_ sender: Any) {
    
    // read aditional comments input
    
    // save on database here,
    
    // Add a new document with a generated ID
    var ref: DocumentReference? = nil
    
//    if let reportScan = newScan, let reportUser =
//        Auth.auth().currentUser?.email {
//
//        ref = db.collection(K.FStore.collectionName).addDocument(data: [
//            K.FStore.senderField: reportUser,
//            K.FStore.scanField: reportScan
//
//        ]) { (error) in
//            if let e = error {
//                print("There was an issue saving data to Firestore, \(e)")
//            } else {
//                print("Sucessfully saved data to Firestore")
//            }
//        }
//
//    }
    
    navigationController?.popViewController(animated: true)
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
            
            // Create a person object
            var newRep = DeviceReportOP(scan: self.newScan)
            newRep.scan = self.newScan
            newRep.title = textfield.text
            newRep.date = Date()
            newRep.deviceType = self.newReport?.deviceType
            newRep.serialNumber = self.newReport?.deviceSerialNumber
            newRep.note = self.commentsTV.text
            newRep.healthIndicator = self.newReport?.deviceFaultIndicator
            
            if self.propertyReport.deviceReport?.count == nil {
                //create new property Report
                self.propertyReport.deviceReport![0] = newRep
            } else {
                self.propertyReport.deviceReport?.append(newRep)
            }
            // get latest report
           // self.fetchLatestServiceReport()
            
            //newRep.serviceReport = self.latestRecord
            
            // save the data to core data db
//            do {
//                try self.context.save()
//            } catch {
//                print("error saving data")
//            }
//
            // self.moveToMainScreen()
            self.moveToNewServiceSummary()
        }
        
        
        // Add button
        alert.addAction(completeServiceButton)
        //        // Add button
        //        alert.addAction(addDeviceButton)
        // show alert
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    func moveToNewServiceSummary() {
        
        // add device report to newServiceReport
        //  fetchServiceReport()
        
        
        
        // perform segue to main
        performSegue(withIdentifier: "NewDeviceReportToNewServiceSummary", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewDeviceReportToNewServiceSummary" {
            let NewServiceSummaryVC = segue.destination as! NewServiceSummaryViewController
            
            NewServiceSummaryVC.propertyReport = self.propertyReport
        }
        
    }
    
    // fetch the service report from core data, how
//    func fetchServiceReport() {
//
//        // fetch all the ServiceReports in core data
//        do {
//
//            let request : NSFetchRequest<ServiceReportCD> = ServiceReportCD.fetchRequest()
//
//            //request.setFetchLimit
//            // set the filtering and sorting on the request
//            //                    let pred = NSPredicate(format: "nameContains 'Ted'")
//            //                    request.predicate = pred
//
//
//            self.serviceReports = try context.fetch(request)
//            // tableView.reloadData()
//            print("servicereports count = ")
//            print(serviceReports!.count)
//        }
//        catch {
//
//        }
//    }
    
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
//        }
//        catch {
//
//        }
//    }
    
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
                // Alarm Stack
                
                cell.title.text = "High CO Alarm (+300 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newReport!.highCOAlarmCount))"
                
                if self.newReport!.highCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    cell.date.text = "Date of Last Alarm: \(self.newReport!.highCOAlarmLastDate!.as_ddmmyyyy())"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newReport!.highCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newReport!.highCOAlarmFaultIndicator)
                
            case 1: // Medium Co Alarm +300PPM
                
                cell.title.text = "Medium CO Alarm (>100 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newReport!.mediumCOAlarmCount!))"
                
                if self.newReport!.mediumCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    cell.date.text = "Date of Last Alarm: \(self.newReport!.mediumCOAlarmLastDate!.as_ddmmyyyy())"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newReport!.mediumCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newReport!.mediumCOAlarmFaultIndicator)

                
            case 2: // Low Co Alarm +300PPM
                
                cell.title.text = "Low CO Alarm (<100 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newReport!.lowCOAlarmCount!))"
                
                if self.newReport!.lowCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    cell.date.text = "Date of Last Alarm: \(self.newReport!.lowCOAlarmLastDate!.as_ddmmyyyy())"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newReport!.lowCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newReport!.lowCOAlarmFaultIndicator)

                
            case 3: // Pre Alarm
                
                cell.title.text = "Pre Alarms"
                cell.count.text = "Alarm Count: \(String(describing: newReport!.preCOAlarmCount!))"
                
                if self.newReport!.preCOAlarmCount == 0 {
                    cell.date.text = ""
                } else {
                    cell.date.text = "Date of Last Alarm: \(self.newReport!.preCOAlarmLastDate!.as_ddmmyyyy())"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newReport!.preCOAlarmFaultIndicator)
                cell.note.text = getFaultNote(str: newReport!.preCOAlarmFaultIndicator)

                
                
            default:
                print("something went wrong here")
                
                
            }
            
            return cell
            
        } else if tableView == GeneralInfoTableView {
            
            
//            let info1 = AlarmInfoRow(frame: CGRect.zero)
//            info1.lblTitle.text = "Manufacture Details"
//            info1.lblDesc1.text = "Serial Number: \(newReport.deviceSerialNumber)"
//            info1.lblDesc2.text = "Manufacture Date"
//            info1.lblDesc3.text = "Date" // not sure how to work this out yet, back date from the clock, use serial number, or ask the user for it if no db value for it. also install date.
//            infoStack.addArrangedSubview(info1)


            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmInfoCellIdentifier", for: indexPath) as! AlarmInfoCell
            
            switch indexPath.row {
            case 0: // Life Remaining
                
                cell.title.text = "Life Remaining"
    
                
                if self.newReport!.lifeRemainingFaultIndicator == "green" {
                    // device not in final year of life
                    cell.count.text = "\(String(describing: self.newReport!.deviceLifeRemaining_YearsLeft!)) Years Left"
                    cell.note.text = " - "
                    
                } else if self.newReport!.lifeRemainingFaultIndicator == "amber" {
                    // the device is in its final year of life
                    cell.count.text = "\(String(describing: self.newReport!.deviceLifeRemaining_MonthsLeft!)) Months Left"
                    cell.note.text = "This device will need to be replaced soon"
                } else {
                    // the device is in its final 6 months
                    cell.count.text = "\(String(describing: self.newReport!.deviceLifeRemaining_DaysLeft!)) Days Left"
                    cell.note.text = "This device needs to be replaced"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newReport!.lifeRemainingFaultIndicator)
                
                cell.date.text = "Product Expiration Date: \( newReport!.snManufactureExpiaryDate!.as_ddmmyyyy())"
                
                
            case 1: // Plate Removals
                
                cell.title.text = "Device Removals"
                cell.count.text = "Removal Count: \(String(self.newReport!.plateRemovals!))"
                
                if self.newReport!.plateRemovals == 0 {
                    cell.date.text = " - "
                    cell.note.text = "Device has never been removed"
                } else {
                    
                    cell.date.text = "Last Removal Date: \(self.newReport!.lastPlateRemovalDate!.as_ddmmyyyy())"
                    
                    if self.newReport!.plateRemovalsFaultIndicator == "amber" {
                        cell.note.text = "Device has been removed in past year"
                    } else if self.newReport!.plateRemovalsFaultIndicator == "red"{
                        cell.note.text = "Device has been removed in past 6 months"
                    } else {
                        cell.note.text = " - "
                    }
               
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newReport!.plateRemovalsFaultIndicator)
                
            case 2: // Device Test History
                
                cell.title.text = "Device Test"
                cell.count.text = "Test Count: \(self.newReport!.deviceTestCount!)"
                
                if self.newReport!.deviceTestCount == 0 {
                    cell.date.text = " Device never tested"
                } else {
                    cell.date.text = "Last Test Date: \(self.newReport!.deviceLastTestDate!.as_ddmmyyyy())"
                }
                
                cell.FaultIndicator.backgroundColor = getFaultColour(str: newReport!.deviceTestFaultIndicator)
               

                
                if self.newReport?.deviceTestFaultIndicator == "green" {
                    
                    cell.note.text = "Device tested within past week"
                    
                } else if self.newReport?.deviceTestFaultIndicator == "amber" {
                    
                    cell.note.text = "Device has not been tested for more than two weeks"
                    
                } else {
                    
                    cell.note.text = "Device has not been tested for more than a month"
                    
                }
                
                
            default:
                print("something went wrong here")
    
            }
            
            return cell
            
        } else {
            
            
            //        } else if tableView == FaultTableView{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaultInfoCellIdentifier", for: indexPath) as! FaultInfoCell
            
            switch indexPath.row {
            case 0:
                
                cell.title.text = "Battery Fault        \(newReport!.batteryVoltage!)V"
                //cell.count.text = "Alarm Count"

                
                if newReport?.batteryFault == true {
                    cell.date.text = "Last Occured \(newReport!.batteryFaultDate!)"
                    cell.note.text = "Battery Fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0xEA4748)
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0x9EC042)
                }
                
                
            case 1:
                
                cell.title.text = "Device Fault"
                //cell.count.text = "Alarm Count"

                
                if newReport?.deviceFault == true {
                    cell.note.text = "Device Fault"
                    cell.date.text = "Last Occured  \(newReport?.deviceFaultDate)"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0xEA4748)
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No Fault"
                    cell.FaultIndicator.backgroundColor = UIColor(rgb: 0x9EC042)
                }

            case 2:
                
                cell.title.text = "End Of Life Fault"
                // cell.count.text = "Alarm Count"

                
                if newReport?.eol_Fault == true {
                    cell.note.text = "eol_Fault"
                    cell.date.text = "Last Occured \(newReport?.eol_FaultDate)"
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
    


}
