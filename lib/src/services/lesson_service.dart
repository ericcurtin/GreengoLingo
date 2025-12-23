import 'dart:convert';
import 'package:flutter/services.dart';

/// Represents a lesson with its metadata and questions
class Lesson {
  final String id;
  final String title;
  final String description;
  final String level;
  final int xpReward;
  final int order;
  final String icon;
  final List<Map<String, dynamic>> questions;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.xpReward,
    required this.order,
    required this.icon,
    required this.questions,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      level: json['level'] as String,
      xpReward: json['xp_reward'] as int? ?? 10,
      order: json['order'] as int? ?? 0,
      icon: json['icon'] as String? ?? 'book',
      questions: (json['questions'] as List<dynamic>)
          .map((q) => q as Map<String, dynamic>)
          .toList(),
    );
  }
}

/// Service for loading lesson content from assets
class LessonService {
  LessonService._();
  static final LessonService instance = LessonService._();

  final Map<String, List<Lesson>> _cache = {};

  /// Get all lessons for a language pair and level
  Future<List<Lesson>> getLessons(String languagePair, String level) async {
    final cacheKey = '${languagePair}_$level';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final lessons = await _loadLessonsFromAssets(languagePair, level);
    _cache[cacheKey] = lessons;
    return lessons;
  }

  /// Load lessons from asset files
  Future<List<Lesson>> _loadLessonsFromAssets(
      String languagePair, String level) async {
    final lessons = <Lesson>[];
    final levelLower = level.toLowerCase();

    // Try to load the asset manifest to find lesson files
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestContent);

    // Find all JSON files for this language pair and level
    final pattern = 'assets/content/$languagePair/$levelLower/';
    final matchingAssets = manifest.keys
        .where((key) => key.startsWith(pattern) && key.endsWith('.json'))
        .toList();

    for (final assetPath in matchingAssets) {
      try {
        final content = await rootBundle.loadString(assetPath);
        final data = json.decode(content) as Map<String, dynamic>;
        lessons.add(Lesson.fromJson(data));
      } catch (_) {
        // Skip files that can't be parsed
      }
    }

    // Sort by order
    lessons.sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }

  /// Get the next uncompleted lesson for a language pair and level
  Future<Lesson?> getNextLesson(
    String languagePair,
    String level,
    List<String> completedLessonIds,
  ) async {
    final lessons = await getLessons(languagePair, level);

    for (final lesson in lessons) {
      if (!completedLessonIds.contains(lesson.id)) {
        return lesson;
      }
    }

    // All lessons completed, return the first one for replay
    return lessons.isNotEmpty ? lessons.first : null;
  }

  /// Get a specific lesson by ID
  Future<Lesson?> getLessonById(
      String languagePair, String level, String lessonId) async {
    final lessons = await getLessons(languagePair, level);
    try {
      return lessons.firstWhere((l) => l.id == lessonId);
    } catch (_) {
      return null;
    }
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }
}
