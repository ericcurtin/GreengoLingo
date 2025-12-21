import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section
            _SectionHeader(title: 'Appearance'),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: settings.darkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDarkMode(value);
                },
                activeColor: AppTheme.primaryGreen,
              ),
            ),

            const SizedBox(height: 24),

            // Learning Section
            _SectionHeader(title: 'Learning'),
            _SettingsTile(
              icon: Icons.translate,
              title: 'Language Pair',
              subtitle: _getLanguagePairName(settings.activeLanguagePair),
              onTap: () => _showLanguagePairDialog(context, ref),
            ),
            _SettingsTile(
              icon: Icons.school_outlined,
              title: 'Preferred Level',
              subtitle: settings.preferredLevel,
              onTap: () => _showLevelDialog(context, ref, settings.preferredLevel),
            ),
            _SettingsTile(
              icon: Icons.keyboard_outlined,
              title: 'Typing Mode',
              subtitle: settings.typingMode == 'lenient'
                  ? 'Lenient (ignores accents)'
                  : 'Strict (requires accents)',
              onTap: () => _showTypingModeDialog(context, ref, settings.typingMode),
            ),

            const SizedBox(height: 24),

            // Feedback Section
            _SectionHeader(title: 'Feedback'),
            _SettingsTile(
              icon: Icons.vibration,
              title: 'Haptic Feedback',
              trailing: Switch(
                value: settings.hapticEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setHapticEnabled(value);
                },
                activeColor: AppTheme.primaryGreen,
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            _SectionHeader(title: 'About'),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '0.1.0',
            ),
            _SettingsTile(
              icon: Icons.code,
              title: 'Open Source',
              subtitle: 'View on GitHub',
              onTap: () {
                // TODO: Open GitHub link
              },
            ),

            const SizedBox(height: 24),

            // Reset Section
            _SectionHeader(title: 'Data'),
            _SettingsTile(
              icon: Icons.refresh,
              title: 'Reset Progress',
              subtitle: 'Clear all learning data',
              iconColor: AppColors.error,
              onTap: () => _showResetDialog(context, ref),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _getLanguagePairName(String? pairCode) {
    switch (pairCode) {
      case 'en_to_pt_pt':
        return 'English → European Portuguese';
      case 'en_to_pt_br':
        return 'English → Brazilian Portuguese';
      case 'pt_pt_to_en':
        return 'European Portuguese → English';
      case 'pt_br_to_en':
        return 'Brazilian Portuguese → English';
      default:
        return 'Not selected';
    }
  }

  void _showLanguagePairDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language Pair'),
        children: [
          _DialogOption(
            title: 'English → European Portuguese',
            onTap: () {
              ref.read(settingsProvider.notifier).setActiveLanguagePair('en_to_pt_pt');
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'English → Brazilian Portuguese',
            onTap: () {
              ref.read(settingsProvider.notifier).setActiveLanguagePair('en_to_pt_br');
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'European Portuguese → English',
            onTap: () {
              ref.read(settingsProvider.notifier).setActiveLanguagePair('pt_pt_to_en');
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Brazilian Portuguese → English',
            onTap: () {
              ref.read(settingsProvider.notifier).setActiveLanguagePair('pt_br_to_en');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLevelDialog(BuildContext context, WidgetRef ref, String currentLevel) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Level'),
        children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
          return _DialogOption(
            title: level,
            selected: level == currentLevel,
            onTap: () {
              ref.read(settingsProvider.notifier).setPreferredLevel(level);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showTypingModeDialog(BuildContext context, WidgetRef ref, String currentMode) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Typing Mode'),
        children: [
          _DialogOption(
            title: 'Lenient',
            subtitle: 'Ignores accent marks (café = cafe)',
            selected: currentMode == 'lenient',
            onTap: () {
              ref.read(settingsProvider.notifier).setTypingMode('lenient');
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Strict',
            subtitle: 'Requires exact accent marks',
            selected: currentMode == 'strict',
            onTap: () {
              ref.read(settingsProvider.notifier).setTypingMode('strict');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all your learning progress, XP, streaks, and achievements. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset')),
              );
            },
            child: Text(
              'Reset',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textMedium,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryGreen),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
      ),
    );
  }
}

class _DialogOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DialogOption({
    required this.title,
    this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: selected
          ? const Icon(Icons.check, color: AppTheme.primaryGreen)
          : null,
      onTap: onTap,
    );
  }
}
