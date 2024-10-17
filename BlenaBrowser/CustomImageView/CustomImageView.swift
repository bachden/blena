//
//  CustomImageView.swift
//  Blena
//
//  Created by Lê Vinh on 27/9/24.
//

import Foundation
import UIKit

class CustomImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()

        // Create a UIBezierPath with rounded corners only at the top-left and top-right
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 16, height: 16))

        // Create a shape layer and set the path to it
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        layer.shadowColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5

        // Set the mask to the image view's layer
        layer.mask = maskLayer
        let shadowPath = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [.topLeft, .topRight],
                                      cornerRadii: CGSize(width: 10, height: 10))
        layer.shadowPath = shadowPath.cgPath
    }
}
