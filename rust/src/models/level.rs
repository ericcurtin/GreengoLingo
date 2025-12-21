use serde::{Deserialize, Serialize};

/// CEFR (Common European Framework of Reference) language proficiency levels
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum CEFRLevel {
    /// Beginner - Can understand and use familiar everyday expressions
    A1,
    /// Elementary - Can communicate in simple and routine tasks
    A2,
    /// Intermediate - Can deal with most situations while traveling
    B1,
    /// Upper Intermediate - Can interact with fluency and spontaneity
    B2,
    /// Advanced - Can express ideas fluently and spontaneously
    C1,
    /// Mastery - Can understand virtually everything heard or read
    C2,
}

impl CEFRLevel {
    /// Get the display name for this level
    pub fn display_name(&self) -> &'static str {
        match self {
            CEFRLevel::A1 => "A1 - Beginner",
            CEFRLevel::A2 => "A2 - Elementary",
            CEFRLevel::B1 => "B1 - Intermediate",
            CEFRLevel::B2 => "B2 - Upper Intermediate",
            CEFRLevel::C1 => "C1 - Advanced",
            CEFRLevel::C2 => "C2 - Mastery",
        }
    }

    /// Get short name (just the level code)
    pub fn short_name(&self) -> &'static str {
        match self {
            CEFRLevel::A1 => "A1",
            CEFRLevel::A2 => "A2",
            CEFRLevel::B1 => "B1",
            CEFRLevel::B2 => "B2",
            CEFRLevel::C1 => "C1",
            CEFRLevel::C2 => "C2",
        }
    }

    /// Get a description of what this level means
    pub fn description(&self) -> &'static str {
        match self {
            CEFRLevel::A1 => "Can understand and use familiar everyday expressions and very basic phrases.",
            CEFRLevel::A2 => "Can communicate in simple and routine tasks requiring direct exchange of information.",
            CEFRLevel::B1 => "Can deal with most situations likely to arise while traveling in the target language area.",
            CEFRLevel::B2 => "Can interact with a degree of fluency and spontaneity with native speakers.",
            CEFRLevel::C1 => "Can express ideas fluently and spontaneously without obvious searching for expressions.",
            CEFRLevel::C2 => "Can understand with ease virtually everything heard or read.",
        }
    }

    /// Get the directory name for content storage
    pub fn content_dir(&self) -> &'static str {
        match self {
            CEFRLevel::A1 => "a1",
            CEFRLevel::A2 => "a2",
            CEFRLevel::B1 => "b1",
            CEFRLevel::B2 => "b2",
            CEFRLevel::C1 => "c1",
            CEFRLevel::C2 => "c2",
        }
    }

    /// Get a color associated with this level (as hex string)
    pub fn color(&self) -> &'static str {
        match self {
            CEFRLevel::A1 => "#4CAF50", // Green
            CEFRLevel::A2 => "#8BC34A", // Light Green
            CEFRLevel::B1 => "#FFC107", // Amber
            CEFRLevel::B2 => "#FF9800", // Orange
            CEFRLevel::C1 => "#F44336", // Red
            CEFRLevel::C2 => "#9C27B0", // Purple
        }
    }

    /// Get all levels in order
    pub fn all() -> Vec<CEFRLevel> {
        vec![
            CEFRLevel::A1,
            CEFRLevel::A2,
            CEFRLevel::B1,
            CEFRLevel::B2,
            CEFRLevel::C1,
            CEFRLevel::C2,
        ]
    }

    /// Get the next level (returns None if already at C2)
    pub fn next(&self) -> Option<CEFRLevel> {
        match self {
            CEFRLevel::A1 => Some(CEFRLevel::A2),
            CEFRLevel::A2 => Some(CEFRLevel::B1),
            CEFRLevel::B1 => Some(CEFRLevel::B2),
            CEFRLevel::B2 => Some(CEFRLevel::C1),
            CEFRLevel::C1 => Some(CEFRLevel::C2),
            CEFRLevel::C2 => None,
        }
    }

    /// Get the previous level (returns None if already at A1)
    pub fn previous(&self) -> Option<CEFRLevel> {
        match self {
            CEFRLevel::A1 => None,
            CEFRLevel::A2 => Some(CEFRLevel::A1),
            CEFRLevel::B1 => Some(CEFRLevel::A2),
            CEFRLevel::B2 => Some(CEFRLevel::B1),
            CEFRLevel::C1 => Some(CEFRLevel::B2),
            CEFRLevel::C2 => Some(CEFRLevel::C1),
        }
    }

    /// Parse from string (case-insensitive)
    pub fn parse(s: &str) -> Option<CEFRLevel> {
        match s.to_uppercase().as_str() {
            "A1" => Some(CEFRLevel::A1),
            "A2" => Some(CEFRLevel::A2),
            "B1" => Some(CEFRLevel::B1),
            "B2" => Some(CEFRLevel::B2),
            "C1" => Some(CEFRLevel::C1),
            "C2" => Some(CEFRLevel::C2),
            _ => None,
        }
    }
}

impl std::fmt::Display for CEFRLevel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.short_name())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_level_ordering() {
        assert!(CEFRLevel::A1 < CEFRLevel::A2);
        assert!(CEFRLevel::B2 < CEFRLevel::C1);
    }

    #[test]
    fn test_next_level() {
        assert_eq!(CEFRLevel::A1.next(), Some(CEFRLevel::A2));
        assert_eq!(CEFRLevel::C2.next(), None);
    }

    #[test]
    fn test_from_str() {
        assert_eq!(CEFRLevel::parse("a1"), Some(CEFRLevel::A1));
        assert_eq!(CEFRLevel::parse("B2"), Some(CEFRLevel::B2));
        assert_eq!(CEFRLevel::parse("invalid"), None);
    }
}
