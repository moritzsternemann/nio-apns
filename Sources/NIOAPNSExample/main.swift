//
//  main.swift
//  NIOAPNSExample
//

import NIO
import NIOAPNS
import Utility

let arguments = Array(CommandLine.arguments.dropFirst())
let parser = ArgumentParser(usage: "<OPTIONS>", overview: "Example APNS client")

let quietOption = parser.add(
    option: "--quiet",
    shortName: "-q",
    kind: Bool.self,
    usage: "Quiet operation (suppress output).")
let keyIdOption = parser.add(
    option: "--keyId",
    shortName: "-k",
    kind: String.self,
    usage: "10-character key identifier of your APNS private key.")
let teamIdOption = parser.add(
    option: "--teamId",
    shortName: "-i",
    kind: String.self,
    usage: "10-character team identifier, obtained from your developer account.")
let privateKeyPathOption = parser.add(
    option: "--privateKeyPath",
    shortName: "-p",
    kind: String.self,
    usage: "Path to your APNS private key (e.g. AuthKey_<key-id>.p8)")
let topicOption = parser.add(
    option: "--topic",
    shortName: "-t",
    kind: String.self,
    usage: "Topic of the remote notification, typically the bundle ID of your app.")
let deviceTokenOption = parser.add(
    option: "--deviceToken",
    shortName: "-d",
    kind: String.self,
    usage: "Unique device token of the target device.")

do {
    let parsedArguments = try parser.parse(arguments)
    
    let quiet = parsedArguments.get(quietOption) ?? false
    guard let keyId = parsedArguments.get(keyIdOption) else {
        throw ArgumentParserError.expectedValue(option: "--keyId")
    }
    guard let teamId = parsedArguments.get(teamIdOption) else {
        throw ArgumentParserError.expectedValue(option: "--teamId")
    }
    guard let privateKeyPath = parsedArguments.get(privateKeyPathOption) else {
        throw ArgumentParserError.expectedValue(option: "--privateKeyPath")
    }
    guard let topic = parsedArguments.get(topicOption) else {
        throw ArgumentParserError.expectedValue(option: "--topic")
    }
    guard let deviceToken = parsedArguments.get(deviceTokenOption) else {
        throw ArgumentParserError.expectedValue(option: "--deviceToken")
    }
    
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    let configuration = try APNSConfiguration(keyId: keyId, teamId: teamId, privateKeyPath: privateKeyPath, server: .development)
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
catch let error as ArgumentParserError {
    print(error.description)
}
catch let error {
    print("Error: \(error.localizedDescription)")
}
