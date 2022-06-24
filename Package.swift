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
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.1.4/_ProseCoreClientFFI.xcframework.zip",
      checksum: "9e079cb9a7b11f6bcabf7dac3fb7fee71217a2aa5caa0a731e6f185bd3788b1f"
    ),
  ]
)

