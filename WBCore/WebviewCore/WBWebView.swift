//
//  WBWebView.swift
//  BleBrowser
//
//  Created by David Park on 22/12/2016.
//  Copyright 2016-2017 David Park. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit
import WebKit
import AuthenticationServices

class WebViewHistory: WKBackForwardList {

    /* Solution 1: return nil, discarding what is in backList & forwardList */

    override var backItem: WKBackForwardListItem? {
        return nil
    }

    override var forwardItem: WKBackForwardListItem? {
        return nil
    }

    /* Solution 2: override backList and forwardList to add a setter */

    var myBackList = [WKBackForwardListItem]()

    override var backList: [WKBackForwardListItem] {
        get {
            return myBackList
        }
        set(list) {
            myBackList = list
        }
    }

    func clearBackList() {
        backList.removeAll()
    }
}

class WBWebView: WKWebView, WKNavigationDelegate {
    
    private var popupWebView: WKWebView?
    
    let webBluetoothHandlerName = "bluetooth"
    private var _wbManager: WBManager?
    var wbManager: WBManager? {
        get {
            return self._wbManager
        }
        set(newWBManager) {
            if self._wbManager != nil {
                self.configuration.userContentController.removeScriptMessageHandler(forName: self.webBluetoothHandlerName)
            }
            self._wbManager = newWBManager
            if let newMan = newWBManager {
                self.configuration.userContentController.add(newMan, name: self.webBluetoothHandlerName)
            }
        }
    }

    private var _navDelegates: [WKNavigationDelegate] = []
    

    // MARK: - Initializers
    required public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.allowsLinkPreview = true
    }
    
    override func goBack() -> WKNavigation? {
        if let backItem = self.backForwardList.backItem{
            let url = backItem.url
            let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
            ud.set(url, forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue)
        }
            
        // Allow normal back navigation for other URLs
        return super.goBack()
    }
    
    override func goForward() -> WKNavigation? {
        if let forwardItem = self.backForwardList.forwardItem{
            let url = forwardItem.url
            let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
            ud.set(url, forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue)
        }
        
        return super.goForward()
    }
    
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        NSLog("catch")
    }
    
    
    // WKNavigationDelegate method: Catch URL changes and update the URL bar
       func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
           if(navigationAction.shouldPerformDownload){
               decisionHandler(.download)
               return
           }
           
           if let url = navigationAction.request.url {
               NSLog(url.absoluteString)
           }
//           if let url = navigationAction.request.url {
//               // Detect Google OAuth 2.0 URL
//               if url.host == "accounts.google.com" && (url.path.contains("oauth") || url.path.contains("gsi")) {
//                   print("Detected Google OAuth 2.0 URL: \(url.absoluteString)")
//                   // Handle Google Sign-In here
//                   handleGoogleSignIn(url: url)
//                   decisionHandler(.cancel)
//                   return
//                }else {
//                   decisionHandler(.allow)
//           }
//           }
           decisionHandler(.allow)
