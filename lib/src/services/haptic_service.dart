import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Service for providing haptic feedback throughout the app
class HapticService {
  HapticService._();

  static final HapticService instance = HapticService._();

  bool enabled = true;
  bool? _hasVibrator;

  /// Initialize and check device capabilities
  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  /// Light tap feedback (for button presses)
  Future<void> lightTap() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap feedback
  Future<void> mediumTap() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap feedback
  Future<void> heavyTap() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback
  Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Success feedback - used for correct answers
  Future<void> success() async {
    if (!enabled) return;

    if (_hasVibrator == true) {
      // Short celebratory pattern
      await Vibration.vibrate(
        pattern: [0, 50, 50, 50],
        intensities: [0, 128, 0, 255],
      );
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Error feedback - used for incorrect answers
  Future<void> error() async {
    if (!enabled) return;

    if (_hasVibrator == true) {
      // Double buzz pattern for errors
      await Vibration.vibrate(
        pattern: [0, 100, 50, 100],
        intensities: [0, 200, 0, 200],
      );
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Achievement unlocked feedback
  Future<void> achievement() async {
    if (!enabled) return;

    if (_hasVibrator == true) {
      // Celebratory pattern for achievements
      await Vibration.vibrate(
        pattern: [0, 50, 100, 50, 100, 100],
        intensities: [0, 128, 0, 200, 0, 255],
      );
    } else {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    }
  }

  /// Streak extended feedback
  Future<void> streak() async {
    if (!enabled) return;

    if (_hasVibrator == true) {
      // Fire-like ascending pattern
      await Vibration.vibrate(
        pattern: [0, 30, 30, 50, 30, 80],
        intensities: [0, 100, 0, 150, 0, 255],
      );
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Level up feedback
  Future<void> levelUp() async {
    if (!enabled) return;

    if (_hasVibrator == true) {
      // Epic level up pattern
      await Vibration.vibrate(
        pattern: [0, 100, 100, 100, 100, 200],
        intensities: [0, 128, 0, 200, 0, 255],
      );
    } else {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    }
  }

  /// Warning feedback
  Future<void> warning() async {
    if (!enabled) return;

    if (_hasVibrator == true) {
      await Vibration.vibrate(duration: 150, amplitude: 128);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }
}
