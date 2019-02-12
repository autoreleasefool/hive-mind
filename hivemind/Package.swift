// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HiveMind",
    products: [.library(name: "HiveMind", targets: ["HiveMind"])
    ],
    dependencies: [
        .package(path: "../engine")
    ],
    targets: [
        .target(name: "HiveMind", dependencies: []),
        .testTarget(name: "HiveMindTests", dependencies: ["HiveMind"])
    ]
)
