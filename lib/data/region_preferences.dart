import 'package:shared_preferences/shared_preferences.dart';

/// All user settings. Reads fall back to defaults until storage answers, and
/// every write retries the platform channel: on a cold start the very first
/// call can fail before the plugin is attached, which used to leave every
/// toggle and star silently dead for the whole session.
class RegionPreferences {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> ready() async {
    final cached = _prefs;
    if (cached != null) return cached;
    return _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> init() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await ready();
        return;
      } catch (_) {
        await Future<void>.delayed(Duration(milliseconds: 250 * (attempt + 1)));
      }
    }
  }

  bool isRegionEnabled(String region) => _prefs?.getBool(region) ?? true;

  Future<void> setRegionEnabled(String region, bool enabled) async {
    await (await ready()).setBool(region, enabled);
  }

  bool get isPowerSavingEnabled => _prefs?.getBool('power_saving') ?? false;

  Future<void> setPowerSavingEnabled(bool value) async {
    await (await ready()).setBool('power_saving', value);
  }

  /// 'system' | 'light' | 'dark'
  String get themeMode => _prefs?.getString('theme_mode') ?? 'system';

  Future<void> setThemeMode(String value) async {
    await (await ready()).setString('theme_mode', value);
  }

  /// 'system' or a language code such as 'sr'.
  String get appLanguage => _prefs?.getString('app_language') ?? 'system';

  Future<void> setAppLanguage(String value) async {
    await (await ready()).setString('app_language', value);
  }

  Set<String> get favorites => _prefs?.getStringList('favorites')?.toSet() ?? {};

  bool isStationFavorite(String streamUrl) => favorites.contains(streamUrl);

  Future<void> toggleFavorite(String streamUrl) async {
    final favorites = this.favorites;
    if (!favorites.remove(streamUrl)) favorites.add(streamUrl);
    await (await ready()).setStringList('favorites', favorites.toList());
  }
}
