import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/srs_provider.dart';
import '../../services/haptic_service.dart';

/// Vocabulary list screen
class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  final _searchController = TextEditingController();
  String? _selectedLevel;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabState = ref.watch(vocabularyProvider);
    final filteredItems = vocabState.filteredItems;
    final stats = vocabState.stats;

    return Scaffold(
      primary: false,
      appBar: AppBar(
        title: const Text('Vocabulary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search vocabulary...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(vocabularyProvider.notifier)
                                  .setSearchQuery(null);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.grey[100],
                  ),
                  onChanged: (value) {
                    ref
                        .read(vocabularyProvider.notifier)
                        .setSearchQuery(value.isEmpty ? null : value);
                  },
                ),
                const SizedBox(height: 12),

                // Level filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _selectedLevel == null,
                        onTap: () {
                          setState(() => _selectedLevel = null);
                          ref
                              .read(vocabularyProvider.notifier)
                              .setLevelFilter(null);
                        },
                      ),
                      for (final level in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'])
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                            label: level,
                            selected: _selectedLevel == level,
                            color: _getLevelColor(level),
                            onTap: () {
                              setState(() => _selectedLevel = level);
                              ref
                                  .read(vocabularyProvider.notifier)
                                  .setLevelFilter(level);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          // Stats bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatBadge(
                  icon: Icons.layers,
                  value: '${stats.total}',
                  label: 'Total',
                ),
                const SizedBox(width: 12),
                _StatBadge(
                  icon: Icons.replay,
                  value: '${stats.inSrs}',
                  label: 'In SRS',
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 12),
                _StatBadge(
                  icon: Icons.add_circle_outline,
                  value: '${stats.notInSrs}',
                  label: 'Not in SRS',
                  color: Colors.grey,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // Vocabulary list
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _VocabularyCard(
                        item: item,
                        onTap: () => _showDetailSheet(item),
                        onAddToSrs: item.inSrs
                            ? null
                            : () => _addToSrs(item),
                      ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No vocabulary found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete lessons to build your vocabulary',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(VocabularyItem item) {
    HapticService.instance.lightTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _VocabularyDetailSheet(item: item),
    );
  }

  void _addToSrs(VocabularyItem item) {
    HapticService.instance.mediumTap();

    // Create SRS card from vocabulary item
    final card = SRSCard.create(
      wordId: item.id,
      sourceWord: item.source,
      targetWord: item.target,
      languagePair: item.languagePair,
      level: item.level,
      lessonId: item.lessonId,
      pronunciation: item.pronunciation,
      exampleSentence: item.exampleSentence,
    );

    ref.read(srsProvider.notifier).addCard(card);
    ref.read(vocabularyProvider.notifier).markInSrs(item.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${item.source}" to SRS'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.levelA1;
      case 'A2':
        return AppColors.levelA2;
      case 'B1':
        return AppColors.levelB1;
      case 'B2':
        return AppColors.levelB2;
      case 'C1':
        return AppColors.levelC1;
      case 'C2':
        return AppColors.levelC2;
      default:
        return Colors.grey;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : chipColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback onTap;
  final VoidCallback? onAddToSrs;

  const _VocabularyCard({
    required this.item,
    required this.onTap,
    this.onAddToSrs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[100],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Level badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getLevelColor(item.level).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.level,
                    style: TextStyle(
                      color: _getLevelColor(item.level),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Word pair
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.source,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item.target,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // SRS indicator or add button
              if (item.inSrs)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.replay,
                        size: 14,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SRS',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (onAddToSrs != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAddToSrs,
                  color: AppColors.primaryGreen,
                  tooltip: 'Add to SRS',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.levelA1;
      case 'A2':
        return AppColors.levelA2;
      case 'B1':
        return AppColors.levelB1;
      case 'B2':
        return AppColors.levelB2;
      case 'C1':
        return AppColors.levelC1;
      case 'C2':
        return AppColors.levelC2;
      default:
        return Colors.grey;
    }
  }
}

class _VocabularyDetailSheet extends StatelessWidget {
  final VocabularyItem item;

  const _VocabularyDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getLevelColor(item.level).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.level,
                  style: TextStyle(
                    color: _getLevelColor(item.level),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.category.displayName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Word pair
          Text(
            item.source,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            item.target,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryGreen,
                ),
          ),

          if (item.pronunciation != null) ...[
            const SizedBox(height: 12),
            Text(
              item.pronunciation!,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          if (item.exampleSentence != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Example',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.exampleSentence!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.levelA1;
      case 'A2':
        return AppColors.levelA2;
      case 'B1':
        return AppColors.levelB1;
      case 'B2':
        return AppColors.levelB2;
      case 'C1':
        return AppColors.levelC1;
      case 'C2':
        return AppColors.levelC2;
      default:
        return Colors.grey;
    }
  }
}
