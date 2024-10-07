//
//  LocalIPGetter.swift
//  Blena
//
//  Created by Lê Vinh on 10/4/24.
//

import Foundation

func getLocalIPAddress() -> String? {
    var address: String?

    // Get list of all interfaces on the device
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }

    // Iterate through all interfaces
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee

        // Check for IPv4 or IPv6 interface
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

            // Convert interface name to a String
            let name = String(cString: interface.ifa_name)
            
            // Look for Wi-Fi connection (usually "en0" for Wi-Fi on iOS devices)
            if name == "en0" {

                // Convert the network address to a human-readable string
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
    }
    
    freeifaddrs(ifaddr)
    
    return address
}
