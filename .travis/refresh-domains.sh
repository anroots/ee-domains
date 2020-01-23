#!/usr/bin/env bash

set -e

if [ $TRAVIS_EVENT_TYPE = "cron" ]; then
  echo "Build triggered by CRON, updating domain DB"
  ./cron/compile-domain-list.sh

  echo "Setting up Git..."
  # Setup Git and SSH push access to upstream repo
  chmod 600 .travis/ssh-key
  eval $(ssh-agent -s)
  ssh-add .travis/ssh-key > /dev/null
  git config user.email "travis@sqroot.eu"
  git config user.name "Travis CI"
  git remote add gh git@github.com:anroots/ee-domains.git
  git checkout -f master
  git pull gh master
  
  echo "Adding changes to Git"
  # Commit changes
  added=$(wc -l src/lists/added.txt | cut -f 1 -d ' ')
  deleted=$(wc -l src/lists/deleted.txt | cut -f 1 -d ' ')
  git add src/lists
  git commit -m "CI CRON: Update domain lists for $(date  --rfc-3339=date) (${added} added; ${deleted} deleted)"
  echo "Pushing changes..."
  git push gh master

  shred -fu .travis/ssh-key
  echo "Done updating domain DB"
else
  echo "Build was triggered by a Git push, not going to refresh domain lists"
  exit 0
fi
