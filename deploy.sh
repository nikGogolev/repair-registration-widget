#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run build

# navigate into the build output directory
cd dist

# git comands 
git init
git add -A
git commit -m 'deploy'
git checkout -b main

# deploy to github
git push -f git@github.com:nikGogolev/repair-registration-widget.git main:gh-pages
