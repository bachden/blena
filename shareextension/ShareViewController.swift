import UIKit
import UniformTypeIdentifiers
import Social

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
                    // Open the main app with the received URL.
                    self.openMainApp(with: url)
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
    
    private func openMainApp(with url: URL) {
        // Encode the URL string to make sure it can be passed as a parameter.
        let encodedURLString = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url.absoluteString
        let customURLString = "myapp://open?url=\(encodedURLString)"
        
        if let appURL = URL(string: customURLString) {
            extensionContext?.open(appURL, completionHandler: { success in
                if success {
                    NSLog("Successfully opened the main app with URL.")
                } else {
                    NSLog("Failed to open the main app.")
                }
                // Always complete the request after attempting to open the main app.
                self.completeExtensionRequest()
            })
        } else {
            NSLog("Failed to create app URL.")
            completeExtensionRequest()
        }
    }

    private func completeExtensionRequest() {
        // Finish the extension context to dismiss the Action Extension.
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
