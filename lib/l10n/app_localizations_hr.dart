// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appName => 'Balkan Radio';

  @override
  String get navHeaderSubtitle => 'Ex-Yu Radio Stanice';

  @override
  String get actionSettings => 'Postavke';

  @override
  String get menuAllRegions => 'Sve regije';

  @override
  String get menuFavorites => 'Omiljene stanice';

  @override
  String get menuAlbania => 'Albanija';

  @override
  String get menuBosnia => 'BiH';

  @override
  String get menuBulgaria => 'Bugarska';

  @override
  String get menuCroatia => 'Hrvatska';

  @override
  String get menuGreece => 'Grčka';

  @override
  String get menuMacedonia => 'Makedonija';

  @override
  String get menuMontenegro => 'Crna Gora';

  @override
  String get menuSerbia => 'Srbija';

  @override
  String get nowPlayingDefault => 'Trenutno ništa ne svira';

  @override
  String get contentDescriptionPlay => 'Reproduciraj';

  @override
  String get contentDescriptionPause => 'Pauziraj';

  @override
  String get contentDescriptionStop => 'Zaustavi';

  @override
  String get contentDescriptionBack => 'Natrag';

  @override
  String get titleSettings => 'Postavke';

  @override
  String get titleEnabledRegions => 'Omogućene regije';

  @override
  String get titlePerformance => 'Performanse';

  @override
  String get labelPowerSaving => 'Štednja baterije';

  @override
  String get descPowerSaving =>
      'Isključuje animaciju rotiranja ikone dok stanica svira.';

  @override
  String get titleLanguage => 'Jezik';

  @override
  String get labelSelectLanguage => 'Odaberite jezik aplikacije';

  @override
  String get langAlbanian => 'Albanski';

  @override
  String get langBosnian => 'Bosanski';

  @override
  String get langBulgarian => 'Bugarski';

  @override
  String get langCroatian => 'Hrvatski';

  @override
  String get langGreek => 'Grčki';

  @override
  String get langMacedonian => 'Makedonski';

  @override
  String get langMontenegrin => 'Crnogorski';

  @override
  String get langSerbian => 'Srpski';

  @override
  String get langEnglish => 'Engleski';

  @override
  String get titleChooseRegion => 'Odaberite regiju';

  @override
  String get titleContent => 'Sadržaj';

  @override
  String get labelRefreshStations => 'Provjeri nove stanice';

  @override
  String get descRefreshStations =>
      'Ažurira popis radio stanica s poslužitelja.';

  @override
  String msgStationsUpdated(int count) {
    return 'Popis stanica ažuriran! Ukupno: $count';
  }

  @override
  String get msgStationsUpdateFailed =>
      'Neuspješno ažuriranje stanica. Pokušajte ponovno kasnije.';

  @override
  String get titleAppearance => 'Izgled';

  @override
  String get labelTheme => 'Tema';

  @override
  String get themeSystem => 'Sustav';

  @override
  String get themeLight => 'Svijetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get languageSystem => 'Jezik sustava';

  @override
  String get searchHint => 'Pretraži stanice ili regije';

  @override
  String get noStationsFound => 'Nema pronađenih stanica';

  @override
  String get favoritesEmpty =>
      'Još nema omiljenih. Dodirni zvjezdicu pokraj stanice da je dodaš.';

  @override
  String get msgKeepOneRegion => 'Mora ostati omogućena barem jedna regija.';

  @override
  String get msgPlayError => 'Nije moguće pokrenuti ovu stanicu.';

  @override
  String get titleAllStations => 'Sve stanice';

  @override
  String get contentDescriptionClear => 'Očisti';

  @override
  String get contentDescriptionFavorite => 'Dodaj u omiljene';

  @override
  String get contentDescriptionUnfavorite => 'Ukloni iz omiljenih';

  @override
  String get titleLegal => 'Pravno';

  @override
  String get privacyPolicy => 'Pravila privatnosti';

  @override
  String get termsOfService => 'Uvjeti korištenja';

  @override
  String get titleAbout => 'O aplikaciji';

  @override
  String aboutVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get privacyBody =>
      'Balkan Radio ne prikuplja, ne čuva i ne dijeli nikakve osobne podatke. Nema računa, nema praćenja, nema analitike i nema oglašavanja.\n\nOmiljene stanice, omogućene regije, tema i jezik čuvaju se samo na ovom uređaju.\n\nPopisi stanica i audio streamovi preuzimaju se izravno s poslužitelja trećih strana. Kao i kod svakog internetskog zahtjeva, ti poslužitelji mogu vidjeti vašu IP adresu.';

  @override
  String get termsBody =>
      'Aplikacija je besplatna i pruža se takva kakva jest, bez ikakvog jamstva.\n\nSve stanice su javni internetski streamovi u vlasništvu trećih strana. Aplikacija ih ne hosta, ne kontrolira i ne podržava, a njihova dostupnost i sadržaj mogu se promijeniti u svakom trenutku.\n\nPopisi stanica ažuriraju se iz repozitorija projekta na GitHubu. Ne koristite aplikaciju za nezakonite radnje.';

  @override
  String get msgStorageError =>
      'Nije moguće spremiti postavku. Pokušajte ponovno.';

  @override
  String get msgPlaybackInterrupted => 'Stream je prekinut.';

  @override
  String get titleDesign => 'Dizajn';

  @override
  String get designClassic => 'Klasik';

  @override
  String get designCyber => 'Cyberpunk';

  @override
  String get designModern => 'Modern';

  @override
  String get labelNowPlaying => 'Trenutno svira';

  @override
  String get labelSleepTimer => 'Tajmer za spavanje';

  @override
  String get sleepOff => 'Isključi';

  @override
  String get sleepCloseApp => 'Zatvori aplikaciju';
}
