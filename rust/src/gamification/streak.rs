use serde::{Deserialize, Serialize};

/// Daily streak tracking
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreakTracker {
    /// Current streak count (days in a row)
    current_streak: u32,
    /// Longest streak ever achieved
    longest_streak: u32,
    /// Date of last activity (ISO format: YYYY-MM-DD)
    last_activity_date: Option<String>,
    /// Whether today's activity has been completed
    completed_today: bool,
}

impl StreakTracker {
    /// Create a new streak tracker
    pub fn new() -> Self {
        Self {
            current_streak: 0,
            longest_streak: 0,
            last_activity_date: None,
            completed_today: false,
        }
    }

    /// Create with existing values (for loading saved progress)
    pub fn with_values(
        current_streak: u32,
        longest_streak: u32,
        last_activity_date: Option<String>,
    ) -> Self {
        Self {
            current_streak,
            longest_streak,
            last_activity_date,
            completed_today: false,
        }
    }

    /// Record activity for the given date
    /// Returns the updated streak status
    pub fn record_activity(&mut self, current_date: &str) -> StreakUpdate {
        let previous_streak = self.current_streak;

        match &self.last_activity_date {
            None => {
                // First ever activity
                self.current_streak = 1;
                self.completed_today = true;
            }
            Some(last_date) => {
                if last_date == current_date {
                    // Already recorded today
                    self.completed_today = true;
                    return StreakUpdate {
                        current_streak: self.current_streak,
                        streak_extended: false,
                        streak_broken: false,
                        is_new_record: false,
                    };
                }

                let days_since = days_between(last_date, current_date);

                if days_since == 1 {
                    // Consecutive day - extend streak
                    self.current_streak += 1;
                    self.completed_today = true;
                } else if days_since > 1 {
                    // Streak broken - reset
                    self.current_streak = 1;
                    self.completed_today = true;
                } else {
                    // Invalid date (in the past) - ignore
                    return StreakUpdate {
                        current_streak: self.current_streak,
                        streak_extended: false,
                        streak_broken: false,
                        is_new_record: false,
                    };
                }
            }
        }

        self.last_activity_date = Some(current_date.to_string());

        // Update longest streak
        let is_new_record = self.current_streak > self.longest_streak;
        if is_new_record {
            self.longest_streak = self.current_streak;
        }

        StreakUpdate {
            current_streak: self.current_streak,
            streak_extended: self.current_streak > previous_streak,
            streak_broken: previous_streak > 1 && self.current_streak == 1,
            is_new_record,
        }
    }

    /// Check if the streak is at risk (no activity today)
    pub fn check_streak_status(&self, current_date: &str) -> StreakStatus {
        match &self.last_activity_date {
            None => StreakStatus::NoStreak,
            Some(last_date) => {
                if last_date == current_date {
                    StreakStatus::CompletedToday
                } else {
                    let days_since = days_between(last_date, current_date);
                    if days_since == 1 {
                        StreakStatus::AtRisk
                    } else {
                        StreakStatus::Broken
                    }
                }
            }
        }
    }

    /// Get current streak count
    pub fn current_streak(&self) -> u32 {
        self.current_streak
    }

    /// Get longest streak ever
    pub fn longest_streak(&self) -> u32 {
        self.longest_streak
    }

    /// Check if activity was completed today
    pub fn completed_today(&self) -> bool {
        self.completed_today
    }

    /// Get the last activity date
    pub fn last_activity_date(&self) -> Option<&str> {
        self.last_activity_date.as_deref()
    }

    /// Reset the tracker (for testing or account reset)
    pub fn reset(&mut self) {
        self.current_streak = 0;
        self.longest_streak = 0;
        self.last_activity_date = None;
        self.completed_today = false;
    }
}

impl Default for StreakTracker {
    fn default() -> Self {
        Self::new()
    }
}

/// Result of recording a streak activity
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreakUpdate {
    /// Current streak after update
    pub current_streak: u32,
    /// Whether the streak was extended
    pub streak_extended: bool,
    /// Whether a previous streak was broken
    pub streak_broken: bool,
    /// Whether this is a new personal record
    pub is_new_record: bool,
}

/// Current streak status
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StreakStatus {
    /// No streak started yet
    NoStreak,
    /// Activity completed today - streak safe
    CompletedToday,
    /// Need to complete today to maintain streak
    AtRisk,
    /// Streak was broken (missed a day)
    Broken,
}

/// Calculate days between two ISO dates (YYYY-MM-DD)
/// Returns positive number if end_date is after start_date
fn days_between(start_date: &str, end_date: &str) -> i32 {
    // Simple date parsing for YYYY-MM-DD format
    fn parse_date(s: &str) -> Option<(i32, u32, u32)> {
        let parts: Vec<&str> = s.split('-').collect();
        if parts.len() != 3 {
            return None;
        }
        let year = parts[0].parse().ok()?;
        let month = parts[1].parse().ok()?;
        let day = parts[2].parse().ok()?;
        Some((year, month, day))
    }

    fn to_days(year: i32, month: u32, day: u32) -> i32 {
        // Simplified Julian day calculation
        let a = (14 - month as i32) / 12;
        let y = year + 4800 - a;
        let m = month as i32 + 12 * a - 3;
        day as i32 + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    }

    match (parse_date(start_date), parse_date(end_date)) {
        (Some((y1, m1, d1)), Some((y2, m2, d2))) => to_days(y2, m2, d2) - to_days(y1, m1, d1),
        _ => 0,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_streak() {
        let mut tracker = StreakTracker::new();
        let update = tracker.record_activity("2024-01-15");

        assert_eq!(update.current_streak, 1);
        assert!(update.streak_extended);
        assert!(!update.streak_broken);
    }

    #[test]
    fn test_extend_streak() {
        let mut tracker = StreakTracker::new();
        tracker.record_activity("2024-01-15");
        let update = tracker.record_activity("2024-01-16");

        assert_eq!(update.current_streak, 2);
        assert!(update.streak_extended);
    }

    #[test]
    fn test_break_streak() {
        let mut tracker = StreakTracker::new();
        tracker.record_activity("2024-01-15");
        tracker.record_activity("2024-01-16");
        let update = tracker.record_activity("2024-01-18"); // Skipped a day

        assert_eq!(update.current_streak, 1);
        assert!(update.streak_broken);
    }

    #[test]
    fn test_streak_status() {
        let mut tracker = StreakTracker::new();
        tracker.record_activity("2024-01-15");

        assert_eq!(
            tracker.check_streak_status("2024-01-15"),
            StreakStatus::CompletedToday
        );
        assert_eq!(
            tracker.check_streak_status("2024-01-16"),
            StreakStatus::AtRisk
        );
        assert_eq!(
            tracker.check_streak_status("2024-01-17"),
            StreakStatus::Broken
        );
    }

    #[test]
    fn test_days_between() {
        assert_eq!(days_between("2024-01-15", "2024-01-16"), 1);
        assert_eq!(days_between("2024-01-15", "2024-01-17"), 2);
        assert_eq!(days_between("2024-01-31", "2024-02-01"), 1);
        assert_eq!(days_between("2024-12-31", "2025-01-01"), 1);
    }
}
