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

    var newScan: String?
    
    //coredata
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var serviceReports: [ServiceReportCD]? = []
    var latestRecord: ServiceReportCD?
    var newReport: DeviceReport?
    
    
  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "DeviceReportViewController") as? DeviceReportViewController else {
      return UIViewController()
    }
    return vc
  }
    

  
    @IBOutlet weak var healthWarning: UILabel!

    @IBOutlet weak var deviceInformationTitle: SectionTitle!
    
    //@IBOutlet var view: UIView!
    
    @IBOutlet weak var faultsTitle: SectionTitle!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var alarmsTitle: SectionTitle!
    @IBOutlet weak var aditionalInfoTitle: SectionTitle!
    
    @IBOutlet weak var AlarmsTableView: UITableView!
    @IBOutlet weak var FaultTableView: UITableView!
    
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
       
        FaultTableView.delegate = self
        FaultTableView.dataSource = self
        // Do any additional setup after loading the view.
        AlarmsTableView.register(UINib(nibName: "AlarmInfoCell", bundle: nil), forCellReuseIdentifier: "AlarmInfoCellIdentifier")
       
        FaultTableView.register(UINib(nibName: "FaultInfoCell", bundle: nil), forCellReuseIdentifier: "FaultInfoCellIdentifier")
        
        // Unpack the scan data
        
        self.newReport = DeviceReport(scan: newScan!)
        
        // Do any additional setup after loading the view.
        healthWarning.text = "Device Health Warning"
        
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
        
        let info1 = AlarmInfoRow(frame: CGRect.zero)
        info1.lblTitle.text = "Manufacture Details"
        info1.lblDesc1.text = "Serial Number: \(newReport.deviceSerialNumber)"
        info1.lblDesc2.text = "Manufacture Date"
        info1.lblDesc3.text = "Date" // not sure how to work this out yet, back date from the clock, use serial number, or ask the user for it if no db value for it. also install date.
        infoStack.addArrangedSubview(info1)
        
        let info2 = AlarmInfoRow(frame: CGRect.zero)
        info2.lblTitle.text = "Life Remaining"
        info2.lblDesc1.text = String(format: "%.1f years remaining", newReport.batteryLifeRemaining_YearsLeft!) // + Months left and remove decimal point
        info2.lblDesc2.text = "Replacement Date: \(newReport.batteryLifeRemaining_ReplacentDate!.as_ddmmyyyy())"
        info2.lblDesc3.text = "need to re structure this field tyoe"
        infoStack.addArrangedSubview(info2)
        
        let info3 = AlarmInfoRow(frame: CGRect.zero)
        info3.lblTitle.text = "Removals From Mounnting Plate"
        info3.lblDesc1.text = String(newReport.plateRemovals!)
        info3.lblDesc2.text = "Last Removal Date: \(newReport.lastPlateRemovalDate!.as_ddmmyyyy())"
        info3.lblDesc3.text = "Last Removal Fault Note"
        infoStack.addArrangedSubview(info3)
        
        let info4 = AlarmInfoRow(frame: CGRect.zero)
        info4.lblTitle.text = "Device Test"
        info4.lblDesc1.text = "Test Count: \(newReport.deviceTestCount!)"
        info4.lblDesc2.text = "Last Test Date: \(newReport.deviceLastTestDate?.as_ddmmyyyy())"
        info4.lblDesc3.text = "Last Test notes" // creat fault note functions
        infoStack.addArrangedSubview(info4)
        
        

