//! GreengoLingo Tauri Application
//!
//! This is the main entry point for the Tauri application that provides
//! the desktop and mobile interface for GreengoLingo.

use greengolingo_core::{
    content::ContentManager,
    dialect::Dialect,
    lesson::{CEFRLevel, Lesson},
    progress::{ProgressSummary, UserProgress},
    question::{check_answer, Answer, Question, QuestionResult, TypingMode},
};
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::State;

/// Application state shared across commands
pub struct AppState {
    pub content_manager: ContentManager,
    pub user_progress: Mutex<UserProgress>,
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            content_manager: ContentManager::new(),
            user_progress: Mutex::new(UserProgress::new("default-user", Dialect::European)),
        }
    }
}

/// User preferences for initialization
#[derive(Debug, Serialize, Deserialize)]
pub struct UserPreferences {
    pub dialect: String,
    pub typing_mode: String,
    pub dark_mode: bool,
}

/// Lesson summary for the UI
#[derive(Debug, Serialize, Deserialize)]
pub struct LessonSummary {
    pub id: String,
    pub title: String,
    pub description: String,
    pub level_code: String,
    pub total_questions: usize,
    pub allows_challenge_out: bool,
}

impl From<&Lesson> for LessonSummary {
    fn from(lesson: &Lesson) -> Self {
        Self {
            id: lesson.id.clone(),
            title: lesson.title.clone(),
            description: lesson.description.clone(),
            level_code: lesson.level.code(),
            total_questions: lesson.total_questions(),
            allows_challenge_out: lesson.allows_challenge_out,
        }
    }
}

/// Get the app version
#[tauri::command]
fn get_version() -> String {
    greengolingo_core::VERSION.to_string()
}

/// Get the app name
#[tauri::command]
fn get_app_name() -> String {
    greengolingo_core::APP_NAME.to_string()
}

/// Initialize user with preferences
#[tauri::command]
fn initialize_user(preferences: UserPreferences, state: State<AppState>) -> Result<(), String> {
    let dialect = match preferences.dialect.as_str() {
        "pt-pt" => Dialect::European,
        "pt-br" => Dialect::Brazilian,
        _ => return Err("Invalid dialect".to_string()),
    };

    let typing_mode = match preferences.typing_mode.as_str() {
        "lenient" => TypingMode::Lenient,
        "strict" => TypingMode::Strict,
        _ => TypingMode::Lenient,
    };

    let mut progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    progress.dialect = dialect;
    progress.typing_mode = typing_mode;
    progress.dark_mode = preferences.dark_mode;

    Ok(())
}

/// Get user progress summary
#[tauri::command]
fn get_progress_summary(state: State<AppState>) -> Result<ProgressSummary, String> {
    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    Ok(ProgressSummary::from_progress(&progress))
}

/// Get user's current dialect
#[tauri::command]
fn get_current_dialect(state: State<AppState>) -> Result<String, String> {
    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    Ok(progress.dialect.code().to_string())
}

/// Set user's dialect
#[tauri::command]
fn set_dialect(dialect: String, state: State<AppState>) -> Result<(), String> {
    let new_dialect = match dialect.as_str() {
        "pt-pt" => Dialect::European,
        "pt-br" => Dialect::Brazilian,
        _ => return Err("Invalid dialect".to_string()),
    };

    let mut progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    progress.dialect = new_dialect;
    Ok(())
}

/// Get available lessons for the current dialect
#[tauri::command]
fn get_lessons(state: State<AppState>) -> Result<Vec<LessonSummary>, String> {
    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    let lessons = state
        .content_manager
        .get_lessons_for_dialect(progress.dialect);
    Ok(lessons.into_iter().map(LessonSummary::from).collect())
}

/// Get lessons for a specific CEFR level
#[tauri::command]
fn get_lessons_by_level(level: String, state: State<AppState>) -> Result<Vec<LessonSummary>, String> {
    let cefr_level = match level.to_uppercase().as_str() {
        "A1" => CEFRLevel::A1,
        "A2" => CEFRLevel::A2,
        "B1" => CEFRLevel::B1,
        "B2" => CEFRLevel::B2,
        "C1" => CEFRLevel::C1,
        "C2" => CEFRLevel::C2,
        _ => return Err("Invalid CEFR level".to_string()),
    };

    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    let lessons = state
        .content_manager
        .get_lessons_for_level(progress.dialect, cefr_level);
    Ok(lessons.into_iter().map(LessonSummary::from).collect())
}

