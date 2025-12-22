import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../services/haptic_service.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final bool enabled;
  final ValueChanged<bool> onAnswer;

  const MultipleChoiceQuestion({
    super.key,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.enabled,
    required this.onAnswer,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  int? _selectedIndex;
  late List<int> _shuffledIndices;
  late int _shuffledCorrectIndex;

  @override
  void initState() {
    super.initState();
    // Create shuffled indices for randomizing option order
    _shuffledIndices = List.generate(widget.options.length, (i) => i)..shuffle();
    // Find where the correct answer ended up after shuffling
    _shuffledCorrectIndex = _shuffledIndices.indexOf(widget.correctIndex);
  }

  void _selectOption(int index) {
    if (!widget.enabled || _selectedIndex != null) return;

    HapticService.instance.selection();

    setState(() {
      _selectedIndex = index;
    });

    final isCorrect = index == _shuffledCorrectIndex;
    widget.onAnswer(isCorrect);
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
        const SizedBox(height: 32),

        // Options (displayed in shuffled order)
        ..._shuffledIndices.asMap().entries.map((entry) {
          final displayIndex = entry.key;
          final originalIndex = entry.value;
          final option = widget.options[originalIndex];
          final isSelected = _selectedIndex == displayIndex;
          final isCorrect = displayIndex == _shuffledCorrectIndex;
          final showResult = _selectedIndex != null;

          Color backgroundColor;
          Color borderColor;
          Color textColor;

          final isDark = Theme.of(context).brightness == Brightness.dark;
          final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
          final defaultTextColor = Theme.of(context).colorScheme.onSurface;

          if (showResult) {
            if (isCorrect) {
              backgroundColor = AppColors.correctLight;
              borderColor = AppColors.correct;
              textColor = AppColors.correct;
            } else if (isSelected) {
              backgroundColor = AppColors.incorrectLight;
              borderColor = AppColors.incorrect;
              textColor = AppColors.incorrect;
            } else {
              backgroundColor = surfaceColor;
              borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
              textColor = defaultTextColor;
            }
          } else {
            backgroundColor = isSelected
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : surfaceColor;
            borderColor = isSelected ? AppTheme.primaryGreen : (isDark ? Colors.grey.shade700 : Colors.grey.shade200);
            textColor = defaultTextColor;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _selectOption(displayIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  children: [
                    // Option letter
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + displayIndex), // A, B, C, D
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Option text
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ),
                    // Result icon
                    if (showResult && (isCorrect || isSelected))
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? AppColors.correct : AppColors.incorrect,
                      ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 + displayIndex * 50).ms).slideX(begin: 0.05);
        }),

        // Explanation (if shown and correct)
        if (_selectedIndex != null && widget.explanation != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.explanation!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}
