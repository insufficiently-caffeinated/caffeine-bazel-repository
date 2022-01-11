#!/bin/bash

cat "modules/$1/metadata.json" | jq -r '.versions[]'
