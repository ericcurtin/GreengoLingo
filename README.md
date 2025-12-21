# GreenGoLingo

GreenGoLingo is a cross-platform Portuguese language learning app.

## ✨ Key Features

### 🎯 Dialect Integrity
Choose your target dialect and learn the real language:

| Feature | European Portuguese (PT-PT) | Brazilian Portuguese (PT-BR) |
| --- | --- | --- |
| **"You" Form** | Focuses on *Tu* (informal) and *Você* (formal) | Primarily uses *Você* |
| **Verb Tense** | "Estou a comer" (Infinitive) | "Estou comendo" (Gerund) |
| **Pronouns** | Objects follow verb (*Amo-te*) | Objects precede verb (*Te amo*) |
| **Vocabulary** | *Autocarro*, *Comboio* | *Ônibus*, *Trem* |

### 📚 CEFR-Aligned Structure
Progress through standardized language levels (A1.1, A1.2, A2.1, etc.) with:
- **Clear Learning Objectives**: Know exactly what you'll learn in each level
- **Challenge Out**: Skip levels by proving competency
- **Grammar Cheat Sheets**: Human-written explanations for every concept

### 📝 Question Types
Two effective question types designed for real learning:

1. **Multiple Choice** (Recognition Phase)
   - Contextual scenarios, not just word translation
   - Real-world situations like ordering at a café

2. **Typing** (Production Phase)
   - No word bubbles - type from memory
   - **Strict Mode**: Accents required (pão vs pau)
   - **Lenient Mode**: Accents optional for beginners

## 🚀 Getting Started

### Prerequisites

- [Rust](https://rustup.rs/) (1.70+)
- [Node.js](https://nodejs.org/) (18+)
- Platform-specific requirements for Tauri:
  - **Linux**: `libwebkit2gtk-4.1-dev`, `libgtk-3-dev`, etc.
  - **macOS**: Xcode Command Line Tools
  - **Windows**: WebView2, MSVC Build Tools

### Installation

```bash
# Clone the repository
git clone https://github.com/ericcurtin/GreengoLingo.git
cd GreengoLingo

# Install dependencies
npm install

# Run Rust tests
cargo test

# Build the frontend
npm run build
```

### Development

```bash
# Run frontend in browser (without Tauri)
npm run dev

# Run with Tauri (requires platform dependencies)
npm run tauri dev
```

### Building for Production

```bash
# Build for current platform
npm run tauri build
```

## 🧪 Testing

```bash
# Run all Rust tests
cargo test

# Run tests with output
cargo test -- --nocapture
```

## 📄 API Reference

### Core Library (Rust)

The `greengolingo_core` crate provides:

- `Dialect`: Enum for PT-PT and PT-BR
- `CEFRLevel`: Language proficiency levels
- `Lesson`, `LessonUnit`, `Level`: Lesson structure
- `Question`, `Answer`, `QuestionResult`: Question handling
- `UserProgress`: Progress tracking
- `ContentManager`: Content organization

### Tauri Commands

The app exposes these commands to the frontend:

- `get_lessons()` - Get lessons for current dialect
- `check_user_answer()` - Evaluate user's answer
- `record_answer()` - Record answer in progress
- `toggle_dark_mode()` - Toggle dark mode
- `set_typing_mode()` - Set strict/lenient mode
- And more...

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests (`cargo test`)
5. Submit a pull request

### Content Contributions

We especially welcome:
- New lessons and questions
- Grammar cheat sheets
- Vocabulary entries
- Dialect-specific corrections

