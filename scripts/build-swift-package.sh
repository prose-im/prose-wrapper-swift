#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

create_swift_package_scaffold() {
  cat << EOF > "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Package.swift"
// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "${SWIFT_LIB_NAME}",
  platforms: [.iOS(.v14)],
  products: [
    .library(name: "${SWIFT_LIB_NAME}", targets: ["${SWIFT_LIB_NAME}"]),
  ],
  targets: [
    .target(
      name: "${SWIFT_LIB_NAME}",
      dependencies: ["${FFI_LIB_NAME}"],
      linkerSettings: [
        .linkedLibrary("xml2"), 
        .linkedLibrary("expat"), 
        .linkedLibrary("resolv"), 
        .unsafeFlags(["-Wl,-no_compact_unwind"])
      ]
    ),
    .binaryTarget(
      name: "${FFI_LIB_NAME}",
      path: "artifacts/${FFI_LIB_NAME}.xcframework"
    ),
  ]
)

EOF

  cat << EOF > "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Sources/${SWIFT_LIB_NAME}/${SWIFT_LIB_NAME}.swift"
@_exported import ${FFI_LIB_NAME}

EOF
}

build_xcframework() {
  local framework_path="${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/artifacts/${FFI_LIB_NAME}.xcframework"

  xcodebuild -create-xcframework \
    -library "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.a" \
    -headers "${FFI_LIB_BUILD_FOLDER}/Headers" \
    -library "${FFI_LIB_BUILD_FOLDER}/iphonesimulator/${FFI_LIB_NAME}.a" \
    -headers "${FFI_LIB_BUILD_FOLDER}/Headers" \
    -library "${FFI_LIB_BUILD_FOLDER}/iphoneos/${FFI_LIB_NAME}.a" \
    -headers "${FFI_LIB_BUILD_FOLDER}/Headers" \
    -output "${framework_path}"

  cp -R "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.swiftmodule/" "${framework_path}/macos-arm64_x86_64/${FFI_LIB_NAME}.swiftmodule"
  cp -R "${FFI_LIB_BUILD_FOLDER}/iphonesimulator/${FFI_LIB_NAME}.swiftmodule/" "${framework_path}/ios-arm64_x86_64-simulator/${FFI_LIB_NAME}.swiftmodule"
  cp -R "${FFI_LIB_BUILD_FOLDER}/iphoneos/${FFI_LIB_NAME}.swiftmodule/" "${framework_path}/ios-arm64/${FFI_LIB_NAME}.swiftmodule"
}

rm -rf "${SPM_BUILD_FOLDER}"

mkdir -p "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Sources/${SWIFT_LIB_NAME}"
mkdir -p "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/artifacts"

create_swift_package_scaffold
build_xcframework