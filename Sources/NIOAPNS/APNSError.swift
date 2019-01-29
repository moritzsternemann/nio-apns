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
        case .invalidAuthTokenFormat:
            return "Could not build JWT auth token."
        case .invalidPrivateKey(let error):
            return "The private key is invalid: \(error)."
        case .signingFailed:
            return "Internal signing error."
        }
    }
}
