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
      checksum: "3513e483989b655f2303290699188f4ed11694348ac9ffb6ca0916422b779bc3"
    ),
  ]
)

