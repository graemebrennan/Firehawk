//
//  BarCodeScanViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit

class BarCodeScanViewController: UIViewController {
  
    let fs = fakeScan()
    var newScan: String?
    
  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "BarCodeScanViewController") as? BarCodeScanViewController else {
      return UIViewController()
    }
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  
  @IBAction func onPressScan(_ sender: Any) {
    //navigationController?.popViewController(animated: true)
    
    // generate random scan
    let randomNumber = Int.random(in: 0...9)
    newScan = fs.ArrayOfScans[randomNumber]
    print(newScan)
    
    // begin scan process here
    
    // Check Scan is Vald
    
    // Scan Complete
    
    performSegue(withIdentifier: "scanToDeviceReport", sender: self)
  }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let deviceReportVC = segue.destination as! DeviceReportViewController
        
        deviceReportVC.scan = newScan
    }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
  
    

