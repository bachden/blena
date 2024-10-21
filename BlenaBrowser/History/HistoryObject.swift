//
//  HistoryObject.swift
//  blena
//
//  Created by Lê Vinh on 10/10/24.
//
import Foundation

class HistoryObject : Codable {
    let url : String
    let title : String
    let image : String
    let dateSuft : Date
    
    init(title: String, url: String, image: String, dateSuft: Date) {
        self.title = title
        self.url = url
        self.image = image
        self.dateSuft = dateSuft
    }
}

enum HistoryKeyword : String{
    case rawValue
}

class HistoryDataSource {
    static let shared = HistoryDataSource()
    
    // Non-optional array of HistoryObject
    var browserHistory: [HistoryObject]
    
    private init() {
        // Initialize the history, or use an empty array if no history is found
        // Initialize browserHistory first, then call getHistory()
        self.browserHistory = []
        if let history = getHistory() {
            self.browserHistory = history
        }
    }
    
    // Save history to UserDefaults
    func saveHistory() -> Bool {
        if (browserHistory.isEmpty){
            UserDefaults(suiteName: "group.com.nhb.blena")!.set(nil, forKey: HistoryKeyword.rawValue.rawValue)
        }
        if let data = try? JSONEncoder().encode(browserHistory) {
            UserDefaults(suiteName: "group.com.nhb.blena")!
                .set(data, forKey: HistoryKeyword.rawValue.rawValue)
            return true
        } else {
            return false
        }
    }
    
    // Retrieve history from UserDefaults
    func getHistory() -> [HistoryObject]? {
        if let data = UserDefaults(suiteName: "group.com.nhb.blena")!.data(
            forKey: HistoryKeyword.rawValue.rawValue
        ) {
            return try? JSONDecoder().decode([HistoryObject].self, from: data)
        } else {
            return nil
        }
    }
}

