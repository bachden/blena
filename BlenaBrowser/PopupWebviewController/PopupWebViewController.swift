//
//  PopupWebViewController.swift
//  Blena
//
//  Created by Lê Vinh on 04/03/2025.
//

import Foundation
import UIKit
import WebKit

class PopupWebViewController : UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var safari_open: UIButton!
    
    var webkitView: WKWebView!
    
    var urlString: String? // Property to receive the URL

        
        override func viewDidLoad() {
            super.viewDidLoad()
            let webCfg = WKWebViewConfiguration()
            if #available(iOS 14.0, *) {
                let webpagePreferences = WKWebpagePreferences()
                webpagePreferences.allowsContentJavaScript = true
                webCfg.preferences.javaScriptEnabled = true
                webCfg.preferences.javaScriptCanOpenWindowsAutomatically = true
                webCfg.defaultWebpagePreferences = webpagePreferences
            } else {
                webCfg.preferences.javaScriptEnabled = true
                webCfg.preferences.javaScriptCanOpenWindowsAutomatically = true
            }

            if #available(iOS 15.4, *) {
                webCfg.preferences.isElementFullscreenEnabled = true
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 17.0, *) {
                webCfg.allowsInlinePredictions = true
            } else {
                // Fallback on earlier versions
            }
            
            webCfg.preferences.javaScriptCanOpenWindowsAutomatically = true
            webCfg.defaultWebpagePreferences.allowsContentJavaScript = true
            webCfg.defaultWebpagePreferences.preferredContentMode = .mobile
            

            webCfg.websiteDataStore = WKWebsiteDataStore.default()

            // Set up the user agent name to include an app specific append rather
            // than just the default WKWebView build number
            // This declares us as Blena but also includes the system
            // version so that
            // https://bowser-js.github.io/bowser-online/
            // will think we're Safari
            let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "<no-version>"
            let bundleName = Bundle.main.infoDictionary?["CFBundleName"] ?? "<no-app-name>"
            let shortOSVersion = (
                UIDevice.current.systemVersion.replacingOccurrences(
                    of: "(\\d+\\.\\d+)(.\\d+)?$", with: "$1", options: [.regularExpression]
                )
            )
            webCfg.applicationNameForUserAgent = (
                "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1 OPT/5.2.0"
            )
            
            webkitView = WKWebView(frame: .zero, configuration: webCfg)
            webkitView.scrollView.isScrollEnabled = true
//            webkitView.allowsBackForwardNavigationGestures = false
            webkitView.navigationDelegate = self
            
            // Add WebView to View
                    view.addSubview(webkitView)

                    // Apply AutoLayout Constraints
                    webkitView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        webkitView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 10),
                        webkitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        webkitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        webkitView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    ])

                    // Load URL if available
                    if let urlString = urlString, let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        webkitView.load(request)
                    }
        }
        
        @IBAction func dismissPopup(_ sender: UIButton) {
            dismiss(animated: true, completion: nil)
        }
    
    @IBAction func openLinkInSafari(_ sender: UIButton) {
        if let urlString = addressTextField.text, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

extension PopupWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            print("WebView is loading: \(url.absoluteString)")
            
            // **Update the text field with the current URL**
            addressTextField.text = url.absoluteString
        }

        decisionHandler(.allow)
    }
}
