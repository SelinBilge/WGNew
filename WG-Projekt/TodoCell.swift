//
//  TodoCell.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

//Delegate for accessing the TodoViewController
protocol TodoCellDelegate: class {
    func checkEntry(index: IndexPath, id: String, done: Bool)
}

class TodoCell: UITableViewCell {
    weak var delegate: TodoCellDelegate?
    var id: String!
    var index: IndexPath!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var person: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //The check Entry method of the delegate is clicked
    @IBAction func doneClicked(_ sender: Any) {
        var done = true
        if(index.section == 2) {
            done = false
        }
        delegate?.checkEntry(index: index, id: id, done: done)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Style of the cell
    override func layoutSubviews() {
            super.layoutSubviews()
            self.contentView.clipsToBounds = true
            self.contentView.layer.cornerRadius = 15
            self.contentView.backgroundColor = UIColor.systemGray5
            //set the values for top,left,bottom,right margins
            let margins = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
            contentView.frame = contentView.frame.inset(by: margins)
    
    }
}
