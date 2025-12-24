//! Learning analytics for identifying weak areas and tracking progress

use super::daily::StatisticsTracker;
use serde::{Deserialize, Serialize};

/// A weak area that needs improvement
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeakArea {
    /// Type of weakness (question_type, level, topic)
    pub area_type: WeakAreaType,
    /// Identifier for the weak area
    pub identifier: String,
    /// Display name
    pub name: String,
    /// Current accuracy percentage
    pub accuracy: f32,
    /// Number of attempts
    pub attempts: u32,
    /// Suggested practice: list of lesson IDs
    pub suggested_practice: Vec<String>,
    /// Severity (0-100, higher = more severe)
    pub severity: u32,
}

/// Type of weak area
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum WeakAreaType {
    QuestionType,
    Level,
    Vocabulary,
}

impl WeakAreaType {
    pub fn display_name(&self) -> &'static str {
        match self {
            WeakAreaType::QuestionType => "Question Type",
            WeakAreaType::Level => "Level",
            WeakAreaType::Vocabulary => "Vocabulary",
        }
    }
}

/// Learning velocity metrics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LearningVelocity {
    /// Lessons per day (average over period)
    pub lessons_per_day: f32,
    /// XP per day (average)
    pub xp_per_day: f32,
    /// Words per day (average)
    pub words_per_day: f32,
    /// Time per day in minutes (average)
    pub minutes_per_day: f32,
    /// Trend direction (positive = improving, negative = declining)
    pub trend: VelocityTrend,
    /// Comparison to previous period
    pub change_percent: f32,
}

/// Velocity trend direction
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum VelocityTrend {
    Improving,
    Stable,
    Declining,
}

impl VelocityTrend {
    pub fn from_change(change_percent: f32) -> Self {
        if change_percent > 10.0 {
            VelocityTrend::Improving
        } else if change_percent < -10.0 {
            VelocityTrend::Declining
        } else {
            VelocityTrend::Stable
        }
    }

    pub fn display_name(&self) -> &'static str {
        match self {
            VelocityTrend::Improving => "Improving",
            VelocityTrend::Stable => "Stable",
            VelocityTrend::Declining => "Declining",
        }
    }

    pub fn icon(&self) -> &'static str {
        match self {
            VelocityTrend::Improving => "trending_up",
            VelocityTrend::Stable => "trending_flat",
            VelocityTrend::Declining => "trending_down",
        }
    }
}

/// Learning analytics engine
pub struct LearningAnalytics;

impl LearningAnalytics {
    /// Identify weak areas from statistics
    pub fn identify_weak_areas(
        stats: &StatisticsTracker,
        accuracy_threshold: f32,
        min_attempts: u32,
    ) -> Vec<WeakArea> {
        let mut weak_areas = Vec::new();

        // Analyze question type accuracy
        for (question_type, type_stats) in &stats.lifetime.accuracy_by_type {
            if type_stats.answered >= min_attempts && type_stats.accuracy() < accuracy_threshold {
                let severity = Self::calculate_severity(type_stats.accuracy(), accuracy_threshold);
                weak_areas.push(WeakArea {
                    area_type: WeakAreaType::QuestionType,
                    identifier: question_type.clone(),
                    name: Self::question_type_display_name(question_type),
                    accuracy: type_stats.accuracy(),
                    attempts: type_stats.answered,
                    suggested_practice: Vec::new(), // Would need lesson data to populate
                    severity,
                });
            }
        }

        // Sort by severity (highest first)
        weak_areas.sort_by(|a, b| b.severity.cmp(&a.severity));

        weak_areas
    }

    /// Calculate learning velocity over a period
    pub fn calculate_velocity(stats: &StatisticsTracker, days: usize) -> LearningVelocity {
        let recent = stats.get_recent(days);
        let days_count = recent.len().max(1) as f32;

        let total_lessons: u32 = recent.iter().map(|s| s.lessons_completed).sum();
        let total_xp: u32 = recent.iter().map(|s| s.xp_earned).sum();
        let total_words: u32 = recent.iter().map(|s| s.new_words_learned).sum();
        let total_seconds: u32 = recent.iter().map(|s| s.time_spent_seconds).sum();

        let lessons_per_day = total_lessons as f32 / days_count;
        let xp_per_day = total_xp as f32 / days_count;
        let words_per_day = total_words as f32 / days_count;
        let minutes_per_day = (total_seconds as f32 / 60.0) / days_count;

        // Calculate trend by comparing to previous period
        let previous = stats.get_recent(days * 2);
        let previous_xp: u32 = previous
            .iter()
            .skip(days.min(previous.len()))
            .map(|s| s.xp_earned)
            .sum();
        let previous_days = (previous.len().saturating_sub(days)).max(1) as f32;
        let previous_xp_per_day = previous_xp as f32 / previous_days;

        let change_percent = if previous_xp_per_day > 0.0 {
            ((xp_per_day - previous_xp_per_day) / previous_xp_per_day) * 100.0
        } else {
            0.0
        };

        let trend = VelocityTrend::from_change(change_percent);

        LearningVelocity {
            lessons_per_day,
            xp_per_day,
            words_per_day,
            minutes_per_day,
            trend,
            change_percent,
        }
    }

