//
//  LastConnectedDevices.swift
//  blena
//
//  Created by Lê Vinh on 10/22/24.
//

import Foundation
class LastConnectedDevices : Codable {
    var name: String?
    var address: String?
    
    init(name: String? = nil, address: String? = nil) {
        self.name = name
        self.address = address
    }
}

enum LastConnectedUserDefaultsKey: String {
    case lastConnectedDevices
}

class LastConnectedDevicesList {
    static let shared = LastConnectedDevicesList()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.nhb.blena")
    
    /// Adds a new device to the list and saves it to UserDefaults.
    func add(_ device: LastConnectedDevices) {
        var devices = getDevices()
        devices.append(device)
        saveDevices(devices)
    }
    
    /// Retrieves the list of last connected devices from UserDefaults.
    func getDevices() -> [LastConnectedDevices] {
        guard let data = userDefaults?.data(forKey: LastConnectedUserDefaultsKey.lastConnectedDevices.rawValue) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([LastConnectedDevices].self, from: data)
        } catch {
            print("Error decoding devices: \(error)")
            return []
        }
    }
    
    /// Saves the list of last connected devices to UserDefaults.
    private func saveDevices(_ devices: [LastConnectedDevices]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(devices)
            userDefaults?.set(data, forKey: LastConnectedUserDefaultsKey.lastConnectedDevices.rawValue)
        } catch {
            print("Error encoding devices: \(error)")
        }
    }
}
