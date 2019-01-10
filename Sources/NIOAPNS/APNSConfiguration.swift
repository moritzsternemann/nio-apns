//
//  APNSConfiguration.swift
//  NIOAPNS

public final class APNSConfiguration {
    
    // MARK: Properties
    
    ///
    let keyId: String?
    
    ///
    let teamId: String?
    
    ///
    let privateKeyPath: String?
    
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
    
    public init(keyId: String, teamId: String, privateKeyPath: String, server: APNSServer) {
        self.keyId = keyId
        self.teamId = teamId
        self.privateKeyPath = privateKeyPath
        self.server = server
    }
    
}
