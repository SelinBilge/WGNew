//
//  CalendarViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase

//Struct for one Event in the calendar
struct Event {
    var title: String
    var date: Date
    var time: String
    var description: String
    var id: String
}

//Section that stores all Events of one Date in the Section
struct CalendarSection {
    var date: String //Date String in the Format of FS
    var events: [Event]
}

//Struct for one Poll
struct Poll {
    var title: String
    var user: [String:Int]  //Map that stores the chosen option for each user, by default -1
    var options: [String]  //String Array with all options
    var till: Date
    var id: String
}


class CalendarViewController: UIViewController {
    let db = Firestore.firestore()
    var eventsArray: [CalendarSection] = []
    var polls: [Poll] = []
    //Variables that are use by Detail and PollView Controller
    var chosenEvents = [Event]()  // Array of Events of the day, the user has chosen
    var chosenDateString = ""  // String representation of the Date the User has chosen
    var selectedPoll: Poll!  // Poll that the user has chosen

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventsTable: UITableView!
    
    //Data Formatter for the Calendar -> repersentation of date without time for the user
    var dateFormatterFS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    //Data Formatter for getting the time out of a date
    var dateFormatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    override func viewDidLoad() {
        //Navigation Bar setup
        super.viewDidLoad()
        guard
            let navigationController = navigationController,
            let flareGradientImage = CAGradientLayer.primaryGradient(on: navigationController.navigationBar)
            else {
                print("Error creating gradient color!")
            return
        }
        navigationController.navigationBar.barTintColor = UIColor(patternImage: flareGradientImage)
        
        //Notifcation -> Todo replace with delegate
        NotificationCenter.default.addObserver(self, selector: #selector(fetchPollData), name: NSNotification.Name(rawValue: "updatePoll"), object: nil)
        
        //set delegate and data source
        calendar.dataSource = self
        calendar.delegate = self
        eventsTable.dataSource = self
        eventsTable.delegate = self
        
        //Fetch data
        fetchEventData()
        fetchPollData()
    }
    
    
    //Prepares for transitions to PollVC and CalendarDetailVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectedDate") {
            //get chosen variables and set them in destination vc
            let vc = (segue.destination as! CalendarDetailViewController)
            if(chosenEvents.count != 0) {
                vc.hasEvents = true
            } else {
                vc.hasEvents = false
            }
            vc.dateString = chosenDateString
            vc.events = chosenEvents
        }
        if(segue.identifier == "showPoll") {
            //get chosen variables and set them in destination vc
            let vc = (segue.destination as! PollViewController)
            vc.poll = selectedPoll
        }
    }
    
    // Transitions to AddPollVC
    @objc func addPollClicked(sender: UIButton!) {
        performSegue(withIdentifier: "addPoll", sender: nil)
    }
    
    
    // Fetches the events from firestore. The events are then sorted and combined in sections
    func fetchEventData() {
        eventsArray = []
        let collectionRef = db.collection("calendar").document("idx").collection("events")
        collectionRef.getDocuments { (querySnapshot, err) in
            if let docs = querySnapshot?.documents {
                for docSnapshot in docs {
                    let data = docSnapshot.data()
                    //get date as String and format it as date
                    let stringDateF = data["date"] as! String
                    let date = dateFormatterFB.date(from: stringDateF)!
                    //Get time as string and date as string in the calendar format
                    let timeString = self.dateFormatterTime.string(from: date)
                    let stringDate = self.dateFormatterFS.string(from: date)
                    //create event
                    let eventEntry: Event = Event(title: data["title"] as! String, date: date, time: timeString, description: data["description"] as! String, id: docSnapshot.documentID)
                    //add to section if the section exiists, create a new one otherwise
                    if let index = self.eventsArray.firstIndex(where: {$0.date == stringDate}) {
                        self.eventsArray[index].events.append(eventEntry)
                    } else {
                       let newSection = CalendarSection(date: stringDate, events: [eventEntry])
                        self.eventsArray.append(newSection)
                    }
                    
                }
                
                //sort the sections
                self.eventsArray.sort { (lhs: CalendarSection, rhs: CalendarSection) -> Bool in
                    let lhsDate = self.dateFormatterFS.date(from: lhs.date)!
                    let rhsDate = self.dateFormatterFS.date(from: rhs.date)!
                    return lhsDate < rhsDate
                }
                //sort the events in the sections
                for (index, _) in self.eventsArray.enumerated() {
                    self.eventsArray[index].events.sort { (lhs: Event, rhs: Event) -> Bool in
                        return lhs.date < rhs.date
                    }
                }
                self.eventsTable.reloadData()
                self.calendar.reloadData()
            }
        }
    }
    
    // Fetch the poll entries from firestore.
    @objc func fetchPollData() {
        polls = []
        let collectionRef = db.collection("poll").document("idx").collection("polls")
        collectionRef.getDocuments { (querySnapshot, err) in
            if let docs = querySnapshot?.documents {
                for docSnapshot in docs {
                    let data = docSnapshot.data()
                    //get dateString and transform it to date
                    let stringDate = data["till"] as! String
                    let date = dateFormatterFB.date(from: stringDate)!

                    
                    let pollEntry: Poll = Poll(title: data["title"] as! String, user: data["decisions"] as! [String:Int], options: data["options"] as! [String], till: date, id: docSnapshot.documentID)
                    self.polls.append(pollEntry)
                    
                }
                self.eventsTable.reloadData()
            }
        }
    }
    
    // Gets called after an Event was added, and the CalendarDetailVC was closed
    // Gets the newEvent from the VC and adds it to firestore. Afterwards, the data is reloaded
    @IBAction func unwindToCalendar(segue: UIStoryboardSegue) {
        let vc = segue.source as! CalendarDetailViewController
        let newEvent = vc.newEvent!
        let stringDate = dateFormatterFB.string(from: newEvent.date)
        
        let ref = db.collection("calendar").document("idx").collection("events")
        ref.addDocument(data: [
            "title": newEvent.title,
            "description": newEvent.description,
            "date": stringDate,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ref: \(ref)")
                self.fetchEventData()
            }
        }
    }
    
    //Gets called after a Poll was added and the PollVC was dissmissed.
    //Gets the new Poll from the VC and adds it to firestore. Afterwards, the data is reloaded
    @IBAction func unwindToPoll(segue: UIStoryboardSegue) {
        let vc = segue.source as! AddPollViewController
        let newPoll = vc.newPoll!
        let stringDate = dateFormatterFB.string(from: newPoll.till)
        
        let ref = db.collection("poll").document("idx").collection("polls")
        ref.addDocument(data: [
            "title": newPoll.title,
            "decisions": newPoll.user,
            "options": newPoll.options,
            "till": stringDate,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ref: \(ref)")
                self.fetchPollData()
            }
        }
    }
    
}


