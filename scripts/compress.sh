#!/bin/bash
# compress.sh - Compress a folder

if [ -z "$1" ]; then
  echo "Usage: ./compress.sh <folder>"
  exit 1
fi

FOLDER="$1"
ARCHIVE="${FOLDER}_$(date +%Y%m%d_%H%M%S).tar.gz"

tar -czf "$ARCHIVE" "$FOLDER"
echo "Folder $FOLDER compressed to $ARCHIVE"
