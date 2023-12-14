#!/bin/bash

set -e

echo "Starting nuxi build"

cp public/lists/last-update.json data/last-update.json

npx nuxi generate

echo "Finished building site, output is at dist"
ls -la dist