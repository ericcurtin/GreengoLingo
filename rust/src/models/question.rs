use serde::{Deserialize, Serialize};

/// Represents a question in a lesson
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Question {
    /// Multiple choice question with one correct answer
    MultipleChoice {
        /// The question prompt (in source language)
        prompt: String,
        /// The available answer options (in target language)
        options: Vec<String>,
        /// Index of the correct answer (0-based)
        correct_index: usize,
        /// Optional explanation shown after answering
        #[serde(skip_serializing_if = "Option::is_none")]
        explanation: Option<String>,
    },

    /// Free-form typing question
    Typing {
        /// The question prompt
        prompt: String,
        /// All accepted correct answers (for variations/synonyms)
        correct_answers: Vec<String>,
        /// Optional hint shown to help the user
        #[serde(skip_serializing_if = "Option::is_none")]
        hint: Option<String>,
        /// Whether to require exact accent marks
        #[serde(default)]
        accent_strict: bool,
    },

    /// Match pairs by dragging/selecting
    MatchingPairs {
        /// Instructions for the matching exercise
        prompt: String,
        /// Pairs to match: (left item, right item)
        pairs: Vec<(String, String)>,
    },

    /// Build a sentence from a word bank
    SentenceBuilder {
        /// The prompt/translation to build
        prompt: String,
        /// Words available in the word bank (shuffled for display)
        words: Vec<String>,
        /// Indices representing the correct word order
        correct_order: Vec<usize>,
        /// Extra words that don't belong (distractors)
        #[serde(default)]
        distractors: Vec<String>,
    },
}

impl Question {
    /// Get the prompt text for this question
    pub fn prompt(&self) -> &str {
        match self {
            Question::MultipleChoice { prompt, .. } => prompt,
            Question::Typing { prompt, .. } => prompt,
            Question::MatchingPairs { prompt, .. } => prompt,
            Question::SentenceBuilder { prompt, .. } => prompt,
        }
    }

    /// Get the question type as a string
    pub fn question_type(&self) -> &'static str {
        match self {
            Question::MultipleChoice { .. } => "multiple_choice",
            Question::Typing { .. } => "typing",
            Question::MatchingPairs { .. } => "matching_pairs",
            Question::SentenceBuilder { .. } => "sentence_builder",
        }
    }

    /// Create a new multiple choice question
    pub fn multiple_choice(
        prompt: impl Into<String>,
        options: Vec<String>,
        correct_index: usize,
        explanation: Option<String>,
    ) -> Self {
        Question::MultipleChoice {
            prompt: prompt.into(),
            options,
            correct_index,
            explanation,
        }
    }

    /// Create a new typing question
    pub fn typing(
        prompt: impl Into<String>,
        correct_answers: Vec<String>,
        hint: Option<String>,
        accent_strict: bool,
    ) -> Self {
        Question::Typing {
            prompt: prompt.into(),
            correct_answers,
            hint,
            accent_strict,
        }
    }

    /// Create a new matching pairs question
    pub fn matching_pairs(prompt: impl Into<String>, pairs: Vec<(String, String)>) -> Self {
        Question::MatchingPairs {
            prompt: prompt.into(),
            pairs,
        }
    }

    /// Create a new sentence builder question
    pub fn sentence_builder(
        prompt: impl Into<String>,
        words: Vec<String>,
        correct_order: Vec<usize>,
        distractors: Vec<String>,
    ) -> Self {
        Question::SentenceBuilder {
            prompt: prompt.into(),
            words,
            correct_order,
            distractors,
        }
    }
}

/// Mode for typing answer validation
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum TypingMode {
    /// Ignores accent differences (e.g., "cafe" matches "café")
    #[default]
    Lenient,
    /// Requires exact accent marks
    Strict,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_multiple_choice_serialization() {
        let q = Question::multiple_choice(
            "How do you say 'Hello'?",
            vec!["Olá".into(), "Adeus".into(), "Obrigado".into()],
            0,
            Some("Olá is the standard greeting.".into()),
        );

        let json = serde_json::to_string(&q).unwrap();
        assert!(json.contains("multiple_choice"));
        assert!(json.contains("Olá"));
    }

    #[test]
    fn test_sentence_builder() {
        let q = Question::sentence_builder(
            "Translate: I am happy",
            vec!["Eu".into(), "estou".into(), "feliz".into()],
            vec![0, 1, 2],
            vec!["triste".into()],
        );

        assert_eq!(q.question_type(), "sentence_builder");
    }

    #[test]
    fn test_question_prompt() {
        let q = Question::typing(
            "Write 'Thank you' in Portuguese",
            vec!["Obrigado".into(), "Obrigada".into()],
            None,
            false,
        );

        assert_eq!(q.prompt(), "Write 'Thank you' in Portuguese");
    }
}
