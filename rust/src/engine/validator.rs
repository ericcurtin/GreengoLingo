use unicode_normalization::UnicodeNormalization;

use crate::models::{Question, TypingMode};

/// Result of validating an answer
#[derive(Debug, Clone, PartialEq)]
pub struct ValidationResult {
    /// Whether the answer is correct
    pub is_correct: bool,
    /// The correct answer(s) for display
    pub correct_answer: String,
    /// Optional explanation
    pub explanation: Option<String>,
    /// For partial credit scenarios (0.0 to 1.0)
    pub score: f32,
}

impl ValidationResult {
    /// Create a correct result
    pub fn correct(correct_answer: String, explanation: Option<String>) -> Self {
        Self {
            is_correct: true,
            correct_answer,
            explanation,
            score: 1.0,
        }
    }

    /// Create an incorrect result
    pub fn incorrect(correct_answer: String, explanation: Option<String>) -> Self {
        Self {
            is_correct: false,
            correct_answer,
            explanation,
            score: 0.0,
        }
    }
}

/// Validates answers for different question types
pub struct AnswerValidator {
    /// Typing mode for text comparisons
    typing_mode: TypingMode,
}

impl AnswerValidator {
    /// Create a new validator with specified typing mode
    pub fn new(typing_mode: TypingMode) -> Self {
        Self { typing_mode }
    }

    /// Validate an answer for a question
    pub fn validate(&self, question: &Question, answer: &Answer) -> ValidationResult {
        match (question, answer) {
            (
                Question::MultipleChoice {
                    options,
                    correct_index,
                    explanation,
                    ..
                },
                Answer::MultipleChoice { selected_index },
            ) => {
                let is_correct = *selected_index == *correct_index;
                let correct_answer = options.get(*correct_index).cloned().unwrap_or_default();

                if is_correct {
                    ValidationResult::correct(correct_answer, explanation.clone())
                } else {
                    ValidationResult::incorrect(correct_answer, explanation.clone())
                }
            }

            (
                Question::Typing {
                    correct_answers,
                    accent_strict,
                    ..
                },
                Answer::Typing { text },
            ) => {
                let use_strict = *accent_strict || self.typing_mode == TypingMode::Strict;
                let is_correct = correct_answers
                    .iter()
                    .any(|correct| compare_text(text, correct, use_strict));

                let correct_answer = correct_answers.first().cloned().unwrap_or_default();

                if is_correct {
                    ValidationResult::correct(correct_answer, None)
                } else {
                    ValidationResult::incorrect(correct_answer, None)
                }
            }

            (Question::MatchingPairs { pairs, .. }, Answer::MatchingPairs { matches }) => {
                // Check if all matches are correct
                let total = pairs.len();
                let correct_count = pairs
                    .iter()
                    .filter(|(left, right)| matches.get(left) == Some(right))
                    .count();

                let score = if total > 0 {
                    correct_count as f32 / total as f32
                } else {
                    0.0
                };

                let correct_answer = pairs
                    .iter()
                    .map(|(l, r)| format!("{} = {}", l, r))
                    .collect::<Vec<_>>()
                    .join(", ");

                if correct_count == total {
                    ValidationResult::correct(correct_answer, None)
                } else {
                    ValidationResult {
                        is_correct: false,
                        correct_answer,
                        explanation: None,
                        score,
                    }
                }
            }

            (
                Question::SentenceBuilder {
                    words,
                    correct_order,
                    ..
                },
                Answer::SentenceBuilder { word_order },
            ) => {
                let is_correct = word_order == correct_order;
                let correct_sentence: String = correct_order
                    .iter()
                    .filter_map(|&i| words.get(i))
                    .cloned()
                    .collect::<Vec<_>>()
                    .join(" ");

                if is_correct {
                    ValidationResult::correct(correct_sentence, None)
                } else {
                    // Calculate partial score based on correct positions
                    let correct_positions = word_order
                        .iter()
                        .zip(correct_order.iter())
                        .filter(|(a, b)| a == b)
                        .count();
                    let score = if correct_order.is_empty() {
                        0.0
                    } else {
                        correct_positions as f32 / correct_order.len() as f32
                    };

                    ValidationResult {
                        is_correct: false,
                        correct_answer: correct_sentence,
                        explanation: None,
                        score,
                    }
                }
            }

            _ => ValidationResult::incorrect(
                "Invalid answer type".to_string(),
                Some("Answer type doesn't match question type".to_string()),
            ),
        }
    }
}

