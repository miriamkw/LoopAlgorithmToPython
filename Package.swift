// swift-tools-version: 5.10
import PackageDescription

// Define platforms conditionally
let packagePlatforms: [SupportedPlatform]
#if os(Windows)
    packagePlatforms = [] // Windows doesn't need platform-specific tags here
#else
    packagePlatforms = [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ]
#endif

let package = Package(
    name: "LoopAlgorithmToPython",
    platforms: packagePlatforms,
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