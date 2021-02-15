//
//  CalendarViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import FSCalendar


struct Event {
    var title: String
    var date: String
    var description: String
}

struct Poll {
    var title: String
    var desicion: Int?
    var possibleDesicions: [String]
    var desicionCount: [Int]
    var till: String
}


class CalendarViewController: UIViewController {
    var chosenEvents = [Event]()
    var chosenDate = ""
    var eventsArray: [[Event]] = []
    
    var Events: [String: [Event]] = ["2021-02-15":
                                    [Event(title: "Spieleabend", date: "2021-02-15", description: "Gemeinsamer Spieleabend")],
                                   "2021-02-13":
                                   [Event(title: "Emil abholen", date: "2012-02-13", description: "Emil vom Flughafen abholen"),
                                    Event(title: "Filmeabend", date: "2012-02-13", description: "The great Gatsby, Sherlock...")]
    ]
    
    var Polls: [Poll] = [Poll(title: "Spieleabend", desicion: nil, possibleDesicions: ["2012-02-18", "2012-02-19", "2012-02-20"], desicionCount: [0,1,0], till: "2012-02-28")]
    
    var dateFormatterFS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        eventsTable.dataSource = self
        eventsTable.delegate = self
        
        eventsArray = Array(Events.values.map{$0})
        
        guard
            let navigationController = navigationController,
            let flareGradientImage = CAGradientLayer.primaryGradient(on: navigationController.navigationBar)
            else {
                print("Error creating gradient color!")
            return
        }
        navigationController.navigationBar.barTintColor = UIColor(patternImage: flareGradientImage)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectedDate") {
            let vc = (segue.destination as! CalendarDetailViewController)
            if(chosenEvents.count != 0) {
                vc.hasEvents = true
            } else {
                vc.hasEvents = false
            }
            vc.date = chosenDate
            vc.events = chosenEvents
        }
    }
    
    @objc func addPollClicked(sender: UIButton!) {
        performSegue(withIdentifier: "addPoll", sender: nil)
    }
    
    
    
}


extension CalendarViewController : FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let dateString = self.dateFormatterFS.string(from: date)

        if self.Events.keys.contains(dateString) {
            return 1
        }


        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateString = self.dateFormatterFS.string(from: date)

        if self.Events.keys.contains(dateString) {
            chosenEvents = Events[dateString]!
        } else {
            chosenEvents = []
        }
        chosenDate = dateString
        performSegue(withIdentifier: "selectedDate", sender: nil)
    }
}



extension CalendarViewController : UITableViewDelegate {

}

extension CalendarViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection number: Int) -> Int {
        if number == 0 {
            return Polls.count
        } else {
            return eventsArray[number-1].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as? CalendarCell else {
            fatalError("Cell could not be cast")
        }
        if(indexPath.section == 0) {
            cell.eventTitle.text = Polls[indexPath.row].title
            if(Polls[indexPath.row].desicion != nil) {
                cell.eventDetail.text = Polls[indexPath.row].possibleDesicions[Polls[indexPath.row].desicion!]
            } else {
                cell.eventDetail.text = "Nicht abgestimmt"
            }
        } else {
            cell.eventTitle.text = eventsArray[indexPath.section-1][indexPath.row].title
            cell.eventDetail.text = "10:00"
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.backgroundColor = UIColor.white.cgColor
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        if(section == 0) {
            label.text = "Abstimmungen"
        } else {
            label.text = eventsArray[section-1][0].date
        }
        label.font = label.font.withSize(17)

        label.textColor = UIColor(displayP3Red: 32.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        

        headerView.addSubview(label)

        let lineView = UIView(frame: CGRect(x: 0, y: 45, width: tableView.frame.width, height: 1.0))
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.systemGray5.cgColor
        headerView.addSubview(lineView)
        
        return headerView
    }
    
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

