//
//  LogInWG.swift
//  WG-Projekt
//
//  Created by Selin Bilge on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInWG: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBOutlet weak var wgNameText: UITextField!
    @IBOutlet weak var wgPasswortText: UITextField!
    
    
    @IBAction func LogInButton(_ sender: Any) {
   
        if wgNameText.text != "" && wgPasswortText.text != "" {
            
            let db = Firestore.firestore()
            let  userID = Auth.auth().currentUser!.uid
            
            var wgname = ""
            var passw = ""
            
            // read data from specific document ID
            db.collection("users").document(userID).getDocument { (document, error) in
           
                if error == nil {
                    // check if document exists
                    if document != nil && document!.exists {
                                            
                        let docData = document!.data()
                        wgname = docData!["wgname"] as? String ?? ""
                        print("Test get code: \(wgname)")
                        
                        passw = docData!["wgpasswort"] as? String ?? ""
                        print("Test get code: \(passw)")
                        
                    }
                }
            }
            
            
            if wgNameText.text == wgname && wgPasswortText.text == passw {
                // go to next screen
                self.performSegue(withIdentifier: "Home", sender: nil)

            } else {
                self.showToast(message: "Die Eingaben sind leider nicht korrekt", font: .systemFont(ofSize: 12.0))
            }
            
            
        } else {
            self.showToast(message: "Bitte fülle alle Felder aus", font: .systemFont(ofSize: 12.0))
        }
        
    }
    

}
