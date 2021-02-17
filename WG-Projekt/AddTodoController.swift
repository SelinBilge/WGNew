//
//  AddTodoController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import Firebase

//Struct for the users that should be displayed
struct User{
    var name : String
}

class AddTodoController: UIViewController{
    var newTodo: Todo!  // The new Todo Struct, accessable in TodoViewController
    private var users: [User] = []  // List of wg users
    private var activePerson = -1  // The currently chosen User
    let db = Firestore.firestore()
    
    @IBOutlet weak var personCollection: UICollectionView!
    @IBOutlet weak var todoTitle: UITextField!
    @IBOutlet weak var todoDate: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        personCollection.delegate = self
        personCollection.dataSource = self
    }
    
    //The Todo gets added and the view is closed
    @IBAction func addTodo(_ sender: Any) {
        if(todoTitle.text == "" ||  activePerson == -1) {
            //TODO display snackbar
        } else {
            let date = todoDate.date
            newTodo = Todo(title: todoTitle.text!, done: false, person: users[activePerson].name, due: date, id: "")
            performSegue(withIdentifier: "unwindFromAddTodo", sender: nil)
        }
    }
    
    //The Users from the Wg are fetched from firestore and displayed as Collection View
    func fetchData() {
        let collectionRef = db.collection("wgs").document("idx")
        collectionRef.getDocument { (querySnapshot, err) in
            if let data = querySnapshot?.data() {
                let usersEntry: [String] = data["users"] as! [String]
                usersEntry.forEach { item in
                    self.users.append(User(name: item))
                }
                self.personCollection.reloadData()
            }
        }
    }
    
    
}



extension AddTodoController : UICollectionViewDataSource {
    
    //Number of entries
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    //Cell creation
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personTag", for: indexPath) as! PersonTag
        cell.personName.text = users[indexPath.row].name
        return cell
    }
    
    //OnSelected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:PersonTag = collectionView.cellForItem(at: indexPath) as! PersonTag
        
        //Set colors
        if(indexPath.row == activePerson) {
            cell.personImage.backgroundColor = UIColor(displayP3Red: 0.0/255.0, green: 144.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            activePerson = -1
        } else {
            cell.personImage.backgroundColor = UIColor.gray
            if(activePerson != -1) {
                let activeIndexPath = NSIndexPath(row: activePerson, section: indexPath.section) as IndexPath
                let activeCell:PersonTag = collectionView.cellForItem(at: activeIndexPath) as! PersonTag
                activeCell.personImage.backgroundColor = UIColor(displayP3Red: 0.0/255.0, green: 144.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            }
            activePerson = indexPath.row
        }
    }
}


extension AddTodoController : UICollectionViewDelegate {
    
}

