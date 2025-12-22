import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../providers/gamification_provider.dart';
import '../../services/haptic_service.dart';
import '../../widgets/questions/multiple_choice.dart';
import '../../widgets/questions/typing_input.dart';
import '../../widgets/questions/matching_pairs.dart';
import '../../widgets/questions/sentence_builder.dart';

/// Demo lesson screen showing question flow
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _showingFeedback = false;
  bool _lastAnswerCorrect = false;
  bool _lessonComplete = false;

  // Demo questions
  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'multiple_choice',
      'prompt': "How do you say 'Hello' in Portuguese?",
      'options': ['Olá', 'Adeus', 'Obrigado', 'Por favor'],
      'correctIndex': 0,
      'explanation': 'Olá is the standard greeting in Portuguese.',
    },
    {
      'type': 'typing',
      'prompt': "Write 'Thank you' in Portuguese",
      'correctAnswers': ['Obrigado', 'Obrigada'],
      'hint': 'Starts with O...',
    },
    {
      'type': 'matching',
      'prompt': 'Match the greetings',
      'pairs': [
        {'left': 'Hello', 'right': 'Olá'},
        {'left': 'Goodbye', 'right': 'Adeus'},
        {'left': 'Good morning', 'right': 'Bom dia'},
      ],
    },
    {
      'type': 'sentence_builder',
      'prompt': "Build: 'I am happy'",
      'words': ['Eu', 'estou', 'feliz', 'triste'],
      'correctOrder': [0, 1, 2],
    },
    {
      'type': 'multiple_choice',
      'prompt': "What does 'Adeus' mean?",
      'options': ['Hello', 'Goodbye', 'Please', 'Thank you'],
      'correctIndex': 1,
      'explanation': 'Adeus means goodbye in Portuguese.',
    },
  ];

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

  void _completeLesson() {
    final scorePercent = (_correctAnswers / _questions.length * 100).round();
    final isPerfect = scorePercent == 100;

    // Award XP
    ref.read(gamificationProvider.notifier).awardXP(
          10, // base XP
          perfect: isPerfect,
          updateStreak: true,
        );

    if (!_lessonComplete) {
      ref.read(gamificationProvider.notifier).recordActivity();
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
    switch (question['type']) {
      case 'multiple_choice':
        return MultipleChoiceQuestion(
          prompt: question['prompt'],
          options: List<String>.from(question['options']),
          correctIndex: question['correctIndex'],
          explanation: question['explanation'],
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      case 'typing':
        return TypingQuestion(
          prompt: question['prompt'],
          correctAnswers: List<String>.from(question['correctAnswers']),
          hint: question['hint'],
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      case 'matching':
        return MatchingPairsQuestion(
          prompt: question['prompt'],
          pairs: (question['pairs'] as List)
              .map((p) => MapEntry<String, String>(p['left'], p['right']))
              .toList(),
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      case 'sentence_builder':
        return SentenceBuilderQuestion(
          prompt: question['prompt'],
          words: List<String>.from(question['words']),
          correctOrder: List<int>.from(question['correctOrder']),
          enabled: !_showingFeedback,
          onAnswer: _handleAnswer,
        );
      default:
        return const Text('Unknown question type');
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
              const SizedBox(height: 16),
              Text(
                'You got $_correctAnswers out of ${_questions.length} correct',
                style: TextStyle(
                  fontSize: 18,
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
                      '+${isPerfect ? 15 : 10} XP',
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
                  onPressed: () => Navigator.of(context).pop(),
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
              Navigator.of(context).pop();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
