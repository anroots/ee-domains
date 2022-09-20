#!/usr/bin/env bash

set -e

echo "Refreshing domain list"
./cron/compile-domain-list.sh

echo "Adding changes to Git"
git status
# Commit changes
added=$(wc -l src/lists/added.txt | cut -f 1 -d ' ')
deleted=$(wc -l src/lists/deleted.txt | cut -f 1 -d ' ')
git add src/lists
git commit -m "CI CRON: Update domain lists for $(date  --rfc-3339=date) (${added} added; ${deleted} deleted)"
echo "Pushing changes..."
git push gh master

echo "Done updating domain DB"
