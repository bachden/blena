//
//  URLTextField.swift
//  Moodi
//
//  Created by David Park on 08/04/2022.
//

import UIKit

class URLTextField: UITextField {
    var alreadyWasFirstResponder = false
    var superViewConstraints: [NSLayoutConstraint] = []

    override func becomeFirstResponder() -> Bool {
        let answer = super.becomeFirstResponder()
        if !self.alreadyWasFirstResponder {
            self.alreadyWasFirstResponder = true
            self.selectAll(nil)
        }
        return answer
    }
    override func resignFirstResponder() -> Bool {
        let answer = super.resignFirstResponder()
        self.alreadyWasFirstResponder = false
        return answer
    }

    override func didMoveToSuperview() {
        if self.superViewConstraints.count > 0 {
            NSLayoutConstraint.deactivate(self.superViewConstraints)
        }

        if let sv = self.superview {
            // Remove any pre-existing constraints on the URLTextField to prevent conflicts
            self.removeConstraints(self.constraints.filter { $0.firstAttribute == .leading || $0.firstAttribute == .trailing })

            // Add new constraints as needed
            self.superViewConstraints = [
                self.leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: 0),
                self.trailingAnchor.constraint(lessThanOrEqualTo: sv.trailingAnchor, constant: 0)
            ]
            NSLayoutConstraint.activate(self.superViewConstraints)
        }
    }
}
