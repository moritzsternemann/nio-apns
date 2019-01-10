//
//  main.swift
//  NIOAPNSExample
//

import NIO
import NIOAPNS

let keyId = "ASDF1337AS"
let teamId = "1337ASDF13"
let privateKeyPath = ".....AuthKey_ASDF1337AS.p8"
let topic = "com.example.PushExample"
let deviceToken = "..."

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let configuration = APNSConfiguration(keyId: keyId, teamId: teamId, privateKeyPath: privateKeyPath, server: .development)
let client = APNSClient(apnsTopic: topic, configuration: configuration, on: group)

let notificationItems: [APNSNotificationItem] = [
    .alertTitle("Hello Worl!"),
    .alertBody("Example body")
]
client.push(deviceToken: deviceToken, notificationItems: notificationItems) { response in
    print("done", response)
}

