// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "HiveMind",
	products: [
		.executable(name: "HiveMind", targets: ["HiveMind"]),
		.library(name: "HiveMindCore", targets: ["HiveMindCore"])
	],
	dependencies: [
		.package(url: "https://github.com/josephroquedev/hive-engine.git", from: "1.2.0"),
		.package(url: "https://github.com/vapor/websocket.git", from: "1.1.2")
	],
	targets: [
		.target(name: "HiveMind", dependencies: ["HiveMindCore"]),
		.target(name: "HiveMindCore", dependencies: ["HiveEngine", "WebSocket"]),
		.testTarget(name: "HiveMindCoreTests", dependencies: ["HiveMindCore"])
	]
)
