//! SM-2 Spaced Repetition Scheduler
//!
//! Implements the SuperMemo 2 algorithm for calculating review intervals.

use super::card::SRSCard;
use serde::{Deserialize, Serialize};

/// Quality ratings for reviews (0-5 scale)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ReviewQuality {
    /// Complete blackout - no recall at all
    Blackout = 0,
    /// Incorrect response but recognized correct answer
    Incorrect = 1,
    /// Incorrect response but correct answer seemed easy to recall
    IncorrectEasy = 2,
    /// Correct response with serious difficulty
    CorrectDifficult = 3,
    /// Correct response after hesitation
    CorrectHesitation = 4,
    /// Perfect response with no hesitation
    Perfect = 5,
}

impl ReviewQuality {
    /// Convert from u8 value
    pub fn from_u8(value: u8) -> Option<Self> {
        match value {
            0 => Some(ReviewQuality::Blackout),
            1 => Some(ReviewQuality::Incorrect),
            2 => Some(ReviewQuality::IncorrectEasy),
            3 => Some(ReviewQuality::CorrectDifficult),
            4 => Some(ReviewQuality::CorrectHesitation),
            5 => Some(ReviewQuality::Perfect),
            _ => None,
        }
    }

    /// Check if this quality indicates a successful recall
    pub fn is_successful(&self) -> bool {
        (*self as u8) >= 3
    }

    /// Get display name for this quality
    pub fn display_name(&self) -> &'static str {
        match self {
            ReviewQuality::Blackout => "Forgot",
            ReviewQuality::Incorrect => "Wrong",
            ReviewQuality::IncorrectEasy => "Almost",
            ReviewQuality::CorrectDifficult => "Hard",
            ReviewQuality::CorrectHesitation => "Good",
            ReviewQuality::Perfect => "Easy",
        }
    }
}

/// Result of calculating next review schedule
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SRSUpdate {
    /// New ease factor (1.3 - 2.5)
    pub new_ease_factor: f32,
    /// New interval in days
    pub new_interval: u32,
    /// Updated repetition count
    pub new_repetitions: u32,
    /// Next review date (ISO format)
    pub next_review_date: String,
    /// Quality rating used for this update
    pub quality: u8,
    /// Whether this was a successful review
    pub was_successful: bool,
}

/// SM-2 Spaced Repetition Scheduler
pub struct SRSScheduler;

impl SRSScheduler {
    /// Calculate the next review schedule based on SM-2 algorithm
    ///
    /// # Arguments
    /// * `card` - The SRS card being reviewed
    /// * `quality` - Quality rating (0-5)
    /// * `current_date` - Current date in ISO format (YYYY-MM-DD)
    ///
    /// # Returns
    /// An SRSUpdate with the new scheduling parameters
    pub fn calculate_next_review(card: &SRSCard, quality: u8, current_date: &str) -> SRSUpdate {
        let quality = quality.min(5); // Clamp to valid range
        let was_successful = quality >= 3;

        let (new_ease_factor, new_interval, new_repetitions) = if was_successful {
            // Successful recall - advance the card
            let new_reps = card.repetitions + 1;

            // Calculate new interval based on repetition count
            let new_interval = match new_reps {
                1 => 1, // First success: review tomorrow
                2 => 6, // Second success: review in 6 days
                _ => {
                    // Subsequent successes: multiply previous interval by ease factor
                    ((card.interval as f32) * card.ease_factor).round() as u32
                }
            };

            // Update ease factor using SM-2 formula
            let new_ease = card.ease_factor
                + (0.1 - (5 - quality) as f32 * (0.08 + (5 - quality) as f32 * 0.02));
            let new_ease = new_ease.clamp(1.3, 2.5);

            (new_ease, new_interval, new_reps)
        } else {
            // Failed recall - reset the card
            // Keep the ease factor but reduce it slightly
            let new_ease = (card.ease_factor - 0.2).max(1.3);
            (new_ease, 1, 0) // Reset to review tomorrow
        };

        // Calculate next review date
        let next_review_date = Self::add_days_to_date(current_date, new_interval);

        SRSUpdate {
            new_ease_factor,
            new_interval,
            new_repetitions,
            next_review_date,
            quality,
            was_successful,
        }
    }

    /// Apply an SRS update to a card
    pub fn apply_update(card: &mut SRSCard, update: &SRSUpdate, current_date: &str) {
        card.ease_factor = update.new_ease_factor;
        card.interval = update.new_interval;
        card.repetitions = update.new_repetitions;
        card.next_review_date = update.next_review_date.clone();
        card.last_reviewed = Some(current_date.to_string());
        card.last_quality = Some(update.quality);
        card.total_reviews += 1;
        if update.was_successful {
            card.correct_reviews += 1;
        }
    }

