//! Dialect module for Portuguese language variants
//!
//! This module provides support for European Portuguese (PT-PT) and
//! Brazilian Portuguese (PT-BR), handling their grammatical and vocabulary differences.

use serde::{Deserialize, Serialize};

/// Portuguese dialect variants
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Dialect {
    /// European Portuguese (Portugal)
    #[serde(rename = "pt-pt")]
    European,
    /// Brazilian Portuguese (Brazil)
    #[serde(rename = "pt-br")]
    Brazilian,
}

impl Dialect {
    /// Returns the display name of the dialect
    pub fn display_name(&self) -> &'static str {
        match self {
            Dialect::European => "European Portuguese (PT-PT)",
            Dialect::Brazilian => "Brazilian Portuguese (PT-BR)",
        }
    }

    /// Returns the short code for the dialect
    pub fn code(&self) -> &'static str {
        match self {
            Dialect::European => "pt-pt",
            Dialect::Brazilian => "pt-br",
        }
    }

    /// Returns the country/region associated with this dialect
    pub fn region(&self) -> &'static str {
        match self {
            Dialect::European => "Portugal",
            Dialect::Brazilian => "Brazil",
        }
    }
}

impl Default for Dialect {
    fn default() -> Self {
        Dialect::European
    }
}

impl std::fmt::Display for Dialect {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.display_name())
    }
}

/// Represents a key grammatical or vocabulary difference between dialects
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DialectDifference {
    /// Category of the difference (e.g., "Pronoun Placement", "Verb Tense")
    pub category: String,
    /// Description of the difference
    pub description: String,
    /// Example in European Portuguese
    pub european_example: String,
    /// Example in Brazilian Portuguese
    pub brazilian_example: String,
    /// English translation
    pub english_translation: String,
}

impl DialectDifference {
    /// Create a new dialect difference
    pub fn new(
        category: impl Into<String>,
        description: impl Into<String>,
        european_example: impl Into<String>,
        brazilian_example: impl Into<String>,
        english_translation: impl Into<String>,
    ) -> Self {
        Self {
            category: category.into(),
            description: description.into(),
            european_example: european_example.into(),
            brazilian_example: brazilian_example.into(),
            english_translation: english_translation.into(),
        }
    }

    /// Get the example for a specific dialect
    pub fn example_for(&self, dialect: Dialect) -> &str {
        match dialect {
            Dialect::European => &self.european_example,
            Dialect::Brazilian => &self.brazilian_example,
        }
    }
}

/// Returns the key dialect differences between PT-PT and PT-BR
pub fn get_key_differences() -> Vec<DialectDifference> {
    vec![
        DialectDifference::new(
            "You Form",
            "European Portuguese uses 'Tu' (informal) and 'Você' (formal), while Brazilian Portuguese primarily uses 'Você' for both.",
            "Tu és muito simpático.",
            "Você é muito simpático.",
            "You are very nice.",
        ),
        DialectDifference::new(
            "Progressive Tense",
            "European Portuguese uses 'estar a + infinitive', while Brazilian Portuguese uses 'estar + gerund'.",
            "Estou a comer.",
            "Estou comendo.",
            "I am eating.",
        ),
        DialectDifference::new(
            "Pronoun Placement",
            "In European Portuguese, object pronouns usually follow the verb. In Brazilian Portuguese, they often precede it.",
            "Amo-te.",
            "Te amo.",
            "I love you.",
        ),
        DialectDifference::new(
            "Vocabulary - Bus",
            "Different words for common items.",
            "Autocarro",
            "Ônibus",
            "Bus",
        ),
        DialectDifference::new(
            "Vocabulary - Train",
            "Different words for common items.",
            "Comboio",
            "Trem",
            "Train",
        ),
        DialectDifference::new(
            "Vocabulary - Bathroom",
            "Different words for common items.",
            "Casa de banho",
            "Banheiro",
            "Bathroom",
        ),
        DialectDifference::new(
            "Vocabulary - Breakfast",
            "Different words for common items.",
            "Pequeno-almoço",
            "Café da manhã",
            "Breakfast",
        ),
        DialectDifference::new(
            "Gerund vs Infinitive",
            "Usage of gerund constructions differs significantly.",
            "Estou a trabalhar em casa.",
            "Estou trabalhando em casa.",
            "I am working from home.",
        ),
    ]
}

