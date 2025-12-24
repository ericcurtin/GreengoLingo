import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Vocabulary category
enum VocabularyCategory {
  noun,
  verb,
  adjective,
  adverb,
  pronoun,
  preposition,
  conjunction,
  interjection,
  phrase,
  expression,
  idiom,
  grammar,
  other;

  String get displayName {
    switch (this) {
      case VocabularyCategory.noun:
        return 'Noun';
      case VocabularyCategory.verb:
        return 'Verb';
      case VocabularyCategory.adjective:
        return 'Adjective';
      case VocabularyCategory.adverb:
        return 'Adverb';
      case VocabularyCategory.pronoun:
        return 'Pronoun';
      case VocabularyCategory.preposition:
        return 'Preposition';
      case VocabularyCategory.conjunction:
        return 'Conjunction';
      case VocabularyCategory.interjection:
        return 'Interjection';
      case VocabularyCategory.phrase:
        return 'Phrase';
      case VocabularyCategory.expression:
        return 'Expression';
      case VocabularyCategory.idiom:
        return 'Idiom';
      case VocabularyCategory.grammar:
        return 'Grammar';
      case VocabularyCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case VocabularyCategory.noun:
        return 'category';
      case VocabularyCategory.verb:
        return 'directions_run';
      case VocabularyCategory.adjective:
        return 'palette';
      case VocabularyCategory.adverb:
        return 'speed';
      case VocabularyCategory.pronoun:
        return 'person';
      case VocabularyCategory.preposition:
        return 'place';
      case VocabularyCategory.conjunction:
        return 'link';
      case VocabularyCategory.interjection:
        return 'chat_bubble';
      case VocabularyCategory.phrase:
        return 'short_text';
      case VocabularyCategory.expression:
        return 'format_quote';
      case VocabularyCategory.idiom:
        return 'lightbulb';
      case VocabularyCategory.grammar:
        return 'rule';
      case VocabularyCategory.other:
        return 'label';
    }
  }
}

/// Vocabulary item
class VocabularyItem {
  final String id;
  final String source;
  final String target;
  final String? pronunciation;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String lessonId;
  final String level;
  final String languagePair;
  final VocabularyCategory category;
  final String? notes;
  final List<String> tags;
  final bool inSrs;
  final String addedAt;

  const VocabularyItem({
    required this.id,
    required this.source,
    required this.target,
    this.pronunciation,
    this.exampleSentence,
    this.exampleTranslation,
    required this.lessonId,
    required this.level,
    required this.languagePair,
    required this.category,
    this.notes,
    this.tags = const [],
    this.inSrs = false,
    required this.addedAt,
  });

  factory VocabularyItem.create({
    required String source,
    required String target,
    required String lessonId,
    required String level,
    required String languagePair,
    VocabularyCategory category = VocabularyCategory.phrase,
    String? pronunciation,
    String? exampleSentence,
    String? notes,
  }) {
    final now = DateTime.now().toIso8601String();
    return VocabularyItem(
      id: '${lessonId}_$source',
      source: source,
      target: target,
      pronunciation: pronunciation,
      exampleSentence: exampleSentence,
      lessonId: lessonId,
      level: level,
      languagePair: languagePair,
      category: category,
      notes: notes,
      addedAt: now,
    );
  }

  VocabularyItem copyWith({
    bool? inSrs,
    String? notes,
    List<String>? tags,
  }) {
    return VocabularyItem(
      id: id,
      source: source,
      target: target,
      pronunciation: pronunciation,
      exampleSentence: exampleSentence,
      exampleTranslation: exampleTranslation,
      lessonId: lessonId,
      level: level,
      languagePair: languagePair,
      category: category,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      inSrs: inSrs ?? this.inSrs,
      addedAt: addedAt,
    );
  }

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return source.toLowerCase().contains(q) ||
        target.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'target': target,
        'pronunciation': pronunciation,
        'example_sentence': exampleSentence,
        'example_translation': exampleTranslation,
        'lesson_id': lessonId,
        'level': level,
        'language_pair': languagePair,
        'category': category.name,
        'notes': notes,
        'tags': tags,
        'in_srs': inSrs,
        'added_at': addedAt,
      };

  factory VocabularyItem.fromJson(Map<String, dynamic> json) => VocabularyItem(
        id: json['id'] as String,
        source: json['source'] as String,
        target: json['target'] as String,
        pronunciation: json['pronunciation'] as String?,
        exampleSentence: json['example_sentence'] as String?,
        exampleTranslation: json['example_translation'] as String?,
        lessonId: json['lesson_id'] as String,
        level: json['level'] as String,
        languagePair: json['language_pair'] as String,
        category: VocabularyCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => VocabularyCategory.phrase,
        ),
        notes: json['notes'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        inSrs: json['in_srs'] as bool? ?? false,
        addedAt: json['added_at'] as String,
      );
}

/// Vocabulary statistics
class VocabularyStats {
  final int total;
  final int inSrs;
  final int notInSrs;
  final Map<String, int> byLevel;
  final Map<String, int> byCategory;

  const VocabularyStats({
    required this.total,
    required this.inSrs,
    required this.notInSrs,
    required this.byLevel,
    required this.byCategory,
  });

  factory VocabularyStats.empty() => const VocabularyStats(
        total: 0,
        inSrs: 0,
        notInSrs: 0,
        byLevel: {},
        byCategory: {},
      );

