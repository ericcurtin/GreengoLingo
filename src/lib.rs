//! GreengoLingo Core Library
//!
//! This crate provides the core functionality for the GreengoLingo Portuguese
//! language learning application. It handles dialect-specific content,
//! CEFR-aligned lesson structure, and question evaluation.

pub mod dialect;
pub mod lesson;
pub mod question;
pub mod progress;
pub mod content;

pub use dialect::{Dialect, DialectDifference};
pub use lesson::{Lesson, Level, CEFRLevel, LessonUnit, CheatSheet};
pub use question::{Question, QuestionType, Answer, TypingMode, QuestionResult};
pub use progress::{UserProgress, LessonProgress};
pub use content::ContentManager;

/// Application version
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// Application name
pub const APP_NAME: &str = "GreengoLingo";

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_version() {
        assert!(!VERSION.is_empty());
    }

    #[test]
    fn test_app_name() {
        assert_eq!(APP_NAME, "GreengoLingo");
    }
}
