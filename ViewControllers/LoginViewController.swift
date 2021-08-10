//
//  LoginViewController.swift
//  FireHawk
//
//  Created by Graeme Brennan on 25/1/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        // hide error mesage
        errorLabel.alpha = 0
        
        // style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginButtonTapped(_ sender: Any) {
        
        // Validate the fields
        let validateError = validateFields()
        // TODO: Validate Text Filds
        
        if validateError != nil {
            //there is something wrong with the fields
            self.showError(validateError!)
        }
        else {
            
            // Create cleaned versions of the text field
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Sign in the User
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    //Couldnt sign in
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                }
                else {
                    //transition to the home screen
                    self.transitionToHome()
                }
                
            }
        }
        
    }
    
    //Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns he error message
    func validateFields() -> String? {
        
        //Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
          
            return "Please fill in all fields."
        }
    
        return nil
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        
        performSegue(withIdentifier: "loginToHome", sender: self)
        
//        let HomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.HomeViewController) as? HomeViewController
//
//        view.window?.rootViewController = HomeViewController
//        view.window?.makeKeyAndVisible()
    }
}
