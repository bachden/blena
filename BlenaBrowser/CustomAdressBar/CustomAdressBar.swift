//
//  CustomAdressBar.swift
//  Blena
//
//  Created by Lê Vinh on 10/1/24.
//

import Foundation
import UIKit

extension CustomAdressBar {
    enum State {
        case editing
        case inactive
    }
}

class CustomAdressBar : UITextField {
    private let reloadButton = UIButton(type: .system)

    var activityState = State.inactive {
        didSet {
            switch activityState {
            case .editing:
                placeholder = nil
                rightView = nil
                selectAll(nil)
                textColor = .black
            case .inactive:
                rightView = hasText ? reloadButton : nil
                textColor = .black
            }
        }
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = CGFloat(16)
        let height = CGFloat(16)
        let y = (bounds.height - height) / 2
        return CGRect(
            x: bounds.width - width - 5,
            y: y,
            width: width,
            height: height
        )
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        layer.cornerRadius = 12
        backgroundColor = .white
        clearButtonMode = .whileEditing
        returnKeyType = .go
        rightViewMode = .always
        autocorrectionType = .no
        autocapitalizationType = .none
        keyboardType = .webSearch
        enablesReturnKeyAutomatically = true
        clipsToBounds = true
        setupReloadButton()
        activityState = .inactive
    }

    func setupReloadButton() {
        reloadButton
            .setImage(
                UIImage(systemName: "arrow.clockwise")?
                    .withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        reloadButton.imageView?.contentMode = .scaleAspectFit
        reloadButton.tintColor = .black
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews {
            if let button = view as? UIButton {
                button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.tintColor = .black
            }
        }
    }


}
