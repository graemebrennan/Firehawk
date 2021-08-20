//
//  AutofillAddressViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import CoreData

class PropertyInformationViewController: UIViewController {
    
    var newPropertyDetails = PropertyDetails()
    
    static func route() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "AutofillAddressViewController") as? PropertyInformationViewController else {
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
        newPropertyDetails.name = inpTitle.tfInput.text
        newPropertyDetails.date = Date()
        newPropertyDetails.line1 = inpAddressLine1.tfInput.text
        newPropertyDetails.line2 = inpAddressLine2.tfInput.text
        newPropertyDetails.postcode = inpZip.tfInput.text
        newPropertyDetails.townCity = inpCityTown.tfInput.text
        
        // change to next screen
        performSegue(withIdentifier: "ReportSetupVCToScanVC", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReportSetupVCToScanVC" {
            
            let scannerVC = segue.destination as! ScannerViewController
            
            scannerVC.newPropertyDetails = self.newPropertyDetails
        }
        
    }
    
    @IBAction func onPressComplete(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
