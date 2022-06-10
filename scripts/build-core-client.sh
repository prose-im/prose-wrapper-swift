#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

generate_bindings() {
  local build_dir=$1
  local pwd="$PWD"
  cd "${UNIFFI_SOURCE_PATH}"

  cargo run generate "${UDL_PATH}" -o "${build_dir}" --language swift
  sed -i '' \
    "s/import ${CORE_LIB_MODULE_NAME}FFI/@_implementationOnly import ${CORE_LIB_MODULE_NAME}FFI/g" \
    "${build_dir}/${CORE_LIB_MODULE_NAME}.swift"
  
  cd "${pwd}"
}

build_core_lib() {
  local target=$1
  local arch=$2
  local platform=$3

  local pwd="$PWD"
  cd "${CORE_CLIENT_SOURCE_PATH}"

  export RUSTFLAGS="-L ${LIBSTROPHE_BUILD_FOLDER}/${platform}/${arch} -lxml2 -lexpat"
  cargo build -p ${CORE_LIB_NAME} --release --target="${target}"

  cd "${pwd}"
}

build_ffi_lib() {
  local rust_target=$1
  local swift_target=$2
  local arch=$3
  local platform=$4
  local interface_dir=$5
  local build_dir="${6}/${platform}-${arch}"

  local pwd="$PWD"
  mkdir -p "${build_dir}"
  cd "${build_dir}"

  # swiftc uses a target triple like clang does.
  # General format is <arch><sub>-<vendor>-<sys>-<abi>
  # For example: x86_64-apple-macosx12.0
  # More info:
  # - https://clang.llvm.org/docs/CrossCompilation.html#target-triple
  # - https://github.com/apple/swift/blob/main/utils/swift_build_support/swift_build_support/targets.py

  swiftc \
    -module-name "${FFI_LIB_NAME}" \
    -emit-library -o "${FFI_LIB_NAME}.a" \
    -emit-module -emit-module-path . \
    -parse-as-library \
    -L "${CORE_CLIENT_SOURCE_PATH}/target/${rust_target}/release" \
    -l"${CORE_LIB_NAME}" \
    -Xcc -fmodule-map-file="${interface_dir}/${CORE_LIB_MODULE_NAME}FFI.modulemap" \
    -static \
    -target "${swift_target}" \
    -enable-library-evolution \
    -emit-module-interface \
    -sdk "$(xcrun --show-sdk-path -sdk "${platform}")" \
    "${interface_dir}/${CORE_LIB_MODULE_NAME}.swift"
  
  cd "${pwd}"
}

combine_libraries_for_arch() {
  local rust_target=$1
  local arch=$2
  local platform=$3
  local build_dir="${4}/${platform}-${arch}"

  xcrun libtool -static \
    -o "${build_dir}/libs-combined.a" \
    "${build_dir}/${FFI_LIB_NAME}.a" \
    "${CORE_CLIENT_SOURCE_PATH}/target/${rust_target}/release/lib${CORE_LIB_NAME}.a" \
    "${LIBSTROPHE_BUILD_FOLDER}/${platform}/${arch}/libstrophe.a"
}

build_macos() {
  local interface_dir=$1
  local tmp_build_dir=$(mktemp -d)

  build_core_lib "x86_64-apple-darwin" "x86_64" "macosx"
  build_core_lib "aarch64-apple-darwin" "arm64" "macosx"

  build_ffi_lib "x86_64-apple-darwin" "x86_64-apple-macos11.0" "x86_64" "macosx" "${interface_dir}" "${tmp_build_dir}"
  build_ffi_lib "aarch64-apple-darwin" "arm64-apple-macos11.0" "arm64" "macosx" "${interface_dir}" "${tmp_build_dir}"

  combine_libraries_for_arch "x86_64-apple-darwin" "x86_64" "macosx" "${tmp_build_dir}"
  combine_libraries_for_arch "aarch64-apple-darwin" "arm64" "macosx" "${tmp_build_dir}"

  mkdir -p "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.swiftmodule"

  cp "${tmp_build_dir}/macosx-x86_64/${FFI_LIB_NAME}.swiftmodule" "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.swiftmodule/x86_64-apple-macos.swiftmodule"
  cp "${tmp_build_dir}/macosx-arm64/${FFI_LIB_NAME}.swiftmodule" "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.swiftmodule/arm64-apple-macos.swiftmodule"
  
  cp "${tmp_build_dir}/macosx-x86_64/${FFI_LIB_NAME}.swiftinterface" "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.swiftmodule/x86_64-apple-macos.swiftinterface"
  cp "${tmp_build_dir}/macosx-arm64/${FFI_LIB_NAME}.swiftinterface" "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.swiftmodule/arm64-apple-macos.swiftinterface"

  xcrun lipo -create \
    "${tmp_build_dir}/macosx-x86_64/libs-combined.a" \
    "${tmp_build_dir}/macosx-arm64/libs-combined.a" \
    -o "${FFI_LIB_BUILD_FOLDER}/macosx/${FFI_LIB_NAME}.a"
  
  rm -rf "${tmp_build_dir}"
}

