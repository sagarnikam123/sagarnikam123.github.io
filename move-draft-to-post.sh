#!/bin/bash

# Script to move draft to post with proper date formatting
# Usage: ./move-draft-to-post.sh draft-filename.md

if [ $# -eq 0 ]; then
    echo "Usage: $0 <draft-filename.md>"
    echo "Example: $0 my-awesome-post.md"
    exit 1
fi

DRAFT_FILE="$1"
DRAFT_PATH="_drafts/$DRAFT_FILE"

# Check if draft exists
if [ ! -f "$DRAFT_PATH" ]; then
    echo "Error: Draft file '$DRAFT_PATH' not found"
    exit 1
fi

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%Y-%m-%d)

# Create post filename with date prefix
POST_FILE="${CURRENT_DATE}-${DRAFT_FILE}"
POST_PATH="_posts/$POST_FILE"

# Move draft to posts folder
mv "$DRAFT_PATH" "$POST_PATH"

echo "✅ Moved draft to: $POST_PATH"
echo "🚀 Ready to commit and deploy!"
