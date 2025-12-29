import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/haptic_service.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User selections
  String? _sourceLanguage;
  String? _targetDialect;
  String? _selectedLevel;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      HapticService.instance.lightTap();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticService.instance.lightTap();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_targetDialect != null) {
      HapticService.instance.success();

      // Determine language pair code
      String pairCode;
      if (_sourceLanguage == 'english') {
        pairCode = _targetDialect == 'pt_PT' ? 'en_to_pt_pt' : 'en_to_pt_br';
      } else {
        pairCode = _targetDialect == 'pt_PT' ? 'pt_pt_to_en' : 'pt_br_to_en';
      }

      // Save settings
      await ref.read(settingsProvider.notifier).setActiveLanguagePair(pairCode);
      if (_selectedLevel != null) {
        await ref
            .read(settingsProvider.notifier)
            .setPreferredLevel(_selectedLevel!);
      }
      await ref.read(settingsProvider.notifier).completeOnboarding();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(4, (index) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primaryGreen
                            : (isDark
                                ? AppColors.progressBackgroundDark
                                : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _SourceLanguagePage(
                    selected: _sourceLanguage,
                    onSelect: (lang) {
                      setState(() => _sourceLanguage = lang);
                      Future.delayed(
                          const Duration(milliseconds: 300), _nextPage);
                    },
                  ),
                  _TargetDialectPage(
                    sourceLanguage: _sourceLanguage,
                    selected: _targetDialect,
                    onSelect: (dialect) {
                      setState(() => _targetDialect = dialect);
                      Future.delayed(
                          const Duration(milliseconds: 300), _nextPage);
                    },
                  ),
                  _LevelSelectionPage(
                    selected: _selectedLevel,
                    onSelect: (level) {
                      setState(() => _selectedLevel = level);
                    },
                    onComplete: _completeOnboarding,
                  ),
                ],
              ),
            ),

            // Back button (not on first page)
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          )
              .animate()
              .scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text("Let's Start!"),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _SourceLanguagePage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SourceLanguagePage({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'I speak...',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Select your native language',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 48),
          _LanguageCard(
            flag: '🇬🇧',
            name: 'English',
            isSelected: selected == 'english',
            onTap: () {
              HapticService.instance.selection();
              onSelect('english');
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          _LanguageCard(
            flag: '🇵🇹',
            name: 'Portuguese',
            isSelected: selected == 'portuguese',
            onTap: () {
              HapticService.instance.selection();
              onSelect('portuguese');
            },
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
        ],
      ),
    );
  }
}

class _TargetDialectPage extends StatelessWidget {
  final String? sourceLanguage;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _TargetDialectPage({
    required this.sourceLanguage,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isLearningPortuguese = sourceLanguage == 'english';
    final titleText = isLearningPortuguese ? 'I want to learn...' : 'I speak...';

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            titleText,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Choose your dialect',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 48),
          _LanguageCard(
            flag: '🇵🇹',
            name: 'European Portuguese',
            subtitle: 'Portugal',
            isSelected: selected == 'pt_PT',
            onTap: () {
              HapticService.instance.selection();
              onSelect('pt_PT');
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          _LanguageCard(
            flag: '🇧🇷',
            name: 'Brazilian Portuguese',
            subtitle: 'Brazil',
            isSelected: selected == 'pt_BR',
            onTap: () {
              HapticService.instance.selection();
              onSelect('pt_BR');
            },
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
        ],
      ),
    );
  }
}

class _LevelSelectionPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onComplete;

  const _LevelSelectionPage({
    required this.selected,
    required this.onSelect,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Your level',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Select your current proficiency',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _LevelCard(
                  level: 'A1',
                  name: 'Beginner',
                  color: AppColors.levelA1,
                  isSelected: selected == 'A1',
                  onTap: () {
                    HapticService.instance.selection();
                    onSelect('A1');
                  },
                ),
                _LevelCard(
                  level: 'A2',
                  name: 'Elementary',
                  color: AppColors.levelA2,
                  isSelected: selected == 'A2',
                  onTap: () {
                    HapticService.instance.selection();
                    onSelect('A2');
                  },
                ),
                _LevelCard(
                  level: 'B1',
                  name: 'Intermediate',
                  color: AppColors.levelB1,
                  isSelected: selected == 'B1',
                  onTap: () {
                    HapticService.instance.selection();
                    onSelect('B1');
                  },
                ),
                _LevelCard(
                  level: 'B2',
                  name: 'Upper Int.',
                  color: AppColors.levelB2,
                  isSelected: selected == 'B2',
                  onTap: () {
                    HapticService.instance.selection();
                    onSelect('B2');
                  },
                ),
                _LevelCard(
                  level: 'C1',
                  name: 'Advanced',
                  color: AppColors.levelC1,
                  isSelected: selected == 'C1',
                  onTap: () {
                    HapticService.instance.selection();
                    onSelect('C1');
                  },
                ),
                _LevelCard(
                  level: 'C2',
                  name: 'Mastery',
                  color: AppColors.levelC2,
                  isSelected: selected == 'C2',
                  onTap: () {
                    HapticService.instance.selection();
                    onSelect('C2');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected != null ? onComplete : null,
              child: const Text('Start Learning'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String name;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.name,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              level,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
