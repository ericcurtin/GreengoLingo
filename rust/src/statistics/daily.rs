//! Daily statistics tracking

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Statistics for a question type
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct QuestionTypeStats {
    pub answered: u32,
    pub correct: u32,
}

impl QuestionTypeStats {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn record(&mut self, correct: bool) {
        self.answered += 1;
        if correct {
            self.correct += 1;
        }
    }

    pub fn accuracy(&self) -> f32 {
        if self.answered == 0 {
            0.0
        } else {
            (self.correct as f32 / self.answered as f32) * 100.0
        }
    }

    pub fn merge(&mut self, other: &QuestionTypeStats) {
        self.answered += other.answered;
        self.correct += other.correct;
    }
}

/// Statistics for a single day
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DailyStats {
    /// Date in ISO format (YYYY-MM-DD)
    pub date: String,
    /// XP earned this day
    pub xp_earned: u32,
    /// Number of lessons completed
    pub lessons_completed: u32,
    /// Time spent learning in seconds
    pub time_spent_seconds: u32,
    /// Total questions answered
    pub questions_answered: u32,
    /// Total correct answers
    pub questions_correct: u32,
    /// SRS reviews completed
    pub srs_reviews: u32,
    /// SRS reviews correct
    pub srs_correct: u32,
    /// New words learned
    pub new_words_learned: u32,
    /// Accuracy by question type
    pub accuracy_by_type: HashMap<String, QuestionTypeStats>,
    /// Levels practiced
    pub levels_practiced: Vec<String>,
}

impl DailyStats {
    /// Create new daily stats for a date
    pub fn new(date: &str) -> Self {
        Self {
            date: date.to_string(),
            xp_earned: 0,
            lessons_completed: 0,
            time_spent_seconds: 0,
            questions_answered: 0,
            questions_correct: 0,
            srs_reviews: 0,
            srs_correct: 0,
            new_words_learned: 0,
            accuracy_by_type: HashMap::new(),
            levels_practiced: Vec::new(),
        }
    }

    /// Record a lesson completion
    pub fn record_lesson_completion(
        &mut self,
        xp: u32,
        questions: u32,
        correct: u32,
        time_seconds: u32,
        level: &str,
    ) {
        self.xp_earned += xp;
        self.lessons_completed += 1;
        self.questions_answered += questions;
        self.questions_correct += correct;
        self.time_spent_seconds += time_seconds;
        if !self.levels_practiced.contains(&level.to_string()) {
            self.levels_practiced.push(level.to_string());
        }
    }

    /// Record a question answer by type
    pub fn record_question(&mut self, question_type: &str, correct: bool) {
        self.accuracy_by_type
            .entry(question_type.to_string())
            .or_default()
            .record(correct);
    }

    /// Record an SRS review
    pub fn record_srs_review(&mut self, correct: bool) {
        self.srs_reviews += 1;
        if correct {
            self.srs_correct += 1;
        }
    }

    /// Record new words learned
    pub fn record_words_learned(&mut self, count: u32) {
        self.new_words_learned += count;
    }

    /// Get overall accuracy for the day
    pub fn accuracy(&self) -> f32 {
        if self.questions_answered == 0 {
            0.0
        } else {
            (self.questions_correct as f32 / self.questions_answered as f32) * 100.0
        }
    }

    /// Get SRS accuracy
    pub fn srs_accuracy(&self) -> f32 {
        if self.srs_reviews == 0 {
            0.0
        } else {
            (self.srs_correct as f32 / self.srs_reviews as f32) * 100.0
        }
    }
}

/// Lifetime statistics summary
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct LifetimeStats {
    /// Total XP earned all time
    pub total_xp: u32,
    /// Total lessons completed
    pub total_lessons: u32,
    /// Total time spent in seconds
    pub total_time_seconds: u32,
    /// Total questions answered
    pub total_questions: u32,
    /// Total correct answers
    pub total_correct: u32,
    /// Total SRS reviews
    pub total_srs_reviews: u32,
    /// Total SRS correct
    pub total_srs_correct: u32,
    /// Total words learned
    pub total_words: u32,
    /// Total days with activity
    pub days_active: u32,
    /// Longest streak achieved
    pub longest_streak: u32,
    /// Current streak
    pub current_streak: u32,
    /// Accuracy by question type (lifetime)
    pub accuracy_by_type: HashMap<String, QuestionTypeStats>,
    /// First activity date
    pub first_activity_date: Option<String>,
    /// Most recent activity date
    pub last_activity_date: Option<String>,
}

