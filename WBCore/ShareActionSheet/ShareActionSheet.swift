//
//  ShareActionSheet.swift
//  Blena
//
//  Created by Lê Vinh on 10/18/24.
//

import Foundation
import UIKit

class ShareActionSheet{
    static let shared = ShareActionSheet()
    
    public func shareActionSheet(viewController: UIViewController, url: URL){
        let actionSheet = UIAlertController(title: "Share As", message: "What type do you want to share", preferredStyle: .actionSheet)
                
                // Add actions
                actionSheet.addAction(UIAlertAction(title: "URL", style: .default, handler: { (action) in
                    self.sharePage(url: url, viewController: viewController)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Blena URL", style: .default, handler: { (action) in
                    let webUrlString = url.absoluteString
                    let blenaUrlString = "blena://open?url=\(webUrlString)"
                    let blenaURL = URL(string: blenaUrlString)!
                    self.sharePage(url: blenaURL, viewController: viewController)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    print("Cancel selected")
                }))
        
        // Configure popoverPresentationController for iPads
                if let popoverPresentationController = actionSheet.popoverPresentationController {
                    popoverPresentationController.sourceView = viewController.view
                    popoverPresentationController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                                      y: viewController.view.bounds.midY,
                                                                      width: 0,
                                                                      height: 0)
                    popoverPresentationController.permittedArrowDirections = []
                }
                
                // Present the action sheet
                viewController.present(actionSheet, animated: true, completion: nil)
        
    }
    
    private func sharePage(url: URL, viewController: UIViewController){
        // Create the activity view controller
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        // Exclude certain activity types if necessary
        activityViewController.excludedActivityTypes = [.print, .assignToContact, .saveToCameraRoll, UIActivity.ActivityType(rawValue: "com.nhb.blena.shareextension"), UIActivity.ActivityType(rawValue: "com.nhb.blena.widget")]

        // Configure popoverPresentationController for iPads
               if let popoverPresentationController = activityViewController.popoverPresentationController {
                   popoverPresentationController.sourceView = viewController.view
                   popoverPresentationController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                                     y: viewController.view.bounds.midY,
                                                                     width: 0,
                                                                     height: 0)
                   popoverPresentationController.permittedArrowDirections = []
               }
        
        // Present the activity view controller
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}
