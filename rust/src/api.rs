//! Flutter Rust Bridge API
//!
//! This module defines the public API exposed to Flutter via flutter_rust_bridge.
//! All functions here are callable from Dart code.

use crate::engine::{Answer, AnswerValidator, ValidationResult};
use crate::gamification::{
    AchievementId, AchievementTracker, StreakStatus, StreakTracker, StreakUpdate,
    UnlockedAchievement, XPAwardResult, XPMultipliers, XPSystem,
};
use crate::models::{
    CEFRLevel, ContentBundle, Dialect, Language, LanguagePair, Lesson, LessonMetadata, Question,
    TypingMode,
};
use crate::progress::{LessonCompletionResult, ProgressStats, ProgressTracker};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ============================================================================
// App State (managed on Rust side)
// ============================================================================

/// Global app state holding all user data
pub struct AppState {
    pub xp_system: XPSystem,
    pub streak_tracker: StreakTracker,
    pub achievement_tracker: AchievementTracker,
    pub progress_tracker: ProgressTracker,
    pub content_bundle: ContentBundle,
    pub settings: UserSettings,
}

impl AppState {
    pub fn new() -> Self {
        Self {
            xp_system: XPSystem::new(),
            streak_tracker: StreakTracker::new(),
            achievement_tracker: AchievementTracker::new(),
            progress_tracker: ProgressTracker::new(),
            content_bundle: ContentBundle::new(),
            settings: UserSettings::default(),
        }
    }
}

impl Default for AppState {
    fn default() -> Self {
        Self::new()
    }
}

/// User preferences and settings
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserSettings {
    pub typing_mode: TypingMode,
    pub active_language_pair: Option<LanguagePair>,
    pub onboarding_completed: bool,
    pub dark_mode: bool,
    pub haptic_enabled: bool,
    pub notifications_enabled: bool,
}

impl Default for UserSettings {
    fn default() -> Self {
        Self {
            typing_mode: TypingMode::Lenient,
            active_language_pair: None,
            onboarding_completed: false,
            dark_mode: false,
            haptic_enabled: true,
            notifications_enabled: true,
        }
    }
}

// ============================================================================
// Language & Content API
// ============================================================================

/// Get all available languages
#[flutter_rust_bridge::frb(sync)]
pub fn get_available_languages() -> Vec<LanguageInfo> {
    vec![
        LanguageInfo {
            language: Language::English,
            name: "English".to_string(),
            native_name: "English".to_string(),
            iso_code: "en".to_string(),
        },
        LanguageInfo {
            language: Language::Portuguese,
            name: "Portuguese".to_string(),
            native_name: "Português".to_string(),
            iso_code: "pt".to_string(),
        },
    ]
}

/// Get all available dialects
#[flutter_rust_bridge::frb(sync)]
pub fn get_available_dialects() -> Vec<DialectInfo> {
    Dialect::all()
        .into_iter()
        .map(|d| DialectInfo {
            dialect: d,
            name: d.display_name().to_string(),
            short_name: d.short_name().to_string(),
            flag_emoji: d.flag_emoji().to_string(),
            locale_code: d.locale_code().to_string(),
        })
        .collect()
}

/// Get supported language pairs for learning
#[flutter_rust_bridge::frb(sync)]
pub fn get_supported_language_pairs() -> Vec<LanguagePairInfo> {
    LanguagePair::supported_pairs()
        .into_iter()
        .map(|pair| LanguagePairInfo {
            pair,
            display_name: pair.display_name(),
            content_dir: pair.content_dir(),
            source_flag: pair.source.flag_emoji().to_string(),
            target_flag: pair.target.flag_emoji().to_string(),
        })
        .collect()
}

/// Get all CEFR levels
#[flutter_rust_bridge::frb(sync)]
pub fn get_cefr_levels() -> Vec<CEFRLevelInfo> {
    CEFRLevel::all()
        .into_iter()
        .map(|level| CEFRLevelInfo {
            level,
            name: level.display_name().to_string(),
            short_name: level.short_name().to_string(),
            description: level.description().to_string(),
            color: level.color().to_string(),
        })
        .collect()
}