impl LifetimeStats {
    pub fn new() -> Self {
        Self::default()
    }

    /// Update lifetime stats from daily stats
    pub fn update_from_daily(&mut self, daily: &DailyStats) {
        self.total_xp += daily.xp_earned;
        self.total_lessons += daily.lessons_completed;
        self.total_time_seconds += daily.time_spent_seconds;
        self.total_questions += daily.questions_answered;
        self.total_correct += daily.questions_correct;
        self.total_srs_reviews += daily.srs_reviews;
        self.total_srs_correct += daily.srs_correct;
        self.total_words += daily.new_words_learned;

        // Merge accuracy by type
        for (question_type, stats) in &daily.accuracy_by_type {
            self.accuracy_by_type
                .entry(question_type.clone())
                .or_default()
                .merge(stats);
        }

        // Update activity dates
        if self.first_activity_date.is_none() {
            self.first_activity_date = Some(daily.date.clone());
        }
        self.last_activity_date = Some(daily.date.clone());
    }

    /// Get overall accuracy
    pub fn accuracy(&self) -> f32 {
        if self.total_questions == 0 {
            0.0
        } else {
            (self.total_correct as f32 / self.total_questions as f32) * 100.0
        }
    }

    /// Get total hours studied
    pub fn total_hours(&self) -> f32 {
        self.total_time_seconds as f32 / 3600.0
    }

    /// Get average XP per day active
    pub fn average_xp_per_day(&self) -> f32 {
        if self.days_active == 0 {
            0.0
        } else {
            self.total_xp as f32 / self.days_active as f32
        }
    }
}

/// Tracker for all statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatisticsTracker {
    /// Daily stats indexed by date
    daily_stats: HashMap<String, DailyStats>,
    /// Lifetime stats
    pub lifetime: LifetimeStats,
}

impl StatisticsTracker {
    /// Create a new statistics tracker
    pub fn new() -> Self {
        Self {
            daily_stats: HashMap::new(),
            lifetime: LifetimeStats::new(),
        }
    }

    /// Get or create daily stats for a date
    pub fn get_or_create_daily(&mut self, date: &str) -> &mut DailyStats {
        if !self.daily_stats.contains_key(date) {
            self.daily_stats
                .insert(date.to_string(), DailyStats::new(date));
            self.lifetime.days_active += 1;
        }
        self.daily_stats.get_mut(date).unwrap()
    }

    /// Get daily stats for a date (if exists)
    pub fn get_daily(&self, date: &str) -> Option<&DailyStats> {
        self.daily_stats.get(date)
    }

    /// Record a lesson completion
    pub fn record_lesson_completion(
        &mut self,
        date: &str,
        xp: u32,
        questions: u32,
        correct: u32,
        time_seconds: u32,
        level: &str,
    ) {
        let daily = self.get_or_create_daily(date);
        daily.record_lesson_completion(xp, questions, correct, time_seconds, level);

        // Update lifetime stats
        self.lifetime.total_xp += xp;
        self.lifetime.total_lessons += 1;
        self.lifetime.total_time_seconds += time_seconds;
        self.lifetime.total_questions += questions;
        self.lifetime.total_correct += correct;
    }

    /// Record a question answer
    pub fn record_question(&mut self, date: &str, question_type: &str, correct: bool) {
        let daily = self.get_or_create_daily(date);
        daily.record_question(question_type, correct);

        self.lifetime
            .accuracy_by_type
            .entry(question_type.to_string())
            .or_default()
            .record(correct);
    }

