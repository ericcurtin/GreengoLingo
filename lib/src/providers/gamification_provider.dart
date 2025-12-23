import 'package:flutter_riverpod/flutter_riverpod.dart';

/// XP information for display
class XPInfo {
  final int totalXP;
  final int todayXP;
  final int currentLevel;
  final double levelProgress;
  final int xpForNextLevel;
  final String levelTitle;

  const XPInfo({
    required this.totalXP,
    required this.todayXP,
    required this.currentLevel,
    required this.levelProgress,
    required this.xpForNextLevel,
    required this.levelTitle,
  });

  factory XPInfo.initial() => const XPInfo(
        totalXP: 0,
        todayXP: 0,
        currentLevel: 1,
        levelProgress: 0.0,
        xpForNextLevel: 100,
        levelTitle: 'Novice',
      );

  XPInfo copyWith({
    int? totalXP,
    int? todayXP,
    int? currentLevel,
    double? levelProgress,
    int? xpForNextLevel,
    String? levelTitle,
  }) {
    return XPInfo(
      totalXP: totalXP ?? this.totalXP,
      todayXP: todayXP ?? this.todayXP,
      currentLevel: currentLevel ?? this.currentLevel,
      levelProgress: levelProgress ?? this.levelProgress,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      levelTitle: levelTitle ?? this.levelTitle,
    );
  }
}

/// Streak information for display
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final bool completedToday;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.completedToday,
  });

  factory StreakInfo.initial() => const StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        completedToday: false,
      );

  StreakInfo copyWith({
    int? currentStreak,
    int? longestStreak,
    bool? completedToday,
  }) {
    return StreakInfo(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedToday: completedToday ?? this.completedToday,
    );
  }
}

/// Achievement definition
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// Gamification state combining XP, streaks, and achievements
class GamificationState {
  final XPInfo xp;
  final StreakInfo streak;
  final List<Achievement> achievements;

  const GamificationState({
    required this.xp,
    required this.streak,
    required this.achievements,
  });

  factory GamificationState.initial() => GamificationState(
        xp: XPInfo.initial(),
        streak: StreakInfo.initial(),
        achievements: _defaultAchievements,
      );

  GamificationState copyWith({
    XPInfo? xp,
    StreakInfo? streak,
    List<Achievement>? achievements,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      achievements: achievements ?? this.achievements,
    );
  }

  int get unlockedAchievementCount =>
      achievements.where((a) => a.isUnlocked).length;
}

/// Default achievement definitions
const List<Achievement> _defaultAchievements = [
  // Getting Started
  Achievement(
    id: 'first_lesson',
    name: 'First Steps',
    description: 'Complete your first lesson',
    icon: 'star',
    xpReward: 10,
  ),
  Achievement(
    id: 'first_perfect',
    name: 'Perfectionist',
    description: 'Complete a lesson without any mistakes',
    icon: 'check_circle',
    xpReward: 15,
  ),
  // Streaks
  Achievement(
    id: 'streak_3',
    name: 'Getting Started',
    description: 'Maintain a 3-day streak',
    icon: 'local_fire_department',
    xpReward: 25,
  ),
  Achievement(
    id: 'streak_7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    icon: 'local_fire_department',
    xpReward: 50,
  ),
  Achievement(
    id: 'streak_30',
    name: 'Monthly Dedication',
    description: 'Maintain a 30-day streak',
    icon: 'local_fire_department',
    xpReward: 200,
  ),
  // Lessons
  Achievement(
    id: 'lessons_10',
    name: 'Dedicated Learner',
    description: 'Complete 10 lessons',
    icon: 'school',
    xpReward: 30,
  ),
  Achievement(
    id: 'lessons_50',
    name: 'Halfway There',
    description: 'Complete 50 lessons',
    icon: 'school',
    xpReward: 150,
  ),
  // XP
  Achievement(
    id: 'xp_500',
    name: 'XP Collector',
    description: 'Earn 500 XP',
    icon: 'bolt',
    xpReward: 25,
  ),
  Achievement(
    id: 'xp_1000',
    name: 'XP Hunter',
    description: 'Earn 1,000 XP',
    icon: 'bolt',
    xpReward: 50,
  ),
];