// ============================================================================
// Content Loading API
// ============================================================================

/// Parse lesson content from JSON string
pub fn parse_lesson_json(json: String) -> Result<Lesson, String> {
    ContentBundle::parse_lesson(&json).map_err(|e| e.to_string())
}

/// Parse multiple lessons from JSON array
pub fn parse_lessons_json(json: String) -> Result<Vec<Lesson>, String> {
    ContentBundle::parse_lessons(&json).map_err(|e| e.to_string())
}

/// Get lesson metadata from a lesson
#[flutter_rust_bridge::frb(sync)]
pub fn get_lesson_metadata(lesson: &Lesson) -> LessonMetadata {
    LessonMetadata::from(lesson)
}

// ============================================================================
// Answer Validation API
// ============================================================================

/// Validate a multiple choice answer
#[flutter_rust_bridge::frb(sync)]
pub fn validate_multiple_choice(
    question: &Question,
    selected_index: usize,
    typing_mode: TypingMode,
) -> AnswerValidationResult {
    let validator = AnswerValidator::new(typing_mode);
    let answer = Answer::MultipleChoice { selected_index };
    let result = validator.validate(question, &answer);
    AnswerValidationResult::from(result)
}

/// Validate a typing answer
#[flutter_rust_bridge::frb(sync)]
pub fn validate_typing_answer(
    question: &Question,
    text: String,
    typing_mode: TypingMode,
) -> AnswerValidationResult {
    let validator = AnswerValidator::new(typing_mode);
    let answer = Answer::Typing { text };
    let result = validator.validate(question, &answer);
    AnswerValidationResult::from(result)
}

/// Validate matching pairs answer
#[flutter_rust_bridge::frb(sync)]
pub fn validate_matching_pairs(
    question: &Question,
    matches: HashMap<String, String>,
    typing_mode: TypingMode,
) -> AnswerValidationResult {
    let validator = AnswerValidator::new(typing_mode);
    let answer = Answer::MatchingPairs { matches };
    let result = validator.validate(question, &answer);
    AnswerValidationResult::from(result)
}

/// Validate sentence builder answer
#[flutter_rust_bridge::frb(sync)]
pub fn validate_sentence_builder(
    question: &Question,
    word_order: Vec<usize>,
    typing_mode: TypingMode,
) -> AnswerValidationResult {
    let validator = AnswerValidator::new(typing_mode);
    let answer = Answer::SentenceBuilder { word_order };
    let result = validator.validate(question, &answer);
    AnswerValidationResult::from(result)
}

// ============================================================================
// XP System API
// ============================================================================

/// Create a new XP system instance
#[flutter_rust_bridge::frb(sync)]
pub fn create_xp_system() -> XPSystem {
    XPSystem::new()
}

/// Award XP and get result
#[flutter_rust_bridge::frb(sync)]
pub fn award_xp(xp_system: &mut XPSystem, amount: u32, current_date: String) -> XPAwardResult {
    xp_system.award_xp(amount, &current_date)
}

/// Calculate XP with multipliers
#[flutter_rust_bridge::frb(sync)]
pub fn calculate_xp_with_multipliers(base_xp: u32, perfect: bool, streak_days: u32) -> u32 {
    let multipliers = XPMultipliers::default();
    multipliers.calculate_xp(base_xp, perfect, streak_days)
}

/// Get XP system info
#[flutter_rust_bridge::frb(sync)]
pub fn get_xp_info(xp_system: &XPSystem) -> XPInfo {
    XPInfo {
        total_xp: xp_system.total_xp(),
        today_xp: xp_system.today_xp(),
        current_level: xp_system.current_level(),
        level_progress: xp_system.level_progress(),
        xp_for_next_level: xp_system.xp_for_next_level(),
        level_title: xp_system.level_title().to_string(),
    }
}

// ============================================================================
// Streak System API
// ============================================================================

/// Create a new streak tracker
#[flutter_rust_bridge::frb(sync)]
pub fn create_streak_tracker() -> StreakTracker {
    StreakTracker::new()
}

