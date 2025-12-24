import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Question type statistics
class QuestionTypeStats {
  final int answered;
  final int correct;

  const QuestionTypeStats({
    required this.answered,
    required this.correct,
  });

  factory QuestionTypeStats.empty() =>
      const QuestionTypeStats(answered: 0, correct: 0);

  double get accuracy => answered == 0 ? 0.0 : (correct / answered) * 100;

  QuestionTypeStats add(bool isCorrect) => QuestionTypeStats(
        answered: answered + 1,
        correct: isCorrect ? correct + 1 : correct,
      );

  Map<String, dynamic> toJson() => {
        'answered': answered,
        'correct': correct,
      };

  factory QuestionTypeStats.fromJson(Map<String, dynamic> json) =>
      QuestionTypeStats(
        answered: json['answered'] as int,
        correct: json['correct'] as int,
      );
}

/// Daily statistics
class DailyStats {
  final String date;
  final int xpEarned;
  final int lessonsCompleted;
  final int timeSpentSeconds;
  final int questionsAnswered;
  final int questionsCorrect;
  final int srsReviews;
  final int srsCorrect;
  final int wordsLearned;
  final Map<String, QuestionTypeStats> accuracyByType;
  final List<String> levelsPracticed;

  const DailyStats({
    required this.date,
    required this.xpEarned,
    required this.lessonsCompleted,
    required this.timeSpentSeconds,
    required this.questionsAnswered,
    required this.questionsCorrect,
    required this.srsReviews,
    required this.srsCorrect,
    required this.wordsLearned,
    required this.accuracyByType,
    required this.levelsPracticed,
  });

  factory DailyStats.forDate(String date) => DailyStats(
        date: date,
        xpEarned: 0,
        lessonsCompleted: 0,
        timeSpentSeconds: 0,
        questionsAnswered: 0,
        questionsCorrect: 0,
        srsReviews: 0,
        srsCorrect: 0,
        wordsLearned: 0,
        accuracyByType: const {},
        levelsPracticed: const [],
      );

  double get accuracy =>
      questionsAnswered == 0 ? 0.0 : (questionsCorrect / questionsAnswered) * 100;

  double get srsAccuracy =>
      srsReviews == 0 ? 0.0 : (srsCorrect / srsReviews) * 100;

