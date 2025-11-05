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
            url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/v0.17.0/ProseSDK-0.17.0.zip",
            checksum: "a801774f51b9f77bba91e3cdd3522b5e929685117e53bbb91f6102ad1c0320fb"
        ),
        .target(
            name: "ProseSDK",
            dependencies: [
                .target(name: "ProseCore")
            ]
        ),
    ]
)
