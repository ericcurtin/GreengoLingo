//! Progress tracking module
//!
//! This module handles tracking user progress through lessons,
//! without a punitive "hearts" system.

use serde::{Deserialize, Serialize};
use crate::dialect::Dialect;
use crate::lesson::CEFRLevel;
use crate::question::TypingMode;
use std::collections::HashMap;

/// Check if two dates (in YYYY-MM-DD format) are consecutive days
fn is_consecutive_day(date1: &str, date2: &str) -> bool {
    // Parse dates in YYYY-MM-DD format
    let parse_date = |s: &str| -> Option<(i32, u32, u32)> {
        let parts: Vec<&str> = s.split('-').collect();
        if parts.len() != 3 {
            return None;
        }
        let year: i32 = parts[0].parse().ok()?;
        let month: u32 = parts[1].parse().ok()?;
        let day: u32 = parts[2].parse().ok()?;
        Some((year, month, day))
    };

    let Some((y1, m1, d1)) = parse_date(date1) else {
        return false;
    };
    let Some((y2, m2, d2)) = parse_date(date2) else {
        return false;
    };

    // Simple consecutive day check
    // Check if date2 is exactly one day after date1
    let days_in_month = |year: i32, month: u32| -> u32 {
        match month {
            1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
            4 | 6 | 9 | 11 => 30,
            2 => {
                if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) {
                    29
                } else {
                    28
                }
            }
            _ => 30,
        }
    };

    // Calculate the expected next day from date1
    let (next_y, next_m, next_d) = if d1 < days_in_month(y1, m1) {
        (y1, m1, d1 + 1)
    } else if m1 < 12 {
        (y1, m1 + 1, 1)
    } else {
        (y1 + 1, 1, 1)
    };

    y2 == next_y && m2 == next_m && d2 == next_d
}

/// User's overall progress and preferences
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserProgress {
    /// User's unique identifier
    pub user_id: String,
    /// Selected dialect to learn
    pub dialect: Dialect,
    /// Base language (English)
    pub base_language: String,
    /// Typing mode preference
    pub typing_mode: TypingMode,
    /// Current CEFR level
    pub current_level: CEFRLevel,
    /// Current sub-level within the CEFR level
    pub current_sub_level: u8,
    /// Progress for each lesson
    pub lesson_progress: HashMap<String, LessonProgress>,
    /// Total questions answered
    pub total_questions_answered: u64,
    /// Total correct answers
    pub total_correct_answers: u64,
    /// Levels that have been "challenged out" (skipped by proving competency)
    pub challenged_out_levels: Vec<String>,
    /// Daily streak (consecutive days of practice)
    pub daily_streak: u32,
    /// Last practice date (ISO 8601 format)
    pub last_practice_date: Option<String>,
    /// Total practice time in minutes
    pub total_practice_minutes: u64,
    /// Dark mode preference
    pub dark_mode: bool,
}

impl UserProgress {
    /// Create a new user progress tracker
    pub fn new(user_id: impl Into<String>, dialect: Dialect) -> Self {
        Self {
            user_id: user_id.into(),
            dialect,
            base_language: "en".to_string(),
            typing_mode: TypingMode::default(),
            current_level: CEFRLevel::A1,
            current_sub_level: 1,
            lesson_progress: HashMap::new(),
            total_questions_answered: 0,
            total_correct_answers: 0,
            challenged_out_levels: Vec::new(),
            daily_streak: 0,
            last_practice_date: None,
            total_practice_minutes: 0,
            dark_mode: true, // Default to dark mode for minimalist interface
        }
    }

    /// Get the current level code (e.g., "A1.1")
    pub fn current_level_code(&self) -> String {
        format!("{:?}.{}", self.current_level, self.current_sub_level)
    }

    /// Record an answer
    pub fn record_answer(&mut self, lesson_id: &str, question_id: &str, is_correct: bool) {
        self.total_questions_answered += 1;
        if is_correct {
            self.total_correct_answers += 1;
        }

        let lesson_progress = self
            .lesson_progress
            .entry(lesson_id.to_string())
            .or_insert_with(|| LessonProgress::new(lesson_id));
        
        lesson_progress.record_answer(question_id, is_correct);
    }

    /// Get the overall accuracy percentage
    pub fn accuracy_percentage(&self) -> f64 {
        if self.total_questions_answered == 0 {
            0.0
        } else {
            (self.total_correct_answers as f64 / self.total_questions_answered as f64) * 100.0
        }
    }

