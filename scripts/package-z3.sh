#!/bin/bash

set -euo pipefail

source scripts/package-common.sh

setup z3 "$1"

url="https://github.com/Z3Prover/z3/archive/refs/tags/z3-$version.zip"

wget -q "$url" -O "$tmpdir/$package.zip"


mkdir -p "$outdir/patches"
build_patch="$outdir/patches/add-build.patch"
utils_patch="$outdir/patches/add-utils.patch"
versn_patch="$outdir/patches/add-version.patch"

echo "VERSION=\"$version.0\"" > "$tmpdir/version.bzl"

generate_insert_patch BUILD     "scripts/data/z3/BUILD"     > "$build_patch"
generate_insert_patch utils.bzl "scripts/data/z3/utils.bzl" > "$utils_patch"
generate_insert_patch version.bzl "$tmpdir/version.bzl"     > "$versn_patch"

cat > "$outdir/source.json" << EOF
{
  "url": "$url",
  "integrity": "$(digest "$tmpdir/$package.zip")",
  "strip_prefix": "z3-z3-$version",
  "patches": {
    "add-build.patch":   "$(digest "$build_patch")",
    "add-utils.patch":   "$(digest "$utils_patch")",
    "add-version.patch": "$(digest "$versn_patch")"
  },
  "patch_strip": 0
}
EOF
