import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// SRS card data model for Flutter
class SRSCard {
  final String wordId;
  final String sourceWord;
  final String targetWord;
  final String languagePair;
  final String level;
  final String lessonId;
  final String? pronunciation;
  final String? exampleSentence;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final String nextReviewDate;
  final String? lastReviewed;
  final int totalReviews;
  final int correctReviews;
  final int? lastQuality;
  final String createdAt;

  const SRSCard({
    required this.wordId,
    required this.sourceWord,
    required this.targetWord,
    required this.languagePair,
    required this.level,
    required this.lessonId,
    this.pronunciation,
    this.exampleSentence,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewDate,
    this.lastReviewed,
    required this.totalReviews,
    required this.correctReviews,
    this.lastQuality,
    required this.createdAt,
  });

  factory SRSCard.create({
    required String wordId,
    required String sourceWord,
    required String targetWord,
    required String languagePair,
    required String level,
    required String lessonId,
    String? pronunciation,
    String? exampleSentence,
  }) {
    final now = DateTime.now().toIso8601String().split('T')[0];
    return SRSCard(
      wordId: wordId,
      sourceWord: sourceWord,
      targetWord: targetWord,
      languagePair: languagePair,
      level: level,
      lessonId: lessonId,
      pronunciation: pronunciation,
      exampleSentence: exampleSentence,
      easeFactor: 2.5,
      interval: 0,
      repetitions: 0,
      nextReviewDate: now,
      totalReviews: 0,
      correctReviews: 0,
      createdAt: now,
    );
  }

  bool get isDue {
    final now = DateTime.now().toIso8601String().split('T')[0];
    return nextReviewDate.compareTo(now) <= 0;
  }

  double get accuracyRate {
    if (totalReviews == 0) return 0.0;
    return (correctReviews / totalReviews) * 100;
  }

  String get masteryLevel {
    if (repetitions == 0) return 'New';
    if (repetitions <= 2) return 'Learning';
    if (repetitions <= 5 && easeFactor >= 2.0) return 'Familiar';
    if (repetitions <= 10 && easeFactor >= 2.2) return 'Proficient';
    if (repetitions > 10 && easeFactor >= 2.4) return 'Mastered';
    return 'Learning';
  }

  SRSCard copyWith({
    double? easeFactor,
    int? interval,
    int? repetitions,
    String? nextReviewDate,
    String? lastReviewed,
    int? totalReviews,
    int? correctReviews,
    int? lastQuality,
  }) {
    return SRSCard(
      wordId: wordId,
      sourceWord: sourceWord,
      targetWord: targetWord,
      languagePair: languagePair,
      level: level,
      lessonId: lessonId,
      pronunciation: pronunciation,
      exampleSentence: exampleSentence,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      totalReviews: totalReviews ?? this.totalReviews,
      correctReviews: correctReviews ?? this.correctReviews,
      lastQuality: lastQuality ?? this.lastQuality,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'word_id': wordId,
        'source_word': sourceWord,
        'target_word': targetWord,
        'language_pair': languagePair,
        'level': level,
        'lesson_id': lessonId,
        'pronunciation': pronunciation,
        'example_sentence': exampleSentence,
        'ease_factor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'next_review_date': nextReviewDate,
        'last_reviewed': lastReviewed,
        'total_reviews': totalReviews,
        'correct_reviews': correctReviews,
        'last_quality': lastQuality,
        'created_at': createdAt,
      };

  factory SRSCard.fromJson(Map<String, dynamic> json) => SRSCard(
        wordId: json['word_id'] as String,
        sourceWord: json['source_word'] as String,
        targetWord: json['target_word'] as String,
        languagePair: json['language_pair'] as String,
        level: json['level'] as String,
        lessonId: json['lesson_id'] as String,
        pronunciation: json['pronunciation'] as String?,
        exampleSentence: json['example_sentence'] as String?,
        easeFactor: (json['ease_factor'] as num).toDouble(),
        interval: json['interval'] as int,
        repetitions: json['repetitions'] as int,
        nextReviewDate: json['next_review_date'] as String,
        lastReviewed: json['last_reviewed'] as String?,
        totalReviews: json['total_reviews'] as int,
        correctReviews: json['correct_reviews'] as int,
        lastQuality: json['last_quality'] as int?,
        createdAt: json['created_at'] as String,
      );
}

/// SRS statistics
class SRSStats {
  final int totalCards;
  final int dueToday;
  final int newCards;
  final int learningCards;
  final int masteredCards;
  final double averageAccuracy;

  const SRSStats({
    required this.totalCards,
    required this.dueToday,
    required this.newCards,
    required this.learningCards,
    required this.masteredCards,
    required this.averageAccuracy,
  });

  factory SRSStats.empty() => const SRSStats(
        totalCards: 0,
        dueToday: 0,
        newCards: 0,
        learningCards: 0,
        masteredCards: 0,
        averageAccuracy: 0.0,
      );