/// Vocabulary entry with dialect-specific translations
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VocabularyEntry {
    /// English word/phrase
    pub english: String,
    /// European Portuguese translation
    pub european: String,
    /// Brazilian Portuguese translation
    pub brazilian: String,
    /// Category (e.g., "Transportation", "Food", "Greetings")
    pub category: String,
    /// Phonetic pronunciation hint (optional)
    pub pronunciation_hint: Option<String>,
}

impl VocabularyEntry {
    /// Create a new vocabulary entry
    pub fn new(
        english: impl Into<String>,
        european: impl Into<String>,
        brazilian: impl Into<String>,
        category: impl Into<String>,
    ) -> Self {
        Self {
            english: english.into(),
            european: european.into(),
            brazilian: brazilian.into(),
            category: category.into(),
            pronunciation_hint: None,
        }
    }

    /// Create a vocabulary entry with pronunciation hint
    pub fn with_pronunciation(
        english: impl Into<String>,
        european: impl Into<String>,
        brazilian: impl Into<String>,
        category: impl Into<String>,
        pronunciation: impl Into<String>,
    ) -> Self {
        Self {
            english: english.into(),
            european: european.into(),
            brazilian: brazilian.into(),
            category: category.into(),
            pronunciation_hint: Some(pronunciation.into()),
        }
    }

    /// Get the translation for a specific dialect
    pub fn translation_for(&self, dialect: Dialect) -> &str {
        match dialect {
            Dialect::European => &self.european,
            Dialect::Brazilian => &self.brazilian,
        }
    }

    /// Check if the translations differ between dialects
    pub fn has_dialect_difference(&self) -> bool {
        self.european != self.brazilian
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dialect_display_name() {
        assert_eq!(Dialect::European.display_name(), "European Portuguese (PT-PT)");
        assert_eq!(Dialect::Brazilian.display_name(), "Brazilian Portuguese (PT-BR)");
    }

    #[test]
    fn test_dialect_code() {
        assert_eq!(Dialect::European.code(), "pt-pt");
        assert_eq!(Dialect::Brazilian.code(), "pt-br");
    }

    #[test]
    fn test_dialect_region() {
        assert_eq!(Dialect::European.region(), "Portugal");
        assert_eq!(Dialect::Brazilian.region(), "Brazil");
    }

    #[test]
    fn test_dialect_difference_example() {
        let diff = DialectDifference::new(
            "Test",
            "Test difference",
            "European example",
            "Brazilian example",
            "English",
        );
        assert_eq!(diff.example_for(Dialect::European), "European example");
        assert_eq!(diff.example_for(Dialect::Brazilian), "Brazilian example");
    }

    #[test]
    fn test_key_differences() {
        let differences = get_key_differences();
        assert!(!differences.is_empty());
        // Should have at least the main grammatical differences
        assert!(differences.len() >= 5);
    }

    #[test]
    fn test_vocabulary_entry() {
        let entry = VocabularyEntry::new("Bus", "Autocarro", "Ônibus", "Transportation");
        assert_eq!(entry.translation_for(Dialect::European), "Autocarro");
        assert_eq!(entry.translation_for(Dialect::Brazilian), "Ônibus");
        assert!(entry.has_dialect_difference());
    }

    #[test]
    fn test_vocabulary_entry_same_translation() {
        let entry = VocabularyEntry::new("Hello", "Olá", "Olá", "Greetings");
        assert!(!entry.has_dialect_difference());
    }

    #[test]
    fn test_dialect_serialization() {
        let european = Dialect::European;
        let json = serde_json::to_string(&european).unwrap();
        assert_eq!(json, "\"pt-pt\"");

        let brazilian = Dialect::Brazilian;
        let json = serde_json::to_string(&brazilian).unwrap();
        assert_eq!(json, "\"pt-br\"");
    }

    #[test]
    fn test_dialect_deserialization() {
        let european: Dialect = serde_json::from_str("\"pt-pt\"").unwrap();
        assert_eq!(european, Dialect::European);

        let brazilian: Dialect = serde_json::from_str("\"pt-br\"").unwrap();
        assert_eq!(brazilian, Dialect::Brazilian);
    }
}
