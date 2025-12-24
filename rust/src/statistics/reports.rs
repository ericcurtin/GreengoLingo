//! Periodic summary reports (weekly and monthly)

use super::daily::StatisticsTracker;
use serde::{Deserialize, Serialize};

/// Weekly summary report
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeeklySummary {
    /// Week start date (Monday) in ISO format
    pub week_start: String,
    /// Week end date (Sunday) in ISO format
    pub week_end: String,
    /// Total XP earned this week
    pub total_xp: u32,
    /// Lessons completed
    pub lessons_completed: u32,
    /// Total time in seconds
    pub time_spent_seconds: u32,
    /// Days with activity
    pub days_active: u32,
    /// Average accuracy
    pub average_accuracy: f32,
    /// New words learned
    pub words_learned: u32,
    /// SRS reviews completed
    pub srs_reviews: u32,
    /// Best day (by XP)
    pub best_day: Option<String>,
    /// Best day XP
    pub best_day_xp: u32,
    /// Comparison to previous week
    pub vs_previous_week: WeekComparison,
    /// Streak maintained
    pub streak_maintained: bool,
}

/// Comparison to previous week
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct WeekComparison {
    /// XP change from previous week
    pub xp_change: i32,
    /// XP change percentage
    pub xp_change_percent: f32,
    /// Lessons change from previous week
    pub lessons_change: i32,
    /// Time change in seconds
    pub time_change: i32,
    /// Accuracy change
    pub accuracy_change: f32,
}

impl WeeklySummary {
    /// Generate weekly summary from statistics tracker
    pub fn generate(
        stats: &StatisticsTracker,
        week_start: &str,
        week_end: &str,
        previous_week: Option<&WeeklySummary>,
        streak_maintained: bool,
    ) -> Self {
        let daily_stats = stats.get_range(week_start, week_end);

        let total_xp: u32 = daily_stats.iter().map(|s| s.xp_earned).sum();
        let lessons_completed: u32 = daily_stats.iter().map(|s| s.lessons_completed).sum();
        let time_spent_seconds: u32 = daily_stats.iter().map(|s| s.time_spent_seconds).sum();
        let days_active = daily_stats.len() as u32;
        let words_learned: u32 = daily_stats.iter().map(|s| s.new_words_learned).sum();
        let srs_reviews: u32 = daily_stats.iter().map(|s| s.srs_reviews).sum();

        let total_questions: u32 = daily_stats.iter().map(|s| s.questions_answered).sum();
        let total_correct: u32 = daily_stats.iter().map(|s| s.questions_correct).sum();
        let average_accuracy = if total_questions > 0 {
            (total_correct as f32 / total_questions as f32) * 100.0
        } else {
            0.0
        };

        // Find best day
        let (best_day, best_day_xp) = daily_stats
            .iter()
            .max_by_key(|s| s.xp_earned)
            .map(|s| (Some(s.date.clone()), s.xp_earned))
            .unwrap_or((None, 0));

        // Calculate comparison
        let vs_previous_week = if let Some(prev) = previous_week {
            WeekComparison {
                xp_change: total_xp as i32 - prev.total_xp as i32,
                xp_change_percent: if prev.total_xp > 0 {
                    ((total_xp as f32 - prev.total_xp as f32) / prev.total_xp as f32) * 100.0
                } else {
                    0.0
                },
                lessons_change: lessons_completed as i32 - prev.lessons_completed as i32,
                time_change: time_spent_seconds as i32 - prev.time_spent_seconds as i32,
                accuracy_change: average_accuracy - prev.average_accuracy,
            }
        } else {
            WeekComparison::default()
        };

        Self {
            week_start: week_start.to_string(),
            week_end: week_end.to_string(),
            total_xp,
            lessons_completed,
            time_spent_seconds,
            days_active,
            average_accuracy,
            words_learned,
            srs_reviews,
            best_day,
            best_day_xp,
            vs_previous_week,
            streak_maintained,
        }
    }

    /// Get time spent in hours
    pub fn hours_studied(&self) -> f32 {
        self.time_spent_seconds as f32 / 3600.0
    }

