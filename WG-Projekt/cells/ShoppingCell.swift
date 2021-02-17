//
//  ShoppingCell.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 17.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

//Delegate for accessing the TodoViewController
protocol ShoppingCellDelegate: class {
    func checkEntry(index: IndexPath, id: String, bought: Bool)
}

class ShoppingCell: UITableViewCell {
    weak var delegate: ShoppingCellDelegate?
    var indexPath: IndexPath!
    var id: String!


    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func doneButtonClicked(_ sender: Any) {
        var bought = true
        if(indexPath.section == 1) {
            bought = false
        }
        delegate?.checkEntry(index: indexPath, id: id, bought: bought)
    }
}
