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

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, ConsoleToggler {

    enum prefKeys: String {
        case consoleOpen
        case version
    }

    // MARK: - Properties
    let currentPrefVersion = 1
    let bottomMarginNotToHideBarsIn: CGFloat = 100.0

    // MARK: IBOutlets
    @IBOutlet var tick: UIImageView!
    @IBOutlet var goBackButton: UIBarButtonItem!
    @IBOutlet var goForwardButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var showConsoleButton: UIBarButtonItem!
    @IBOutlet var extraShowBarsView: UIView!
    @IBOutlet var goHomeButton : UIBarButtonItem!

    var initialURL: URL?
    var lastRefresh: Date?

    var consoleViewBottomConstraint: NSLayoutConstraint? = nil
    var shouldShowBars = true {
        didSet {
            let nc = self.navigationController!
            nc.setToolbarHidden(!self.shouldShowBars, animated: true)
            nc.setNavigationBarHidden(!self.shouldShowBars, animated: true)
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self._setExtraBarHiddenState()
            self.setHidesOnSwipesFromScrollView(
                self.webView.scrollView
            )
        }
    }

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
        }
        self.lastRefresh = Date()
    }
    @IBAction func showBars() {
        NSLog("Show bars")
        self.shouldShowBars = true
    }
    @IBAction func toggleConsole() {
        if let cvc = self.consoleContainerController {
            NSLog("Hiding console")
            cvc.performSegue(
                withIdentifier: "HideConsoleSegueID",
                sender: self
            )
        } else {
            NSLog("Showing console")
            self.performSegue(
                withIdentifier: "ShowConsoleSegueID",
                sender: self
            )
        }
    }

    // MARK: - Home bar indicator control
    override var prefersHomeIndicatorAutoHidden: Bool {
        return !self.shouldShowBars
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

        let ud = UserDefaults.standard

        // connect view to other objects
        self.webView.addNavigationDelegate(self)
        self.webView.scrollView.delegate = self
        self.webView.scrollView.clipsToBounds = false
        self.webViewContainerController.addObserver(self, forKeyPath: "pickerIsShowing", options: [], context: nil)

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
                lastLocation = "https://progressier.com/pwa-capabilities/bluetooth"
            }
            self.loadLocation(lastLocation)
        }

        // Maybe re-open console
        if ud.bool(forKey: prefKeys.consoleOpen.rawValue) {
            self.toggleConsole()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let nc = self.navigationController as! NavigationViewController
        nc.addObserver(self, forKeyPath: "navBarIsHidden", options: [.initial, .new], context: nil)
        if self.shouldShowBars {
            self.showBars()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        let nc = self.navigationController as! NavigationViewController
        nc.removeObserver(self, forKeyPath: "navBarIsHidden")
        super.viewWillDisappear(animated)
    }
    
    func loadLocation(_ location: String) {
        var location = location
        if !location.hasPrefix("http://") && !location.hasPrefix("https://") {
            location = "https://\(location)"
        }
        guard let url = URL(string: location) else {
            NSLog("Failed to convert location \(location) into a URL")
            return
        }
        loadURL(url)
    }

    func loadURL(_ url: URL) {
        guard self.isViewLoaded else {
            self.initialURL = url
            return
        }
        self.webView.load(URLRequest(url: url))
    }

    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.setHidesOnSwipesFromScrollView(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.setHidesOnSwipesFromScrollView(scrollView)
        if !self.shouldShowBars && scrollView.contentOffset.y == 0.0 {
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
        if self.shouldShowBars {
            // already showing bars, scroll to top
            return true
        }
        if scrollView.contentOffset.y > 1.0 {
            // big scroll, don't scroll quite to top so that we can detect being
            // told to again and show the status bar
            scrollView.setContentOffset(
                CGPoint(x: 0.0, y: 1.0), animated: true
            )
            return false
        }
        // We basically already are at the top, so this tap means show the bars
        self.shouldShowBars = true
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
            self.goBackButton.isEnabled = defChange[NSKeyValueChangeKey.newKey] as! Bool
        case "canGoForward":
            self.goForwardButton.isEnabled = defChange[NSKeyValueChangeKey.newKey] as! Bool
        case "navBarIsHidden":
            let navBarIsHidden = defChange[NSKeyValueChangeKey.newKey] as! Bool
            self.shouldShowBars = !navBarIsHidden
        case "pickerIsShowing":
            self._setExtraBarHiddenState()
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
                nc.hidesBarsOnSwipe = true
            }
        }
    }
    private func _setExtraBarHiddenState() {
        let pickerIsShowing = self.webViewContainerController.pickerIsShowing
        let toolBarIsShowing = !self.navigationController!.isToolbarHidden
        self.extraShowBarsView.isHidden = pickerIsShowing || toolBarIsShowing
    }
}
