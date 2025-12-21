import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../services/haptic_service.dart';

/// User settings model
class UserSettings {
  final String? activeLanguagePair;
  final String preferredLevel;
  final String typingMode;
  final bool darkMode;
  final bool hapticEnabled;
  final bool onboardingCompleted;

  const UserSettings({
    this.activeLanguagePair,
    this.preferredLevel = 'A1',
    this.typingMode = 'lenient',
    this.darkMode = false,
    this.hapticEnabled = true,
    this.onboardingCompleted = false,
  });

  UserSettings copyWith({
    String? activeLanguagePair,
    String? preferredLevel,
    String? typingMode,
    bool? darkMode,
    bool? hapticEnabled,
    bool? onboardingCompleted,
  }) {
    return UserSettings(
      activeLanguagePair: activeLanguagePair ?? this.activeLanguagePair,
      preferredLevel: preferredLevel ?? this.preferredLevel,
      typingMode: typingMode ?? this.typingMode,
      darkMode: darkMode ?? this.darkMode,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'activeLanguagePair': activeLanguagePair,
        'preferredLevel': preferredLevel,
        'typingMode': typingMode,
        'darkMode': darkMode,
        'hapticEnabled': hapticEnabled,
        'onboardingCompleted': onboardingCompleted,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        activeLanguagePair: json['activeLanguagePair'] as String?,
        preferredLevel: json['preferredLevel'] as String? ?? 'A1',
        typingMode: json['typingMode'] as String? ?? 'lenient',
        darkMode: json['darkMode'] as bool? ?? false,
        hapticEnabled: json['hapticEnabled'] as bool? ?? true,
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      );
}

/// Settings provider that loads and saves settings
class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    return _loadSettings();
  }

  Future<UserSettings> _loadSettings() async {
    final storage = StorageService.instance;
    final json = storage.loadSettings();

    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        final settings = UserSettings.fromJson(data);
        HapticService.instance.enabled = settings.hapticEnabled;
        return settings;
      } catch (_) {
        // If parsing fails, return defaults
      }
    }

    return const UserSettings();
  }

  Future<void> _saveSettings(UserSettings settings) async {
    final storage = StorageService.instance;
    await storage.saveSettings(jsonEncode(settings.toJson()));
  }

  /// Set the active language pair
  Future<void> setActiveLanguagePair(String? pairCode) async {
    final current = await future;
    final updated = current.copyWith(activeLanguagePair: pairCode);
    state = AsyncValue.data(updated);
    await _saveSettings(updated);
    await StorageService.instance.setActiveLanguagePair(pairCode);
  }

  /// Set the preferred CEFR level
  Future<void> setPreferredLevel(String level) async {
    final current = await future;
    final updated = current.copyWith(preferredLevel: level);
    state = AsyncValue.data(updated);
    await _saveSettings(updated);
  }

  /// Set typing mode (lenient/strict)
  Future<void> setTypingMode(String mode) async {
    final current = await future;
    final updated = current.copyWith(typingMode: mode);
    state = AsyncValue.data(updated);
    await _saveSettings(updated);
  }

  /// Toggle dark mode
  Future<void> setDarkMode(bool enabled) async {
    final current = await future;
    final updated = current.copyWith(darkMode: enabled);
    state = AsyncValue.data(updated);
    await _saveSettings(updated);
  }

  /// Toggle haptic feedback
  Future<void> setHapticEnabled(bool enabled) async {
    final current = await future;
    final updated = current.copyWith(hapticEnabled: enabled);
    state = AsyncValue.data(updated);
    HapticService.instance.enabled = enabled;
    await _saveSettings(updated);
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final current = await future;
    final updated = current.copyWith(onboardingCompleted: true);
    state = AsyncValue.data(updated);
    await _saveSettings(updated);
    await StorageService.instance.setOnboardingCompleted(true);
  }

  /// Reset all settings to defaults
  Future<void> resetSettings() async {
    const defaults = UserSettings();
    state = const AsyncValue.data(defaults);
    await _saveSettings(defaults);
  }
}

/// Provider for user settings
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);
