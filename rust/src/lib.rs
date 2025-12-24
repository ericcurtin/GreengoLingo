//! GreengoLingo Core Library
//!
//! This library provides the core logic for the GreengoLingo language learning app,
//! including content management, gamification systems, progress tracking, and
//! answer validation.

pub mod api;
pub mod engine;
pub mod gamification;
pub mod models;
pub mod progress;
pub mod srs;
pub mod statistics;

// Re-export main types for convenience
pub use engine::{Answer, AnswerValidator, ValidationResult};
pub use gamification::{
    AchievementId, AchievementTracker, StreakStatus, StreakTracker, XPMultipliers, XPSystem,
};
pub use models::{
    CEFRLevel, CheatSheet, ContentBundle, ContentIndex, Dialect, Language, LanguagePair, Lesson,
    LessonMetadata, Question, TypingMode,
};
pub use progress::{LessonCompletionResult, ProgressStats, ProgressTracker};
pub use srs::{
    MasteryLevel, ReviewQuality, SRSCard, SRSCardStats, SRSScheduler, SRSUpdate, VocabularyBank,
    VocabularyCategory, VocabularyItem, VocabularyStats,
};
pub use statistics::{
    DailyStats, LearningAnalytics, LearningVelocity, LifetimeStats, MonthlySummary,
    QuestionTypeStats, StatisticsTracker, StudyPatternAnalysis, VelocityTrend, WeakArea,
    WeakAreaType, WeeklySummary,
};
