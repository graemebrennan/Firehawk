//
//  SignUpViewController.swift
//  FireHawk
//
//  Created by Graeme Brennan on 25/1/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore


class SignUpViewController: UIViewController {


    @IBOutlet weak var firstNameIF: InputField!
    @IBOutlet weak var lastNameIF: InputField!
    @IBOutlet weak var emailIF: InputField!
    @IBOutlet weak var passwordIF: InputField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
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
//        Utilities.styleTextField(firstNameTextField)
//        Utilities.styleTextField(lastNameTextField)
//        Utilities.styleTextField(emailTextField)
//        Utilities.styleTextField(passwordTextField)
        
        // Do any additional setup after loading the view.
        self.firstNameIF.lblTitle.text = "First Name"
        self.firstNameIF.placeholder = "Enter first name"
        
        self.lastNameIF.lblTitle.text = "Last Name"
        self.lastNameIF.placeholder = "Enter last name"
        
        self.emailIF.lblTitle.text = "Email"
        self.emailIF.placeholder = "Enter your email address"
        
        self.passwordIF.lblTitle.text = "Password"
        self.passwordIF.placeholder = "Enter your password"
        
        Utilities.styleFilledButton(signUpButton)
        
        //listen for keyboard events

        }
    

    
//    @objc func keyboardWillChange(notification: Notification) {
//        print("Keyboard will show: \(notification.name.rawValue)")
//
//
//        view.frame.origin.y = -300
//    }
    
    //Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns he error message
    func validateFields() -> String? {
        
        //Check that all fields are filled in
        if firstNameIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
             
            return "Please fill in all fields."
        }
        
        //Check if the password is secure
        let cleanedPassword = passwordIF.lblTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            //Password isnt secure enough
            return "Please mae sure your password is at least 8 characters, contains a special character and a number."
        }
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        //Validate the fields
        let error = validateFields()
        
        if error != nil {
            //there is something wrong with the fields
            self.showError(error!)
        }
        else {
        
            //create cleaned versions of the data, strip out white spaces
            let firstName = firstNameIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordIF.lblTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
        //create new user
            Auth.auth().createUser(withEmail: email!, password: password!) { (result, err) in
                
                //Check for errors
                if err != nil {
                    //there was an error
                    self.showError("Error creating user")
                    
                }
                else {
                    //User was created sucessfully, now store the first name and last name
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                        if error != nil {
                        //show message
                        self.showError("Error saving user data")
                        // handle errors here, retry save or ask user to repeat signup
                        }
                            
                    }
                    
                    //transition to the home screen
                    self.transitionToHome()
                    
                }
                
                
            }
            
        
        
        }
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        
        performSegue(withIdentifier: "signUpToHome", sender: self)
        
//        let HomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.HomeViewController) as? HomeViewController
//        
//        view.window?.rootViewController = HomeViewController
//        view.window?.makeKeyAndVisible()
    }

}
