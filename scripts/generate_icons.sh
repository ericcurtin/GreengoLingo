#!/bin/bash
# Generate app icons from the logo in README.md
# Requires: curl, ImageMagick (convert/magick command)

set -e

# Get script directory (works on both Unix and Windows Git Bash)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Logo URL from README.md
LOGO_URL="https://github.com/user-attachments/assets/55452d70-b75e-4a95-aca4-6ad94b024877"

# Use project directory for temp file (more portable than mktemp)
TEMP_DIR="$PROJECT_ROOT/.icon_temp"
mkdir -p "$TEMP_DIR"
trap "rm -rf '$TEMP_DIR'" EXIT

echo "Downloading logo..."
curl -sL "$LOGO_URL" -o "$TEMP_DIR/logo.png"

# Copy logo to assets/images for in-app use
ASSETS_IMAGES="$PROJECT_ROOT/assets/images"
mkdir -p "$ASSETS_IMAGES"
cp "$TEMP_DIR/logo.png" "$ASSETS_IMAGES/logo.png"
echo "  In-app logo saved to assets/images/"

# Detect ImageMagick command (magick on Windows, convert on Unix)
if command -v magick &> /dev/null; then
    CONVERT="magick"
elif command -v convert &> /dev/null; then
    CONVERT="convert"
else
    echo "Error: ImageMagick not found. Please install ImageMagick."
    exit 1
fi

echo "Generating icons using $CONVERT..."

# Android icons
ANDROID_RES="$PROJECT_ROOT/android/app/src/main/res"
mkdir -p "$ANDROID_RES/mipmap-mdpi" "$ANDROID_RES/mipmap-hdpi" "$ANDROID_RES/mipmap-xhdpi" "$ANDROID_RES/mipmap-xxhdpi" "$ANDROID_RES/mipmap-xxxhdpi"
$CONVERT "$TEMP_DIR/logo.png" -resize 48x48 "$ANDROID_RES/mipmap-mdpi/ic_launcher.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 72x72 "$ANDROID_RES/mipmap-hdpi/ic_launcher.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 96x96 "$ANDROID_RES/mipmap-xhdpi/ic_launcher.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 144x144 "$ANDROID_RES/mipmap-xxhdpi/ic_launcher.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 192x192 "$ANDROID_RES/mipmap-xxxhdpi/ic_launcher.png"
echo "  Android icons generated"

# iOS icons
IOS_ICONS="$PROJECT_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_ICONS"
$CONVERT "$TEMP_DIR/logo.png" -resize 20x20 "$IOS_ICONS/Icon-App-20x20@1x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 40x40 "$IOS_ICONS/Icon-App-20x20@2x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 60x60 "$IOS_ICONS/Icon-App-20x20@3x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 29x29 "$IOS_ICONS/Icon-App-29x29@1x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 58x58 "$IOS_ICONS/Icon-App-29x29@2x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 87x87 "$IOS_ICONS/Icon-App-29x29@3x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 40x40 "$IOS_ICONS/Icon-App-40x40@1x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 80x80 "$IOS_ICONS/Icon-App-40x40@2x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 120x120 "$IOS_ICONS/Icon-App-40x40@3x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 120x120 "$IOS_ICONS/Icon-App-60x60@2x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 180x180 "$IOS_ICONS/Icon-App-60x60@3x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 76x76 "$IOS_ICONS/Icon-App-76x76@1x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 152x152 "$IOS_ICONS/Icon-App-76x76@2x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 167x167 "$IOS_ICONS/Icon-App-83.5x83.5@2x.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 1024x1024 "$IOS_ICONS/Icon-App-1024x1024@1x.png"
echo "  iOS icons generated"

# iOS Launch images (transparent placeholder)
IOS_LAUNCH="$PROJECT_ROOT/ios/Runner/Assets.xcassets/LaunchImage.imageset"
mkdir -p "$IOS_LAUNCH"
$CONVERT -size 1x1 xc:transparent "$IOS_LAUNCH/LaunchImage.png"
$CONVERT -size 1x1 xc:transparent "$IOS_LAUNCH/LaunchImage@2x.png"
$CONVERT -size 1x1 xc:transparent "$IOS_LAUNCH/LaunchImage@3x.png"
echo "  iOS launch images generated"

# macOS icons
MACOS_ICONS="$PROJECT_ROOT/macos/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$MACOS_ICONS"
$CONVERT "$TEMP_DIR/logo.png" -resize 16x16 "$MACOS_ICONS/app_icon_16.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 32x32 "$MACOS_ICONS/app_icon_32.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 64x64 "$MACOS_ICONS/app_icon_64.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 128x128 "$MACOS_ICONS/app_icon_128.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 256x256 "$MACOS_ICONS/app_icon_256.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 512x512 "$MACOS_ICONS/app_icon_512.png"
$CONVERT "$TEMP_DIR/logo.png" -resize 1024x1024 "$MACOS_ICONS/app_icon_1024.png"
echo "  macOS icons generated"

# Windows icon (ICO with multiple sizes)
WINDOWS_ICONS="$PROJECT_ROOT/windows/runner/resources"
mkdir -p "$WINDOWS_ICONS"
$CONVERT "$TEMP_DIR/logo.png" -define icon:auto-resize=256,128,64,48,32,16 "$WINDOWS_ICONS/app_icon.ico"
echo "  Windows icon generated"

echo "All icons generated successfully!"
