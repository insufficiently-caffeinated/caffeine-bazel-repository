#!/bin/bash

set -euxo pipefail

version="$1"

tmpdir=$(mktemp -d -t package-fmt-XXXXXXXXXXX)
trap "rm -rf $tmpdir" EXIT

function digest() (
  echo "sha256-$(cat "$1" | openssl dgst -sha256 -binary | openssl base64 -A)"
)

if [ -z "$version" ]; then
  echo "Invalid version string"
  exit 1
fi

build="$tmpdir/BUILD.bazel"
url="https://github.com/fmtlib/fmt/releases/download/$version/fmt-$version.zip"

wget -q "https://raw.githubusercontent.com/fmtlib/fmt/$version/support/bazel/BUILD.bazel" -O "$build"
wget -q "$url" -O "$tmpdir/fmt.zip"
sed -e 's/^/+/' -i "$build"

outdir="modules/fmt/$version"

rm -rf "$outdir"
mkdir -p "$outdir"

mkdir -p "$outdir/patches"
patch="$outdir/patches/add-build.patch"

echo "--- BUILD	1970-01-01 01:00:00.000000000 +0100" >> "$patch"
echo "+++ BUILD	2020-01-01 01:00:00.000000000 +0100" >> "$patch"
echo "@@ -0,0 +0,$(wc -l < "$build") @@"         >> "$patch"
cat  "$tmpdir/BUILD.bazel"                       >> "$patch"

cat > "$outdir/MODULE.bazel" << EOF
module(
    name = "fmt",
    version = "$version",
)
EOF

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

