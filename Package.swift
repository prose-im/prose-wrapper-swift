// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift Package: ProseSDK
import PackageDescription

let package = Package(
    name: "ProseSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ProseSDK",
            targets: ["ProseSDK"]
        )
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(
            name: "ProseCore",
            url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/v0.18.0/ProseSDK-0.18.0.zip",
            checksum: "b70a05e2f9ef51097ad904913a83d09b1fa493d1f0ba4d7cae92f3f245d32262"
        ),
        .target(
            name: "ProseSDK",
            dependencies: [
                .target(name: "ProseCore")
            ]
        ),
    ]
)
