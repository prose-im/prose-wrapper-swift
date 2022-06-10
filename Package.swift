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
      url: "https://github.com/nesium/prose-core-spm/releases/download//a3b0366/_ProseCoreClientFFI.xcframework.zip",
      checksum: "1003b2d5ef451a0a06c928439e31f8c7fdae71b50fc3b6f695cc40e0dd4f8d54"
    ),
  ]
)

