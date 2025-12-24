//! SRS Card model for spaced repetition learning

use serde::{Deserialize, Serialize};

/// An SRS card representing a vocabulary item to be reviewed
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct SRSCard {
    /// Unique identifier for this card
    pub word_id: String,
    /// Word in the source language
    pub source_word: String,
    /// Word in the target language
    pub target_word: String,
    /// Language pair code (e.g., "en_to_pt_br")
    pub language_pair: String,
    /// CEFR level (A1-C2)
    pub level: String,
    /// ID of the lesson this word came from
    pub lesson_id: String,
    /// Optional pronunciation guide
    pub pronunciation: Option<String>,
    /// Optional example sentence
    pub example_sentence: Option<String>,

    // SM-2 Algorithm fields
    /// Ease factor (starts at 2.5, minimum 1.3)
    pub ease_factor: f32,
    /// Interval in days until next review
    pub interval: u32,
    /// Number of successful consecutive reviews
    pub repetitions: u32,
    /// ISO date string for next scheduled review
    pub next_review_date: String,
    /// ISO date string of last review (if any)
    pub last_reviewed: Option<String>,

    // Performance tracking
    /// Total number of times this card was reviewed
    pub total_reviews: u32,
    /// Number of correct reviews
    pub correct_reviews: u32,
    /// Quality rating from last review (0-5)
    pub last_quality: Option<u8>,
    /// ISO date string when card was created
    pub created_at: String,
}

impl SRSCard {
    /// Create a new SRS card with default SM-2 values
    pub fn new(
        word_id: String,
        source_word: String,
        target_word: String,
        language_pair: String,
        level: String,
        lesson_id: String,
        current_date: &str,
    ) -> Self {
        Self {
            word_id,
            source_word,
            target_word,
            language_pair,
            level,
            lesson_id,
            pronunciation: None,
            example_sentence: None,
            ease_factor: 2.5,
            interval: 0,
            repetitions: 0,
            next_review_date: current_date.to_string(),
            last_reviewed: None,
            total_reviews: 0,
            correct_reviews: 0,
            last_quality: None,
            created_at: current_date.to_string(),
        }
    }

    /// Create a new card with pronunciation and example
    #[allow(clippy::too_many_arguments)]
    pub fn with_details(
        word_id: String,
        source_word: String,
        target_word: String,
        language_pair: String,
        level: String,
        lesson_id: String,
        pronunciation: Option<String>,
        example_sentence: Option<String>,
        current_date: &str,
    ) -> Self {
        let mut card = Self::new(
            word_id,
            source_word,
            target_word,
            language_pair,
            level,
            lesson_id,
            current_date,
        );
        card.pronunciation = pronunciation;
        card.example_sentence = example_sentence;
        card
    }

    /// Check if this card is due for review
    pub fn is_due(&self, current_date: &str) -> bool {
        self.next_review_date.as_str() <= current_date
    }

    /// Calculate accuracy rate as a percentage
    pub fn accuracy_rate(&self) -> f32 {
        if self.total_reviews == 0 {
            0.0
        } else {
            (self.correct_reviews as f32 / self.total_reviews as f32) * 100.0
        }
    }

    /// Check if this card is considered "weak" (low ease factor or accuracy)
    pub fn is_weak(&self, ease_threshold: f32, accuracy_threshold: f32) -> bool {
        self.ease_factor < ease_threshold || self.accuracy_rate() < accuracy_threshold
    }

    /// Get mastery level based on repetitions and ease factor
    pub fn mastery_level(&self) -> MasteryLevel {
        match (self.repetitions, self.ease_factor) {
            (0, _) => MasteryLevel::New,
            (1..=2, _) => MasteryLevel::Learning,
            (3..=5, ef) if ef >= 2.0 => MasteryLevel::Familiar,
            (6..=10, ef) if ef >= 2.2 => MasteryLevel::Proficient,
            (r, ef) if r > 10 && ef >= 2.4 => MasteryLevel::Mastered,
            _ => MasteryLevel::Learning,
        }
    }
}

/// Mastery levels for vocabulary items
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum MasteryLevel {
    /// Card has never been reviewed
    New,
    /// Card is in the learning phase (1-2 successful reviews)
    Learning,
    /// Card is becoming familiar (3-5 successful reviews)
    Familiar,
    /// Card is well-known (6-10 successful reviews)
    Proficient,
    /// Card is fully mastered (10+ successful reviews with high ease)
    Mastered,
}

