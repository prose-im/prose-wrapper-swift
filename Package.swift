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
            url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/v0.15.0/ProseSDK-0.15.0.zip",
            checksum: "8e7fc314c534718b9f82cbba4d5a9ded4f8c07819eae60713b8b36af1e9d2003"
        ),
        .target(
            name: "ProseSDK",
            dependencies: [
                .target(name: "ProseCore")
            ]
        ),
    ]
)
