//
//  Copyright © 2017 Paul Theriault & David Park. All rights reserved.
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

import UIKit
import WebKit
import WidgetKit
import EasyTipView
import AuthenticationServices

enum URLTextFieldState : String {
    case editing, inactive
}

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, UIScrollViewDelegate, EasyTipViewDelegate {
    private var popupWebView: WKWebView?

    // Correct implementation of EasyTipViewDelegate methods
        func easyTipViewDidTap(_ tipView: EasyTipView) {
            // Handle tap on the EasyTipView
            print("Tip view tapped.")
        }

        func easyTipViewDidDismiss(_ tipView: EasyTipView) {
            // Handle dismissal of the EasyTipView
            print("Tip view dismissed.")
        }
    

    enum prefKeys: String {
        case consoleOpen
        case version
    }
    
    // MARK: - Properties
    let currentPrefVersion = 1
    let bottomMarginNotToHideBarsIn: CGFloat = 100.0

    // MARK: IBOutlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet var goBackButton: UIButton!
    @IBOutlet var goForwardButton: UIButton!
    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var urlStackView : UIStackView!
    @IBOutlet var showURLBarButton : UIButton!
    @IBOutlet var settingButton : UIButton!
    @IBOutlet var containerView : UIView!

    // MARK: layout IBoutlet
    @IBOutlet weak var containerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlStackViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlStackViewConstrantLeading: NSLayoutConstraint!
    @IBOutlet weak var urlStackViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var ShowURLBarButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var locationTextFieldLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var locationTextFieldTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var goFowardWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlStackViewTopConstraint: NSLayoutConstraint!
    // MARK: define private widget
    @IBOutlet weak var showURLBarWidth: NSLayoutConstraint!
    private let reloadButton = UIButton(type: .system)
    
    private var observedKeyPaths: Set<String> = []
    private var tooltips: EasyTipView?
    private var preferences = EasyTipView.Preferences()


    var activityState = URLTextFieldState.inactive {
        didSet {
            switch activityState {
            case .editing:
                self.locationTextField.rightView = nil
                //            self.locationTextField.selectAll(nil)
                self.locationTextField.textColor = .black
                self.goBackButton.alpha = 0
                self.goBackButton.isHidden = true
                self.settingButton.alpha = 0
                self.settingButton.isHidden = true
                self.goForwardButton.alpha = 0
                self.goForwardButton.isEnabled = false
                self.goFowardWidthConstraint.constant = 16
                self.refreshButton.alpha = 0
                self.refreshButton.isEnabled = false
                self.homeButtonWidthConstraint.constant = 16
                UIView.animate(withDuration: 0.3) {
                    // Hide floating button
                    self.view.layoutIfNeeded()
                }
            case .inactive:
                self.locationTextField.rightView = self.locationTextField.hasText ? reloadButton : reloadButton
                self.locationTextField.textColor = .black
                self.goBackButton.alpha = 1
                self.goBackButton.isHidden = false
                self.goForwardButton.alpha = 1
                self.goForwardButton.isHidden = false
                self.refreshButton.alpha = 1
                self.refreshButton.isHidden = false
                self.settingButton.alpha = 1
                self.settingButton.isHidden = false
                self.goForwardButton.alpha = 1
                self.goForwardButton.isEnabled = UserDefaults(suiteName: "group.com.nhb.blena")!.bool(forKey: "OldCanGoForward")
                self.goFowardWidthConstraint.constant = 40
                self.refreshButton.alpha = 1
                self.refreshButton.isEnabled = true
                self.homeButtonWidthConstraint.constant = 40
                UIView.animate(withDuration: 0.3) {
                    // Hide floating button
                    self.view.layoutIfNeeded()
                }
            }
        }
    }


    func setupReloadButton() {
        // Ensure button creation is on the main thread
            DispatchQueue.main.async {
                self.reloadButton.setImage(UIImage(systemName: "arrow.clockwise")?.withRenderingMode(.alwaysTemplate), for: .normal)
                self.reloadButton.imageView?.contentMode = .scaleAspectFit
                self.reloadButton.tintColor = .black
                self.reloadButton.addTarget(self, action: #selector(self.innerReloadTap), for: .touchUpInside)

                // Ensure that auto layout is used
                self.reloadButton.translatesAutoresizingMaskIntoConstraints = false

                // Add the reload button as a rightView to the locationTextField
                self.locationTextField.rightView = self.reloadButton
                self.locationTextField.rightViewMode = .always

                // Set constraints for the reload button within the text field
                if let rightView = self.locationTextField.rightView {
                    rightView.translatesAutoresizingMaskIntoConstraints = false

                    // Constrain the rightView inside the text field
                    NSLayoutConstraint.activate([
//                        rightView.centerYAnchor.constraint(equalTo: self.locationTextField.centerYAnchor),
                        rightView.widthAnchor.constraint(equalToConstant: 24), // Adjust button size
                        rightView.heightAnchor.constraint(equalToConstant: 24)
                    ])
                }
            }
    }

    @objc func innerReloadTap() {
        self.reload()
    }

    //MARK: action
    @IBAction func optionSelection(_ sender: UIAction) {
        switch sender.title {
        case "Show Full Screen":
            hideUrlStackView()
        case "Share":
            sharePage()
        case "Set As Home Page":
            let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
            let newHomePage = ud.string(forKey: "LastDirectLocation")
            ud.set(newHomePage, forKey: "HomePageLocation")
            self.view.makeToast("Successfully set as home page")
            WidgetCenter.shared.reloadAllTimelines()
        case "Settings":
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
                settingsVC.modalPresentationStyle = .pageSheet
                if #available(iOS 15.0, *) {
                    if let sheet = settingsVC.sheetPresentationController {
                        // Customize detents (heights) for the bottom sheet
                        sheet.detents = [.large()] // Medium and large sizes
                        sheet.largestUndimmedDetentIdentifier = .medium
                    }
                } else {
                    // Fallback on earlier versions
                }

                // Present the bottom sheet
                self.present(settingsVC, animated: true, completion: nil)
            }
        case "About Blena":
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let settingsVC = storyboard.instantiateViewController(withIdentifier: "AboutBlenaController") as? AboutBlenaController {
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

                    self.present(settingsVC, animated: true, completion: nil)
                // Present the bottom sheet
            }
        default :
            break
        }
    }

    @IBAction func goToHomePage(){
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        let homePageLocation = ud.value(forKey: "HomePageLocation") as? String
        NSLog("homePageLocation: \(homePageLocation!)")
        if(homePageLocation != nil){
            ud.set(homePageLocation, forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue)
            ud.set(homePageLocation, forKey: "LastDirectLocation")
            if(homePageLocation == nil || URL(string: homePageLocation!) == nil){
                self.webView.load(URLRequest(url: URL(string: "homepage://")!))
            }
            var urlRequest = URLRequest(url: URL(string: homePageLocation ?? "homepage://")!)
            if(DisableCacheSession.shared.isDisableCacheSession()){
                let disableCacheScript = """
                (function() {
                    if (window.caches) {
                        caches.keys().then(function(names) {
                            for (let name of names) caches.delete(name);
                        });
                    }
                    window.localStorage.clear();
                    window.sessionStorage.clear();
                })();
                """
                self.webView.evaluateJavaScript(disableCacheScript, completionHandler: nil)
            }
            if(urlRequest.url != nil && urlRequest.url!.absoluteString != ""){
                self.webView.load(urlRequest)
            } else {
                self.webView.load(URLRequest(url: URL(string: "homepage://")!))
            }
        } else {
            self.webView.load(URLRequest(url: URL(string: "homepage://")!))
        }
    }

    var initialURL: URL?
    var lastRefresh: Date?

    var consoleViewBottomConstraint: NSLayoutConstraint? = nil

    let pattern = #"https://pmf\.mjbuilder\.dev/.*"#

    var webViewContainerController: WBWebViewContainerController {
        get {
            return self.children.first(where: {$0 as? WBWebViewContainerController != nil}) as! WBWebViewContainerController
        }
    }
    var webViewController: WBWebViewController {
        get {
            return self.webViewContainerController.webViewController
        }
    }
    var webView: WBWebView {
        get {
            return self.webViewController.webView
        }
    }
    var consoleContainerController: ConsoleViewContainerController? {
        get {
            return self.children.first(where: {$0 as? ConsoleViewContainerController != nil}) as? ConsoleViewContainerController
        }
    }

    @IBAction func goForward() {
        if(self.webView.canGoForward){
            self.webView.goForward()
        }
    }
    @IBAction func goBackward() {
        if(self.webView.canGoBack){
            self.webView.goBack()
        }
    }
    @IBAction func reload() {
        if(DisableCacheSession.shared.isDisableCacheSession()){
            
        }
        if self.webView.url != nil {
            if let lastRefresh = self.lastRefresh,
               Date() < lastRefresh + 1 {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                if self.webView.isLoading {
                    self.webView.stopLoading()
                }
                self.webView.reloadFromOrigin()
            } else {
                self.webView.reload()
            }
        } else if let textLocation = self.locationTextField?.text {
            NSLog("Reload from location")
            self.loadLocation(textLocation)
        }
        self.lastRefresh = Date()
    }

    // MARK: - Home bar indicator control
    override var prefersHomeIndicatorAutoHidden: Bool {
        return false
    }

    @objc func dismissBottomSheet() {
            self.dismiss(animated: true, completion: nil) // Dismiss the bottom sheet when tapped outside
        }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.loadLocation(textField.text!)
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        UserDefaults(suiteName: "group.com.nhb.blena")!.set(false, forKey: "OldCanGoForward")
    }

    // MARK: - Event handling
    override func viewDidLoad() {

        super.viewDidLoad()
        webView.uiDelegate = self
        
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        EasyTipView.globalPreferences = preferences
        tooltips = EasyTipView(text: "The address bar is currently hidden. Click, or swipe the button to reveal it.",
                               preferences: preferences,
                               delegate: self)
        
        self.showURLBarWidth.constant = 0
        self.showURLBarButton.isHidden = true
        setupReloadButton()
        self.activityState = .inactive
        self.locationTextField.rightViewMode = .always
        self.urlStackView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
        self.view.superview?.addGestureRecognizer(tapGesture)

        let consoleScript = """
                var originalLog = console.log;
                console.log = function(message) {
                    window.webkit.messageHandlers.consoleHandler.postMessage(String(message));
                    originalLog.apply(console, arguments);
                };
                """

        let userScript = WKUserScript(source: consoleScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        let fakeSafariScript = """
        Object.defineProperty(navigator, 'userAgent', {
            get: function() { 
                return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15';
            }
        });
        Object.defineProperty(navigator, 'platform', {
            get: function() { 
                return 'MacIntel';
            }
        });
        Object.defineProperty(navigator, 'vendor', {
            get: function() { 
                return 'Apple Computer, Inc.';
            }
        });
        Object.defineProperty(navigator, 'appVersion', {
            get: function() { 
                return '5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15';
            }
        });
        Object.defineProperty(window, 'safari', {
            get: function() {
                return {};
            }
        });
        """

        let fakeScript = WKUserScript(source: fakeSafariScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)

        self.webView.configuration.userContentController.addUserScript(userScript)
        self.webView.configuration.userContentController.addUserScript(fakeScript)
        self.webView.configuration.userContentController.add(self, name: "consoleHandler")
        if #available(iOS 16.4, *) {
            self.webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }

        let nc = self.navigationController!
        nc.setNavigationBarHidden(true, animated: false)
        nc.setToolbarHidden(true, animated: false)
        self.webView.isUserInteractionEnabled = true

        self.goBackButton.isEnabled = false
        self.goForwardButton.isEnabled = false
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        let homePageLocation = ud.value(forKey: "HomePageLocation") as? String
        if(homePageLocation == nil){
                ud.set("homepage://", forKey: "HomePageLocation")
        }

        // connect view to other objects
        self.locationTextField.delegate = self
        self.webView.addNavigationDelegate(self)
        self.webView.scrollView.delegate = self
        self.webView.scrollView.clipsToBounds = true

        if #available(iOS 11.0, *){
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else{
            automaticallyAdjustsScrollViewInsets = false
        }

        for path in ["canGoBack", "canGoForward", "URL"] {
            self.webView.addObserver(self, forKeyPath: path, options: .new, context: nil)
            self.observedKeyPaths.insert(path)
        }

        // Load last location
        if let url = initialURL {
            loadURL(url)
        }
        else {
        var lastLocation: String
            lastLocation = ud.string(forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue) ?? "homepage://"
//            self.loadLocation(lastLocation)
            self.loadLocation(lastLocation)
        }

        // #MARK: Set swipe direction and add gesture recognizer for StackView
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        swipeRight.direction = .right
        self.urlStackView.addGestureRecognizer(swipeRight)
        self.urlStackView.addGestureRecognizer(swipeLeft)
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if(self.containerViewConstraint.constant == -view.safeAreaInsets.top){
                NSLog("Swiped left!")
                showUrlStackView()
            } else {
                NSLog("Shouldn't Swiped left!")

            }
            // Perform actions for left swipe (e.g., remove a view or change layout)
        } else if gesture.direction == .right {
            if(self.containerViewConstraint.constant == 0){
                NSLog("shoudln't Swiped right!")
            } else {
                NSLog("Swiped right!")
                hideUrlStackView()

            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        //        let nc = self.navigationController as! NavigationViewController
        //        nc.removeObserver(self, forKeyPath: "navBarIsHidden")
        let paths = ["canGoBack", "canGoForward", "URL"]
                for path in paths {
                    if observedKeyPaths.contains(path) {
                        self.webView.removeObserver(self, forKeyPath: path)
                        observedKeyPaths.remove(path)
                    }
                }
        super.viewWillDisappear(animated)
    }

    func loadLocation(_ location: String) {
        var location = location
        if !location.hasPrefix("http://") && !location.hasPrefix("https://") {
            if(LocalHostRegrexShared.shared.isLocalHost(location)){
                location = "http://\(location)"
            } else if(location.contains(".") || location.contains("www")){
                location = "https://\(location)"
            } else if(location != "homepage://"){
                location = "https://www.google.com/search?q=\(location)"
            } else {
                location = "homepage://"
            }
        }
        guard let url = URL(string: location) else {
            NSLog("Failed to convert location \(location) into a URL")
            return
        }
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        ud.set(location, forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue)
        loadURL(url)
        
    }

    func loadURL(_ directUrl: URL) {
        let url = directUrl
        guard self.isViewLoaded else {
            self.initialURL = URL(string: url.absoluteString)
            return
        }
        self.setLocationText(url.absoluteString)
        UserDefaults(suiteName: "group.com.nhb.blena")!.set(url.absoluteString, forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue)
        var urlRequest = URLRequest(url: url)
        if(DisableCacheSession.shared.isDisableCacheSession()){
            urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
            URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
            URLCache.shared.memoryCapacity = 0
            URLCache.shared.diskCapacity = 0
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.removeCachedResponse(for: urlRequest)
            self.webView.load(urlRequest)
        } else {
            self.webView.load(urlRequest)
        }
    }
    func setLocationText(_ text: String) {
        var url: String? = text
        if(url == "homepage://"){
            url = nil
        }
        self.locationTextField.text = url

    }

    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let urlString = webView.url?.absoluteString {
            self.setLocationText(urlString)
            do{
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(urlString.startIndex..<urlString.endIndex, in: urlString)
                if(regex.firstMatch(in: urlString, range: range) != nil) {

                } else {

                }
            } catch{}
        }
    }




    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.setHidesOnSwipesFromScrollView(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.setHidesOnSwipesFromScrollView(scrollView)
        if scrollView.contentOffset.y == 0.0 {
            // Hack... this *probably* means we've been scrolled to the top using
            // a swipe. This on its own shouldn't show the bars, but at this point
            // it's natural for the user to hit the menu bar to see the menu, but
            // the only way we can detect that is through a scrollToTop delegate
            // method, but we won't get that if we're already at the top. So set
            // a 1 pixel offset so that we can effectively re-enable the
            // scroll to top notification.
            //
            // The only problem with this is that we get *DidEndDecelerating
            // if the user "catches" the swipe scroll and instigates a new
            // swipe scroll. In that case this will erroneously set the 1 pixel
            // offset, leading to a small UI glitch. However that is acceptable
            // given that it would be very unlikely for them to catch it at
            // exactly 0.0 offset.
            scrollView.setContentOffset(
                CGPoint(x: 0.0, y: 1.0), animated: true
            )
        }
    }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if scrollView.contentOffset.y > 1.0 {
            // big scroll, don't scroll quite to top so that we can detect being
            // told to again and show the status bar
            scrollView.setContentOffset(
                CGPoint(x: 0.0, y: 1.0), animated: true
            )
            return false
        }
        return true
    }

    // MARK: - Observe protocol
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            let defKeyPath = keyPath,
            let defChange = change
        else {
            NSLog("Unexpected change with either no keyPath or no change dictionary!")
            return
        }

        switch defKeyPath {
        case "canGoBack":
            NSLog(defChange[NSKeyValueChangeKey.newKey] as! Bool == true ? "true" : "false")
            self.goBackButton.isEnabled = defChange[NSKeyValueChangeKey.newKey] as! Bool
        case "canGoForward":
            UserDefaults(suiteName: "group.com.nhb.blena")!.setValue(defChange[NSKeyValueChangeKey.newKey] as! Bool, forKey: "OldCanGoForward")
            self.goForwardButton.isEnabled = defChange[NSKeyValueChangeKey.newKey] as! Bool
        case "URL":
            let defURL = defChange[NSKeyValueChangeKey.newKey] as? URL
            if defURL != nil{
                setLocationText((defChange[NSKeyValueChangeKey.newKey] as! URL).absoluteString)
            }
        default:
            NSLog("Unexpected change observed by ViewController: \(defKeyPath)")
        }
    }

    func setHidesOnSwipesFromScrollView(_ scrollView: UIScrollView) {
        // Due to an apparent bug this should not be called when the toolbar / navbar are animating up or down as far as possible as that seems to cause a crash
        let yOffset = scrollView.contentOffset.y
        let frameHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        let nc = self.navigationController!

        if yOffset + frameHeight > (
            contentHeight > self.bottomMarginNotToHideBarsIn
            ? contentHeight - self.bottomMarginNotToHideBarsIn
            : 0
        ) {
            if nc.hidesBarsOnSwipe {
                nc.hidesBarsOnSwipe = false
            }
        } else {
            if !nc.hidesBarsOnSwipe {
                nc.hidesBarsOnSwipe = false
            }
        }
    }

    func hideUrlStackView() {
        
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        print(ud.string(forKey: "StatusBarColor")!)
        let statusColor = UIColor(hex: ud.string(forKey: "StatusBarColor")!)
        self.containerViewConstraint.constant = -view.safeAreaInsets.top
        self.locationTextField.alpha = 0
        self.locationTextField.isHidden = true
        self.goBackButton.alpha = 0
        self.urlStackView.backgroundColor = .clear
        self.goBackButton.isHidden = true
        self.goForwardButton.alpha = 0
        self.goForwardButton.isHidden = true
        self.refreshButton.alpha = 0
        self.urlStackViewTopConstraint.constant = 50
        self.refreshButton.isHidden = true
        self.settingButton.alpha = 0
        self.settingButton.isHidden = true
        self.urlStackView.backgroundColor = .clear
        self.urlStackViewConstrantLeading.constant = UIScreen.main.bounds.width - 25
        self.urlStackViewConstraintHeight.constant = 30
        self.showURLBarButton.isHidden = false
        self.ShowURLBarButtonHeight.constant = 70
        self.showURLBarWidth.constant = 10
        self.view.bringSubviewToFront(self.urlStackView)
        self.view.backgroundColor = statusColor
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        if(!IsFirstTimeUseApp.shared.isFirstTime()){
            tooltips?.show(animated: true, forView: self.showURLBarButton,
            withinSuperview: self.navigationController?.view)
            IsFirstTimeUseApp.shared.setIsFirstTime(true)
        }
    }

    @IBAction func showUrlStackView() {
        self.showURLBarWidth.constant = 0
        let statusColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        self.urlStackViewConstrantLeading.constant = 0
        self.containerViewConstraint.constant = 40
        self.locationTextField.alpha = 1
        self.urlStackView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        self.locationTextField.isHidden = false
        self.goBackButton.alpha = 1
        self.goBackButton.isHidden = false
        self.goForwardButton.alpha = 1
        self.goForwardButton.isHidden = false
        self.settingButton.alpha = 1
        self.urlStackViewTopConstraint.constant = 0
        self.settingButton.isHidden = false
        self.refreshButton.alpha = 1
        self.refreshButton.isHidden = false
        self.showURLBarButton.isHidden = true
        self.showURLBarButton.alpha = 1
        self.view.bringSubviewToFront(self.urlStackView)
        self.urlStackViewConstraintHeight.constant = 40
        self.ShowURLBarButtonHeight.constant = 40
        // Show the stack view with animation
        self.view.backgroundColor = statusColor
        UIView.animate(withDuration: 0.3) {
            // Hide floating button
            self.view.layoutIfNeeded()
        }
        tooltips?.dismiss()
        if(!IsFirstTimeUseApp.shared.isFirstTime()){
            IsFirstTimeUseApp.shared.setIsFirstTime(true)
        }
        
    }


    // MARK: Share page
    func sharePage() {
        guard let currentURL = self.webView.url else {
            // If there's no URL loaded, show an alert
            let alert = UIAlertController(title: "No Page Loaded", message: "There is no page loaded in the web view to share.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        ShareActionSheet.shared.shareActionSheet(viewController: self, url: currentURL)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activityState = .editing
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.activityState = .inactive
        return true
    }
    
    func startGoogleSignIn() {
            let authURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=YOUR_CLIENT_ID&redirect_uri=com.yourapp:/oauth2redirect&response_type=code&scope=email")!
            let callbackURLScheme = "com.yourapp"

            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                if let error = error {
                    print("Authentication error: \(error.localizedDescription)")
                    return
                }

                if let callbackURL = callbackURL {
                    // Parse the authorization code from the URL
                    let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                    if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                        print("Authorization code: \(code)")
                        // Exchange code for tokens here
                    }
                }
            }

            session.presentationContextProvider = self
            session.start()
        }
    
    func processCallback(url: URL) {
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        if let code = queryItems?.first(where: { $0.name == "code" })?.value {
            print("Authorization code: \(code)")
            // Exchange the code for tokens
        }
    }

}

extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}


extension ViewController: WKUIDelegate {
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
//        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        popupWebView?.navigationDelegate = self
//        popupWebView?.uiDelegate = self
//        if let newWebview = popupWebView {
//            view.addSubview(newWebview)
//        }
//        return popupWebView ?? nil
//    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            UIApplication.shared.open(navigationAction.request.url!, options: [:])
        }
        return nil
    }
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        popupWebView = nil
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let ac = UIAlertController(title: nil,
                                       message: message,
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok",
                                       style: .default) { _ in
                completionHandler()
            })
            present(ac, animated: true)
    }
    
    func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping @MainActor (Bool) -> Void) {
        // Check the type of challenge
        if let serverTrust = challenge.protectionSpace.serverTrust {
            // Validate the server trust if needed
            if SecTrustEvaluateWithError(serverTrust, nil) {
                print("Server trust is valid.")
                // Reject deprecated TLS (recommended)
                decisionHandler(false)
                return
            }
        }
        // Allowing deprecated TLS (NOT recommended unless absolutely necessary)
        print("Deprecated TLS detected. Allowing connection.")
        decisionHandler(true)
    }}
