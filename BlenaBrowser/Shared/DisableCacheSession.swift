//
//  DisableCacheSession.swift
//  blena
//
//  Created by Lê Vinh on 10/28/24.
//

import Foundation

enum DisableCacheSessionKey : String {
    case disableKey
}

class DisableCacheSession{
    static let shared = DisableCacheSession()
    func isDisableCacheSession() -> Bool {
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")
        let disable = ud?.bool(forKey: DisableCacheSessionKey.disableKey.rawValue) ?? false
        NSLog("disable cache session: \(disable)")
        return ud?.bool(forKey: DisableCacheSessionKey.disableKey.rawValue) ?? false
    }
    
    func setDisableCacheSession(_ value: Bool) {
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")
        ud?.set(value, forKey: DisableCacheSessionKey.disableKey.rawValue)
    }
    
}
