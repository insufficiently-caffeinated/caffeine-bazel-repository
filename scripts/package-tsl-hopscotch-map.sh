#!/bin/bash

set -euxo pipefail

source scripts/package-common.sh

setup tsl_hopscotch_map "$1"

url="https://github.com/Tessil/hopscotch-map/archive/refs/tags/v$version.zip"

wget -q "$url" -O "$tmpdir/$package.zip"


mkdir -p "$outdir/patches"
patch="$outdir/patches/add-build.patch"

cat > "$tmpdir/BUILD" << EOF
cc_library(
    name = "hopscotch-map",
    hdrs = glob(["include/**/*.h"]),
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
EOF

generate_insert_patch BUILD "$tmpdir/BUILD" > "$patch"

cat > "$outdir/source.json" << EOF
{
  "url": "$url",
  "integrity": "$(digest "$tmpdir/$package.zip")",
  "strip_prefix": "hopscotch-map-$version",
  "patches": {
    "add-build.patch": "$(digest "$patch")"
  },
  "patch_strip": 0
}
EOF
