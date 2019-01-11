//
//  APNSPayload.swift
//  NIOAPNS
//
//  Created by Kyle Browning on 1/10/19.
//

import Foundation

public struct Payload: Codable {
    /// iss
    public let teamId: String
    
    /// iat
    public let issueDate: Int
    
    enum CodingKeys: String, CodingKey {
        case teamId = "iss"
        case issueDate = "iat"
    }
}
