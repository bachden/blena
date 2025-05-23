//
//  WBWebViewContainerController.swift
//  Blena
//
//  Created by David Park on 23/09/2019.
//

import UIKit
@preconcurrency import WebKit

protocol ConsoleToggler {
    func toggleConsole()
}

class WBWebViewContainerController: UIViewController, WKNavigationDelegate, WKUIDelegate, WBPicker, ConnectDeviceDelegate {
    func dismissVC() {
        self.BluetoothDeviceController?.dismiss(animated: true)
    }
    
    func addRow(_ row: String) {
        return ;
    }
    
    
    enum prefKeys: String {
        case lastLocation
    }
    
    @IBOutlet var loadingProgressContainer: UIView!
    @IBOutlet var loadingProgressView: UIView!
    
    // At some point it might be nice to try and handle back and
    // forward in the browser better, i.e. by managing multiple managers
    // for recent pages so that you can go back and forward to them
    // without losing bluetooth connections, or at least notifying that
    // the devices have been disconnected
    var wbManager: WBManager?
    
    var webViewController: WBWebViewController {
        get {
            return self.children
                .first(
                    where: {$0 as? WBWebViewController != nil
                    }) as! WBWebViewController
        }
    }
    var webView: WBWebView {
        get {
            return self.webViewController.webView
        }
    }
    
    // If the pop up picker is showing, then the
    // following two vars are not null.
    @objc var pickerIsShowing = false
    var popUpPickerBottomConstraint: NSLayoutConstraint!
    var BluetoothDeviceController : ConnectDeviceViewController?

    // MARK: - IBActions
    @IBAction public func toggleConsole() {
        if let consoleToggler = self.parent as? ConsoleToggler {
            consoleToggler.toggleConsole()
        }
    }
    
    // MARK: - View Event handling
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.addNavigationDelegate(self)
        self.webView.uiDelegate = self
        