//        // Faults Stack
//        let info5 = AlarmInfoRow(frame: CGRect.zero)
//        //info5.lblTitle.textAlignment = .center
//        info5.lblTitle.text = "Battery Status"
//        info5.lblDesc1.text = "Fault Status"
//        info5.lblDesc2.text = "Last Fault Date: "
//        info5.lblDesc3.text = "Fault Note"
//        faultsStack.addArrangedSubview(info5)
//
//        let info6 = AlarmInfoRow(frame: CGRect.zero)
//        //info6.lblTitle.textAlignment = .center
//        info6.lblTitle.text = "Device Fault"
//        info6.lblDesc1.text = "Fault Status"
//        info6.lblDesc2.text = "Fault Triggered"
//        info6.lblDesc3.text = "Date"
//        faultsStack.addArrangedSubview(info6)
//
//        let info7 = AlarmInfoRow(frame: CGRect.zero)
//       // info7.lblTitle.textAlignment = .center
//        info7.lblTitle.text = "End Of Life Fault"
//        info7.lblDesc1.text = "Fault Status"
//        info7.lblDesc2.text = "Fault Triggered"
//        info7.lblDesc3.text = "Date"
//        faultsStack.addArrangedSubview(info7)
//
//        let info8 = AlarmInfoRow(frame: CGRect.zero)
//        //info8.lblTitle.textAlignment = .center
//        info8.lblTitle.text = "Remote Fault"
//        info8.lblDesc1.text = "Fault Status"
//        info8.lblDesc2.text = "Fault Triggered"
//        info8.lblDesc3.text = "Date"
//        faultsStack.addArrangedSubview(info8)
    
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
            let newRep = DeviceReportCD(context: self.context)
            newRep.scan = self.newScan
            newRep.title = textfield.text
            newRep.date = Date()
            newRep.deviceType = self.newReport?.deviceType
            newRep.serialNumber = self.newReport?.deviceSerialNumber
            newRep.note = self.commentsTV.text
            
            // get latest report
            self.fetchLatestServiceReport()
            
            newRep.serviceReport = self.latestRecord
            
            // save the data to core data db
            do {
                try self.context.save()
            } catch {
                print("error saving data")
            }
            
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
    
    // fetch the service report from core data, how
    func fetchServiceReport() {
        
        // fetch all the ServiceReports in core data
        do {
            
            let request : NSFetchRequest<ServiceReportCD> = ServiceReportCD.fetchRequest()
            
            //request.setFetchLimit
            // set the filtering and sorting on the request
            //                    let pred = NSPredicate(format: "nameContains 'Ted'")
            //                    request.predicate = pred
            
            
            self.serviceReports = try context.fetch(request)
            // tableView.reloadData()
            print("servicereports count = ")
            print(serviceReports!.count)
        }
        catch {
            
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
                cell.date.text = "Date of Last Alarm: \(self.newReport!.highCOAlarmLastDate!.as_ddmmyyyy())"
                
                self.newReport!.highCOAlarmLastDate!.as_ddmmyyyy()
                if 
                    cell.note.text = ""
                
                
            case 1: // Medium Co Alarm +300PPM
                
                cell.title.text = "Medium CO Alarm (>100 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newReport?.mediumCOAlarmCount!))"
                cell.date.text = "Date of Last Alarm: \(self.newReport?.mediumCOAlarmLastDate?.as_ddmmyyyy())"
                cell.note.text = self.newReport?.mediumCOAlarmLastDate?.as_ddmmyyyy()
                
            case 2: // Low Co Alarm +300PPM
                
                cell.title.text = "Low CO Alarm (<100 PPM)"
                cell.count.text = "Alarm Count: \(String(describing: self.newReport?.lowCOAlarmCount!))"
                cell.date.text = "Date of Last Alarm: \(self.newReport?.lowCOAlarmLastDate?.as_ddmmyyyy())"
                cell.note.text = "health warning note"
                
                
            case 3: // Pre Alarm
                
                cell.title.text = "Pre Alarms"
                cell.count.text = "Alarm Count: \(String(describing: newReport?.preCOAlarmCount!))"
                cell.date.text = "Last Occured: \(newReport?.preCOAlarmLastDate?.as_ddmmyyyy())"
                cell.note.text = newReport?.preCOAlarmLastDate?.as_ddmmyyyy()
                
                
            default:
                print("something went wrong here")
                
                
            }
            
            return cell
            
        } else {
            
            //        } else if tableView == FaultTableView{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaultInfoCellIdentifier", for: indexPath) as! FaultInfoCell
            
            switch indexPath.row {
            case 0:
                
                cell.title.text = "Battery Fault Active"
                //cell.count.text = "Alarm Count"

                
                if newReport?.batteryFault == true {
                    cell.note.text = "Battery Fault"
                    cell.date.text = "Last Occured \(newReport?.batteryFaultDate)"
                    cell.FaultIndicator.backgroundColor = .red
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No Fault"
                    cell.FaultIndicator.backgroundColor = .green
                }
                
                
            case 1:
                
                cell.title.text = "Device"
                //cell.count.text = "Alarm Count"

                
                if newReport?.deviceFault == true {
                    cell.note.text = "Device Fault"
                    cell.date.text = "Last Occured  \(newReport?.deviceFaultDate)"
                    cell.FaultIndicator.backgroundColor = .red
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No Fault"
                    cell.FaultIndicator.backgroundColor = .green
                }

            case 2:
                
                cell.title.text = "End Of Life"
                // cell.count.text = "Alarm Count"

                
                if newReport?.eol_Fault == true {
                    cell.note.text = "eol_Fault"
                    cell.date.text = "Last Occured \(newReport?.eol_FaultDate)"
                    cell.FaultIndicator.backgroundColor = .red
                } else {
                    cell.date.text = " - "
                    cell.note.text = "No Fault"
                    cell.FaultIndicator.backgroundColor = .green
                }
                
//            case 3:
//
//                cell.title.text = "Remote"
//                //cell.count.text = "Alarm Count"
//                cell.date.text = "Last Occured \(newReport?.remoteFault)"
//                cell.note.text = "jsbsjcb"
                
            default:
                print("Something went wrong")
                
            }
            return cell
        }
        
        
    }
    

        
        // fill device nib property fields
        //        cell.title.text = self.deviceReportList?[indexPath.row].title
        //        cell.date.text =  self.deviceReportList?[indexPath.row].date?.as_ddmmyyyy_hhmmss()
        //        cell.count.text = self.deviceReportList?[indexPath.row].serialNumber
        //        cell.note.text = self.deviceReportList?[indexPath.row].serialNumber
        // add device image

        
    

}
