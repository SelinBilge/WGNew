//
//  CalendarCell.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class CalendarCell: UITableViewCell {

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
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
