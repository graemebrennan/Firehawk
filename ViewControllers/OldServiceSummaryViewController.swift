//
//  ReportSummaryViewController.swift
//  FireHawk
//
//  Created by Graeme Brennan on 5/7/21.
//

import UIKit
import CoreData
import MessageUI
import PDFKit

class OldServiceSummaryViewController: UIViewController {
    
    
    //coredata
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //var serviceReports: [ServiceReportCD]? = []
    var latestRecord: ServiceReportCD?
    var deviceReportList: [DeviceReportCD]? = []
    
    var serviceReport: ServiceReportCD?
    var selectedDeviceReport: DeviceReportCD?
    
    @IBOutlet weak var tableView: UITableView!
    
    var pdfDocument: PDFDocument!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "DeviceCellIdentifier")
        
        
        
        if let allDeviceReports = serviceReport?.deviceReports?.allObjects as? [DeviceReportCD] {
            self.deviceReportList = allDeviceReports
        }
        
    }
    
    
    @IBAction func sendEmailPressed(_ sender: Any) {
        
        print("Send Email")
        
        print("compose Email")
        composeEmail()
        
    }
    
    func composeEmail() {
        
        // build title page
        composeCoverPagePDF()
        
        print("creating new PDF \(Int(deviceReportList?.count ?? 0))pages")
        
        for i in 0...deviceReportList!.count-1 {
            // creat and insert a new pdf page for each device
            composeDevicePagePDF(i: i)
            
        }
        
        //self.pdfDocument
        showMailComposer()
        self.serviceReport?.houseAddress?.line1
    }
    
    func composeCoverPagePDF() {
        
        let pdfTitle = self.serviceReport?.name
        let pdfBody = """
                    
                        Property Address:
                            Line 1:   \(self.serviceReport?.houseAddress?.line1 ?? "Unknown")
                            Line 2:   \(self.serviceReport?.houseAddress?.line2 ?? "Unknown")
                            City:     \(self.serviceReport?.houseAddress?.townCity ?? "Unknown")
                            Postcode: \(self.serviceReport?.houseAddress?.postcode ?? " Unknown")
                    
                        Report Date:\
                        \(self.dateFormat(date: (self.serviceReport?.date)!) )
                    """
        let pdfHeaderImage = UIImage(named: "Logo")
        
        let pdfCreator = PDFCoverCreator(title: pdfTitle!, body: pdfBody, image: pdfHeaderImage!)
        
        let data = pdfCreator.createPDFReport()
        
        self.pdfDocument = PDFDocument(data: data)
        
    }
    
    func composeDevicePagePDF(i: Int) {
        
        let pdfTitle = self.serviceReport?.name
        let pdfBody = pdfDeviceBody(i: i)
        let pdfHeaderImage = UIImage(named: "ReportHeader")
        // let pdfContact = "contactTextView.text"
        
        
        let pdfCreator = PDFCreator(title: pdfTitle!, body: pdfBody, image: pdfHeaderImage!)
        
        
        
        
        let data = pdfCreator.createPDFReport()
        
        //self.pdfDocument = PDFDocument(data: data)
        let newPage = PDFDocument(data: data)
        let page = newPage?.page(at: 0)
        
        self.pdfDocument.insert(page!, at: i+1 )
        
        //let newPage = PDFPage()
        
        
        
        //return data
    }
    
    func pdfDeviceBody(i: Int) -> String {
        
        var bodyString = ""
        
        // unpack the devie scan data
        var deviceScanData = ScanAnalysis(scan: self.deviceReportList![i].scan!)
        
        //TODO:- need to check for nil dates before trying to use them in the report. this is causig a crash if no date is available.
        var string = """
                \(deviceReportList![i].title!)
                -----------------------------------------------------------------
                Device Information
                -----------------------------------------------------------------
                Device Type: \(deviceReportList![i].deviceType!)
                
                Serial Number: \(deviceReportList![i].serialNumber!)
                Report Date: \( dateFormat(date: deviceReportList![i].date!) )
                
                Device Health Status: \(deviceReportList![i].healthIndicator!)
                Life Remaining: \(deviceScanData.batteryLifeRemaining_YearsLeft!)
                Replace By: \(deviceScanData.deviceReplacentDate!)
                
                Removals From Mounting Plate: \(deviceScanData.plateRemovals!)
                
                Device Tests:
                Device Test Count: \(deviceScanData.deviceTestCount!)
                Last Test Date: \(deviceScanData.deviceLastTestDate!)
                
                Manufacture Details
                Serial Number: \(deviceScanData.deviceSerialNumber!)
                Manufacture Date: \(deviceScanData.snManufactureDate!)
                -----------------------------------------------------------------
                Alarms
                -----------------------------------------------------------------
                High CO Alarm (+300 PPM)
                High Alarm Count: \(String(describing: deviceScanData.highCOAlarmCount!))
                Last Occured: \( dateFormat(date: deviceScanData.highCOAlarmLastDate!) )
                
                Medium CO Alarm (>100 PPM)
                Medium Alarm Count: \(String(describing: deviceScanData.mediumCOAlarmCount!))
                Last Occured: \(dateFormat(date:deviceScanData.mediumCOAlarmLastDate!))
                
                Low CO Alarm (<100 PPM)
                Low Alarm Count: \(String(describing: deviceScanData.lowCOAlarmCount!))
                Last Occured: \(dateFormat(date:deviceScanData.lowCOAlarmLastDate!))
                
                Pre Alarm
                Pre Alarm Count: \(String(describing: deviceScanData.preCOAlarmCount!))
                Last Occured: \(dateFormat(date: deviceScanData.preCOAlarmLastDate!))
                -----------------------------------------------------------------
                Faults
                -----------------------------------------------------------------
                Fault Status: \(String(describing:deviceScanData.faultFlag))
                
                Device Faults: \(String(describing:deviceScanData.deviceFault))
                Date: \(dateFormat(date: deviceScanData.deviceFaultDate!))
                
                Battery Fault: \(String(describing:deviceScanData.batteryFault))
                Date: \(dateFormat(date:deviceScanData.batteryFaultDate!))
                
                Remote Faults: \(String(describing:deviceScanData.remoteFault))
                Date: \(dateFormat(date:deviceScanData.remoteFaultDate!))
                
                End Of Life: \(String(describing:deviceScanData.eol_Fault))
                Date: \(dateFormat(date:deviceScanData.eol_FaultDate!))
                -----------------------------------------------------------------
                Comments
                -----------------------------------------------------------------
                \(String(describing:deviceReportList![i].note))
                
                -----------------------------------------------------------------
                """
        bodyString.append(string)
        
        return bodyString
    }
    
    
