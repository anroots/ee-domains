#!/bin/sh

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_files() {
  git add lists
  git commit --message "Update lists (Travis build: $TRAVIS_BUILD_NUMBER)"
}

push_files() {
  git remote add origin-master https://${GH_TOKEN}@github.com/anroots/ee-domains.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-master master
  git remote rm origin-master
}

setup_git
commit_files
push_files