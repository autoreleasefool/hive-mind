// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HiveMind",
    products: [
        .executable(name: "HiveMind", targets: ["HiveMind"]),
        .library(name: "HiveMindCore", targets: ["HiveMindCore"])
    ],
    dependencies: [
        .package(path: "../engine")
    ],
    targets: [
        .target(name: "HiveMind", dependencies: ["HiveMindCore"]),
        .target(name: "HiveMindCore", dependencies: ["HiveMindEngine"]),
        .testTarget(name: "HiveMindCoreTests", dependencies: ["HiveMindCore"])
    ]
)
