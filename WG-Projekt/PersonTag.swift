//
//  PersonTag.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

class PersonTag: UICollectionViewCell {
    
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
