import Foundation
import WebKit
import UIKit

class SingleWebView: UIViewController {
    var webView: WKWebView!
    var urlRequest: URLRequest?
    
    // Custom initializer to pass URLRequest
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required initializer for UIViewController subclass
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        view.backgroundColor = .systemBackground
        setupWebView()
        
        // Load the passed URLRequest if available
        if let request = urlRequest {
            webView.load(request)
        }
    }
    
    private func setupWebView() {
        webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        // Add constraints to make the web view fill the view controller
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