extension CalendarViewController : FSCalendarDelegate, FSCalendarDataSource {
    
    //Sets points in calendar for events
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        //get date String
        let dateString = self.dateFormatterFS.string(from: date)
        //check if a section exists -> look how many events are on this day
        if let section = self.eventsArray.first(where: {$0.date == dateString}) {
            return section.events.count
        }
        return 0
    }
    
    //Handles click Event on calendar -> performes a segue to the CalendarDetailVC
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //get date String
        let dateString = self.dateFormatterFS.string(from: date)
        
        //set variables that are used in the prepare method
        chosenDateString = dateString
        if let section = self.eventsArray.first(where: {$0.date == dateString}) {
            chosenEvents = section.events
            
        } else {
            chosenEvents = []
        }
        performSegue(withIdentifier: "selectedDate", sender: nil)
    }
}



extension CalendarViewController : UITableViewDelegate {
    
    //Open PollVC when a poll is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPoll = polls[indexPath.row]
        performSegue(withIdentifier: "showPoll", sender: nil)
    }

}

extension CalendarViewController : UITableViewDataSource {
    
    //Number of event section + 1 for the poll section
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventsArray.count + 1
    }
    
    //Number of the polls bzw the events in one section
    func tableView(_ tableView: UITableView, numberOfRowsInSection number: Int) -> Int {
        if number == 0 {
            return polls.count
        } else {
            return eventsArray[number-1].events.count
        }
    }
    
    //Height for the footers
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        return 30
    }
    
    //Height for the headers
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }

    
    // cell creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get cell and set cell layout
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as? CalendarCell else {
            fatalError("Cell could not be cast")
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.backgroundColor = UIColor.white.cgColor
        
        //Properties are chosen depending on if its a poll or event section
        if(indexPath.section == 0) {
            //Poll: Depending on wether a user has voted, text is displayes
            cell.eventTitle.text = polls[indexPath.row].title
            if(polls[indexPath.row].user["Paul"] != -1) {
                cell.eventDetail.text = "abgestimmt"
            } else {
                cell.eventDetail.text = "Nicht abgestimmt"
            }
        } else {
            //Events
            cell.eventTitle.text = eventsArray[indexPath.section-1].events[indexPath.row].title
            cell.eventDetail.text = eventsArray[indexPath.section-1].events[indexPath.row].time
        }
        
        return cell
    }
    
    
    // header Creation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //create subviews
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        
        let lineView = UIView(frame: CGRect(x: 0, y: 45, width: tableView.frame.width, height: 1.0))
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.systemGray5.cgColor

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.font = label.font.withSize(17)
        label.textColor = UIColor(displayP3Red: 32.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        if(section == 0) {
            label.text = "Abstimmungen"
        } else {
            label.text = eventsArray[section-1].date
        }
        
        //merge subviews
        headerView.addSubview(label)
        headerView.addSubview(lineView)
        return headerView
    }
    
    // Footer creation, Only for the Poll Section. Creats a Button for adding a Poll
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let image = UIImage(systemName: "plus.circle")
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.setImage(image, for: .normal)
            button.tintColor = UIColor(displayP3Red: 230.0/255.0, green: 186.0/255.0, blue: 59.0/255.0, alpha: 1.0)
            button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 30), forImageIn: .normal)
            button.addTarget(self, action: #selector(addPollClicked), for: .touchUpInside)
            return button
        } else {
            return UIView()
        }
    }
    
}