  factory VocabularyStats.fromItems(List<VocabularyItem> items) {
    if (items.isEmpty) return VocabularyStats.empty();

    final byLevel = <String, int>{};
    final byCategory = <String, int>{};
    int inSrs = 0;

    for (final item in items) {
      byLevel[item.level] = (byLevel[item.level] ?? 0) + 1;
      byCategory[item.category.displayName] =
          (byCategory[item.category.displayName] ?? 0) + 1;
      if (item.inSrs) inSrs++;
    }

    return VocabularyStats(
      total: items.length,
      inSrs: inSrs,
      notInSrs: items.length - inSrs,
      byLevel: byLevel,
      byCategory: byCategory,
    );
  }
}

/// Vocabulary state
class VocabularyState {
  final List<VocabularyItem> items;
  final VocabularyStats stats;
  final bool isLoading;
  final String? searchQuery;
  final String? filterLevel;
  final VocabularyCategory? filterCategory;

  const VocabularyState({
    required this.items,
    required this.stats,
    this.isLoading = false,
    this.searchQuery,
    this.filterLevel,
    this.filterCategory,
  });

  factory VocabularyState.initial() => VocabularyState(
        items: const [],
        stats: VocabularyStats.empty(),
      );

  VocabularyState copyWith({
    List<VocabularyItem>? items,
    VocabularyStats? stats,
    bool? isLoading,
    String? searchQuery,
    String? filterLevel,
    VocabularyCategory? filterCategory,
  }) {
    return VocabularyState(
      items: items ?? this.items,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery,
      filterLevel: filterLevel,
      filterCategory: filterCategory,
    );
  }

  /// Get filtered items
  List<VocabularyItem> get filteredItems {
    var result = items;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      result = result.where((i) => i.matchesQuery(searchQuery!)).toList();
    }

    if (filterLevel != null) {
      result = result.where((i) => i.level == filterLevel).toList();
    }

    if (filterCategory != null) {
      result = result.where((i) => i.category == filterCategory).toList();
    }

    return result;
  }
}

/// Vocabulary notifier
class VocabularyNotifier extends Notifier<VocabularyState> {
  @override
  VocabularyState build() {
    _loadVocabulary();
    return VocabularyState.initial();
  }

  Future<void> _loadVocabulary() async {
    state = state.copyWith(isLoading: true);

    final json = StorageService.instance.loadAllVocabulary();
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        final items = decoded.map((e) => VocabularyItem.fromJson(e)).toList();
        state = VocabularyState(
          items: items,
          stats: VocabularyStats.fromItems(items),
        );
      } catch (e) {
        state = VocabularyState.initial();
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveVocabulary() async {
    final json = jsonEncode(state.items.map((i) => i.toJson()).toList());
    await StorageService.instance.saveAllVocabulary(json);
  }

  /// Add a vocabulary item
  Future<void> addItem(VocabularyItem item) async {
    if (state.items.any((i) => i.id == item.id)) {
      return;
    }

    final newItems = [...state.items, item];
    state = state.copyWith(
      items: newItems,
      stats: VocabularyStats.fromItems(newItems),
    );
    await _saveVocabulary();
  }

  /// Add items from a lesson
  Future<void> addItemsFromLesson({
    required String lessonId,
    required String languagePair,
    required String level,
    required List<Map<String, String>> vocabulary,
  }) async {
    for (final vocab in vocabulary) {
      final item = VocabularyItem.create(
        source: vocab['source'] ?? '',
        target: vocab['target'] ?? '',
        lessonId: lessonId,
        level: level,
        languagePair: languagePair,
        pronunciation: vocab['pronunciation'],
        exampleSentence: vocab['example'],
      );
      await addItem(item);
    }
  }

  /// Mark item as in SRS
  Future<void> markInSrs(String id) async {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final newItems = [...state.items];
    newItems[index] = newItems[index].copyWith(inSrs: true);

    state = state.copyWith(
      items: newItems,
      stats: VocabularyStats.fromItems(newItems),
    );
    await _saveVocabulary();
  }

  /// Update notes for an item
  Future<void> updateNotes(String id, String notes) async {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final newItems = [...state.items];
    newItems[index] = newItems[index].copyWith(notes: notes);

    state = state.copyWith(items: newItems);
    await _saveVocabulary();
  }

  /// Set search query
  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Set level filter
  void setLevelFilter(String? level) {
    state = state.copyWith(filterLevel: level);
  }

  /// Set category filter
  void setCategoryFilter(VocabularyCategory? category) {
    state = state.copyWith(filterCategory: category);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: null,
      filterLevel: null,
      filterCategory: null,
    );
  }

  /// Remove an item
  Future<void> removeItem(String id) async {
    final newItems = state.items.where((i) => i.id != id).toList();
    state = state.copyWith(
      items: newItems,
      stats: VocabularyStats.fromItems(newItems),
    );
    await _saveVocabulary();
  }
}

/// Provider for vocabulary state
final vocabularyProvider =
    NotifierProvider<VocabularyNotifier, VocabularyState>(
        VocabularyNotifier.new);

/// Provider for vocabulary stats
final vocabularyStatsProvider = Provider<VocabularyStats>((ref) {
  return ref.watch(vocabularyProvider).stats;
});

/// Provider for filtered vocabulary items
final filteredVocabularyProvider = Provider<List<VocabularyItem>>((ref) {
  return ref.watch(vocabularyProvider).filteredItems;
});

/// Provider for vocabulary count by level
final vocabularyByLevelProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(vocabularyProvider).stats.byLevel;
});
