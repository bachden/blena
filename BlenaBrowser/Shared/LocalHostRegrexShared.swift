//
//  LocalHostRegrexShared.swift
//  blena
//
//  Created by Lê Vinh on 10/22/24.
//

import Foundation

class LocalHostRegrexShared{
    static let shared = LocalHostRegrexShared()
    
    func isLocalHost(_ host: String) -> Bool{
        return useRegex(for: host)
    }
    
    private func useRegex(for text: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "([0-9]+(\\.[0-9]+)+)", options: [.caseInsensitive])
        let range = NSRange(location: 0, length: text.count)
        let matches = regex.matches(in: text, options: [], range: range)
        return matches.first != nil
    }
}
