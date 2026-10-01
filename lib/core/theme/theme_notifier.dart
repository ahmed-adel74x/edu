import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's theme mode — light, dark, or following the system — persisted
/// between launches.
///
/// A plain [ChangeNotifier] on purpose: `MaterialApp` needs the mode and the
/// Settings screen only has to call the setters, so no state-management package
/// is needed; the shape (one value + setters) keeps a later Cubit swap
/// mechanical.
class ThemeNotifier extends ChangeNotifier {
  /// Starts on the given [mode]; [loadSaved] reads the persisted one for main().
  ThemeNotifier([this._mode = ThemeMode.system]);

  /// Where the choice is kept between launches.
  static const prefsKey = 'themeMode';

  /// The mode the last session ended on, or [ThemeMode.system] on a first run.
  static Future<ThemeMode> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return fromName(prefs.getString(prefsKey));
  }

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  bool get isLight => _mode == ThemeMode.light;
  bool get isDark => _mode == ThemeMode.dark;

  /// True while the app follows the platform's brightness.
  bool get followsSystem => _mode == ThemeMode.system;

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, mode.name);
  }

  Future<void> useLight() => setMode(ThemeMode.light);

  Future<void> useDark() => setMode(ThemeMode.dark);

  Future<void> useSystem() => setMode(ThemeMode.system);

  /// [ThemeMode.name] back to a mode; anything unknown follows the system.
  static ThemeMode fromName(String? name) => switch (name) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

/// Makes the app's [ThemeNotifier] reachable from every screen — the Settings
/// screen will read and drive it through here.
class ThemeScope extends InheritedNotifier<ThemeNotifier> {
  const ThemeScope({
    super.key,
    required ThemeNotifier super.notifier,
    required super.child,
  });

  static ThemeNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found above this context.');
    return scope!.notifier!;
  }
}
