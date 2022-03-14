#!/bin/bash

set -euo pipefail

source scripts/package-common.sh

setup phmap "$1"

url="https://github.com/greg7mdp/parallel-hashmap/archive/refs/tags/$version.zip"

wget -q "$url" -O "$tmpdir/$package.zip"

mkdir -p "$outdir/patches"
build_patch="$outdir/patches/add-build.patch"

generate_insert_patch BUILD "scripts/data/z3/BUILD" > "$build_patch"

cat > "$outdir/source.json" << EOF
{
  "url": "$url",
  "integrity": "$(digest "$tmpdir/$package.zip")",
  "strip_prefix": "parallel-hashmap-$version",
  "patches": {
    "add-build.patch":   "$(digest "$build_patch")"
  },
  "patch_strip": 0
}
EOF
