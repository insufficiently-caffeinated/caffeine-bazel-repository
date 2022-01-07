#!/bin/bash

set -euxo pipefail

source scripts/package-common.sh

setup immer "$1"

url="https://github.com/arximboldi/immer/archive/refs/tags/v$version.zip"

wget -q "$url" -O "$tmpdir/$package.zip"

cat > "$outdir/source.json" << EOF
{
  "url": "$url",
  "integrity": "$(digest "$tmpdir/$package.zip")",
  "strip_prefix": "immer-$version"
}
EOF
