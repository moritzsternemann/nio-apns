//
//  APNSHeader.swift
//  NIOAPNS
//
//  Created by Kyle Browning on 1/10/19.
//

import Foundation

public struct Header: Codable {
    /// alg
    public let algorithm: String = "ES256"
    
    /// kid
    public let keyID: String
    
    enum CodingKeys: String, CodingKey {
        case keyID = "kid"
        case algorithm = "alg"
    }
}
