//
//  CalendarEventCell.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 13.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class CalendarEventCell: UITableViewCell {

    @IBOutlet weak var eventTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var eventDescription: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
