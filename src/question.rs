//! Question module for language learning exercises
//!
//! This module provides multiple choice and typing question types,
//! including strict mode for accent checking.

use serde::{Deserialize, Serialize};
use unicode_normalization::UnicodeNormalization;

/// Types of questions available
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum QuestionType {
    /// Multiple choice question - recognition phase
    MultipleChoice,
    /// Typing question - production phase
    Typing,
}

impl QuestionType {
    /// Returns the display name of the question type
    pub fn display_name(&self) -> &'static str {
        match self {
            QuestionType::MultipleChoice => "Multiple Choice",
            QuestionType::Typing => "Typing",
        }
    }
}

/// Typing mode for accent strictness
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize, Default)]
pub enum TypingMode {
    /// Lenient mode - ignores accent mistakes
    #[default]
    Lenient,
    /// Strict mode - requires exact accents (ã, ç, é, etc.)
    Strict,
}

impl TypingMode {
    /// Returns the display name of the typing mode
    pub fn display_name(&self) -> &'static str {
        match self {
            TypingMode::Lenient => "Lenient (accents optional)",
            TypingMode::Strict => "Strict (accents required)",
        }
    }

    /// Returns a description of this mode
    pub fn description(&self) -> &'static str {
        match self {
            TypingMode::Lenient => "Missing accents won't count as mistakes. Good for beginners.",
            TypingMode::Strict => "Missing tildes (~), cedillas (ç), and other accents count as mistakes. Essential for advanced learning where 'pão' (bread) and 'pau' (stick) must be distinguished.",
        }
    }
}

/// A multiple choice option
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MultipleChoiceOption {
    /// The option text
    pub text: String,
    /// Whether this is the correct answer
    pub is_correct: bool,
    /// Optional explanation for why this is correct/incorrect
    pub explanation: Option<String>,
}

impl MultipleChoiceOption {
    /// Create a new option
    pub fn new(text: impl Into<String>, is_correct: bool) -> Self {
        Self {
            text: text.into(),
            is_correct,
            explanation: None,
        }
    }

    /// Create an option with explanation
    pub fn with_explanation(
        text: impl Into<String>,
        is_correct: bool,
        explanation: impl Into<String>,
    ) -> Self {
        Self {
            text: text.into(),
            is_correct,
            explanation: Some(explanation.into()),
        }
    }
}

/// Context for a question (makes it more meaningful than simple translation)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuestionContext {
    /// A scenario or situation description
    pub scenario: String,
    /// Optional image URL or reference
    pub image: Option<String>,
    /// Optional audio clip reference
    pub audio: Option<String>,
}

impl QuestionContext {
    /// Create a new context with just a scenario
    pub fn new(scenario: impl Into<String>) -> Self {
        Self {
            scenario: scenario.into(),
            image: None,
            audio: None,
        }
    }

    /// Create a context with an image
    pub fn with_image(scenario: impl Into<String>, image: impl Into<String>) -> Self {
        Self {
            scenario: scenario.into(),
            image: Some(image.into()),
            audio: None,
        }
    }

    /// Create a context with audio
    pub fn with_audio(scenario: impl Into<String>, audio: impl Into<String>) -> Self {
        Self {
            scenario: scenario.into(),
            image: None,
            audio: Some(audio.into()),
        }
    }
}

/// A language learning question
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Question {
    /// Unique identifier for this question
    pub id: String,
    /// The type of question
    pub question_type: QuestionType,
    /// The question prompt
    pub prompt: String,
    /// Optional context for the question
    pub context: Option<QuestionContext>,
    /// The correct answer (for typing questions)
    pub correct_answer: String,
    /// Alternative correct answers (for typing questions)
    pub alternative_answers: Vec<String>,
    /// Options for multiple choice questions
    pub options: Vec<MultipleChoiceOption>,
    /// Hint text (shown after first mistake)
    pub hint: Option<String>,
    /// Explanation shown after answering
    pub explanation: Option<String>,
    /// Community naturalness score (0-100)
    pub naturalness_score: Option<u8>,
    /// Number of community flags for review
    pub flag_count: u32,
}

impl Question {
    /// Create a new typing question
    pub fn typing(
        id: impl Into<String>,
        prompt: impl Into<String>,
        correct_answer: impl Into<String>,
    ) -> Self {
        Self {
            id: id.into(),
            question_type: QuestionType::Typing,
            prompt: prompt.into(),
            context: None,
            correct_answer: correct_answer.into(),
            alternative_answers: Vec::new(),
            options: Vec::new(),
            hint: None,
            explanation: None,
            naturalness_score: None,
            flag_count: 0,
        }
    }

