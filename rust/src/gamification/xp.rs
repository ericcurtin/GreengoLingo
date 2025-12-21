use serde::{Deserialize, Serialize};

/// XP (Experience Points) calculation and tracking
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct XPSystem {
    /// Total XP earned by the user
    total_xp: u32,
    /// XP earned today
    today_xp: u32,
    /// Date of last XP earned (ISO format)
    last_xp_date: Option<String>,
}

impl XPSystem {
    /// Create a new XP system
    pub fn new() -> Self {
        Self {
            total_xp: 0,
            today_xp: 0,
            last_xp_date: None,
        }
    }

    /// Create with existing values (for loading saved progress)
    pub fn with_values(total_xp: u32, today_xp: u32, last_xp_date: Option<String>) -> Self {
        Self {
            total_xp,
            today_xp,
            last_xp_date,
        }
    }

    /// Award XP for completing a lesson
    pub fn award_xp(&mut self, amount: u32, current_date: &str) -> XPAwardResult {
        // Reset today's XP if it's a new day
        if self.last_xp_date.as_deref() != Some(current_date) {
            self.today_xp = 0;
            self.last_xp_date = Some(current_date.to_string());
        }

        let previous_level = self.current_level();
        self.total_xp += amount;
        self.today_xp += amount;
        let new_level = self.current_level();

        XPAwardResult {
            amount_awarded: amount,
            new_total: self.total_xp,
            today_total: self.today_xp,
            leveled_up: new_level > previous_level,
            new_level,
        }
    }

    /// Get total XP
    pub fn total_xp(&self) -> u32 {
        self.total_xp
    }

    /// Get XP earned today
    pub fn today_xp(&self) -> u32 {
        self.today_xp
    }

    /// Calculate current level based on total XP
    /// Uses a simple formula: level = sqrt(total_xp / 100)
    pub fn current_level(&self) -> u32 {
        ((self.total_xp as f64 / 100.0).sqrt().floor() as u32).max(1)
    }

    /// Get XP required for the next level
    pub fn xp_for_next_level(&self) -> u32 {
        let next_level = self.current_level() + 1;
        next_level * next_level * 100
    }

    /// Get progress towards the next level (0.0 to 1.0)
    pub fn level_progress(&self) -> f32 {
        let current = self.current_level();
        let current_threshold = current * current * 100;
        let next_threshold = (current + 1) * (current + 1) * 100;
        let progress_in_level = self.total_xp.saturating_sub(current_threshold);
        let level_range = next_threshold - current_threshold;

        if level_range == 0 {
            1.0
        } else {
            (progress_in_level as f32 / level_range as f32).min(1.0)
        }
    }

    /// Get the title for the current level
    pub fn level_title(&self) -> &'static str {
        match self.current_level() {
            1 => "Novice",
            2 => "Learner",
            3 => "Student",
            4 => "Apprentice",
            5 => "Practitioner",
            6..=7 => "Intermediate",
            8..=10 => "Advanced",
            11..=15 => "Expert",
            16..=20 => "Master",
            _ => "Grandmaster",
        }
    }
}

impl Default for XPSystem {
    fn default() -> Self {
        Self::new()
    }
}

/// Result of awarding XP
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct XPAwardResult {
    /// Amount of XP awarded
    pub amount_awarded: u32,
    /// New total XP
    pub new_total: u32,
    /// Total XP earned today
    pub today_total: u32,
    /// Whether the user leveled up
    pub leveled_up: bool,
    /// Current level after award
    pub new_level: u32,
}

/// Multipliers and bonuses for XP
#[derive(Debug, Clone, Copy)]
pub struct XPMultipliers {
    /// Bonus for perfect lesson (no mistakes)
    pub perfect_lesson: f32,
    /// Bonus for streak (per day of streak, capped)
    pub streak_bonus_per_day: f32,
    /// Maximum streak bonus multiplier
    pub max_streak_bonus: f32,
}

impl Default for XPMultipliers {
    fn default() -> Self {
        Self {
            perfect_lesson: 1.5,
            streak_bonus_per_day: 0.1,
            max_streak_bonus: 2.0,
        }
    }
}

impl XPMultipliers {
    /// Calculate final XP with multipliers
    pub fn calculate_xp(&self, base_xp: u32, perfect: bool, streak_days: u32) -> u32 {
        let mut multiplier = 1.0;

        if perfect {
            multiplier *= self.perfect_lesson;
        }

        let streak_bonus =
            (streak_days as f32 * self.streak_bonus_per_day).min(self.max_streak_bonus - 1.0);
        multiplier += streak_bonus;

        (base_xp as f32 * multiplier).round() as u32
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_xp_award() {
        let mut xp = XPSystem::new();
        let result = xp.award_xp(100, "2024-01-15");

        assert_eq!(result.amount_awarded, 100);
        assert_eq!(result.new_total, 100);
        assert_eq!(xp.total_xp(), 100);
    }

    #[test]
    fn test_level_calculation() {
        let xp = XPSystem::with_values(400, 0, None);
        assert_eq!(xp.current_level(), 2); // sqrt(400/100) = 2
    }

    #[test]
    fn test_level_progress() {
        let xp = XPSystem::with_values(150, 0, None);
        // Level 1: 0-100, Level 2: 100-400
        // At 150, progress in level 1 should be (150-100)/(400-100) = 50/300 ≈ 0.167
        let progress = xp.level_progress();
        assert!(progress > 0.15 && progress < 0.2);
    }

    #[test]
    fn test_xp_multipliers() {
        let multipliers = XPMultipliers::default();

        // Perfect lesson: 1.5x
        let xp = multipliers.calculate_xp(100, true, 0);
        assert_eq!(xp, 150);

        // 5 day streak: 1.0 + 0.5 = 1.5x
        let xp = multipliers.calculate_xp(100, false, 5);
        assert_eq!(xp, 150);

        // Perfect + streak: 1.5 * 1.5 = 2.25... but streak is additive
        // Actually: 1.5 (perfect) + 0.5 (streak) - 1.0 (already counted) = 2.0x
        let xp = multipliers.calculate_xp(100, true, 5);
        assert_eq!(xp, 200); // 1.5 + 0.5 = 2.0
    }
}
