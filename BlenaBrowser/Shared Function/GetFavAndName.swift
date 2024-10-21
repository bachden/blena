//
//  GetFavAndName.swift
//  Blena
//
//  Created by Lê Vinh on 10/17/24.
//

import Foundation
import UIKit
import WebKit

@MainActor
class GetFavAndName{
    static let shared = GetFavAndName()
    
    func getFaviconAndTitle(_ webView: WKWebView) async throws -> (String, String) {
        // JavaScript to get the favicon and the page title
        let js = """
            (function() {
                let favicon = '';
                // Try to get favicon from link tags
                var nodeList = document.querySelectorAll('link[rel="icon"], link[rel="shortcut icon"], link[rel="apple-touch-icon"]');
                if (nodeList.length > 0) {
                    favicon = nodeList[0].href;
                }
                let title = document.title; // Get the title of the page

                return {
                    favicon: favicon,
                    title: title
                };
            })();
        """

        return try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(js) { (result, error) in
                if let resultDict = result as? [String: Any] {
                    // Extract the favicon and title from the result
                    let faviconUrl = resultDict["favicon"] as? String ?? "No Favicon"
                    let title = resultDict["title"] as? String ?? "No Title"

                    continuation.resume(returning: (faviconUrl, title))
                } else if let error = error {
                    continuation.resume(returning: ("No Fav", "No Tittle"))
                }
            }
        }
    }

}

