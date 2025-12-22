# GreengoLingo

<img width="1600" height="1600" alt="GreengoLingo" src="https://github.com/user-attachments/assets/55452d70-b75e-4a95-aca4-6ad94b024877" />

A language app for learning through gamified lessons and interactive exercises.

## Features

- **Multiple Question Types**: Multiple choice, typing, matching pairs, and sentence building
- **Gamification**: XP points, daily streaks, achievements, and level progression
- **CEFR Levels**: Structured learning from A1 (Beginner) to C2 (Mastery)
- **Dialect Support**: European Portuguese (PT-PT) and Brazilian Portuguese (PT-BR)
- **Haptic Feedback**: Vibrations for correct/incorrect answers
- **Offline First**: All content bundled with the app
- **Cross-Platform**: Windows, macOS, Linux, Android, and iOS

## Getting Started

### Prerequisites

- Flutter
- Rust
- For mobile: Android SDK / Xcode

### Installation

```bash
# Clone the repository
git clone https://github.com/ericcurtin/GreengoLingo.git
cd GreengoLingo

# Install dependencies
just install

# Run the app
just dev
```

### Building

```bash
# Build for current platform
just build

# Platform-specific builds
just build-android    # Android APK
just build-ios        # iOS (requires macOS)
just build-macos      # macOS app
just build-linux      # Linux app
just build-windows    # Windows exe
```

### Testing

```bash
# Run all tests
just test

# Rust tests only
just test-rust

# Flutter tests only
just test-flutter
```

## Supported Languages

| Source | Target | Code |
|--------|--------|------|
| English | European Portuguese | en_to_pt_pt |
| English | Brazilian Portuguese | en_to_pt_br |
| European Portuguese | English | pt_pt_to_en |
| Brazilian Portuguese | English | pt_br_to_en |

