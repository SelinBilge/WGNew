//
//  TodoDetailViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 17.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

var dateFormatterWOY: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM"
    return formatter
}()

class TodoDetailViewController: UIViewController {
    var todo: Todo!

    @IBOutlet weak var transparentTop: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var todoDescription: UILabel!
    @IBOutlet weak var todoUsers: UILabel!
    @IBOutlet weak var todoStatus: UILabel!
    @IBOutlet weak var todoDue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Border Radius
        bottomView.clipsToBounds = true
        bottomView.layer.cornerRadius = 15
        bottomView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        //Shadow
        bottomView.layer.masksToBounds = false
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.3
        bottomView.layer.shadowOffset = CGSize(width: -1, height: 1)
        bottomView.layer.shadowRadius = 3
        bottomView.layer.shouldRasterize = true
        bottomView.layer.rasterizationScale = true ? UIScreen.main.scale : 1
        
        //Tab recoginzer  
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        transparentTop.addGestureRecognizer(tap)
        
        todoTitle.text = todo.title
        todoUsers.text = todo.person
        todoDue.text = dateFormatterTime.string(from: todo.due) + " " + dateFormatterWOY.string(from: todo.due)
        todoDescription.text = "Keine Beschreibung"
        if(todo.done) {
            todoStatus.text = "erledigt"
        } else {
            todoStatus.text = "ausstehend"
        }
        

        // Do any additional setup after loading the view.
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        performSegue(withIdentifier: "unwindToTodo", sender: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        performSegue(withIdentifier: "unwindToTodo", sender: nil)
    }


}
