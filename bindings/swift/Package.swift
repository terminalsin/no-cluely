// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ClueLyDetector",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ClueLyDetector",
            targets: ["ClueLyDetector"]),
    ],
    dependencies: [
        // Add any Swift dependencies here if needed
    ],
    targets: [
        .systemLibrary(
            name: "CNoClueLyDriver",
            pkgConfig: "no-cluely-driver",
            providers: [
                .brew(["no-cluely-driver"]),
                .apt(["libno-cluely-driver-dev"])
            ]
        ),
        .target(
            name: "ClueLyDetector",
            dependencies: ["CNoClueLyDriver"],
            path: "Sources/ClueLyDetector"
        ),
        .testTarget(
            name: "ClueLyDetectorTests",
            dependencies: ["ClueLyDetector"],
            path: "Tests/ClueLyDetectorTests"
        ),
    ]
) 