/// Record activity for streak
#[flutter_rust_bridge::frb(sync)]
pub fn record_streak_activity(tracker: &mut StreakTracker, current_date: String) -> StreakUpdate {
    tracker.record_activity(&current_date)
}

/// Check streak status
#[flutter_rust_bridge::frb(sync)]
pub fn check_streak_status(tracker: &StreakTracker, current_date: String) -> StreakStatus {
    tracker.check_streak_status(&current_date)
}

/// Get streak info
#[flutter_rust_bridge::frb(sync)]
pub fn get_streak_info(tracker: &StreakTracker) -> StreakInfo {
    StreakInfo {
        current_streak: tracker.current_streak(),
        longest_streak: tracker.longest_streak(),
        completed_today: tracker.completed_today(),
    }
}

// ============================================================================
// Achievement System API
// ============================================================================

/// Create a new achievement tracker
#[flutter_rust_bridge::frb(sync)]
pub fn create_achievement_tracker() -> AchievementTracker {
    AchievementTracker::new()
}

/// Check and unlock achievements based on current stats
pub fn check_achievements(
    tracker: &mut AchievementTracker,
    total_xp: u32,
    current_streak: u32,
    current_level: u32,
    timestamp: String,
) -> Vec<AchievementInfo> {
    tracker
        .check_achievements(total_xp, current_streak, current_level, &timestamp)
        .into_iter()
        .map(AchievementInfo::from)
        .collect()
}

/// Record lesson completion for achievements
pub fn record_lesson_for_achievements(
    tracker: &mut AchievementTracker,
    perfect: bool,
    timestamp: String,
) -> Vec<AchievementInfo> {
    tracker
        .record_lesson_completion(perfect, &timestamp)
        .into_iter()
        .map(AchievementInfo::from)
        .collect()
}

/// Get all achievement definitions
#[flutter_rust_bridge::frb(sync)]
pub fn get_all_achievements() -> Vec<AchievementDefinition> {
    AchievementId::all()
        .into_iter()
        .map(|id| AchievementDefinition {
            id: format!("{:?}", id),
            name: id.name().to_string(),
            description: id.description().to_string(),
            icon: id.icon().to_string(),
            xp_reward: id.xp_reward(),
        })
        .collect()
}

/// Get unlocked achievements
#[flutter_rust_bridge::frb(sync)]
pub fn get_unlocked_achievements(tracker: &AchievementTracker) -> Vec<AchievementInfo> {
    tracker
        .unlocked_achievements()
        .iter()
        .map(|a| AchievementInfo::from(a.clone()))
        .collect()
}

// ============================================================================
// Progress Tracking API
// ============================================================================

/// Create a new progress tracker
#[flutter_rust_bridge::frb(sync)]
pub fn create_progress_tracker() -> ProgressTracker {
    ProgressTracker::new()
}

/// Record lesson completion
#[flutter_rust_bridge::frb(sync)]
pub fn record_lesson_completion(
    tracker: &mut ProgressTracker,
    pair: &LanguagePair,
    lesson_id: String,
    score_percent: u32,
) -> LessonCompletionResult {
    tracker.record_lesson_completion(pair, &lesson_id, score_percent)
}

/// Get progress stats for a language pair
#[flutter_rust_bridge::frb(sync)]
pub fn get_progress_stats(
    tracker: &ProgressTracker,
    pair: &LanguagePair,
    total_lessons: usize,
) -> ProgressStats {
    tracker.get_progress_stats(pair, total_lessons)
}

/// Check if lesson is completed
#[flutter_rust_bridge::frb(sync)]
pub fn is_lesson_completed(
    tracker: &ProgressTracker,
    pair: &LanguagePair,
    lesson_id: String,
) -> bool {
    tracker.is_lesson_completed(pair, &lesson_id)
}

// ============================================================================
// Data Transfer Objects
// ============================================================================

/// Language information for display
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LanguageInfo {
    pub language: Language,
    pub name: String,
    pub native_name: String,
    pub iso_code: String,
}

/// Dialect information for display
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DialectInfo {
    pub dialect: Dialect,
    pub name: String,
    pub short_name: String,
    pub flag_emoji: String,
    pub locale_code: String,
}

