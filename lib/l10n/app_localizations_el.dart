// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appName => 'Balkan Radio';

  @override
  String get navHeaderSubtitle => 'Ραδιοφωνικοί Σταθμοί Ex-Yu';

  @override
  String get actionSettings => 'Ρυθμίσεις';

  @override
  String get menuAllRegions => 'Όλες οι περιοχές';

  @override
  String get menuFavorites => 'Αγαπημένα';

  @override
  String get menuAlbania => 'Αλβανία';

  @override
  String get menuBosnia => 'Βοσνία-Ερζεγοβίνη';

  @override
  String get menuBulgaria => 'Βουλγαρία';

  @override
  String get menuCroatia => 'Κροατία';

  @override
  String get menuGreece => 'Ελλάδα';

  @override
  String get menuMacedonia => 'Μακεδονία';

  @override
  String get menuMontenegro => 'Μαυροβούνιο';

  @override
  String get menuSerbia => 'Σερβία';

  @override
  String get nowPlayingDefault => 'Δεν αναπαράγεται τίποτα';

  @override
  String get contentDescriptionPlay => 'Αναπαραγωγή';

  @override
  String get contentDescriptionPause => 'Παύση';

  @override
  String get contentDescriptionStop => 'Διακοπή';

  @override
  String get contentDescriptionBack => 'Πίσω';

  @override
  String get titleSettings => 'Ρυθμίσεις';

  @override
  String get titleEnabledRegions => 'Ενεργοποιημένες περιοχές';

  @override
  String get titlePerformance => 'Απόδοση';

  @override
  String get labelPowerSaving => 'Εξοικονόμηση μπαταρίας';

  @override
  String get descPowerSaving =>
      'Σταματά το περιστρεφόμενο εικονίδιο όσο παίζει ο σταθμός.';

  @override
  String get titleLanguage => 'Γλώσσα';

  @override
  String get labelSelectLanguage => 'Επιλογή γλώσσας εφαρμογής';

  @override
  String get langAlbanian => 'Αλβανικά';

  @override
  String get langBosnian => 'Βοσνιακά';

  @override
  String get langBulgarian => 'Βουλγαρικά';

  @override
  String get langCroatian => 'Κροατικά';

  @override
  String get langGreek => 'Ελληνικά';

  @override
  String get langMacedonian => 'Μακεδονικά';

  @override
  String get langMontenegrin => 'Μαυροβουνιακά';

  @override
  String get langSerbian => 'Σερβικά';

  @override
  String get langEnglish => 'Αγγλικά';

  @override
  String get titleChooseRegion => 'Επιλέξτε περιοχή';

  @override
  String get titleContent => 'Περιεχόμενο';

  @override
  String get labelRefreshStations => 'Έλεγχος για νέους σταθμούς';

  @override
  String get descRefreshStations =>
      'Ενημερώνει τη λίστα των ραδιοφωνικών σταθμών από τον διακομιστή.';

  @override
  String msgStationsUpdated(int count) {
    return 'Η λίστα σταθμών ενημερώθηκε! Σύνολο: $count';
  }

  @override
  String get msgStationsUpdateFailed =>
      'Αποτυχία ενημέρωσης σταθμών. Παρακαλώ δοκιμάστε ξανά αργότερα.';

  @override
  String get titleAppearance => 'Εμφάνιση';

  @override
  String get labelTheme => 'Θέμα';

  @override
  String get themeSystem => 'Σύστημα';

  @override
  String get themeLight => 'Φωτεινό';

  @override
  String get themeDark => 'Σκοτεινό';

  @override
  String get languageSystem => 'Γλώσσα συστήματος';

  @override
  String get searchHint => 'Αναζήτηση σταθμών ή περιοχών';

  @override
  String get noStationsFound => 'Δεν βρέθηκαν σταθμοί';

  @override
  String get favoritesEmpty =>
      'Δεν υπάρχουν αγαπημένα ακόμη. Πατήστε το αστέρι δίπλα σε έναν σταθμό για να τον προσθέσετε.';

  @override
  String get msgKeepOneRegion =>
      'Τουλάχιστον μία περιοχή πρέπει να παραμείνει ενεργή.';

  @override
  String get msgPlayError => 'Δεν ήταν δυνατή η αναπαραγωγή αυτού του σταθμού.';

  @override
  String get titleAllStations => 'Όλοι οι σταθμοί';

  @override
  String get contentDescriptionClear => 'Καθαρισμός';

  @override
  String get contentDescriptionFavorite => 'Προσθήκη στα αγαπημένα';

  @override
  String get contentDescriptionUnfavorite => 'Αφαίρεση από τα αγαπημένα';

  @override
  String get titleLegal => 'Νομικά';

  @override
  String get privacyPolicy => 'Πολιτική απορρήτου';

  @override
  String get termsOfService => 'Όροι χρήσης';

  @override
  String get titleAbout => 'Σχετικά';

  @override
  String aboutVersion(String version) {
    return 'Έκδοση $version';
  }

  @override
  String get privacyBody =>
      'Το Balkan Radio δεν συλλέγει, δεν αποθηκεύει και δεν κοινοποιεί προσωπικά δεδομένα. Δεν υπάρχει λογαριασμός, παρακολούθηση, αναλυτικά στοιχεία ή διαφημίσεις.\n\nΤα αγαπημένα, οι ενεργές περιοχές, το θέμα και η γλώσσα αποθηκεύονται μόνο σε αυτή τη συσκευή.\n\nΟι λίστες σταθμών και οι ροές ήχου λαμβάνονται απευθείας από διακομιστές τρίτων. Όπως σε κάθε αίτημα στο διαδίκτυο, οι διακομιστές αυτοί μπορούν να δουν τη διεύθυνση IP σας.';

  @override
  String get termsBody =>
      'Η εφαρμογή είναι δωρεάν και παρέχεται ως έχει, χωρίς καμία εγγύηση.\n\nΌλοι οι σταθμοί είναι δημόσιες ροές στο διαδίκτυο που ανήκουν σε τρίτους. Η εφαρμογή δεν τους φιλοξενεί, δεν τους ελέγχει και δεν τους υποστηρίζει, και η διαθεσιμότητα ή το περιεχόμενό τους μπορεί να αλλάξει ανά πάσα στιγμή.\n\nΟι λίστες σταθμών ενημερώνονται από το αποθετήριο του έργου στο GitHub. Μην χρησιμοποιείτε την εφαρμογή για παράνομες ενέργειες.';

  @override
  String get msgStorageError =>
      'Δεν ήταν δυνατή η αποθήκευση της ρύθμισης. Δοκιμάστε ξανά.';

  @override
  String get msgPlaybackInterrupted => 'Η ροή διακόπηκε.';
}
