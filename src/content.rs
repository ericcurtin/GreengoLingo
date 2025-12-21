//! Content management module
//!
//! This module provides content management for lessons, including
//! sample content for A1 level Portuguese learning.

use crate::dialect::{Dialect, VocabularyEntry};
use crate::lesson::{CEFRLevel, CheatSheet, CheatSheetExample, Lesson, LessonUnit, Level};
use crate::question::{MultipleChoiceOption, Question, QuestionContext};

/// Content manager for organizing and retrieving lessons
pub struct ContentManager {
    /// Available lessons
    lessons: Vec<Lesson>,
    /// Vocabulary entries
    vocabulary: Vec<VocabularyEntry>,
}

impl ContentManager {
    /// Create a new content manager with default content
    pub fn new() -> Self {
        let mut manager = Self {
            lessons: Vec::new(),
            vocabulary: Vec::new(),
        };
        manager.load_default_content();
        manager
    }

    /// Load default content for both dialects
    fn load_default_content(&mut self) {
        // Load vocabulary
        self.vocabulary = get_base_vocabulary();

        // Load lessons for both dialects
        for dialect in [Dialect::European, Dialect::Brazilian] {
            self.lessons.extend(create_a1_lessons(dialect));
        }
    }

    /// Get all lessons for a specific dialect
    pub fn get_lessons_for_dialect(&self, dialect: Dialect) -> Vec<&Lesson> {
        self.lessons
            .iter()
            .filter(|l| l.dialect == dialect)
            .collect()
    }

    /// Get lessons for a specific CEFR level and dialect
    pub fn get_lessons_for_level(&self, dialect: Dialect, level: CEFRLevel) -> Vec<&Lesson> {
        self.lessons
            .iter()
            .filter(|l| l.dialect == dialect && l.level.cefr == level)
            .collect()
    }

    /// Get a specific lesson by ID
    pub fn get_lesson(&self, lesson_id: &str) -> Option<&Lesson> {
        self.lessons.iter().find(|l| l.id == lesson_id)
    }

    /// Get vocabulary for a specific dialect
    pub fn get_vocabulary_for_dialect(&self, dialect: Dialect) -> Vec<(&VocabularyEntry, &str)> {
        self.vocabulary
            .iter()
            .map(|v| (v, v.translation_for(dialect)))
            .collect()
    }

    /// Get vocabulary by category
    pub fn get_vocabulary_by_category(&self, category: &str) -> Vec<&VocabularyEntry> {
        self.vocabulary
            .iter()
            .filter(|v| v.category.to_lowercase() == category.to_lowercase())
            .collect()
    }

    /// Get all available levels with their descriptions
    pub fn get_available_levels(&self, dialect: Dialect) -> Vec<&Level> {
        self.lessons
            .iter()
            .filter(|l| l.dialect == dialect)
            .map(|l| &l.level)
            .collect()
    }

    /// Add a new lesson
    pub fn add_lesson(&mut self, lesson: Lesson) {
        self.lessons.push(lesson);
    }

    /// Add vocabulary entry
    pub fn add_vocabulary(&mut self, entry: VocabularyEntry) {
        self.vocabulary.push(entry);
    }
}

impl Default for ContentManager {
    fn default() -> Self {
        Self::new()
    }
}

