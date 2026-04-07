#!/bin/bash
# Build for Android (APK and AAB)

set -e

echo "📱 ClashDash Android Build"

cd "$(dirname "$0")"

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build APK
echo "🔨 Building Android APK..."
flutter build apk --release --no-tree-shake-icons

echo ""
echo "✅ APK build complete!"
echo "📍 Output: build/app/outputs/flutter-apk/app-release.apk"

# Build AAB (for Google Play)
echo ""
echo "🔨 Building Android App Bundle..."
flutter build appbundle --release --no-tree-shake-icons

echo ""
echo "✅ AAB build complete!"
echo "📍 Output: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "💡 Install APK on device:"
echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
