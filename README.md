# prose-wrapper-swift

[![Build](https://github.com/prose-im/prose-wrapper-swift/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/prose-im/prose-wrapper-swift/actions/workflows/build.yml) [![GitHub Release](https://img.shields.io/github/v/release/prose-im/prose-wrapper-swift.svg)](https://github.com/prose-im/prose-wrapper-swift/releases)

**Prose wrappers for Swift.**

Copyright 2022, Prose Foundation - Released under the [Mozilla Public License 2.0](./LICENSE.md).

## Purpose

Builds and hosts [prose-core-client](https://github.com/prose-im/prose-core-client) as a Swift Package Manager package.

## How To Build?

To build locally install the following dependencies:

- Xcode
- Rust toolchain with targets `x86_64-apple-darwin`, `aarch64-apple-darwin`, `x86_64-apple-ios`, `aarch64-apple-ios-sim`, `aarch64-apple-ios`

Then build by running `make swift-package`.
