import 'package:hive_flutter/hive_flutter.dart';

/// Service for persisting user data locally using Hive
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const String _settingsBox = 'settings';
  static const String _progressBox = 'progress';
  static const String _gamificationBox = 'gamification';

  late Box<String> _settings;
  late Box<String> _progress;
  late Box<String> _gamification;

  bool _initialized = false;

  /// Initialize the storage service
  Future<void> init() async {
    if (_initialized) return;

    _settings = await Hive.openBox<String>(_settingsBox);
    _progress = await Hive.openBox<String>(_progressBox);
    _gamification = await Hive.openBox<String>(_gamificationBox);

    _initialized = true;
  }

  // ============================================================================
  // Settings
  // ============================================================================

  /// Save user settings JSON
  Future<void> saveSettings(String json) async {
    await _settings.put('user_settings', json);
  }

  /// Load user settings JSON
  String? loadSettings() {
    return _settings.get('user_settings');
  }

  /// Check if onboarding is completed
  bool get isOnboardingCompleted {
    return _settings.get('onboarding_completed') == 'true';
  }

  /// Set onboarding completed status
  Future<void> setOnboardingCompleted(bool completed) async {
    await _settings.put('onboarding_completed', completed.toString());
  }

  /// Get active language pair code
  String? get activeLanguagePair {
    return _settings.get('active_language_pair');
  }

  /// Set active language pair code
  Future<void> setActiveLanguagePair(String? pairCode) async {
    if (pairCode == null) {
      await _settings.delete('active_language_pair');
    } else {
      await _settings.put('active_language_pair', pairCode);
    }
  }

  /// Get preferred CEFR level
  String get preferredLevel {
    return _settings.get('preferred_level') ?? 'A1';
  }

  /// Set preferred CEFR level
  Future<void> setPreferredLevel(String level) async {
    await _settings.put('preferred_level', level);
  }

  /// Get typing mode (lenient/strict)
  String get typingMode {
    return _settings.get('typing_mode') ?? 'lenient';
  }

  /// Set typing mode
  Future<void> setTypingMode(String mode) async {
    await _settings.put('typing_mode', mode);
  }

  /// Get dark mode preference
  bool get isDarkMode {
    return _settings.get('dark_mode') == 'true';
  }

  /// Set dark mode preference
  Future<void> setDarkMode(bool enabled) async {
    await _settings.put('dark_mode', enabled.toString());
  }

  /// Get haptic feedback preference
  bool get isHapticEnabled {
    return _settings.get('haptic_enabled') != 'false'; // Default true
  }

  /// Set haptic feedback preference
  Future<void> setHapticEnabled(bool enabled) async {
    await _settings.put('haptic_enabled', enabled.toString());
  }

  // ============================================================================
  // Progress
  // ============================================================================

  /// Save progress tracker JSON
  Future<void> saveProgress(String json) async {
    await _progress.put('progress_tracker', json);
  }

  /// Load progress tracker JSON
  String? loadProgress() {
    return _progress.get('progress_tracker');
  }

  /// Get completed lesson IDs for a language pair
  List<String> getCompletedLessons(String languagePairCode) {
    final json = _progress.get('completed_$languagePairCode');
    if (json == null) return [];
    return json.split(',').where((s) => s.isNotEmpty).toList();
  }

  /// Add a completed lesson
  Future<void> addCompletedLesson(String languagePairCode, String lessonId) async {
    final completed = getCompletedLessons(languagePairCode);
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
      await _progress.put('completed_$languagePairCode', completed.join(','));
    }
  }

  // ============================================================================
  // Gamification
  // ============================================================================

  /// Save XP system JSON
  Future<void> saveXPSystem(String json) async {
    await _gamification.put('xp_system', json);
  }

  /// Load XP system JSON
  String? loadXPSystem() {
    return _gamification.get('xp_system');
  }

  /// Save streak tracker JSON
  Future<void> saveStreakTracker(String json) async {
    await _gamification.put('streak_tracker', json);
  }

  /// Load streak tracker JSON
  String? loadStreakTracker() {
    return _gamification.get('streak_tracker');
  }

  /// Save achievement tracker JSON
  Future<void> saveAchievementTracker(String json) async {
    await _gamification.put('achievement_tracker', json);
  }

  /// Load achievement tracker JSON
  String? loadAchievementTracker() {
    return _gamification.get('achievement_tracker');
  }

  // ============================================================================
  // Utility
  // ============================================================================

  /// Clear all stored data
  Future<void> clearAll() async {
    await _settings.clear();
    await _progress.clear();
    await _gamification.clear();
  }

  /// Clear only progress (keep settings)
  Future<void> clearProgress() async {
    await _progress.clear();
    await _gamification.clear();
  }
}
