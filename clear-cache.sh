#!/bin/bash

echo "🧹 Clearing Jekyll cache..."

# Remove Jekyll cache
rm -rf .jekyll-cache/
echo "✅ Cleared .jekyll-cache/"

# Remove built site
rm -rf _site/
echo "✅ Cleared _site/"

# Remove Sass cache
rm -rf .sass-cache/
echo "✅ Cleared .sass-cache/ (if existed)"

# Remove bundle cache (optional)
# rm -rf vendor/bundle/
# echo "✅ Cleared vendor/bundle/"

echo "🚀 Starting Jekyll with fresh cache..."
bundle exec jekyll serve --livereload --incremental --force_polling