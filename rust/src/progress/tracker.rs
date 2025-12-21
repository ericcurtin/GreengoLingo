use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};

use crate::models::{CEFRLevel, LanguagePair};

/// Tracks user progress across lessons and language pairs
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgressTracker {
    /// Completed lessons per language pair
    completed_lessons: HashMap<String, HashSet<String>>,
    /// Best scores per lesson (percentage, 0-100)
    lesson_scores: HashMap<String, u32>,
    /// Number of attempts per lesson
    lesson_attempts: HashMap<String, u32>,
    /// Active language pair
    active_language_pair: Option<LanguagePair>,
    /// Preferred CEFR level
    preferred_level: CEFRLevel,
}

impl ProgressTracker {
    /// Create a new progress tracker
    pub fn new() -> Self {
        Self {
            completed_lessons: HashMap::new(),
            lesson_scores: HashMap::new(),
            lesson_attempts: HashMap::new(),
            active_language_pair: None,
            preferred_level: CEFRLevel::A1,
        }
    }

    /// Set the active language pair
    pub fn set_active_language_pair(&mut self, pair: LanguagePair) {
        self.active_language_pair = Some(pair);
    }

    /// Get the active language pair
    pub fn active_language_pair(&self) -> Option<&LanguagePair> {
        self.active_language_pair.as_ref()
    }

    /// Set the preferred level
    pub fn set_preferred_level(&mut self, level: CEFRLevel) {
        self.preferred_level = level;
    }

    /// Get the preferred level
    pub fn preferred_level(&self) -> CEFRLevel {
        self.preferred_level
    }

    /// Record a lesson completion
    pub fn record_lesson_completion(
        &mut self,
        pair: &LanguagePair,
        lesson_id: &str,
        score_percent: u32,
    ) -> LessonCompletionResult {
        let pair_key = pair.content_dir();
        let lesson_key = format!("{}:{}", pair_key, lesson_id);

        // Track completion
        let completed_set = self.completed_lessons.entry(pair_key.clone()).or_default();
        let was_new = completed_set.insert(lesson_id.to_string());

        // Track attempts
        let attempts = self.lesson_attempts.entry(lesson_key.clone()).or_insert(0);
        *attempts += 1;

        // Track best score
        let best_score = self.lesson_scores.entry(lesson_key).or_insert(0);
        let improved = score_percent > *best_score;
        if improved {
            *best_score = score_percent;
        }

        LessonCompletionResult {
            first_completion: was_new,
            score_percent,
            is_perfect: score_percent == 100,
            improved_score: improved,
            attempt_number: *attempts,
        }
    }

    /// Check if a lesson is completed
    pub fn is_lesson_completed(&self, pair: &LanguagePair, lesson_id: &str) -> bool {
        let pair_key = pair.content_dir();
        self.completed_lessons
            .get(&pair_key)
            .is_some_and(|set| set.contains(lesson_id))
    }

    /// Get the best score for a lesson (0-100, or None if never attempted)
    pub fn lesson_score(&self, pair: &LanguagePair, lesson_id: &str) -> Option<u32> {
        let key = format!("{}:{}", pair.content_dir(), lesson_id);
        self.lesson_scores.get(&key).copied()
    }

    /// Get the number of attempts for a lesson
    pub fn lesson_attempts(&self, pair: &LanguagePair, lesson_id: &str) -> u32 {
        let key = format!("{}:{}", pair.content_dir(), lesson_id);
        self.lesson_attempts.get(&key).copied().unwrap_or(0)
    }

    /// Get count of completed lessons for a language pair
    pub fn completed_count(&self, pair: &LanguagePair) -> usize {
        let pair_key = pair.content_dir();
        self.completed_lessons
            .get(&pair_key)
            .map_or(0, |set| set.len())
    }

    /// Get all completed lesson IDs for a language pair
    pub fn completed_lessons(&self, pair: &LanguagePair) -> Vec<String> {
        let pair_key = pair.content_dir();
        self.completed_lessons
            .get(&pair_key)
            .map_or(Vec::new(), |set| set.iter().cloned().collect())
    }

