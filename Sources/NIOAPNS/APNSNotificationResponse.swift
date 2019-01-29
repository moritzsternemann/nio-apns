//
//  APNSNotificationResponse.swift
//  NIOAPNS
//

import NIOHTTP1

///
public struct APNSNotificationResponse: CustomStringConvertible {
    
    ///
    internal let status: HTTPResponseStatus
    
    ///
    internal let body: String

    /// See `CustomStringConvertible.description`
    public var description: String {
        return "\(status): \(body)"
    }
}
