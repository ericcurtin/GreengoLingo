import 'package:hive_flutter/hive_flutter.dart';

/// Service for persisting user data locally using Hive
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const String _settingsBox = 'settings';
  static const String _progressBox = 'progress';
  static const String _gamificationBox = 'gamification';
  static const String _srsBox = 'srs';
  static const String _vocabularyBox = 'vocabulary';
  static const String _statisticsBox = 'statistics';

  late Box<String> _settings;
  late Box<String> _progress;
  late Box<String> _gamification;
  late Box<String> _srs;
  late Box<String> _vocabulary;
  late Box<String> _statistics;

  bool _initialized = false;

  /// Initialize the storage service
  Future<void> init() async {
    if (_initialized) return;

    _settings = await Hive.openBox<String>(_settingsBox);
    _progress = await Hive.openBox<String>(_progressBox);
    _gamification = await Hive.openBox<String>(_gamificationBox);
    _srs = await Hive.openBox<String>(_srsBox);
    _vocabulary = await Hive.openBox<String>(_vocabularyBox);
    _statistics = await Hive.openBox<String>(_statisticsBox);

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
  Future<void> addCompletedLesson(
      String languagePairCode, String lessonId) async {
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
  // SRS (Spaced Repetition System)
  // ============================================================================

  /// Save SRS cards JSON for a language pair
  Future<void> saveSRSCards(String languagePairCode, String json) async {
    await _srs.put('cards_$languagePairCode', json);
  }

  /// Load SRS cards JSON for a language pair
  String? loadSRSCards(String languagePairCode) {
    return _srs.get('cards_$languagePairCode');
  }

  /// Save all SRS cards JSON (global)
  Future<void> saveAllSRSCards(String json) async {
    await _srs.put('all_cards', json);
  }

  /// Load all SRS cards JSON
  String? loadAllSRSCards() {
    return _srs.get('all_cards');
  }

  // ============================================================================
  // Vocabulary Bank
  // ============================================================================

  /// Save vocabulary bank JSON for a language pair
  Future<void> saveVocabularyBank(String languagePairCode, String json) async {
    await _vocabulary.put('bank_$languagePairCode', json);
  }

  /// Load vocabulary bank JSON for a language pair
  String? loadVocabularyBank(String languagePairCode) {
    return _vocabulary.get('bank_$languagePairCode');
  }

  /// Save all vocabulary JSON (global)
  Future<void> saveAllVocabulary(String json) async {
    await _vocabulary.put('all_vocabulary', json);
  }

  /// Load all vocabulary JSON
  String? loadAllVocabulary() {
    return _vocabulary.get('all_vocabulary');
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Save statistics tracker JSON
  Future<void> saveStatisticsTracker(String json) async {
    await _statistics.put('tracker', json);
  }

  /// Load statistics tracker JSON
  String? loadStatisticsTracker() {
    return _statistics.get('tracker');
  }

  /// Save daily stats for a specific date
  Future<void> saveDailyStats(String date, String json) async {
    await _statistics.put('daily_$date', json);
  }

  /// Load daily stats for a specific date
  String? loadDailyStats(String date) {
    return _statistics.get('daily_$date');
  }

  /// Save weekly summary
  Future<void> saveWeeklySummary(String weekStart, String json) async {
    await _statistics.put('weekly_$weekStart', json);
  }

  /// Load weekly summary
  String? loadWeeklySummary(String weekStart) {
    return _statistics.get('weekly_$weekStart');
  }

  /// Save monthly summary
  Future<void> saveMonthlySummary(int year, int month, String json) async {
    await _statistics.put('monthly_${year}_$month', json);
  }

  /// Load monthly summary
  String? loadMonthlySummary(int year, int month) {
    return _statistics.get('monthly_${year}_$month');
  }

  // ============================================================================
  // Utility
  // ============================================================================

  /// Clear all stored data
  Future<void> clearAll() async {
    await _settings.clear();
    await _progress.clear();
    await _gamification.clear();
    await _srs.clear();
    await _vocabulary.clear();
    await _statistics.clear();
  }

  /// Clear only progress (keep settings)
  Future<void> clearProgress() async {
    await _progress.clear();
    await _gamification.clear();
    await _srs.clear();
    await _vocabulary.clear();
    await _statistics.clear();
  }
}
