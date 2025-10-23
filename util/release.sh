#!/usr/bin/env bash
#
# Usage: util/release.sh [version]
#
# where version (optional) is the new version of rules_rust.
set -xeuo pipefail

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

# Update matching VERSION constants in version.bzl files.
function version_pattern() {
  local version_quoted="\"$1\""
  echo "VERSION = $version_quoted"
}

grep -rl \
  --include='version.bzl' \
  "$(version_pattern $OLD)" \
  | xargs sed -i "s/^$(version_pattern $OLD)$/$(version_pattern $NEW)/g"

# Update matching bazel_dep(name = "rules_rust", version = ...) declarations.
function bazel_dep_pattern() {
  local version_quoted="\"$1\""
  echo "bazel_dep(name = \"rules_rust\", version = $version_quoted)"
}

grep -rl \
  --include='MODULE.bazel' --include='*.bzl' --include='*.md' \
  "$(bazel_dep_pattern $OLD)" \
  | xargs sed -i "s/^$(bazel_dep_pattern $OLD)$/$(bazel_dep_pattern $NEW)/"
