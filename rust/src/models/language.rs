use serde::{Deserialize, Serialize};

/// Base language without regional variants
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Language {
    English,
    Portuguese,
}

impl Language {
    /// Get the display name for this language
    pub fn display_name(&self) -> &'static str {
        match self {
            Language::English => "English",
            Language::Portuguese => "Portuguese",
        }
    }

    /// Get the ISO 639-1 code
    pub fn iso_code(&self) -> &'static str {
        match self {
            Language::English => "en",
            Language::Portuguese => "pt",
        }
    }
}

/// Specific dialect/variant of a language
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Dialect {
    #[serde(rename = "en_US")]
    EnglishUS,
    #[serde(rename = "en_UK")]
    EnglishUK,
    #[serde(rename = "pt_PT")]
    PortugueseEuropean,
    #[serde(rename = "pt_BR")]
    PortugueseBrazilian,
}

impl Dialect {
    /// Get the base language for this dialect
    pub fn language(&self) -> Language {
        match self {
            Dialect::EnglishUS | Dialect::EnglishUK => Language::English,
            Dialect::PortugueseEuropean | Dialect::PortugueseBrazilian => Language::Portuguese,
        }
    }

    /// Get the display name for this dialect
    pub fn display_name(&self) -> &'static str {
        match self {
            Dialect::EnglishUS => "English (US)",
            Dialect::EnglishUK => "English (UK)",
            Dialect::PortugueseEuropean => "European Portuguese",
            Dialect::PortugueseBrazilian => "Brazilian Portuguese",
        }
    }

    /// Get the short display name
    pub fn short_name(&self) -> &'static str {
        match self {
            Dialect::EnglishUS => "US English",
            Dialect::EnglishUK => "UK English",
            Dialect::PortugueseEuropean => "PT-PT",
            Dialect::PortugueseBrazilian => "PT-BR",
        }
    }

    /// Get the locale code (e.g., "en_US", "pt_BR")
    pub fn locale_code(&self) -> &'static str {
        match self {
            Dialect::EnglishUS => "en_US",
            Dialect::EnglishUK => "en_UK",
            Dialect::PortugueseEuropean => "pt_PT",
            Dialect::PortugueseBrazilian => "pt_BR",
        }
    }

    /// Get the flag emoji for this dialect
    pub fn flag_emoji(&self) -> &'static str {
        match self {
            Dialect::EnglishUS => "🇺🇸",
            Dialect::EnglishUK => "🇬🇧",
            Dialect::PortugueseEuropean => "🇵🇹",
            Dialect::PortugueseBrazilian => "🇧🇷",
        }
    }

    /// Get all dialects for a given language
    pub fn dialects_for_language(language: Language) -> Vec<Dialect> {
        match language {
            Language::English => vec![Dialect::EnglishUS, Dialect::EnglishUK],
            Language::Portuguese => vec![Dialect::PortugueseEuropean, Dialect::PortugueseBrazilian],
        }
    }

    /// Get all available dialects
    pub fn all() -> Vec<Dialect> {
        vec![
            Dialect::EnglishUS,
            Dialect::EnglishUK,
            Dialect::PortugueseEuropean,
            Dialect::PortugueseBrazilian,
        ]
    }
}

/// A pair of dialects representing a learning direction (source -> target)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct LanguagePair {
    /// The language the learner knows (interface language)
    pub source: Dialect,
    /// The language the learner is studying
    pub target: Dialect,
}

impl LanguagePair {
    /// Create a new language pair
    pub fn new(source: Dialect, target: Dialect) -> Self {
        Self { source, target }
    }

    /// Get the content directory name for this pair (e.g., "en_to_pt_pt")
    pub fn content_dir(&self) -> String {
        let source_lang = self.source.language().iso_code();
        let target_locale = self.target.locale_code().to_lowercase();
        format!("{}_to_{}", source_lang, target_locale)
    }

    /// Get display name (e.g., "English → European Portuguese")
    pub fn display_name(&self) -> String {
        format!(
            "{} → {}",
            self.source.display_name(),
            self.target.display_name()
        )
    }

    /// Get all supported language pairs
    pub fn supported_pairs() -> Vec<LanguagePair> {
        vec![
            // English speakers learning Portuguese
            LanguagePair::new(Dialect::EnglishUS, Dialect::PortugueseEuropean),
            LanguagePair::new(Dialect::EnglishUS, Dialect::PortugueseBrazilian),
            // Portuguese speakers learning English
            LanguagePair::new(Dialect::PortugueseEuropean, Dialect::EnglishUS),
            LanguagePair::new(Dialect::PortugueseBrazilian, Dialect::EnglishUS),
        ]
    }

    /// Check if this is a supported language pair
    pub fn is_supported(&self) -> bool {
        Self::supported_pairs().contains(self)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dialect_language() {
        assert_eq!(Dialect::EnglishUS.language(), Language::English);
        assert_eq!(
            Dialect::PortugueseBrazilian.language(),
            Language::Portuguese
        );
    }

    #[test]
    fn test_language_pair_content_dir() {
        let pair = LanguagePair::new(Dialect::EnglishUS, Dialect::PortugueseEuropean);
        assert_eq!(pair.content_dir(), "en_to_pt_pt");
    }

    #[test]
    fn test_supported_pairs() {
        let pairs = LanguagePair::supported_pairs();
        assert_eq!(pairs.len(), 4);
    }
}