    /// Advance to the next sub-level
    pub fn advance_sub_level(&mut self) {
        self.current_sub_level += 1;
        // If we've completed enough sub-levels, advance to next CEFR level
        if self.current_sub_level > 3 {
            if let Some(next_level) = self.current_level.next() {
                self.current_level = next_level;
                self.current_sub_level = 1;
            }
        }
    }

    /// Challenge out of a level (skip it by proving competency)
    pub fn challenge_out(&mut self, level_code: &str) {
        if !self.challenged_out_levels.contains(&level_code.to_string()) {
            self.challenged_out_levels.push(level_code.to_string());
        }
    }

    /// Check if a level has been challenged out
    pub fn has_challenged_out(&self, level_code: &str) -> bool {
        self.challenged_out_levels.contains(&level_code.to_string())
    }

    /// Update the daily streak
    /// 
    /// The current_date should be in ISO 8601 format (YYYY-MM-DD).
    /// Streak is incremented only if the practice is on the consecutive day.
    pub fn update_streak(&mut self, current_date: &str) {
        if let Some(last_date) = &self.last_practice_date {
            if last_date == current_date {
                // Same day, no streak update needed
                return;
            }
            
            // Parse dates to check if they are consecutive
            // Expected format: YYYY-MM-DD
            if is_consecutive_day(last_date, current_date) {
                self.daily_streak += 1;
            } else {
                // Streak broken - reset to 1
                self.daily_streak = 1;
            }
        } else {
            self.daily_streak = 1;
        }
        self.last_practice_date = Some(current_date.to_string());
    }

    /// Get progress for a specific lesson
    pub fn get_lesson_progress(&self, lesson_id: &str) -> Option<&LessonProgress> {
        self.lesson_progress.get(lesson_id)
    }

    /// Check if a lesson is completed
    pub fn is_lesson_completed(&self, lesson_id: &str) -> bool {
        self.lesson_progress
            .get(lesson_id)
            .map(|p| p.is_completed)
            .unwrap_or(false)
    }

    /// Set the typing mode preference
    pub fn set_typing_mode(&mut self, mode: TypingMode) {
        self.typing_mode = mode;
    }

    /// Toggle dark mode
    pub fn toggle_dark_mode(&mut self) {
        self.dark_mode = !self.dark_mode;
    }

    /// Add practice time
    pub fn add_practice_time(&mut self, minutes: u64) {
        self.total_practice_minutes += minutes;
    }
}

impl Default for UserProgress {
    fn default() -> Self {
        Self::new("default-user", Dialect::default())
    }
}

/// Progress for a single lesson
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LessonProgress {
    /// Lesson identifier
    pub lesson_id: String,
    /// Whether the lesson is completed
    pub is_completed: bool,
    /// Questions answered in this lesson
    pub questions_answered: HashMap<String, QuestionAttempt>,
    /// Number of times this lesson has been practiced
    pub practice_count: u32,
    /// Best score achieved (percentage)
    pub best_score: f64,
    /// Last score achieved (percentage)
    pub last_score: f64,
    /// Total time spent on this lesson (minutes)
    pub time_spent_minutes: u64,
}

impl LessonProgress {
    /// Create new lesson progress
    pub fn new(lesson_id: impl Into<String>) -> Self {
        Self {
            lesson_id: lesson_id.into(),
            is_completed: false,
            questions_answered: HashMap::new(),
            practice_count: 0,
            best_score: 0.0,
            last_score: 0.0,
            time_spent_minutes: 0,
        }
    }

    /// Record an answer for a question
    pub fn record_answer(&mut self, question_id: &str, is_correct: bool) {
        let attempt = self
            .questions_answered
            .entry(question_id.to_string())
            .or_insert_with(|| QuestionAttempt::new(question_id));
        
        attempt.record(is_correct);
    }

    /// Calculate the current score (percentage correct)
    pub fn calculate_score(&self) -> f64 {
        if self.questions_answered.is_empty() {
            return 0.0;
        }

        let correct = self
            .questions_answered
            .values()
            .filter(|a| a.is_mastered())
            .count();

        (correct as f64 / self.questions_answered.len() as f64) * 100.0
    }

    /// Mark the lesson as completed
    pub fn mark_completed(&mut self) {
        self.is_completed = true;
        self.practice_count += 1;
        self.last_score = self.calculate_score();
        if self.last_score > self.best_score {
            self.best_score = self.last_score;
        }
    }

