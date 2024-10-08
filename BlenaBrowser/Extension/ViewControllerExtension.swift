//
//  ViewControllerExtension.swift
//  Blena
//
//  Created by Lê Vinh on 10/8/24.
//

import Foundation
import WebKit

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "consoleHandler", let logMessage = message.body as? String {
            NSLog("JavaScript console.log: \(logMessage)")
            addDataToDataSource(logMessage)
        }
    }
}
