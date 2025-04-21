//
//  RegisterDisableSwipeDataSource.swift
//  blena
//
//  Created by Lê Vinh on 20/4/25.
//


//
//  HistoryObject.swift
//  blena
//
//  Created by Lê Vinh on 10/10/24.
//

import Foundation

// MARK: –– Model

class WebsiteDisableObject: Codable {
    let urlRegrex: String
    var enable: Bool     // ← make this mutable

    init(urlRegrex: String, enable: Bool = false) {
        self.urlRegrex = urlRegrex
        self.enable    = enable
    }
}

enum WebsiteDisableKey: String {
    case rawValue
}

// MARK: –– Data Source

class WebsiteDisableDataSource {
    static let shared = WebsiteDisableDataSource()

    private let userDefaults = UserDefaults(suiteName: "group.com.nhb.blena")
    private let storageKey  = WebsiteDisableKey.rawValue.rawValue

    /// Holds all of the regex+enable pairs
    private(set) var websiteDisableList: [WebsiteDisableObject]

    private init() {
        self.websiteDisableList = []
        if let saved = loadList() {
            self.websiteDisableList = saved
        } else {
            self.websiteDisableList = []
        }
    }

    /// Returns true only if there’s an enabled rule matching this URL
    func isDisableWebsite(url: String) -> Bool {
        return websiteDisableList.contains {
            $0.enable && url.contains($0.urlRegrex)
        }
    }

    /// Add a new regex (with an initial enable state)
    func addWebsite(urlRegrex: String, enable: Bool = false) {
        guard !websiteDisableList.contains(where: { $0.urlRegrex == urlRegrex }) else {
            return
        }
        let newRule = WebsiteDisableObject(urlRegrex: urlRegrex, enable: enable)
        websiteDisableList.append(newRule)
        save()
    }

    /// Update the `enable` flag on an existing regex
    func updateEnable(for urlRegrex: String, to enable: Bool) {
        guard let idx = websiteDisableList.firstIndex(where: { $0.urlRegrex == urlRegrex }) else {
            return
        }
        websiteDisableList[idx].enable = enable
        save()
    }

    /// Remove a regex entirely
    func removeWebsite(urlRegrex: String) {
        websiteDisableList.removeAll { $0.urlRegrex == urlRegrex }
        save()
    }

    // MARK: –– Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(websiteDisableList) else {
            print("⚠️ Failed to encode disable list")
            return
        }
        userDefaults?.set(data, forKey: storageKey)
    }

    private func loadList() -> [WebsiteDisableObject]? {
        guard let data = userDefaults?.data(forKey: storageKey) else {
            return nil
        }
        return try? JSONDecoder().decode([WebsiteDisableObject].self, from: data)
    }
}