    /// Get the number of questions mastered
    pub fn questions_mastered(&self) -> usize {
        self.questions_answered.values().filter(|a| a.is_mastered()).count()
    }

    /// Add time spent on this lesson
    pub fn add_time(&mut self, minutes: u64) {
        self.time_spent_minutes += minutes;
    }
}

/// An attempt at answering a question
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuestionAttempt {
    /// Question identifier
    pub question_id: String,
    /// Total attempts
    pub total_attempts: u32,
    /// Correct attempts
    pub correct_attempts: u32,
    /// Last attempt was correct
    pub last_correct: bool,
    /// Consecutive correct answers (for mastery)
    pub consecutive_correct: u32,
}

impl QuestionAttempt {
    /// Create a new question attempt
    pub fn new(question_id: impl Into<String>) -> Self {
        Self {
            question_id: question_id.into(),
            total_attempts: 0,
            correct_attempts: 0,
            last_correct: false,
            consecutive_correct: 0,
        }
    }

    /// Record an attempt
    pub fn record(&mut self, is_correct: bool) {
        self.total_attempts += 1;
        self.last_correct = is_correct;
        
        if is_correct {
            self.correct_attempts += 1;
            self.consecutive_correct += 1;
        } else {
            self.consecutive_correct = 0;
        }
    }

    /// Check if the question is mastered (3 consecutive correct answers)
    pub fn is_mastered(&self) -> bool {
        self.consecutive_correct >= 3
    }

    /// Get the accuracy percentage
    pub fn accuracy(&self) -> f64 {
        if self.total_attempts == 0 {
            0.0
        } else {
            (self.correct_attempts as f64 / self.total_attempts as f64) * 100.0
        }
    }
}

/// Statistics summary for the user
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgressSummary {
    /// Current level display
    pub current_level: String,
    /// Overall accuracy percentage
    pub accuracy: f64,
    /// Daily streak
    pub streak: u32,
    /// Total lessons completed
    pub lessons_completed: usize,
    /// Total practice time (formatted)
    pub practice_time: String,
    /// Words learned estimate
    pub words_learned: usize,
}

impl ProgressSummary {
    /// Generate a summary from user progress
    pub fn from_progress(progress: &UserProgress) -> Self {
        let lessons_completed = progress
            .lesson_progress
            .values()
            .filter(|p| p.is_completed)
            .count();

        let words_learned = progress
            .lesson_progress
            .values()
            .map(|p| p.questions_mastered())
            .sum();

        let hours = progress.total_practice_minutes / 60;
        let minutes = progress.total_practice_minutes % 60;
        let practice_time = if hours > 0 {
            format!("{}h {}m", hours, minutes)
        } else {
            format!("{}m", minutes)
        };

        Self {
            current_level: progress.current_level_code(),
            accuracy: progress.accuracy_percentage(),
            streak: progress.daily_streak,
            lessons_completed,
            practice_time,
            words_learned,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_progress_creation() {
        let progress = UserProgress::new("user-1", Dialect::European);
        assert_eq!(progress.user_id, "user-1");
        assert_eq!(progress.dialect, Dialect::European);
        assert_eq!(progress.current_level, CEFRLevel::A1);
        assert_eq!(progress.current_sub_level, 1);
        assert!(progress.dark_mode); // Default is dark mode
    }

    #[test]
    fn test_current_level_code() {
        let progress = UserProgress::new("user-1", Dialect::European);
        assert_eq!(progress.current_level_code(), "A1.1");
    }

    #[test]
    fn test_record_answer() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        progress.record_answer("lesson-1", "q1", true);
        progress.record_answer("lesson-1", "q2", false);

        assert_eq!(progress.total_questions_answered, 2);
        assert_eq!(progress.total_correct_answers, 1);
    }

    #[test]
    fn test_accuracy_percentage() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        progress.record_answer("lesson-1", "q1", true);
        progress.record_answer("lesson-1", "q2", true);
        progress.record_answer("lesson-1", "q3", false);
        progress.record_answer("lesson-1", "q4", true);

        assert!((progress.accuracy_percentage() - 75.0).abs() < 0.01);
    }

    #[test]
    fn test_advance_sub_level() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        assert_eq!(progress.current_level_code(), "A1.1");

        progress.advance_sub_level();
        assert_eq!(progress.current_level_code(), "A1.2");

        progress.advance_sub_level();
        assert_eq!(progress.current_level_code(), "A1.3");