    /// Create a new multiple choice question
    pub fn multiple_choice(
        id: impl Into<String>,
        prompt: impl Into<String>,
        options: Vec<MultipleChoiceOption>,
    ) -> Self {
        let correct_answer = options
            .iter()
            .find(|o| o.is_correct)
            .map(|o| o.text.clone())
            .unwrap_or_default();

        Self {
            id: id.into(),
            question_type: QuestionType::MultipleChoice,
            prompt: prompt.into(),
            context: None,
            correct_answer,
            alternative_answers: Vec::new(),
            options,
            hint: None,
            explanation: None,
            naturalness_score: None,
            flag_count: 0,
        }
    }

    /// Add context to this question
    pub fn with_context(mut self, context: QuestionContext) -> Self {
        self.context = Some(context);
        self
    }

    /// Add a hint to this question
    pub fn with_hint(mut self, hint: impl Into<String>) -> Self {
        self.hint = Some(hint.into());
        self
    }

    /// Add an explanation to this question
    pub fn with_explanation(mut self, explanation: impl Into<String>) -> Self {
        self.explanation = Some(explanation.into());
        self
    }

    /// Add alternative correct answers (for typing questions)
    pub fn with_alternatives(mut self, alternatives: Vec<String>) -> Self {
        self.alternative_answers = alternatives;
        self
    }

    /// Flag this question for review
    pub fn flag_for_review(&mut self) {
        self.flag_count += 1;
    }

    /// Set the naturalness score
    pub fn set_naturalness_score(&mut self, score: u8) {
        self.naturalness_score = Some(score.min(100));
    }
}

/// User's answer to a question
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Answer {
    /// The question ID this answer is for
    pub question_id: String,
    /// The user's answer text
    pub answer_text: String,
    /// The index of the selected option (for multiple choice)
    pub selected_option_index: Option<usize>,
    /// The typing mode used
    pub typing_mode: TypingMode,
}

impl Answer {
    /// Create a typing answer
    pub fn typing(question_id: impl Into<String>, answer_text: impl Into<String>) -> Self {
        Self {
            question_id: question_id.into(),
            answer_text: answer_text.into(),
            selected_option_index: None,
            typing_mode: TypingMode::default(),
        }
    }

    /// Create a typing answer with specific mode
    pub fn typing_with_mode(
        question_id: impl Into<String>,
        answer_text: impl Into<String>,
        mode: TypingMode,
    ) -> Self {
        Self {
            question_id: question_id.into(),
            answer_text: answer_text.into(),
            selected_option_index: None,
            typing_mode: mode,
        }
    }

    /// Create a multiple choice answer
    pub fn multiple_choice(question_id: impl Into<String>, option_index: usize) -> Self {
        Self {
            question_id: question_id.into(),
            answer_text: String::new(),
            selected_option_index: Some(option_index),
            typing_mode: TypingMode::default(),
        }
    }
}

/// Result of checking an answer
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuestionResult {
    /// Whether the answer was correct
    pub is_correct: bool,
    /// The correct answer
    pub correct_answer: String,
    /// The user's answer
    pub user_answer: String,
    /// Feedback message
    pub feedback: String,
    /// Whether accents were the only issue (for lenient mode feedback)
    pub accent_issues_only: bool,
    /// Specific accent mistakes made
    pub accent_mistakes: Vec<AccentMistake>,
}

/// An accent mistake in typing
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccentMistake {
    /// The word with the mistake
    pub word: String,
    /// The correct word with proper accents
    pub correct_word: String,
    /// Position in the answer
    pub position: usize,
}

/// Check if two strings match, ignoring accents
fn strings_match_ignoring_accents(s1: &str, s2: &str) -> bool {
    let normalize = |s: &str| -> String {
        s.nfd()
            .filter(|c| {
                // Remove combining diacritical marks (accents)
                let code = *c as u32;
                !(0x0300..=0x036F).contains(&code)
            })
            .collect::<String>()
            .to_lowercase()
            .trim()
            .to_string()
    };
    normalize(s1) == normalize(s2)
}

/// Check if two strings match exactly
fn strings_match_exact(s1: &str, s2: &str) -> bool {
    s1.trim().to_lowercase() == s2.trim().to_lowercase()
}

/// Find accent differences between two strings
fn find_accent_mistakes(user_answer: &str, correct_answer: &str) -> Vec<AccentMistake> {
    let user_words: Vec<&str> = user_answer.split_whitespace().collect();
    let correct_words: Vec<&str> = correct_answer.split_whitespace().collect();
    let mut mistakes = Vec::new();

    for (i, (user_word, correct_word)) in user_words.iter().zip(correct_words.iter()).enumerate() {
        if strings_match_ignoring_accents(user_word, correct_word)
            && !strings_match_exact(user_word, correct_word)
        {
            mistakes.push(AccentMistake {
                word: user_word.to_string(),
                correct_word: correct_word.to_string(),
                position: i,
            });
        }
    }

    mistakes
}

