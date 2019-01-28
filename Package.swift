// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "nio-apns",
    products: [
        .executable(
            name: "nio-apns-example",
            targets: ["NIOAPNSExample"]
        ),
        .library(
            name: "NIOAPNS",
            targets: ["NIOAPNS"]
        ),
    ],
    dependencies: [
      .package(
          url: "https://github.com/moritzsternemann/nio-h2",
          .upToNextMinor(from: "0.1.0")
      ),
      .package(
          url: "https://github.com/IBM-Swift/OpenSSL",
          .upToNextMinor(from: "2.2.1")
      )
    ],
    targets: [
        .target(
            name: "NIOAPNSExample",
            dependencies: ["NIOAPNS"]
        ),
        .target(
            name: "NIOAPNS",
            dependencies: ["NIOH2", "OpenSSL"]
        ),
        .testTarget(
            name: "NIOAPNSTests",
            dependencies: ["NIOAPNS"]
        ),
    ]
)
