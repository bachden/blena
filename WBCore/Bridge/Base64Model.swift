//
//  Base64Model.swift
//  Blena
//
//  Created by Lê Vinh on 31/03/2025.
//

import Foundation

class Base64Model {
    var base64 : String
    var width : Int
    var height : Int
    var name : String
    var type : String
    
    init(base64: String, width: Int, height: Int, name: String, type: String) {
        self.base64 = base64
        self.width = width
        self.height = height
        self.name = name
        self.type = type
    }
    
    func jsonify() -> String {
            let dict: [String: Any] = [
                "base64": base64,
                "width": width,
                "height": height,
                "name": name,
                "type": type
            ]
        return (dict as Jsonifiable).jsonify()
        }
}
