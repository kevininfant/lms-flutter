#!/bin/bash

echo "🔍 Checking SCORM files in assets/scorms/ directory..."
echo ""

# Check if assets/scorms directory exists
if [ ! -d "assets/scorms" ]; then
    echo "❌ assets/scorms/ directory not found"
    echo "💡 Creating assets/scorms/ directory..."
    mkdir -p assets/scorms
fi

echo "📁 Contents of assets/scorms/:"
ls -la assets/scorms/ 2>/dev/null || echo "❌ Directory is empty or doesn't exist"

echo ""
echo "🔍 Checking each SCORM file:"

# Check each SCORM file
for file in assets/scorms/*.zip; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        size=$(stat -c%s "$file" 2>/dev/null || echo "unknown")
        echo "  📦 $filename ($size bytes)"
        
        # Check if it's a valid ZIP file
        if unzip -t "$file" >/dev/null 2>&1; then
            echo "    ✅ Valid ZIP file"
            
            # List contents
            echo "    📋 Contents:"
            unzip -l "$file" | head -10 | tail -n +4 | while read line; do
                echo "      $line"
            done
            
            # Check for HTML files
            html_count=$(unzip -l "$file" | grep -i "\.html\?$" | wc -l)
            if [ $html_count -gt 0 ]; then
                echo "    ✅ Contains $html_count HTML file(s)"
            else
                echo "    ❌ No HTML files found"
            fi
            
            # Check for manifest
            manifest_count=$(unzip -l "$file" | grep -i "manifest" | wc -l)
            if [ $manifest_count -gt 0 ]; then
                echo "    ✅ Contains manifest file(s)"
            else
                echo "    ❌ No manifest file found"
            fi
            
        else
            echo "    ❌ Invalid or corrupted ZIP file"
        fi
        echo ""
    fi
done

echo "🔧 Troubleshooting tips:"
echo "• If pri.zip is missing, copy it to assets/scorms/"
echo "• If pri.zip is corrupted, try re-downloading it"
echo "• If pri.zip has no HTML files, it's not a valid SCORM package"
echo "• Check console logs when running the app for detailed errors"
