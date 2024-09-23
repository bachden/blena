//
//  ConsoleScrollView.swift
//  BleBrowser
//
//  Created by David Park on 23/09/2018.
//  Copyright © 2018 David Park. All rights reserved.
//

import UIKit

class ConsoleScrollView: UIScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.subviews.count > 0 else {
            NSLog("No subviews yet")
            return
        }
        let scrollView = self.subviews[0]
        if self.contentSize != scrollView.frame.size {
            self.contentSize = scrollView.frame.size
        }
    }
    override func didAddSubview(_ subview: UIView) {
        guard self.subviews.count == 1 else {
            return
        }
        let constr = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([constr])
    }
}
