//
//  TabItem.swift
//  Blena
//
//  Created by Lê Vinh on 28/9/24.
//

import Foundation
import UIKit

struct TabItem {

    enum keys: String {
        case title, url
    }

    let title: String
    let url: URL

    var dictionary: [String: String] {
        get {
            return [
                TabItem.keys.title.rawValue: self.title,
                TabItem.keys.url.rawValue: self.url.absoluteString
            ]
        }
    }
    var assumedHTTPSURLPath: String {
        get {
            return self.url.absoluteString.replacingOccurrences(of: "https://", with: "")
        }
    }

    init (title: String, url: URL) {
        self.title = title
        self.url = url
    }

    init? (fromDictionary dictionary: [String: String]) {
        guard
            let title = dictionary[TabItem.keys.title.rawValue],
            let urlStr = dictionary[TabItem.keys.url.rawValue],
            let url = URL(string: urlStr)
        else {
            return nil
        }
        self.init(title: title, url: url)
    }

    static func == (left: TabItem, right: TabItem) -> Bool {
        return left.url == right.url
    }
}