        // After 3 sub-levels, advance to next CEFR level
        progress.advance_sub_level();
        assert_eq!(progress.current_level_code(), "A2.1");
    }

    #[test]
    fn test_challenge_out() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        assert!(!progress.has_challenged_out("A1.1"));

        progress.challenge_out("A1.1");
        assert!(progress.has_challenged_out("A1.1"));

        // Duplicate challenge out should not add again
        progress.challenge_out("A1.1");
        assert_eq!(progress.challenged_out_levels.len(), 1);
    }

    #[test]
    fn test_lesson_progress() {
        let mut lesson_progress = LessonProgress::new("lesson-1");
        lesson_progress.record_answer("q1", true);
        lesson_progress.record_answer("q1", true);
        lesson_progress.record_answer("q1", true);

        assert!(lesson_progress.questions_answered.get("q1").unwrap().is_mastered());
    }

    #[test]
    fn test_question_attempt_mastery() {
        let mut attempt = QuestionAttempt::new("q1");
        assert!(!attempt.is_mastered());

        attempt.record(true);
        attempt.record(true);
        assert!(!attempt.is_mastered());

        attempt.record(true);
        assert!(attempt.is_mastered());
    }

    #[test]
    fn test_question_attempt_streak_reset() {
        let mut attempt = QuestionAttempt::new("q1");
        attempt.record(true);
        attempt.record(true);
        attempt.record(false); // Reset streak
        assert!(!attempt.is_mastered());
        assert_eq!(attempt.consecutive_correct, 0);
    }

    #[test]
    fn test_progress_summary() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        progress.record_answer("lesson-1", "q1", true);
        progress.total_practice_minutes = 125; // 2h 5m

        let summary = ProgressSummary::from_progress(&progress);
        assert_eq!(summary.current_level, "A1.1");
        assert_eq!(summary.practice_time, "2h 5m");
    }

    #[test]
    fn test_toggle_dark_mode() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        assert!(progress.dark_mode);

        progress.toggle_dark_mode();
        assert!(!progress.dark_mode);

        progress.toggle_dark_mode();
        assert!(progress.dark_mode);
    }

    #[test]
    fn test_typing_mode_preference() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        assert_eq!(progress.typing_mode, TypingMode::Lenient);

        progress.set_typing_mode(TypingMode::Strict);
        assert_eq!(progress.typing_mode, TypingMode::Strict);
    }

    #[test]
    fn test_is_consecutive_day() {
        // Normal consecutive days
        assert!(is_consecutive_day("2025-01-01", "2025-01-02"));
        assert!(is_consecutive_day("2025-01-15", "2025-01-16"));
        
        // Month boundary
        assert!(is_consecutive_day("2025-01-31", "2025-02-01"));
        assert!(is_consecutive_day("2025-03-31", "2025-04-01"));
        
        // Year boundary
        assert!(is_consecutive_day("2024-12-31", "2025-01-01"));
        
        // Leap year
        assert!(is_consecutive_day("2024-02-28", "2024-02-29"));
        assert!(is_consecutive_day("2024-02-29", "2024-03-01"));
        
        // Non-leap year
        assert!(is_consecutive_day("2025-02-28", "2025-03-01"));
        
        // Non-consecutive days
        assert!(!is_consecutive_day("2025-01-01", "2025-01-03"));
        assert!(!is_consecutive_day("2025-01-01", "2025-02-01"));
        assert!(!is_consecutive_day("2025-01-15", "2025-01-15")); // Same day
    }

    #[test]
    fn test_streak_consecutive_days() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        
        // First day
        progress.update_streak("2025-01-01");
        assert_eq!(progress.daily_streak, 1);
        
        // Consecutive day
        progress.update_streak("2025-01-02");
        assert_eq!(progress.daily_streak, 2);
        
        // Another consecutive day
        progress.update_streak("2025-01-03");
        assert_eq!(progress.daily_streak, 3);
    }

    #[test]
    fn test_streak_same_day() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        
        progress.update_streak("2025-01-01");
        assert_eq!(progress.daily_streak, 1);
        
        // Same day should not change streak
        progress.update_streak("2025-01-01");
        assert_eq!(progress.daily_streak, 1);
    }

    #[test]
    fn test_streak_broken() {
        let mut progress = UserProgress::new("user-1", Dialect::European);
        
        progress.update_streak("2025-01-01");
        progress.update_streak("2025-01-02");
        assert_eq!(progress.daily_streak, 2);
        
        // Skip a day - streak should reset
        progress.update_streak("2025-01-04");
        assert_eq!(progress.daily_streak, 1);
    }
}