    /// Get average XP per active day
    pub fn xp_per_active_day(&self) -> f32 {
        if self.days_active == 0 {
            0.0
        } else {
            self.total_xp as f32 / self.days_active as f32
        }
    }
}

/// Monthly summary report
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonthlySummary {
    /// Year
    pub year: u32,
    /// Month (1-12)
    pub month: u32,
    /// Month name
    pub month_name: String,
    /// Total XP earned
    pub total_xp: u32,
    /// Lessons completed
    pub lessons_completed: u32,
    /// Total time in seconds
    pub time_spent_seconds: u32,
    /// Days with activity
    pub days_active: u32,
    /// Total days in month
    pub days_in_month: u32,
    /// Average accuracy
    pub average_accuracy: f32,
    /// Words learned
    pub words_learned: u32,
    /// SRS reviews
    pub srs_reviews: u32,
    /// Best week
    pub best_week: Option<String>,
    /// Best week XP
    pub best_week_xp: u32,
    /// Weekly breakdown (up to 5 weeks)
    pub weekly_breakdown: Vec<WeeklyXPBreakdown>,
    /// Comparison to previous month
    pub vs_previous_month: MonthComparison,
    /// Levels practiced
    pub levels_practiced: Vec<String>,
    /// Most practiced level
    pub most_practiced_level: Option<String>,
}

/// Weekly XP breakdown for monthly report
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeeklyXPBreakdown {
    pub week_number: u32,
    pub xp: u32,
}

/// Comparison to previous month
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct MonthComparison {
    pub xp_change: i32,
    pub xp_change_percent: f32,
    pub lessons_change: i32,
    pub time_change: i32,
    pub accuracy_change: f32,
}

impl MonthlySummary {
    /// Generate monthly summary
    pub fn generate(
        stats: &StatisticsTracker,
        year: u32,
        month: u32,
        previous_month: Option<&MonthlySummary>,
    ) -> Self {
        let month_start = format!("{:04}-{:02}-01", year, month);
        let days_in_month = Self::days_in_month(year, month);
        let month_end = format!("{:04}-{:02}-{:02}", year, month, days_in_month);

        let daily_stats = stats.get_range(&month_start, &month_end);

        let total_xp: u32 = daily_stats.iter().map(|s| s.xp_earned).sum();
        let lessons_completed: u32 = daily_stats.iter().map(|s| s.lessons_completed).sum();
        let time_spent_seconds: u32 = daily_stats.iter().map(|s| s.time_spent_seconds).sum();
        let days_active = daily_stats.len() as u32;
        let words_learned: u32 = daily_stats.iter().map(|s| s.new_words_learned).sum();
        let srs_reviews: u32 = daily_stats.iter().map(|s| s.srs_reviews).sum();

        let total_questions: u32 = daily_stats.iter().map(|s| s.questions_answered).sum();
        let total_correct: u32 = daily_stats.iter().map(|s| s.questions_correct).sum();
        let average_accuracy = if total_questions > 0 {
            (total_correct as f32 / total_questions as f32) * 100.0
        } else {
            0.0
        };

        // Collect levels practiced
        let mut levels_practiced: Vec<String> = daily_stats
            .iter()
            .flat_map(|s| s.levels_practiced.iter().cloned())
            .collect();
        levels_practiced.sort();
        levels_practiced.dedup();

        // Find most practiced level (would need more data to determine accurately)
        let most_practiced_level = levels_practiced.first().cloned();

        // Calculate weekly breakdown
        let weekly_breakdown = Self::calculate_weekly_breakdown(&daily_stats);
        let (best_week, best_week_xp) = weekly_breakdown
            .iter()
            .max_by_key(|w| w.xp)
            .map(|w| (Some(format!("Week {}", w.week_number)), w.xp))
            .unwrap_or((None, 0));

        // Calculate comparison
        let vs_previous_month = if let Some(prev) = previous_month {
            MonthComparison {
                xp_change: total_xp as i32 - prev.total_xp as i32,
                xp_change_percent: if prev.total_xp > 0 {
                    ((total_xp as f32 - prev.total_xp as f32) / prev.total_xp as f32) * 100.0
                } else {
                    0.0
                },
                lessons_change: lessons_completed as i32 - prev.lessons_completed as i32,
                time_change: time_spent_seconds as i32 - prev.time_spent_seconds as i32,
                accuracy_change: average_accuracy - prev.average_accuracy,
            }
        } else {
            MonthComparison::default()
        };

        Self {
            year,
            month,
            month_name: Self::month_name(month),
            total_xp,
            lessons_completed,
            time_spent_seconds,
            days_active,
            days_in_month,
            average_accuracy,
            words_learned,
            srs_reviews,
            best_week,
            best_week_xp,
            weekly_breakdown,
            vs_previous_month,
            levels_practiced,
            most_practiced_level,
        }
    }