  DailyStats copyWith({
    int? xpEarned,
    int? lessonsCompleted,
    int? timeSpentSeconds,
    int? questionsAnswered,
    int? questionsCorrect,
    int? srsReviews,
    int? srsCorrect,
    int? wordsLearned,
    Map<String, QuestionTypeStats>? accuracyByType,
    List<String>? levelsPracticed,
  }) {
    return DailyStats(
      date: date,
      xpEarned: xpEarned ?? this.xpEarned,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      questionsCorrect: questionsCorrect ?? this.questionsCorrect,
      srsReviews: srsReviews ?? this.srsReviews,
      srsCorrect: srsCorrect ?? this.srsCorrect,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      accuracyByType: accuracyByType ?? this.accuracyByType,
      levelsPracticed: levelsPracticed ?? this.levelsPracticed,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'xp_earned': xpEarned,
        'lessons_completed': lessonsCompleted,
        'time_spent_seconds': timeSpentSeconds,
        'questions_answered': questionsAnswered,
        'questions_correct': questionsCorrect,
        'srs_reviews': srsReviews,
        'srs_correct': srsCorrect,
        'words_learned': wordsLearned,
        'accuracy_by_type':
            accuracyByType.map((k, v) => MapEntry(k, v.toJson())),
        'levels_practiced': levelsPracticed,
      };

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
        date: json['date'] as String,
        xpEarned: json['xp_earned'] as int,
        lessonsCompleted: json['lessons_completed'] as int,
        timeSpentSeconds: json['time_spent_seconds'] as int,
        questionsAnswered: json['questions_answered'] as int,
        questionsCorrect: json['questions_correct'] as int,
        srsReviews: json['srs_reviews'] as int,
        srsCorrect: json['srs_correct'] as int,
        wordsLearned: json['words_learned'] as int,
        accuracyByType:
            (json['accuracy_by_type'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(
                    k,
                    QuestionTypeStats.fromJson(v as Map<String, dynamic>),
                  ),
                ) ??
                {},
        levelsPracticed:
            (json['levels_practiced'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

/// Lifetime statistics
class LifetimeStats {
  final int totalXp;
  final int totalLessons;
  final int totalTimeSeconds;
  final int totalQuestions;
  final int totalCorrect;
  final int totalSrsReviews;
  final int totalSrsCorrect;
  final int totalWords;
  final int daysActive;
  final int longestStreak;
  final int currentStreak;
  final Map<String, QuestionTypeStats> accuracyByType;
  final String? firstActivityDate;
  final String? lastActivityDate;

  const LifetimeStats({
    required this.totalXp,
    required this.totalLessons,
    required this.totalTimeSeconds,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalSrsReviews,
    required this.totalSrsCorrect,
    required this.totalWords,
    required this.daysActive,
    required this.longestStreak,
    required this.currentStreak,
    required this.accuracyByType,
    this.firstActivityDate,
    this.lastActivityDate,
  });

  factory LifetimeStats.empty() => const LifetimeStats(
        totalXp: 0,
        totalLessons: 0,
        totalTimeSeconds: 0,
        totalQuestions: 0,
        totalCorrect: 0,
        totalSrsReviews: 0,
        totalSrsCorrect: 0,
        totalWords: 0,
        daysActive: 0,
        longestStreak: 0,
        currentStreak: 0,
        accuracyByType: {},
      );

  double get accuracy =>
      totalQuestions == 0 ? 0.0 : (totalCorrect / totalQuestions) * 100;

  double get totalHours => totalTimeSeconds / 3600;

  double get averageXpPerDay => daysActive == 0 ? 0.0 : totalXp / daysActive;

  LifetimeStats copyWith({
    int? totalXp,
    int? totalLessons,
    int? totalTimeSeconds,
    int? totalQuestions,
    int? totalCorrect,
    int? totalSrsReviews,
    int? totalSrsCorrect,
    int? totalWords,
    int? daysActive,
    int? longestStreak,
    int? currentStreak,
    Map<String, QuestionTypeStats>? accuracyByType,
    String? firstActivityDate,
    String? lastActivityDate,
  }) {
    return LifetimeStats(
      totalXp: totalXp ?? this.totalXp,
      totalLessons: totalLessons ?? this.totalLessons,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalSrsReviews: totalSrsReviews ?? this.totalSrsReviews,
      totalSrsCorrect: totalSrsCorrect ?? this.totalSrsCorrect,
      totalWords: totalWords ?? this.totalWords,
      daysActive: daysActive ?? this.daysActive,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      accuracyByType: accuracyByType ?? this.accuracyByType,
      firstActivityDate: firstActivityDate ?? this.firstActivityDate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_xp': totalXp,
        'total_lessons': totalLessons,
        'total_time_seconds': totalTimeSeconds,
        'total_questions': totalQuestions,
        'total_correct': totalCorrect,
        'total_srs_reviews': totalSrsReviews,
        'total_srs_correct': totalSrsCorrect,
        'total_words': totalWords,
        'days_active': daysActive,
        'longest_streak': longestStreak,
        'current_streak': currentStreak,
        'accuracy_by_type':
            accuracyByType.map((k, v) => MapEntry(k, v.toJson())),
        'first_activity_date': firstActivityDate,
        'last_activity_date': lastActivityDate,
      };

  factory LifetimeStats.fromJson(Map<String, dynamic> json) => LifetimeStats(
        totalXp: json['total_xp'] as int,
        totalLessons: json['total_lessons'] as int,
        totalTimeSeconds: json['total_time_seconds'] as int,
        totalQuestions: json['total_questions'] as int,
        totalCorrect: json['total_correct'] as int,
        totalSrsReviews: json['total_srs_reviews'] as int,
        totalSrsCorrect: json['total_srs_correct'] as int,
        totalWords: json['total_words'] as int,
        daysActive: json['days_active'] as int,
        longestStreak: json['longest_streak'] as int,
        currentStreak: json['current_streak'] as int,
        accuracyByType:
            (json['accuracy_by_type'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(
                    k,
                    QuestionTypeStats.fromJson(v as Map<String, dynamic>),
                  ),
                ) ??
                {},
        firstActivityDate: json['first_activity_date'] as String?,
        lastActivityDate: json['last_activity_date'] as String?,
      );
}

/// XP trend data point
class XPTrendPoint {
  final String date;
  final int xp;

  const XPTrendPoint({required this.date, required this.xp});
}

/// Accuracy trend data point
class AccuracyTrendPoint {
  final String date;
  final double accuracy;

  const AccuracyTrendPoint({required this.date, required this.accuracy});
}

/// Statistics state
class StatisticsState {
  final Map<String, DailyStats> dailyStats;
  final LifetimeStats lifetime;
  final bool isLoading;

  const StatisticsState({
    required this.dailyStats,
    required this.lifetime,
    this.isLoading = false,
  });

  factory StatisticsState.initial() => StatisticsState(
        dailyStats: const {},
        lifetime: LifetimeStats.empty(),
      );

  StatisticsState copyWith({
    Map<String, DailyStats>? dailyStats,
    LifetimeStats? lifetime,
    bool? isLoading,
  }) {
    return StatisticsState(
      dailyStats: dailyStats ?? this.dailyStats,
      lifetime: lifetime ?? this.lifetime,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get today's stats
  DailyStats? get todayStats {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return dailyStats[today];
  }

  /// Get XP trend for last N days
  List<XPTrendPoint> xpTrend(int days) {
    final result = <XPTrendPoint>[];
    final now = DateTime.now();

    for (var i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final stats = dailyStats[dateStr];
      result.add(XPTrendPoint(
        date: dateStr,
        xp: stats?.xpEarned ?? 0,
      ));
    }

    return result;
  }

  /// Get accuracy trend for last N days
  List<AccuracyTrendPoint> accuracyTrend(int days) {
    final result = <AccuracyTrendPoint>[];
    final now = DateTime.now();

    for (var i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final stats = dailyStats[dateStr];
      result.add(AccuracyTrendPoint(
        date: dateStr,
        accuracy: stats?.accuracy ?? 0,
      ));
    }

    return result;
  }

  /// Get recent stats
  List<DailyStats> recentStats(int days) {
    final result = <DailyStats>[];
    final now = DateTime.now();

    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final stats = dailyStats[dateStr];
      if (stats != null) {
        result.add(stats);
      }
    }

    return result;
  }
}

/// Statistics notifier
class StatisticsNotifier extends Notifier<StatisticsState> {
  @override
  StatisticsState build() {
    _loadStatistics();
    return StatisticsState.initial();
  }

  Future<void> _loadStatistics() async {
    state = state.copyWith(isLoading: true);

    final json = StorageService.instance.loadStatisticsTracker();
    if (json != null) {
      try {
        final decoded = jsonDecode(json) as Map<String, dynamic>;

        final dailyStatsJson =
            decoded['daily_stats'] as Map<String, dynamic>? ?? {};
        final dailyStats = dailyStatsJson.map(
          (k, v) => MapEntry(k, DailyStats.fromJson(v as Map<String, dynamic>)),
        );

        final lifetimeJson =
            decoded['lifetime'] as Map<String, dynamic>? ?? {};
        final lifetime = LifetimeStats.fromJson(lifetimeJson);

        state = StatisticsState(
          dailyStats: dailyStats,
          lifetime: lifetime,
        );
      } catch (e) {
        state = StatisticsState.initial();
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveStatistics() async {
    final data = {
      'daily_stats':
          state.dailyStats.map((k, v) => MapEntry(k, v.toJson())),
      'lifetime': state.lifetime.toJson(),
    };
    final json = jsonEncode(data);
    await StorageService.instance.saveStatisticsTracker(json);
  }

  String _getCurrentDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// Record a lesson completion
  Future<void> recordLessonCompletion({
    required int xp,
    required int questions,
    required int correct,
    required int timeSeconds,
    required String level,
  }) async {
    final date = _getCurrentDate();
    final daily = state.dailyStats[date] ?? DailyStats.forDate(date);

    final newLevels = [...daily.levelsPracticed];
    if (!newLevels.contains(level)) {
      newLevels.add(level);
    }

    final updatedDaily = daily.copyWith(
      xpEarned: daily.xpEarned + xp,
      lessonsCompleted: daily.lessonsCompleted + 1,
      questionsAnswered: daily.questionsAnswered + questions,
      questionsCorrect: daily.questionsCorrect + correct,
      timeSpentSeconds: daily.timeSpentSeconds + timeSeconds,
      levelsPracticed: newLevels,
    );

    final newDailyStats = {...state.dailyStats};
    newDailyStats[date] = updatedDaily;

    // Update lifetime
    var lifetime = state.lifetime;
    if (!state.dailyStats.containsKey(date)) {
      lifetime = lifetime.copyWith(daysActive: lifetime.daysActive + 1);
    }
    if (lifetime.firstActivityDate == null) {
      lifetime = lifetime.copyWith(firstActivityDate: date);
    }
    lifetime = lifetime.copyWith(
      totalXp: lifetime.totalXp + xp,
      totalLessons: lifetime.totalLessons + 1,
      totalQuestions: lifetime.totalQuestions + questions,
      totalCorrect: lifetime.totalCorrect + correct,
      totalTimeSeconds: lifetime.totalTimeSeconds + timeSeconds,
      lastActivityDate: date,
    );

    state = state.copyWith(
      dailyStats: newDailyStats,
      lifetime: lifetime,
    );
    await _saveStatistics();
  }

  /// Record a question answer
  Future<void> recordQuestion({
    required String questionType,
    required bool correct,
  }) async {
    final date = _getCurrentDate();
    final daily = state.dailyStats[date] ?? DailyStats.forDate(date);

    final accuracyByType = Map<String, QuestionTypeStats>.from(daily.accuracyByType);
    final typeStats = accuracyByType[questionType] ?? QuestionTypeStats.empty();
    accuracyByType[questionType] = typeStats.add(correct);

    final updatedDaily = daily.copyWith(accuracyByType: accuracyByType);

    final newDailyStats = {...state.dailyStats};
    newDailyStats[date] = updatedDaily;

    // Update lifetime accuracy by type
    final lifetimeAccuracy =
        Map<String, QuestionTypeStats>.from(state.lifetime.accuracyByType);
    final lifetimeTypeStats =
        lifetimeAccuracy[questionType] ?? QuestionTypeStats.empty();
    lifetimeAccuracy[questionType] = lifetimeTypeStats.add(correct);

    state = state.copyWith(
      dailyStats: newDailyStats,
      lifetime: state.lifetime.copyWith(accuracyByType: lifetimeAccuracy),
    );
    await _saveStatistics();
  }

  /// Record an SRS review
  Future<void> recordSrsReview({required bool correct}) async {
    final date = _getCurrentDate();
    final daily = state.dailyStats[date] ?? DailyStats.forDate(date);

    final updatedDaily = daily.copyWith(
      srsReviews: daily.srsReviews + 1,
      srsCorrect: correct ? daily.srsCorrect + 1 : daily.srsCorrect,
    );

    final newDailyStats = {...state.dailyStats};
    newDailyStats[date] = updatedDaily;

    state = state.copyWith(
      dailyStats: newDailyStats,
      lifetime: state.lifetime.copyWith(
        totalSrsReviews: state.lifetime.totalSrsReviews + 1,
        totalSrsCorrect: correct
            ? state.lifetime.totalSrsCorrect + 1
            : state.lifetime.totalSrsCorrect,
      ),
    );
    await _saveStatistics();
  }

  /// Record words learned
  Future<void> recordWordsLearned(int count) async {
    final date = _getCurrentDate();
    final daily = state.dailyStats[date] ?? DailyStats.forDate(date);

    final updatedDaily = daily.copyWith(
      wordsLearned: daily.wordsLearned + count,
    );

    final newDailyStats = {...state.dailyStats};
    newDailyStats[date] = updatedDaily;

    state = state.copyWith(
      dailyStats: newDailyStats,
      lifetime: state.lifetime.copyWith(
        totalWords: state.lifetime.totalWords + count,
      ),
    );
    await _saveStatistics();
  }

  /// Update streak info
  void updateStreak(int current, int longest) {
    state = state.copyWith(
      lifetime: state.lifetime.copyWith(
        currentStreak: current,
        longestStreak:
            longest > state.lifetime.longestStreak ? longest : state.lifetime.longestStreak,
      ),
    );
    _saveStatistics();
  }
}

/// Provider for statistics state
final statisticsProvider =
    NotifierProvider<StatisticsNotifier, StatisticsState>(
        StatisticsNotifier.new);

/// Provider for lifetime stats
final lifetimeStatsProvider = Provider<LifetimeStats>((ref) {
  return ref.watch(statisticsProvider).lifetime;
});

/// Provider for today's stats
final todayStatsProvider = Provider<DailyStats?>((ref) {
  return ref.watch(statisticsProvider).todayStats;
});

/// Provider for XP trend (7 days)
final xpTrend7DaysProvider = Provider<List<XPTrendPoint>>((ref) {
  return ref.watch(statisticsProvider).xpTrend(7);
});

/// Provider for XP trend (30 days)
final xpTrend30DaysProvider = Provider<List<XPTrendPoint>>((ref) {
  return ref.watch(statisticsProvider).xpTrend(30);
});

/// Provider for accuracy trend (7 days)
final accuracyTrend7DaysProvider = Provider<List<AccuracyTrendPoint>>((ref) {
  return ref.watch(statisticsProvider).accuracyTrend(7);
});

/// Provider for accuracy trend (30 days)
final accuracyTrend30DaysProvider = Provider<List<AccuracyTrendPoint>>((ref) {
  return ref.watch(statisticsProvider).accuracyTrend(30);
});
