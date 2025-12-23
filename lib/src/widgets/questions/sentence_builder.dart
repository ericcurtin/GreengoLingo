import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../services/haptic_service.dart';

class SentenceBuilderQuestion extends StatefulWidget {
  final String prompt;
  final List<String> words;
  final List<int> correctOrder;
  final bool enabled;
  final ValueChanged<bool> onAnswer;

  const SentenceBuilderQuestion({
    super.key,
    required this.prompt,
    required this.words,
    required this.correctOrder,
    required this.enabled,
    required this.onAnswer,
  });

  @override
  State<SentenceBuilderQuestion> createState() => _SentenceBuilderQuestionState();
}

class _SentenceBuilderQuestionState extends State<SentenceBuilderQuestion> {
  final List<int> _selectedIndices = [];
  bool _hasSubmitted = false;
  bool _isCorrect = false;
  List<int> _shuffledDisplayOrder = [];

  @override
  void initState() {
    super.initState();
    _shuffledDisplayOrder = List.generate(widget.words.length, (i) => i)
      ..shuffle(Random());
  }

  void _selectWord(int index) {
    if (!widget.enabled || _hasSubmitted) return;
    if (_selectedIndices.contains(index)) return;

    HapticService.instance.lightTap();

    setState(() {
      _selectedIndices.add(index);
    });
  }

  void _removeWord(int selectedPosition) {
    if (!widget.enabled || _hasSubmitted) return;

    HapticService.instance.lightTap();

    setState(() {
      _selectedIndices.removeAt(selectedPosition);
    });
  }

  void _submit() {
    if (_selectedIndices.isEmpty || _hasSubmitted) return;

    HapticService.instance.lightTap();

    // Check if the selected order matches the correct order
    final isCorrect = _checkAnswer();

    setState(() {
      _hasSubmitted = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect);
  }

  bool _checkAnswer() {
    if (_selectedIndices.length != widget.correctOrder.length) {
      return false;
    }

    for (int i = 0; i < _selectedIndices.length; i++) {
      if (_selectedIndices[i] != widget.correctOrder[i]) {
        return false;
      }
    }

    return true;
  }

  String get _correctSentence {
    return widget.correctOrder.map((i) => widget.words[i]).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        Text(
          widget.prompt,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.3,
          ),
        ).animate().fadeIn(),

        const SizedBox(height: 8),

        Text(
          'Tap words to build the sentence',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 24),

        // Selected words area (answer zone)
        Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasSubmitted
                    ? (_isCorrect ? AppColors.correctLight : AppColors.incorrectLight)
                    : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasSubmitted
                      ? (_isCorrect ? AppColors.correct : AppColors.incorrect)
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  width: 2,
                ),
              ),
              child: _selectedIndices.isEmpty
                  ? Center(
                      child: Text(
                        'Your sentence will appear here',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedIndices.asMap().entries.map((entry) {
                    final position = entry.key;
                    final wordIndex = entry.value;
                    final word = widget.words[wordIndex];

                    return GestureDetector(
                      onTap: () => _removeWord(position),
                      child: _WordChip(
                        word: word,
                        isInAnswer: true,
                        isCorrect: _hasSubmitted ? _isCorrect : null,
                      ),
                    );
                  }).toList(),
                ),
            );
          },
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 24),

        // Word bank
        Text(
          'Word Bank',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _shuffledDisplayOrder.asMap().entries.map((entry) {
            final displayIndex = entry.key;
            final originalIndex = entry.value;
            final word = widget.words[originalIndex];
            final isUsed = _selectedIndices.contains(originalIndex);

            return GestureDetector(
              onTap: isUsed ? null : () => _selectWord(originalIndex),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isUsed ? 0.4 : 1.0,
                child: _WordChip(
                  word: word,
                  isInAnswer: false,
                  isDisabled: isUsed,
                ),
              ),
            ).animate().fadeIn(delay: (200 + displayIndex * 50).ms).scale(begin: const Offset(0.9, 0.9));
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Submit button
        if (!_hasSubmitted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedIndices.isNotEmpty ? _submit : null,
              child: const Text('Check'),
            ),
          ).animate().fadeIn(delay: 400.ms),

        // Show correct answer if wrong
        if (_hasSubmitted && !_isCorrect)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correct answer:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _correctSentence,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool isInAnswer;
  final bool isDisabled;
  final bool? isCorrect;

  const _WordChip({
    required this.word,
    required this.isInAnswer,
    this.isDisabled = false,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
    final defaultBorderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    if (isCorrect != null) {
      if (isCorrect!) {
        backgroundColor = AppColors.correct;
        textColor = Colors.white;
        borderColor = AppColors.correct;
      } else {
        backgroundColor = AppColors.incorrect;
        textColor = Colors.white;
        borderColor = AppColors.incorrect;
      }
    } else if (isInAnswer) {
      backgroundColor = AppTheme.primaryGreen;
      textColor = Colors.white;
      borderColor = AppTheme.primaryGreen;
    } else if (isDisabled) {
      backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
      borderColor = defaultBorderColor;
    } else {
      backgroundColor = surfaceColor;
      textColor = Theme.of(context).colorScheme.onSurface;
      borderColor = defaultBorderColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isInAnswer || isDisabled
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
