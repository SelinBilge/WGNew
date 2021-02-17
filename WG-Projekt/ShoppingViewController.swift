//
//  ShoppingViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import Firebase

//Sections for Todo
struct ShoppingSection{
    let name: String
    var entries: [Item]
}

//One Totdo Object
struct Item: Codable{
    let title: String
    var bought: Bool
    var id: String
}


class ShoppingViewController: UIViewController {
    //Array that stores the todo sectios
    private var shoppingList: [ShoppingSection] = []
    let db = Firestore.firestore()

    @IBOutlet weak var shoppingTable: UITableView!
    @IBOutlet weak var addField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set filed delegate
        addField.delegate = self
        //set navigation bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        guard
            let navigationController = navigationController,
            let flareGradientImage = CAGradientLayer.primaryGradient(on: navigationController.navigationBar)
            else {
                print("Error creating gradient color!")
            return
            }
        navigationController.navigationBar.barTintColor = UIColor(patternImage: flareGradientImage)
        
        //Create 2 Sections. Call fetch data
        shoppingList = [
            ShoppingSection(name: "Einkaufsliste", entries: []),
            ShoppingSection(name: "Gekauft", entries: [])]
        fetchData()
        
        shoppingTable.delegate = self
        shoppingTable.dataSource = self
    }
    
    //item is added to the list
    @IBAction func addButtonClicked(_ sender: Any) {
        addItem()
    }
    
    func addItem() {
        if(addField.text == "") {
            return
        }
        
        let ref = db.collection("shoppinglist").document("idx").collection("items")
        ref.addDocument(data: [
            "bought": false,
            "title": addField.text!,
        ]) { err in
            if err != nil {
                print("Error adding Todo")
            } else {
                print("Todo added")
                self.fetchData()
                self.addField.text = ""
            }
        }
    }
    
    //Fetches data from firestore. Clears the entries of the 2 Sections.
    func fetchData() {
        shoppingList[0].entries = []
        shoppingList[1].entries = []
        
        let collectionRef = db.collection("shoppinglist").document("idx").collection("items")
        collectionRef.getDocuments { (querySnapshot, err) in
            if let docs = querySnapshot?.documents {
                for docSnapshot in docs {
                    let data = docSnapshot.data()
                    let itemEntry: Item = Item(title: data["title"] as! String, bought: data["bought"] as! Bool, id: docSnapshot.documentID )
                    
                    if(itemEntry.bought) {
                        self.shoppingList[1].entries.append(itemEntry)
                    } else {
                        self.shoppingList[0].entries.append(itemEntry)
                    }
                    
                }
                self.shoppingTable.reloadData()
            }
        }
    }
    
    
    // Delete a Todo and fetch data afterwards
    func deleteItem(id: String, indexPath: IndexPath) {
        let ref = db.collection("shoppinglist").document("idx").collection("items").document(id)
        ref.delete() { err in
            if let err = err {
                print("Unable to delete document, reason: \(err)")
            } else {
                print("Data deleted successfully")
                self.fetchData()
            }
        }
    }

}

// Extension for the Cell Delegate. Cells can communicate with the VC via the delegate.
extension ShoppingViewController: ShoppingCellDelegate {
    
    //Is called when a cell checkbox is clicked. The id of the cell, the index of the cell and whether it is done or not,
    // is passed.
    // The Todo is updated in firestore with the done variable. Then fetchData is called
    func checkEntry(index: IndexPath, id: String, bought: Bool) {
        let ref = db.collection("shoppinglist").document("idx").collection("items").document(id)
        ref.updateData([
                "bought": bought
            ]) { err in
            if let err = err {
                    print("Unable to update data, reason: \(err)")
                } else {
                    self.fetchData()
                }
            }
    }
}


//Extension for the Data Source of the Table
extension ShoppingViewController : UITableViewDataSource {
    
    // Returns the number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return shoppingList.count
    }
    
    //Number of entries in each Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection number: Int) -> Int {
        return shoppingList[number].entries.count
    }
    
    //Height of section footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (shoppingList[section].entries.count == 0) {
            return 80
        }
        return 30
    }
    
    //Height of section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    // Delete Swipe Action Configuration
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let id = shoppingList[indexPath.section].entries[indexPath.row].id
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                self.deleteItem(id: id, indexPath: indexPath)
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            //configuration.performsFirstActionWithFullSwipe = false
            return configuration
    }

    //Delete Style
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let swipeContainerView = tableView.subviews.first(where: { String(describing: type(of: $0)) == "_UITableViewCellSwipeContainerView" }) {
          if let swipeActionPullView = swipeContainerView.subviews.first, String(describing: type(of: swipeActionPullView)) == "UISwipeActionPullView" {
            swipeActionPullView.frame.size.height = 30
            swipeActionPullView.frame.origin.y = 7
            swipeActionPullView.layer.cornerRadius = 15
            swipeActionPullView.clipsToBounds = true
          }
        }
    }
    
    //Cell creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get cell as Todo cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath) as? ShoppingCell else {
            fatalError("Cell could not be cast")
        }
        
        //Cell Sytyle
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.backgroundColor = UIColor.white.cgColor
        
        //Cell properties
        cell.indexPath = indexPath
        cell.id = shoppingList[indexPath.section].entries[indexPath.row].id
        cell.delegate = self
        cell.itemInfo.text = ""
        
        //Depending on the section, the Title is crossed through and the checkbox is marked
        let titleText = shoppingList[indexPath.section].entries[indexPath.row].title
        if(indexPath.section == 1) {
            cell.checkBox.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: titleText)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.itemTitle.attributedText = attributeString
        } else {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: titleText)
            cell.itemTitle.attributedText = attributeString
            cell.checkBox.setImage(UIImage(systemName: "circle"), for: .normal)
            
        }
        return cell
    }
    
    //Header creation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Create Subview
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.font = label.font.withSize(17)
        label.text =  shoppingList[section].name
        
        let lineView = UIView(frame: CGRect(x: 0, y: 45, width: tableView.frame.width, height: 1.0))
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.systemGray5.cgColor
        
        //Set the text color accordingly to the section
        if(section == 1) {
            label.textColor = UIColor.gray
        } else {
            label.textColor = UIColor(displayP3Red: 32.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        }

        //Merge and return Subviews
        headerView.addSubview(label)
        headerView.addSubview(lineView)
        return headerView
    }
    
    //Footer creator
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var text = ""
        if (shoppingList[section].entries.count == 0) {
            text = "KEINE ITEMS IN DER LISTE"
        }
        
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 40, y: 0, width: footerView.frame.width-80, height: footerView.frame.height)
        label.font = label.font.withSize(13)
        label.text =  text
        label.textAlignment = .center
        label.textColor = UIColor.systemGray3
        footerView.addSubview(label)
        return footerView
    }

}

extension ShoppingViewController : UITextFieldDelegate {
    
    //Handles Enter Event from the return Key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addItem()
        return true;
    }
}


extension ShoppingViewController : UITableViewDelegate {
    
}
