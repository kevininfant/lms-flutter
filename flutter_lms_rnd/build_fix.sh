#!/bin/bash

echo "🔧 Flutter LMS Build Fix Script"
echo "================================"

# Navigate to project directory
cd /home/administrator/Documents/flutter/novac_rnd_project/flutter_lms_rnd

echo "📦 Step 1: Cleaning project..."
flutter clean

echo "📥 Step 2: Getting dependencies..."
flutter pub get

echo "🔍 Step 3: Analyzing code..."
flutter analyze

echo "🏗️ Step 4: Building APK..."
flutter build apk --debug

echo "✅ Build process completed!"
echo ""
echo "If you still encounter issues, try:"
echo "1. flutter doctor -v"
echo "2. flutter upgrade"
echo "3. Check Android SDK and build tools versions"
