import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../services/lesson_service.dart';
import 'settings_provider.dart';

/// Progress state for a specific level
class LevelProgress {
  final String level;
  final int totalLessons;
  final int completedLessons;
  final List<String> completedLessonIds;

  const LevelProgress({
    required this.level,
    required this.totalLessons,
    required this.completedLessons,
    required this.completedLessonIds,
  });

  double get progress =>
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;
  bool get isCompleted => totalLessons > 0 && completedLessons >= totalLessons;
}

/// Overall progress state
class ProgressState {
  final Map<String, LevelProgress> levelProgress;
  final String? currentLanguagePair;

  const ProgressState({
    this.levelProgress = const {},
    this.currentLanguagePair,
  });

  LevelProgress? getProgress(String level) => levelProgress[level];

  int getCompletedCount(String level) =>
      levelProgress[level]?.completedLessons ?? 0;

  int getTotalCount(String level) => levelProgress[level]?.totalLessons ?? 0;

  List<String> getCompletedIds(String level) =>
      levelProgress[level]?.completedLessonIds ?? [];
}

/// Provider for tracking lesson progress
class ProgressNotifier extends AsyncNotifier<ProgressState> {
  @override
  Future<ProgressState> build() async {
    // Watch settings to get current language pair
    final settings = await ref.watch(settingsProvider.future);
    final languagePair = settings.activeLanguagePair ?? 'en_to_pt_pt';

    return _loadProgress(languagePair);
  }

  Future<ProgressState> _loadProgress(String languagePair) async {
    final storage = StorageService.instance;
    final lessonService = LessonService.instance;

    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final progressMap = <String, LevelProgress>{};

    for (final level in levels) {
      final completedIds =
          storage.getCompletedLessons('${languagePair}_$level');
      final lessons = await lessonService.getLessons(languagePair, level);

      progressMap[level] = LevelProgress(
        level: level,
        totalLessons: lessons.length,
        completedLessons: completedIds.length,
        completedLessonIds: completedIds,
      );
    }

    return ProgressState(
      levelProgress: progressMap,
      currentLanguagePair: languagePair,
    );
  }

  /// Mark a lesson as completed
  Future<void> completeLesson(String level, String lessonId) async {
    final current = await future;
    final languagePair = current.currentLanguagePair ?? 'en_to_pt_pt';
    final storageKey = '${languagePair}_$level';

    // Save to storage
    await StorageService.instance.addCompletedLesson(storageKey, lessonId);

    // Reload progress
    state = AsyncValue.data(await _loadProgress(languagePair));
  }

  /// Get the next lesson to complete for a level
  Future<Lesson?> getNextLesson(String level) async {
    final current = await future;
    final languagePair = current.currentLanguagePair ?? 'en_to_pt_pt';
    final completedIds = current.getCompletedIds(level);

    return LessonService.instance
        .getNextLesson(languagePair, level, completedIds);
  }

  /// Get all lessons for a level
  Future<List<Lesson>> getLessonsForLevel(String level) async {
    final current = await future;
    final languagePair = current.currentLanguagePair ?? 'en_to_pt_pt';
    return LessonService.instance.getLessons(languagePair, level);
  }

  /// Check if a specific lesson is completed
  bool isLessonCompleted(String level, String lessonId) {
    final current = state.valueOrNull;
    if (current == null) return false;
    return current.getCompletedIds(level).contains(lessonId);
  }

  /// Refresh progress data
  Future<void> refresh() async {
    final current = await future;
    final languagePair = current.currentLanguagePair ?? 'en_to_pt_pt';
    state = AsyncValue.data(await _loadProgress(languagePair));
  }
}

/// Main progress provider
final progressProvider = AsyncNotifierProvider<ProgressNotifier, ProgressState>(
    ProgressNotifier.new);

/// Provider for getting available lessons for a level
final lessonsForLevelProvider =
    FutureProvider.family<List<Lesson>, String>((ref, level) async {
  final progress = await ref.watch(progressProvider.future);
  final languagePair = progress.currentLanguagePair ?? 'en_to_pt_pt';
  return LessonService.instance.getLessons(languagePair, level);
});

/// Provider for getting the next lesson for a level
final nextLessonProvider =
    FutureProvider.family<Lesson?, String>((ref, level) async {
  final progress = await ref.watch(progressProvider.future);
  final languagePair = progress.currentLanguagePair ?? 'en_to_pt_pt';
  final completedIds = progress.getCompletedIds(level);
  return LessonService.instance
      .getNextLesson(languagePair, level, completedIds);
});
