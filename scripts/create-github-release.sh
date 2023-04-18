#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

release_number=$(latest_core_client_tag)

rm -rf "${ARCHIVE_BUILD_FOLDER}"
mkdir -p "${ARCHIVE_BUILD_FOLDER}"

# Copy generated Swift file
cp "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Sources/${SWIFT_LIB_NAME}/${CORE_LIB_MODULE_NAME}.swift" "${SOURCES_FOLDER}/${SWIFT_LIB_NAME}"

# Zip framework
(cd "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/${CORE_LIB_MODULE_NAME}FFI"; zip --symlinks -r "${ARCHIVE_BUILD_FOLDER}/${ARCHIVE_NAME}" "${CORE_LIB_MODULE_NAME}FFI.xcframework")

# Generate checksum
checksum=$(swift package --package-path "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}" compute-checksum "${ARCHIVE_BUILD_FOLDER}/${ARCHIVE_NAME}" | tr -d '\n')

cat << EOF > "${BASE_PWD}/Package.swift"
// swift-tools-version:5.8
import PackageDescription

let package = Package(
  name: "${SWIFT_LIB_NAME}",
  platforms: [.macOS(.v11), .iOS(.v13)],
  products: [
    .library(name: "${SWIFT_LIB_NAME}", targets: ["${SWIFT_LIB_NAME}"]),
  ],
  targets: [
    .target(name: "${SWIFT_LIB_NAME}", dependencies: ["${CORE_LIB_MODULE_NAME}FFI"]),
    .binaryTarget(
      name: "${CORE_LIB_MODULE_NAME}FFI",
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