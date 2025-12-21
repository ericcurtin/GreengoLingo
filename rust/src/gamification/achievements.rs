use serde::{Deserialize, Serialize};
use std::collections::HashSet;

/// Defines all available achievements
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum AchievementId {
    // Getting Started
    FirstLesson,
    FirstPerfect,
    FirstLevel,

    // Streaks
    Streak3Days,
    Streak7Days,
    Streak14Days,
    Streak30Days,
    Streak100Days,
    Streak365Days,

    // Lessons
    Lessons10,
    Lessons25,
    Lessons50,
    Lessons100,
    Lessons500,

    // XP Milestones
    Xp100,
    Xp500,
    Xp1000,
    Xp5000,
    Xp10000,

    // Perfect Lessons
    Perfect5,
    Perfect10,
    Perfect25,
    Perfect50,

    // Level Completion
    CompleteA1,
    CompleteA2,
    CompleteB1,
    CompleteB2,
    CompleteC1,
    CompleteC2,

    // Special
    NightOwl,       // Complete lesson after 10pm
    EarlyBird,      // Complete lesson before 6am
    WeekendWarrior, // Complete lessons on 10 weekends
    Polyglot,       // Study more than one language pair
}

impl AchievementId {
    /// Get the display name for this achievement
    pub fn name(&self) -> &'static str {
        match self {
            Self::FirstLesson => "First Steps",
            Self::FirstPerfect => "Perfectionist",
            Self::FirstLevel => "Level Up",

            Self::Streak3Days => "Getting Started",
            Self::Streak7Days => "Week Warrior",
            Self::Streak14Days => "Two Week Streak",
            Self::Streak30Days => "Monthly Dedication",
            Self::Streak100Days => "Century Club",
            Self::Streak365Days => "Year of Learning",

            Self::Lessons10 => "Dedicated Learner",
            Self::Lessons25 => "Knowledge Seeker",
            Self::Lessons50 => "Halfway There",
            Self::Lessons100 => "Century Scholar",
            Self::Lessons500 => "Master Student",

            Self::Xp100 => "XP Beginner",
            Self::Xp500 => "XP Collector",
            Self::Xp1000 => "XP Hunter",
            Self::Xp5000 => "XP Expert",
            Self::Xp10000 => "XP Master",

            Self::Perfect5 => "Accuracy Ace",
            Self::Perfect10 => "Flawless Five",
            Self::Perfect25 => "Precision Pro",
            Self::Perfect50 => "Perfect Master",

            Self::CompleteA1 => "A1 Complete",
            Self::CompleteA2 => "A2 Complete",
            Self::CompleteB1 => "B1 Complete",
            Self::CompleteB2 => "B2 Complete",
            Self::CompleteC1 => "C1 Complete",
            Self::CompleteC2 => "Language Master",

            Self::NightOwl => "Night Owl",
            Self::EarlyBird => "Early Bird",
            Self::WeekendWarrior => "Weekend Warrior",
            Self::Polyglot => "Polyglot",
        }
    }

    /// Get the description for this achievement
    pub fn description(&self) -> &'static str {
        match self {
            Self::FirstLesson => "Complete your first lesson",
            Self::FirstPerfect => "Complete a lesson without any mistakes",
            Self::FirstLevel => "Reach level 2",

            Self::Streak3Days => "Maintain a 3-day streak",
            Self::Streak7Days => "Maintain a 7-day streak",
            Self::Streak14Days => "Maintain a 14-day streak",
            Self::Streak30Days => "Maintain a 30-day streak",
            Self::Streak100Days => "Maintain a 100-day streak",
            Self::Streak365Days => "Maintain a 365-day streak",

            Self::Lessons10 => "Complete 10 lessons",
            Self::Lessons25 => "Complete 25 lessons",
            Self::Lessons50 => "Complete 50 lessons",
            Self::Lessons100 => "Complete 100 lessons",
            Self::Lessons500 => "Complete 500 lessons",

            Self::Xp100 => "Earn 100 XP",
            Self::Xp500 => "Earn 500 XP",
            Self::Xp1000 => "Earn 1,000 XP",
            Self::Xp5000 => "Earn 5,000 XP",
            Self::Xp10000 => "Earn 10,000 XP",

            Self::Perfect5 => "Complete 5 perfect lessons",
            Self::Perfect10 => "Complete 10 perfect lessons",
            Self::Perfect25 => "Complete 25 perfect lessons",
            Self::Perfect50 => "Complete 50 perfect lessons",

            Self::CompleteA1 => "Complete all A1 lessons",
            Self::CompleteA2 => "Complete all A2 lessons",
            Self::CompleteB1 => "Complete all B1 lessons",
            Self::CompleteB2 => "Complete all B2 lessons",
            Self::CompleteC1 => "Complete all C1 lessons",
            Self::CompleteC2 => "Complete all C2 lessons",

            Self::NightOwl => "Complete a lesson after 10pm",
            Self::EarlyBird => "Complete a lesson before 6am",
            Self::WeekendWarrior => "Complete lessons on 10 different weekends",
            Self::Polyglot => "Study more than one language pair",
        }
    }

    /// Get the icon name for this achievement
    pub fn icon(&self) -> &'static str {
        match self {
            Self::FirstLesson => "star",
            Self::FirstPerfect => "check_circle",
            Self::FirstLevel => "trending_up",

            Self::Streak3Days
            | Self::Streak7Days
            | Self::Streak14Days
            | Self::Streak30Days
            | Self::Streak100Days
            | Self::Streak365Days => "local_fire_department",

            Self::Lessons10
            | Self::Lessons25
            | Self::Lessons50
            | Self::Lessons100
            | Self::Lessons500 => "school",

            Self::Xp100 | Self::Xp500 | Self::Xp1000 | Self::Xp5000 | Self::Xp10000 => "bolt",

            Self::Perfect5 | Self::Perfect10 | Self::Perfect25 | Self::Perfect50 => {
                "workspace_premium"
            }

            Self::CompleteA1
            | Self::CompleteA2
            | Self::CompleteB1
            | Self::CompleteB2
            | Self::CompleteC1
            | Self::CompleteC2 => "emoji_events",

            Self::NightOwl => "dark_mode",
            Self::EarlyBird => "wb_sunny",
            Self::WeekendWarrior => "weekend",
            Self::Polyglot => "translate",
        }
    }

    /// Get XP reward for unlocking this achievement
    pub fn xp_reward(&self) -> u32 {
        match self {
            Self::FirstLesson => 10,
            Self::FirstPerfect => 15,
            Self::FirstLevel => 20,

            Self::Streak3Days => 25,
            Self::Streak7Days => 50,
            Self::Streak14Days => 100,
            Self::Streak30Days => 200,
            Self::Streak100Days => 500,
            Self::Streak365Days => 1000,

            Self::Lessons10 => 30,
            Self::Lessons25 => 75,
            Self::Lessons50 => 150,
            Self::Lessons100 => 300,
            Self::Lessons500 => 1000,

            Self::Xp100 => 10,
            Self::Xp500 => 25,
            Self::Xp1000 => 50,
            Self::Xp5000 => 100,
            Self::Xp10000 => 200,

            Self::Perfect5 => 25,
            Self::Perfect10 => 50,
            Self::Perfect25 => 125,
            Self::Perfect50 => 250,

            Self::CompleteA1 => 100,
            Self::CompleteA2 => 150,
            Self::CompleteB1 => 200,
            Self::CompleteB2 => 250,
            Self::CompleteC1 => 300,
            Self::CompleteC2 => 500,

            Self::NightOwl => 15,
            Self::EarlyBird => 15,
            Self::WeekendWarrior => 100,
            Self::Polyglot => 50,
        }
    }

    /// Get all achievement IDs
    pub fn all() -> Vec<AchievementId> {
        vec![
            Self::FirstLesson,
            Self::FirstPerfect,
            Self::FirstLevel,
            Self::Streak3Days,
            Self::Streak7Days,
            Self::Streak14Days,
            Self::Streak30Days,
            Self::Streak100Days,
            Self::Streak365Days,
            Self::Lessons10,
            Self::Lessons25,
            Self::Lessons50,
            Self::Lessons100,
            Self::Lessons500,
            Self::Xp100,
            Self::Xp500,
            Self::Xp1000,
            Self::Xp5000,
            Self::Xp10000,
            Self::Perfect5,
            Self::Perfect10,
            Self::Perfect25,
            Self::Perfect50,
            Self::CompleteA1,
            Self::CompleteA2,
            Self::CompleteB1,
            Self::CompleteB2,
            Self::CompleteC1,
            Self::CompleteC2,
            Self::NightOwl,
            Self::EarlyBird,
            Self::WeekendWarrior,
            Self::Polyglot,
        ]
    }
}

