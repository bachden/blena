//
//  CustomURLSchemeHandler.swift
//  Blena
//
//  Created by Lê Vinh on 10/7/24.
//

import Foundation
import WebKit
import UIKit

// Custom Scheme Handler
class HomepageSchemeHandler: NSObject, WKURLSchemeHandler {
    
    // This method is called when the web view starts loading a URL with the custom scheme.
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        // Only handle "homepage" scheme
        if let url = urlSchemeTask.request.url, url.scheme == "homepage" {
            
            // Define the HTML content to be displayed
            let htmlString = homePageHTMLPage
            
            // Convert the HTML string to Data
            let data = htmlString.data(using: .utf8)!
            
            // Create a URL response with the correct MIME type for HTML
            let response = URLResponse(url: url, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: "utf-8")
            
            // Pass the response and data to the URL scheme task
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()  // Mark the request as finished
        }
    }
    
    // This method is called when the request is stopped or cancelled.
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Clean up resources if needed (not necessary in this simple case)
    }
}

