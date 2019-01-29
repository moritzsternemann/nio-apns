//
//  APNSPayloadTests.swift
//  NIOAPNSTests
//

import XCTest
@testable import NIOAPNS

final class APNSPayloadTests: XCTestCase {
    func testBasicAlert() {
        let items: [APNSNotificationItem] = [
            .alertTitle("Hello World"),
            .alertBody("This is a basic alert")
        ]
        let payload = APNSPayload(notificationItems: items)
        
        XCTAssertEqual(payload.jsonString,
            "{\"aps\":{\"alert\":{\"title\":\"Hello World\",\"body\":\"This is a basic alert\"}}}")
    }
    
    func testBasicAPSParameters() {
        var items: [APNSNotificationItem]
        var payload: APNSPayload
        
        items = [.badge(1337)]
        payload = APNSPayload(notificationItems: items)
        XCTAssertEqual(payload.jsonString, "{\"aps\":{\"badge\":1337}}")
        
        items = [.sound("1337.wav")]
        payload = APNSPayload(notificationItems: items)
        XCTAssertEqual(payload.jsonString, "{\"aps\":{\"sound\":\"1337.wav\"}}")
        
        items = [.contentAvailable]
        payload = APNSPayload(notificationItems: items)
        XCTAssertEqual(payload.jsonString, "{\"aps\":{\"content-available\":1}}")
    }
    
    func testComplete() {
        let items: [APNSNotificationItem] = [
            .alertBody("Test alert body"),
            .alertTitle("Alert title"),
            .alertTitleLoc("TEST_ALERT_TITLE", ["Parameter1", "Parameter2"]),
            .alertActionLoc("TEST_ALERT_ACTION"),
            .alertLoc("TEST_ALERT_BODY", ["Foobar1", "Foobar2"]),
            .alertLaunchImage("launchimage1337.jpg"),
            .badge(1337),
            .sound("foobar.wav"),
            .contentAvailable,
            .category("TEST_ALERT_CATEGORY"),
            .threadId("TEST_ALERT_GROUP1"),
            .mutableContent
        ]
        let payload = APNSPayload(notificationItems: items)
        
        XCTAssertEqual(payload.jsonString,
            """
            {"aps":{"category":"TEST_ALERT_CATEGORY","badge":1337,"sound":"foobar.wav","content-available":1,"alert":{"loc-args":["Foobar1","Foobar2"],"title":"Alert title","title-loc-args":["Parameter1","Parameter2"],"title-loc-key":"TEST_ALERT_TITLE","action-loc-key":"TEST_ALERT_ACTION","body":"Test alert body","loc-key":"TEST_ALERT_BODY","launch-image":"launchimage1337.jpg"},"thread-id":"TEST_ALERT_GROUP1","mutable-content":1}}
            """)
    }
    
    static var allTests = [
        ("testBasicAlert", testBasicAlert)
    ]
}
