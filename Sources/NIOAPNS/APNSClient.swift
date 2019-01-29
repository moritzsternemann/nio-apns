//
//  APNSClient.swift
//  NIOAPNS
//

import NIO
import NIOHTTP1
import NIOH2

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
    private let worker: EventLoopGroup
    
    ///
    private let client: HTTP2Client
    

    // MARK: Init

    ///
    public init(apnsTopic: String,
          expiration: APNSExpiration = .immediate,
          priority: APNSPriority = .immediate,
          collapseId: String? = nil,
          configuration: APNSConfiguration,
          on worker: EventLoopGroup) throws {
        self.apnsTopic = apnsTopic
        self.expiration = expiration
        self.priority = priority
        self.collapseId = collapseId
        self.configuration = configuration
        self.worker = worker
        
        self.client = try HTTP2Client.connect(hostname: K.apnsDevelopmentHost, port: Int(K.apnsPort), on: worker).wait()
    }

    // MARK:
    
    /// Push one message to a single device.
    ///
    ///     let notificationItems: [APNSNotificationItem] = [.alertTitle("Hello"), .alertBody("World!")]
    ///     let response = client.push(deviceToken: "...", notificationItems: notificationItems)
    ///
    /// - note: The returned future will resolve on the clients `EventLoop`.
    /// - parameters:
    ///     - deviceToken: The unique device token of the target device.
    ///     - notificationItems: A list of `APNSNotificationItem`s that represent the payload of the notification.
    /// - returns: A `EventLoopFuture` `APNSNotificationResponse` containing the server's response.
    public func push(deviceToken: String, notificationItems: [APNSNotificationItem]) -> EventLoopFuture<APNSNotificationResponse> {
        let payload = APNSPayload(notificationItems: notificationItems)
        return self.push(deviceToken: deviceToken, payload: payload)
    }
    
    /// Push one message to multiple devices.
    ///
    ///     let notificationItems: [APNSNotificationItem] = [.alertTitle("Hello"), .alertBody("World!")]
    ///     let response = client.push(deviceTokens: ["...", "..."], notificationItems: notificationItems)
    ///
    /// - note: The returned future will resolve on the clients `EventLoop`.
    /// - parameters:
    ///     - deviceTokens: A list of unique device tokens of the target devices.
    ///     - notificationItems: A list of `APNSNotificationItem`s that represent the payload of the notification.
    /// - returns: A `EventLoopFuture` `APNSNotificationResponse` containing the server's response.
    public func push(deviceTokens: [String], notificationItems: [APNSNotificationItem]) -> EventLoopFuture<[APNSNotificationResponse]> {
        let payload = APNSPayload(notificationItems: notificationItems)
        return self.push(deviceTokens: deviceTokens, payload: payload)
    }
    
    // MARK:
    
    ///
    private var pushHeaders: HTTPHeaders {
        var headers = HTTPHeaders([
            ("content-type", "application/json; charset=utf-8"),
            ("apns-expiration", "\(self.expiration.rawValue)"),
            ("apns-priority", "\(self.priority.rawValue)"),
            ("apns-topic", self.apnsTopic),
            ("authorization", self.configuration.authorizationHeader)
            ])
        if let cid = self.collapseId {
            headers.add(name: "apns-collapse-id", value: cid)
        }
        
        return headers
    }
    
    ///
    private func push(deviceToken: String, payload: APNSPayload) -> EventLoopFuture<APNSNotificationResponse> {
        guard let payloadString = payload.jsonString else {
            fatalError()
        }
        
        let url = "\(K.pushEndpoint)/\(deviceToken)"
        let request = HTTPRequest(method: .POST, url: url, headers: self.pushHeaders, body: payloadString)
        
        return self.client.send(request)
            .map(to: APNSNotificationResponse.self) { response in
                APNSNotificationResponse(status: response.status, body: response.body.description)
            }
    }
    
    ///
    private func push(deviceTokens: [String], payload: APNSPayload) -> EventLoopFuture<[APNSNotificationResponse]> {
        var futures: [EventLoopFuture<APNSNotificationResponse>] = []
        
        for deviceToken in deviceTokens {
            futures.append(push(deviceToken: deviceToken, payload: payload))
        }
        
        let allResponses = EventLoopFuture<[APNSNotificationResponse]>
            .reduce(into: [], futures, eventLoop: self.worker.eventLoop) { (acc, result) in
                acc.append(result)
            }
        
        return allResponses
    }
}
