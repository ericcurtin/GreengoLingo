import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../providers/srs_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../services/haptic_service.dart';

/// SRS flashcard review screen
class SRSReviewScreen extends ConsumerStatefulWidget {
  const SRSReviewScreen({super.key});

  @override
  ConsumerState<SRSReviewScreen> createState() => _SRSReviewScreenState();
}

class _SRSReviewScreenState extends ConsumerState<SRSReviewScreen> {
  bool _showAnswer = false;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _totalReviewed = 0;

  @override
  Widget build(BuildContext context) {
    final srsState = ref.watch(srsProvider);
    final dueCards = srsState.dueCards;

    if (dueCards.isEmpty || _currentIndex >= dueCards.length) {
      return _buildCompletionScreen();
    }

    final card = dueCards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${_currentIndex + 1}/${dueCards.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / dueCards.length,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mastery indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getMasteryColor(card.masteryLevel)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        card.masteryLevel,
                        style: TextStyle(
                          color: _getMasteryColor(card.masteryLevel),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ).animate().fadeIn(),

                    const Spacer(),

                    // Card content
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              card.sourceWord,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            if (_showAnswer) ...[
                              const SizedBox(height: 24),
                              Container(
                                width: 60,
                                height: 2,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                card.targetWord,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                    ),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                              if (card.pronunciation != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  card.pronunciation!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              if (card.exampleSentence != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  card.exampleSentence!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),

                    const Spacer(),

                    // Action buttons
                    if (!_showAnswer)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticService.instance.lightTap();
                            setState(() => _showAnswer = true);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Show Answer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      _buildRatingButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButtons() {
    return Column(
      children: [
        Text(
          'How well did you know this?',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: 'Forgot',
                color: AppColors.error,
                onTap: () => _rateCard(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingButton(
                label: 'Hard',
                color: AppColors.streakOrange,
                onTap: () => _rateCard(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingButton(
                label: 'Good',
                color: AppColors.levelA1,
                onTap: () => _rateCard(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingButton(
                label: 'Easy',
                color: AppColors.primaryGreen,
                onTap: () => _rateCard(5),
              ),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    final accuracy =
        _totalReviewed > 0 ? (_correctCount / _totalReviewed) * 100 : 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 60,
                  ),
                ).animate().scale(),
                const SizedBox(height: 24),
                Text(
                  'Review Complete!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                Text(
                  'You reviewed $_totalReviewed cards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CompletionStat(
                      label: 'Correct',
                      value: '$_correctCount',
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 24),
                    _CompletionStat(
                      label: 'Accuracy',
                      value: '${accuracy.toStringAsFixed(0)}%',
                      color: AppColors.xpGold,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _rateCard(int quality) {
    HapticService.instance.mediumTap();
    final dueCards = ref.read(srsProvider).dueCards;
    final card = dueCards[_currentIndex];

    // Record the review
    ref.read(srsProvider.notifier).reviewCard(card.wordId, quality);
    ref.read(statisticsProvider.notifier).recordSrsReview(correct: quality >= 3);

    setState(() {
      _totalReviewed++;
      if (quality >= 3) _correctCount++;
      _showAnswer = false;
      _currentIndex++;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Review?'),
        content: Text(
          'You have reviewed $_totalReviewed cards. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Color _getMasteryColor(String level) {
    switch (level) {
      case 'New':
        return Colors.grey;
      case 'Learning':
        return AppColors.streakOrange;
      case 'Familiar':
        return AppColors.xpGold;
      case 'Proficient':
        return AppColors.levelA2;
      case 'Mastered':
        return AppColors.primaryGreen;
      default:
        return Colors.grey;
    }
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompletionStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
