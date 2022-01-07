#!/bin/bash

set -euxo pipefail

source scripts/package-common.sh

setup fmt "$1"

build="$tmpdir/BUILD.bazel"
url="https://github.com/fmtlib/fmt/releases/download/$version/fmt-$version.zip"

wget -q "https://raw.githubusercontent.com/fmtlib/fmt/$version/support/bazel/BUILD.bazel" -O "$build"
wget -q "$url" -O "$tmpdir/fmt.zip"

mkdir -p "$outdir/patches"
patch="$outdir/patches/add-build.patch"

generate_insert_patch BUILD "$build" > "$patch"

cat > "$outdir/source.json" << EOF
{
  "url": "$url",
  "integrity": "$(digest "$tmpdir/fmt.zip")",
  "strip_prefix": "fmt-$version",
  "patches": {
    "add-build.patch": "$(digest "$patch")"
  },
  "patch_strip": 0
}
EOF

