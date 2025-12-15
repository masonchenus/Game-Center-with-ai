#!/bin/bash
# Exit immediately if a command exits with a non-zero status (failure).
set -e

echo "--- 🚀 Starting Smart Build Script ---"

# --- 1. Find the Project Root ---
# This ensures that even if you run the script from a subdirectory, 
# 'npm' runs in the correct location where package.json lives.
PROJECT_ROOT=$(pwd)
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/package.json" ]; do
    PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

if [ ! -f "$PROJECT_ROOT/package.json" ]; then
    echo "❌ ERROR: Could not find 'package.json'. This must be run inside a project directory."
    exit 1
fi

# Move into the project directory
cd "$PROJECT_ROOT"
echo "Project context established: $(pwd)"

# --- 2. Check for Critical Files ---
REQUIRED_FILES=("package-lock.json" "package.json")
MISSING=false

for FILE in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        echo "⚠️ WARNING: Required file '$FILE' is missing."
        MISSING=true
    fi
done

if [ "$MISSING" = true ]; then
    echo "Please ensure all required files are present before building."
    # We continue, but the subsequent npm install/build may fail.
fi

# --- 3. Ensure Dependencies are Synchronized ---
# 'npm ci' (clean install) is the best practice for builds, as it strictly 
# uses 'package-lock.json' to ensure a reproducible build.
echo "📦 Running npm ci to synchronize dependencies via package-lock.json..."
npm ci

# --- 4. Execute the Main Build Command ---
# This line is the core action, leveraging package.json to find the 'build' script.
echo "🔨 Running the 'npm run build' script defined in package.json..."
npm run build

echo "--- ✅ Build Complete! ---"