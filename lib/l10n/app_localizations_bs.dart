// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

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
  String get menuBosnia => 'Bosna i Hercegovina';

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
  String get contentDescriptionPlay => 'Reprodukuj';

  @override
  String get contentDescriptionPause => 'Pauziraj';

  @override
  String get contentDescriptionStop => 'Zaustavi';

  @override
  String get contentDescriptionBack => 'Nazad';

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
  String get descRefreshStations => 'Ažurira listu radio stanica sa servera.';

  @override
  String msgStationsUpdated(int count) {
    return 'Lista stanica ažurirana! Ukupno: $count';
  }

  @override
  String get msgStationsUpdateFailed =>
      'Neuspješno ažuriranje stanica. Pokušajte ponovo kasnije.';

  @override
  String get titleAppearance => 'Izgled';

  @override
  String get labelTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Svijetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get languageSystem => 'Jezik sistema';

  @override
  String get searchHint => 'Pretraži stanice ili regije';

  @override
  String get noStationsFound => 'Nema pronađenih stanica';

  @override
  String get favoritesEmpty =>
      'Još nema omiljenih. Dodirni zvjezdicu pored stanice da je dodaš.';

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
  String get privacyPolicy => 'Politika privatnosti';

  @override
  String get termsOfService => 'Uslovi korištenja';

  @override
  String get titleAbout => 'O aplikaciji';

  @override
  String aboutVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get privacyBody =>
      'Balkan Radio ne prikuplja, ne čuva i ne dijeli nikakve lične podatke. Nema računa, nema praćenja, nema analitike i nema oglašavanja.\n\nOmiljene stanice, omogućene regije, tema i jezik čuvaju se samo na ovom uređaju.\n\nListe stanica i audio strimovi preuzimaju se direktno sa servera trećih strana. Kao i kod svakog internet zahtjeva, ti serveri mogu vidjeti vašu IP adresu.';

  @override
  String get termsBody =>
      'Aplikacija je besplatna i pruža se takva kakva jeste, bez ikakve garancije.\n\nSve stanice su javni internet strimovi u vlasništvu trećih strana. Aplikacija ih ne hostuje, ne kontroliše i ne podržava, a njihova dostupnost i sadržaj se mogu promijeniti u svakom trenutku.\n\nListe stanica se ažuriraju iz repozitorija projekta na GitHub-u. Ne koristite aplikaciju za nezakonite radnje.';

  @override
  String get msgStorageError =>
      'Nije moguće sačuvati postavku. Pokušajte ponovo.';

  @override
  String get msgPlaybackInterrupted => 'Strim je prekinut.';

  @override
  String get titleDesign => 'Dizajn';

  @override
  String get designClassic => 'Klasik';

  @override
  String get designBold => 'Novi izgled';

  @override
  String get labelNowPlaying => 'Trenutno svira';

  @override
  String get labelSleepTimer => 'Tajmer za spavanje';

  @override
  String get sleepOff => 'Isključi';

  @override
  String get sleepCloseApp => 'Zatvori aplikaciju';
}
