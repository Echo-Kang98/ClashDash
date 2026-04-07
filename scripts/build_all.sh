#!/bin/bash

# ===========================================
# ClashDash Build Script
# ===========================================

set -e

echo "🚀 Starting ClashDash Build..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${YELLOW}Project: $PROJECT_DIR${NC}"

# -----------------------------------------
# Step 1: Get dependencies
# -----------------------------------------
echo -e "\n${GREEN}[1/4] Installing dependencies...${NC}"
flutter pub get

# -----------------------------------------
# Step 2: Enable desktop support
# -----------------------------------------
echo -e "\n${GREEN}[2/4] Enabling desktop support...${NC}"
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop

# -----------------------------------------
# Step 3: Build for each platform
# -----------------------------------------

# Android APK
echo -e "\n${GREEN}[3/4] Building Android APK...${NC}"
flutter build apk --release --no-tree-shake-icons
echo -e "${GREEN}✓ Android APK: build/app/outputs/flutter-apk/app-release.apk${NC}"

# Android App Bundle (for Google Play)
echo -e "\n${GREEN}[4/4] Building Android App Bundle...${NC}"
flutter build appbundle --release --no-tree-shake-icons
echo -e "${GREEN}✓ Android AAB: build/app/outputs/bundle/release/app-release.aab${NC}"

# iOS (requires macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "\n${GREEN}Building iOS...${NC}"
    flutter build ios --release --no-codesign
    echo -e "${GREEN}✓ iOS build: build/ios/iphoneos/Runner.ipa${NC}"
else
    echo -e "\n${YELLOW}⚠ Skipping iOS (requires macOS)${NC}"
fi

# macOS (requires macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "\n${GREEN}Building macOS...${NC}"
    flutter build macos --release
    echo -e "${GREEN}✓ macOS build: build/macos/Build/Products/Release/ClashDash.app${NC}"
else
    echo -e "\n${YELLOW}⚠ Skipping macOS (requires macOS)${NC}"
fi

# Linux
echo -e "\n${GREEN}Building Linux...${NC}"
flutter build linux --release
echo -e "${GREEN}✓ Linux build: build/linux/release/bundle/clashdash${NC}"

# Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo -e "\n${GREEN}Building Windows...${NC}"
    flutter build windows --release
    echo -e "${GREEN}✓ Windows build: build/windows/runner/Release/ClashDash.exe${NC}"
else
    echo -e "\n${YELLOW}⚠ Skipping Windows (run on Windows machine)${NC}"
fi

# -----------------------------------------
# Summary
# -----------------------------------------
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  🎉 Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n📦 Output files:"
echo "   📱 Android APK:     build/app/outputs/flutter-apk/app-release.apk"
echo "   📦 Android AAB:     build/app/outputs/bundle/release/app-release.aab"
[[ "$OSTYPE" == "darwin"* ]] && echo "   🍎 iOS:             build/ios/iphoneos/Runner.ipa"
[[ "$OSTYPE" == "darwin"* ]] && echo "   🖥️  macOS:           build/macos/Build/Products/Release/ClashDash.app"
echo "   🐧 Linux:           build/linux/release/bundle/clashdash"
[[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]] && echo "   🪟 Windows:         build/windows/runner/Release/ClashDash.exe"
echo -e "\n📂 All builds in: $PROJECT_DIR/build/"
