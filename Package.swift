// swift-tools-version: 6.0
import PackageDescription

let packagePlatforms: [SupportedPlatform]
let packageLocalization: LanguageTag?

#if os(Windows)
    packagePlatforms = [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ]
    packageLocalization = nil
#else
    packagePlatforms = [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ]
    packageLocalization = "no"
#endif

let package = Package(
    name: "LoopAlgorithmToPython",
    defaultLocalization: packageLocalization,
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