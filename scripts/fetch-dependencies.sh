#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

mkdir -p "${DEPENDENCIES_FOLDER}"

clone_repo() {
  local tag=$1
  local url=$2
  local path=$3

  if [ ! -d "${path}" ]; then
    git clone --depth 1 --branch "${tag}" "${url}" "${path}"
  fi
}

if [ ! -d "${CORE_CLIENT_SOURCE_PATH}" ]; then
  git clone --depth 1 "${CORE_CLIENT_REPO_URL}" "${CORE_CLIENT_SOURCE_PATH}"
fi

clone_repo "${LIBSTROPHE_REPO_TAG}" "${LIBSTROPHE_REPO_URL}" "${LIBSTROPHE_SOURCE_PATH}"
clone_repo "${OPENSSL_REPO_TAG}" "${OPENSSL_REPO_URL}" "${OPENSSL_PATH}"
clone_repo "${UNIFFI_REPO_TAG}" "${UNIFFI_REPO_URL}" "${UNIFFI_SOURCE_PATH}"