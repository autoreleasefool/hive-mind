// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HiveMindEngine",
    products: [
        .library(name: "HiveMindEngine", targets: ["HiveMindEngine"])
    ],
    dependencies: [],
    targets: [
        .target(name: "HiveMindEngine", dependencies: []),
        .testTarget(name: "HiveMindEngineTests", dependencies: ["HiveMindEngine"])
    ]
)
