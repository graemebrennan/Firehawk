//
//  DeviceReportViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import Firebase

class DeviceReportViewController: UIViewController {

    var scan: String?
    
    var db = Firestore.firestore()
    
    // Reference to managed core data object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var info9: BoolInputRow?
    var info10: BoolInputRow?
    var info11: BoolInputRow?
    var info12: BoolInputRow?
    var info13: BoolInputRow?
    
    var newReport: DeviceReport?
    
  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "DeviceReportViewController") as? DeviceReportViewController else {
      return UIViewController()
    }
    return vc
  }
    

  
    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var deviceInformationTitle: SectionTitle!
    
    
    @IBOutlet weak var faultsTitle: SectionTitle!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var alarmsTitle: SectionTitle!
    @IBOutlet weak var aditionalInfoTitle: SectionTitle!
    
   // @IBOutlet weak var vHeader: UIView!
    @IBOutlet weak var faultsStack: UIStackView!
    @IBOutlet weak var AdditionalInformationStack: UIStackView!
    @IBOutlet weak var productCard: ProductCard!
    @IBOutlet weak var alarmDataStack: UIStackView!
    
    
    @IBOutlet weak var AdditionalInfo: MultiLineInputField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Unpack the scan data
        
        self.newReport = DeviceReport(scan: scan!)
        
        // Do any additional setup after loading the view.
      lblWarning.text = "Device Health Warning"
      deviceInformationTitle.lblTitle.text = "Device Information"
      faultsTitle.lblTitle.text = "Device Faults"
        alarmsTitle.lblTitle.text = "Alarms"
        aditionalInfoTitle.lblTitle.text = "Additional Information"
        
        AdditionalInfo.lblTitle.text = "Additional Comments"

        // vHeader.roundCorners(corners: [.topLeft, .topRight], radius: 16)
      
        
        
        // fill information
        
        if newReport?.deviceType == "X10" {
            
            SmokeAlarmInformation(newReport: newReport!)

        } else if newReport?.deviceType == "CO" {

            COAlarmInformation(newReport: newReport!)
            
        } else if newReport?.deviceType == "H10"{

            HeatAlarmInformation(newReport: newReport!)

        } else {
            print ("Error, devicetype not recognised")
        }
    }
    
    func COAlarmInformation(newReport: DeviceReport) {
    
        productCard.imgView.image = UIImage(named: "Firehawk_CO7B10Y.png")
        productCard.lblTitle.text = newReport.deviceType
        
        
        // General Info
    let info1 = AlarmInfoRow(frame: CGRect.zero)
    info1.lblTitle.text = "Life Remaining"
    info1.lblDesc1.text = String(format: "%.2f years left", newReport.batteryLifeRemaining_YearsLeft!)
    info1.lblDesc2.text = "Replace by"
    info1.lblDesc3.text = newReport.batteryLifeRemaining_ReplacentDate!.as_ddmmyyyy()
    infoStack.addArrangedSubview(info1)
    
    let info2 = AlarmInfoRow(frame: CGRect.zero)
    info2.lblTitle.text = "Removals From Mounnting Plate"
        info2.lblDesc1.text = String(newReport.plateRemovals!)
    infoStack.addArrangedSubview(info2)
    
    let info3 = AlarmInfoRow(frame: CGRect.zero)
    info3.lblTitle.text = "Device Test"
    info3.lblDesc1.text = "Test Count: \(newReport.deviceTestCount!)"
    info3.lblDesc2.text = "Last Test Date"
    info3.lblDesc3.text = newReport.deviceLastTestDate?.as_ddmmyyyy()
    infoStack.addArrangedSubview(info3)
    
    let info4 = AlarmInfoRow(frame: CGRect.zero)
    info4.lblTitle.text = "Manufacture Details"
    info4.lblDesc1.text = newReport.deviceSerialNumber
    info4.lblDesc2.text = "Manufacture Date"
    info4.lblDesc3.text = "Date" // not sure how to work this out yet, back date from the clock, use serial number, or ask the user for it if no db value for it. also install date.
    infoStack.addArrangedSubview(info4)
    
        // Alarm Stack
        let alarmInfo1 = AlarmInfoRow(frame: CGRect.zero)
        alarmInfo1.lblTitle.text = "High CO Alarm (+300 PPM)"
        alarmInfo1.lblDesc1.text = "Alarm Count: \(String(describing: newReport.highCOAlarmCount!))"
        alarmInfo1.lblDesc2.text = "Last Occured"
        alarmInfo1.lblDesc3.text = newReport.highCOAlarmLastDate?.as_ddmmyyyy()
        alarmDataStack.addArrangedSubview(alarmInfo1)
        
        let alarmInfo2 = AlarmInfoRow(frame: CGRect.zero)
        alarmInfo2.lblTitle.text = "Medium CO Alarm (>100 PPM)"
        alarmInfo2.lblDesc1.text = "Alarm Count: \(String(describing: newReport.mediumCOAlarmCount!))"
        alarmInfo2.lblDesc2.text = "Last Occured"
        alarmInfo2.lblDesc3.text = newReport.mediumCOAlarmLastDate?.as_ddmmyyyy()
        alarmDataStack.addArrangedSubview(alarmInfo2)
        
        let alarmInfo3 = AlarmInfoRow(frame: CGRect.zero)
        alarmInfo3.lblTitle.text = "Low CO Alarm (<100 PPM)"
        alarmInfo3.lblDesc1.text = "Alarm Count: \(String(describing: newReport.lowCOAlarmCount!))"
        alarmInfo3.lblDesc2.text = "Last Occured"
        alarmInfo3.lblDesc3.text = newReport.lowCOAlarmLastDate?.as_ddmmyyyy()
        alarmDataStack.addArrangedSubview(alarmInfo3)
        
        let alarmInfo4 = AlarmInfoRow(frame: CGRect.zero)
        alarmInfo4.lblTitle.text = "Pre Alarms"
        alarmInfo4.lblDesc1.text = "Alarm Count: \(String(describing: newReport.preCOAlarmCount!))"
        alarmInfo4.lblDesc2.text = "Last Occured"
        alarmInfo4.lblDesc3.text = newReport.preCOAlarmLastDate?.as_ddmmyyyy()
        alarmDataStack.addArrangedSubview(alarmInfo4)
        
        let alarmInfo5 = AlarmInfoRow(frame: CGRect.zero)
        alarmInfo5.lblTitle.text = "Background CO"
        alarmInfo5.lblDesc1.text = "\(newReport.backgroundCOLevel!)"
        alarmDataStack.addArrangedSubview(alarmInfo5)
        
        // Faults Stack
        let info5 = AlarmInfoRow(frame: CGRect.zero)
        //info5.lblTitle.textAlignment = .center
        info5.lblTitle.text = "Battery Status"
        info5.lblDesc1.text = "Fault Status"
        info5.lblDesc2.text = "Fault Triggered"
        info5.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info5)
        
        let info6 = AlarmInfoRow(frame: CGRect.zero)
        //info6.lblTitle.textAlignment = .center
        info6.lblTitle.text = "Device Fault"
        info6.lblDesc1.text = "Fault Status"
        info6.lblDesc2.text = "Fault Triggered"
        info6.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info6)
        
        let info7 = AlarmInfoRow(frame: CGRect.zero)
       // info7.lblTitle.textAlignment = .center
        info7.lblTitle.text = "End Of Life Fault"
        info7.lblDesc1.text = "Fault Status"
        info7.lblDesc2.text = "Fault Triggered"
        info7.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info7)
        
        let info8 = AlarmInfoRow(frame: CGRect.zero)
        //info8.lblTitle.textAlignment = .center
        info8.lblTitle.text = "Remote Fault"
        info8.lblDesc1.text = "Fault Status"
        info8.lblDesc2.text = "Fault Triggered"
        info8.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info8)
    
        info9 = BoolInputRow(frame: CGRect.zero)
        info9!.lblTitle.text = "Is the Device in the Correct Location ?"
        AdditionalInformationStack.addArrangedSubview(info9!)
        
        info10 = BoolInputRow(frame: CGRect.zero)
        info10!.lblTitle.text = "Is the Device clear of Furniture ?"
        AdditionalInformationStack.addArrangedSubview(info10!)
        
        info11 = BoolInputRow(frame: CGRect.zero)
        info11!.lblTitle.text = "Did Audio play during the Test ?"
        AdditionalInformationStack.addArrangedSubview(info11!)
        
        info12 = BoolInputRow(frame: CGRect.zero)
        info12!.lblTitle.text = "Is the Device in good Condition ?"
        AdditionalInformationStack.addArrangedSubview(info12!)
        
        info13 = BoolInputRow(frame: CGRect.zero)
        info13!.lblTitle.text = "Does the Device need to be Replaced ?"
        AdditionalInformationStack.addArrangedSubview(info13!)
  }
  
    func SmokeAlarmInformation(newReport: DeviceReport) {
        
        productCard.imgView.image = UIImage(named: "Firehawk_FHB10_smoke_alarm.png")
        productCard.lblTitle.text = newReport.deviceType
        
        // Basic device Information
        let info1 = AlarmInfoRow(frame: CGRect.zero)
        info1.lblTitle.text = "Life Remaining"
        info1.lblDesc1.text = String(format: "%.2f years left", newReport.batteryLifeRemaining_YearsLeft!)
        info1.lblDesc2.text = "Replace by"
        info1.lblDesc3.text = newReport.batteryLifeRemaining_ReplacentDate!.as_ddmmyyyy()
        infoStack.addArrangedSubview(info1)
        
        let info2 = AlarmInfoRow(frame: CGRect.zero)
        info2.lblTitle.text = "Removals From Mounnting Plate"
        info2.lblDesc1.text = String(newReport.plateRemovals!)
        infoStack.addArrangedSubview(info2)
        
        let info3 = AlarmInfoRow(frame: CGRect.zero)
        info3.lblTitle.text = "Device Test"
        info3.lblDesc1.text = "Test Count: \(newReport.deviceTestCount!)"
        info3.lblDesc2.text = "Last Test Date"
        info3.lblDesc3.text = newReport.deviceLastTestDate?.as_ddmmyyyy()
        infoStack.addArrangedSubview(info3)
        
        let info4 = AlarmInfoRow(frame: CGRect.zero)
        info4.lblTitle.text = "Manufacture Details"
        info4.lblDesc1.text = newReport.deviceSerialNumber
        info4.lblDesc2.text = "Manufacture Date"
        info4.lblDesc3.text = "Date" // not sure how to work this out yet, back date from the clock, use serial number, or ask the user for it if no db value for it. also install date.
        infoStack.addArrangedSubview(info4)
        
            //Device Alarm History
            
        
            // Device Faults
            let info5 = AlarmInfoRow(frame: CGRect.zero)
            //info5.lblTitle.textAlignment = .center
            info5.lblTitle.text = "Battery Status"
            info5.lblDesc1.text = "Fault Status"
            info5.lblDesc2.text = "Fault Triggered"
            info5.lblDesc3.text = "Date"
            faultsStack.addArrangedSubview(info5)
            
            let info6 = AlarmInfoRow(frame: CGRect.zero)
            //info6.lblTitle.textAlignment = .center
            info6.lblTitle.text = "Device Fault"
            info6.lblDesc1.text = "Fault Status"
            info6.lblDesc2.text = "Fault Triggered"
            info6.lblDesc3.text = "Date"
            faultsStack.addArrangedSubview(info6)
            
            let info7 = AlarmInfoRow(frame: CGRect.zero)
           // info7.lblTitle.textAlignment = .center
            info7.lblTitle.text = "End Of Life Fault"
            info7.lblDesc1.text = "Fault Status"
            info7.lblDesc2.text = "Fault Triggered"
            info7.lblDesc3.text = "Date"
            faultsStack.addArrangedSubview(info7)
            
            let info8 = AlarmInfoRow(frame: CGRect.zero)
            //info8.lblTitle.textAlignment = .center
            info8.lblTitle.text = "Remote Fault"
            info8.lblDesc1.text = "Fault Status"
            info8.lblDesc2.text = "Fault Triggered"
            info8.lblDesc3.text = "Date"
            faultsStack.addArrangedSubview(info8)
        
            // Device Questions
        info9 = BoolInputRow(frame: CGRect.zero)
        info9!.lblTitle.text = "Is the Device in the Correct Location ?"
        AdditionalInformationStack.addArrangedSubview(info9!)
        
        info10 = BoolInputRow(frame: CGRect.zero)
        info10!.lblTitle.text = "Is the Device clear of Furniture ?"
        AdditionalInformationStack.addArrangedSubview(info10!)
        
        info11 = BoolInputRow(frame: CGRect.zero)
        info11!.lblTitle.text = "Did Audio play during the Test ?"
        AdditionalInformationStack.addArrangedSubview(info11!)
        
        info12 = BoolInputRow(frame: CGRect.zero)
        info12!.lblTitle.text = "Is the Device in good Condition ?"
        AdditionalInformationStack.addArrangedSubview(info12!)
        
        info13 = BoolInputRow(frame: CGRect.zero)
        info13!.lblTitle.text = "Does the Device need to be Replaced ?"
        AdditionalInformationStack.addArrangedSubview(info13!)
        
        
  }
  
  func HeatAlarmInformation(newReport: DeviceReport) {
    
    productCard.imgView.image = UIImage(named: "Firehawk_FHH10_heat_alarm.png")
    productCard.lblTitle.text = newReport.deviceType
    
    let info1 = AlarmInfoRow(frame: CGRect.zero)
    info1.lblTitle.text = "Life Remaining"
    info1.lblDesc1.text = String(format: "%.2f years left", newReport.batteryLifeRemaining_YearsLeft!)
    info1.lblDesc2.text = "Replace by"
    info1.lblDesc3.text = newReport.batteryLifeRemaining_ReplacentDate!.as_ddmmyyyy()
    infoStack.addArrangedSubview(info1)
    
    let info2 = AlarmInfoRow(frame: CGRect.zero)
    info2.lblTitle.text = "Removals From Mounnting Plate"
        info2.lblDesc1.text = String(newReport.plateRemovals!)
    infoStack.addArrangedSubview(info2)
    
    let info3 = AlarmInfoRow(frame: CGRect.zero)
    info3.lblTitle.text = "Device Test"
    info3.lblDesc1.text = "Test Count: \(newReport.deviceTestCount!)"
    info3.lblDesc2.text = "Last Test Date"
    info3.lblDesc3.text = newReport.deviceLastTestDate?.as_ddmmyyyy()
    infoStack.addArrangedSubview(info3)
    
    let info4 = AlarmInfoRow(frame: CGRect.zero)
    info4.lblTitle.text = "Manufacture Details"
    info4.lblDesc1.text = newReport.deviceSerialNumber
    info4.lblDesc2.text = "Manufacture Date"
    info4.lblDesc3.text = "Date" // not sure how to work this out yet, back date from the clock, use serial number, or ask the user for it if no db value for it. also install date.
    infoStack.addArrangedSubview(info4)
    
        
        let info5 = AlarmInfoRow(frame: CGRect.zero)
        //info5.lblTitle.textAlignment = .center
        info5.lblTitle.text = "Battery Status"
        info5.lblDesc1.text = "Fault Status"
        info5.lblDesc2.text = "Fault Triggered"
        info5.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info5)
        
        let info6 = AlarmInfoRow(frame: CGRect.zero)
        //info6.lblTitle.textAlignment = .center
        info6.lblTitle.text = "Device Fault"
        info6.lblDesc1.text = "Fault Status"
        info6.lblDesc2.text = "Fault Triggered"
        info6.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info6)
        
        let info7 = AlarmInfoRow(frame: CGRect.zero)
       // info7.lblTitle.textAlignment = .center
        info7.lblTitle.text = "End Of Life Fault"
        info7.lblDesc1.text = "Fault Status"
        info7.lblDesc2.text = "Fault Triggered"
        info7.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info7)
        
        let info8 = AlarmInfoRow(frame: CGRect.zero)
        //info8.lblTitle.textAlignment = .center
        info8.lblTitle.text = "Remote Fault"
        info8.lblDesc1.text = "Fault Status"
        info8.lblDesc2.text = "Fault Triggered"
        info8.lblDesc3.text = "Date"
        faultsStack.addArrangedSubview(info8)
    
    info9 = BoolInputRow(frame: CGRect.zero)
    info9!.lblTitle.text = "Is the Device in the Correct Location ?"
    AdditionalInformationStack.addArrangedSubview(info9!)
    
    info10 = BoolInputRow(frame: CGRect.zero)
    info10!.lblTitle.text = "Is the Device clear of Furniture ?"
    AdditionalInformationStack.addArrangedSubview(info10!)
    
    info11 = BoolInputRow(frame: CGRect.zero)
    info11!.lblTitle.text = "Did Audio play during the Test ?"
    AdditionalInformationStack.addArrangedSubview(info11!)
    
    info12 = BoolInputRow(frame: CGRect.zero)
    info12!.lblTitle.text = "Is the Device in good Condition ?"
    AdditionalInformationStack.addArrangedSubview(info12!)
    
    info13 = BoolInputRow(frame: CGRect.zero)
    info13!.lblTitle.text = "Does the Device need to be Replaced ?"
    AdditionalInformationStack.addArrangedSubview(info13!)
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
  @IBAction func onPressComplete(_ sender: Any) {
    
    // read aditional comments input
    
    // save on database here,
    
    // Add a new document with a generated ID
    var ref: DocumentReference? = nil
    
    if let reportScan = scan, let reportUser =
        Auth.auth().currentUser?.email {
        
        ref = db.collection(K.FStore.collectionName).addDocument(data: [
            K.FStore.senderField: reportUser,
            K.FStore.scanField: reportScan
            
        ]) { (error) in
            if let e = error {
                print("There was an issue saving data to Firestore, \(e)")
            } else {
                print("Sucessfully saved data to Firestore")
            }
        }
        
    }
    
    navigationController?.popViewController(animated: true)
  }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        
        // add the report to the database here then segue to the main menue, the refference for the bellow code with alert was from code with chris
        // https://www.youtube.com/watch?v=O7u9nYWjvKk
        
        // Create alert
        let alert = UIAlertController(title: "Report Title", message: "please enter a title for the device report", preferredStyle: .alert)
        alert.addTextField()
        
        // Configure button handler
        let submitButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            // Get the textfield for the alert
            let textfield = alert.textFields![0]
            
            // Create a person object
            let newRep = DeviceReportCD(context: self.context)
            newRep.scan = self.scan
            newRep.title = textfield.text
            newRep.date = Date()
            newRep.deviceType = self.newReport?.deviceType
            newRep.serialNumber = self.newReport?.deviceSerialNumber
            
            

            //get switch positions and add to core data module
            newRep.q1 = self.info9!.scPosition.isOn
            newRep.q2 = self.info10!.scPosition.isOn
            newRep.q3 = self.info11!.scPosition.isOn
            newRep.q4 = self.info12!.scPosition.isOn
            newRep.q5 = self.info13!.scPosition.isOn
            
            newRep.note = self.AdditionalInfo.tfInput.text
            
            // save the data to core data db
            do {
                try self.context.save()
            } catch {
                print("error saving data")
            }
            
            self.moveToMainScreen()

            
        }
        
        // Add button
        alert.addAction(submitButton)
        
        // show alert
        self.present(alert, animated: true, completion: nil)
        

        
    }
    
    func moveToMainScreen() {
        
        // perform segue to main
        performSegue(withIdentifier: "DeviceReportToMain", sender: self)
    }
    
    
}