/// Get base vocabulary entries
fn get_base_vocabulary() -> Vec<VocabularyEntry> {
    vec![
        // Greetings
        VocabularyEntry::new("Hello", "Olá", "Olá", "Greetings"),
        VocabularyEntry::new("Good morning", "Bom dia", "Bom dia", "Greetings"),
        VocabularyEntry::new("Good afternoon", "Boa tarde", "Boa tarde", "Greetings"),
        VocabularyEntry::new("Good night", "Boa noite", "Boa noite", "Greetings"),
        VocabularyEntry::new("Goodbye", "Adeus", "Tchau", "Greetings"),
        VocabularyEntry::new("See you later", "Até logo", "Até logo", "Greetings"),
        VocabularyEntry::new("Please", "Por favor", "Por favor", "Greetings"),
        VocabularyEntry::new("Thank you", "Obrigado/Obrigada", "Obrigado/Obrigada", "Greetings"),
        VocabularyEntry::new("You're welcome", "De nada", "De nada", "Greetings"),
        VocabularyEntry::new("Excuse me", "Com licença", "Com licença", "Greetings"),
        // Numbers
        VocabularyEntry::new("One", "Um/Uma", "Um/Uma", "Numbers"),
        VocabularyEntry::new("Two", "Dois/Duas", "Dois/Duas", "Numbers"),
        VocabularyEntry::new("Three", "Três", "Três", "Numbers"),
        VocabularyEntry::new("Four", "Quatro", "Quatro", "Numbers"),
        VocabularyEntry::new("Five", "Cinco", "Cinco", "Numbers"),
        VocabularyEntry::new("Six", "Seis", "Seis", "Numbers"),
        VocabularyEntry::new("Seven", "Sete", "Sete", "Numbers"),
        VocabularyEntry::new("Eight", "Oito", "Oito", "Numbers"),
        VocabularyEntry::new("Nine", "Nove", "Nove", "Numbers"),
        VocabularyEntry::new("Ten", "Dez", "Dez", "Numbers"),
        // Transportation (dialect-specific)
        VocabularyEntry::new("Bus", "Autocarro", "Ônibus", "Transportation"),
        VocabularyEntry::new("Train", "Comboio", "Trem", "Transportation"),
        VocabularyEntry::new("Car", "Carro", "Carro", "Transportation"),
        VocabularyEntry::new("Airplane", "Avião", "Avião", "Transportation"),
        VocabularyEntry::new("Subway", "Metro", "Metrô", "Transportation"),
        // Food
        VocabularyEntry::new("Coffee", "Café", "Café", "Food"),
        VocabularyEntry::new("Water", "Água", "Água", "Food"),
        VocabularyEntry::new("Bread", "Pão", "Pão", "Food"),
        VocabularyEntry::new("Milk", "Leite", "Leite", "Food"),
        VocabularyEntry::new("Breakfast", "Pequeno-almoço", "Café da manhã", "Food"),
        VocabularyEntry::new("Lunch", "Almoço", "Almoço", "Food"),
        VocabularyEntry::new("Dinner", "Jantar", "Jantar", "Food"),
        // Places
        VocabularyEntry::new("Bathroom", "Casa de banho", "Banheiro", "Places"),
        VocabularyEntry::new("Restaurant", "Restaurante", "Restaurante", "Places"),
        VocabularyEntry::new("Hotel", "Hotel", "Hotel", "Places"),
        VocabularyEntry::new("Airport", "Aeroporto", "Aeroporto", "Places"),
        VocabularyEntry::new("Beach", "Praia", "Praia", "Places"),
        VocabularyEntry::new("City", "Cidade", "Cidade", "Places"),
        // Personal pronouns
        VocabularyEntry::new("I", "Eu", "Eu", "Pronouns"),
        VocabularyEntry::new("You (informal)", "Tu", "Você", "Pronouns"),
        VocabularyEntry::new("You (formal)", "Você", "Você", "Pronouns"),
        VocabularyEntry::new("He", "Ele", "Ele", "Pronouns"),
        VocabularyEntry::new("She", "Ela", "Ela", "Pronouns"),
        VocabularyEntry::new("We", "Nós", "A gente/Nós", "Pronouns"),
        VocabularyEntry::new("They (masc.)", "Eles", "Eles", "Pronouns"),
        VocabularyEntry::new("They (fem.)", "Elas", "Elas", "Pronouns"),
    ]
}

/// Create A1 level lessons for a specific dialect
fn create_a1_lessons(dialect: Dialect) -> Vec<Lesson> {
    let dialect_code = dialect.code();

    vec![
        // A1.1 - First Steps
        create_a1_1_lesson(dialect, dialect_code),
        // A1.2 - At the Café
        create_a1_2_lesson(dialect, dialect_code),
        // A1.3 - Introducing Family
        create_a1_3_lesson(dialect, dialect_code),
    ]
}

