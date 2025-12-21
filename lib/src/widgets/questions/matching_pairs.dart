import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../services/haptic_service.dart';

class MatchingPairsQuestion extends StatefulWidget {
  final String prompt;
  final List<MapEntry<String, String>> pairs;
  final bool enabled;
  final ValueChanged<bool> onAnswer;

  const MatchingPairsQuestion({
    super.key,
    required this.prompt,
    required this.pairs,
    required this.enabled,
    required this.onAnswer,
  });

  @override
  State<MatchingPairsQuestion> createState() => _MatchingPairsQuestionState();
}

class _MatchingPairsQuestionState extends State<MatchingPairsQuestion> {
  String? _selectedLeft;
  String? _selectedRight;
  final Map<String, String> _matches = {};
  final Set<String> _matchedLeft = {};
  final Set<String> _matchedRight = {};
  bool _hasSubmitted = false;
  late List<String> _shuffledRight;

  @override
  void initState() {
    super.initState();
    // Shuffle the right column
    _shuffledRight = widget.pairs.map((p) => p.value).toList()..shuffle();
  }

  void _selectLeft(String item) {
    if (!widget.enabled || _matchedLeft.contains(item) || _hasSubmitted) return;
    HapticService.instance.selection();
    setState(() {
      _selectedLeft = item;
      _tryMatch();
    });
  }

  void _selectRight(String item) {
    if (!widget.enabled || _matchedRight.contains(item) || _hasSubmitted) return;
    HapticService.instance.selection();
    setState(() {
      _selectedRight = item;
      _tryMatch();
    });
  }

  void _tryMatch() {
    if (_selectedLeft != null && _selectedRight != null) {
      // Record the match
      _matches[_selectedLeft!] = _selectedRight!;
      _matchedLeft.add(_selectedLeft!);
      _matchedRight.add(_selectedRight!);

      // Check if this match is correct for visual feedback
      final correctRight = widget.pairs
          .firstWhere((p) => p.key == _selectedLeft)
          .value;
      final isCorrect = _selectedRight == correctRight;

      if (isCorrect) {
        HapticService.instance.success();
      } else {
        HapticService.instance.error();
      }

      // Clear selection
      _selectedLeft = null;
      _selectedRight = null;

      // Check if all matched
      if (_matches.length == widget.pairs.length) {
        _submit();
      }
    }
  }

  void _submit() {
    // Check all matches
    int correct = 0;
    for (final pair in widget.pairs) {
      if (_matches[pair.key] == pair.value) {
        correct++;
      }
    }

    final isAllCorrect = correct == widget.pairs.length;

    setState(() {
      _hasSubmitted = true;
    });

    widget.onAnswer(isAllCorrect);
  }

  bool _isMatchCorrect(String leftItem) {
    final correctRight = widget.pairs.firstWhere((p) => p.key == leftItem).value;
    return _matches[leftItem] == correctRight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        Text(
          widget.prompt,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            height: 1.3,
          ),
        ).animate().fadeIn(),

        const SizedBox(height: 8),

        Text(
          'Tap to match pairs',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMedium,
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 24),

        // Matching grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: widget.pairs.map((pair) {
                  final item = pair.key;
                  final isMatched = _matchedLeft.contains(item);
                  final isSelected = _selectedLeft == item;
                  final showResult = _hasSubmitted && isMatched;
                  final isCorrect = showResult && _isMatchCorrect(item);

                  return _MatchItem(
                    text: item,
                    isSelected: isSelected,
                    isMatched: isMatched,
                    isCorrect: isCorrect,
                    showResult: showResult,
                    onTap: () => _selectLeft(item),
                  );
                }).toList(),
              ),
            ),

            // Connection indicators
            const SizedBox(width: 16),

            // Right column
            Expanded(
              child: Column(
                children: _shuffledRight.map((item) {
                  final isMatched = _matchedRight.contains(item);
                  final isSelected = _selectedRight == item;

                  // Find if this right item was correctly matched
                  final matchedLeftItem = _matches.entries
                      .where((e) => e.value == item)
                      .firstOrNull
                      ?.key;
                  final showResult = _hasSubmitted && isMatched;
                  final isCorrect = showResult && matchedLeftItem != null &&
                      widget.pairs.any((p) => p.key == matchedLeftItem && p.value == item);

                  return _MatchItem(
                    text: item,
                    isSelected: isSelected,
                    isMatched: isMatched,
                    isCorrect: isCorrect,
                    showResult: showResult,
                    onTap: () => _selectRight(item),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const _MatchItem({
    required this.text,
    required this.isSelected,
    required this.isMatched,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = AppColors.correctLight;
        borderColor = AppColors.correct;
        textColor = AppColors.correct;
      } else {
        backgroundColor = AppColors.incorrectLight;
        borderColor = AppColors.incorrect;
        textColor = AppColors.incorrect;
      }
    } else if (isMatched) {
      backgroundColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade300;
      textColor = AppColors.textMedium;
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryGreen.withOpacity(0.15);
      borderColor = AppTheme.primaryGreen;
      textColor = AppTheme.primaryGreen;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = AppColors.textDark;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isMatched ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (showResult)
                Icon(
                  isCorrect ? Icons.check : Icons.close,
                  size: 18,
                  color: isCorrect ? AppColors.correct : AppColors.incorrect,
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}
