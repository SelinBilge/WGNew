//
//  GradientView.swift
//  WG-Projekt
//
//  Created by Selin Bilge on 10.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit
@IBDesignable
class GradientView: UIView {
    
    
    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.3877317208, green: 0.5741714384, blue: 1, alpha: 1)
    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.4023113676, green: 1, blue: 0.8214523969, alpha: 1)
    
    
    var startPointX: CGFloat = 0
    var startPointY: CGFloat = 0
    var endPointX: CGFloat = 1
    var endPointY: CGFloat = 1
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)

    }

    
}
