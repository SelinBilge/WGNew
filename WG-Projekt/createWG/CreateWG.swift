//
//  CreateWG.swift
//  WG-Projekt
//
//  Created by Selin Bilge on 13.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


class CreateWG: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // display email
        emailtext.text = Auth.auth().currentUser?.email

    }
    
    
    @IBOutlet weak var nameofWg: UITextField!
    @IBOutlet weak var emailtext: UITextField!
    @IBOutlet weak var passworttext: UITextField!
    
    @IBAction func wgname(_ sender: Any) {
       
    }
    
    @IBAction func emailcheck(_ sender: Any) {
           
    }
    
    
    @IBAction func password(_ sender: Any) {
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        
        
        if nameofWg.text != "" && emailtext.text != "" && passworttext.text != ""  {
            
            // create User
            let wgname =  nameofWg.text!.trimmingCharacters(in: .newlines)
            let wgpassword = passworttext.text!.trimmingCharacters(in: .newlines)
            
          
            // save WG Information
            let db = Firestore.firestore()
            
        
            let  userID = Auth.auth().currentUser!.uid
            print("Test UserID: \(userID)")

            

            // updating a specific document id
            db.collection("users").document(userID).setData(["wgname":wgname, "wgpasswort":wgpassword]) { (error) in
                
                if error != nil {
                    self.showToast(message: "Error beim speichern in der Datenbank", font: .systemFont(ofSize: 12.0))
               
                } else {
                    print("WGInfos were saved")

                    // go to next screen
                    self.performSegue(withIdentifier: "shareWG", sender: nil)
                }
            
            }
            
        
           } else {
                // SHOW TOAST MESSAGE
                self.showToast(message: "Bitte fülle alle Felder aus", font: .systemFont(ofSize: 12.0))
           }
    }
    
    
}
