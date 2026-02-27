#!/bin/bash

# Script to fix Core Data model reference in Xcode project
# Run this from Terminal in your project directory

echo "🔧 Fixing Core Data model references..."

PROJECT_FILE="Concert App.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: Could not find project.pbxproj"
    echo "Make sure you run this script from your project directory"
    exit 1
fi

# Backup the original file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ Created backup: $PROJECT_FILE.backup"

# Replace old model name with new one
OLD_NAME="Concert App .xcdatamodeld"
NEW_NAME="ConcertApp.xcdatamodeld"

sed -i '' "s/$OLD_NAME/$NEW_NAME/g" "$PROJECT_FILE"

echo "✅ Replaced '$OLD_NAME' with '$NEW_NAME'"
echo ""
echo "🎉 Done! Now:"
echo "1. Open Xcode"
echo "2. Clean Build Folder (⇧⌘K)"
echo "3. Build (⌘B)"
echo ""
echo "If something goes wrong, restore the backup:"
echo "mv '$PROJECT_FILE.backup' '$PROJECT_FILE'"