/// Check a user's answer against a question
pub fn check_answer(question: &Question, answer: &Answer) -> QuestionResult {
    match question.question_type {
        QuestionType::MultipleChoice => check_multiple_choice(question, answer),
        QuestionType::Typing => check_typing(question, answer),
    }
}

fn check_multiple_choice(question: &Question, answer: &Answer) -> QuestionResult {
    let selected_index = answer.selected_option_index.unwrap_or(usize::MAX);
    let is_correct = question
        .options
        .get(selected_index)
        .is_some_and(|o| o.is_correct);

    let user_answer = question
        .options
        .get(selected_index)
        .map(|o| o.text.clone())
        .unwrap_or_else(|| "No answer selected".to_string());

    let feedback = if is_correct {
        "Correct! Well done.".to_string()
    } else {
        let correct_option = question.options.iter().find(|o| o.is_correct);
        match correct_option {
            Some(opt) => {
                if let Some(explanation) = &opt.explanation {
                    format!("The correct answer is '{}'. {}", opt.text, explanation)
                } else {
                    format!("The correct answer is '{}'.", opt.text)
                }
            }
            None => "Incorrect.".to_string(),
        }
    };

    QuestionResult {
        is_correct,
        correct_answer: question.correct_answer.clone(),
        user_answer,
        feedback,
        accent_issues_only: false,
        accent_mistakes: Vec::new(),
    }
}

