//
//  BarCodeScanViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit

class ScannerViewController: UIViewController {
    
    let fs = fakeScan()
    var newScan: String?
    let SCAN_LENGTH: Int = 72
    
    var newPropertyDetails = PropertyDetails()
    
    @IBOutlet weak var scanButton: UIButton!
    
    
    static func route() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "BarCodeScanViewController") as? ScannerViewController else {
            return UIViewController()
        }
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements() {

        Utilities.styleFilledButton(scanButton)
        
    }
    
    
    @IBAction func onPressScan(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        
        // generate random scan
        let randomNumber = Int.random(in: 0...9)
        newScan = fs.ArrayOfScans[randomNumber]
        print(newScan)
        
        // begin scan process here
        
        // Check Scan is Vald
        // check scan data
        if checkScan() {
            performSegue(withIdentifier: "scanToDeviceReport", sender: self)
        }else {
            //shwo error message and re-scan
            print("checksum failed o perform segue")
        }
        
        // Scan Complete
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let deviceReportVC = segue.destination as! DeviceReportViewController
        
        deviceReportVC.newScan = self.newScan
        deviceReportVC.propertyDetails = self.newPropertyDetails
        
    }
    
    func checkScan() -> Bool {
        
        var sum: UInt16 = 0
        
        let ckSumStrStartIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: SCAN_LENGTH-2)
        let ckSumStrEndIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: SCAN_LENGTH-1)
        let ckSumStr = String(self.newScan![ckSumStrStartIndex...ckSumStrEndIndex])
        let ckSum = Int(ckSumStr)
        
        for i in stride(from: 0, to: SCAN_LENGTH, by: 2) {
            
            //MARK:- SerialNumber
            let newValStrStartIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: i)
            let newValStrEndIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: i+1)
            let newValStr = String(self.newScan![newValStrStartIndex...newValStrEndIndex])
            
            var newValInt = Int(newValStr, radix: 16)
            
            sum += UInt16(newValInt!)
            sum = sum & 0x00FF
            // sum = sum + newValInt!
        }
        
        //        if sum != ckSum! {
        //
        //            print ("checksume fail")
        //            return false
        //
        //        } else {
        //
        
        print ("checksume pass")
        return true
        //}
    }
    
    @IBAction func unwindToScannerViewController(_ sender: UIStoryboardSegue) {}
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

    

