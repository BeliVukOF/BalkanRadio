// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appName => 'Balkan Radio';

  @override
  String get navigationDrawerOpen => 'Otvori meni';

  @override
  String get navigationDrawerClose => 'Zatvori meni';

  @override
  String get navHeaderTitle => 'Balkan Radio';

  @override
  String get navHeaderSubtitle => 'Ex-Yu Radio Stanice';

  @override
  String get navHeaderDesc => 'Zaglavlje menija';

  @override
  String get actionSettings => 'Podešavanja';

  @override
  String get menuAllRegions => 'Svi Regioni';

  @override
  String get menuFavorites => 'Omiljene Stanice';

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
  String get menuSettings => 'Podešavanja';

  @override
  String get nowPlayingDefault => 'Ništa ne svira';

  @override
  String get contentDescriptionPlay => 'Pusti';

  @override
  String get contentDescriptionPause => 'Pauziraj';

  @override
  String get contentDescriptionStop => 'Zaustavi';

  @override
  String get contentDescriptionBack => 'Nazad';

  @override
  String get titleSettings => 'Podešavanja';

  @override
  String get titleEnabledRegions => 'Omogućeni Regioni';

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
  String get labelSelectLanguage => 'Izaberi jezik aplikacije';

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
  String get titleChooseRegion => 'Izaberi Region';

  @override
  String get labelAlbania => 'Albanija';

  @override
  String get labelBosnia => 'Bosna';

  @override
  String get labelBulgaria => 'Bugarska';

  @override
  String get labelCroatia => 'Hrvatska';

  @override
  String get labelGreece => 'Grčka';

  @override
  String get labelMacedonia => 'Makedonija';

  @override
  String get labelMontenegro => 'Crna Gora';

  @override
  String get labelSerbia => 'Srbija';

  @override
  String get labelAllRegions => 'Svi Regioni';

  @override
  String get titleContent => 'Sadržaj';

  @override
  String get labelRefreshStations => 'Proveri nove stanice';

  @override
  String get descRefreshStations => 'Ažurira listu radio stanica sa servera.';

  @override
  String msgStationsUpdated(int count) {
    return 'Lista stanica ažurirana! Ukupno: $count';
  }

  @override
  String get msgStationsUpdateFailed =>
      'Neuspešno ažuriranje stanica. Pokušajte ponovo kasnije.';

  @override
  String get titleAppearance => 'Izgled';

  @override
  String get labelTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Svetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get languageSystem => 'Jezik sistema';

  @override
  String get searchHint => 'Pretraži stanice ili regione';

  @override
  String get noStationsFound => 'Nema pronađenih stanica';

  @override
  String get favoritesEmpty =>
      'Još nema omiljenih. Dodirni zvezdicu pored stanice da je dodaš.';

  @override
  String get msgKeepOneRegion => 'Mora ostati omogućen bar jedan region.';

  @override
  String get msgPlayError => 'Nije moguće pustiti ovu stanicu.';

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
  String get termsOfService => 'Uslovi korišćenja';

  @override
  String get titleAbout => 'O aplikaciji';

  @override
  String aboutVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get privacyBody =>
      'Balkan Radio ne prikuplja, ne čuva i ne deli nikakve lične podatke. Nema naloga, nema praćenja, nema analitike i nema oglašavanja.\n\nOmiljene stanice, omogućeni regioni, tema i jezik čuvaju se samo na ovom uređaju.\n\nListe stanica i audio strimovi preuzimaju se direktno sa servera trećih strana. Kao i kod svakog internet zahteva, ti serveri mogu videti tvoju IP adresu.';

  @override
  String get termsBody =>
      'Aplikacija je besplatna i pruža se takva kakva jeste, bez ikakve garancije.\n\nSve stanice su javni internet strimovi u vlasništvu trećih strana. Aplikacija ih ne hostuje, ne kontroliše i ne podržava, a njihova dostupnost i sadržaj se mogu promeniti u svakom trenutku.\n\nListe stanica se ažuriraju iz repozitorijuma projekta na GitHub-u. Ne koristi aplikaciju za nezakonite radnje.';
}
