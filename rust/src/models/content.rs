use serde::{Deserialize, Serialize};

use super::language::LanguagePair;
use super::lesson::{Lesson, LessonMetadata};
use super::level::CEFRLevel;

/// A bundle of lessons loaded from content files
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContentBundle {
    /// All lessons indexed by ID
    lessons: Vec<Lesson>,
}

impl ContentBundle {
    /// Create a new empty content bundle
    pub fn new() -> Self {
        Self {
            lessons: Vec::new(),
        }
    }

    /// Create a content bundle from a list of lessons
    pub fn from_lessons(lessons: Vec<Lesson>) -> Self {
        Self { lessons }
    }

    /// Add a lesson to the bundle
    pub fn add_lesson(&mut self, lesson: Lesson) {
        self.lessons.push(lesson);
    }

    /// Get all lessons
    pub fn lessons(&self) -> &[Lesson] {
        &self.lessons
    }

    /// Get a lesson by ID
    pub fn get_lesson(&self, id: &str) -> Option<&Lesson> {
        self.lessons.iter().find(|l| l.id == id)
    }

    /// Get lessons for a specific language pair
    pub fn lessons_for_pair(&self, pair: &LanguagePair) -> Vec<&Lesson> {
        self.lessons
            .iter()
            .filter(|l| &l.language_pair == pair)
            .collect()
    }

    /// Get lessons for a specific level
    pub fn lessons_for_level(&self, level: CEFRLevel) -> Vec<&Lesson> {
        self.lessons.iter().filter(|l| l.level == level).collect()
    }

    /// Get lessons for a specific language pair and level
    pub fn lessons_for_pair_and_level(
        &self,
        pair: &LanguagePair,
        level: CEFRLevel,
    ) -> Vec<&Lesson> {
        self.lessons
            .iter()
            .filter(|l| &l.language_pair == pair && l.level == level)
            .collect()
    }

    /// Get metadata for all lessons matching criteria
    pub fn get_lesson_metadata(
        &self,
        pair: Option<&LanguagePair>,
        level: Option<CEFRLevel>,
    ) -> Vec<LessonMetadata> {
        self.lessons
            .iter()
            .filter(|l| {
                pair.is_none_or(|p| &l.language_pair == p) && level.is_none_or(|lv| l.level == lv)
            })
            .map(LessonMetadata::from)
            .collect()
    }

    /// Get the total number of lessons
    pub fn lesson_count(&self) -> usize {
        self.lessons.len()
    }

    /// Parse a lesson from JSON string
    pub fn parse_lesson(json: &str) -> Result<Lesson, serde_json::Error> {
        serde_json::from_str(json)
    }

    /// Parse multiple lessons from a JSON array string
    pub fn parse_lessons(json: &str) -> Result<Vec<Lesson>, serde_json::Error> {
        serde_json::from_str(json)
    }

    /// Serialize a lesson to JSON
    pub fn serialize_lesson(lesson: &Lesson) -> Result<String, serde_json::Error> {
        serde_json::to_string_pretty(lesson)
    }
}

impl Default for ContentBundle {
    fn default() -> Self {
        Self::new()
    }
}

/// Index of available content per language pair and level
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContentIndex {
    /// Available language pairs with their levels
    pub pairs: Vec<LanguagePairIndex>,
}

/// Index entry for a language pair
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LanguagePairIndex {
    pub pair: LanguagePair,
    /// Available levels with lesson counts
    pub levels: Vec<LevelIndex>,
}

/// Index entry for a level within a language pair
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LevelIndex {
    pub level: CEFRLevel,
    /// Number of lessons available at this level
    pub lesson_count: usize,
    /// Total XP available at this level
    pub total_xp: u32,
}

impl ContentIndex {
    /// Build an index from a content bundle
    pub fn from_bundle(bundle: &ContentBundle) -> Self {
        let mut pairs_map: std::collections::HashMap<
            LanguagePair,
            std::collections::HashMap<CEFRLevel, (usize, u32)>,
        > = std::collections::HashMap::new();

        for lesson in bundle.lessons() {
            let level_map = pairs_map.entry(lesson.language_pair).or_default();
            let (count, xp) = level_map.entry(lesson.level).or_insert((0, 0));
            *count += 1;
            *xp += lesson.xp_reward;
        }

        let pairs = pairs_map
            .into_iter()
            .map(|(pair, levels_map)| {
                let mut levels: Vec<LevelIndex> = levels_map
                    .into_iter()
                    .map(|(level, (lesson_count, total_xp))| LevelIndex {
                        level,
                        lesson_count,
                        total_xp,
                    })
                    .collect();
                levels.sort_by_key(|l| l.level);
                LanguagePairIndex { pair, levels }
            })
            .collect();

        Self { pairs }
    }

    /// Get the index for a specific language pair
    pub fn get_pair_index(&self, pair: &LanguagePair) -> Option<&LanguagePairIndex> {
        self.pairs.iter().find(|p| &p.pair == pair)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::language::Dialect;
    use crate::models::question::Question;

    fn create_test_lesson(id: &str, level: CEFRLevel) -> Lesson {
        let pair = LanguagePair::new(Dialect::EnglishUS, Dialect::PortugueseEuropean);
        Lesson::builder(id, "Test")
            .level(level)
            .language_pair(pair)
            .add_question(Question::typing("Q", vec!["A".into()], None, false))
            .build()
            .unwrap()
    }

    #[test]
    fn test_content_bundle() {
        let mut bundle = ContentBundle::new();
        bundle.add_lesson(create_test_lesson("l1", CEFRLevel::A1));
        bundle.add_lesson(create_test_lesson("l2", CEFRLevel::A1));
        bundle.add_lesson(create_test_lesson("l3", CEFRLevel::A2));

        assert_eq!(bundle.lesson_count(), 3);
        assert_eq!(bundle.lessons_for_level(CEFRLevel::A1).len(), 2);
    }

    #[test]
    fn test_content_index() {
        let mut bundle = ContentBundle::new();
        bundle.add_lesson(create_test_lesson("l1", CEFRLevel::A1));
        bundle.add_lesson(create_test_lesson("l2", CEFRLevel::A1));

        let index = ContentIndex::from_bundle(&bundle);
        assert_eq!(index.pairs.len(), 1);
        assert_eq!(index.pairs[0].levels[0].lesson_count, 2);
    }
}
