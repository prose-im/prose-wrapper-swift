#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

xcodebuild_args=(-create-xcframework -output "${CORE_LIB_FRAMEWORK_PATH}")

generate_bindings() {
  local build_dir=$1
  local pwd="$PWD"
  cd "${CORE_CLIENT_SOURCE_PATH}"

  cargo run --bin uniffi-bindgen generate \
    --lib-file "${CORE_CLIENT_SOURCE_PATH}/target/aarch64-apple-darwin/release/lib${CORE_LIB_NAME}.a" \
    "${UDL_PATH}" \
    -o "${build_dir}" \
    --language swift
  
  cd "${pwd}"
}

build_rust_lib() {
  local target=$1
  local arch=$2
  local platform=$3

  local pwd="$PWD"
  cd "${CORE_CLIENT_SOURCE_PATH}"

  export RUSTFLAGS="-L ${LIBSTROPHE_BUILD_FOLDER}/${platform}/${arch} -lxml2 -lexpat -lresolv"
  cargo build -p ${CORE_LIB_NAME} --release --target="${target}"

  cd "${pwd}"
}

combine_libraries_for_arch() {
  local rust_target=$1
  local arch=$2
  local platform=$3
  local build_dir="${4}/${platform}-${arch}"
  
  mkdir -p "${build_dir}"
  
  xcrun lipo -info "${CORE_CLIENT_SOURCE_PATH}/target/${rust_target}/release/lib${CORE_LIB_NAME}.a"
  xcrun lipo -info "${LIBSTROPHE_BUILD_FOLDER}/${platform}/${arch}/libstrophe.a"

  xcrun libtool -static -no_warning_for_no_symbols \
    -o "${build_dir}/libs-combined.a" \
    "${CORE_CLIENT_SOURCE_PATH}/target/${rust_target}/release/lib${CORE_LIB_NAME}.a" \
    "${LIBSTROPHE_BUILD_FOLDER}/${platform}/${arch}/libstrophe.a"
}

build_macos() {
  local build_dir=$1
  local header_dir=$2
  
  mkdir -p "${build_dir}/macosx"

  build_rust_lib "x86_64-apple-darwin" "x86_64" "macosx"
  build_rust_lib "aarch64-apple-darwin" "arm64" "macosx"

  combine_libraries_for_arch "x86_64-apple-darwin" "x86_64" "macosx" "${build_dir}"
  combine_libraries_for_arch "aarch64-apple-darwin" "arm64" "macosx" "${build_dir}"

  xcrun lipo -create \
    "${build_dir}/macosx-x86_64/libs-combined.a" \
    "${build_dir}/macosx-arm64/libs-combined.a" \
    -o "${build_dir}/macosx/${FFI_LIB_NAME}.a"

  xcodebuild_args+=(
    -library "${build_dir}/macosx/${FFI_LIB_NAME}.a"
    -headers "${header_dir}"
  )
}

build_ios() {
  local build_dir=$1
  local header_dir=$2

  build_rust_lib "x86_64-apple-ios" "x86_64" "iphonesimulator"
  build_rust_lib "aarch64-apple-ios-sim" "arm64" "iphonesimulator"
  build_rust_lib "aarch64-apple-ios" "arm64" "iphoneos"

  combine_libraries_for_arch "x86_64-apple-ios" "x86_64" "iphonesimulator" "${build_dir}"
  combine_libraries_for_arch "aarch64-apple-ios-sim" "arm64" "iphonesimulator" "${build_dir}"
  combine_libraries_for_arch "aarch64-apple-ios" "arm64" "iphoneos" "${build_dir}"
  
  mkdir -p "${build_dir}/iphonesimulator"

  xcrun lipo -create \
    "${build_dir}/iphonesimulator-x86_64/libs-combined.a" \
    "${build_dir}/iphonesimulator-arm64/libs-combined.a" \
    -o "${build_dir}/iphonesimulator/${FFI_LIB_NAME}.a"

  xcodebuild_args+=(
    -library "${build_dir}/iphoneos-arm64/libs-combined.a"
    -headers "${header_dir}"
  )
  xcodebuild_args+=(
    -library "${build_dir}/iphonesimulator/${FFI_LIB_NAME}.a"
    -headers "${header_dir}"
  )
}

collect_headers() {
  local interface_dir=$1
  local headers_dir=$2
  
  mkdir -p "${headers_dir}"
  
  cp "${interface_dir}/${CORE_LIB_MODULE_NAME}FFI.h" "${headers_dir}"
  
  cat << EOF > "${headers_dir}/module.modulemap"
module ${CORE_LIB_MODULE_NAME}FFI {
  header "${CORE_LIB_MODULE_NAME}FFI.h"
  link "sqlite3"
  link "xml2"
  link "expat"
  link "resolv"
  export *
}

EOF
}

generate_swift_package() {
  local interface_dir=$1
  
  mkdir -p "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Sources/${SWIFT_LIB_NAME}"
  cp "${interface_tmp_dir}/${CORE_LIB_MODULE_NAME}.swift" "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Sources/${SWIFT_LIB_NAME}"
  cp "${SOURCES_FOLDER}/${SWIFT_LIB_NAME}/Emoji.swift" "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Sources/${SWIFT_LIB_NAME}"
  cp "${SOURCES_FOLDER}/${SWIFT_LIB_NAME}/MessageId.swift" "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Sources/${SWIFT_LIB_NAME}"
  
  xcrun xcodebuild "${xcodebuild_args[@]}"
  
  cat << EOF > "${SPM_BUILD_FOLDER}/${SWIFT_LIB_NAME}/Package.swift"
// swift-tools-version:5.8
import PackageDescription

let package = Package(
  name: "${SWIFT_LIB_NAME}",
  platforms: [.iOS(.v13), .macOS(.v11)],
  products: [
    .library(name: "${SWIFT_LIB_NAME}", targets: ["${SWIFT_LIB_NAME}"]),
  ],
  targets: [
    .target(name: "${SWIFT_LIB_NAME}", dependencies: ["${CORE_LIB_MODULE_NAME}FFI"]),
    .binaryTarget(
      name: "${CORE_LIB_MODULE_NAME}FFI",
      path: "${CORE_LIB_MODULE_NAME}FFI/${CORE_LIB_MODULE_NAME}FFI.xcframework"
    ),
  ]
)

EOF
}

tmp_dir=$(mktemp -d)
built_libs_tmp_dir="${tmp_dir}/Libs"
interface_tmp_dir="${tmp_dir}/Interface"
headers_tmp_dir="${tmp_dir}/Headers"

rm -rf "${SPM_BUILD_FOLDER}"

build_macos "${built_libs_tmp_dir}/macOS" "${headers_tmp_dir}"
build_ios "${built_libs_tmp_dir}/iOS" "${headers_tmp_dir}"

generate_bindings "${interface_tmp_dir}"
collect_headers "${interface_tmp_dir}" "${headers_tmp_dir}"

generate_swift_package "${interface_tmp_dir}"

rm -rf "${tmp_dir}"