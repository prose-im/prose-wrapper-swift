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
            url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/v0.14.0/ProseSDK-0.14.0.zip",
            checksum: "dccf6b10bb579d43666f96474e8a795d636132c3d3ca14052c9ca60fd9456827"
        ),
        .target(
            name: "ProseSDK",
            dependencies: [
                .target(name: "ProseCore")
            ]
        ),
    ]
)
