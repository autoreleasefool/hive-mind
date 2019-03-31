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
		.package(url: "git@github.com:josephroquedev/hive-engine.git", .branch("master"))
	],
	targets: [
		.target(name: "HiveMind", dependencies: ["HiveMindCore"]),
		.target(name: "HiveMindCore", dependencies: ["HiveEngine"]),
		.testTarget(name: "HiveMindCoreTests", dependencies: ["HiveMindCore"])
	]
)
