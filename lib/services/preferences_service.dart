import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeModeKey = 'theme_mode';
  static const String _usernameKey = 'username';
  static const String _localeKey = 'locale';
  static const String _pinnedGroupsKey = 'pinned_groups';
  static const String _groupsOrderKey = 'groups_order';

  static SharedPreferences? _preferences;

  /// Initialize the preferences service
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Get saved theme mode (defaults to system)
  static ThemeMode getThemeMode() {
    final themeModeString = _preferences?.getString(_themeModeKey);
    if (themeModeString == null) {
      return ThemeMode.system;
    }

    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Save theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      default:
        modeString = 'system';
    }
    await _preferences?.setString(_themeModeKey, modeString);
  }

  /// Get saved username (defaults to 'User')
  static String getUsername() {
    return _preferences?.getString(_usernameKey) ?? 'User';
  }

  /// Save username
  static Future<void> setUsername(String username) async {
    await _preferences?.setString(_usernameKey, username);
  }

  /// Get saved locale (defaults to English US)
  static Locale getLocale() {
    final localeString = _preferences?.getString(_localeKey);
    if (localeString == null) {
      return const Locale('en', 'US');
    }
    // Parse locale string (format: "en_US" or "ar_EG")
    final parts = localeString.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  /// Save locale
  static Future<void> setLocale(Locale locale) async {
    final localeString = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await _preferences?.setString(_localeKey, localeString);
  }

  /// Get pinned group IDs
  static List<String> getPinnedGroups() {
    return _preferences?.getStringList(_pinnedGroupsKey) ?? [];
  }

  /// Save pinned group IDs
  static Future<void> setPinnedGroups(List<String> groupIds) async {
    await _preferences?.setStringList(_pinnedGroupsKey, groupIds);
  }

  /// Check if a group is pinned
  static bool isGroupPinned(String groupId) {
    final pinned = getPinnedGroups();
    return pinned.contains(groupId);
  }

  /// Toggle pin status for a group
  static Future<void> toggleGroupPin(String groupId) async {
    final pinned = getPinnedGroups();
    if (pinned.contains(groupId)) {
      pinned.remove(groupId);
    } else {
      pinned.add(groupId);
    }
    await setPinnedGroups(pinned);
  }

  /// Get custom groups order
  static List<String> getGroupsOrder() {
    return _preferences?.getStringList(_groupsOrderKey) ?? [];
  }

  /// Save custom groups order
  static Future<void> setGroupsOrder(List<String> groupIds) async {
    await _preferences?.setStringList(_groupsOrderKey, groupIds);
  }
}
