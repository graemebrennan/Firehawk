//
//  ServiceLocationViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit

class ServiceLocationViewController: UIViewController {
  
    var scan: String?
    
  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "ServiceLocationViewController") as? ServiceLocationViewController else {
      return UIViewController()
    }
    return vc
  }
  
  
    @IBOutlet weak var roomInputField: InputField!
    @IBOutlet weak var nameInputFiled: InputField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    roomInputField.lblTitle.text = "What Room is the device in ?"
    roomInputField.placeholder = "Select room of house"
    
    //    selectFiled.selectedValue = "Bedroom"
    
    nameInputFiled.lblTitle.text = "Device Name"
    nameInputFiled.placeholder = "Enter your Device name here"
  }
  
  @IBAction func onPressContinue(_ sender: Any) {
    //navigationController?.popViewController(animated: true)
    
    performSegue(withIdentifier: "serviceLocationToScan", sender: self)
    
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