/// An unlocked achievement
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UnlockedAchievement {
    pub id: AchievementId,
    /// When the achievement was unlocked (ISO datetime)
    pub unlocked_at: String,
}

/// Tracks achievement progress and unlocks
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AchievementTracker {
    /// Set of unlocked achievement IDs
    unlocked: HashSet<AchievementId>,
    /// Detailed unlock info
    unlock_history: Vec<UnlockedAchievement>,
    /// Progress counters
    lessons_completed: u32,
    perfect_lessons: u32,
    weekends_with_lessons: u32,
    language_pairs_studied: u32,
}

impl AchievementTracker {
    /// Create a new achievement tracker
    pub fn new() -> Self {
        Self {
            unlocked: HashSet::new(),
            unlock_history: Vec::new(),
            lessons_completed: 0,
            perfect_lessons: 0,
            weekends_with_lessons: 0,
            language_pairs_studied: 0,
        }
    }

    /// Check if an achievement is unlocked
    pub fn is_unlocked(&self, id: AchievementId) -> bool {
        self.unlocked.contains(&id)
    }

    /// Get all unlocked achievements
    pub fn unlocked_achievements(&self) -> &[UnlockedAchievement] {
        &self.unlock_history
    }

    /// Get count of unlocked achievements
    pub fn unlocked_count(&self) -> usize {
        self.unlocked.len()
    }

