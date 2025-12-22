import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../providers/settings_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../widgets/gamification/xp_bar.dart';
import '../../widgets/gamification/streak_badge.dart';
import '../lesson/lesson_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ = ref.watch(settingsProvider); // Watch for rebuild on settings change
    final xpInfo = ref.watch(xpInfoProvider);
    final streakInfo = ref.watch(streakInfoProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.translate,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'GreengoLingo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: XPBar(
                        totalXP: xpInfo.totalXP,
                        level: xpInfo.currentLevel,
                        progress: xpInfo.levelProgress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    StreakBadge(
                      streak: streakInfo.currentStreak,
                      isActive: streakInfo.completedToday,
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.1),
              ),
            ),

            // Level Selector Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Choose Your Level',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            // Level Cards
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _LevelCard(
                    level: 'A1',
                    name: 'Beginner',
                    lessonCount: 10,
                    completedCount: 2,
                    color: AppColors.levelA1,
                    onTap: () => _openLessons(context, 'A1'),
                  ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
                  _LevelCard(
                    level: 'A2',
                    name: 'Elementary',
                    lessonCount: 12,
                    completedCount: 0,
                    color: AppColors.levelA2,
                    onTap: () => _openLessons(context, 'A2'),
                  ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.9, 0.9)),
                  _LevelCard(
                    level: 'B1',
                    name: 'Intermediate',
                    lessonCount: 15,
                    completedCount: 0,
                    color: AppColors.levelB1,
                    isLocked: true,
                    onTap: null,
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                  _LevelCard(
                    level: 'B2',
                    name: 'Upper Int.',
                    lessonCount: 15,
                    completedCount: 0,
                    color: AppColors.levelB2,
                    isLocked: true,
                    onTap: null,
                  ).animate().fadeIn(delay: 250.ms).scale(begin: const Offset(0.9, 0.9)),
                  _LevelCard(
                    level: 'C1',
                    name: 'Advanced',
                    lessonCount: 18,
                    completedCount: 0,
                    color: AppColors.levelC1,
                    isLocked: true,
                    onTap: null,
                  ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
                  _LevelCard(
                    level: 'C2',
                    name: 'Mastery',
                    lessonCount: 20,
                    completedCount: 0,
                    color: AppColors.levelC2,
                    isLocked: true,
                    onTap: null,
                  ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.9, 0.9)),
                ]),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  void _openLessons(BuildContext context, String level) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LessonScreen()),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String name;
  final int lessonCount;
  final int completedCount;
  final Color color;
  final bool isLocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.name,
    required this.lessonCount,
    required this.completedCount,
    required this.color,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = lessonCount > 0 ? completedCount / lessonCount : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
    final lockedColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? lockedColor : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isLocked ? Colors.grey : color).withOpacity(isDark ? 0.3 : 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey.shade300
                              : color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : color,
                          ),
                        ),
                      ),
                      if (isLocked)
                        Icon(
                          Icons.lock_outline,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLocked ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount / $lessonCount lessons',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? AppColors.progressBackgroundDark : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        isLocked ? Colors.grey : color,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
