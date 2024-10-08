//
//  GlobalScriptDataSource.swift
//  Blena
//
//  Created by Lê Vinh on 10/8/24.
//

import Foundation

// Singleton class to manage a global data source
class GlobalDataSource {
    static let shared = GlobalDataSource()

    // Sample data source (array of strings in this case)
    var data: [String] = []

    private init() {} // Private initializer to ensure only one instance is created
}

// Function to add data to the global data source
func addDataToDataSource(_ data: String) {
    GlobalDataSource.shared.data.insert(data, at: 0)
    print("Data added:", data)
}

// Function to get all data from the global data source
func getDataSource() -> [String] {
    return GlobalDataSource.shared.data
}
