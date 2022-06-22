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
      linkerSettings: [
        .linkedLibrary("xml2"), 
        .linkedLibrary("expat"), 
        .linkedLibrary("resolv"), 
        .unsafeFlags(["-Wl,-no_compact_unwind"])
      ]
    ),
    .binaryTarget(
      name: "_ProseCoreClientFFI",
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.1.2/_ProseCoreClientFFI.xcframework.zip",
      checksum: "093ae206ae3718960f49be6be0502d6d32a1a55d4aba6a7f952d606efe856955"
    ),
  ]
)

