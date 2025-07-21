#!/bin/bash

echo "Building Jekyll site..."
JEKYLL_ENV=production bundle exec jekyll build

echo "Testing site with html-proofer..."
bundle exec htmlproofer _site \
  --disable-external \
  --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

echo "Site test completed!"
