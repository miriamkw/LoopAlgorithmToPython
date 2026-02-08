// swift-tools-version: 5.10
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
        .library(
            name: "LoopAlgorithmToPython",
            type: .dynamic,
            targets: ["LoopAlgorithmToPython"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tidepool-org/LoopAlgorithm.git", branch: "main"),
    ],
    targets: [
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