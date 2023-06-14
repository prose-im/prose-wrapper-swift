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
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.13.0/ProseCoreFFI.xcframework.zip",
      checksum: "cef697da3a3c8809b9eb1279d9dbd1435513eadfcb53c0113f590d86b78b834e"
    ),
  ]
)

