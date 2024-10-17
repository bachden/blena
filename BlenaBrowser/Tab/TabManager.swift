//
//  TabManager.swift
//  Blena
//
//  Created by Lê Vinh on 28/9/24.
//

import Foundation

class TabManager {

    // MARK: - Properties
    let userDefaults: UserDefaults
    let key: String
    var tabItems: [TabItem]
    
    

    init (userDefaults: UserDefaults, key: String) {
        self.key = key
        self.userDefaults = userDefaults

        let bma = self.userDefaults.array(forKey: key) ?? [Any]()

        var bms = [TabItem]()
        for bment in bma {
            guard
                let bmd = bment as? [String: String],
                let bm = TabItem(fromDictionary: bmd)
                else {
                    NSLog("Bad entry in bookmarks dict \(bment)")
                    continue
            }
            bms.append(bm)
        }
        self.tabItems = bms
    }
    func addBookmarks(_ bookmarks: [TabItem]) {
        self.tabItems.append(contentsOf: bookmarks)
        self.userDefaults.set(self.tabItems.map{$0.dictionary}, forKey: self.key)
    }
    func mergeInBookmarks(bookmarks: [TabItem]) {
        let toAdd = tabItems.filter{bm in !self.tabItems.contains(where: {$0 == bm})}
        self.addBookmarks(toAdd)
    }
    func mergeInBookmarkDicts(bookmarkDicts: [[String: String]]) {
        let bms = bookmarkDicts.map{TabItem(fromDictionary: $0)}.filter{$0 != nil}.map{$0!}
        self.mergeInBookmarks(bookmarks: bms)
    }
    func saveBookmarks() {
        let bms = self.tabItems.map{$0.dictionary}
        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        ud.set(bms, forKey: self.key)
        ud.synchronize()
    }
}
