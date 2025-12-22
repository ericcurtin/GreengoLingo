#!/bin/bash
# Generate app icons from the logo in README.md
# Requires: curl, and either ImageMagick OR sips (macOS built-in)

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

# Check if logo already exists in assets
ASSETS_IMAGES="$PROJECT_ROOT/assets/images"
if [ -f "$ASSETS_IMAGES/logo.png" ]; then
    echo "Using existing logo from assets/images/"
    cp "$ASSETS_IMAGES/logo.png" "$TEMP_DIR/logo.png"
else
    echo "Downloading logo..."
    if ! curl -sfL "$LOGO_URL" -o "$TEMP_DIR/logo.png" || [ ! -s "$TEMP_DIR/logo.png" ]; then
        echo "Download failed, generating placeholder icon..."
        # Detect ImageMagick command first
        if command -v magick &> /dev/null; then
            CONVERT="magick"
        elif command -v convert &> /dev/null; then
            CONVERT="convert"
        else
            echo "Error: ImageMagick not found and logo download failed."
            exit 1
        fi
        # Generate a simple green placeholder icon with "GL" text
        $CONVERT -size 1024x1024 xc:"#58CC02" \
            -gravity center -pointsize 400 -fill white \
            -font Helvetica-Bold -annotate 0 "GL" \
            "$TEMP_DIR/logo.png"
    fi
fi

# Copy logo to assets/images for in-app use
mkdir -p "$ASSETS_IMAGES"
cp "$TEMP_DIR/logo.png" "$ASSETS_IMAGES/logo.png"
echo "  In-app logo saved to assets/images/"

# Detect image processing tool
USE_SIPS=false
if command -v magick &> /dev/null; then
    CONVERT="magick"
    echo "Generating icons using ImageMagick (magick)..."
elif command -v convert &> /dev/null; then
    CONVERT="convert"
    echo "Generating icons using ImageMagick (convert)..."
elif command -v sips &> /dev/null; then
    USE_SIPS=true
    echo "Generating icons using sips (macOS)..."
else
    echo "Error: No image processing tool found. Please install ImageMagick."
    exit 1
fi

# Helper function to resize images
resize_image() {
    local src="$1"
    local dst="$2"
    local size="$3"

    if [ "$USE_SIPS" = true ]; then
        cp "$src" "$dst"
        sips -z "$size" "$size" "$dst" > /dev/null 2>&1
    else
        $CONVERT "$src" -resize "${size}x${size}" "$dst"
    fi
}

# Android icons
ANDROID_RES="$PROJECT_ROOT/android/app/src/main/res"
mkdir -p "$ANDROID_RES/mipmap-mdpi" "$ANDROID_RES/mipmap-hdpi" "$ANDROID_RES/mipmap-xhdpi" "$ANDROID_RES/mipmap-xxhdpi" "$ANDROID_RES/mipmap-xxxhdpi"
resize_image "$TEMP_DIR/logo.png" "$ANDROID_RES/mipmap-mdpi/ic_launcher.png" 48
resize_image "$TEMP_DIR/logo.png" "$ANDROID_RES/mipmap-hdpi/ic_launcher.png" 72
resize_image "$TEMP_DIR/logo.png" "$ANDROID_RES/mipmap-xhdpi/ic_launcher.png" 96
resize_image "$TEMP_DIR/logo.png" "$ANDROID_RES/mipmap-xxhdpi/ic_launcher.png" 144
resize_image "$TEMP_DIR/logo.png" "$ANDROID_RES/mipmap-xxxhdpi/ic_launcher.png" 192
echo "  Android icons generated"

# iOS icons
IOS_ICONS="$PROJECT_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_ICONS"
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-20x20@1x.png" 20
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-20x20@2x.png" 40
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-20x20@3x.png" 60
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-29x29@1x.png" 29
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-29x29@2x.png" 58
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-29x29@3x.png" 87
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-40x40@1x.png" 40
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-40x40@2x.png" 80
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-40x40@3x.png" 120
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-60x60@2x.png" 120
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-60x60@3x.png" 180
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-76x76@1x.png" 76
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-76x76@2x.png" 152
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-83.5x83.5@2x.png" 167
resize_image "$TEMP_DIR/logo.png" "$IOS_ICONS/Icon-App-1024x1024@1x.png" 1024
echo "  iOS icons generated"

# iOS Launch images (transparent placeholder or solid color)
IOS_LAUNCH="$PROJECT_ROOT/ios/Runner/Assets.xcassets/LaunchImage.imageset"
mkdir -p "$IOS_LAUNCH"
if [ "$USE_SIPS" = true ]; then
    # sips can't create transparent images, use a 1x1 white PNG as placeholder
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\xff\xff?\x00\x05\xfe\x02\xfe\xa7V\xbd\x00\x00\x00\x00IEND\xaeB`\x82' > "$IOS_LAUNCH/LaunchImage.png"
    cp "$IOS_LAUNCH/LaunchImage.png" "$IOS_LAUNCH/LaunchImage@2x.png"
    cp "$IOS_LAUNCH/LaunchImage.png" "$IOS_LAUNCH/LaunchImage@3x.png"
else
    $CONVERT -size 1x1 xc:transparent "$IOS_LAUNCH/LaunchImage.png"
    $CONVERT -size 1x1 xc:transparent "$IOS_LAUNCH/LaunchImage@2x.png"
    $CONVERT -size 1x1 xc:transparent "$IOS_LAUNCH/LaunchImage@3x.png"
fi
echo "  iOS launch images generated"

# macOS icons
MACOS_ICONS="$PROJECT_ROOT/macos/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$MACOS_ICONS"
resize_image "$TEMP_DIR/logo.png" "$MACOS_ICONS/app_icon_16.png" 16
resize_image "$TEMP_DIR/logo.png" "$MACOS_ICONS/app_icon_32.png" 32
resize_image "$TEMP_DIR/logo.png" "$MACOS_ICONS/app_icon_64.png" 64
resize_image "$TEMP_DIR/logo.png" "$MACOS_ICONS/app_icon_128.png" 128
resize_image "$TEMP_DIR/logo.png" "$MACOS_ICONS/app_icon_256.png" 256
resize_image "$TEMP_DIR/logo.png" "$MACOS_ICONS/app_icon_512.png" 512
resize_image "$TEMP_DIR/logo.png" "$MACOS_ICONS/app_icon_1024.png" 1024
echo "  macOS icons generated"

# Windows icon (ICO with multiple sizes)
WINDOWS_ICONS="$PROJECT_ROOT/windows/runner/resources"
mkdir -p "$WINDOWS_ICONS"
if [ "$USE_SIPS" = true ]; then
    # sips can't create ICO files, use the largest PNG as a fallback
    # Windows can use PNG as app icon in modern versions
    resize_image "$TEMP_DIR/logo.png" "$WINDOWS_ICONS/app_icon.png" 256
    echo "  Windows icon generated (PNG format - install ImageMagick for ICO)"
else
    $CONVERT "$TEMP_DIR/logo.png" -define icon:auto-resize=256,128,64,48,32,16 "$WINDOWS_ICONS/app_icon.ico"
    echo "  Windows icon generated"
fi

echo "All icons generated successfully!"
