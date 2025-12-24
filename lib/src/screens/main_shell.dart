import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home/home_screen.dart';
import 'review/review_screen.dart';
import 'vocabulary/vocabulary_screen.dart';
import 'statistics/statistics_screen.dart';
import '../theme/colors.dart';

/// Selected navigation index provider
final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main shell with bottom navigation bar
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: const [
              HomeScreen(),
              ReviewScreen(),
              VocabularyScreen(),
              StatisticsScreen(),
            ],
          ),
        ),
        Material(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                ref.read(selectedNavIndexProvider.notifier).state = index;
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              selectedItemColor: AppColors.primaryGreen,
              unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.replay_outlined),
                  activeIcon: Icon(Icons.replay),
                  label: 'Review',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.book),
                  label: 'Vocab',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Stats',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
