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
import Telegraph

enum URLTextFieldState : String {
    case editing, inactive
}

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {

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
    // MARK: define private widget
    @IBOutlet weak var showURLBarWidth: NSLayoutConstraint!
    private let reloadButton = UIButton(type: .system)


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
                self.goForwardButton.isEnabled = UserDefaults.standard.bool(forKey: "OldCanGoForward")
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
            let ud = UserDefaults.standard
            ud.set(locationTextField.text, forKey: "HomePageLocation")
            self.view.makeToast("Successfully set as home page")
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
        case "Support Us":
                let url = URL(string: "https://buymeacoffee.com/bachhoangnguyen")!
                guard UIApplication.shared.canOpenURL(url) else {
                    let alert = UIAlertController(title: "Can't open URL",message: "Can't navigate to this URL.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default :
            break
        }
    }

    @IBAction func goToHomePage(){
        let ud = UserDefaults.standard
        let homePageLocation = ud.value(forKey: "HomePageLocation") as? String
        NSLog("homePageLocation: \(homePageLocation!)")
        if(homePageLocation != nil){
            ud.set(homePageLocation, forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue)
            ud.set(homePageLocation, forKey: "LastDirectLocation")
            self.webView.load(URLRequest(url: URL(string: homePageLocation!)!))
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
        UserDefaults.standard.set(false, forKey: "OldCanGoForward")
    }

    // MARK: - Event handling
    override func viewDidLoad() {

        super.viewDidLoad()
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
        self.webView.configuration.userContentController.addUserScript(userScript)
        self.webView.configuration.userContentController.add(self, name: "consoleHandler")

        let nc = self.navigationController!
        nc.setNavigationBarHidden(true, animated: false)
        nc.setToolbarHidden(true, animated: false)
        self.webView.isUserInteractionEnabled = true

        self.goBackButton.isEnabled = false
        self.goForwardButton.isEnabled = false
        let ud = UserDefaults.standard
        let homePageLocation = ud.value(forKey: "HomePageLocation") as? String
        if(homePageLocation == nil){
                ud.set("homepage://", forKey: "HomePageLocation")
        }

        // connect view to other objects
        self.locationTextField.delegate = self
        self.webView.addNavigationDelegate(self)
        self.webView.scrollView.delegate = self
        self.webView.scrollView.clipsToBounds = true
        self.webViewContainerController.addObserver(self, forKeyPath: "pickerIsShowing", options: [], context: nil)

        if #available(iOS 11.0, *){
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else{
            automaticallyAdjustsScrollViewInsets = false
        }

        for path in ["canGoBack", "canGoForward"] {
            self.webView.addObserver(self, forKeyPath: path, options: .new, context: nil)
        }

        // Load last location
        if let url = initialURL {
            loadURL(url)
        }
        else {
            var lastLocation: String
            if(ud.string(forKey: "HomePageLocation") != nil){
                lastLocation = ud.string(forKey: "HomePageLocation")!
                if(lastLocation == "homepage://"){
                    if let prefLoc = ud.value(forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue) as? String {
                        lastLocation = prefLoc
                    } else {
                        lastLocation = "homepage://"
                    }
                }
            }
            else {
                if let prefLoc = ud.value(forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue) as? String {
                    lastLocation = prefLoc
                } else {
                    lastLocation = "homepage://"
                }
            }
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
            if(self.containerViewConstraint.constant == 0){
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
        super.viewWillDisappear(animated)
    }

    func loadLocation(_ location: String) {
        var location = location
        if !location.hasPrefix("http://") && !location.hasPrefix("https://") {
            if(location.contains(".") || location.contains("www")){
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
        let ud = UserDefaults.standard
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
        UserDefaults.standard.set(url.absoluteString, forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue)
        self.webView.load(URLRequest(url: url))
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
            UserDefaults.standard.setValue(defChange[NSKeyValueChangeKey.newKey] as! Bool, forKey: "OldCanGoForward")
            self.goForwardButton.isEnabled = defChange[NSKeyValueChangeKey.newKey] as! Bool
        case "navBarIsHidden":
            return ;
        case "pickerIsShowing":
            return;
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
        let ud = UserDefaults.standard
        print(ud.string(forKey: "StatusBarColor")!)
        let statusColor = UIColor(hex: ud.string(forKey: "StatusBarColor")!)
        self.containerViewConstraint.constant = 0
        self.locationTextField.alpha = 0
        self.locationTextField.isHidden = true
        self.goBackButton.alpha = 0
        self.goBackButton.isHidden = true
        self.goForwardButton.alpha = 0
        self.goForwardButton.isHidden = true
        self.refreshButton.alpha = 0
        self.refreshButton.isHidden = true
        self.settingButton.alpha = 0
        self.settingButton.isHidden = true
        self.urlStackView.backgroundColor = .clear
        self.urlStackViewConstrantLeading.constant = UIScreen.main.bounds.width - 25
        self.urlStackViewConstraintHeight.constant = 100
        self.showURLBarButton.isHidden = false
        self.ShowURLBarButtonHeight.constant = 70
        self.showURLBarWidth.constant = 20
        self.view.bringSubviewToFront(self.urlStackView)
        self.view.backgroundColor = statusColor
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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

        // Create the activity view controller
        let activityViewController = UIActivityViewController(activityItems: [currentURL], applicationActivities: nil)

        // Exclude certain activity types if necessary
        activityViewController.excludedActivityTypes = [.print, .assignToContact, .saveToCameraRoll]

        // Present the activity view controller
        present(activityViewController, animated: true, completion: nil)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activityState = .editing
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.activityState = .inactive
        return true
    }

}

