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
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.10.0/ProseCoreFFI.xcframework.zip",
      checksum: "4136d901b902c51dc94832052180d952ccef1aa5631021f2c397c4fc676f71d8"
    ),
  ]
)

