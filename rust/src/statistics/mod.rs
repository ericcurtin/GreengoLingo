//! Statistics and analytics for learning progress
//!
//! This module tracks daily learning statistics, analyzes performance,
//! and generates periodic reports.

pub mod analytics;
pub mod daily;
pub mod reports;

// Re-export commonly used types
pub use analytics::{
    LearningAnalytics, LearningVelocity, StudyPatternAnalysis, VelocityTrend, WeakArea,
    WeakAreaType,
};
pub use daily::{DailyStats, LifetimeStats, QuestionTypeStats, StatisticsTracker};
pub use reports::{MonthlySummary, WeeklySummary};
