//! Vocabulary bank for organizing and searching learned words

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Category of vocabulary item
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum VocabularyCategory {
    Noun,
    Verb,
    Adjective,
    Adverb,
    Pronoun,
    Preposition,
    Conjunction,
    Interjection,
    Phrase,
    Expression,
    Idiom,
    Grammar,
    Other,
}

impl VocabularyCategory {
    /// Get display name for the category
    pub fn display_name(&self) -> &'static str {
        match self {
            VocabularyCategory::Noun => "Noun",
            VocabularyCategory::Verb => "Verb",
            VocabularyCategory::Adjective => "Adjective",
            VocabularyCategory::Adverb => "Adverb",
            VocabularyCategory::Pronoun => "Pronoun",
            VocabularyCategory::Preposition => "Preposition",
            VocabularyCategory::Conjunction => "Conjunction",
            VocabularyCategory::Interjection => "Interjection",
            VocabularyCategory::Phrase => "Phrase",
            VocabularyCategory::Expression => "Expression",
            VocabularyCategory::Idiom => "Idiom",
            VocabularyCategory::Grammar => "Grammar",
            VocabularyCategory::Other => "Other",
        }
    }

    /// Get icon for the category
    pub fn icon(&self) -> &'static str {
        match self {
            VocabularyCategory::Noun => "category",
            VocabularyCategory::Verb => "directions_run",
            VocabularyCategory::Adjective => "palette",
            VocabularyCategory::Adverb => "speed",
            VocabularyCategory::Pronoun => "person",
            VocabularyCategory::Preposition => "place",
            VocabularyCategory::Conjunction => "link",
            VocabularyCategory::Interjection => "chat_bubble",
            VocabularyCategory::Phrase => "short_text",
            VocabularyCategory::Expression => "format_quote",
            VocabularyCategory::Idiom => "lightbulb",
            VocabularyCategory::Grammar => "rule",
            VocabularyCategory::Other => "label",
        }
    }

    /// Get all categories
    pub fn all() -> Vec<Self> {
        vec![
            VocabularyCategory::Noun,
            VocabularyCategory::Verb,
            VocabularyCategory::Adjective,
            VocabularyCategory::Adverb,
            VocabularyCategory::Pronoun,
            VocabularyCategory::Preposition,
            VocabularyCategory::Conjunction,
            VocabularyCategory::Interjection,
            VocabularyCategory::Phrase,
            VocabularyCategory::Expression,
            VocabularyCategory::Idiom,
            VocabularyCategory::Grammar,
            VocabularyCategory::Other,
        ]
    }
}

/// A vocabulary item representing a word or phrase
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct VocabularyItem {
    /// Unique identifier
    pub id: String,
    /// Word/phrase in source language
    pub source: String,
    /// Word/phrase in target language
    pub target: String,
    /// Pronunciation guide (optional)
    pub pronunciation: Option<String>,
    /// Example sentence (optional)
    pub example_sentence: Option<String>,
    /// Example sentence translation (optional)
    pub example_translation: Option<String>,
    /// ID of the lesson this word came from
    pub lesson_id: String,
    /// CEFR level (A1-C2)
    pub level: String,
    /// Language pair code
    pub language_pair: String,
    /// Category of the vocabulary item
    pub category: VocabularyCategory,
    /// Additional notes (optional)
    pub notes: Option<String>,
    /// Tags for searching/filtering
    pub tags: Vec<String>,
    /// Whether this item has been added to SRS
    pub in_srs: bool,
    /// ISO date when added
    pub added_at: String,
}

impl VocabularyItem {
    /// Create a new vocabulary item
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        id: String,
        source: String,
        target: String,
        lesson_id: String,
        level: String,
        language_pair: String,
        category: VocabularyCategory,
        current_date: &str,
    ) -> Self {
        Self {
            id,
            source,
            target,
            pronunciation: None,
            example_sentence: None,
            example_translation: None,
            lesson_id,
            level,
            language_pair,
            category,
            notes: None,
            tags: Vec::new(),
            in_srs: false,
            added_at: current_date.to_string(),
        }
    }

    /// Create with full details
    #[allow(clippy::too_many_arguments)]
    pub fn with_details(
        id: String,
        source: String,
        target: String,
        pronunciation: Option<String>,
        example_sentence: Option<String>,
        example_translation: Option<String>,
        lesson_id: String,
        level: String,
        language_pair: String,
        category: VocabularyCategory,
        notes: Option<String>,
        current_date: &str,
    ) -> Self {
        Self {
            id,
            source,
            target,
            pronunciation,
            example_sentence,
            example_translation,
            lesson_id,
            level,
            language_pair,
            category,
            notes,
            tags: Vec::new(),
            in_srs: false,
            added_at: current_date.to_string(),
        }
    }

    /// Check if this item matches a search query
    pub fn matches_query(&self, query: &str) -> bool {
        let query_lower = query.to_lowercase();
        self.source.to_lowercase().contains(&query_lower)
            || self.target.to_lowercase().contains(&query_lower)
            || self
                .tags
                .iter()
                .any(|t| t.to_lowercase().contains(&query_lower))
    }
}