build_ios() {
  local interface_dir=$1
  local tmp_build_dir=$(mktemp -d)

  build_core_lib "x86_64-apple-ios" "x86_64" "iphonesimulator"
  build_core_lib "aarch64-apple-ios-sim" "arm64" "iphonesimulator"
  build_core_lib "aarch64-apple-ios" "arm64" "iphoneos"

  build_ffi_lib "x86_64-apple-ios" "x86_64-apple-ios14.0" "x86_64" "iphonesimulator" "${interface_dir}" "${tmp_build_dir}"
  build_ffi_lib "aarch64-apple-ios-sim" "arm64-apple-ios14.0-simulator" "arm64" "iphonesimulator" "${interface_dir}" "${tmp_build_dir}"
  build_ffi_lib "aarch64-apple-ios" "arm64-apple-ios14.0" "arm64" "iphoneos" "${interface_dir}" "${tmp_build_dir}"

  combine_libraries_for_arch "x86_64-apple-ios" "x86_64" "iphonesimulator" "${tmp_build_dir}"
  combine_libraries_for_arch "aarch64-apple-ios-sim" "arm64" "iphonesimulator" "${tmp_build_dir}"
  combine_libraries_for_arch "aarch64-apple-ios" "arm64" "iphoneos" "${tmp_build_dir}"

  mkdir -p "${FFI_LIB_BUILD_FOLDER}"/{iphoneos,iphonesimulator}/"${FFI_LIB_NAME}.swiftmodule"

  cp "${tmp_build_dir}/iphonesimulator-x86_64/${FFI_LIB_NAME}.swiftmodule" "${FFI_LIB_BUILD_FOLDER}/iphonesimulator/${FFI_LIB_NAME}.swiftmodule/x86_64-apple-ios-simulator.swiftmodule"
  cp "${tmp_build_dir}/iphonesimulator-arm64/${FFI_LIB_NAME}.swiftmodule" "${FFI_LIB_BUILD_FOLDER}/iphonesimulator/${FFI_LIB_NAME}.swiftmodule/arm64-apple-ios-simulator.swiftmodule"
  cp "${tmp_build_dir}/iphoneos-arm64/${FFI_LIB_NAME}.swiftmodule" "${FFI_LIB_BUILD_FOLDER}/iphoneos/${FFI_LIB_NAME}.swiftmodule/arm64-apple-ios.swiftmodule"
  
  cp "${tmp_build_dir}/iphonesimulator-x86_64/${FFI_LIB_NAME}.swiftinterface" "${FFI_LIB_BUILD_FOLDER}/iphonesimulator/${FFI_LIB_NAME}.swiftmodule/x86_64-apple-ios-simulator.swiftinterface"
  cp "${tmp_build_dir}/iphonesimulator-arm64/${FFI_LIB_NAME}.swiftinterface" "${FFI_LIB_BUILD_FOLDER}/iphonesimulator/${FFI_LIB_NAME}.swiftmodule/arm64-apple-ios-simulator.swiftinterface"
  cp "${tmp_build_dir}/iphoneos-arm64/${FFI_LIB_NAME}.swiftinterface" "${FFI_LIB_BUILD_FOLDER}/iphoneos/${FFI_LIB_NAME}.swiftmodule/arm64-apple-ios.swiftinterface"

  xcrun lipo -create \
    "${tmp_build_dir}/iphonesimulator-x86_64/libs-combined.a" \
    "${tmp_build_dir}/iphonesimulator-arm64/libs-combined.a" \
    -o "${FFI_LIB_BUILD_FOLDER}/iphonesimulator/${FFI_LIB_NAME}.a"

  mv "${tmp_build_dir}/iphoneos-arm64/libs-combined.a" "${FFI_LIB_BUILD_FOLDER}/iphoneos/${FFI_LIB_NAME}.a"

  rm -rf "${tmp_build_dir}"
}

#rm -rf "${FFI_LIB_BUILD_FOLDER}"
#(cd "${CORE_CLIENT_SOURCE_PATH}"; cargo clean)

interface_tmp_dir=$(mktemp -d)
generate_bindings "${interface_tmp_dir}"

build_macos "${interface_tmp_dir}"
build_ios "${interface_tmp_dir}"

mkdir -p "${FFI_LIB_BUILD_FOLDER}/Headers"
cp "${interface_tmp_dir}/${CORE_LIB_MODULE_NAME}FFI.h" "${FFI_LIB_BUILD_FOLDER}/Headers"
cp "${interface_tmp_dir}/${CORE_LIB_MODULE_NAME}FFI.modulemap" "${FFI_LIB_BUILD_FOLDER}/Headers"

rm -rf "${interface_tmp_dir}"