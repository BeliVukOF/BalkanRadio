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

  /// No description provided for @navigationDrawerOpen.
  ///
  /// In en, this message translates to:
  /// **'Open navigation drawer'**
  String get navigationDrawerOpen;

  /// No description provided for @navigationDrawerClose.
  ///
  /// In en, this message translates to:
  /// **'Close navigation drawer'**
  String get navigationDrawerClose;

  /// No description provided for @navHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Balkan Radio'**
  String get navHeaderTitle;

  /// No description provided for @navHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ex-Yu Radio Stations'**
  String get navHeaderSubtitle;

  /// No description provided for @navHeaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Navigation header'**
  String get navHeaderDesc;

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

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

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

  /// No description provided for @labelAlbania.
  ///
  /// In en, this message translates to:
  /// **'Albania'**
  String get labelAlbania;

  /// No description provided for @labelBosnia.
  ///
  /// In en, this message translates to:
  /// **'Bosnia'**
  String get labelBosnia;

  /// No description provided for @labelBulgaria.
  ///
  /// In en, this message translates to:
  /// **'Bulgaria'**
  String get labelBulgaria;

  /// No description provided for @labelCroatia.
  ///
  /// In en, this message translates to:
  /// **'Croatia'**
  String get labelCroatia;

  /// No description provided for @labelGreece.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get labelGreece;

  /// No description provided for @labelMacedonia.
  ///
  /// In en, this message translates to:
  /// **'Macedonia'**
  String get labelMacedonia;

  /// No description provided for @labelMontenegro.
  ///
  /// In en, this message translates to:
  /// **'Montenegro'**
  String get labelMontenegro;

  /// No description provided for @labelSerbia.
  ///
  /// In en, this message translates to:
  /// **'Serbia'**
  String get labelSerbia;

  /// No description provided for @labelAllRegions.
  ///
  /// In en, this message translates to:
  /// **'All Regions'**
  String get labelAllRegions;

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
  /// **'No favorites yet. Tap the star next to a station to add it.'**
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
