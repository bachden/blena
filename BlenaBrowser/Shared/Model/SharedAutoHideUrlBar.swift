//
//  SharedAutoHideUrlBar.swift
//  blena
//
//  Created by Lê Vinh on 12/4/24.
//

import Foundation

enum AutoHideBarKey : String {
    case disableKey
}

class SharedAutoHideUrlBar{
    static let shared = SharedAutoHideUrlBar()
    func isAutoHideUrlBar() -> Bool {
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")
        let disable = ud?.bool(forKey: AutoHideBarKey.disableKey.rawValue) ?? false
        NSLog("disable cache session: \(disable)")
        return ud?.bool(forKey: AutoHideBarKey.disableKey.rawValue) ?? false
    }
    
    func setIsAutoHideUrlBar(_ value: Bool) {
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")
        ud?.set(value, forKey: AutoHideBarKey.disableKey.rawValue)
    }
}
