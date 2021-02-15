//
//  inviteToWg.swift
//  WG-Projekt
//
//  Created by Selin Bilge on 13.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class inviteToWg: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // code text feld zeigt das passwort an
    }
    
    @IBOutlet weak var displayCode: UITextField!

    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBAction func Button(_ sender: Any) {
        
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
                    
                    // sharesheet with wg-name and the password for th wg
                    var message = "WG-Name: \(wgname) Passwort: \(passw)"
                    
                    let shareSheetVC = UIActivityViewController(
                        activityItems:[
                        message
                        ],
                        applicationActivities: nil
                    )
                    shareSheetVC.popoverPresentationController?.sourceView = self.view
                    self.present(shareSheetVC, animated: true, completion: nil)
                    
                }
            }
        }
        
       
     
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        // next screen
        self.performSegue(withIdentifier: "logIntoWG", sender: nil)
    }

}





















