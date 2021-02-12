//
//  ProfileScreen.swift
//  WG-Projekt
//
//  Created by Selin Bilge on 10.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

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

        
        // add an done button to the keyboard
        let toolbar = UIToolbar(frame: CGRect(x: 0, y:0, width: view.frame.size.width, height: 50))
       
        // items
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        toolbar.items = [flexibleSpace, doneButton]
        toolbar.sizeToFit()
        
        nameText.inputAccessoryView = toolbar
        emailText.inputAccessoryView = toolbar
        passwordText.inputAccessoryView = toolbar
        
    }
    
    // close keyboard after clicking on done button
         @objc private func didTapDone(){
            nameText.resignFirstResponder()
            emailText.resignFirstResponder()
            passwordText.resignFirstResponder()
         }
    
   
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           nameText.becomeFirstResponder()
           emailText.becomeFirstResponder()
           passwordText.becomeFirstResponder()
       }

   
    @IBAction func name(_ sender: Any) {
    }
    
    @IBAction func email(_ sender: Any) {
        
        if emailText.text != ""{
            
            // email is not valid
           if emailText.text!.isEmail == false {
                
                // SHOW TOAST MESSAGE
                self.showToast(message: "Das ist keine Emailadresse", font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
    
    @IBAction func password(_ sender: Any) {
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
           
        
        if nameText.text != "" && emailText.text != "" && passwordText.text != "" && emailText.text?.isEmail == true {
            
            // create User
            let username = nameText.text!.trimmingCharacters(in: .newlines)
            let useremail = emailText.text!.trimmingCharacters(in: .newlines)
            let userpassword = passwordText.text!.trimmingCharacters(in: .newlines)
            
            Auth.auth().createUser(withEmail: useremail, password: username) { (result, err) in
                
                // check for errors
                if let err = err {
                    self.showToast(message: "Error beim User erstellen", font: .systemFont(ofSize: 12.0))
                    
                } else {
                    // User erstellen
                    let db = Firestore.firestore()
                   
                    db.collection("users").addDocument(data: ["name": username, "uid": result!.user.uid]) { (error) in
                        
                        if error != nil {
                            self.showToast(message: "Error beim speichern in der Datenbank", font: .systemFont(ofSize: 12.0))
                        }
                    }
                    
                    // go to next screen
                    self.performSegue(withIdentifier: "AfterProfile", sender: nil)
                                
                    
                }
                
            }
            
            
            
              
            
           } else {
                // SHOW TOAST MESSAGE
                self.showToast(message: "Bitte fülle alle Felder aus", font: .systemFont(ofSize: 12.0))
           }
 
       }

}




extension UIViewController {

func showToast(message: String, font: UIFont) {
    let toastLabel = UILabel()
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = .white
    toastLabel.font = font
    toastLabel.textAlignment = .center
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    
    let maxWidthPercentage: CGFloat = 0.8
    let maxTitleSize = CGSize(width: view.bounds.size.width * maxWidthPercentage, height: view.bounds.size.height * maxWidthPercentage)
    var titleSize = toastLabel.sizeThatFits(maxTitleSize)
    titleSize.width += 20
    titleSize.height += 10
    toastLabel.frame = CGRect(x: view.frame.size.width / 2 - titleSize.width / 2, y: view.frame.size.height - 50, width: titleSize.width, height: titleSize.height)
    
    view.addSubview(toastLabel)
    
    UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
    }, completion: { _ in
        toastLabel.removeFromSuperview()
    })
    }
    
}
