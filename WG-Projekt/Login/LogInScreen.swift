//
//  LogInScreen.swift
//  WG-Projekt
//
//  Created by Selin Bilge on 12.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInScreen: UIViewController {

    
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var newEmailText: UITextField!
    
    @IBAction func email(_ sender: Any) {
        if newEmailText.text != ""{
            
            // email is not valid
           if newEmailText.text!.isEmail == false {
                
                // SHOW TOAST MESSAGE
                self.showToast(message: "Das ist keine Emailadresse", font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let email = newEmailText.text!.trimmingCharacters(in: .newlines)
        let password = passwordText.text!.trimmingCharacters(in: .newlines)
    
        
        // check if fields are empty
        if email != "" && password != "" && newEmailText.text?.isEmail == true {
            
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
           
            // couldn't sign in
            if error != nil{
                self.showToast(message: error!.localizedDescription, font: .systemFont(ofSize: 12.0))
                
            } else {
                print("Login was successful")
                self.performSegue(withIdentifier: "Home", sender: nil)
            }
        }
        }
    }
    
    
}
