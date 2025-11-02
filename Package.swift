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
            url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/v0.16.0/ProseSDK-0.16.0.zip",
            checksum: "24532a6c70543625e646311b9a4d0212bfdf39f42f3aee1260efeb3229bee9da"
        ),
        .target(
            name: "ProseSDK",
            dependencies: [
                .target(name: "ProseCore")
            ]
        ),
    ]
)
