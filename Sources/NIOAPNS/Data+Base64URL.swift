//
//  Data+Base64URL.swift
//  NIOAPNS
//
//  Created by Kyle Browning on 1/10/19.
//

import Foundation

extension Data {
    func base64EncodedURLString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
