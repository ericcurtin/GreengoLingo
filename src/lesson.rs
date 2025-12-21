//! Lesson module for CEFR-aligned language learning structure
//!
//! This module provides the lesson structure based on the Common European
//! Framework of Reference for Languages (CEFR).

use serde::{Deserialize, Serialize};
use crate::dialect::Dialect;
use crate::question::Question;

/// CEFR proficiency levels
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
    /// Proficient - Can understand virtually everything heard or read
    C2,
}

impl CEFRLevel {
    /// Returns the display name of the CEFR level
    pub fn display_name(&self) -> &'static str {
        match self {
            CEFRLevel::A1 => "A1 - Beginner",
            CEFRLevel::A2 => "A2 - Elementary",
            CEFRLevel::B1 => "B1 - Intermediate",
            CEFRLevel::B2 => "B2 - Upper Intermediate",
            CEFRLevel::C1 => "C1 - Advanced",
            CEFRLevel::C2 => "C2 - Proficient",
        }
    }

    /// Returns a description of what the learner can do at this level
    pub fn description(&self) -> &'static str {
        match self {
            CEFRLevel::A1 => "Can understand and use familiar everyday expressions and very basic phrases aimed at the satisfaction of needs of a concrete type.",
            CEFRLevel::A2 => "Can understand sentences and frequently used expressions related to areas of most immediate relevance.",
            CEFRLevel::B1 => "Can understand the main points of clear standard input on familiar matters regularly encountered in work, school, leisure, etc.",
            CEFRLevel::B2 => "Can understand the main ideas of complex text on both concrete and abstract topics, including technical discussions in their field of specialization.",
            CEFRLevel::C1 => "Can understand a wide range of demanding, longer texts, and recognise implicit meaning.",
            CEFRLevel::C2 => "Can understand with ease virtually everything heard or read.",
        }
    }

    /// Returns all CEFR levels in order
    pub fn all() -> &'static [CEFRLevel] {
        &[
            CEFRLevel::A1,
            CEFRLevel::A2,
            CEFRLevel::B1,
            CEFRLevel::B2,
            CEFRLevel::C1,
            CEFRLevel::C2,
        ]
    }

    /// Returns the next CEFR level, if any
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

    /// Returns the previous CEFR level, if any
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
}

impl std::fmt::Display for CEFRLevel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.display_name())
    }
}

/// A specific sub-level within a CEFR level (e.g., A1.1, A1.2)
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct Level {
    /// The base CEFR level
    pub cefr: CEFRLevel,
    /// The sub-level (1, 2, etc.)
    pub sub_level: u8,
    /// The title of this level
    pub title: String,
    /// What the learner will be able to do after completing this level
    pub learning_objectives: Vec<String>,
}

impl Level {
    /// Create a new level
    pub fn new(
        cefr: CEFRLevel,
        sub_level: u8,
        title: impl Into<String>,
        learning_objectives: Vec<String>,
    ) -> Self {
        Self {
            cefr,
            sub_level,
            title: title.into(),
            learning_objectives,
        }
    }

    /// Returns the full level code (e.g., "A1.1")
    pub fn code(&self) -> String {
        format!("{:?}.{}", self.cefr, self.sub_level)
    }

    /// Returns the display name with title
    pub fn display_name(&self) -> String {
        format!("{} - {}", self.code(), self.title)
    }
}

impl std::fmt::Display for Level {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.display_name())
    }
}

/// A grammar explanation or "cheat sheet" for a lesson
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CheatSheet {
    /// Title of the grammar concept
    pub title: String,
    /// Explanation of the grammar rule
    pub explanation: String,
    /// Examples with translations
    pub examples: Vec<CheatSheetExample>,
    /// Common mistakes to avoid
    pub common_mistakes: Vec<String>,
    /// Tips for remembering this concept
    pub tips: Vec<String>,
}

/// An example in a cheat sheet
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CheatSheetExample {
    /// The Portuguese text
    pub portuguese: String,
    /// The English translation
    pub english: String,
    /// Optional breakdown of the grammar
    pub breakdown: Option<String>,
}

impl CheatSheetExample {
    /// Create a new example
    pub fn new(portuguese: impl Into<String>, english: impl Into<String>) -> Self {
        Self {
            portuguese: portuguese.into(),
            english: english.into(),
            breakdown: None,
        }
    }

    /// Create an example with a grammatical breakdown
    pub fn with_breakdown(
        portuguese: impl Into<String>,
        english: impl Into<String>,
        breakdown: impl Into<String>,
    ) -> Self {
        Self {
            portuguese: portuguese.into(),
            english: english.into(),
            breakdown: Some(breakdown.into()),
        }
    }
}

impl CheatSheet {
    /// Create a new cheat sheet
    pub fn new(title: impl Into<String>, explanation: impl Into<String>) -> Self {
        Self {
            title: title.into(),
            explanation: explanation.into(),
            examples: Vec::new(),
            common_mistakes: Vec::new(),
            tips: Vec::new(),
        }
    }

    /// Add an example to the cheat sheet
    pub fn with_example(mut self, example: CheatSheetExample) -> Self {
        self.examples.push(example);
        self
    }

    /// Add a common mistake to avoid
    pub fn with_mistake(mut self, mistake: impl Into<String>) -> Self {
        self.common_mistakes.push(mistake.into());
        self
    }

    /// Add a tip for remembering
    pub fn with_tip(mut self, tip: impl Into<String>) -> Self {
        self.tips.push(tip.into());
        self
    }
}