/// A collection of vocabulary items with indexing for efficient lookups
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VocabularyBank {
    /// All vocabulary items by ID
    items: HashMap<String, VocabularyItem>,
    /// Index by level
    by_level: HashMap<String, Vec<String>>,
    /// Index by lesson
    by_lesson: HashMap<String, Vec<String>>,
    /// Index by language pair
    by_language_pair: HashMap<String, Vec<String>>,
    /// Index by category
    by_category: HashMap<VocabularyCategory, Vec<String>>,
}

impl VocabularyBank {
    /// Create a new empty vocabulary bank
    pub fn new() -> Self {
        Self {
            items: HashMap::new(),
            by_level: HashMap::new(),
            by_lesson: HashMap::new(),
            by_language_pair: HashMap::new(),
            by_category: HashMap::new(),
        }
    }

    /// Add a vocabulary item to the bank
    pub fn add(&mut self, item: VocabularyItem) {
        let id = item.id.clone();
        let level = item.level.clone();
        let lesson_id = item.lesson_id.clone();
        let language_pair = item.language_pair.clone();
        let category = item.category;

        // Add to main storage
        self.items.insert(id.clone(), item);

        // Update indices
        self.by_level.entry(level).or_default().push(id.clone());
        self.by_lesson
            .entry(lesson_id)
            .or_default()
            .push(id.clone());
        self.by_language_pair
            .entry(language_pair)
            .or_default()
            .push(id.clone());
        self.by_category.entry(category).or_default().push(id);
    }

    /// Get a vocabulary item by ID
    pub fn get(&self, id: &str) -> Option<&VocabularyItem> {
        self.items.get(id)
    }

    /// Get a mutable reference to a vocabulary item
    pub fn get_mut(&mut self, id: &str) -> Option<&mut VocabularyItem> {
        self.items.get_mut(id)
    }

    /// Remove a vocabulary item
    pub fn remove(&mut self, id: &str) -> Option<VocabularyItem> {
        if let Some(item) = self.items.remove(id) {
            // Remove from indices
            if let Some(ids) = self.by_level.get_mut(&item.level) {
                ids.retain(|i| i != id);
            }
            if let Some(ids) = self.by_lesson.get_mut(&item.lesson_id) {
                ids.retain(|i| i != id);
            }
            if let Some(ids) = self.by_language_pair.get_mut(&item.language_pair) {
                ids.retain(|i| i != id);
            }
            if let Some(ids) = self.by_category.get_mut(&item.category) {
                ids.retain(|i| i != id);
            }
            Some(item)
        } else {
            None
        }
    }

    /// Get all vocabulary items
    pub fn all(&self) -> Vec<&VocabularyItem> {
        self.items.values().collect()
    }

    /// Get vocabulary items by level
    pub fn by_level(&self, level: &str) -> Vec<&VocabularyItem> {
        self.by_level
            .get(level)
            .map(|ids| ids.iter().filter_map(|id| self.items.get(id)).collect())
            .unwrap_or_default()
    }

    /// Get vocabulary items by lesson
    pub fn by_lesson(&self, lesson_id: &str) -> Vec<&VocabularyItem> {
        self.by_lesson
            .get(lesson_id)
            .map(|ids| ids.iter().filter_map(|id| self.items.get(id)).collect())
            .unwrap_or_default()
    }

    /// Get vocabulary items by language pair
    pub fn by_language_pair(&self, language_pair: &str) -> Vec<&VocabularyItem> {
        self.by_language_pair
            .get(language_pair)
            .map(|ids| ids.iter().filter_map(|id| self.items.get(id)).collect())
            .unwrap_or_default()
    }

