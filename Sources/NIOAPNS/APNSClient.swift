//
//  APNSClient.swift
//  NIOAPNS
//

import NIO

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
    }

    // MARK:
    
    ///
    public func push(deviceToken: String, notificationItems: [APNSNotificationItem], callback: @escaping (APNSNotificationResponse) -> ()) {
        push(deviceTokens: [deviceToken], notificationItems: notificationItems) { responses in
            callback(responses.first!)
        }
    }
    
    ///
    public func push(deviceTokens: [String], notificationItems: [APNSNotificationItem], callback: @escaping ([APNSNotificationResponse]) -> ()) {
        
    }
}
