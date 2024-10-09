//
//  SettingViewController.swift
//  Blena
//
//  Created by Lê Vinh on 10/3/24.
//

import Foundation
import UIKit
import WebKit

class SettingViewController: UIViewController {
    var button : UIButton!
    
    @IBOutlet var backButton : UIButton!
    
    @IBOutlet var clearCacheButton : UIStackView!
    @IBOutlet var clearHistoryButton : UIStackView!
    @IBOutlet var privacyPolicyButton : UIStackView!
    @IBOutlet var forwardButton : UIButton!
    @IBOutlet var supportUsButton : UIStackView!
    @IBOutlet var showScriptButton : UIStackView!
    
    override func viewDidLoad() {
            super.viewDidLoad()

            // Customize the corner radius or background appearance
            view.layer.cornerRadius = 20
            view.layer.masksToBounds = true
        
            // Add tap logic
        // Add a tap gesture recognizer to the view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let clearCacheGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let privacyPolicyGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let supportUsGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let showScriptGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.clearCacheButton.addGestureRecognizer(tapGesture)
        self.clearHistoryButton.addGestureRecognizer(clearCacheGesture)
        self.privacyPolicyButton.addGestureRecognizer(privacyPolicyGesture)
        self.supportUsButton.addGestureRecognizer(supportUsGesture)
        self.showScriptButton.addGestureRecognizer(showScriptGesture)
        
        // Enable user interaction
        self.clearCacheButton.isUserInteractionEnabled = true
        self.clearHistoryButton.isUserInteractionEnabled = true
        self.privacyPolicyButton.isUserInteractionEnabled = true
        self.forwardButton.setTitle("", for: UIControl.State.normal)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Set the preferred size of the view controller
            self.preferredContentSize = CGSize(width: self.view.frame.width, height: UIScreen.main.bounds.height * 2 / 3)
        }
    
    @IBAction func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.1,
                               animations: {
                    // Visual feedback: make the view slightly smaller
            sender.view!.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { _ in
                    // Return to normal size with bounce effect
                    UIView.animate(withDuration: 0.1,
                                   delay: 0.1,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 3,
                                   options: .allowUserInteraction,
                                   animations: {
                        sender.view!.transform = .identity // Reset the scale
                    }, completion: nil)
                }
        switch sender.view {
        case self.clearCacheButton:
            removeAllBrowserData()
        case self.clearHistoryButton:
            removeHistory()
        case self.privacyPolicyButton:
            self.goToPrivacyPolicy()
        case self.supportUsButton:
            self.supportUsFunction()
        case self.showScriptButton:
            self.scriptDebugViewer()
        default:
            break
        }
    }
    
    // MARK: Remove all data
    func removeAllBrowserData() {
        let alertActionController = UIAlertController(title: "Clear Cache", message: "Are you sure you want to clear cache?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.clearAllWKWebViewData()
            self.view.makeToast("Cache cleared successfully.")
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertActionController.addAction(yesAction)
        alertActionController.addAction(noAction)
        present(alertActionController, animated: true, completion: nil)
    }
    
    func clearAllWKWebViewData() {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes() // All data types
        let dateFrom = Date(timeIntervalSince1970: 0) // Clear all data since epoch
        
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
            print("Cleared all website data (cookies, cache, local storage, etc.).")
        }
    }
    
    // Mark: Remove history
    func removeHistory() {
        let alertActionController = UIAlertController(title: "Clear History", message: "Are you sure you want to remove history?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.removeAllHistory()
            self.view.makeToast("History has been cleared successfully.")
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertActionController.addAction(yesAction)
        alertActionController.addAction(noAction)
        present(alertActionController, animated: true, completion: nil)
    }
    
    func removeAllHistory() {
        NSLog("Remove history")
    }
    
    // Mark: Privacy Policy
    func goToPrivacyPolicy() {
        NSLog("Privacy Policy")
    }
    
    func supportUsFunction() {
        NSLog("Support Us")
        let url = URL(string: "a.v")!
        guard UIApplication.shared.canOpenURL(url) else {
            let alert = UIAlertController(title: "Can't open URL",message: "Can't navigate to this URL.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func scriptDebugViewer() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "ScriptLogViewer") as? ScriptLogViewer {
            settingsVC.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = settingsVC.sheetPresentationController {
                    // Customize detents (heights) for the bottom sheet
                    sheet.detents = [.large()] // Medium and large sizes
                    sheet.largestUndimmedDetentIdentifier = .large
                }
            } else {
                // Fallback on earlier versions
            }

            // Present the bottom sheet
            self.present(settingsVC, animated: true, completion: nil)
        }
    }
}
