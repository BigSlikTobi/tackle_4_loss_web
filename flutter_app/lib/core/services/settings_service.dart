import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team_model.dart';
import 'team_service.dart';
import '../../design_tokens.dart';

class SettingsService with ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal() {
    _initLocale();
    _loadPersistedTeam();
    _loadPersistedTheme();
  }

  Locale _locale = const Locale('en');
  Team? _selectedTeam;
  ThemeMode _themeMode = ThemeMode.light;

  static const String _teamKey = 'selected_team_id';
  static const String _themeKey = 'theme_mode';

  Locale get locale => _locale;
  Team? get selectedTeam => _selectedTeam;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Immersive Background Logic
  LinearGradient get backgroundGradient {
    // 1. Team Takeover (Dynamic)
    if (_selectedTeam != null) {
      if (isDarkMode) {
        // Dark Mode: Deep, shiny team color usage
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedTeam!.primaryColor, // Team Color
            Color.lerp(_selectedTeam!.primaryColor, Colors.black, 0.8)!, // Deep Fade
          ],
        );
      } else {
        // Light Mode: Bright, slightly more intense tint of team color
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             // Start soft but visible (15% mix)
            Color.lerp(Colors.white, _selectedTeam!.primaryColor, 0.15)!,
            // End with a distinctive punch (50% mix)
            Color.lerp(Colors.white, _selectedTeam!.primaryColor, 0.5)!, 
          ],
        );
      }
    }

    // 2. Default Themes (No Team Selected)
    if (isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
           Color(0xFF0F0F12),
           Color(0xFF1A1A24),
        ],
      );
    } else {
      // Light Mode (Default)
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.neutralBase,
          AppColors.neutralSoft,
        ],
      );
    }
  }

  void _initLocale() {
    // Detect system locale
    final String languageCode = PlatformDispatcher.instance.locale.languageCode;
    if (languageCode == 'de') {
      _locale = const Locale('de');
    } else {
      _locale = const Locale('en');
    }
  }

  void setLocale(Locale newLocale) {
    if (newLocale != _locale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  Future<void> _loadPersistedTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final teamId = prefs.getString(_teamKey);
    if (teamId != null) {
      final teams = TeamService().getTeams();
      final team = teams.firstWhere(
        (t) => t.id == teamId,
        orElse: () => teams.first,
      );
      _selectedTeam = team;
      notifyListeners();
    }
  }

  Future<void> setFavoriteTeam(Team team) async {
    if (_selectedTeam?.id != team.id) {
      _selectedTeam = team;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_teamKey, team.id);
    }
  }

  Future<void> _loadPersistedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
  }
}
