// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Balkan Radio';

  @override
  String get navHeaderSubtitle => 'Ex-Yu Radio Stations';

  @override
  String get actionSettings => 'Settings';

  @override
  String get menuAllRegions => 'All Regions';

  @override
  String get menuFavorites => 'Favorites';

  @override
  String get menuAlbania => 'Albania';

  @override
  String get menuBosnia => 'Bosnia';

  @override
  String get menuBulgaria => 'Bulgaria';

  @override
  String get menuCroatia => 'Croatia';

  @override
  String get menuGreece => 'Greece';

  @override
  String get menuMacedonia => 'Macedonia';

  @override
  String get menuMontenegro => 'Montenegro';

  @override
  String get menuSerbia => 'Serbia';

  @override
  String get nowPlayingDefault => 'Not Playing';

  @override
  String get contentDescriptionPlay => 'Play';

  @override
  String get contentDescriptionPause => 'Pause';

  @override
  String get contentDescriptionStop => 'Stop';

  @override
  String get contentDescriptionBack => 'Back';

  @override
  String get titleSettings => 'Settings';

  @override
  String get titleEnabledRegions => 'Enabled Regions';

  @override
  String get titlePerformance => 'Performance';

  @override
  String get labelPowerSaving => 'Power Saving Mode';

  @override
  String get descPowerSaving =>
      'Stops the spinning icon animation while a station is playing.';

  @override
  String get titleLanguage => 'Language';

  @override
  String get labelSelectLanguage => 'Select App Language';

  @override
  String get langAlbanian => 'Albanian';

  @override
  String get langBosnian => 'Bosnian';

  @override
  String get langBulgarian => 'Bulgarian';

  @override
  String get langCroatian => 'Croatian';

  @override
  String get langGreek => 'Greek';

  @override
  String get langMacedonian => 'Macedonian';

  @override
  String get langMontenegrin => 'Montenegrin';

  @override
  String get langSerbian => 'Serbian';

  @override
  String get langEnglish => 'English';

  @override
  String get titleChooseRegion => 'Choose a Region';

  @override
  String get titleContent => 'Content';

  @override
  String get labelRefreshStations => 'Check for new stations';

  @override
  String get descRefreshStations =>
      'Updates the list of radio stations from the server.';

  @override
  String msgStationsUpdated(int count) {
    return 'Station list updated! Total: $count';
  }

  @override
  String get msgStationsUpdateFailed =>
      'Failed to update stations. Please try again later.';

  @override
  String get titleAppearance => 'Appearance';

  @override
  String get labelTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSystem => 'System language';

  @override
  String get searchHint => 'Search stations or regions';

  @override
  String get noStationsFound => 'No stations found';

  @override
  String get favoritesEmpty =>
      'No favorites yet. Tap the heart next to a station to add it.';

  @override
  String get msgKeepOneRegion => 'At least one region must stay enabled.';

  @override
  String get msgPlayError => 'Could not play this station.';

  @override
  String get titleAllStations => 'All stations';

  @override
  String get contentDescriptionClear => 'Clear';

  @override
  String get contentDescriptionFavorite => 'Add to favorites';

  @override
  String get contentDescriptionUnfavorite => 'Remove from favorites';

  @override
  String get titleLegal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get titleAbout => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get privacyBody =>
      'Balkan Radio does not collect, store or share any personal data. There is no account, no tracking, no analytics and no advertising.\n\nYour favorites, enabled regions, theme and language are saved only on this device.\n\nStation lists and audio streams are downloaded directly from third-party servers. As with any internet request, those servers can see your IP address.';

  @override
  String get termsBody =>
      'The app is free of charge and provided as is, without any warranty.\n\nAll stations are public internet streams owned by third parties. The app does not host, control or endorse them, and their availability or content may change at any time.\n\nStation lists are updated from the project repository on GitHub. Do not use the app for anything unlawful.';

  @override
  String get msgStorageError => 'Could not save the setting. Try again.';

  @override
  String get msgPlaybackInterrupted => 'Stream interrupted.';

  @override
  String get titleDesign => 'Design';

  @override
  String get designClassic => 'Classic';

  @override
  String get designCyber => 'Cyberpunk';

  @override
  String get designModern => 'Modern';

  @override
  String get labelNowPlaying => 'Now playing';

  @override
  String get labelSleepTimer => 'Sleep timer';

  @override
  String get sleepOff => 'Off';

  @override
  String get sleepCloseApp => 'Close the app';

  @override
  String get contentDescriptionPreviousStation => 'Previous station';

  @override
  String get contentDescriptionNextStation => 'Next station';

  @override
  String get titleUpdate => 'App update';

  @override
  String get labelCheckForUpdate => 'Check for app update';

  @override
  String get descCheckForUpdate => 'Looks for a newer version on GitHub';

  @override
  String get updateAvailableTitle => 'New update available';

  @override
  String updateAvailableBody(String versionName) {
    return 'Version $versionName is ready to install.';
  }

  @override
  String get updateNow => 'Install now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateDownloading => 'Downloading update';

  @override
  String get updateInstalling => 'Opening installer';

  @override
  String get msgUpdateUpToDate => 'You have the latest version';

  @override
  String get msgUpdateFailed => 'Update check failed';

  @override
  String get msgUpdatePermissionNeeded =>
      'Allow installing from this app to update';

  @override
  String get msgUpdateInstalled => 'Update ready';
}
