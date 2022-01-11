#!/bin/bash

package="$1"

for version in $(./scripts/package-versions.sh "$package"); do
  echo "Updating entry for $package $version"
  ./scripts/package-$package.sh $version
done