impl MasteryLevel {
    /// Get display name for mastery level
    pub fn display_name(&self) -> &'static str {
        match self {
            MasteryLevel::New => "New",
            MasteryLevel::Learning => "Learning",
            MasteryLevel::Familiar => "Familiar",
            MasteryLevel::Proficient => "Proficient",
            MasteryLevel::Mastered => "Mastered",
        }
    }

    /// Get color for mastery level (hex code)
    pub fn color(&self) -> &'static str {
        match self {
            MasteryLevel::New => "#9E9E9E",        // Grey
            MasteryLevel::Learning => "#FF9800",   // Orange
            MasteryLevel::Familiar => "#FFEB3B",   // Yellow
            MasteryLevel::Proficient => "#8BC34A", // Light Green
            MasteryLevel::Mastered => "#4CAF50",   // Green
        }
    }
}

/// Statistics for a collection of SRS cards
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SRSCardStats {
    pub total_cards: usize,
    pub due_today: usize,
    pub new_cards: usize,
    pub learning_cards: usize,
    pub familiar_cards: usize,
    pub proficient_cards: usize,
    pub mastered_cards: usize,
    pub average_ease_factor: f32,
    pub average_accuracy: f32,
}

impl SRSCardStats {
    /// Calculate statistics from a collection of cards
    pub fn from_cards(cards: &[SRSCard], current_date: &str) -> Self {
        let total_cards = cards.len();
        if total_cards == 0 {
            return Self {
                total_cards: 0,
                due_today: 0,
                new_cards: 0,
                learning_cards: 0,
                familiar_cards: 0,
                proficient_cards: 0,
                mastered_cards: 0,
                average_ease_factor: 0.0,
                average_accuracy: 0.0,
            };
        }

        let due_today = cards.iter().filter(|c| c.is_due(current_date)).count();
        let new_cards = cards
            .iter()
            .filter(|c| c.mastery_level() == MasteryLevel::New)
            .count();
        let learning_cards = cards
            .iter()
            .filter(|c| c.mastery_level() == MasteryLevel::Learning)
            .count();
        let familiar_cards = cards
            .iter()
            .filter(|c| c.mastery_level() == MasteryLevel::Familiar)
            .count();
        let proficient_cards = cards
            .iter()
            .filter(|c| c.mastery_level() == MasteryLevel::Proficient)
            .count();
        let mastered_cards = cards
            .iter()
            .filter(|c| c.mastery_level() == MasteryLevel::Mastered)
            .count();

        let total_ease: f32 = cards.iter().map(|c| c.ease_factor).sum();
        let average_ease_factor = total_ease / total_cards as f32;

        let cards_with_reviews: Vec<_> = cards.iter().filter(|c| c.total_reviews > 0).collect();
        let average_accuracy = if cards_with_reviews.is_empty() {
            0.0
        } else {
            cards_with_reviews
                .iter()
                .map(|c| c.accuracy_rate())
                .sum::<f32>()
                / cards_with_reviews.len() as f32
        };

        Self {
            total_cards,
            due_today,
            new_cards,
            learning_cards,
            familiar_cards,
            proficient_cards,
            mastered_cards,
            average_ease_factor,
            average_accuracy,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_card() {
        let card = SRSCard::new(
            "vocab_001".to_string(),
            "hello".to_string(),
            "olá".to_string(),
            "en_to_pt_br".to_string(),
            "A1".to_string(),
            "greetings".to_string(),
            "2024-01-15",
        );

        assert_eq!(card.ease_factor, 2.5);
        assert_eq!(card.interval, 0);
        assert_eq!(card.repetitions, 0);
        assert!(card.is_due("2024-01-15"));
        assert_eq!(card.mastery_level(), MasteryLevel::New);
    }

    #[test]
    fn test_accuracy_rate() {
        let mut card = SRSCard::new(
            "vocab_001".to_string(),
            "hello".to_string(),
            "olá".to_string(),
            "en_to_pt_br".to_string(),
            "A1".to_string(),
            "greetings".to_string(),
            "2024-01-15",
        );

        assert_eq!(card.accuracy_rate(), 0.0);

        card.total_reviews = 10;
        card.correct_reviews = 8;
        assert_eq!(card.accuracy_rate(), 80.0);
    }

    #[test]
    fn test_is_weak() {
        let mut card = SRSCard::new(
            "vocab_001".to_string(),
            "hello".to_string(),
            "olá".to_string(),
            "en_to_pt_br".to_string(),
            "A1".to_string(),
            "greetings".to_string(),
            "2024-01-15",
        );

        card.ease_factor = 1.5;
        assert!(card.is_weak(2.0, 60.0));

        card.ease_factor = 2.5;
        card.total_reviews = 10;
        card.correct_reviews = 5;
        assert!(card.is_weak(2.0, 60.0));
    }
}