//           if navigationAction.request.url?.absoluteString.contains("gsi/select") == true {
//                   webView.load(navigationAction.request)
//                   decisionHandler(.cancel) // Prevent new window creation
//               } else {
//           if navigationAction.request.url?.absoluteString.contains("gsi/select") == true {
//               webView.load(navigationAction.request)
//               decisionHandler(.cancel) // Prevent new window creation
//           } else {
//           }
//               }
       }
       
    func handleGoogleSignIn(url: URL) {
            // Open in ASWebAuthenticationSession for secure authentication
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "blena") { callbackURL, error in
                if let error = error {
                    print("Authentication error: \(error.localizedDescription)")
                    return
                }
                if let callbackURL = callbackURL {
                    print("Authentication success: \(callbackURL.absoluteString)")
                    // Handle the callback
                    self.processCallback(url: callbackURL)
                }
                
            }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let window = appDelegate?.window
        let rootVC = window?.rootViewController as? UINavigationController
        let viewController = rootVC?.topViewController as? ViewController
            session.presentationContextProvider = viewController
            session.start()
        }

        func processCallback(url: URL) {
            let queryItems = URLComponents(string: url.absoluteString)?.queryItems
            if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                print("Authorization code: \(code)")
                // Exchange the code for tokens
            }
        }
    
    // Correctly overriding the WKNavigationDelegate method
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            // Check if the MIME type can be displayed
            if navigationResponse.canShowMIMEType {
                NSLog(navigationResponse.response.mimeType!)
                if(MimeTypeHandler().isDownloadable(mimeType: navigationResponse.response.mimeType!)){
                    decisionHandler(.download)
                } else{
                    decisionHandler(.allow)
                }
            } else {
                if #available(iOS 14.5, *) {
                    // If the MIME type can't be displayed, start the download (iOS 14.5+)
                    decisionHandler(.download)
                } else {
                    // Fallback for older iOS versions (just cancel the request)
                    decisionHandler(.cancel)
                }
            }
        }

    convenience public required init?(coder: NSCoder) {
        // load polyfill script
        let webCfg = WKWebViewConfiguration()
        let userController = WKUserContentController()
        
        
        
        webCfg.userContentController = userController
        webCfg.allowsInlineMediaPlayback = true
        webCfg.allowsPictureInPictureMediaPlayback = true
        webCfg.preferences.javaScriptCanOpenWindowsAutomatically = true
        webCfg.mediaTypesRequiringUserActionForPlayback = []
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
        
        // Register the custom URL scheme handler
        let customSchemeHandler = HomepageSchemeHandler()
        webCfg
            .setURLSchemeHandler(
                customSchemeHandler,
                forURLScheme: "homepage"
            )
        

        self.init(
            frame: CGRect(),
            configuration: webCfg
        )
        self.navigationDelegate = self

        // TODO: this probably should be more controllable.
        // Before configuring the WKWebView, delete caches since
        // it seems a bit arbitrary when this happens otherwise.
        // This from http://stackoverflow.com/a/34376943/5920499
//        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]) as! Set<String>
//        let ds = WKWebsiteDataStore.default()
//        ds.removeData(
//            ofTypes: websiteDataTypes,
//            modifiedSince: NSDate(timeIntervalSince1970: 0) as Date,
//            completionHandler:{})

        // Load js
        for jsfilename in [
            "stringview",
            "WBUtils",
            "WBEventTarget",
            "WBBluetoothUUID",
            "WBDevice",
            "WBBluetoothRemoteGATTServer",
            "WBBluetoothRemoteGATTService",
            "WBBluetoothRemoteGATTCharacteristic",
            "WBPolyfill"
        ] {
            guard let filePath = Bundle(for: WBWebView.self).path(forResource: jsfilename, ofType:"js") else {
                NSLog("Failed to find polyfill \(jsfilename)")
                return
            }
            var polyfillScriptContent: String
            do {
                polyfillScriptContent = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            } catch _ {
                NSLog("Error loading polyfil")
                return
            }
            let userScript = WKUserScript(
                source: polyfillScriptContent, injectionTime: .atDocumentStart,
                forMainFrameOnly: false)
            userController.addUserScript(userScript)
        }

        // WKWebView static config
        self.translatesAutoresizingMaskIntoConstraints = false
        self.allowsBackForwardNavigationGestures = true
        self.allowsLinkPreview = true
    }

    // MARK: - API
    open func addNavigationDelegate(_ del: WKNavigationDelegate) {
        self._navDelegates.append(del)
    }
    open func removeNavigationDelegate(_ del: WKNavigationDelegate) {
        self._navDelegates.removeAll(where: {$0.isEqual(del)})
    }

    // MARK: - WKNavigationDelegate
    // Propagates the notification to all the registered delegates
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self._navDelegates.forEach{$0.webView?(webView, didStartProvisionalNavigation: navigation)}
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self._enableBluetoothInView()
        self._navDelegates.forEach{$0.webView?(webView, didFinish: navigation)}
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self._navDelegates.forEach{$0.webView?(webView, didFail: navigation, withError: error)}
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self._navDelegates.forEach{$0.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)}
    }
    
    
    
    // MARK: - Internal
    open func _enableBluetoothInView() {
        self.evaluateJavaScript(
            "window.iOSNativeAPI.enableBluetooth()",
            completionHandler: { _, error in
                if let error_ = error {
                    NSLog("Error enabling bluetooth in view: \(error_)")
                }
            }
        )
    }
    
    open func _enableVibratorAPI() {
        self.evaluateJavaScript(
            "window.iOSNativeAPI.enableVibrate()",
            completionHandler: { _, error in
                if let error_ = error {
                    NSLog("Error enabling vibrator in view: \(error_)")
                }
            }
        )
    }
    
    open func _enableLogging() {
        self.evaluateJavaScript(
            "window.iOSNativeAPI.enableLog()",
            completionHandler: { _, error in
                if let error_ = error {
                    NSLog("Error enabling logging in view: \(error_)")
                }
            }
        )
    }
    
    

}

class SpecialTapRecognizer: UITapGestureRecognizer {
    override func canBePrevented(by: UIGestureRecognizer) -> Bool {
        return false
    }
}


