#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

SPM_PACKAGE_PATH="${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}"

release_number=$(latest_core_client_tag)

rm -rf "${ARCHIVE_BUILD_FOLDER}"
mkdir -p "${ARCHIVE_BUILD_FOLDER}" 

# Zip framework
(cd ${SPM_PACKAGE_PATH}/artifacts; zip --symlinks -r "${ARCHIVE_BUILD_FOLDER}/${ARCHIVE_NAME}" "${FFI_LIB_NAME}.xcframework")

# Generate checksum
checksum=$(swift package --package-path "${SPM_PACKAGE_PATH}" compute-checksum "${ARCHIVE_BUILD_FOLDER}/${ARCHIVE_NAME}" | tr -d '\n')

cat << EOF > "${BASE_PWD}/Package.swift"
// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "${SWIFT_LIB_NAME}",
  platforms: [.macOS(.v12), .iOS(.v14)],
  products: [
    .library(name: "${SWIFT_LIB_NAME}", targets: ["${SWIFT_LIB_NAME}"]),
  ],
  targets: [
    .target(
      name: "${SWIFT_LIB_NAME}",
      dependencies: ["${FFI_LIB_NAME}"],
      linkerSettings: [.linkedLibrary("xml2"), .linkedLibrary("expat"), .linkedLibrary("resolv")]
    ),
    .binaryTarget(
      name: "${FFI_LIB_NAME}",
      url: "${ARCHIVE_DOWNLOAD_URL}${release_number}/${ARCHIVE_NAME}",
      checksum: "${checksum}"
    ),
  ]
)

EOF

git add .
git commit -m "Created automatic release of prose-core-client ${release_number}."
git tag "${release_number}"
git push && git push --tags

gh release create "${release_number}" "${ARCHIVE_BUILD_FOLDER}/${ARCHIVE_NAME}" --notes "Automatic release of prose-core-client ${release_number}."