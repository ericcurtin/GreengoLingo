import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/lesson_service.dart';
import '../../services/haptic_service.dart';
import '../../widgets/questions/multiple_choice.dart';
import '../../widgets/questions/typing_input.dart';
import '../../widgets/questions/matching_pairs.dart';
import '../../widgets/questions/sentence_builder.dart';

/// Lesson screen that displays questions from a lesson
class LessonScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  final String level;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.level,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _showingFeedback = false;
  bool _lastAnswerCorrect = false;
  bool _lessonComplete = false;

  List<Map<String, dynamic>> get _questions => widget.lesson.questions;

  void _handleAnswer(bool isCorrect) {
    setState(() {
      _showingFeedback = true;
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
        HapticService.instance.success();
      } else {
        HapticService.instance.error();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _showingFeedback = false;
      });
    } else {
      _completeLesson();
    }
  }

  void _completeLesson() async {
    final scorePercent = (_correctAnswers / _questions.length * 100).round();
    final isPerfect = scorePercent == 100;

    // Award XP using lesson's XP reward
    ref.read(gamificationProvider.notifier).awardXP(
          widget.lesson.xpReward,
          perfect: isPerfect,
          updateStreak: true,
        );

    if (!_lessonComplete) {
      ref.read(gamificationProvider.notifier).recordActivity();

      // Mark lesson as completed in progress tracker
      await ref.read(progressProvider.notifier).completeLesson(
            widget.level,
            widget.lesson.id,
          );
    }

    setState(() {
      _lessonComplete = true;
    });

    HapticService.instance.achievement();
  }

  @override
  Widget build(BuildContext context) {
    if (_lessonComplete) {
      return _buildCompletionScreen();
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.lesson.title),
        ),
        body: const Center(
          child: Text('No questions available for this lesson.'),
        ),
      );
    }

    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.progressBackgroundDark
                : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
            minHeight: 8,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestion + 1}/${_questions.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildQuestion(question),
              ),
            ),
            if (_showingFeedback) _buildFeedbackBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    final type = question['type'] as String;

    switch (type) {
      case 'multiple_choice':
        return MultipleChoiceQuestion(
          key: ValueKey('question_$_currentQuestion'),
          prompt: question['prompt'] as String,
          options: List<String>.from(question['options'] as List),
          correctIndex: question['correct_index'] as int? ?? question['correctIndex'] as int? ?? 0,
          explanation: question['explanation'] as String?,
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      case 'typing':
        return TypingQuestion(
          key: ValueKey('question_$_currentQuestion'),
          prompt: question['prompt'] as String,
          correctAnswers: List<String>.from(question['correct_answers'] as List? ?? question['correctAnswers'] as List? ?? []),
          hint: question['hint'] as String?,
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      case 'matching_pairs':
      case 'matching':
        final pairs = question['pairs'] as List;
        return MatchingPairsQuestion(
          key: ValueKey('question_$_currentQuestion'),
          prompt: question['prompt'] as String,
          pairs: pairs.map((p) {
            if (p is List) {
              return MapEntry<String, String>(p[0] as String, p[1] as String);
            } else if (p is Map) {
              return MapEntry<String, String>(
                (p['left'] ?? p[0]) as String,
                (p['right'] ?? p[1]) as String,
              );
            }
            return const MapEntry<String, String>('', '');
          }).toList(),
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      case 'sentence_builder':
        return SentenceBuilderQuestion(
          key: ValueKey('question_$_currentQuestion'),
          prompt: question['prompt'] as String,
          words: List<String>.from(question['words'] as List),
          correctOrder: List<int>.from(question['correct_order'] as List? ?? question['correctOrder'] as List? ?? []),
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      default:
        return Text('Unknown question type: $type');
    }
  }

  Widget _buildFeedbackBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lastAnswerCorrect
            ? AppColors.correctLight
            : AppColors.incorrectLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                color: _lastAnswerCorrect
                    ? AppColors.correct
                    : AppColors.incorrect,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _lastAnswerCorrect ? 'Correct!' : 'Not quite...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _lastAnswerCorrect
                        ? AppColors.correct
                        : AppColors.incorrect,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _lastAnswerCorrect
                    ? AppColors.correct
                    : AppColors.incorrect,
              ),
              child: Text(
                _currentQuestion < _questions.length - 1
                    ? 'Continue'
                    : 'Finish',
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildCompletionScreen() {
    final scorePercent = (_correctAnswers / _questions.length * 100).round();
    final isPerfect = scorePercent == 100;
    final xpEarned = isPerfect
        ? (widget.lesson.xpReward * 1.5).round()
        : widget.lesson.xpReward;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPerfect ? Icons.star : Icons.celebration,
                size: 80,
                color: isPerfect ? AppColors.xpGold : AppTheme.primaryGreen,
              ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                isPerfect ? 'Perfect!' : 'Lesson Complete!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 8),
              Text(
                widget.lesson.title,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 16),
              Text(
                'You got $_correctAnswers out of ${_questions.length} correct',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 32),
              // Score circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryGreen,
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$scorePercent%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ).animate().scale(delay: 600.ms),
              const SizedBox(height: 32),
              // XP earned
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.xpGold),
                    const SizedBox(width: 8),
                    Text(
                      '+$xpEarned XP',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.xpGold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true), // Return true to indicate completion
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Lesson?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false); // Return false to indicate no completion
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