/// Language pair information for display
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LanguagePairInfo {
    pub pair: LanguagePair,
    pub display_name: String,
    pub content_dir: String,
    pub source_flag: String,
    pub target_flag: String,
}

/// CEFR level information for display
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CEFRLevelInfo {
    pub level: CEFRLevel,
    pub name: String,
    pub short_name: String,
    pub description: String,
    pub color: String,
}

/// Answer validation result for Flutter
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnswerValidationResult {
    pub is_correct: bool,
    pub correct_answer: String,
    pub explanation: Option<String>,
    pub score: f32,
}

impl From<ValidationResult> for AnswerValidationResult {
    fn from(result: ValidationResult) -> Self {
        Self {
            is_correct: result.is_correct,
            correct_answer: result.correct_answer,
            explanation: result.explanation,
            score: result.score,
        }
    }
}

/// XP system information for display
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct XPInfo {
    pub total_xp: u32,
    pub today_xp: u32,
    pub current_level: u32,
    pub level_progress: f32,
    pub xp_for_next_level: u32,
    pub level_title: String,
}

/// Streak information for display
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreakInfo {
    pub current_streak: u32,
    pub longest_streak: u32,
    pub completed_today: bool,
}

/// Achievement definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AchievementDefinition {
    pub id: String,
    pub name: String,
    pub description: String,
    pub icon: String,
    pub xp_reward: u32,
}

/// Unlocked achievement info
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AchievementInfo {
    pub id: String,
    pub name: String,
    pub description: String,
    pub icon: String,
    pub xp_reward: u32,
    pub unlocked_at: String,
}

impl From<UnlockedAchievement> for AchievementInfo {
    fn from(achievement: UnlockedAchievement) -> Self {
        Self {
            id: format!("{:?}", achievement.id),
            name: achievement.id.name().to_string(),
            description: achievement.id.description().to_string(),
            icon: achievement.id.icon().to_string(),
            xp_reward: achievement.id.xp_reward(),
            unlocked_at: achievement.unlocked_at,
        }
    }
}

// ============================================================================
// Serialization API (for persistence)
// ============================================================================

/// Serialize XP system to JSON
pub fn serialize_xp_system(xp_system: &XPSystem) -> Result<String, String> {
    serde_json::to_string(xp_system).map_err(|e| e.to_string())
}

/// Deserialize XP system from JSON
pub fn deserialize_xp_system(json: String) -> Result<XPSystem, String> {
    serde_json::from_str(&json).map_err(|e| e.to_string())
}

/// Serialize streak tracker to JSON
pub fn serialize_streak_tracker(tracker: &StreakTracker) -> Result<String, String> {
    serde_json::to_string(tracker).map_err(|e| e.to_string())
}

/// Deserialize streak tracker from JSON
pub fn deserialize_streak_tracker(json: String) -> Result<StreakTracker, String> {
    serde_json::from_str(&json).map_err(|e| e.to_string())
}

/// Serialize achievement tracker to JSON
pub fn serialize_achievement_tracker(tracker: &AchievementTracker) -> Result<String, String> {
    serde_json::to_string(tracker).map_err(|e| e.to_string())
}

/// Deserialize achievement tracker from JSON
pub fn deserialize_achievement_tracker(json: String) -> Result<AchievementTracker, String> {
    serde_json::from_str(&json).map_err(|e| e.to_string())
}

/// Serialize progress tracker to JSON
pub fn serialize_progress_tracker(tracker: &ProgressTracker) -> Result<String, String> {
    serde_json::to_string(tracker).map_err(|e| e.to_string())
}

/// Deserialize progress tracker from JSON
pub fn deserialize_progress_tracker(json: String) -> Result<ProgressTracker, String> {
    serde_json::from_str(&json).map_err(|e| e.to_string())
}

/// Serialize user settings to JSON
pub fn serialize_user_settings(settings: &UserSettings) -> Result<String, String> {
    serde_json::to_string(settings).map_err(|e| e.to_string())
}

/// Deserialize user settings from JSON
pub fn deserialize_user_settings(json: String) -> Result<UserSettings, String> {
    serde_json::from_str(&json).map_err(|e| e.to_string())
}