    /// Get all cards that are due for review
    pub fn get_due_cards<'a>(cards: &'a [SRSCard], current_date: &str) -> Vec<&'a SRSCard> {
        cards.iter().filter(|c| c.is_due(current_date)).collect()
    }

    /// Get cards that are considered weak (low ease factor or accuracy)
    pub fn get_weak_cards(
        cards: &[SRSCard],
        ease_threshold: f32,
        accuracy_threshold: f32,
    ) -> Vec<&SRSCard> {
        cards
            .iter()
            .filter(|c| c.is_weak(ease_threshold, accuracy_threshold))
            .collect()
    }

    /// Get new cards that haven't been reviewed yet
    pub fn get_new_cards(cards: &[SRSCard]) -> Vec<&SRSCard> {
        cards.iter().filter(|c| c.total_reviews == 0).collect()
    }

    /// Sort cards by priority for review (due first, then by ease factor)
    pub fn sort_by_priority(cards: &mut [SRSCard], current_date: &str) {
        cards.sort_by(|a, b| {
            // Due cards come first
            let a_due = a.is_due(current_date);
            let b_due = b.is_due(current_date);
            if a_due != b_due {
                return b_due.cmp(&a_due);
            }

            // Among due cards, lower ease factor = harder = review first
            a.ease_factor
                .partial_cmp(&b.ease_factor)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
    }

    /// Add days to a date string (simple implementation)
    fn add_days_to_date(date: &str, days: u32) -> String {
        // Parse the date (assuming YYYY-MM-DD format)
        let parts: Vec<&str> = date.split('-').collect();
        if parts.len() != 3 {
            return date.to_string();
        }

        let year: i32 = parts[0].parse().unwrap_or(2024);
        let month: u32 = parts[1].parse().unwrap_or(1);
        let day: u32 = parts[2].parse().unwrap_or(1);

        // Simple date addition (not accounting for all edge cases perfectly)
        let days_in_month = |y: i32, m: u32| -> u32 {
            match m {
                1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
                4 | 6 | 9 | 11 => 30,
                2 => {
                    if (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0) {
                        29
                    } else {
                        28
                    }
                }
                _ => 30,
            }
        };

        let mut new_day = day + days;
        let mut new_month = month;
        let mut new_year = year;

        while new_day > days_in_month(new_year, new_month) {
            new_day -= days_in_month(new_year, new_month);
            new_month += 1;
            if new_month > 12 {
                new_month = 1;
                new_year += 1;
            }
        }

        format!("{:04}-{:02}-{:02}", new_year, new_month, new_day)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_card() -> SRSCard {
        SRSCard::new(
            "vocab_001".to_string(),
            "hello".to_string(),
            "olá".to_string(),
            "en_to_pt_br".to_string(),
            "A1".to_string(),
            "greetings".to_string(),
            "2024-01-15",
        )
    }

    #[test]
    fn test_first_successful_review() {
        let card = create_test_card();
        let update = SRSScheduler::calculate_next_review(&card, 4, "2024-01-15");

        assert!(update.was_successful);
        assert_eq!(update.new_interval, 1);
        assert_eq!(update.new_repetitions, 1);
        assert_eq!(update.next_review_date, "2024-01-16");
    }

    #[test]
    fn test_second_successful_review() {
        let mut card = create_test_card();
        card.repetitions = 1;
        card.interval = 1;

        let update = SRSScheduler::calculate_next_review(&card, 4, "2024-01-16");

        assert!(update.was_successful);
        assert_eq!(update.new_interval, 6);
        assert_eq!(update.new_repetitions, 2);
    }

    #[test]
    fn test_failed_review_resets() {
        let mut card = create_test_card();
        card.repetitions = 5;
        card.interval = 30;
        card.ease_factor = 2.5;

        let update = SRSScheduler::calculate_next_review(&card, 1, "2024-02-15");

        assert!(!update.was_successful);
        assert_eq!(update.new_interval, 1);
        assert_eq!(update.new_repetitions, 0);
        assert!(update.new_ease_factor < 2.5);
    }

    #[test]
    fn test_ease_factor_clamping() {
        let mut card = create_test_card();
        card.ease_factor = 1.3; // Already at minimum

        let update = SRSScheduler::calculate_next_review(&card, 0, "2024-01-15");
        assert!(update.new_ease_factor >= 1.3);
    }

    #[test]
    fn test_perfect_review_increases_ease() {
        let card = create_test_card();
        let update = SRSScheduler::calculate_next_review(&card, 5, "2024-01-15");

        assert!(update.new_ease_factor >= card.ease_factor);
    }

    #[test]
    fn test_add_days_to_date() {
        assert_eq!(
            SRSScheduler::add_days_to_date("2024-01-15", 1),
            "2024-01-16"
        );
        assert_eq!(
            SRSScheduler::add_days_to_date("2024-01-31", 1),
            "2024-02-01"
        );
        assert_eq!(
            SRSScheduler::add_days_to_date("2024-12-31", 1),
            "2025-01-01"
        );
    }
}
