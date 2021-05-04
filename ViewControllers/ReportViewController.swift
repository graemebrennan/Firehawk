//
//  ReportStatusViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit

class ReportViewController: UIViewController {
  
    var scan: String?
    var rep: DeviceReportCD?
    var newReport: DeviceReport?
    
    var info9: BoolInputRow?
    var info10: BoolInputRow?
    var info11: BoolInputRow?
    var info12: BoolInputRow?
    var info13: BoolInputRow?
    
      @IBOutlet weak var lblWarning: UILabel!
      @IBOutlet weak var deviceInformationTitle: SectionTitle!
      
      
      @IBOutlet weak var faultsTitle: SectionTitle!
      @IBOutlet weak var infoStack: UIStackView!
      @IBOutlet weak var alarmsTitle: SectionTitle!
      @IBOutlet weak var aditionalInfoTitle: SectionTitle!
      
     // @IBOutlet weak var vHeader: UIView!
    
      @IBOutlet weak var productCard: ProductCard!
      @IBOutlet weak var alarmDataStack: UIStackView!
      
    @IBOutlet weak var faultsStack: UIStackView!
    
    
    // Question labels
    @IBOutlet weak var lblQ1: UILabel!
    @IBOutlet weak var lblQ2: UILabel!
    @IBOutlet weak var lblQ3: UILabel!
    @IBOutlet weak var lblQ4: UILabel!
    @IBOutlet weak var lblQ5: UILabel!
    
      
      @IBOutlet weak var AdditionalInfo: MultiLineInputField!
    

    
    static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "ReportStatusViewController") as? ReportViewController else {
      return UIViewController()
    }
    return vc
  }
  
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
    AdditionalInfo.tfInput.text = rep?.note
    // TODO: add ditional notes in text field of report.
    // AdditionalInfo.tfInput.text = rep.note
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
    let reportDate = self.rep!.date!.as_ddmmyyyy_hhmmss()
    productCard.lblNote.text = "Report Date: \(String(describing: reportDate))"
    
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


    // add text the report labels 
    if rep!.q1 == true {
        lblQ1.text = "The Device is in the Correct Location"
        lblQ1.textColor = .green
    } else {
        lblQ1.text = "The Device Is not in the Correct Location"
        lblQ1.textColor = .red
    }
    
    if rep!.q2 == true {
        lblQ2.text = "The Device is clear of furniture"
        lblQ2.textColor = .green
    } else {
        lblQ2.text = "The Device is blocked by furniture"
        lblQ2.textColor = .red
    }
    
    if rep!.q3 == true {
        lblQ3.text = "Audio did play during the Test"
        lblQ3.textColor = .green
    } else {
        lblQ3.text = "Audio did not play during the Test"
        lblQ3.textColor = .red
    }
    
    if rep!.q4 == true {
        lblQ4.text = "The Device appears in good condition"
        lblQ4.textColor = .green
    } else {
        lblQ4.text = "The Device appears in bad condition"
        lblQ4.textColor = .red
    }
    
    if rep!.q5 == true {
        lblQ5.text = "The Device dose not need to be replaced"
        lblQ5.textColor = .green
    } else {
        lblQ5.text = "The Device Needs to Be replaced"
        lblQ5.textColor = .red
    }
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
    
    // add text the report labels
    if rep!.q1 == true {
        lblQ1.text = "The Device is in the Correct Location"
        lblQ1.textColor = .green
    } else {
        lblQ1.text = "The Device Is not in the Correct Location"
        lblQ1.textColor = .red
    }
    
    if rep!.q2 == true {
        lblQ2.text = "The Device is clear of furniture"
        lblQ2.textColor = .green
    } else {
        lblQ2.text = "The Device is blocked by furniture"
        lblQ2.textColor = .red
    }
    
    if rep!.q3 == true {
        lblQ3.text = "Audio did play during the Test"
        lblQ3.textColor = .green
    } else {
        lblQ3.text = "Audio did not play during the Test"
        lblQ3.textColor = .red
    }
    
    if rep!.q4 == true {
        lblQ4.text = "The Device appears in good condition"
        lblQ4.textColor = .green
    } else {
        lblQ4.text = "The Device appears in bad condition"
        lblQ4.textColor = .red
    }
    
    if rep!.q5 == true {
        lblQ5.text = "The Device dose not need to be replaced"
        lblQ5.textColor = .green
    } else {
        lblQ5.text = "The Device Needs to Be replaced"
        lblQ5.textColor = .red
    }
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

    // add text the report labels
    if rep!.q1 == true {
        lblQ1.text = "The Device is in the Correct Location"
        lblQ1.textColor = .green
    } else {
        lblQ1.text = "The Device Is not in the Correct Location"
        lblQ1.textColor = .red
    }
    
    if rep!.q2 == true {
        lblQ2.text = "The Device is clear of furniture"
        lblQ2.textColor = .green
    } else {
        lblQ2.text = "The Device is blocked by furniture"
        lblQ2.textColor = .red
    }
    
    if rep!.q3 == true {
        lblQ3.text = "Audio did play during the Test"
        lblQ3.textColor = .green
    } else {
        lblQ3.text = "Audio did not play during the Test"
        lblQ3.textColor = .red
    }
    
    if rep!.q4 == true {
        lblQ4.text = "The Device appears in good condition"
        lblQ4.textColor = .green
    } else {
        lblQ4.text = "The Device appears in bad condition"
        lblQ4.textColor = .red
    }
    
    if rep!.q5 == true {
        lblQ5.text = "The Device dose not need to be replaced"
        lblQ5.textColor = .green
    } else {
        lblQ5.text = "The Device Needs to Be replaced"
        lblQ5.textColor = .red
    }
}
}
