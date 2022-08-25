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
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.4.3/_ProseCoreClientFFI.xcframework.zip",
      checksum: "ab12a045132a292f7c630908e8936554274e22fa812ebce2baa77e0fb6f96a9a"
    ),
  ]
)

