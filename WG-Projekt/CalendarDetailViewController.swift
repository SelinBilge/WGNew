//
//  CalendarDetailViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 13.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class CalendarDetailViewController: UIViewController {
    var date: String!
    var events: [Event]!
    var hasEvents: Bool!

    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var addFooter: UIView!
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFooter.isHidden = true
        eventDate.text = date
        eventsTable.delegate = self
        eventsTable.dataSource = self
        //eventsTable.tableFooterView = UIView.init()
    }

    @IBAction func addEventClick(_ sender: Any) {
        addEventButton.isHidden = true
        addFooter.isHidden = false
    }
}


extension CalendarDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? CalendarEventCell else {
            fatalError("Cell could not be cast")
        }
        cell.eventTitle.text = events[indexPath.row].title
        cell.eventDescription.text = events[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
}