    /// Get vocabulary items by category
    pub fn by_category(&self, category: VocabularyCategory) -> Vec<&VocabularyItem> {
        self.by_category
            .get(&category)
            .map(|ids| ids.iter().filter_map(|id| self.items.get(id)).collect())
            .unwrap_or_default()
    }

    /// Search vocabulary items
    pub fn search(&self, query: &str, limit: Option<usize>) -> Vec<&VocabularyItem> {
        let mut results: Vec<_> = self
            .items
            .values()
            .filter(|item| item.matches_query(query))
            .collect();

        // Sort by relevance (exact matches first)
        let query_lower = query.to_lowercase();
        results.sort_by(|a, b| {
            let a_exact =
                a.source.to_lowercase() == query_lower || a.target.to_lowercase() == query_lower;
            let b_exact =
                b.source.to_lowercase() == query_lower || b.target.to_lowercase() == query_lower;
            b_exact.cmp(&a_exact)
        });

        if let Some(limit) = limit {
            results.truncate(limit);
        }

        results
    }

    /// Get total count
    pub fn len(&self) -> usize {
        self.items.len()
    }

    /// Check if empty
    pub fn is_empty(&self) -> bool {
        self.items.is_empty()
    }

    /// Get items not yet in SRS
    pub fn not_in_srs(&self) -> Vec<&VocabularyItem> {
        self.items.values().filter(|item| !item.in_srs).collect()
    }

    /// Mark item as added to SRS
    pub fn mark_in_srs(&mut self, id: &str) -> bool {
        if let Some(item) = self.items.get_mut(id) {
            item.in_srs = true;
            true
        } else {
            false
        }
    }

    /// Get vocabulary statistics
    pub fn stats(&self) -> VocabularyStats {
        let total = self.items.len();
        let in_srs = self.items.values().filter(|i| i.in_srs).count();
        let by_level: HashMap<String, usize> = self
            .by_level
            .iter()
            .map(|(level, ids)| (level.clone(), ids.len()))
            .collect();
        let by_category: HashMap<String, usize> = self
            .by_category
            .iter()
            .map(|(cat, ids)| (cat.display_name().to_string(), ids.len()))
            .collect();

        VocabularyStats {
            total,
            in_srs,
            not_in_srs: total - in_srs,
            by_level,
            by_category,
        }
    }
}

impl Default for VocabularyBank {
    fn default() -> Self {
        Self::new()
    }
}

/// Statistics about the vocabulary bank
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VocabularyStats {
    pub total: usize,
    pub in_srs: usize,
    pub not_in_srs: usize,
    pub by_level: HashMap<String, usize>,
    pub by_category: HashMap<String, usize>,
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_item(id: &str, source: &str, target: &str) -> VocabularyItem {
        VocabularyItem::new(
            id.to_string(),
            source.to_string(),
            target.to_string(),
            "greetings".to_string(),
            "A1".to_string(),
            "en_to_pt_br".to_string(),
            VocabularyCategory::Phrase,
            "2024-01-15",
        )
    }

    #[test]
    fn test_vocabulary_bank_add_and_get() {
        let mut bank = VocabularyBank::new();
        let item = create_test_item("vocab_001", "hello", "olá");

        bank.add(item.clone());

        assert_eq!(bank.len(), 1);
        assert_eq!(bank.get("vocab_001"), Some(&item));
    }

    #[test]
    fn test_vocabulary_bank_search() {
        let mut bank = VocabularyBank::new();
        bank.add(create_test_item("vocab_001", "hello", "olá"));
        bank.add(create_test_item("vocab_002", "goodbye", "tchau"));
        bank.add(create_test_item("vocab_003", "good morning", "bom dia"));

        let results = bank.search("good", None);
        assert_eq!(results.len(), 2);
    }

    #[test]
    fn test_vocabulary_bank_by_level() {
        let mut bank = VocabularyBank::new();
        bank.add(create_test_item("vocab_001", "hello", "olá"));

        let a1_items = bank.by_level("A1");
        assert_eq!(a1_items.len(), 1);

        let b1_items = bank.by_level("B1");
        assert_eq!(b1_items.len(), 0);
    }

    #[test]
    fn test_mark_in_srs() {
        let mut bank = VocabularyBank::new();
        bank.add(create_test_item("vocab_001", "hello", "olá"));

        assert!(!bank.get("vocab_001").unwrap().in_srs);
        bank.mark_in_srs("vocab_001");
        assert!(bank.get("vocab_001").unwrap().in_srs);
    }
}
