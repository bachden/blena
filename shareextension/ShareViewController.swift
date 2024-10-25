//
//  ActionViewController.swift
//  widget
//
//  Created by Lê Vinh on 10/18/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Retrieve the first item shared.
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            completeExtensionRequest()
            return
        }

        // Check if the shared content is a URL.
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                if let error = error {
                    NSLog("Error loading URL: \(error.localizedDescription)")
                    self.completeExtensionRequest()
                    return
                }

                if let url = item as? URL {
                    // Send a notification with the received URL.
                    self.openApp(url: url)
                } else {
                    NSLog("Shared item is not a valid URL.")
                    self.completeExtensionRequest()
                }
            }
        } else {
            NSLog("No URL found in shared content.")
            completeExtensionRequest()
        }
    }

    private func completeExtensionRequest() {
        // Finish the extension context to dismiss the Share Extension.
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        NSLog("done")
    }

    func openApp(url: URL) {
        var cleanURL = url
        if url.absoluteString.contains("blena://open?url=") {
            // Remove the "blena://" prefix from the URL
            let cleanedUrlString = url.absoluteString.replacingOccurrences(of: "blena://open?url=", with: "")
            cleanURL = URL(string: cleanedUrlString)!
            print("Cleaned URL: \(cleanedUrlString)")
        }
        let scheme = "blena://open?url=\(cleanURL.absoluteString)"
            guard let appURL = URL(string: scheme) else {
                print("Invalid URL: \(scheme)")
                return
            }

            // Traverse the responder chain to find an instance of UIApplication
            var responder = self as UIResponder?
            responder = (responder as? UIViewController)?.parent

            while responder != nil && !(responder is UIApplication) {
                responder = responder?.next
            }

            if let application = responder as? UIApplication {
                // Use the modern open(_:options:completionHandler:) method
                application.open(appURL, options: [:], completionHandler: { success in
                    if success {
                        print("Successfully opened app with URL: \(appURL)")
                        self.completeExtensionRequest()
                    } else {
                        print("Failed to open app with URL: \(appURL)")
                        self.completeExtensionRequest()
                    }
                })
            } else {
                print("UIApplication not found in responder chain.")
                self.completeExtensionRequest()
            }
        }
}