    /// Get progress statistics for a language pair
    pub fn get_progress_stats(&self, pair: &LanguagePair, total_lessons: usize) -> ProgressStats {
        let completed = self.completed_count(pair);
        let pair_key = pair.content_dir();

        // Calculate average score
        let scores: Vec<u32> = self
            .lesson_scores
            .iter()
            .filter(|(k, _)| k.starts_with(&pair_key))
            .map(|(_, v)| *v)
            .collect();

        let average_score = if scores.is_empty() {
            0.0
        } else {
            scores.iter().sum::<u32>() as f32 / scores.len() as f32
        };

        // Count perfect scores
        let perfect_count = scores.iter().filter(|&&s| s == 100).count();

        ProgressStats {
            completed_lessons: completed,
            total_lessons,
            completion_percent: if total_lessons > 0 {
                (completed as f32 / total_lessons as f32 * 100.0).round() as u32
            } else {
                0
            },
            average_score,
            perfect_lessons: perfect_count,
        }
    }

    /// Get all language pairs that have been started
    pub fn started_language_pairs(&self) -> Vec<String> {
        self.completed_lessons.keys().cloned().collect()
    }

    /// Reset progress for a specific language pair
    pub fn reset_pair_progress(&mut self, pair: &LanguagePair) {
        let pair_key = pair.content_dir();
        self.completed_lessons.remove(&pair_key);

        // Remove lesson scores and attempts for this pair
        self.lesson_scores.retain(|k, _| !k.starts_with(&pair_key));
        self.lesson_attempts
            .retain(|k, _| !k.starts_with(&pair_key));
    }

    /// Reset all progress
    pub fn reset_all(&mut self) {
        self.completed_lessons.clear();
        self.lesson_scores.clear();
        self.lesson_attempts.clear();
    }
}

impl Default for ProgressTracker {
    fn default() -> Self {
        Self::new()
    }
}

/// Result of completing a lesson
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LessonCompletionResult {
    /// Whether this was the first time completing this lesson
    pub first_completion: bool,
    /// Score achieved (0-100)
    pub score_percent: u32,
    /// Whether it was a perfect score
    pub is_perfect: bool,
    /// Whether the score improved from previous best
    pub improved_score: bool,
    /// Which attempt number this was
    pub attempt_number: u32,
}

/// Progress statistics for a language pair
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgressStats {
    /// Number of completed lessons
    pub completed_lessons: usize,
    /// Total lessons available
    pub total_lessons: usize,
    /// Completion percentage (0-100)
    pub completion_percent: u32,
    /// Average score across all attempted lessons
    pub average_score: f32,
    /// Number of lessons with perfect scores
    pub perfect_lessons: usize,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::Dialect;

    fn test_pair() -> LanguagePair {
        LanguagePair::new(Dialect::EnglishUS, Dialect::PortugueseEuropean)
    }

    #[test]
    fn test_lesson_completion() {
        let mut tracker = ProgressTracker::new();
        let pair = test_pair();

        let result = tracker.record_lesson_completion(&pair, "lesson_01", 85);

        assert!(result.first_completion);
        assert_eq!(result.score_percent, 85);
        assert!(!result.is_perfect);
        assert_eq!(result.attempt_number, 1);
    }

    #[test]
    fn test_improved_score() {
        let mut tracker = ProgressTracker::new();
        let pair = test_pair();

        tracker.record_lesson_completion(&pair, "lesson_01", 70);
        let result = tracker.record_lesson_completion(&pair, "lesson_01", 90);

        assert!(!result.first_completion);
        assert!(result.improved_score);
        assert_eq!(result.attempt_number, 2);
        assert_eq!(tracker.lesson_score(&pair, "lesson_01"), Some(90));
    }

    #[test]
    fn test_progress_stats() {
        let mut tracker = ProgressTracker::new();
        let pair = test_pair();

        tracker.record_lesson_completion(&pair, "lesson_01", 100);
        tracker.record_lesson_completion(&pair, "lesson_02", 80);

        let stats = tracker.get_progress_stats(&pair, 10);

        assert_eq!(stats.completed_lessons, 2);
        assert_eq!(stats.total_lessons, 10);
        assert_eq!(stats.completion_percent, 20);
        assert_eq!(stats.perfect_lessons, 1);
    }
}
