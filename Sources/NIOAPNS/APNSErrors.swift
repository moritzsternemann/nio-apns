//
//  APNSErrors.swift
//  NIOAPNS
//
//  Created by Kyle Browning on 1/10/19.
//

import Foundation
public enum APNSError: Error {
    case invalidP8
    case couldNotSign
}

extension APNSError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidP8:
            return "The .p8 string has invalid format."
        case .couldNotSign:
            return "couldNotSign."
        }
    }
}
