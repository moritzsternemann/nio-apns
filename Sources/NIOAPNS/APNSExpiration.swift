//
//  APNSExpiration.swift
//  NIOAPNS
//

import Foundation

/// Time in the future when the notification, if has not been able to be deliver, will expire.
public enum APNSExpiration: RawRepresentable {
    /// See `RawRepresentable.RawValue`
    public typealias RawValue = Int
    
    /// Discard the notification if it can't be immediately delivered.
    case immediate
    
    /// Discard the notification at a relative time in the future.
    case relative(Int)
    
    /// Discard the notification at a point in time (UTC since epoch).
    case absolute(Int)
    
    ///
    public var rawValue: Int {
        switch self {
        case .immediate: return 0
        case .relative(let v): return Int(time(nil)) + v
        case .absolute(let v): return v
        }
    }
    
    /// Creates a new absolute `APNSExpiration`.
    public init?(rawValue: Int) {
        self = .absolute(rawValue)
    }
}
