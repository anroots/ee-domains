#!/bin/bash

set -e

echo "Starting nuxi build"

cp public/lists/last-update.json data/last-update.json

npx nuxi generate

# CloudFlare Pages can not handle paths beginning with a dot for deployment
# (internal check for file existence fails)
mv .output/public output

echo "Finished building site, output is at output/public"
ls -la output