#!/bin/bash
# Build for Linux

set -e

echo "🐧 ClashDash Linux Build"

cd "$(dirname "$0")"

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Enable Linux desktop
echo "🔧 Enabling Linux desktop..."
flutter config --enable-linux-desktop

# Build Linux
echo "🔨 Building Linux..."
flutter build linux --release

echo "✅ Linux build complete!"
echo "📍 Output: build/linux/release/bundle/"
echo ""
echo "Run with: ./build/linux/release/bundle/clashdash"
