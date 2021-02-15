//
//  PollResultCell.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 15.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class PollResultCell: UITableViewCell {

    @IBOutlet weak var pollTitle: UILabel!
    @IBOutlet weak var pollResult: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
