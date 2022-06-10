#!/bin/bash

BASE_PWD="$PWD"

# The name of the core library as defined in the Cargo.toml (lib.name).
CORE_LIB_NAME="prose_core_client_ffi"

# The name of the Swift module of the core library, as defined as module_name in uniffi.toml.
CORE_LIB_MODULE_NAME="ProseCoreClientFFI"

# The name of the SwiftPM target name of the library. This will be wrapped by a more readable name in the final Swift package.
FFI_LIB_NAME="_ProseCoreClientFFI"

# The name of the Swift library as we want to import from Swift code later.
SWIFT_LIB_NAME="ProseCoreClientFFI"

# Path to the build folder.
BUILD_FOLDER="${BASE_PWD}/Build"
# Path to where the checkouts of dependencies should go.
DEPENDENCIES_FOLDER="${BASE_PWD}/dependencies"

# Path to the precompiled OpenSSL binaries.
OPENSSL_PATH="${DEPENDENCIES_FOLDER}/OpenSSL"
# The URL to the OpenSSL repository.
OPENSSL_REPO_URL="https://github.com/krzyzanowskim/OpenSSL"
# The tag to clone from the OpenSSL repository.
OPENSSL_REPO_TAG="1.1.1501"

# The URL to the libstrophe repository.
LIBSTROPHE_REPO_URL="https://github.com/strophe/libstrophe"
# The tag to clone from the libstrophe repository.
LIBSTROPHE_REPO_TAG="0.12.0"
# Path to the libstrophe sources.
LIBSTROPHE_SOURCE_PATH="${DEPENDENCIES_FOLDER}/libstrophe"
# Path the the built libstrophe library.
LIBSTROPHE_BUILD_FOLDER="${BUILD_FOLDER}/libstrophe"

# The URL to the libstrophe repository.
CORE_CLIENT_REPO_URL="https://github.com/prose-im/prose-core-client.git"
# Path to the core client.
CORE_CLIENT_SOURCE_PATH="${DEPENDENCIES_FOLDER}/prose-core-client"

# Path to the UniFFI UDL.
UDL_PATH="${CORE_CLIENT_SOURCE_PATH}/prose_core_client_ffi/src/ProseCoreClientFFI.udl"

# The URL to the uniffi-rs repository.
UNIFFI_REPO_URL="https://github.com/mozilla/uniffi-rs"
# The tag to clone from the uniffi-rs repository.
UNIFFI_REPO_TAG="v0.18.0"
# Path to the UniFFI sources.
UNIFFI_SOURCE_PATH="${DEPENDENCIES_FOLDER}/uniffi-rs"

# Path to the built (from the sources generated by UniFFI) FFI library.
FFI_LIB_BUILD_FOLDER="${BUILD_FOLDER}/ProseCoreClientFFI"

# Path to the generated spm package, which can be used locally. Contains the XCFramework.
SPM_BUILD_FOLDER="${BUILD_FOLDER}/spm"

# Path where the zipped XCFramework should go.
ARCHIVE_BUILD_FOLDER="${BUILD_FOLDER}/Archive"

# The name of the zip file.
ARCHIVE_NAME="${FFI_LIB_NAME}.xcframework.zip"

# The base URL where the zipped XCFramework can be downloaded from.
ARCHIVE_DOWNLOAD_URL="https://github.com/prose-im/prose-wrapper-swift/releases/download/"

# Returns the latest tag of the core client repository.
# Source: https://stackoverflow.com/a/12704727
latest_core_client_tag() {
  git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags "${CORE_CLIENT_REPO_URL}" '*.*.*' \
    | tail --lines=1 \
    | cut -d '/' -f 3
}