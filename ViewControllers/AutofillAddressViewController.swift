//
//  AutofillAddressViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit

class AutofillAddressViewController: UIViewController {

  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "AutofillAddressViewController") as? AutofillAddressViewController else {
      return UIViewController()
    }
    return vc
  }
  
  @IBOutlet weak var scannedCard: ScannedCard!
  @IBOutlet weak var inpName: InputField!
  @IBOutlet weak var inpStreet: InputField!
  @IBOutlet weak var inpZip: InputField!
  @IBOutlet weak var inpCity: InputField!
  @IBOutlet weak var inpCountry: InputField!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      inpName.lblTitle.text = "Apartment Name"
      inpName.placeholder = "Enter your apartment name"
      inpStreet.lblTitle.text = "Street"
      inpStreet.placeholder = "Enter your street address"
      inpZip.lblTitle.text = "Zip Code"
      inpZip.placeholder = "Enter your Zip code"
      inpCity.lblTitle.text = "City"
      inpCity.placeholder = "Enter your City"
      inpCountry.lblTitle.text = "Country"
      inpCountry.placeholder = "Enter your Country"
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
    navigationController?.popViewController(animated: true)
  }
}
