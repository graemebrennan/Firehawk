//
//  OpenViewController.swift
//  FireHawk
//
//  Created by Graeme Brennan on 3/2/21.
//

import UIKit

class OpenViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpElements()
    }
 
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    func setUpElements() {

        // style the elements
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(signUpButton)
    }
}
