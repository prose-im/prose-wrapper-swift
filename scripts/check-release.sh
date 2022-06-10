#!/bin/bash
set -e -x

set -o allexport
source scripts/build-config.sh
set +o allexport

release_number=$(latest_core_client_tag)
release_detail=$(gh release view "${release_number}" || echo 'release not found')

if [ "${release_detail}" = "release not found" ]; then
  echo "::set-output name=ok::true"
fi