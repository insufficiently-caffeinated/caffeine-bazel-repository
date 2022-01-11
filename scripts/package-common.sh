#!/bin/bash

function digest() (
  echo "sha256-$(cat "$1" | openssl dgst -sha256 -binary | openssl base64 -A)"
)

function update_metadata() (
  package="$1"
  version="$2"
  metadata="modules/$package/metadata.json"

  if [ ! -f "$metadata" ]; then
    cat > "$metadata" << EOF
{
  "homepage": "TODO",
  "maintainers": [],
  "versions": []
}
EOF
  fi

  cat "$metadata" | jq '.versions += ["'"$version"'"]' | sponge "$metadata"
  cat "$metadata" | jq '.versions |= unique'           | sponge "$metadata"
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

  update_metadata "$package" "$version"
}

function generate_insert_patch() (
  path="$1"
  file="$2"

  echo "--- $path	1970-01-01 01:00:00.000000000 +0100"
  echo "+++ $path	2020-01-01 01:00:00.000000000 +0100"
  echo "@@ -0,0 +0,$(wc -l < "$file") @@"
  sed -e "s/^/+/" "$file"
)
