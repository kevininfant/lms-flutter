#!/bin/bash

# Setup script for SCORM assets
echo "🚀 Setting up SCORM assets..."

# Create asset directories
echo "📁 Creating asset directories..."
mkdir -p assets/h5p
mkdir -p assets/scorms

# Copy H5P files
echo "📦 Copying H5P files..."
if [ -f "my_new_app/assets/h5p/boardgame.h5p" ]; then
    cp my_new_app/assets/h5p/boardgame.h5p assets/h5p/
    echo "✅ Copied boardgame.h5p"
else
    echo "⚠️  boardgame.h5p not found in my_new_app/assets/h5p/"
fi

# Copy SCORM files
echo "📦 Copying SCORM files..."
if [ -f "my_new_app/assets/scorms/PRI.zip" ]; then
    cp my_new_app/assets/scorms/PRI.zip assets/scorms/
    echo "✅ Copied PRI.zip"
else
    echo "⚠️  PRI.zip not found in my_new_app/assets/scorms/"
fi

if [ -f "my_new_app/assets/scorms/scorm.zip" ]; then
    cp my_new_app/assets/scorms/scorm.zip assets/scorms/
    echo "✅ Copied scorm.zip"
else
    echo "⚠️  scorm.zip not found in my_new_app/assets/scorms/"
fi

# Install dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

echo "✨ Asset setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Run 'flutter pub get' if not already done"
echo "2. Test the SCORM screen in your app"
echo "3. Check that all tabs work: SCORM, H5P, Docs, Audio"
