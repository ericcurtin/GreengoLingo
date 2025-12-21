//! Gamification systems: XP, streaks, and achievements

pub mod achievements;
pub mod streak;
pub mod xp;

// Re-export commonly used types
pub use achievements::{AchievementId, AchievementTracker, UnlockedAchievement};
pub use streak::{StreakStatus, StreakTracker, StreakUpdate};
pub use xp::{XPAwardResult, XPMultipliers, XPSystem};
