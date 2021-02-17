//
//  TodoViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
import Firebase

//Sections for Todo
struct Section{
    let name: String
    var entries: [Todo]
}

//One Totdo Object
struct Todo: Codable{
    let title: String
    var done: Bool
    var person: String
    var due: Date
    var id: String
}

//Date Formatter for Firestore
var dateFormatterFB: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter
}()


class TodoViewController: UIViewController {
    //Array that stores the todo sectios
    private var todos: [Section] = []
    private var chosenTodo: Todo!
    let db = Firestore.firestore()

    @IBOutlet weak var todoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        //Create 3 Sections. Call fetch data
        todos = [
            Section(name: "bis Heute", entries: []),
            Section(name: "Demnächst", entries: []),
            Section(name: "Erledigt", entries: [])]
        fetchData()
        
        todoTable.delegate = self
        todoTable.dataSource = self
    }
    
    //Is called upon return from addTodoVC. The newTodo stored in the addTodoVC is fetched and added to the Database.
    //Afterwards, the data is reloaded
    @IBAction func unwindToCalendarView(segue: UIStoryboardSegue) {
        let vc = segue.source as! AddTodoController
        let newTodo = vc.newTodo!
        let stringDate = dateFormatterFB.string(from: newTodo.due)
        
        let ref = db.collection("todo").document("idx").collection("do")
        ref.addDocument(data: [
            "done": false,
            "due": stringDate,
            "person": newTodo.person,
            "title": newTodo.title,
        ]) { err in
            if err != nil {
                print("Error adding Todo")
            } else {
                print("Todo added")
                self.fetchData()
            }
        }
    }
    
    //Fetches data from firestore. Clears the entries of the 3 Sections.
    //Depending on the Date, the entries are stored in their sections accordingly
    func fetchData() {
        todos[0].entries = []
        todos[1].entries = []
        todos[2].entries = []
        
        let collectionRef = db.collection("todo").document("idx").collection("do")
        collectionRef.getDocuments { (querySnapshot, err) in
            if let docs = querySnapshot?.documents {
                for docSnapshot in docs {
                    let data = docSnapshot.data()
                    let stringDate = data["due"] as! String
                    let date = dateFormatterFB.date(from: stringDate)!
                    let todoEntry: Todo = Todo(title: data["title"] as! String, done: data["done"] as! Bool, person: data["person"] as! String, due: date , id: docSnapshot.documentID )
                    
                    let calendar = Calendar.current
                    if(todoEntry.done) {
                        self.todos[2].entries.append(todoEntry)
                    } else if(calendar.isDateInToday(date)) {
                        self.todos[0].entries.append(todoEntry)
                    } else {
                        self.todos[1].entries.append(todoEntry)
                    }
                    
                }
                self.todoTable.reloadData()
            }
        }
    }
    
    
    // Delete a Todo and fetch data afterwards
    func deleteTodo(id: String, indexPath: IndexPath) {
        let ref = db.collection("todo").document("idx").collection("do").document(id)
        ref.delete() { err in
            if let err = err {
                print("Unable to delete document, reason: \(err)")
            } else {
                print("Data deleted successfully")
                self.fetchData()
            }
        }
    }
    
    //Prepare to show detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "todoDetail") {
            //get chosen variables and set them in destination vc
            let vc = (segue.destination as! TodoDetailViewController)
            vc.todo = chosenTodo
        }
    }
    
    //unwind from todo detail
    @IBAction func unwindToTodo(segue: UIStoryboardSegue) {

    }

}

// Extension for the Cell Delegate. Cells can communicate with the VC via the delegate.
extension TodoViewController: TodoCellDelegate {
    
    //Is called when a cell checkbox is clicked. The id of the cell, the index of the cell and whether it is done or not,
    // is passed.
    // The Todo is updated in firestore with the done variable. Then fetchData is called
    func checkEntry(index: IndexPath, id: String, done: Bool) {
        let ref = db.collection("todo").document("idx").collection("do").document(id)
        ref.updateData([
                "done": done
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
extension TodoViewController : UITableViewDataSource {
    
    // Returns the number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return todos.count
    }
    
    //Number of entries in each Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection number: Int) -> Int {
        return todos[number].entries.count
    }
    
    //Height of section footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (todos[section].entries.count == 0) {
            return 80
        }
        return 30
    }
    
    //Height of section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTodo = todos[indexPath.section].entries[indexPath.row]
        performSegue(withIdentifier: "todoDetail", sender: nil)
    }
    
    // Delete Swipe Action Configuration
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let id = todos[indexPath.section].entries[indexPath.row].id
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                self.deleteTodo(id: id, indexPath: indexPath)
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as? TodoCell else {
            fatalError("Cell could not be cast")
        }
        
        //Cell Sytyle
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.backgroundColor = UIColor.white.cgColor
        
        //Cell properties
        cell.index = indexPath
        cell.id = todos[indexPath.section].entries[indexPath.row].id
        cell.delegate = self
        cell.person.text = todos[indexPath.section].entries[indexPath.row].person
        
        //Depending on the section, the Title is crossed through and the checkbox is marked
        let titleText = todos[indexPath.section].entries[indexPath.row].title
        if(indexPath.section == 2) {
            cell.checkBox.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: titleText)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.title.attributedText = attributeString
        } else {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: titleText)
            cell.title.attributedText = attributeString
            cell.checkBox.setImage(UIImage(systemName: "circle"), for: .normal)
            
        }
        return cell
    }
    
    
    //Footer creation
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var text = ""
        if (todos[section].entries.count == 0) {
            switch section {
            case 0:
                text = "HEUTE KEINE TODOS"
            case 1:
                text = "DEMNÄCHST KEINE TODOS"
            case 2:
                text = "LISTE LEER"
            default:
                text = ""
            }
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

    
    //Header creation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Create Subview
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.font = label.font.withSize(17)
        label.text =  todos[section].name
        
        let lineView = UIView(frame: CGRect(x: 0, y: 45, width: tableView.frame.width, height: 1.0))
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.systemGray5.cgColor
        
        //Set the text color accordingly to the section
        if(section == 2) {
            label.textColor = UIColor.gray
        } else {
            label.textColor = UIColor(displayP3Red: 32.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        }

        //Merge and return Subviews
        headerView.addSubview(label)
        headerView.addSubview(lineView)
        return headerView
    }
}


//Gradient for the NavigationBar
extension CAGradientLayer {

    class func primaryGradient(on view: UIView) -> UIImage? {
        let gradient = CAGradientLayer()
        let flareRed = UIColor(displayP3Red: 32.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        let flareOrange = UIColor(displayP3Red: 0.0/255.0, green: 124.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        var bounds = view.bounds
        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds
        gradient.colors = [flareRed.cgColor, flareOrange.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        return gradient.createGradientImage(on: view)
    }

    private func createGradientImage(on view: UIView) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}


extension TodoViewController : UITableViewDelegate {
    
}
