//
//  APNSClient.swift
//  NIOAPNS
//

import NIO
import NIOH2
import NIOHTTP1
import Foundation

///
public final class APNSClient {

    // MARK: Properties
    
    ///
    private let apnsTopic: String
    
    ///
    private let expiration: APNSExpiration
    
    ///
    private let priority: APNSPriority
    
    ///
    private let collapseId: String?
    
    ///
    private let configuration: APNSConfiguration
    
    ///
    private let group: EventLoopGroup
    // MARK: Init

    ///
    public init (apnsTopic: String,
          expiration: APNSExpiration = .immediate,
          priority: APNSPriority = .immediate,
          collapseId: String? = nil,
          configuration: APNSConfiguration,
          on: EventLoopGroup) {
        self.apnsTopic = apnsTopic
        self.expiration = expiration
        self.priority = priority
        self.collapseId = collapseId
        self.configuration = configuration
        self.group = on
    }

    // MARK:
    
    ///
    public func push(deviceToken: String, notificationItems: [APNSNotificationItem], callback: @escaping (APNSNotificationResponse) -> ()) {
        push(deviceTokens: [deviceToken], notificationItems: notificationItems) { responses in
            callback(responses.first!)
        }
    }
    
    ///
    // TODO: Proper do catch try/ throw.
    public func push(deviceTokens: [String], notificationItems: [APNSNotificationItem], callback: @escaping ([APNSNotificationResponse]) -> ()) {
        // temp
        guard let keyId = self.configuration.keyId,
            let teamId = self.configuration.teamId,
            let privateKeyPath = self.configuration.privateKeyPath else {
            // TODO: throw proper error.
            return
        }
        let header = Header(keyID: keyId)
        let iat = Int(Date().timeIntervalSince1970.rounded())
        let payload = Payload(teamId: teamId, issueDate: iat)
        
        let headerString = try! JSONEncoder().encode(header.self).base64EncodedURLString()
        let payloadString = try! JSONEncoder().encode(payload.self).base64EncodedURLString()
        let digest = "\(headerString).\(payloadString)"
        let signingKey = SigningKey(url: URL(fileURLWithPath: privateKeyPath))!
        let fixedDigest = sha256(message: digest.data(using: .utf8)!)
        let signature = try! signingKey.sign(digest: fixedDigest)
        let headerDigest = digest + "." + signature.base64EncodedURLString()
        let hostname = self.configuration.apnsHost
        let client = try! HTTP2Client.connect(hostname: hostname, on: group).wait()
        let authorizationHeader = "bearer \(headerDigest)"
        let headers: [(String, String)] = [
            ("content-type", "application/json"),
            ("apns-topic", self.apnsTopic),
            ("authorization", authorizationHeader),
        ]
        let apn:String = "{\"aps\": {\"badge\": 1,\"category\": \"mycategory\",\"alert\": {\"title\": \"my title\",\"subtitle\": \"my subtitle\",\"body\": \"my body text message\"}},\"custom\": {\"mykey\": \"myvalue\"}}"
        let request = HTTPRequest.init(method: .POST, url: "/3/device/\(deviceTokens.first!)", version: .init(major: 2, minor: 0), headers: HTTPHeaders(headers), body: apn)
        let response = try! client.send(request).wait()
            print(response.description)
    }
}
