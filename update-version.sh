#!/bin/bash
set -euo pipefail

### ---- ###

echo "Switch back to master"
git checkout master
git reset --hard origin/master

### ---- ###

echo "Excuting update"
make update

echo "Checking for changes..."
git diff --exit-code && exit 0

echo "Updating repository..."
make tag

git push -q https://${GH_USER}:${GH_TOKEN}@github.com/luzifer-docker/vault.git master --tags
