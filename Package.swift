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
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.7.0/ProseCoreFFI.xcframework.zip",
      checksum: "616db78b0c145cdabb1148feb0df7a2c830a73fa4e9a114f3e58138d1a500587"
    ),
  ]
)