    /// Estimate days to complete a level based on current velocity
    pub fn estimate_level_completion(
        velocity: &LearningVelocity,
        lessons_remaining: u32,
    ) -> Option<u32> {
        if velocity.lessons_per_day <= 0.0 {
            return None;
        }

        Some((lessons_remaining as f32 / velocity.lessons_per_day).ceil() as u32)
    }

    /// Get best performing question type
    pub fn best_question_type(stats: &StatisticsTracker) -> Option<(String, f32)> {
        stats
            .lifetime
            .accuracy_by_type
            .iter()
            .filter(|(_, s)| s.answered >= 10)
            .max_by(|(_, a), (_, b)| a.accuracy().partial_cmp(&b.accuracy()).unwrap())
            .map(|(t, s)| (t.clone(), s.accuracy()))
    }

    /// Get worst performing question type
    pub fn worst_question_type(stats: &StatisticsTracker) -> Option<(String, f32)> {
        stats
            .lifetime
            .accuracy_by_type
            .iter()
            .filter(|(_, s)| s.answered >= 10)
            .min_by(|(_, a), (_, b)| a.accuracy().partial_cmp(&b.accuracy()).unwrap())
            .map(|(t, s)| (t.clone(), s.accuracy()))
    }

    /// Calculate optimal study time based on performance patterns
    pub fn analyze_study_patterns(stats: &StatisticsTracker) -> StudyPatternAnalysis {
        let recent = stats.get_recent(30);

        if recent.is_empty() {
            return StudyPatternAnalysis::default();
        }

        let avg_time: f32 = recent.iter().map(|s| s.time_spent_seconds).sum::<u32>() as f32
            / recent.len() as f32
            / 60.0;

        let avg_accuracy: f32 =
            recent.iter().map(|s| s.accuracy()).sum::<f32>() / recent.len() as f32;

        let consistency = Self::calculate_consistency(&recent);

        StudyPatternAnalysis {
            average_session_minutes: avg_time,
            average_accuracy: avg_accuracy,
            consistency_score: consistency,
            recommended_daily_minutes: 15.0_f32.max(avg_time * 0.8), // Suggest slightly less to avoid burnout
            days_analyzed: recent.len() as u32,
        }
    }

    /// Calculate severity score (0-100)
    fn calculate_severity(accuracy: f32, threshold: f32) -> u32 {
        let gap = threshold - accuracy;
        ((gap / threshold) * 100.0).clamp(0.0, 100.0) as u32
    }

    /// Get display name for question type
    fn question_type_display_name(question_type: &str) -> String {
        match question_type {
            "multiple_choice" => "Multiple Choice".to_string(),
            "typing" => "Typing".to_string(),
            "matching_pairs" => "Matching Pairs".to_string(),
            "sentence_builder" => "Sentence Builder".to_string(),
            other => other.replace('_', " "),
        }
    }

    /// Calculate study consistency (0-100)
    fn calculate_consistency(stats: &[&super::daily::DailyStats]) -> f32 {
        if stats.len() < 2 {
            return 100.0;
        }

        // Count days with activity out of total days in range
        let days_with_activity = stats.iter().filter(|s| s.lessons_completed > 0).count();
        (days_with_activity as f32 / stats.len() as f32) * 100.0
    }
}

/// Analysis of study patterns
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct StudyPatternAnalysis {
    /// Average session length in minutes
    pub average_session_minutes: f32,
    /// Average accuracy across sessions
    pub average_accuracy: f32,
    /// How consistent the user is (0-100)
    pub consistency_score: f32,
    /// Recommended daily study time in minutes
    pub recommended_daily_minutes: f32,
    /// Number of days analyzed
    pub days_analyzed: u32,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_velocity_trend() {
        assert_eq!(VelocityTrend::from_change(20.0), VelocityTrend::Improving);
        assert_eq!(VelocityTrend::from_change(-20.0), VelocityTrend::Declining);
        assert_eq!(VelocityTrend::from_change(5.0), VelocityTrend::Stable);
    }

    #[test]
    fn test_severity_calculation() {
        // Accuracy 50%, threshold 80% -> severity should be around 37
        let severity = LearningAnalytics::calculate_severity(50.0, 80.0);
        assert!(severity > 30 && severity < 40);

        // Accuracy at threshold -> severity 0
        let severity = LearningAnalytics::calculate_severity(80.0, 80.0);
        assert_eq!(severity, 0);
    }

    #[test]
    fn test_estimate_completion() {
        let velocity = LearningVelocity {
            lessons_per_day: 2.0,
            xp_per_day: 100.0,
            words_per_day: 10.0,
            minutes_per_day: 30.0,
            trend: VelocityTrend::Stable,
            change_percent: 0.0,
        };

        let estimate = LearningAnalytics::estimate_level_completion(&velocity, 10);
        assert_eq!(estimate, Some(5));
    }
}
