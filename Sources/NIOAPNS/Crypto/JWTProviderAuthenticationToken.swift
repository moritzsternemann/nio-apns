//
//  JWTProviderAuthenticationToken.swift
//  NIOAPNS
//

import Foundation

/// Codable representation of the JWT authentication token for the APNS api.
internal struct JWTProviderAuthenticationToken: CustomStringConvertible {
    /// Header of the authentication token object.
    struct Header: Codable {
        /// The encryption algorithm used to encrypt the token.
        let algorithm: String = "ES256"
        
        /// A 10-character key identifier, obtained from your developer account.
        let keyId: String
        
        /// See `Codable.CodingKeys`
        private enum CodingKeys: String, CodingKey {
            case algorithm = "alg"
            case keyId = "kid"
        }
    }
    
    /// Payload of the authentication token object.
    struct Payload: Codable {
        /// A 10-character Team ID, obtained from your developer account.
        let teamId: String
        
        /// Time at which the token was generated.
        let issueDate: Int
        
        /// See `Codable.CodingKeys`
        private enum CodingKeys: String, CodingKey {
            case teamId = "iss"
            case issueDate = "iat"
        }
    }
    
    // MARK: Init
    
    /// Creates a new `JWTProviderAuthenticationToken`.
    ///
    ///     let token = JWTProviderAuthenticationToken(keyId: ..., teamId: ...)
    ///
    /// - parameters:
    ///     - keyId: A 10-character key identifier, obtained from your developer account.
    ///     - teamId: A 10-character Team ID, obtained from your developer account.
    ///     - issueDate: Time at which the token was generated.
    init(keyId: String, teamId: String, issueDate: Date = Date()) throws {
        let header = Header(keyId: keyId)
        let payload = Payload(teamId: teamId, issueDate: Int(issueDate.timeIntervalSince1970.rounded()))
        
        let jsonEncoder = JSONEncoder()
        do {
            let headerString = try jsonEncoder.encode(header)
            let payloadString = try jsonEncoder.encode(payload)
            
            self.description = "\(headerString.base64EncodedURLString()).\(payloadString.base64EncodedURLString())"
        }
        catch {
            throw APNSError.invalidAuthTokenFormat
        }
    }
    
    /// String representation of the authentication token.
    public private(set) var description: String
}
