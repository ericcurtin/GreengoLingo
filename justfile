# GreengoLingo Build Commands
# Use with: just <command>

# Default recipe to show available commands
default:
    @just --list

# Install dependencies
install:
    npm install

# Run Rust tests
test:
    cargo test

# Build frontend only
build-frontend:
    npm run build

# Build desktop app for current platform
build-desktop:
    npm run tauri build

# Build desktop app for Linux (run on Linux)
# Tauri builds for current platform automatically
build-linux:
    npm run tauri build

# Build desktop app for macOS (run on macOS)
# Tauri builds for current platform automatically
build-macos:
    npm run tauri build

# Build desktop app for Windows (run on Windows)
# Tauri builds for current platform automatically
build-windows:
    npm run tauri build

# Build Android APK (requires Android SDK)
build-android:
    npm run tauri android build -- --apk true

# Build iOS app (requires macOS with Xcode and code signing)
build-ios:
    npm run tauri ios build

# Build iOS app for simulator (no code signing required, for CI)
build-ios-simulator:
    npm run tauri ios build -- --target aarch64-sim

# Build all desktop formats (run on appropriate OS)
build-all-desktop:
    npm run tauri build

# Development mode
dev:
    npm run tauri dev

# Development mode for Android
dev-android:
    npm run tauri android dev

# Development mode for iOS
dev-ios:
    npm run tauri ios dev

# Initialize Android project (first time setup)
init-android:
    npm run tauri android init

# Initialize iOS project (first time setup)
init-ios:
    npm run tauri ios init

# Clean build artifacts
clean:
    cargo clean
    rm -rf dist
    rm -rf node_modules

# Lint Rust code
lint-rust:
    cargo clippy --all-targets --all-features -- -D warnings

# Format Rust code
fmt-rust:
    cargo fmt

# Check Rust formatting
check-fmt-rust:
    cargo fmt -- --check
