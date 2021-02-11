//
//  ProfileScreen.swift
//  WG-Projekt
//
//  Created by Selin Bilge on 10.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit


extension String {
          var isEmail: Bool {
             let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
             let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
           return emailTest.evaluate(with: self)
          }
}



class ProfileScreen: UIViewController {
    
@IBOutlet weak var nameText: UITextField!
@IBOutlet weak var emailText: UITextField!
@IBOutlet weak var passwordText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add an done button to the keyboard
        let toolbar = UIToolbar(frame: CGRect(x: 0, y:0, width: view.frame.size.width, height: 50))
       
        // items
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        toolbar.items = [flexibleSpace, doneButton]
        toolbar.sizeToFit()
        
        nameText.inputAccessoryView = toolbar
      //  emailText.inputAccessoryView = toolbar
      //  passwordText.inputAccessoryView = toolbar
    }
    
    // close keyboard after clicking on done button
    @objc private func didTapDone(){
        nameText.resignFirstResponder()
       // emailText.resignFirstResponder()
      //  passwordText.resignFirstResponder()
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           nameText.becomeFirstResponder()
         //  emailText.becomeFirstResponder()
         //  passwordText.becomeFirstResponder()
       }
    
   

    @IBAction func email(_ sender: Any) {
        
        /*
        if emailText.text != ""{
            
            // email is not valid
           // if emailText.text!.isEmail == false {
                
                // SHOW TOAST MESSAGE
                
                
          //  }
        }
 */
        
    }
    
    @IBAction func password(_ sender: Any) {
        
    }
    
    @IBAction func nextButton(_ sender: Any) {
           
        /*
           if nameText.text != "" && emailText.text != "" && passwordText.text != "" {
               
               // weiter zu nächsten screen
               // performSegue(withIdentifier: "AfterProfile", sender: nil)
               
           } else {
                // SHOW TOAST MESSAGE
           }
 */
       }
 
   
    
}
