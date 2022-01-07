#!/bin/bash

set -euxo pipefail

source scripts/package-common.sh

setup magic_enum "$1"

url="https://github.com/Neargye/magic_enum/archive/refs/tags/v$version.zip"

wget -q "$url" -O "$tmpdir/$package.zip"

cat > "$outdir/source.json" << EOF
{
  "url": "$url",
  "integrity": "$(digest "$tmpdir/$package.zip")",
  "strip_prefix": "$package-$version"
}
EOF