  factory SRSStats.fromCards(List<SRSCard> cards) {
    if (cards.isEmpty) return SRSStats.empty();

    final dueToday = cards.where((c) => c.isDue).length;
    final newCards = cards.where((c) => c.repetitions == 0).length;
    final learningCards =
        cards.where((c) => c.repetitions > 0 && c.repetitions <= 5).length;
    final masteredCards = cards.where((c) => c.repetitions > 10).length;

    final cardsWithReviews = cards.where((c) => c.totalReviews > 0);
    final avgAccuracy = cardsWithReviews.isEmpty
        ? 0.0
        : cardsWithReviews.map((c) => c.accuracyRate).reduce((a, b) => a + b) /
            cardsWithReviews.length;

    return SRSStats(
      totalCards: cards.length,
      dueToday: dueToday,
      newCards: newCards,
      learningCards: learningCards,
      masteredCards: masteredCards,
      averageAccuracy: avgAccuracy,
    );
  }
}

/// SRS state
class SRSState {
  final List<SRSCard> cards;
  final SRSStats stats;
  final bool isLoading;

  const SRSState({
    required this.cards,
    required this.stats,
    this.isLoading = false,
  });

  factory SRSState.initial() => SRSState(
        cards: const [],
        stats: SRSStats.empty(),
      );

  SRSState copyWith({
    List<SRSCard>? cards,
    SRSStats? stats,
    bool? isLoading,
  }) {
    return SRSState(
      cards: cards ?? this.cards,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<SRSCard> get dueCards => cards.where((c) => c.isDue).toList();
  List<SRSCard> get weakCards =>
      cards.where((c) => c.easeFactor < 2.0 || c.accuracyRate < 60).toList();
}

/// SRS notifier
class SRSNotifier extends Notifier<SRSState> {
  @override
  SRSState build() {
    _loadCards();
    return SRSState.initial();
  }

  Future<void> _loadCards() async {
    state = state.copyWith(isLoading: true);

    final json = StorageService.instance.loadAllSRSCards();
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        final cards = decoded.map((e) => SRSCard.fromJson(e)).toList();
        state = SRSState(
          cards: cards,
          stats: SRSStats.fromCards(cards),
        );
      } catch (e) {
        state = SRSState.initial();
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveCards() async {
    final json = jsonEncode(state.cards.map((c) => c.toJson()).toList());
    await StorageService.instance.saveAllSRSCards(json);
  }

  /// Add a new card
  Future<void> addCard(SRSCard card) async {
    // Check if card already exists
    if (state.cards.any((c) => c.wordId == card.wordId)) {
      return;
    }

    final newCards = [...state.cards, card];
    state = SRSState(
      cards: newCards,
      stats: SRSStats.fromCards(newCards),
    );
    await _saveCards();
  }

  /// Review a card with SM-2 algorithm
  Future<void> reviewCard(String wordId, int quality) async {
    final cardIndex = state.cards.indexWhere((c) => c.wordId == wordId);
    if (cardIndex == -1) return;

    final card = state.cards[cardIndex];
    final now = DateTime.now();
    final currentDate = now.toIso8601String().split('T')[0];

    // SM-2 algorithm
    final wasSuccessful = quality >= 3;
    double newEaseFactor;
    int newInterval;
    int newRepetitions;

    if (wasSuccessful) {
      newRepetitions = card.repetitions + 1;
      if (newRepetitions == 1) {
        newInterval = 1;
      } else if (newRepetitions == 2) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * card.easeFactor).round();
      }
      newEaseFactor = card.easeFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      newEaseFactor = newEaseFactor.clamp(1.3, 2.5);
    } else {
      newRepetitions = 0;
      newInterval = 1;
      newEaseFactor = (card.easeFactor - 0.2).clamp(1.3, 2.5);
    }

    // Calculate next review date
    final nextReview = now.add(Duration(days: newInterval));
    final nextReviewDate = nextReview.toIso8601String().split('T')[0];

    final updatedCard = card.copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      nextReviewDate: nextReviewDate,
      lastReviewed: currentDate,
      totalReviews: card.totalReviews + 1,
      correctReviews: wasSuccessful ? card.correctReviews + 1 : card.correctReviews,
      lastQuality: quality,
    );

    final newCards = [...state.cards];
    newCards[cardIndex] = updatedCard;

    state = SRSState(
      cards: newCards,
      stats: SRSStats.fromCards(newCards),
    );
    await _saveCards();
  }

  /// Remove a card
  Future<void> removeCard(String wordId) async {
    final newCards = state.cards.where((c) => c.wordId != wordId).toList();
    state = SRSState(
      cards: newCards,
      stats: SRSStats.fromCards(newCards),
    );
    await _saveCards();
  }

  /// Add cards from a completed lesson
  Future<void> addCardsFromLesson({
    required String lessonId,
    required String languagePair,
    required String level,
    required List<Map<String, String>> vocabulary,
  }) async {
    for (final vocab in vocabulary) {
      final card = SRSCard.create(
        wordId: '${lessonId}_${vocab['source']}',
        sourceWord: vocab['source'] ?? '',
        targetWord: vocab['target'] ?? '',
        languagePair: languagePair,
        level: level,
        lessonId: lessonId,
        pronunciation: vocab['pronunciation'],
        exampleSentence: vocab['example'],
      );
      await addCard(card);
    }
  }
}

/// Provider for SRS state
final srsProvider = NotifierProvider<SRSNotifier, SRSState>(SRSNotifier.new);

/// Provider for due cards count
final dueCardsCountProvider = Provider<int>((ref) {
  return ref.watch(srsProvider).dueCards.length;
});

/// Provider for SRS stats
final srsStatsProvider = Provider<SRSStats>((ref) {
  return ref.watch(srsProvider).stats;
});
