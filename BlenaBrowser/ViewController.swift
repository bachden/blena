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

    // MARK: layout IBoutlet
    @IBOutlet weak var containerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlStackViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlStackViewConstrantLeading: NSLayoutConstraint!
    @IBOutlet weak var urlStackViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var ShowURLBarButtonHeight: NSLayoutConstraint!
    
    //MARK: action
    @IBAction func optionSelection(_ sender: UIAction) {
        switch sender.title {
        case "Show Full Screen":
            hideUrlStackView()
        case "Share":
            sharePage()
        case "Home Page":
            // Assuming you are using a storyboard named "Main" or the default storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            // Instantiate HomeViewController using its storyboard ID
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                // Set the presentation style if needed
                homeVC.modalPresentationStyle = .fullScreen

                // Create a transition animation
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = .push // Use desired type like `.fade`, `.moveIn`, `.reveal`, etc.
                transition.subtype = .fromRight // Direction of the transition, e.g., `.fromRight`
                homeVC.navigationController?.setNavigationBarHidden(true, animated: false)
                // Add the transition to the window's layer
                self.navigationController?.pushViewController(homeVC, animated: true)
            }

        default :
            break
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
        NSLog("Go forward")
        self.webView.goForward()
    }
    @IBAction func goBackward() {
        NSLog("Go backward")
        self.webView.goBack()
    }
    @IBAction func reload() {
        if self.webView.url != nil {
            if let lastRefresh = self.lastRefresh,
               Date() < lastRefresh + 1 {
                NSLog("Hard reload")
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                if self.webView.isLoading {
                    self.webView.stopLoading()
                }
                self.webView.reloadFromOrigin()
            } else {
                NSLog("Reload")
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

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.loadLocation(textField.text!)
        return true
    }

    // MARK: - Event handling
    override func viewDidLoad() {

        super.viewDidLoad()
        self.showURLBarButton.isHidden = true
        self.additionalSafeAreaInsets.top = 0
        
        let nc = self.navigationController!
        nc.setNavigationBarHidden(true, animated: false)
        nc.setToolbarHidden(true, animated: false)
        self.goBackButton.isEnabled = false
        self.goForwardButton.isEnabled = false
        let ud = UserDefaults.standard

        // connect view to other objects
        self.locationTextField.delegate = self
        self.webView.addNavigationDelegate(self)
        self.webView.scrollView.delegate = self
        self.webView.scrollView.clipsToBounds = true
        self.webViewContainerController.addObserver(self, forKeyPath: "pickerIsShowing", options: [], context: nil)

        if #available(iOS 11.0, *){
            self.webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        } else{
            automaticallyAdjustsScrollViewInsets = true
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
            if let prefLoc = ud.value(forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue) as? String {
                lastLocation = prefLoc
            } else {
                lastLocation = "https://www.google.com/"
            }
            self.loadLocation(lastLocation)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        let nc = self.navigationController as! NavigationViewController
//        nc.addObserver(self, forKeyPath: "navBarIsHidden", options: [.initial, .new], context: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
//        let nc = self.navigationController as! NavigationViewController
//        nc.removeObserver(self, forKeyPath: "navBarIsHidden")
        super.viewWillDisappear(animated)
    }

    func loadLocation(_ location: String) {
        var location = location
        if !location.hasPrefix("http://") && !location.hasPrefix("https://") {
            location = "https://www.google.com/search?q=\(location)"
        }
        guard let url = URL(string: location) else {
            NSLog("Failed to convert location \(location) into a URL")
            return
        }
        loadURL(url)
    }

    func loadURL(_ url: URL) {
        var maskURL = ""
        guard self.isViewLoaded else {
            do{
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(url.absoluteString.startIndex..<url.absoluteString.endIndex, in: url.absoluteString)
                if(regex.firstMatch(in: url.absoluteString, range: range) != nil) {
                    NSLog("match")
                    maskURL = ""
                } else {
                    NSLog("not match")
                    maskURL = url.absoluteString
                }
            } catch{}
            self.initialURL = URL(string: maskURL)
            return
        }


        self.setLocationText(maskURL)
        self.webView.load(URLRequest(url: url))
    }
    func setLocationText(_ text: String) {
        do{
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            if(regex.firstMatch(in: text, range: range) != nil) {
            } else {
            }
        } catch{}
        self.locationTextField.text = text

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
        self.view.bringSubviewToFront(self.urlStackView)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func showUrlStackView() {
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
        UIView.animate(withDuration: 0.3) {
            // Hide floating button
            self.view.layoutIfNeeded()
        }
    }

    func loadInitialURL() {
        let defaultURL = URL(string: "https://www.google.com/")!
        let request = URLRequest(url: defaultURL)
        webView.load(request)
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

}
