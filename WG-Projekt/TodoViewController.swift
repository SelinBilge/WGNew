//
//  TodoViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

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

struct Section{
    let name: String
    var entries: [Todo]
}

struct Todo{
    let title: String
    var done: Bool
    var person: String
    var due: Int
}

class TodoViewController: UIViewController {
    private var todos: [Section] = []

    @IBOutlet weak var todoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        guard
            let navigationController = navigationController,
            let flareGradientImage = CAGradientLayer.primaryGradient(on: navigationController.navigationBar)
            else {
                print("Error creating gradient color!")
            return
            }

        navigationController.navigationBar.barTintColor = UIColor(patternImage: flareGradientImage)
        
        //todoTable.rowHeight = 60
        //todoTable.estimatedRowHeight = 100
        todos = [
            Section(name: "bis Heute", entries: [
                        Todo(title: "Staubsaugen", done: false, person: "Paul", due: 0),]),
            Section(name: "Demnächst", entries: [
                        Todo(title: "Bad putzen", done: false, person: "Emil", due: 2),
                        Todo(title: "Blumen gießen", done: false, person: "Hanna", due: 3)]),
            Section(name: "Erledigt", entries: [
                        Todo(title: "Müll rausbringen", done: true, person: "Jerome", due: -2
                    )])]
        
        todoTable.delegate = self
        todoTable.dataSource = self
    }

}

extension TodoViewController : UITableViewDelegate {

}

extension TodoViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection number: Int) -> Int {
        return todos[number].entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as? TodoCell else {
            fatalError("Cell could not be cast")
        }
        cell.person.text = todos[indexPath.section].entries[indexPath.row].person
        cell.title.text = todos[indexPath.section].entries[indexPath.row].title
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.backgroundColor = UIColor.white.cgColor
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text =  todos[section].name
        label.font = label.font.withSize(17)
        if(section == 2) {
            label.textColor = UIColor.gray
        } else {
            label.textColor = UIColor(displayP3Red: 32.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        }

        headerView.addSubview(label)

        let lineView = UIView(frame: CGRect(x: 0, y: 45, width: tableView.frame.width, height: 1.0))
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.systemGray5.cgColor
        headerView.addSubview(lineView)
        
        return headerView
    }
}

