import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../services/haptic_service.dart';

class TypingQuestion extends StatefulWidget {
  final String prompt;
  final List<String> correctAnswers;
  final String? hint;
  final bool enabled;
  final bool strictMode;
  final ValueChanged<bool> onAnswer;

  const TypingQuestion({
    super.key,
    required this.prompt,
    required this.correctAnswers,
    this.hint,
    required this.enabled,
    this.strictMode = false,
    required this.onAnswer,
  });

  @override
  State<TypingQuestion> createState() => _TypingQuestionState();
}

class _TypingQuestionState extends State<TypingQuestion> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasSubmitted = false;
  bool _isCorrect = false;

  // Portuguese diacritical characters
  static const List<String> _specialChars = [
    'á',
    'à',
    'â',
    'ã',
    'é',
    'ê',
    'í',
    'ó',
    'ô',
    'õ',
    'ú',
    'ç',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.enabled || _hasSubmitted) return;

    final answer = _controller.text.trim();
    if (answer.isEmpty) return;

    HapticService.instance.lightTap();

    final isCorrect = _checkAnswer(answer);

    setState(() {
      _hasSubmitted = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect);
  }

  bool _checkAnswer(String answer) {
    final normalizedAnswer = _normalize(answer);

    for (final correct in widget.correctAnswers) {
      if (_normalize(correct) == normalizedAnswer) {
        return true;
      }
    }

    return false;
  }

  String _normalize(String text) {
    var normalized = text.toLowerCase().trim();

    if (!widget.strictMode) {
      // Remove diacritics for lenient comparison
      const diacritics = 'áàâãéêíóôõúç';
      const replacements = 'aaaaeeioooucc';
      for (var i = 0; i < diacritics.length; i++) {
        normalized = normalized.replaceAll(diacritics[i], replacements[i]);
      }
    }

    return normalized;
  }

  void _insertChar(String char) {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      char,
    );
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + 1),
    );
    _focusNode.requestFocus();
    HapticService.instance.lightTap();
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

        if (widget.hint != null && !_hasSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Hint: ${widget.hint}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 32),

        // Text input
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled && !_hasSubmitted,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Type your answer...',
            filled: true,
            fillColor: _hasSubmitted
                ? (_isCorrect
                    ? AppColors.correctLight
                    : AppColors.incorrectLight)
                : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.grey.shade100),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            suffixIcon: _hasSubmitted
                ? Icon(
                    _isCorrect ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect ? AppColors.correct : AppColors.incorrect,
                  )
                : null,
          ),
          style: TextStyle(
            fontSize: 18,
            color: _hasSubmitted
                ? (_isCorrect ? AppColors.correct : AppColors.incorrect)
                : Theme.of(context).colorScheme.onSurface,
          ),
          onSubmitted: (_) => _submit(),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Special character buttons
        if (!_hasSubmitted)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _specialChars.map((char) {
              return GestureDetector(
                onTap: () => _insertChar(char),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      char,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 24),

        // Submit button
        if (!_hasSubmitted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _controller.text.isNotEmpty ? _submit : null,
              child: const Text('Check'),
            ),
          ).animate().fadeIn(delay: 300.ms),

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
                      widget.correctAnswers.first,
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
