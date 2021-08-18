//
//  AutofillAddressViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import CoreData

class AutofillAddressViewController: UIViewController {

    // core data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "AutofillAddressViewController") as? AutofillAddressViewController else {
      return UIViewController()
    }
    return vc
  }
  
 
  @IBOutlet weak var inpTitle: InputField!
  @IBOutlet weak var inpAddressLine1: InputField!
  @IBOutlet weak var inpZip: InputField!
  @IBOutlet weak var inpCityTown: InputField!
  @IBOutlet weak var inpAddressLine2: InputField!
    @IBOutlet weak var NextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inpTitle.lblTitle.text = "Report Title"
        inpTitle.placeholder = "Enter a title for the report"
        
        inpAddressLine1.lblTitle.text = "Address Line 1"
        inpAddressLine1.placeholder = "Enter your street address"
        
        inpAddressLine2.lblTitle.text = "Address Line 2"
        inpAddressLine2.placeholder = "Enter your street address"
        
        inpZip.lblTitle.text = "Post Code"
        inpZip.placeholder = "Enter your Post code"
        
        inpCityTown.lblTitle.text = "City"
        inpCityTown.placeholder = "Enter your City"
        
        setUpElements()
        
    }
    
    func setUpElements() {
        
        // style the elements
        Utilities.styleFilledButton(NextButton)
        
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        // create report
        var newServiceReport = ServiceReportCD(context: self.context)
        newServiceReport.name = inpTitle.tfInput.text
        newServiceReport.date = Date()
        
        var newServiceAddress = AddressCD(context: self.context)
        newServiceAddress.serviceReport = newServiceReport
        newServiceAddress.line1 = inpAddressLine1.tfInput.text
        newServiceAddress.line2 = inpAddressLine2.tfInput.text
        newServiceAddress.postcode = inpZip.tfInput.text
        newServiceAddress.townCity = inpCityTown.tfInput.text

        
        
        // save the date to core
        do {
            try self.context.save()
        }
        catch {
            print("error in storing new service report on core date. ")
        }
        
        // change to next screen
        performSegue(withIdentifier: "ReoprtSetupVCToScanVC", sender: self)
        
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