fn create_a1_1_lesson(dialect: Dialect, dialect_code: &str) -> Lesson {
    let level = Level::new(
        CEFRLevel::A1,
        1,
        "First Steps",
        vec![
            "Greet someone appropriately based on time of day".to_string(),
            "Introduce yourself with your name".to_string(),
            "Ask someone's name politely".to_string(),
            "Say goodbye in different situations".to_string(),
        ],
    );

    let greeting_cheat_sheet = CheatSheet::new(
        "Portuguese Greetings",
        "Portuguese has different greetings depending on the time of day. Unlike English, these are used very consistently in daily interactions.",
    )
    .with_example(CheatSheetExample::with_breakdown(
        "Bom dia",
        "Good morning",
        "'Bom' (good) + 'dia' (day) - Used until noon",
    ))
    .with_example(CheatSheetExample::with_breakdown(
        "Boa tarde",
        "Good afternoon",
        "'Boa' (good, feminine) + 'tarde' (afternoon) - Used from noon until sunset",
    ))
    .with_example(CheatSheetExample::with_breakdown(
        "Boa noite",
        "Good evening/night",
        "'Boa' (good, feminine) + 'noite' (night) - Used after sunset",
    ))
    .with_mistake("Don't use 'Bom noite' - noite is feminine, so it must be 'Boa noite'")
    .with_tip("Notice how 'Bom' changes to 'Boa' to match the gender of the noun: 'dia' (masculine) vs 'tarde/noite' (feminine)");

    let unit = LessonUnit::new(
        format!("{}-a1.1-greetings", dialect_code),
        "Basic Greetings",
        "Learn to greet people in Portuguese throughout the day",
        dialect,
    )
    .with_cheat_sheet(greeting_cheat_sheet)
    .with_vocabulary(vec![
        "Olá".to_string(),
        "Bom dia".to_string(),
        "Boa tarde".to_string(),
        "Boa noite".to_string(),
    ])
    .with_question(
        Question::multiple_choice(
            format!("{}-q1", dialect_code),
            "It's 9 AM. How do you greet someone?",
            vec![
                MultipleChoiceOption::with_explanation("Bom dia", true, "Correct! 'Bom dia' is used in the morning until noon."),
                MultipleChoiceOption::with_explanation("Boa tarde", false, "'Boa tarde' is used in the afternoon, not morning."),
                MultipleChoiceOption::with_explanation("Boa noite", false, "'Boa noite' is used in the evening/night."),
            ],
        )
        .with_context(QuestionContext::new("You meet your neighbor on your way to work in the morning."))
    )
    .with_question(
        Question::multiple_choice(
            format!("{}-q2", dialect_code),
            "It's 3 PM. What do you say?",
            vec![
                MultipleChoiceOption::new("Bom dia", false),
                MultipleChoiceOption::new("Boa tarde", true),
                MultipleChoiceOption::new("Boa noite", false),
            ],
        )
        .with_context(QuestionContext::new("You enter a shop in the afternoon."))
    )
    .with_question(
        Question::typing(
            format!("{}-q3", dialect_code),
            "Translate: 'Good morning'",
            "Bom dia",
        )
        .with_hint("Remember: 'dia' is masculine, so we use 'Bom'")
    )
    .with_question(
        Question::typing(
            format!("{}-q4", dialect_code),
            "Translate: 'Good afternoon'",
            "Boa tarde",
        )
        .with_hint("Remember: 'tarde' is feminine, so we use 'Boa'")
    )
    .with_question(
        Question::typing(
            format!("{}-q5", dialect_code),
            "Translate: 'Hello'",
            "Olá",
        )
    );

    Lesson::new(
        format!("{}-lesson-a1.1", dialect_code),
        level,
        "First Steps: Greetings",
        "By the end of this lesson, you will be able to greet anyone in Portuguese at any time of day.",
        dialect,
    )
    .with_unit(unit)
}

