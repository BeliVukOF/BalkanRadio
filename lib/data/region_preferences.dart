import 'package:shared_preferences/shared_preferences.dart';

class RegionPreferences {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool isRegionEnabled(String region) => _prefs?.getBool(region) ?? true;

  Future<void> setRegionEnabled(String region, bool enabled) async {
    await _prefs?.setBool(region, enabled);
  }

  bool get isPowerSavingEnabled => _prefs?.getBool('power_saving') ?? false;

  Future<void> setPowerSavingEnabled(bool value) async {
    await _prefs?.setBool('power_saving', value);
  }

  /// 'system' | 'light' | 'dark'
  String get themeMode => _prefs?.getString('theme_mode') ?? 'system';

  Future<void> setThemeMode(String value) async {
    await _prefs?.setString('theme_mode', value);
  }

  /// 'system' or a language code such as 'sr'.
  String get appLanguage => _prefs?.getString('app_language') ?? 'system';

  Future<void> setAppLanguage(String value) async {
    await _prefs?.setString('app_language', value);
  }

  Set<String> get favorites => _prefs?.getStringList('favorites')?.toSet() ?? {};

  bool isStationFavorite(String streamUrl) => favorites.contains(streamUrl);

  Future<void> toggleFavorite(String streamUrl) async {
    final favorites = this.favorites;
    if (!favorites.remove(streamUrl)) favorites.add(streamUrl);
    await _prefs?.setStringList('favorites', favorites.toList());
  }
}
