import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_bs.dart';
import 'app_localizations_cnr.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_mk.dart';
import 'app_localizations_sq.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('bs'),
    Locale('cnr'),
    Locale('el'),
    Locale('en'),
    Locale('hr'),
    Locale('mk'),
    Locale('sq'),
    Locale('sr')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Balkan Radio'**
  String get appName;

  /// No description provided for @navHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ex-Yu Radio Stations'**
  String get navHeaderSubtitle;

  /// No description provided for @actionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get actionSettings;

  /// No description provided for @menuAllRegions.
  ///
  /// In en, this message translates to:
  /// **'All Regions'**
  String get menuAllRegions;

  /// No description provided for @menuFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get menuFavorites;

  /// No description provided for @menuAlbania.
  ///
  /// In en, this message translates to:
  /// **'Albania'**
  String get menuAlbania;

  /// No description provided for @menuBosnia.
  ///
  /// In en, this message translates to:
  /// **'Bosnia'**
  String get menuBosnia;

  /// No description provided for @menuBulgaria.
  ///
  /// In en, this message translates to:
  /// **'Bulgaria'**
  String get menuBulgaria;

  /// No description provided for @menuCroatia.
  ///
  /// In en, this message translates to:
  /// **'Croatia'**
  String get menuCroatia;

  /// No description provided for @menuGreece.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get menuGreece;

  /// No description provided for @menuMacedonia.
  ///
  /// In en, this message translates to:
  /// **'Macedonia'**
  String get menuMacedonia;

  /// No description provided for @menuMontenegro.
  ///
  /// In en, this message translates to:
  /// **'Montenegro'**
  String get menuMontenegro;

  /// No description provided for @menuSerbia.
  ///
  /// In en, this message translates to:
  /// **'Serbia'**
  String get menuSerbia;

  /// No description provided for @nowPlayingDefault.
  ///
  /// In en, this message translates to:
  /// **'Not Playing'**
  String get nowPlayingDefault;

  /// No description provided for @contentDescriptionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get contentDescriptionPlay;

  /// No description provided for @contentDescriptionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get contentDescriptionPause;

  /// No description provided for @contentDescriptionStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get contentDescriptionStop;

  /// No description provided for @contentDescriptionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get contentDescriptionBack;

  /// No description provided for @titleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// No description provided for @titleEnabledRegions.
  ///
  /// In en, this message translates to:
  /// **'Enabled Regions'**
  String get titleEnabledRegions;

  /// No description provided for @titlePerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get titlePerformance;

  /// No description provided for @labelPowerSaving.
  ///
  /// In en, this message translates to:
  /// **'Power Saving Mode'**
  String get labelPowerSaving;

  /// No description provided for @descPowerSaving.
  ///
  /// In en, this message translates to:
  /// **'Stops the spinning icon animation while a station is playing.'**
  String get descPowerSaving;

  /// No description provided for @titleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get titleLanguage;

  /// No description provided for @labelSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get labelSelectLanguage;

  /// No description provided for @langAlbanian.
  ///
  /// In en, this message translates to:
  /// **'Albanian'**
  String get langAlbanian;

  /// No description provided for @langBosnian.
  ///
  /// In en, this message translates to:
  /// **'Bosnian'**
  String get langBosnian;

  /// No description provided for @langBulgarian.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian'**
  String get langBulgarian;

  /// No description provided for @langCroatian.
  ///
  /// In en, this message translates to:
  /// **'Croatian'**
  String get langCroatian;

  /// No description provided for @langGreek.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get langGreek;

  /// No description provided for @langMacedonian.
  ///
  /// In en, this message translates to:
  /// **'Macedonian'**
  String get langMacedonian;

  /// No description provided for @langMontenegrin.
  ///
  /// In en, this message translates to:
  /// **'Montenegrin'**
  String get langMontenegrin;

  /// No description provided for @langSerbian.
  ///
  /// In en, this message translates to:
  /// **'Serbian'**
  String get langSerbian;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @titleChooseRegion.
  ///
  /// In en, this message translates to:
  /// **'Choose a Region'**
  String get titleChooseRegion;

  /// No description provided for @titleContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get titleContent;

  /// No description provided for @labelRefreshStations.
  ///
  /// In en, this message translates to:
  /// **'Check for new stations'**
  String get labelRefreshStations;

  /// No description provided for @descRefreshStations.
  ///
  /// In en, this message translates to:
  /// **'Updates the list of radio stations from the server.'**
  String get descRefreshStations;

  /// Refresh result
  ///
  /// In en, this message translates to:
  /// **'Station list updated! Total: {count}'**
  String msgStationsUpdated(int count);

  /// No description provided for @msgStationsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update stations. Please try again later.'**
  String get msgStationsUpdateFailed;

  /// No description provided for @titleAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get titleAppearance;

  /// No description provided for @labelTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get labelTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search stations or regions'**
  String get searchHint;

  /// No description provided for @noStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No stations found'**
  String get noStationsFound;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Tap the heart next to a station to add it.'**
  String get favoritesEmpty;

  /// No description provided for @msgKeepOneRegion.
  ///
  /// In en, this message translates to:
  /// **'At least one region must stay enabled.'**
  String get msgKeepOneRegion;

  /// No description provided for @msgPlayError.
  ///
  /// In en, this message translates to:
  /// **'Could not play this station.'**
  String get msgPlayError;

  /// No description provided for @titleAllStations.
  ///
  /// In en, this message translates to:
  /// **'All stations'**
  String get titleAllStations;

  /// No description provided for @contentDescriptionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get contentDescriptionClear;

  /// No description provided for @contentDescriptionFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get contentDescriptionFavorite;

  /// No description provided for @contentDescriptionUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get contentDescriptionUnfavorite;

  /// No description provided for @titleLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get titleLegal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @titleAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get titleAbout;

  /// Version line
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Balkan Radio does not collect, store or share any personal data. There is no account, no tracking, no analytics and no advertising.\n\nYour favorites, enabled regions, theme and language are saved only on this device.\n\nStation lists and audio streams are downloaded directly from third-party servers. As with any internet request, those servers can see your IP address.'**
  String get privacyBody;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'The app is free of charge and provided as is, without any warranty.\n\nAll stations are public internet streams owned by third parties. The app does not host, control or endorse them, and their availability or content may change at any time.\n\nStation lists are updated from the project repository on GitHub. Do not use the app for anything unlawful.'**
  String get termsBody;

  /// No description provided for @msgStorageError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the setting. Try again.'**
  String get msgStorageError;

  /// No description provided for @msgPlaybackInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Stream interrupted.'**
  String get msgPlaybackInterrupted;

  /// No description provided for @titleDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get titleDesign;

  /// No description provided for @designClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get designClassic;

  /// No description provided for @designCyber.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk'**
  String get designCyber;

  /// No description provided for @designModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get designModern;

  /// No description provided for @labelNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get labelNowPlaying;

  /// No description provided for @labelSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get labelSleepTimer;

  /// No description provided for @sleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepOff;

  /// No description provided for @sleepCloseApp.
  ///
  /// In en, this message translates to:
  /// **'Close the app'**
  String get sleepCloseApp;

  /// No description provided for @contentDescriptionPreviousStation.
  ///
  /// In en, this message translates to:
  /// **'Previous station'**
  String get contentDescriptionPreviousStation;

  /// No description provided for @contentDescriptionNextStation.
  ///
  /// In en, this message translates to:
  /// **'Next station'**
  String get contentDescriptionNextStation;

  /// No description provided for @titleUpdate.
  ///
  /// In en, this message translates to:
  /// **'App update'**
  String get titleUpdate;

  /// No description provided for @labelCheckForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for the Update'**
  String get labelCheckForUpdate;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'New update available'**
  String get updateAvailableTitle;

  /// Body of the new-update dialog.
  ///
  /// In en, this message translates to:
  /// **'Version {versionName} is ready to install.'**
  String updateAvailableBody(String versionName);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Install now'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update'**
  String get updateDownloading;

  /// No description provided for @updateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Opening installer'**
  String get updateInstalling;

  /// No description provided for @msgUpdateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version'**
  String get msgUpdateUpToDate;

  /// No description provided for @msgUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update check failed'**
  String get msgUpdateFailed;

  /// No description provided for @msgUpdatePermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Allow installing from this app to update'**
  String get msgUpdatePermissionNeeded;

  /// No description provided for @msgUpdateInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the installer. Try again from Settings.'**
  String get msgUpdateInstallFailed;

  /// No description provided for @msgUpdateInstalled.
  ///
  /// In en, this message translates to:
  /// **'Update ready'**
  String get msgUpdateInstalled;

  /// No description provided for @updateInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get updateInstall;

  /// No description provided for @labelAutoOpenPlayer.
  ///
  /// In en, this message translates to:
  /// **'Open player automatically'**
  String get labelAutoOpenPlayer;

  /// No description provided for @descAutoOpenPlayer.
  ///
  /// In en, this message translates to:
  /// **'The full-screen player opens as soon as a station starts.'**
  String get descAutoOpenPlayer;

  /// No description provided for @labelStopButtonX.
  ///
  /// In en, this message translates to:
  /// **'X instead of stop button'**
  String get labelStopButtonX;

  /// No description provided for @descStopButtonX.
  ///
  /// In en, this message translates to:
  /// **'In the app, the notification and the lock screen.'**
  String get descStopButtonX;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bg',
        'bs',
        'cnr',
        'el',
        'en',
        'hr',
        'mk',
        'sq',
        'sr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'bs':
      return AppLocalizationsBs();
    case 'cnr':
      return AppLocalizationsCnr();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'hr':
      return AppLocalizationsHr();
    case 'mk':
      return AppLocalizationsMk();
    case 'sq':
      return AppLocalizationsSq();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
