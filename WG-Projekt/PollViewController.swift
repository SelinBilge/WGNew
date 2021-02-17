//
//  PollViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import Firebase

protocol PollDelegate: class {
    func updatePolls()
}

class PollViewController: UIViewController {
    weak var delegate: PollDelegate?
    let db = Firestore.firestore()
    var poll: Poll!  //current poll
    var decided: Bool = true //bool fo whether the user has voted or not
    var chosenCell = -1 //the cell for which the user votet

    @IBOutlet weak var pollTitle: UILabel!
    @IBOutlet weak var pollTable: UITableView!
    @IBOutlet weak var pollButton: UIButton!
    @IBOutlet weak var pollDue: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatus()
        pollTable.dataSource = self
        pollTable.delegate = self
        pollTitle.text = poll.title
    }
    
    //Method that sets the decided variable based on the poll.user array (that stores the votes of each wg user)
    //Also changes the button text
    func setStatus() {
        if(poll.finished) {
            pollDue.text = "Abstimmung beendet"
        } else{
            pollDue.text = "bis " + dateFormatterFS.string(from: poll.till) + " " +  dateFormatterTime.string(from: poll.till)
        }
        
        if(self.poll.user["Paul"] == -1) {
            self.decided = false
            self.pollButton.setTitle("abstimmen", for: .normal)
        } else {
            self.decided = true
            self.pollButton.setTitle("rückgängig", for: .normal)
        }
        if(self.poll.finished) {
            self.pollButton.isHidden = true
        }
    }
    

    //Button for voting is clicked.
    //The vote is updated in firestore
    //The status is updated
    @IBAction func pollButtonClicked(_ sender: Any) {
        
        if(chosenCell == -1 && !decided) {
            //user wants to vote without a chosen option
            return
        }
        if(decided) {
            //user wants to undo his vote -> chosen cell is set to -1
            chosenCell = -1
        }
        
        //modifie user array to update it in firestore
        poll.user["Paul"] = chosenCell
        let ref = db.collection("poll").document("idx").collection("polls").document(poll.id)
        ref.updateData([
            "decisions": poll.user
            ]) { err in
                if let err = err {
                    print("Unable to update data, reason: \(err)")
                } else {
                    ref.getDocument { (snapshot, err) in
                        if let data = snapshot?.data() {
                            let currentDate = Date()
                            let stringDate = data["till"] as! String
                            let date = dateFormatterFB.date(from: stringDate)!
                            var finished = false
                            if(date < currentDate) {
                                finished = true
                            }
                            
                            self.poll = Poll(title: data["title"] as! String, user: data["decisions"] as! [String:Int], options: data["options"] as! [String], till: date, finished: finished, id: self.poll.id)
                            self.setStatus()
                            self.pollTable.reloadData()
                            self.delegate?.updatePolls()
                        } else {
                            print("Couldn't find the document")
                        }
                    }
                }
            }
    }
    
}

extension PollViewController: UITableViewDelegate, UITableViewDataSource {
    
    //Option count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poll.options.count
    }
    
    //By clicking, the user is choosing a cell, the table is reloaded
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCell = indexPath.row
        pollTable.reloadData()
    }
    
    //Cell creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(decided || poll.finished) {
            //Cells that are printed if the user has already voted
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "pollResultCell", for: indexPath) as? PollResultCell else {
                fatalError("Cell could not be cast")
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            //get resiult for the option of the cell with the poll.user array
            var result = 0
            for user in poll.user {
                if(user.value == indexPath.row) {
                    result += 1
                }
            }
            if(poll.user["Paul"] == indexPath.row) {
                cell.pollTitle.textColor = UIColor(displayP3Red: 230.0/255.0, green: 185.0/255.0, blue: 59.0/255.0, alpha: 1.0)
            } else {
                cell.pollTitle.textColor = UIColor.darkGray
            }
            
            //set properties
            cell.pollTitle.text = poll.options[indexPath.row]
            cell.pollResult.text = String(result)
            return cell
        } else {
            //Cells that are printed if the usser has not voted
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "pollCell", for: indexPath) as? PollCell else {
                fatalError("Cell could not be cast")
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            //If the cell is selected, display it
            if(indexPath.row == chosenCell) {
                cell.pollCheckmark.image = (UIImage(systemName: "checkmark.circle"))
            } else {
                cell.pollCheckmark.image = (UIImage(systemName: "circle"))
            }
            cell.pollTitle.text = poll.options[indexPath.row]
            return cell
        }
    }
    
    
    
    
}