fn create_a1_2_lesson(dialect: Dialect, dialect_code: &str) -> Lesson {
    let level = Level::new(
        CEFRLevel::A1,
        2,
        "At the Café",
        vec![
            "Order a coffee and basic drinks".to_string(),
            "Ask for the bill politely".to_string(),
            "Use numbers 1-10 for quantities".to_string(),
            "Say please and thank you appropriately".to_string(),
        ],
    );

    let politeness_cheat_sheet = CheatSheet::new(
        "Being Polite in Portuguese",
        "Politeness is very important in Portuguese culture. Always use 'por favor' (please) and 'obrigado/obrigada' (thank you).",
    )
    .with_example(CheatSheetExample::with_breakdown(
        "Um café, por favor",
        "A coffee, please",
        "'Um' (a/one) + 'café' (coffee) + 'por favor' (please)",
    ))
    .with_example(CheatSheetExample::with_breakdown(
        "Obrigado", 
        "Thank you (said by men)",
        "Men always say 'obrigado' (masculine ending -o)",
    ))
    .with_example(CheatSheetExample::with_breakdown(
        "Obrigada",
        "Thank you (said by women)",
        "Women always say 'obrigada' (feminine ending -a)",
    ))
    .with_mistake("Don't say 'obrigada' if you're male, or 'obrigado' if you're female - this is based on the speaker's gender, not the listener's")
    .with_tip("The gender of 'obrigado/obrigada' depends on WHO IS SPEAKING, not who you're talking to");

    let numbers_cheat_sheet = CheatSheet::new(
        "Numbers 1-5",
        "Portuguese numbers are essential for ordering quantities. Note that 'um/uma' and 'dois/duas' change based on gender.",
    )
    .with_example(CheatSheetExample::new("Um café", "One coffee (masculine)"))
    .with_example(CheatSheetExample::new("Uma água", "One water (feminine)"))
    .with_example(CheatSheetExample::new("Dois cafés", "Two coffees (masculine)"))
    .with_example(CheatSheetExample::new("Duas águas", "Two waters (feminine)"));

    let unit = LessonUnit::new(
        format!("{}-a1.2-cafe", dialect_code),
        "Ordering at a Café",
        "Learn to order drinks and be polite in Portuguese",
        dialect,
    )
    .with_cheat_sheet(politeness_cheat_sheet)
    .with_cheat_sheet(numbers_cheat_sheet)
    .with_vocabulary(vec![
        "Café".to_string(),
        "Água".to_string(),
        "Por favor".to_string(),
        "Obrigado".to_string(),
        "Obrigada".to_string(),
        "A conta".to_string(),
    ])
    .with_question(
        Question::multiple_choice(
            format!("{}-cafe-q1", dialect_code),
            "How do you politely order a coffee?",
            vec![
                MultipleChoiceOption::new("Um café, por favor", true),
                MultipleChoiceOption::new("Café!", false),
                MultipleChoiceOption::new("Dá-me café", false),
            ],
        )
        .with_context(QuestionContext::new("You're at a café and want to order a coffee."))
    )
    .with_question(
        Question::typing(
            format!("{}-cafe-q2", dialect_code),
            "Translate: 'A coffee, please'",
            "Um café, por favor",
        )
        .with_alternatives(vec!["Um café por favor".to_string()])
    )
    .with_question(
        Question::typing(
            format!("{}-cafe-q3", dialect_code),
            "Translate: 'Thank you' (if you're a man)",
            "Obrigado",
        )
    )
    .with_question(
        Question::typing(
            format!("{}-cafe-q4", dialect_code),
            "Translate: 'Thank you' (if you're a woman)",
            "Obrigada",
        )
    )
    .with_question(
        Question::multiple_choice(
            format!("{}-cafe-q5", dialect_code),
            "How do you ask for the bill?",
            vec![
                MultipleChoiceOption::new("A conta, por favor", true),
                MultipleChoiceOption::new("Dinheiro, por favor", false),
                MultipleChoiceOption::new("Pagar, por favor", false),
            ],
        )
        .with_hint("'Conta' means bill/check")
    );

    Lesson::new(
        format!("{}-lesson-a1.2", dialect_code),
        level,
        "At the Café",
        "By the end of this lesson, you will be able to order a coffee and pay the bill politely.",
        dialect,
    )
    .with_unit(unit)
}

