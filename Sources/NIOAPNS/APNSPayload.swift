//
//  APNSPayload.swift
//  NIOAPNS
//

import Foundation

fileprivate struct APS: Encodable {
    var alert: Alert?
    var badge: Int?
    var sound: String?
    var contentAvailable: Int?
    var category: String?
    var threadId: String?
    var mutableContent: Int?
    
    enum CodingKeys: String, CodingKey {
        case alert = "alert"
        case badge = "badge"
        case sound = "sound"
        case contentAvailable = "content-available"
        case category = "category"
        case threadId = "thread-id"
        case mutableContent = "mutable-content"
    }
}

fileprivate struct Alert: Encodable {
    var body: String?
    var title: String?
    var titleLocKey: String?
    var titleLocArgs: [String]?
    var actionLocKey: String?
    var locKey: String?
    var locArgs: [String]?
    var launchImage: String?
    
    enum CodingKeys: String, CodingKey {
        case body = "body"
        case title = "title"
        case titleLocKey = "title-loc-key"
        case titleLocArgs = "title-loc-args"
        case actionLocKey = "action-loc-key"
        case locKey = "loc-key"
        case locArgs = "loc-args"
        case launchImage = "launch-image"
    }
    
    var notEmpty: Bool {
        return body != nil
            || title != nil
            || titleLocKey != nil
            || actionLocKey != nil
            || locKey != nil
            || locArgs != nil
            || launchImage != nil
    }
}

internal struct APNSPayload: Encodable {
    private var aps = APS()
    // TODO: Find a way to include custom payload
    
    init(notificationItems items: [APNSNotificationItem]) {
        var alert = Alert()
        
        for item in items {
            switch item {
            case .alertBody(let body):
                alert.body = body
                
            case .alertTitle(let title):
                alert.title = title
                
            case .alertTitleLoc(let key, let args):
                alert.titleLocKey = key
                alert.titleLocArgs = args
                
            case .alertActionLoc(let key):
                alert.actionLocKey = key
                
            case .alertLoc(let key, let args):
                alert.locKey = key
                alert.locArgs = args
                
            case .alertLaunchImage(let image):
                alert.launchImage = image
                
            case .badge(let number):
                aps.badge = number
                
            case .sound(let sound):
                aps.sound = sound
                
            case .contentAvailable:
                aps.contentAvailable = 1
                
            case .category(let category):
                aps.category = category
                
            case .threadId(let threadId):
                aps.threadId = threadId
                
            case .customPayload(_, _):
                fatalError()
                
            case .mutableContent:
                aps.mutableContent = 1
            }
        }
        
        // only add alert payload if it's actually used
        aps.alert = alert.notEmpty ? alert : nil
    }
    
    var jsonString: String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        return String(data: jsonData, encoding: .utf8)
    }
}