impl Default for AnswerValidator {
    fn default() -> Self {
        Self::new(TypingMode::Lenient)
    }
}

/// User's answer to a question
#[derive(Debug, Clone)]
pub enum Answer {
    /// Selected option index for multiple choice
    MultipleChoice { selected_index: usize },
    /// Text input for typing questions
    Typing { text: String },
    /// Matched pairs (left item -> right item)
    MatchingPairs {
        matches: std::collections::HashMap<String, String>,
    },
    /// Order of word indices for sentence building
    SentenceBuilder { word_order: Vec<usize> },
}

/// Compare two text strings with optional accent sensitivity
fn compare_text(input: &str, expected: &str, strict: bool) -> bool {
    let normalize = |s: &str| -> String {
        let trimmed = s.trim().to_lowercase();
        if strict {
            trimmed.nfc().collect()
        } else {
            // Remove diacritics for lenient comparison
            trimmed
                .nfd()
                .filter(|c| !c.is_ascii() || c.is_alphanumeric() || c.is_whitespace())
                .filter(|c| {
                    // Filter out combining diacritical marks
                    let cat = unicode_general_category::get_general_category(*c);
                    cat != unicode_general_category::GeneralCategory::NonspacingMark
                })
                .collect::<String>()
                .nfc()
                .collect()
        }
    };

    normalize(input) == normalize(expected)
}

/// Unicode general category lookup (simplified)
mod unicode_general_category {
    #[derive(Debug, Clone, Copy, PartialEq, Eq)]
    pub enum GeneralCategory {
        NonspacingMark,
        Other,
    }

    pub fn get_general_category(c: char) -> GeneralCategory {
        // Unicode combining diacritical marks range
        let code = c as u32;
        if (0x0300..=0x036F).contains(&code)
            || (0x1AB0..=0x1AFF).contains(&code)
            || (0x1DC0..=0x1DFF).contains(&code)
            || (0x20D0..=0x20FF).contains(&code)
            || (0xFE20..=0xFE2F).contains(&code)
        {
            GeneralCategory::NonspacingMark
        } else {
            GeneralCategory::Other
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_multiple_choice_correct() {
        let validator = AnswerValidator::default();
        let question = Question::multiple_choice(
            "What is 'Hello' in Portuguese?",
            vec!["Olá".into(), "Adeus".into(), "Obrigado".into()],
            0,
            Some("Olá means Hello".into()),
        );

        let answer = Answer::MultipleChoice { selected_index: 0 };
        let result = validator.validate(&question, &answer);

        assert!(result.is_correct);
        assert_eq!(result.correct_answer, "Olá");
    }

    #[test]
    fn test_multiple_choice_incorrect() {
        let validator = AnswerValidator::default();
        let question = Question::multiple_choice(
            "What is 'Hello'?",
            vec!["Olá".into(), "Adeus".into()],
            0,
            None,
        );

        let answer = Answer::MultipleChoice { selected_index: 1 };
        let result = validator.validate(&question, &answer);

        assert!(!result.is_correct);
    }

    #[test]
    fn test_typing_lenient() {
        let validator = AnswerValidator::new(TypingMode::Lenient);
        let question = Question::typing("Write 'coffee'", vec!["café".into()], None, false);

        let answer = Answer::Typing {
            text: "cafe".into(), // No accent
        };
        let result = validator.validate(&question, &answer);

        assert!(result.is_correct);
    }

    #[test]
    fn test_typing_strict() {
        let validator = AnswerValidator::new(TypingMode::Strict);
        let question = Question::typing("Write 'coffee'", vec!["café".into()], None, true);

        let answer = Answer::Typing {
            text: "cafe".into(),
        };
        let result = validator.validate(&question, &answer);

        assert!(!result.is_correct);
    }

    #[test]
    fn test_sentence_builder() {
        let validator = AnswerValidator::default();
        let question = Question::sentence_builder(
            "Build: I am happy",
            vec!["Eu".into(), "estou".into(), "feliz".into()],
            vec![0, 1, 2],
            vec![],
        );

        let answer = Answer::SentenceBuilder {
            word_order: vec![0, 1, 2],
        };
        let result = validator.validate(&question, &answer);

        assert!(result.is_correct);
        assert_eq!(result.correct_answer, "Eu estou feliz");
    }
}