/// Get a specific lesson by ID
#[tauri::command]
fn get_lesson(lesson_id: String, state: State<AppState>) -> Result<String, String> {
    let lesson = state
        .content_manager
        .get_lesson(&lesson_id)
        .ok_or_else(|| "Lesson not found".to_string())?;
    serde_json::to_string(lesson).map_err(|e| e.to_string())
}

/// Get questions for a lesson
#[tauri::command]
fn get_lesson_questions(lesson_id: String, state: State<AppState>) -> Result<String, String> {
    let lesson = state
        .content_manager
        .get_lesson(&lesson_id)
        .ok_or_else(|| "Lesson not found".to_string())?;

    let questions: Vec<&Question> = lesson.all_questions();
    serde_json::to_string(&questions).map_err(|e| e.to_string())
}

/// Check an answer
#[tauri::command]
fn check_user_answer(
    question_json: String,
    answer_text: String,
    selected_option: Option<usize>,
    state: State<AppState>,
) -> Result<String, String> {
    let question: Question = serde_json::from_str(&question_json).map_err(|e| e.to_string())?;
    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;

    let answer = if let Some(index) = selected_option {
        Answer::multiple_choice(&question.id, index)
    } else {
        Answer::typing_with_mode(&question.id, answer_text, progress.typing_mode)
    };

    let result = check_answer(&question, &answer);
    serde_json::to_string(&result).map_err(|e| e.to_string())
}

/// Record an answer in progress
#[tauri::command]
fn record_answer(
    lesson_id: String,
    question_id: String,
    is_correct: bool,
    state: State<AppState>,
) -> Result<(), String> {
    let mut progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    progress.record_answer(&lesson_id, &question_id, is_correct);
    Ok(())
}

/// Toggle dark mode
#[tauri::command]
fn toggle_dark_mode(state: State<AppState>) -> Result<bool, String> {
    let mut progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    progress.toggle_dark_mode();
    Ok(progress.dark_mode)
}

/// Get dark mode status
#[tauri::command]
fn get_dark_mode(state: State<AppState>) -> Result<bool, String> {
    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    Ok(progress.dark_mode)
}

/// Set typing mode
#[tauri::command]
fn set_typing_mode(mode: String, state: State<AppState>) -> Result<(), String> {
    let typing_mode = match mode.as_str() {
        "lenient" => TypingMode::Lenient,
        "strict" => TypingMode::Strict,
        _ => return Err("Invalid typing mode".to_string()),
    };

    let mut progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    progress.set_typing_mode(typing_mode);
    Ok(())
}

/// Get typing mode
#[tauri::command]
fn get_typing_mode(state: State<AppState>) -> Result<String, String> {
    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    Ok(match progress.typing_mode {
        TypingMode::Lenient => "lenient",
        TypingMode::Strict => "strict",
    }
    .to_string())
}

/// Get dialect differences
#[tauri::command]
fn get_dialect_differences() -> Result<String, String> {
    let differences = greengolingo_core::dialect::get_key_differences();
    serde_json::to_string(&differences).map_err(|e| e.to_string())
}

/// Flag a question for review
#[tauri::command]
fn flag_question(question_id: String) -> Result<(), String> {
    // In a real app, this would save to a database
    // For now, just acknowledge the flag
    println!("Question {} flagged for review", question_id);
    Ok(())
}

/// Challenge out of a level
#[tauri::command]
fn challenge_out(level_code: String, state: State<AppState>) -> Result<(), String> {
    let mut progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    progress.challenge_out(&level_code);
    Ok(())
}

/// Check if a level has been challenged out
#[tauri::command]
fn has_challenged_out(level_code: String, state: State<AppState>) -> Result<bool, String> {
    let progress = state.user_progress.lock().map_err(|e| e.to_string())?;
    Ok(progress.has_challenged_out(&level_code))
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .manage(AppState::default())
        .invoke_handler(tauri::generate_handler![
            get_version,
            get_app_name,
            initialize_user,
            get_progress_summary,
            get_current_dialect,
            set_dialect,
            get_lessons,
            get_lessons_by_level,
            get_lesson,
            get_lesson_questions,
            check_user_answer,
            record_answer,
            toggle_dark_mode,
            get_dark_mode,
            set_typing_mode,
            get_typing_mode,
            get_dialect_differences,
            flag_question,
            challenge_out,
            has_challenged_out,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
