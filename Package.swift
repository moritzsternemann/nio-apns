// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "NIOAPNS",
    products: [
        .library(
            name: "NIOAPNS",
            targets: ["NIOAPNS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio-http2.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "NIOAPNS",
            dependencies: ["NIOHTTP2"]),
        .testTarget(
            name: "NIOAPNS-Tests",
            dependencies: ["NIOAPNS"]),
    ]
)
