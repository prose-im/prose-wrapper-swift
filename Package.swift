// swift-tools-version:5.8
import PackageDescription

let package = Package(
  name: "ProseCoreFFI",
  platforms: [.macOS(.v11), .iOS(.v13)],
  products: [
    .library(name: "ProseCoreFFI", targets: ["ProseCoreFFI"]),
  ],
  targets: [
    .target(name: "ProseCoreFFI", dependencies: ["ProseCoreFFIFFI"]),
    .binaryTarget(
      name: "ProseCoreFFIFFI",
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.11.0/ProseCoreFFI.xcframework.zip",
      checksum: "180f6f7e0884b4e8c5a1b6527d0f4f40c44c770b3d5d4e6880efc1bafa7e9406"
    ),
  ]
)