/// Gamification notifier
class GamificationNotifier extends Notifier<GamificationState> {
  @override
  GamificationState build() {
    return GamificationState.initial();
  }

  /// Award XP and update state
  void awardXP(int amount, {bool perfect = false, bool updateStreak = true}) {
    final current = state;

    // Calculate with multipliers
    var totalAmount = amount;
    if (perfect) {
      totalAmount = (totalAmount * 1.5).round();
    }

    // Add streak bonus
    final streakBonus = (current.streak.currentStreak * 0.1).clamp(0.0, 1.0);
    totalAmount = (totalAmount * (1 + streakBonus)).round();

    // Update XP
    final newTotalXP = current.xp.totalXP + totalAmount;
    final newTodayXP = current.xp.todayXP + totalAmount;
    final newLevel = _calculateLevel(newTotalXP);
    final levelProgress = _calculateLevelProgress(newTotalXP, newLevel);
    final xpForNext = _xpForLevel(newLevel + 1);

    final updatedXP = current.xp.copyWith(
      totalXP: newTotalXP,
      todayXP: newTodayXP,
      currentLevel: newLevel,
      levelProgress: levelProgress,
      xpForNextLevel: xpForNext,
      levelTitle: _getLevelTitle(newLevel),
    );

    state = current.copyWith(xp: updatedXP);
  }

  /// Record streak activity (only increments streak once per day)
  void recordActivity() {
    final current = state;

    // Only increment streak if this is the first activity today
    if (current.streak.completedToday) {
      return; // Already recorded activity for today
    }

    final newStreak = current.streak.currentStreak + 1;
    final newLongest = newStreak > current.streak.longestStreak
        ? newStreak
        : current.streak.longestStreak;

    state = current.copyWith(
      streak: current.streak.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        completedToday: true,
      ),
    );
  }

  /// Unlock an achievement
  void unlockAchievement(String id) {
    final current = state;
    final achievements = current.achievements.map((a) {
      if (a.id == id && !a.isUnlocked) {
        return a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return a;
    }).toList();

    state = current.copyWith(achievements: achievements);
  }

  int _calculateLevel(int totalXP) {
    return ((totalXP / 100).sqrt().floor()).clamp(1, 100);
  }

  double _calculateLevelProgress(int totalXP, int currentLevel) {
    final currentThreshold = _xpForLevel(currentLevel);
    final nextThreshold = _xpForLevel(currentLevel + 1);
    final progressInLevel = totalXP - currentThreshold;
    final levelRange = nextThreshold - currentThreshold;
    return (progressInLevel / levelRange).clamp(0.0, 1.0);
  }

  int _xpForLevel(int level) => level * level * 100;

  String _getLevelTitle(int level) {
    if (level <= 1) return 'Novice';
    if (level <= 2) return 'Learner';
    if (level <= 3) return 'Student';
    if (level <= 4) return 'Apprentice';
    if (level <= 5) return 'Practitioner';
    if (level <= 7) return 'Intermediate';
    if (level <= 10) return 'Advanced';
    if (level <= 15) return 'Expert';
    if (level <= 20) return 'Master';
    return 'Grandmaster';
  }
}

/// Provider for gamification state
final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
        GamificationNotifier.new);

/// Provider for just XP info
final xpInfoProvider = Provider<XPInfo>((ref) {
  return ref.watch(gamificationProvider).xp;
});

/// Provider for just streak info
final streakInfoProvider = Provider<StreakInfo>((ref) {
  return ref.watch(gamificationProvider).streak;
});

/// Provider for achievements
final achievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(gamificationProvider).achievements;
});

/// Provider for unlocked achievement count
final unlockedAchievementCountProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).unlockedAchievementCount;
});

extension on double {
  double sqrt() => this < 0
      ? 0
      : this == 0
          ? 0
          : _sqrt(this);

  double _sqrt(double n) {
    double x = n;
    double y = 1;
    const e = 0.000001;
    while (x - y > e) {
      x = (x + y) / 2;
      y = n / x;
    }
    return x;
  }
}
