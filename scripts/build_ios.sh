#!/bin/bash
# Build for iOS (macOS only)

set -e

echo "🍎 ClashDash iOS Build"

cd "$(dirname "$0")"

# Check if macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ iOS build requires macOS!"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build iOS
echo "🔨 Building iOS (Simulator)..."
flutter build ios --simulator --no-codesign

echo "✅ iOS build complete!"
echo "📍 Output: build/ios/iphonesimulator/Runner.app"

# For real device / App Store
echo ""
echo "📱 For real device deployment:"
echo "   flutter build ios --release"
echo "   Then use Xcode to sign and deploy"
