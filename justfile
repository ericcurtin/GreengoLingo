# GreengoLingo Build Commands
# Use with: just <command>

# Default recipe to show available commands
default:
    @just --list

# ============================================================================
# Setup & Dependencies
# ============================================================================

# Install all dependencies and generate icons
install:
    flutter pub get
    cargo fetch
    ./scripts/generate_icons.sh

# Clean all build artifacts
clean:
    flutter clean
    cargo clean

# ============================================================================
# Development
# ============================================================================

# Run app in development mode (defaults to current platform)
dev:
    flutter run

# Run app on Android device/emulator
dev-android:
    flutter run -d android

# Run app on iOS simulator
dev-ios:
    flutter run -d ios

# Run app on Chrome (web)
dev-web:
    flutter run -d chrome

# Run app on macOS
dev-macos:
    flutter run -d macos

# Run app on Linux
dev-linux:
    flutter run -d linux

# Run app on Windows
dev-windows:
    flutter run -d windows

# Hot reload/restart (when running)
reload:
    flutter attach

# ============================================================================
# Testing
# ============================================================================

# Run all tests
test: test-rust test-flutter

# Run Rust tests
test-rust:
    cargo test

# Run Flutter tests
test-flutter:
    flutter test

# Run Flutter tests with coverage
test-coverage:
    flutter test --coverage

# ============================================================================
# Code Quality
# ============================================================================

# Run all lints and checks
lint: lint-rust lint-flutter

# Lint Rust code
lint-rust:
    cargo clippy --all-targets --all-features -- -D warnings

# Lint Flutter/Dart code
lint-flutter:
    flutter analyze

# Format all code
fmt: fmt-rust fmt-flutter

# Format Rust code
fmt-rust:
    cargo fmt

# Format Dart code
fmt-flutter:
    dart format lib test

# Check formatting without changes
check-fmt: check-fmt-rust check-fmt-flutter

# Check Rust formatting
check-fmt-rust:
    cargo fmt -- --check

# Check Dart formatting
check-fmt-flutter:
    dart format --set-exit-if-changed lib test

# ============================================================================
# Build - Desktop
# ============================================================================

# Build for current platform (release)
build:
    flutter build

# Build Linux app
build-linux:
    flutter build linux --release

# Build macOS app
build-macos:
    flutter build macos --release

# Build Windows app
build-windows:
    flutter build windows --release

# ============================================================================
# Build - Mobile
# ============================================================================

# Build Android APK
build-android:
    flutter build apk --release

# Build Android App Bundle (for Play Store)
build-android-bundle:
    flutter build appbundle --release

# Build Android with split APKs by ABI
build-android-split:
    flutter build apk --release --split-per-abi

# Build iOS (requires code signing)
build-ios:
    flutter build ios --release

# Build iOS without code signing (for CI)
build-ios-nosign:
    flutter build ios --release --no-codesign

# Build iOS IPA (requires code signing and export options)
build-ipa:
    flutter build ipa --release

# ============================================================================
# Build - All Platforms
# ============================================================================

# Build all desktop platforms (run on appropriate OS)
build-all-desktop: build-linux build-macos build-windows

# Build all mobile platforms
build-all-mobile: build-android build-ios-nosign

# ============================================================================
# Rust-specific
# ============================================================================

# Build Rust library (debug)
rust-build:
    cargo build

# Build Rust library (release)
rust-build-release:
    cargo build --release

# Generate flutter_rust_bridge bindings
frb-generate:
    flutter_rust_bridge_codegen generate

# ============================================================================
# Utilities
# ============================================================================

# Show connected devices
devices:
    flutter devices

# Show Flutter doctor output
doctor:
    flutter doctor -v

# Upgrade Flutter
upgrade:
    flutter upgrade

# Update dependencies
update:
    flutter pub upgrade
    cargo update

# Generate app icons from README logo
icons:
    ./scripts/generate_icons.sh

# Generate splash screen
splash:
    flutter pub run flutter_native_splash:create

# Open iOS project in Xcode
xcode:
    open ios/Runner.xcworkspace

# Open Android project in Android Studio
android-studio:
    open -a "Android Studio" android
