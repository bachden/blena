//
//  TooltipView.swift
//  blena
//
//  Created by Lê Vinh on 12/7/24.
//
import Foundation


class TooltipView{
    
}


enum FirstTimeUseApp : String {
    case isFirstTime
}

class IsFirstTimeUseApp{
    static let shared = IsFirstTimeUseApp()
    func isFirstTime() -> Bool {
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")
        let firstTime = ud?.bool(forKey: FirstTimeUseApp.isFirstTime.rawValue) ?? false
        NSLog("first time open: \(firstTime)")
        return firstTime
    }
    
    func setIsFirstTime(_ value: Bool) {
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")
        ud?.set(value, forKey: FirstTimeUseApp.isFirstTime.rawValue)
    }
    
}
