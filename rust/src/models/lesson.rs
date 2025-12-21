use serde::{Deserialize, Serialize};

use super::language::LanguagePair;
use super::level::CEFRLevel;
use super::question::Question;

/// A complete lesson with questions and metadata
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Lesson {
    /// Unique identifier for this lesson
    pub id: String,
    /// Display title of the lesson
    pub title: String,
    /// Short description of what this lesson covers
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    /// CEFR level of this lesson
    pub level: CEFRLevel,
    /// Language pair (source -> target)
    pub language_pair: LanguagePair,
    /// XP reward for completing this lesson
    #[serde(default = "default_xp")]
    pub xp_reward: u32,
    /// The questions in this lesson
    pub questions: Vec<Question>,
    /// Optional cheat sheet with grammar/vocabulary reference
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cheat_sheet: Option<CheatSheet>,
    /// Order within the level (for sorting)
    #[serde(default)]
    pub order: u32,
    /// Icon name for display
    #[serde(skip_serializing_if = "Option::is_none")]
    pub icon: Option<String>,
}

fn default_xp() -> u32 {
    10
}

impl Lesson {
    /// Create a new lesson builder
    pub fn builder(id: impl Into<String>, title: impl Into<String>) -> LessonBuilder {
        LessonBuilder::new(id, title)
    }

    /// Get the number of questions in this lesson
    pub fn question_count(&self) -> usize {
        self.questions.len()
    }

    /// Check if this lesson has a cheat sheet
    pub fn has_cheat_sheet(&self) -> bool {
        self.cheat_sheet.is_some()
    }
}

/// Builder for creating lessons
pub struct LessonBuilder {
    id: String,
    title: String,
    description: Option<String>,
    level: CEFRLevel,
    language_pair: Option<LanguagePair>,
    xp_reward: u32,
    questions: Vec<Question>,
    cheat_sheet: Option<CheatSheet>,
    order: u32,
    icon: Option<String>,
}

impl LessonBuilder {
    pub fn new(id: impl Into<String>, title: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            title: title.into(),
            description: None,
            level: CEFRLevel::A1,
            language_pair: None,
            xp_reward: 10,
            questions: Vec::new(),
            cheat_sheet: None,
            order: 0,
            icon: None,
        }
    }

    pub fn description(mut self, desc: impl Into<String>) -> Self {
        self.description = Some(desc.into());
        self
    }

    pub fn level(mut self, level: CEFRLevel) -> Self {
        self.level = level;
        self
    }

    pub fn language_pair(mut self, pair: LanguagePair) -> Self {
        self.language_pair = Some(pair);
        self
    }

    pub fn xp_reward(mut self, xp: u32) -> Self {
        self.xp_reward = xp;
        self
    }

    pub fn questions(mut self, questions: Vec<Question>) -> Self {
        self.questions = questions;
        self
    }

    pub fn add_question(mut self, question: Question) -> Self {
        self.questions.push(question);
        self
    }

    pub fn cheat_sheet(mut self, sheet: CheatSheet) -> Self {
        self.cheat_sheet = Some(sheet);
        self
    }

    pub fn order(mut self, order: u32) -> Self {
        self.order = order;
        self
    }

    pub fn icon(mut self, icon: impl Into<String>) -> Self {
        self.icon = Some(icon.into());
        self
    }

    pub fn build(self) -> Result<Lesson, &'static str> {
        let language_pair = self.language_pair.ok_or("Language pair is required")?;

        if self.questions.is_empty() {
            return Err("At least one question is required");
        }

        Ok(Lesson {
            id: self.id,
            title: self.title,
            description: self.description,
            level: self.level,
            language_pair,
            xp_reward: self.xp_reward,
            questions: self.questions,
            cheat_sheet: self.cheat_sheet,
            order: self.order,
            icon: self.icon,
        })
    }
}

/// Reference material shown alongside a lesson
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CheatSheet {
    /// Title of the cheat sheet
    pub title: String,
    /// Sections containing the reference content
    pub sections: Vec<CheatSheetSection>,
}

/// A section within a cheat sheet
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CheatSheetSection {
    /// Section heading
    pub heading: String,
    /// Content items (text, examples, etc.)
    pub content: Vec<CheatSheetContent>,
}

/// Content within a cheat sheet section
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum CheatSheetContent {
    /// Plain text explanation
    Text { text: String },
    /// Example with source and target language
    Example {
        source: String,
        target: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        note: Option<String>,
    },
    /// A tip or hint
    Tip { text: String },
    /// A warning about common mistakes
    Warning { text: String },
    /// A vocabulary list
    Vocabulary { items: Vec<(String, String)> },
}

/// Metadata about a lesson (without the full content)
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct LessonMetadata {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub level: CEFRLevel,
    pub xp_reward: u32,
    pub question_count: usize,
    pub has_cheat_sheet: bool,
    pub order: u32,
    pub icon: Option<String>,
}

impl From<&Lesson> for LessonMetadata {
    fn from(lesson: &Lesson) -> Self {
        Self {
            id: lesson.id.clone(),
            title: lesson.title.clone(),
            description: lesson.description.clone(),
            level: lesson.level,
            xp_reward: lesson.xp_reward,
            question_count: lesson.questions.len(),
            has_cheat_sheet: lesson.cheat_sheet.is_some(),
            order: lesson.order,
            icon: lesson.icon.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::language::Dialect;

    #[test]
    fn test_lesson_builder() {
        let pair = LanguagePair::new(Dialect::EnglishUS, Dialect::PortugueseEuropean);
        let question =
            Question::multiple_choice("Test question", vec!["A".into(), "B".into()], 0, None);

        let lesson = Lesson::builder("test_01", "Test Lesson")
            .description("A test lesson")
            .level(CEFRLevel::A1)
            .language_pair(pair)
            .xp_reward(15)
            .add_question(question)
            .order(1)
            .build()
            .unwrap();

        assert_eq!(lesson.id, "test_01");
        assert_eq!(lesson.question_count(), 1);
        assert_eq!(lesson.xp_reward, 15);
    }

    #[test]
    fn test_lesson_metadata() {
        let pair = LanguagePair::new(Dialect::EnglishUS, Dialect::PortugueseEuropean);
        let question = Question::typing("Test", vec!["answer".into()], None, false);

        let lesson = Lesson::builder("meta_test", "Metadata Test")
            .language_pair(pair)
            .add_question(question)
            .build()
            .unwrap();

        let metadata: LessonMetadata = (&lesson).into();
        assert_eq!(metadata.id, "meta_test");
        assert_eq!(metadata.question_count, 1);
    }
}