//    func getDateText(date: Date) -> String {
//        
//        var str = "No date value"
//        
//        if date != nil {
//            str = dateFormat(date:deviceScanData.lowCOAlarmLastDate!
//        }
//        
//        return str
//    }
    
    
    func showMailComposer() {
        
        print("creating Email")
        
        guard MFMailComposeViewController.canSendMail() else {
            // TODO:- Show alert informing the user
            print("Mail services are not available")
            return
        }
        
        // send email of PDF
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([""])
        composeVC.setSubject("Firehawk Service Report")
        composeVC.setMessageBody("", isHTML: true)
        
        //Attach pdf
        composeVC.addAttachmentData(self.pdfDocument.dataRepresentation()! as Data, mimeType: "pdf" , fileName: "FireHawkServiceReport.pdf")
        
        self.present(composeVC, animated: true, completion: nil)
    }
}

extension OldServiceSummaryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.deviceReportList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCellIdentifier", for: indexPath) as! DeviceCell
        
        cell.lblName.text = self.deviceReportList?[indexPath.row].title
        cell.lblSerialNumber.text = self.deviceReportList?[indexPath.row].serialNumber
        cell.lblDate.text =  "Date: \(dateFormat(date: (self.deviceReportList?[indexPath.row].date!)!) ?? "Unknown")"
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
    
}

extension OldServiceSummaryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get selected report.
        self.selectedDeviceReport = self.deviceReportList![indexPath.row]
        
        //self.i = indexPath.row
        performSegue(withIdentifier: "ReportSummaryVCtoReportVC", sender: self)
        
        print( " pressed selected row \(indexPath.row) ")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ReportSummaryVCtoReportVC" {
            
            var deviceReportVC = segue.destination as! ReportViewController
            
            //ReportVC.scan = self.items![i].scan
            deviceReportVC.deviceReport = self.selectedDeviceReport
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
}


extension OldServiceSummaryViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed to send")
        case .saved:
            print("Saved")
        case .sent:
            print("Email Sent")
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true)
    }
    
    func dateFormat(date: Date) -> String {

        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short//"dd/mm/yyyy"
        
        
        let str = formatter1.string(from: date)
        return str
    }
}

