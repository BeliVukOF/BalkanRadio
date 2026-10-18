// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Macedonian (`mk`).
class AppLocalizationsMk extends AppLocalizations {
  AppLocalizationsMk([String locale = 'mk']) : super(locale);

  @override
  String get appName => 'Balkan Radio';

  @override
  String get navigationDrawerOpen => 'Отвори мени';

  @override
  String get navigationDrawerClose => 'Затвори мени';

  @override
  String get navHeaderTitle => 'Balkan Radio';

  @override
  String get navHeaderSubtitle => 'Ex-Yu Радио Станици';

  @override
  String get navHeaderDesc => 'Заглавие на менито';

  @override
  String get actionSettings => 'Поставки';

  @override
  String get menuAllRegions => 'Сите региони';

  @override
  String get menuFavorites => 'Омилени станици';

  @override
  String get menuAlbania => 'Албанија';

  @override
  String get menuBosnia => 'БиХ';

  @override
  String get menuBulgaria => 'Бугарија';

  @override
  String get menuCroatia => 'Хрватска';

  @override
  String get menuGreece => 'Грција';

  @override
  String get menuMacedonia => 'Македонија';

  @override
  String get menuMontenegro => 'Црна Гора';

  @override
  String get menuSerbia => 'Србија';

  @override
  String get menuSettings => 'Поставки';

  @override
  String get nowPlayingDefault => 'Ништо не се репродуцира';

  @override
  String get contentDescriptionPlay => 'Пушти';

  @override
  String get contentDescriptionPause => 'Паузирај';

  @override
  String get contentDescriptionStop => 'Стопирај';

  @override
  String get contentDescriptionBack => 'Назад';

  @override
  String get titleSettings => 'Поставки';

  @override
  String get titleEnabledRegions => 'Овозможени региони';

  @override
  String get titlePerformance => 'Перформанси';

  @override
  String get labelPowerSaving => 'Штедење батерија';

  @override
  String get descPowerSaving =>
      'Ја исклучува анимацијата на ротирање на иконата додека свири станицата.';

  @override
  String get titleLanguage => 'Јазик';

  @override
  String get labelSelectLanguage => 'Избери јазик на апликацијата';

  @override
  String get langAlbanian => 'Албански';

  @override
  String get langBosnian => 'Босански';

  @override
  String get langBulgarian => 'Бугарски';

  @override
  String get langCroatian => 'Хрватски';

  @override
  String get langGreek => 'Грчки';

  @override
  String get langMacedonian => 'Македонски';

  @override
  String get langMontenegrin => 'Црногорски';

  @override
  String get langSerbian => 'Српски';

  @override
  String get langEnglish => 'Англиски';

  @override
  String get titleChooseRegion => 'Избери регион';

  @override
  String get labelAlbania => 'Албанија';

  @override
  String get labelBosnia => 'БиХ';

  @override
  String get labelBulgaria => 'Бугарија';

  @override
  String get labelCroatia => 'Хрватска';

  @override
  String get labelGreece => 'Грција';

  @override
  String get labelMacedonia => 'Македонија';

  @override
  String get labelMontenegro => 'Црна Гора';

  @override
  String get labelSerbia => 'Србија';

  @override
  String get labelAllRegions => 'Сите региони';

  @override
  String get titleContent => 'Содржина';

  @override
  String get labelRefreshStations => 'Провери за нови станици';

  @override
  String get descRefreshStations =>
      'Ја ажурира листата на радио станици од серверот.';

  @override
  String msgStationsUpdated(int count) {
    return 'Листата на станици е ажурирана! Вкупно: $count';
  }

  @override
  String get msgStationsUpdateFailed =>
      'Неуспешно ажурирање на станиците. Ве молиме обидете се подоцна.';

  @override
  String get titleAppearance => 'Изглед';

  @override
  String get labelTheme => 'Тема';

  @override
  String get themeSystem => 'Систем';

  @override
  String get themeLight => 'Светла';

  @override
  String get themeDark => 'Темна';

  @override
  String get languageSystem => 'Јазик на системот';

  @override
  String get searchHint => 'Пребарај станици или региони';

  @override
  String get noStationsFound => 'Не се пронајдени станици';

  @override
  String get favoritesEmpty =>
      'Сè уште нема омилени. Допрете ѕвездичката кај станицата за да ја додадете.';

  @override
  String get msgKeepOneRegion => 'Мора да остане овозможен барем еден регион.';

  @override
  String get msgPlayError => 'Не може да се пушти оваа станица.';

  @override
  String get titleAllStations => 'Сите станици';

  @override
  String get contentDescriptionClear => 'Исчисти';

  @override
  String get contentDescriptionFavorite => 'Додај во омилени';

  @override
  String get contentDescriptionUnfavorite => 'Отстрани од омилени';

  @override
  String get titleLegal => 'Правно';

  @override
  String get privacyPolicy => 'Политика за приватност';

  @override
  String get termsOfService => 'Услови за користење';

  @override
  String get titleAbout => 'За апликацијата';

  @override
  String aboutVersion(String version) {
    return 'Верзија $version';
  }

  @override
  String get privacyBody =>
      'Balkan Radio не собира, не чува и не споделува никакви лични податоци. Нема сметка, нема следење, нема аналитика и нема рекламирање.\n\nОмилени станици, овозможени региони, тема и јазик се чуваат само на овој уред.\n\nЛистите на станици и аудио стримовите се преземаат директно од сервери на трети страни. Како и кај секое интернет барање, тие сервери можат да ја видат вашата IP адреса.';

  @override
  String get termsBody =>
      'Апликацијата е бесплатна и се нуди таква каква што е, без каква било гаранција.\n\nСите станици се јавни интернет стримови во сопственост на трети страни. Апликацијата не ги хостира, не ги контролира и не ги поддржува, а нивната достапност и содржина може да се променат во секое време.\n\nЛистите на станици се ажурираат од репозиториумот на проектот на GitHub. Не користете ја апликацијата за незаконски дејствија.';
}
