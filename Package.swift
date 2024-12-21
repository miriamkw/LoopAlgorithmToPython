// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoopAlgorithmToPython",
    defaultLocalization: "no",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LoopAlgorithmToPython",
            type: .dynamic,
            targets: ["LoopAlgorithmToPython"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tidepool-org/LoopAlgorithm.git", branch: "d4c674fd12f27bf2848b6d46a941ffb32b8a3eee"), // TEMPORARY! Until main branch is HealthKit - independent
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LoopAlgorithmToPython",
            dependencies: ["LoopAlgorithm"]
        ),
        .testTarget(
            name: "LoopAlgorithmToPythonTests",
            dependencies: ["LoopAlgorithmToPython"],
            resources: [
                .process("TestData")
        ])
    ]
)
