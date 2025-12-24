import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../providers/srs_provider.dart';
import '../../services/haptic_service.dart';
import 'srs_review_screen.dart';
import 'quick_practice_screen.dart';

/// Review mode options
enum ReviewMode {
  srs,
  weakAreas,
  practice,
}

/// Review screen for SRS and practice modes
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srsState = ref.watch(srsProvider);
    final dueCount = srsState.dueCards.length;
    final weakCount = srsState.weakCards.length;
    final totalCards = srsState.cards.length;

    return Scaffold(
      primary: false,
      appBar: AppBar(
        title: const Text('Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Practice & Review',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'Strengthen your vocabulary with spaced repetition',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),

              // SRS Review Card
              _ReviewModeCard(
                title: 'SRS Review',
                subtitle: dueCount > 0
                    ? '$dueCount cards due for review'
                    : 'No cards due today',
                icon: Icons.replay_circle_filled,
                color: AppColors.primaryGreen,
                count: dueCount,
                onTap: dueCount > 0
                    ? () {
                        HapticService.instance.lightTap();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SRSReviewScreen(),
                          ),
                        );
                      }
                    : null,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Weak Areas Card
              _ReviewModeCard(
                title: 'Weak Areas',
                subtitle: weakCount > 0
                    ? '$weakCount words need practice'
                    : 'No weak areas found',
                icon: Icons.warning_amber_rounded,
                color: AppColors.streakOrange,
                count: weakCount,
                onTap: weakCount > 0
                    ? () {
                        HapticService.instance.lightTap();
                        // TODO: Navigate to weak areas practice
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon: Weak areas practice'),
                          ),
                        );
                      }
                    : null,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Random Practice Card
              _ReviewModeCard(
                title: 'Quick Practice',
                subtitle: totalCards > 0
                    ? '$totalCards words available to practice'
                    : 'Complete lessons to add vocabulary',
                icon: Icons.shuffle_rounded,
                color: AppColors.levelB1,
                count: totalCards > 0 ? totalCards : null,
                onTap: totalCards > 0
                    ? () {
                        HapticService.instance.lightTap();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QuickPracticeScreen(),
                          ),
                        );
                      }
                    : null,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Stats section
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Cards',
                      value: '${srsState.stats.totalCards}',
                      icon: Icons.layers,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Mastered',
                      value: '${srsState.stats.masteredCards}',
                      icon: Icons.check_circle,
                      color: AppColors.levelA1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Accuracy',
                      value: '${srsState.stats.averageAccuracy.toStringAsFixed(0)}%',
                      icon: Icons.trending_up,
                      color: AppColors.xpGold,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback? onTap;

  const _ReviewModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(isEnabled ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isEnabled ? color : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isEnabled ? null : Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (count != null && count! > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: isEnabled ? Colors.grey[400] : Colors.grey[300],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
