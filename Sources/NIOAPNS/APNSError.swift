//
//  APNSError.swift
//  NIOAPNS

import Foundation

public enum APNSError: Error {
    case invalidAuthTokenFormat
    case invalidPrivateKey(StaticString)
    case signingFailed
}

extension APNSError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        default:
            fatalError()
        }
    }
}
