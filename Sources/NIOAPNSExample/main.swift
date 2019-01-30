//
//  main.swift
//  NIOAPNSExample
//

import NIO
import NIOAPNS

func usage() {
    print("Usage: nio-apns-example [-q] <keyId> <teamId> <privateKeyPath> <topic> <deviceToken>")
    print("              -q: Quiet operation (suppress output).")
    print("           keyId: 10-character key identifier of your APNS private key.")
    print("          teamId: 10-character team identifier, obtained from your developer account.")
    print("  privateKeyPath: Path to your APNS private key (e.g. AuthKey_<key-id>.p8)")
    print("           topic: Topic of the remote notification, typically the bundle ID of your app.")
    print("     deviceToken: Unique device token of the target device.")
}

var args = Array(CommandLine.arguments.dropFirst())
var quiet = false

if args.first == "-q" {
    quiet = true
    args = Array(args.dropFirst())
}

guard args.count == 5 else {
    usage()
    exit(1)
}

let keyId = args[0]
let teamId = args[1]
let privateKeyPath = args[2]
let topic = args[3]
let deviceToken = args[4]

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

do {
    let configuration = try APNSConfiguration(keyId: keyId,
                                              teamId: teamId,
                                              privateKeyPath: privateKeyPath,
                                              server: .development)
    let client = try APNSClient(apnsTopic: topic, configuration: configuration, on: group)
    
    let notificationItems: [APNSNotificationItem] = [
        .alertTitle("Hello"),
        .alertBody("World!"),
        .sound("default")
    ]
    let response = try client.push(deviceToken: deviceToken, notificationItems: notificationItems).wait()
    
    if !quiet {
        print("done,", response.description)
    }
}
catch let error {
    print("Error: \(error.localizedDescription)")
}
