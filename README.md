# GreenGoLingo 🇵🇹🇧🇷

**Premium Portuguese Language Learning Application**

GreenGoLingo is a cross-platform Portuguese language learning app that prioritizes **dialect precision**, **academic structure**, and **human-crafted quality** over gamification. Unlike other apps, GreenGoLingo treats European Portuguese (PT-PT) and Brazilian Portuguese (PT-BR) as genuinely separate courses, not just different accents.

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

### 💚 No Penalties
- **No Hearts System**: Mistakes are learning opportunities
- **No Punishments**: Practice as much as you want
- **Community Vetting**: Flag sentences for naturalness review

### 🌙 Modern Design
- Dark mode by default
- Clean, minimalist interface
- Adult-oriented - no "preschool" aesthetics

## 🛠️ Technology Stack

- **Core Logic**: Rust (cross-platform shared library)
- **Desktop & Mobile**: Tauri 2.0 (macOS, Linux, Windows, iOS, Android)
- **Frontend**: Vanilla JavaScript + CSS (no framework bloat)
- **Build**: Vite + Cargo

## 📦 Project Structure

```
GreengoLingo/
├── src/                    # Rust core library
│   ├── lib.rs              # Main library entry
│   ├── dialect.rs          # PT-PT vs PT-BR handling
│   ├── lesson.rs           # CEFR-aligned lessons
│   ├── question.rs         # Question types & evaluation
│   ├── progress.rs         # User progress tracking
│   └── content.rs          # Lesson content management
├── src-tauri/              # Tauri application
│   ├── src/
│   │   ├── lib.rs          # Tauri commands & state
│   │   └── main.rs         # Entry point
│   └── tauri.conf.json     # Tauri configuration
├── src/                    # Frontend assets
│   ├── main.js             # Application logic
│   └── styles.css          # Dark mode styles
├── index.html              # Main HTML
├── Cargo.toml              # Rust dependencies
├── package.json            # Node dependencies
└── vite.config.js          # Vite configuration
```

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

## 📱 Platform Support

| Platform | Status |
| --- | --- |
| Linux | ✅ Supported |
| macOS | ✅ Supported |
| Windows | ✅ Supported |
| iOS | ✅ Supported (via Tauri 2.0) |
| Android | ✅ Supported (via Tauri 2.0) |

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

## 📜 License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## 🎯 Philosophy

GreenGoLingo is built on these principles:

1. **Quality over Quantity**: Human-crafted content over AI-generated
2. **Precision over Simplification**: Real dialect differences matter
3. **Learning over Gaming**: Tools for learners, not addiction mechanics
4. **Transparency over Mystery**: Clear goals and explanations
5. **Freedom over Punishment**: No hearts, no penalties

---

*"Learn Portuguese the right way – with dialect precision and academic structure."*
