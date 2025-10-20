#!/usr/bin/env bash
#
# Usage: util/release.sh [version]
#
# where version (optional) is the new version of rules_rust.
set -eux

# Normalize working directory to root of repository.
cd "$(dirname "${BASH_SOURCE[0]}")"/..

# Read the old version.
readonly OLD="$(cat version.bzl | grep VERSION | awk '{print $3}' | tr -d '"')"

function new_from_old() {
  local major=$(awk -F. '{print $1}' <<<"$OLD")
  local minor=$(awk -F. '{print $2}' <<<"$OLD")
  echo "$major.$((minor + 1)).0"
}

readonly NEW="${1:-$(new_from_old)}"

sed -i "s/$OLD/$NEW/" \
  version.bzl \
  MODULE.bazel \
  crate_universe/extensions.bzl \
  docs/src/index.md \
  extensions/bindgen/MODULE.bazel \
  extensions/mdbook/MODULE.bazel \
  extensions/prost/MODULE.bazel \
  extensions/protobuf/MODULE.bazel \
  extensions/wasm_bindgen/MODULE.bazel \
  extensions/pyo3/MODULE.bazel \
  extensions/pyo3/version.bzl
