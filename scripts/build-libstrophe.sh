#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

build() {
  local build_dir=$1
  local arch=$2
  local platform=$3
  local sdk_version=$4

  cd "${LIBSTROPHE_SOURCE_PATH}"

  export CFLAGS="-I${OPENSSL_PATH}/${platform}/include -arch ${arch} -m${platform}-version-min=${sdk_version} -isysroot $(xcrun -sdk "${platform}" --show-sdk-path)"
  export CPPFLAGS=$CFLAGS
  export LDFLAGS="-L${OPENSSL_PATH}/${platform}/lib"

  ./configure --host="${arch}-apple-darwin" --disable-shared --enable-static --prefix=""

  make clean
  make DESTDIR="${build_dir}/${platform}-${arch}" install

  cd "${BASE_PWD}"
}

combine_libraries_for_arch() {
  local arch=$1
  local platform=$2
  local build_dir="${3}/${platform}-${arch}"

  xcrun lipo -extract "${arch}" "${OPENSSL_PATH}/${platform}/lib/libssl.a" -o "${build_dir}/libssl.a"
  xcrun lipo -extract "${arch}" "${OPENSSL_PATH}/${platform}/lib/libcrypto.a" -o "${build_dir}/libcrypto.a"

  xcrun libtool -static \
    -o "${build_dir}/libstrophe-combined.a" \
    "${build_dir}/lib/libstrophe.a" \
    "${build_dir}/libssl.a" \
    "${build_dir}/libcrypto.a"
}

build_macos() {
  local tmp_build_dir=$(mktemp -d)
  local sdk_version="11.0"
  
  mkdir -p "${LIBSTROPHE_BUILD_FOLDER}/macosx"/{x86_64,arm64}
  
  if [ ! -f "${LIBSTROPHE_BUILD_FOLDER}/macosx/x86_64/libstrophe.a" ]; then
    build "$tmp_build_dir" "x86_64" "macosx" $sdk_version
    combine_libraries_for_arch "x86_64" "macosx" "${tmp_build_dir}"
    mv "${tmp_build_dir}/macosx-x86_64/libstrophe-combined.a" "${LIBSTROPHE_BUILD_FOLDER}/macosx/x86_64/libstrophe.a"
  fi
  
  if [ ! -f "${LIBSTROPHE_BUILD_FOLDER}/macosx/arm64/libstrophe.a" ]; then
    build "$tmp_build_dir" "arm64" "macosx" $sdk_version
    combine_libraries_for_arch "arm64" "macosx" "${tmp_build_dir}"
    mv "${tmp_build_dir}/macosx-arm64/libstrophe-combined.a" "${LIBSTROPHE_BUILD_FOLDER}/macosx/arm64/libstrophe.a"
  fi
  
  rm -rf "${tmp_build_dir}"
}

build_ios() {
  local tmp_build_dir=$(mktemp -d)
  local sdk_version="14.0"
  
  mkdir -p "${LIBSTROPHE_BUILD_FOLDER}"/{iphoneos,iphonesimulator}/{x86_64,arm64}
  
  if [ ! -f "${LIBSTROPHE_BUILD_FOLDER}/iphonesimulator/x86_64/libstrophe.a" ]; then
    build "$tmp_build_dir" "x86_64" "iphonesimulator" $sdk_version
    combine_libraries_for_arch "x86_64" "iphonesimulator" "${tmp_build_dir}"
    mv "${tmp_build_dir}/iphonesimulator-x86_64/libstrophe-combined.a" "${LIBSTROPHE_BUILD_FOLDER}/iphonesimulator/x86_64/libstrophe.a"
  fi

  if [ ! -f "${LIBSTROPHE_BUILD_FOLDER}/iphonesimulator/arm64/libstrophe.a" ]; then
    build "$tmp_build_dir" "arm64" "iphonesimulator" $sdk_version
    combine_libraries_for_arch "arm64" "iphonesimulator" "${tmp_build_dir}"
    mv "${tmp_build_dir}/iphonesimulator-arm64/libstrophe-combined.a" "${LIBSTROPHE_BUILD_FOLDER}/iphonesimulator/arm64/libstrophe.a"
  fi
  
  if [ ! -f "${LIBSTROPHE_BUILD_FOLDER}/iphoneos/arm64/libstrophe.a" ]; then
    build "$tmp_build_dir" "arm64" "iphoneos" $sdk_version
    combine_libraries_for_arch "arm64" "iphoneos" "${tmp_build_dir}"
    mv "${tmp_build_dir}/iphoneos-arm64/libstrophe-combined.a" "${LIBSTROPHE_BUILD_FOLDER}/iphoneos/arm64/libstrophe.a"
  fi
  
  rm -rf "${tmp_build_dir}"
}

#rm -rf "${LIBSTROPHE_BUILD_FOLDER}"

if [ ! -f "${LIBSTROPHE_SOURCE_PATH}/configure" ]; then
  (cd "${LIBSTROPHE_SOURCE_PATH}"; ./bootstrap.sh)
fi

build_macos
build_ios