    /// Record an SRS review
    pub fn record_srs_review(&mut self, date: &str, correct: bool) {
        let daily = self.get_or_create_daily(date);
        daily.record_srs_review(correct);

        self.lifetime.total_srs_reviews += 1;
        if correct {
            self.lifetime.total_srs_correct += 1;
        }
    }

    /// Record words learned
    pub fn record_words_learned(&mut self, date: &str, count: u32) {
        let daily = self.get_or_create_daily(date);
        daily.record_words_learned(count);
        self.lifetime.total_words += count;
    }

    /// Update streak information
    pub fn update_streak(&mut self, current: u32, longest: u32) {
        self.lifetime.current_streak = current;
        if longest > self.lifetime.longest_streak {
            self.lifetime.longest_streak = longest;
        }
    }

    /// Get stats for a date range
    pub fn get_range(&self, start_date: &str, end_date: &str) -> Vec<&DailyStats> {
        self.daily_stats
            .values()
            .filter(|s| s.date.as_str() >= start_date && s.date.as_str() <= end_date)
            .collect()
    }

    /// Get recent stats (last N days)
    pub fn get_recent(&self, days: usize) -> Vec<&DailyStats> {
        let mut stats: Vec<_> = self.daily_stats.values().collect();
        stats.sort_by(|a, b| b.date.cmp(&a.date));
        stats.truncate(days);
        stats
    }

    /// Get XP trend for last N days
    pub fn xp_trend(&self, days: usize) -> Vec<(String, u32)> {
        let mut stats: Vec<_> = self.daily_stats.values().collect();
        stats.sort_by(|a, b| b.date.cmp(&a.date));
        stats.truncate(days);
        stats.reverse();
        stats
            .iter()
            .map(|s| (s.date.clone(), s.xp_earned))
            .collect()
    }

    /// Get accuracy trend for last N days
    pub fn accuracy_trend(&self, days: usize) -> Vec<(String, f32)> {
        let mut stats: Vec<_> = self.daily_stats.values().collect();
        stats.sort_by(|a, b| b.date.cmp(&a.date));
        stats.truncate(days);
        stats.reverse();
        stats
            .iter()
            .map(|s| (s.date.clone(), s.accuracy()))
            .collect()
    }

    /// Get total daily stats count
    pub fn days_tracked(&self) -> usize {
        self.daily_stats.len()
    }
}

impl Default for StatisticsTracker {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_daily_stats() {
        let mut stats = DailyStats::new("2024-01-15");
        stats.record_lesson_completion(100, 10, 8, 300, "A1");

        assert_eq!(stats.xp_earned, 100);
        assert_eq!(stats.lessons_completed, 1);
        assert_eq!(stats.accuracy(), 80.0);
    }

    #[test]
    fn test_question_type_tracking() {
        let mut stats = DailyStats::new("2024-01-15");
        stats.record_question("multiple_choice", true);
        stats.record_question("multiple_choice", true);
        stats.record_question("multiple_choice", false);
        stats.record_question("typing", true);

        let mc_stats = stats.accuracy_by_type.get("multiple_choice").unwrap();
        assert_eq!(mc_stats.answered, 3);
        assert_eq!(mc_stats.correct, 2);
        assert!((mc_stats.accuracy() - 66.67).abs() < 0.1);
    }

    #[test]
    fn test_statistics_tracker() {
        let mut tracker = StatisticsTracker::new();
        tracker.record_lesson_completion("2024-01-15", 100, 10, 8, 300, "A1");
        tracker.record_lesson_completion("2024-01-16", 150, 12, 10, 400, "A1");

        assert_eq!(tracker.lifetime.total_xp, 250);
        assert_eq!(tracker.lifetime.total_lessons, 2);
        assert_eq!(tracker.days_tracked(), 2);
    }

    #[test]
    fn test_xp_trend() {
        let mut tracker = StatisticsTracker::new();
        tracker.record_lesson_completion("2024-01-15", 100, 10, 8, 300, "A1");
        tracker.record_lesson_completion("2024-01-16", 150, 12, 10, 400, "A1");

        let trend = tracker.xp_trend(7);
        assert_eq!(trend.len(), 2);
    }
}
