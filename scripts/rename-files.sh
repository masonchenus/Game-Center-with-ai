#!/bin/bash
# rename_files.sh - Add prefix to all files in a folder

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./rename_files.sh <folder> <prefix>"
  exit 1
fi

FOLDER="$1"
PREFIX="$2"

for FILE in "$FOLDER"/*; do
  BASENAME=$(basename "$FILE")
  mv "$FILE" "$FOLDER/${PREFIX}_${BASENAME}"
done

echo "Files in $FOLDER renamed with prefix $PREFIX"
