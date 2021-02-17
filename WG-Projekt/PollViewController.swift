//
//  PollViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import Firebase

class PollViewController: UIViewController {
    let db = Firestore.firestore()
    var poll: Poll!
    var decided: Bool = true
    var chosenCell = -1

    @IBOutlet weak var pollTitle: UILabel!
    @IBOutlet weak var pollDue: UILabel!
    @IBOutlet weak var pollTable: UITableView!
    @IBOutlet weak var pollButton: UIButton!
    
    var dateFormatterFB: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    func setStatus() {
        print("set status")
        if(self.poll.user["Paul"] == -1) {
            self.decided = false
            self.pollButton.setTitle("abstimmen", for: .normal)
        } else {
            self.decided = true
            self.pollButton.setTitle("rückgängig", for: .normal)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatus()
        pollTable.dataSource = self
        pollTable.delegate = self
        pollTitle.text = poll.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePoll"), object: nil)
        }
    }
    

    @IBAction func pollButtonClicked(_ sender: Any) {
        if(chosenCell == -1) {
            return
        }
        if(decided) {
            chosenCell = -1
        }
        
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
                            let stringDate = data["till"] as! String
                            let date = self.dateFormatterFB.date(from: stringDate)!

                            self.poll = Poll(title: data["title"] as! String, user: data["decisions"] as! [String:Int], options: data["options"] as! [String], till: date, id: self.poll.id)
                            self.setStatus()
                            self.pollTable.reloadData()
                        } else {
                            print("Couldn't find the document")
                        }
                    }
                }
            }
    }
    
}

extension PollViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poll.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(decided) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "pollResultCell", for: indexPath) as? PollResultCell else {
                fatalError("Cell could not be cast")
            }
            var result = 0
            for user in poll.user {
                if(user.value == indexPath.row) {
                    result += 1
                }
            }
            cell.pollTitle.text = poll.options[indexPath.row]
            cell.pollResult.text = String(result)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "pollCell", for: indexPath) as? PollCell else {
                fatalError("Cell could not be cast")
            }
            if(indexPath.row == chosenCell) {
                cell.pollButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            } else {
                cell.pollButton.setImage(UIImage(systemName: "circle"), for: .normal)
            }
            cell.pollTitle.text = poll.options[indexPath.row]
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCell = indexPath.row
        pollTable.reloadData()
    }
    
    
}