    /// Get hours studied
    pub fn hours_studied(&self) -> f32 {
        self.time_spent_seconds as f32 / 3600.0
    }

    /// Get activity rate (days active / days in month)
    pub fn activity_rate(&self) -> f32 {
        (self.days_active as f32 / self.days_in_month as f32) * 100.0
    }

    /// Get number of days in a month
    fn days_in_month(year: u32, month: u32) -> u32 {
        match month {
            1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
            4 | 6 | 9 | 11 => 30,
            2 => {
                if (year.is_multiple_of(4) && !year.is_multiple_of(100)) || year.is_multiple_of(400)
                {
                    29
                } else {
                    28
                }
            }
            _ => 30,
        }
    }

    /// Get month name
    fn month_name(month: u32) -> String {
        match month {
            1 => "January",
            2 => "February",
            3 => "March",
            4 => "April",
            5 => "May",
            6 => "June",
            7 => "July",
            8 => "August",
            9 => "September",
            10 => "October",
            11 => "November",
            12 => "December",
            _ => "Unknown",
        }
        .to_string()
    }

    /// Calculate weekly breakdown from daily stats
    fn calculate_weekly_breakdown(
        daily_stats: &[&super::daily::DailyStats],
    ) -> Vec<WeeklyXPBreakdown> {
        // Group by week (1-5)
        let mut weeks: Vec<u32> = vec![0; 5];

        for stat in daily_stats {
            // Extract day from date
            if let Some(day_str) = stat.date.split('-').nth(2) {
                if let Ok(day) = day_str.parse::<u32>() {
                    let week_index = ((day - 1) / 7).min(4) as usize;
                    weeks[week_index] += stat.xp_earned;
                }
            }
        }

        weeks
            .into_iter()
            .enumerate()
            .filter(|(_, xp)| *xp > 0)
            .map(|(i, xp)| WeeklyXPBreakdown {
                week_number: i as u32 + 1,
                xp,
            })
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_days_in_month() {
        assert_eq!(MonthlySummary::days_in_month(2024, 1), 31);
        assert_eq!(MonthlySummary::days_in_month(2024, 2), 29); // Leap year
        assert_eq!(MonthlySummary::days_in_month(2023, 2), 28);
        assert_eq!(MonthlySummary::days_in_month(2024, 4), 30);
    }

    #[test]
    fn test_month_name() {
        assert_eq!(MonthlySummary::month_name(1), "January");
        assert_eq!(MonthlySummary::month_name(12), "December");
    }

    #[test]
    fn test_weekly_summary_hours() {
        let summary = WeeklySummary {
            week_start: "2024-01-15".to_string(),
            week_end: "2024-01-21".to_string(),
            total_xp: 500,
            lessons_completed: 10,
            time_spent_seconds: 3600, // 1 hour
            days_active: 5,
            average_accuracy: 85.0,
            words_learned: 50,
            srs_reviews: 100,
            best_day: Some("2024-01-18".to_string()),
            best_day_xp: 150,
            vs_previous_week: WeekComparison::default(),
            streak_maintained: true,
        };

        assert_eq!(summary.hours_studied(), 1.0);
        assert_eq!(summary.xp_per_active_day(), 100.0);
    }
}
