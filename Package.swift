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
      url: "https://github.com/prose-im/prose-wrapper-swift/releases/download/0.1.1/_ProseCoreClientFFI.xcframework.zip",
      checksum: "53f1ddde94cde2a416616b5995fdb56262f71404db636fc74c7144b8dcf39173"
    ),
  ]
)