        for path in ["estimatedProgress"] {
            self.webView
                .addObserver(
                    self,
                    forKeyPath: path,
                    options: .new,
                    context: nil
                )
        }
    }
    
    // MARK: - WBPicker
    public func showPicker() {
        let storyboard = UIStoryboard(name: "WBCore", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "ConnectDeviceBluetooth") as? ConnectDeviceViewController {
            settingsVC.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = settingsVC.sheetPresentationController {
                    // Customize detents (heights) for the bottom sheet
                    sheet.detents = [.medium() ,.large()] // Medium and large sizes
                    sheet.largestUndimmedDetentIdentifier = .large
                }
            } else {
                // Fallback on earlier versions
            }

            // Present the bottom sheet
            settingsVC.wbManager = self.wbManager
            self.BluetoothDeviceController = settingsVC
            self.present(settingsVC, animated: true, completion: nil)
            
        }
    }
    public func updatePicker() {
        self.BluetoothDeviceController?.tableView?.reloadData()
    }
    
    // MARK: - WKNavigationDelegate
    public func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        self.loadingProgressContainer.isHidden = false
        self._configureNewManager()
        // Optionally, clear JavaScript-accessible cache
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let urlString = webView.url?.absoluteString,
           urlString != "about:blank" {
            UserDefaults(suiteName: "group.com.nhb.blena")!
                .setValue(
                    urlString,
                    forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue
                )
            UserDefaults(suiteName: "group.com.nhb.blena")!
                .setValue(urlString, forKey: "LastDirectLocation")
            let backForwardList = webView.backForwardList.backList
            for item in backForwardList {
                NSLog(item.url.absoluteString)
            }
        }
        let script = """
                (function() {
                    var rgb = window.getComputedStyle(document.body).backgroundColor;
                    return rgb;
                })();
                """
        
            
    self.loadingProgressContainer.isHidden = true
           
        // Inject JavaScript and handle the result
        webView.evaluateJavaScript(script) {
 [weak self] result,
 error in
            let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
            if(result == nil){
                ud.setValue("#FFFFFF", forKey: "StatusBarColor")
            }
            else if(result as! String == "rgba(0, 0, 0, 0)"){
                ud.setValue("#FFFFFF", forKey: "StatusBarColor")
            } else {
                ud
                    .setValue(
                        self?.rgbToHex(rgb: (result as! String)),
                        forKey: "StatusBarColor"
                    )
            }
            if let rgbString = result as? String {
                // Convert the RGB string to Hex in Swift
                if let hexColor = self?.rgbToHex(rgb: rgbString) {
                    print("Hex Color: \(hexColor)")
                }
            } else if let error = error {
                print(
                    "Error evaluating JavaScript: \(error.localizedDescription)"
                )
            }
            
        }
        
        if(webView.url != nil && webView.url?.absoluteString != "homepage://"){
            let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
            if(ud.data(forKey: HistoryKeyword.rawValue.rawValue) == nil){
                Task {
                    do {
                        let (favIcon, title) = try await GetFavAndName.shared.getFaviconAndTitle(webView)
                        HistoryDataSource.shared.browserHistory.insert(HistoryObject(title: title, url: webView.url!.absoluteString, image: favIcon, dateSuft: Date()), at: 0)
                        let saveStatus = HistoryDataSource.shared.saveHistory()
                        NSLog("\(saveStatus)")
                    } catch {
                        print("Failed to fetch favicon and title: \(error)")
                    }
                }
            } else if let historyData = ud.data(forKey: HistoryKeyword.rawValue.rawValue), let history = try? JSONDecoder().decode([HistoryObject].self, from: historyData), history.first?.url == webView.url!.absoluteString{
                return;
            } else {
                Task {
                    do {
                        let (favIcon, title) = try await GetFavAndName.shared.getFaviconAndTitle(webView)
                        HistoryDataSource.shared.browserHistory.insert(HistoryObject(title: title, url: webView.url!.absoluteString, image: favIcon, dateSuft: Date()), at: 0)
                        let saveStatus = HistoryDataSource.shared.saveHistory()
                        NSLog("\(saveStatus)")
                    } catch {
                        print("Failed to fetch favicon and title: \(error)")
                    }
                }
            }
                // Update the UI or open a specific view in response to the intent
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   let window = appDelegate.window,
                   let rootVC = window.rootViewController as? UINavigationController,
                   let viewController = rootVC.topViewController as? ViewController {
                    if(SharedAutoHideUrlBar.shared.isAutoHideUrlBar()){
                        viewController.hideUrlStackView()
                    }
                }
            
            if let urlString = webView.url?.absoluteString,
               WebsiteDisableDataSource.shared.isDisableWebsite(url: urlString) {
                webView.allowsBackForwardNavigationGestures = false
            } else {
                webView.allowsBackForwardNavigationGestures = true
            }
        }
        
            
    }
    
    // Function to convert RGB string to Hex in Swift
    func rgbToHex(rgb: String) -> String? {
        // Extract the rgb values using a regex
        let regex = try! NSRegularExpression(pattern: "\\d+")
        let matches = regex.matches(
            in: rgb,
            range: NSRange(rgb.startIndex..., in: rgb)
        )
            
        let rgbValues = matches.compactMap {
            Int((rgb as NSString).substring(with: $0.range))
        }
            
        guard rgbValues.count == 3 else {
            return nil
        } // Ensure there are exactly 3 RGB values
            
        let red = rgbValues[0]
        let green = rgbValues[1]
        let blue = rgbValues[2]
            
        // Convert to hex and pad with zeroes if necessary
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        NSLog(error.localizedDescription)
        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            let alert = UIAlertController(
                title: "No Internet Connection",
                message: "Please check your internet connection and try again.",
                preferredStyle: .alert
            )
            alert
                .addAction(
                    UIAlertAction(title: "OK", style: .default, handler: nil)
                )
            
            // Present the alert
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                                  y: self.view.bounds.midY,
                                                                  width: 0,
                                                                  height: 0)
                popoverPresentationController.permittedArrowDirections = []
            }
            
            self.present(alert, animated: true, completion: nil)
            self.loadingProgressContainer.isHidden = true
            return
        }
        if (error as NSError).code == NSURLErrorCancelled {
            self.loadingProgressContainer.isHidden = true
            return
        }
        self.loadingProgressContainer.isHidden = true
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        let lastLocation = ud.string(
            forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue
        )
        NSLog(lastLocation!)
        let cleanedURL = lastLocation?.replacingOccurrences(
            of: "https://",
            with: ""
        ) ?? "homepage://"
        self._maybeShowErrorUI(URL(string: cleanedURL)!)
    }
    
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        NSLog(error.localizedDescription)
        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            let alert = UIAlertController(
                title: "No Internet Connection",
                message: "Please check your internet connection and try again.",
                preferredStyle: .alert
            )
            alert
                .addAction(
                    UIAlertAction(title: "OK", style: .default, handler: nil)
                )
            // Present the alert
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                                  y: self.view.bounds.midY,
                                                                  width: 0,
                                                                  height: 0)
                popoverPresentationController.permittedArrowDirections = []
            }
            self.present(alert, animated: true, completion: nil)
            self.loadingProgressContainer.isHidden = true
            return
        }
        if (error as NSError).code == NSURLErrorCancelled {
            self.loadingProgressContainer.isHidden = true
            return
        }
        self.loadingProgressContainer.isHidden = true
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        let lastLocation = ud.string(
            forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue
        )
        NSLog(lastLocation!)
        let cleanedURL = lastLocation?.replacingOccurrences(
            of: "https://",
            with: ""
        ) ?? "homepage://"
        self._maybeShowErrorUI(URL(string: cleanedURL)!)
    }
    
    
    
    // MARK: - WKUIDelegate
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: (@escaping () -> Void)
    ) {
        let alertController = UIAlertController(
            title: frame.request.url?.host, message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "OK", style: .default, handler: {_ in completionHandler()}))
        // Present the alert
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                              y: self.view.bounds.midY,
                                                              width: 0,
                                                              height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Observe protocol
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard
            let defKeyPath = keyPath,
            let defChange = change
        else {
            NSLog(
                "Unexpected change with either no keyPath or no change dictionary!"
            )
            return
        }
        switch defKeyPath {
        case "estimatedProgress":
            let estimatedProgress = defChange[NSKeyValueChangeKey.newKey] as! Double
            let fwidth = self.loadingProgressContainer.frame.size.width
            let newWidth: CGFloat = CGFloat(estimatedProgress) * fwidth
            if newWidth < self.loadingProgressView.frame.size.width {
                self.loadingProgressView.frame.size.width = newWidth
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.loadingProgressView.frame.size.width = newWidth
                })
            }
        default:
            NSLog("Unexpected change observed by ViewController: \(defKeyPath)")
        }
    }
    
    // MARK: - Private
    private func _configureNewManager() {
        self.wbManager?.clearState()
        self.wbManager = WBManager(devicePicker: self, connectDeviceDelegate: self)
        self.webView.wbManager = self.wbManager
    }

    private func _maybeShowErrorUI(_ error: URL) {
        if(error.absoluteString == "homepage://"){
            self.webView.load(URLRequest(url: URL(string: "homepage://")!))
        } else {
            var urlRequest = URLRequest(url: URL(string: "https://www.google.com/search?q=" + error.absoluteString)!)
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
            self.webView.load(urlRequest)
        }
    }
}