/// A unit within a lesson containing related content
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LessonUnit {
    /// Unique identifier for this unit
    pub id: String,
    /// Title of the unit
    pub title: String,
    /// Description of what this unit covers
    pub description: String,
    /// The dialect this unit is for
    pub dialect: Dialect,
    /// Grammar cheat sheets for this unit
    pub cheat_sheets: Vec<CheatSheet>,
    /// Questions in this unit
    pub questions: Vec<Question>,
    /// Vocabulary words introduced in this unit
    pub vocabulary: Vec<String>,
}

impl LessonUnit {
    /// Create a new lesson unit
    pub fn new(
        id: impl Into<String>,
        title: impl Into<String>,
        description: impl Into<String>,
        dialect: Dialect,
    ) -> Self {
        Self {
            id: id.into(),
            title: title.into(),
            description: description.into(),
            dialect,
            cheat_sheets: Vec::new(),
            questions: Vec::new(),
            vocabulary: Vec::new(),
        }
    }

    /// Add a cheat sheet to this unit
    pub fn with_cheat_sheet(mut self, cheat_sheet: CheatSheet) -> Self {
        self.cheat_sheets.push(cheat_sheet);
        self
    }

    /// Add a question to this unit
    pub fn with_question(mut self, question: Question) -> Self {
        self.questions.push(question);
        self
    }

    /// Add vocabulary words to this unit
    pub fn with_vocabulary(mut self, words: Vec<String>) -> Self {
        self.vocabulary.extend(words);
        self
    }
}

/// A complete lesson with multiple units
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Lesson {
    /// Unique identifier for this lesson
    pub id: String,
    /// The level this lesson belongs to
    pub level: Level,
    /// Title of the lesson
    pub title: String,
    /// Description of the lesson
    pub description: String,
    /// The dialect this lesson is for
    pub dialect: Dialect,
    /// Units in this lesson
    pub units: Vec<LessonUnit>,
    /// Whether this lesson allows "challenge out" (skip if user proves competency)
    pub allows_challenge_out: bool,
}

impl Lesson {
    /// Create a new lesson
    pub fn new(
        id: impl Into<String>,
        level: Level,
        title: impl Into<String>,
        description: impl Into<String>,
        dialect: Dialect,
    ) -> Self {
        Self {
            id: id.into(),
            level,
            title: title.into(),
            description: description.into(),
            dialect,
            units: Vec::new(),
            allows_challenge_out: true,
        }
    }

    /// Add a unit to this lesson
    pub fn with_unit(mut self, unit: LessonUnit) -> Self {
        self.units.push(unit);
        self
    }

    /// Set whether this lesson allows challenge out
    pub fn with_challenge_out(mut self, allows: bool) -> Self {
        self.allows_challenge_out = allows;
        self
    }

    /// Get the total number of questions in this lesson
    pub fn total_questions(&self) -> usize {
        self.units.iter().map(|u| u.questions.len()).sum()
    }

    /// Get all questions in this lesson
    pub fn all_questions(&self) -> Vec<&Question> {
        self.units.iter().flat_map(|u| &u.questions).collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cefr_level_display() {
        assert_eq!(CEFRLevel::A1.display_name(), "A1 - Beginner");
        assert_eq!(CEFRLevel::C2.display_name(), "C2 - Proficient");
    }

    #[test]
    fn test_cefr_level_all() {
        let levels = CEFRLevel::all();
        assert_eq!(levels.len(), 6);
        assert_eq!(levels[0], CEFRLevel::A1);
        assert_eq!(levels[5], CEFRLevel::C2);
    }

    #[test]
    fn test_cefr_level_next() {
        assert_eq!(CEFRLevel::A1.next(), Some(CEFRLevel::A2));
        assert_eq!(CEFRLevel::C2.next(), None);
    }

    #[test]
    fn test_cefr_level_previous() {
        assert_eq!(CEFRLevel::A1.previous(), None);
        assert_eq!(CEFRLevel::A2.previous(), Some(CEFRLevel::A1));
    }

    #[test]
    fn test_level_code() {
        let level = Level::new(
            CEFRLevel::A1,
            1,
            "Introduction",
            vec!["Order a coffee".to_string()],
        );
        assert_eq!(level.code(), "A1.1");
    }

    #[test]
    fn test_cheat_sheet_builder() {
        let cheat_sheet = CheatSheet::new(
            "Present Tense",
            "The present tense is used for current actions.",
        )
        .with_example(CheatSheetExample::new("Eu falo", "I speak"))
        .with_mistake("Don't forget verb conjugation endings")
        .with_tip("Regular -ar verbs follow a consistent pattern");

        assert_eq!(cheat_sheet.title, "Present Tense");
        assert_eq!(cheat_sheet.examples.len(), 1);
        assert_eq!(cheat_sheet.common_mistakes.len(), 1);
        assert_eq!(cheat_sheet.tips.len(), 1);
    }

    #[test]
    fn test_lesson_unit_builder() {
        let unit = LessonUnit::new(
            "unit-1",
            "Greetings",
            "Learn basic greetings",
            Dialect::European,
        )
        .with_vocabulary(vec!["Olá".to_string(), "Bom dia".to_string()]);

        assert_eq!(unit.id, "unit-1");
        assert_eq!(unit.vocabulary.len(), 2);
    }

    #[test]
    fn test_lesson_builder() {
        let level = Level::new(
            CEFRLevel::A1,
            1,
            "First Steps",
            vec!["Introduce yourself".to_string()],
        );
        let unit = LessonUnit::new(
            "unit-1",
            "Greetings",
            "Learn basic greetings",
            Dialect::European,
        );
        let lesson = Lesson::new(
            "lesson-1",
            level,
            "Hello World",
            "Your first Portuguese lesson",
            Dialect::European,
        )
        .with_unit(unit);

        assert_eq!(lesson.id, "lesson-1");
        assert_eq!(lesson.units.len(), 1);
        assert!(lesson.allows_challenge_out);
    }
}