fn create_a1_3_lesson(dialect: Dialect, dialect_code: &str) -> Lesson {
    let (you_informal, you_formal, verb_example_pt, verb_example_en) = match dialect {
        Dialect::European => ("Tu", "Você", "Eu chamo-me", "I am called (lit. I call myself)"),
        Dialect::Brazilian => ("Você", "O senhor/A senhora", "Eu me chamo", "I am called (lit. I call myself)"),
    };

    let level = Level::new(
        CEFRLevel::A1,
        3,
        "Introducing Yourself & Family",
        vec![
            "Introduce yourself with your name and nationality".to_string(),
            "Ask someone's name".to_string(),
            "Introduce family members".to_string(),
            "Use basic personal pronouns".to_string(),
        ],
    );

    let intro_cheat_sheet = CheatSheet::new(
        "Introducing Yourself",
        format!("There are several ways to introduce yourself in Portuguese. In {} Portuguese, pronoun placement differs.", dialect.region()),
    )
    .with_example(CheatSheetExample::with_breakdown(
        verb_example_pt,
        verb_example_en,
        "The reflexive verb 'chamar-se' means 'to be called'",
    ))
    .with_example(CheatSheetExample::new(
        "O meu nome é... / Meu nome é...",
        "My name is...",
    ))
    .with_tip(format!("In {} Portuguese, '{}' is informal and '{}' is formal/polite.", dialect.region(), you_informal, you_formal));

    let (question_how_name, answer_how_name) = match dialect {
        Dialect::European => ("Como te chamas?", "Como te chamas?"),
        Dialect::Brazilian => ("Como você se chama?", "Como você se chama?"),
    };

    let unit = LessonUnit::new(
        format!("{}-a1.3-intro", dialect_code),
        "Self Introduction",
        "Learn to introduce yourself and ask someone's name",
        dialect,
    )
    .with_cheat_sheet(intro_cheat_sheet)
    .with_vocabulary(vec![
        verb_example_pt.to_string(),
        "O meu nome é".to_string(),
        question_how_name.to_string(),
        "Prazer em conhecer".to_string(),
    ])
    .with_question(
        Question::typing(
            format!("{}-intro-q1", dialect_code),
            "How do you ask 'What's your name?' (informal)",
            answer_how_name,
        )
        .with_context(QuestionContext::new("You meet someone your age at a party."))
    )
    .with_question(
        Question::multiple_choice(
            format!("{}-intro-q2", dialect_code),
            "Someone asks your name. Which is a correct response?",
            vec![
                MultipleChoiceOption::new(format!("{} Maria", verb_example_pt), true),
                MultipleChoiceOption::new("Nome Maria", false),
                MultipleChoiceOption::new("Maria chama", false),
            ],
        )
    )
    .with_question(
        Question::typing(
            format!("{}-intro-q3", dialect_code),
            "Translate: 'Nice to meet you'",
            "Prazer em conhecer",
        )
        .with_alternatives(vec!["Muito prazer".to_string(), "Prazer".to_string()])
    );

    Lesson::new(
        format!("{}-lesson-a1.3", dialect_code),
        level,
        "Introducing Yourself",
        "By the end of this lesson, you will be able to introduce yourself and your family.",
        dialect,
    )
    .with_unit(unit)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_content_manager_creation() {
        let manager = ContentManager::new();
        assert!(!manager.lessons.is_empty());
        assert!(!manager.vocabulary.is_empty());
    }

    #[test]
    fn test_get_lessons_for_dialect() {
        let manager = ContentManager::new();
        let european_lessons = manager.get_lessons_for_dialect(Dialect::European);
        let brazilian_lessons = manager.get_lessons_for_dialect(Dialect::Brazilian);

        assert!(!european_lessons.is_empty());
        assert!(!brazilian_lessons.is_empty());

        // All lessons should be for the requested dialect
        for lesson in &european_lessons {
            assert_eq!(lesson.dialect, Dialect::European);
        }
        for lesson in &brazilian_lessons {
            assert_eq!(lesson.dialect, Dialect::Brazilian);
        }
    }

    #[test]
    fn test_get_lessons_for_level() {
        let manager = ContentManager::new();
        let a1_lessons = manager.get_lessons_for_level(Dialect::European, CEFRLevel::A1);

        assert!(!a1_lessons.is_empty());
        for lesson in &a1_lessons {
            assert_eq!(lesson.level.cefr, CEFRLevel::A1);
        }
    }

    #[test]
    fn test_vocabulary_dialect_differences() {
        let manager = ContentManager::new();
        let transportation = manager.get_vocabulary_by_category("Transportation");

        // Find "Bus" entry
        let bus = transportation.iter().find(|v| v.english == "Bus").unwrap();
        assert!(bus.has_dialect_difference());
        assert_eq!(bus.translation_for(Dialect::European), "Autocarro");
        assert_eq!(bus.translation_for(Dialect::Brazilian), "Ônibus");
    }

    #[test]
    fn test_lessons_have_questions() {
        let manager = ContentManager::new();
        for lesson in &manager.lessons {
            assert!(lesson.total_questions() > 0, "Lesson {} has no questions", lesson.id);
        }
    }

    #[test]
    fn test_lessons_have_cheat_sheets() {
        let manager = ContentManager::new();
        for lesson in &manager.lessons {
            let has_cheat_sheet = lesson.units.iter().any(|u| !u.cheat_sheets.is_empty());
            assert!(has_cheat_sheet, "Lesson {} has no cheat sheets", lesson.id);
        }
    }

    #[test]
    fn test_get_lesson_by_id() {
        let manager = ContentManager::new();
        let lesson = manager.get_lesson("pt-pt-lesson-a1.1");
        assert!(lesson.is_some());
        assert_eq!(lesson.unwrap().dialect, Dialect::European);
    }
}
