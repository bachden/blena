//
//  ConnectDeviceViewController.swift
//  Blena
//
//  Created by Lê Vinh on 10/11/24.
//

import Foundation
import UIKit


class ConnectDeviceViewController : UIViewController {
    @IBOutlet weak var topDivider: UIView!
    @IBOutlet weak var nearbyDevicesText: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var wbManager: WBManager!
    
    
    var selectedCell: BluetoothTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "BluetoothTableViewColumn", bundle: nil)
        tableView
            .register(nib, forCellReuseIdentifier: "BluetoothTableViewColumn")
                refreshButton.titleLabel?.text = ""
        topDivider.backgroundColor = UIColor(hex: "#E0E0E0")
        topDivider.layer.cornerRadius = 3
        nearbyDevicesText.textColor = UIColor(hex: "#9E9E9E")
        tableView.delegate = wbManager
        tableView.dataSource = wbManager
        tableView.reloadData()
    }
    
    @IBAction func refresh(_ sender: Any) {
        wbManager.refreshData()
    }
    
    // Define a closure that will be called when the VC is dismissed
    var onDismiss: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Check if the view controller is being dismissed
        if self.isBeingDismissed {
            wbManager.cancelDeviceSearch()  // Call the closure when dismissed
        }
    }
}


class BluetoothTableViewCell : UITableViewCell {
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var expandableStack: UIStackView!
    
    // Track the hidden state of details
    var areDetailsHidden = true
    
    var connectAction: (() -> Void)?
    var tableViewClose: (() -> Void)?
        
    // Set up the button and other styles when the view is loaded from the nib
    override func awakeFromNib() {
        super.awakeFromNib()
            
        // Style the Connect button
        connectButton.layer.cornerRadius = 10
        connectButton.layer.borderWidth = 1.0
        connectButton.layer.borderColor = UIColor.systemBlue.cgColor
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.setTitleColor(.lightGray, for: .highlighted)
        connectButton.backgroundColor = .systemBlue
            
        // Initial state: hide the UUID and description labels
        uuidLabel.isHidden = true
        descriptionLabel.isHidden = true
        areDetailsHidden = true
            
        // Add animation
        connectButton
            .addTarget(
                self,
                action: #selector(connectButtonTapped),
                for: .touchUpInside
            )
    }
        
    // Function to configure the cell's content
    func configure(with name: String, uuid: String, description: String, connecAction: @escaping ()->Void, closeTableView: @escaping ()->Void) {
        deviceName.text = name
        uuidLabel.text = "UUID: \(uuid)"
        descriptionLabel.text = "Description: \(description)"
            
        // Ensure the details are hidden initially
        self.expandableStack.isHidden = true
        self.areDetailsHidden = true
        self.connectAction = connecAction
        self.tableViewClose = closeTableView
    }
        
    // Toggle the details with animation
    func toggleDetails() {
        self.areDetailsHidden.toggle()
            
        UIView.animate(withDuration: 0.3) {
            self.expandableStack.isHidden = false
            self.layoutIfNeeded()  // This will ensure Auto Layout is updated with the animation
        }
    }
        
    // Example action for the Connect button
    @objc func connectButtonTapped() {
        Task {
            tableViewClose?()
            connectAction?()
        }
        print(
            "Connect button tapped for device: \(deviceName.text ?? "Unknown")"
        )
                    
        // Animate button scaling effect
        UIView.animate(
            withDuration: 0.1,
            animations: {
                // Scale down (shrink) the button slightly
                self.connectButton.transform = CGAffineTransform(
                    scaleX: 0.95,
                    y: 0.95
                )
            },
            completion: { _ in
                // Scale back to original size with a bounce effect
                UIView
                    .animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
                        self.connectButton.transform = CGAffineTransform.identity  // Reset to original size
                    }, completion: nil)
            })
                    
        // Optional: Change button background color briefly during the animation
        UIView.animate(withDuration: 0.2) {
            self.connectButton.backgroundColor = .systemGreen
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.connectButton.backgroundColor = .systemBlue  // Revert back to original color
            }
        }
    }
}
