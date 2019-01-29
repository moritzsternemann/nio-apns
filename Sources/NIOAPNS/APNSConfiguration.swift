//
//  APNSConfiguration.swift
//  NIOAPNS

import Foundation

public final class APNSConfiguration {
    
    // MARK: Properties
    
    ///
    private let keyId: String?
    
    ///
    private let teamId: String?
    
    ///
    private let privateKeyPath: String?
    
    ///
    public let authorizationHeader: String
    
    ///
    let server: APNSServer
    
    ///
    var apnsHost: String {
        switch server {
        case .development:
            return K.apnsDevelopmentHost
        case .production:
            return K.apnsProductionHost
        case .test(let host, _):
            return host
        }
    }
    
    ///
    var apnsPort: UInt16 {
        switch server {
        case .test(_, let port):
            return port
        default:
            return K.apnsPort
        }
    }
    
    // MARK: Init
    
    public init(keyId: String, teamId: String, privateKeyPath: String, server: APNSServer) throws {
        self.keyId = keyId
        self.teamId = teamId
        self.privateKeyPath = privateKeyPath
        self.server = server
        
        let authToken = try JWTProviderAuthenticationToken(keyId: keyId, teamId: teamId)
        guard let authTokenHash = authToken.description.data(using: .utf8)?.sha256() else {
            throw APNSError.invalidAuthTokenFormat
        }
        
        let privateKeyUrl = URL(fileURLWithPath: privateKeyPath)
        let signingKey = try APNSSigningKey(url: privateKeyUrl)
        
        let signature = try signingKey.sign(digest: authTokenHash)
        let headerDigest = "\(authToken.description).\(signature.base64EncodedURLString())"
        
        self.authorizationHeader = "bearer \(headerDigest)"
    }
    
}