fn check_typing(question: &Question, answer: &Answer) -> QuestionResult {
    let user_answer = answer.answer_text.trim();
    let correct_answer = &question.correct_answer;

    // Check for exact match first
    if strings_match_exact(user_answer, correct_answer) {
        return QuestionResult {
            is_correct: true,
            correct_answer: correct_answer.clone(),
            user_answer: user_answer.to_string(),
            feedback: "Perfect! Excellent work.".to_string(),
            accent_issues_only: false,
            accent_mistakes: Vec::new(),
        };
    }

    // Check alternative answers
    for alt in &question.alternative_answers {
        if strings_match_exact(user_answer, alt) {
            return QuestionResult {
                is_correct: true,
                correct_answer: correct_answer.clone(),
                user_answer: user_answer.to_string(),
                feedback: "Correct! That's also a valid answer.".to_string(),
                accent_issues_only: false,
                accent_mistakes: Vec::new(),
            };
        }
    }

    // Check with accent leniency
    let matches_ignoring_accents = strings_match_ignoring_accents(user_answer, correct_answer)
        || question
            .alternative_answers
            .iter()
            .any(|alt| strings_match_ignoring_accents(user_answer, alt));

    if matches_ignoring_accents {
        let accent_mistakes = find_accent_mistakes(user_answer, correct_answer);

        match answer.typing_mode {
            TypingMode::Lenient => {
                let feedback = if accent_mistakes.is_empty() {
                    "Correct!".to_string()
                } else {
                    let mistake_words: Vec<String> = accent_mistakes
                        .iter()
                        .map(|m| format!("'{}' → '{}'", m.word, m.correct_word))
                        .collect();
                    format!(
                        "Correct! Note the accents: {}",
                        mistake_words.join(", ")
                    )
                };

                QuestionResult {
                    is_correct: true,
                    correct_answer: correct_answer.clone(),
                    user_answer: user_answer.to_string(),
                    feedback,
                    accent_issues_only: true,
                    accent_mistakes,
                }
            }
            TypingMode::Strict => {
                let mistake_words: Vec<String> = accent_mistakes
                    .iter()
                    .map(|m| format!("'{}' should be '{}'", m.word, m.correct_word))
                    .collect();
                let feedback = format!(
                    "Almost! Check your accents: {}. The correct answer is '{}'.",
                    mistake_words.join(", "),
                    correct_answer
                );

                QuestionResult {
                    is_correct: false,
                    correct_answer: correct_answer.clone(),
                    user_answer: user_answer.to_string(),
                    feedback,
                    accent_issues_only: true,
                    accent_mistakes,
                }
            }
        }
    } else {
        // Completely wrong answer
        let feedback = format!("Incorrect. The correct answer is '{}'.", correct_answer);

        QuestionResult {
            is_correct: false,
            correct_answer: correct_answer.clone(),
            user_answer: user_answer.to_string(),
            feedback,
            accent_issues_only: false,
            accent_mistakes: Vec::new(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_question_type_display() {
        assert_eq!(QuestionType::MultipleChoice.display_name(), "Multiple Choice");
        assert_eq!(QuestionType::Typing.display_name(), "Typing");
    }

    #[test]
    fn test_typing_mode_display() {
        assert_eq!(
            TypingMode::Lenient.display_name(),
            "Lenient (accents optional)"
        );
        assert_eq!(TypingMode::Strict.display_name(), "Strict (accents required)");
    }

    #[test]
    fn test_multiple_choice_question() {
        let options = vec![
            MultipleChoiceOption::new("Bom dia", true),
            MultipleChoiceOption::new("Boa noite", false),
            MultipleChoiceOption::new("Olá", false),
        ];
        let question = Question::multiple_choice("q1", "How do you say 'Good morning'?", options);

        assert_eq!(question.question_type, QuestionType::MultipleChoice);
        assert_eq!(question.correct_answer, "Bom dia");
        assert_eq!(question.options.len(), 3);
    }

    #[test]
    fn test_typing_question() {
        let question = Question::typing("q1", "Translate: 'Hello'", "Olá");

        assert_eq!(question.question_type, QuestionType::Typing);
        assert_eq!(question.correct_answer, "Olá");
    }

    #[test]
    fn test_check_multiple_choice_correct() {
        let options = vec![
            MultipleChoiceOption::new("Wrong", false),
            MultipleChoiceOption::new("Correct", true),
        ];
        let question = Question::multiple_choice("q1", "Test question", options);
        let answer = Answer::multiple_choice("q1", 1);

        let result = check_answer(&question, &answer);
        assert!(result.is_correct);
    }

    #[test]
    fn test_check_multiple_choice_incorrect() {
        let options = vec![
            MultipleChoiceOption::new("Wrong", false),
            MultipleChoiceOption::new("Correct", true),
        ];
        let question = Question::multiple_choice("q1", "Test question", options);
        let answer = Answer::multiple_choice("q1", 0);

        let result = check_answer(&question, &answer);
        assert!(!result.is_correct);
    }

    #[test]
    fn test_check_typing_exact_match() {
        let question = Question::typing("q1", "Translate: 'bread'", "pão");
        let answer = Answer::typing("q1", "pão");

        let result = check_answer(&question, &answer);
        assert!(result.is_correct);
        assert!(!result.accent_issues_only);
    }

    #[test]
    fn test_check_typing_lenient_mode() {
        let question = Question::typing("q1", "Translate: 'bread'", "pão");
        let answer = Answer::typing_with_mode("q1", "pao", TypingMode::Lenient);

        let result = check_answer(&question, &answer);
        assert!(result.is_correct);
        assert!(result.accent_issues_only);
    }

    #[test]
    fn test_check_typing_strict_mode() {
        let question = Question::typing("q1", "Translate: 'bread'", "pão");
        let answer = Answer::typing_with_mode("q1", "pao", TypingMode::Strict);

        let result = check_answer(&question, &answer);
        assert!(!result.is_correct);
        assert!(result.accent_issues_only);
    }

    #[test]
    fn test_check_typing_wrong_answer() {
        let question = Question::typing("q1", "Translate: 'bread'", "pão");
        let answer = Answer::typing("q1", "leite");

        let result = check_answer(&question, &answer);
        assert!(!result.is_correct);
        assert!(!result.accent_issues_only);
    }

    #[test]
    fn test_check_typing_alternative_answers() {
        let question = Question::typing("q1", "Translate: 'You are nice'", "Tu és simpático")
            .with_alternatives(vec!["Você é simpático".to_string()]);
        let answer = Answer::typing("q1", "Você é simpático");

        let result = check_answer(&question, &answer);
        assert!(result.is_correct);
    }

    #[test]
    fn test_question_flagging() {
        let mut question = Question::typing("q1", "Test", "Test");
        assert_eq!(question.flag_count, 0);

        question.flag_for_review();
        assert_eq!(question.flag_count, 1);

        question.flag_for_review();
        assert_eq!(question.flag_count, 2);
    }

    #[test]
    fn test_naturalness_score() {
        let mut question = Question::typing("q1", "Test", "Test");
        assert!(question.naturalness_score.is_none());

        question.set_naturalness_score(85);
        assert_eq!(question.naturalness_score, Some(85));

        // Test clamping to 100
        question.set_naturalness_score(150);
        assert_eq!(question.naturalness_score, Some(100));
    }

    #[test]
    fn test_strings_match_ignoring_accents() {
        assert!(strings_match_ignoring_accents("pão", "pao"));
        assert!(strings_match_ignoring_accents("café", "cafe"));
        assert!(strings_match_ignoring_accents("coração", "coracao"));
        assert!(!strings_match_ignoring_accents("pão", "pau"));
    }

    #[test]
    fn test_context_creation() {
        let context = QuestionContext::new("Someone asks you for directions");
        assert!(context.image.is_none());
        assert!(context.audio.is_none());

        let context_with_image =
            QuestionContext::with_image("At a bakery", "bakery.jpg");
        assert!(context_with_image.image.is_some());
    }
}
