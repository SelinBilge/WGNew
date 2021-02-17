//
//  CalendarDetailViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 13.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class CalendarDetailViewController: UIViewController {
    var dateString: String!
    var events: [Event]!
    var hasEvents: Bool!
    var newEvent: Event!

    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var addFooter: UIView!
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    var dateFormatterFS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    var dateFormatterFB: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFooter.isHidden = true
        eventDate.text = dateString
        eventsTable.delegate = self
        eventsTable.dataSource = self
        //eventsTable.tableFooterView = UIView.init()
    }

    @IBAction func createEvent(_ sender: Any) {
        if(eventTitle.text == "" || eventDescription.text == "") {
            return
        }
        let timeDate = eventDatePicker.date
        let timeDateString = dateFormatterFB.string(from: timeDate)
        let chosenDateSring = dateFormatterFB.string(from: dateFormatterFS.date(from: dateString)!)
        let newDateStrig = String(chosenDateSring.prefix(10) + timeDateString.suffix(6))
        let newDate = dateFormatterFB.date(from: newDateStrig)
        newEvent = Event(title: eventTitle.text!, date: newDate!, time: "", description: eventDescription.text!, id: "")
        performSegue(withIdentifier: "unwindToCalendar", sender: nil)
        
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





