//
//  CalendarDetailViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 13.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import Firebase

protocol CalendarDetailDelegate: class {
    func removeEvent(id: String)
}

class CalendarDetailViewController: UIViewController {
    weak var delegate: CalendarDetailDelegate?
    //Variables passed by the TodoVC
    var dateString: String!
    var events: [Event]!
    var newEvent: Event!
    
    let db = Firestore.firestore()

    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var addFooter: UIView!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFooter.isHidden = true
        eventDate.text = dateString
        eventsTable.delegate = self
        eventsTable.dataSource = self
    }

    //Button for creating new event
    @IBAction func createEvent(_ sender: Any) {
        //validation
        if(eventTitle.text == "" || eventDescription.text == "") {
            return
        }
        //Get variables
        let timeDate = eventDatePicker.date
        let timeDateString = dateFormatterFB.string(from: timeDate)
        let chosenDateSring = dateFormatterFB.string(from: dateFormatterFS.date(from: dateString)!)
        let newDateStrig = String(chosenDateSring.prefix(10) + timeDateString.suffix(6))
        let newDate = dateFormatterFB.date(from: newDateStrig)
        //set the newEvent variable, that is accessable in the CalendarVC and performeSgue
        newEvent = Event(title: eventTitle.text!, date: newDate!, time: "", description: eventDescription.text!, id: "")
        performSegue(withIdentifier: "unwindToCalendar", sender: nil)
        
    }
    
    //Toggles the addEvent Form
    @IBAction func addEventClick(_ sender: Any) {
        addEventButton.isHidden = true
        addFooter.isHidden = false
    }
    
    
    func deleteEvent(id: String, indexPath: IndexPath) {
        delegate?.removeEvent(id: id)
        events.remove(at: indexPath.row)
        eventsTable.reloadData()
    }

}


extension CalendarDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    //Count of the Events on that day
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    //Height of one Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    //cell creator
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? CalendarEventCell else {
            fatalError("Cell could not be cast")
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.eventTitle.text = events[indexPath.row].title
        cell.eventDescription.text = events[indexPath.row].description
        return cell
    }
    
    // Delete Swipe Action Configuration
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            let id = self.events[indexPath.row].id
            self.deleteEvent(id: id, indexPath: indexPath)
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
    }
    
    
    
}





