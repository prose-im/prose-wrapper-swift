// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "ProseCoreClientFFI",
  platforms: [.macOS(.v12), .iOS(.v14)],
  products: [
    .library(name: "ProseCoreClientFFI", targets: ["ProseCoreClientFFI"]),
  ],
  targets: [
    .target(
      name: "ProseCoreClientFFI",
      dependencies: ["_ProseCoreClientFFI"],
      linkerSettings: [.linkedLibrary("xml2"), .linkedLibrary("expat"), .linkedLibrary("resolv")]
    ),
    .binaryTarget(
      name: "_ProseCoreClientFFI",
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.1.0/_ProseCoreClientFFI.xcframework.zip",
      checksum: "90a0061ec2a0cdc4ade0094babc65da8fba6400c209c86d48e842c8d551373cd"
    ),
  ]
)

