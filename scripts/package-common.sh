#!/bin/bash

function digest() (
  echo "sha256-$(cat "$1" | openssl dgst -sha256 -binary | openssl base64 -A)"
)

function setup() {
  tmpdir=$(mktemp -d -t package-fmt-XXXXXXXXXXX)
  trap "rm -rf $tmpdir" EXIT

  package="$1"
  version="$2"

  if [ -z "$version" ]; then
    echo "Invalid version string"
    exit 1
  fi

  outdir="modules/$package/$version"
  rm -rf "$outdir"
  mkdir -p "$outdir"

  cat > "$outdir/MODULE.bazel" << EOF
module(
    name = "$package",
    version = "$version",
)
EOF
}
