//
//  ShoppingViewController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class ShoppingViewController: UIViewController {
    
    private var shoppingList: [String] = ["Eier", "Mehl", "Salz"]

    @IBOutlet weak var shoppingTable: UITableView!
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
        shoppingTable.dataSource = self
        shoppingTable.delegate = self
    }
   

}



extension ShoppingViewController : UITableViewDelegate {

}

extension ShoppingViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection number: Int) -> Int {
        return shoppingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as? TodoCell else {
            fatalError("Cell could not be cast")
        }
        cell.person.text = ""
        cell.title.text = shoppingList[indexPath.row]
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

        label.text = "Einkaufsliste"
  
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