    /// Get total available achievements
    pub fn total_achievements(&self) -> usize {
        AchievementId::all().len()
    }

    /// Try to unlock an achievement
    /// Returns Some(UnlockedAchievement) if newly unlocked, None if already unlocked or conditions not met
    fn try_unlock(&mut self, id: AchievementId, timestamp: &str) -> Option<UnlockedAchievement> {
        if self.unlocked.contains(&id) {
            return None;
        }

        self.unlocked.insert(id);
        let achievement = UnlockedAchievement {
            id,
            unlocked_at: timestamp.to_string(),
        };
        self.unlock_history.push(achievement.clone());
        Some(achievement)
    }

    /// Check and unlock achievements based on current stats
    pub fn check_achievements(
        &mut self,
        total_xp: u32,
        current_streak: u32,
        current_level: u32,
        timestamp: &str,
    ) -> Vec<UnlockedAchievement> {
        let mut newly_unlocked = Vec::new();

        // XP achievements
        if total_xp >= 100 {
            if let Some(a) = self.try_unlock(AchievementId::Xp100, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if total_xp >= 500 {
            if let Some(a) = self.try_unlock(AchievementId::Xp500, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if total_xp >= 1000 {
            if let Some(a) = self.try_unlock(AchievementId::Xp1000, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if total_xp >= 5000 {
            if let Some(a) = self.try_unlock(AchievementId::Xp5000, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if total_xp >= 10000 {
            if let Some(a) = self.try_unlock(AchievementId::Xp10000, timestamp) {
                newly_unlocked.push(a);
            }
        }

        // Streak achievements
        if current_streak >= 3 {
            if let Some(a) = self.try_unlock(AchievementId::Streak3Days, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if current_streak >= 7 {
            if let Some(a) = self.try_unlock(AchievementId::Streak7Days, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if current_streak >= 14 {
            if let Some(a) = self.try_unlock(AchievementId::Streak14Days, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if current_streak >= 30 {
            if let Some(a) = self.try_unlock(AchievementId::Streak30Days, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if current_streak >= 100 {
            if let Some(a) = self.try_unlock(AchievementId::Streak100Days, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if current_streak >= 365 {
            if let Some(a) = self.try_unlock(AchievementId::Streak365Days, timestamp) {
                newly_unlocked.push(a);
            }
        }

        // Level achievements
        if current_level >= 2 {
            if let Some(a) = self.try_unlock(AchievementId::FirstLevel, timestamp) {
                newly_unlocked.push(a);
            }
        }

        // Lesson count achievements
        if self.lessons_completed >= 10 {
            if let Some(a) = self.try_unlock(AchievementId::Lessons10, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if self.lessons_completed >= 25 {
            if let Some(a) = self.try_unlock(AchievementId::Lessons25, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if self.lessons_completed >= 50 {
            if let Some(a) = self.try_unlock(AchievementId::Lessons50, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if self.lessons_completed >= 100 {
            if let Some(a) = self.try_unlock(AchievementId::Lessons100, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if self.lessons_completed >= 500 {
            if let Some(a) = self.try_unlock(AchievementId::Lessons500, timestamp) {
                newly_unlocked.push(a);
            }
        }

        // Perfect lesson achievements
        if self.perfect_lessons >= 5 {
            if let Some(a) = self.try_unlock(AchievementId::Perfect5, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if self.perfect_lessons >= 10 {
            if let Some(a) = self.try_unlock(AchievementId::Perfect10, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if self.perfect_lessons >= 25 {
            if let Some(a) = self.try_unlock(AchievementId::Perfect25, timestamp) {
                newly_unlocked.push(a);
            }
        }
        if self.perfect_lessons >= 50 {
            if let Some(a) = self.try_unlock(AchievementId::Perfect50, timestamp) {
                newly_unlocked.push(a);
            }
        }

        // Polyglot
        if self.language_pairs_studied >= 2 {
            if let Some(a) = self.try_unlock(AchievementId::Polyglot, timestamp) {
                newly_unlocked.push(a);
            }
        }

        newly_unlocked
    }

    /// Record a completed lesson
    pub fn record_lesson_completion(
        &mut self,
        perfect: bool,
        timestamp: &str,
    ) -> Vec<UnlockedAchievement> {
        self.lessons_completed += 1;
        if perfect {
            self.perfect_lessons += 1;
        }

        let mut newly_unlocked = Vec::new();

        // First lesson achievement
        if self.lessons_completed == 1 {
            if let Some(a) = self.try_unlock(AchievementId::FirstLesson, timestamp) {
                newly_unlocked.push(a);
            }
        }

        // First perfect achievement
        if perfect && self.perfect_lessons == 1 {
            if let Some(a) = self.try_unlock(AchievementId::FirstPerfect, timestamp) {
                newly_unlocked.push(a);
            }
        }

        newly_unlocked
    }

    /// Record studying a new language pair
    pub fn record_language_pair(&mut self) {
        self.language_pairs_studied += 1;
    }

    /// Check time-based achievements (night owl, early bird)
    pub fn check_time_achievement(
        &mut self,
        hour: u32,
        timestamp: &str,
    ) -> Option<UnlockedAchievement> {
        if !(6..22).contains(&hour) {
            if hour >= 22 {
                self.try_unlock(AchievementId::NightOwl, timestamp)
            } else {
                self.try_unlock(AchievementId::EarlyBird, timestamp)
            }
        } else {
            None
        }
    }
}

impl Default for AchievementTracker {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_first_lesson_achievement() {
        let mut tracker = AchievementTracker::new();
        let unlocked = tracker.record_lesson_completion(false, "2024-01-15T10:00:00");

        assert_eq!(unlocked.len(), 1);
        assert_eq!(unlocked[0].id, AchievementId::FirstLesson);
        assert!(tracker.is_unlocked(AchievementId::FirstLesson));
    }

    #[test]
    fn test_first_perfect_achievement() {
        let mut tracker = AchievementTracker::new();
        let unlocked = tracker.record_lesson_completion(true, "2024-01-15T10:00:00");

        assert_eq!(unlocked.len(), 2); // FirstLesson + FirstPerfect
        assert!(tracker.is_unlocked(AchievementId::FirstPerfect));
    }

    #[test]
    fn test_xp_achievements() {
        let mut tracker = AchievementTracker::new();
        let unlocked = tracker.check_achievements(500, 0, 1, "2024-01-15T10:00:00");

        assert!(unlocked.iter().any(|a| a.id == AchievementId::Xp100));
        assert!(unlocked.iter().any(|a| a.id == AchievementId::Xp500));
    }

    #[test]
    fn test_no_duplicate_unlocks() {
        let mut tracker = AchievementTracker::new();
        tracker.check_achievements(500, 0, 1, "2024-01-15T10:00:00");
        let unlocked = tracker.check_achievements(500, 0, 1, "2024-01-15T10:00:00");

        assert!(unlocked.is_empty()); // Already unlocked, no duplicates
    }

    #[test]
    fn test_night_owl() {
        let mut tracker = AchievementTracker::new();
        let achievement = tracker.check_time_achievement(23, "2024-01-15T23:00:00");

        assert!(achievement.is_some());
        assert_eq!(achievement.unwrap().id, AchievementId::NightOwl);
    }
}
