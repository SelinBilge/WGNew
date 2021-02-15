//
//  PollViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class PollViewController: UIViewController {

    @IBOutlet weak var pollTitle: UILabel!
    @IBOutlet weak var pollDue: UILabel!
    @IBOutlet weak var pollTable: UITableView!
    @IBOutlet weak var pollButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func pollButtonClicked(_ sender: Any) {
    }

}
