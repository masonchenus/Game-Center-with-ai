#!/bin/bash
echo "📦 Building frontend..."
# Optional: minify JS/CSS
cp -r src/core/* dist/
echo "📦 Building backend..."
npx pkg server.js --output dist/iGame-center.exe
echo "✅ Build complete!"
