//! Spaced Repetition System (SRS) for vocabulary retention
//!
//! This module implements the SM-2 algorithm for optimized learning intervals.

pub mod card;
pub mod scheduler;
pub mod vocabulary;

// Re-export commonly used types
pub use card::{MasteryLevel, SRSCard, SRSCardStats};
pub use scheduler::{ReviewQuality, SRSScheduler, SRSUpdate};
pub use vocabulary::{VocabularyBank, VocabularyCategory, VocabularyItem, VocabularyStats};
