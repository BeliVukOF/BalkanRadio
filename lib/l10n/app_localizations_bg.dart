// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appName => 'Balkan Radio';

  @override
  String get navHeaderSubtitle => 'Ex-Yu Радиостанции';

  @override
  String get actionSettings => 'Настройки';

  @override
  String get menuAllRegions => 'Всички региони';

  @override
  String get menuFavorites => 'Любими станции';

  @override
  String get menuAlbania => 'Албания';

  @override
  String get menuBosnia => 'БиХ';

  @override
  String get menuBulgaria => 'България';

  @override
  String get menuCroatia => 'Хърватия';

  @override
  String get menuGreece => 'Гърция';

  @override
  String get menuMacedonia => 'Македония';

  @override
  String get menuMontenegro => 'Черна гора';

  @override
  String get menuSerbia => 'Сърбия';

  @override
  String get nowPlayingDefault => 'В момента не звучи нищо';

  @override
  String get contentDescriptionPlay => 'Пусни';

  @override
  String get contentDescriptionPause => 'Пауза';

  @override
  String get contentDescriptionStop => 'Спри';

  @override
  String get contentDescriptionBack => 'Назад';

  @override
  String get titleSettings => 'Настройки';

  @override
  String get titleEnabledRegions => 'Активирани региони';

  @override
  String get titlePerformance => 'Производителност';

  @override
  String get labelPowerSaving => 'Режим на пестене на енергия';

  @override
  String get descPowerSaving =>
      'Спира анимацията на въртене на иконата, докато станцията свири.';

  @override
  String get titleLanguage => 'Език';

  @override
  String get labelSelectLanguage => 'Изберете език на приложението';

  @override
  String get langAlbanian => 'Албански';

  @override
  String get langBosnian => 'Босненски';

  @override
  String get langBulgarian => 'Български';

  @override
  String get langCroatian => 'Хърватски';

  @override
  String get langGreek => 'Гръцки';

  @override
  String get langMacedonian => 'Македонски';

  @override
  String get langMontenegrin => 'Черногорски';

  @override
  String get langSerbian => 'Сръбски';

  @override
  String get langEnglish => 'Английски';

  @override
  String get titleChooseRegion => 'Изберете регион';

  @override
  String get titleContent => 'Съдържание';

  @override
  String get labelRefreshStations => 'Проверка за нови станции';

  @override
  String get descRefreshStations =>
      'Актуализира списъка с радиостанции от сървъра.';

  @override
  String msgStationsUpdated(int count) {
    return 'Списъкът със станции е актуализиран! Общо: $count';
  }

  @override
  String get msgStationsUpdateFailed =>
      'Неуспешна актуализация на станциите. Моля, опитайте отново по-късно.';

  @override
  String get titleAppearance => 'Изглед';

  @override
  String get labelTheme => 'Тема';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светла';

  @override
  String get themeDark => 'Тъмна';

  @override
  String get languageSystem => 'Език на системата';

  @override
  String get searchHint => 'Търсене на станции или региони';

  @override
  String get noStationsFound => 'Няма намерени станции';

  @override
  String get favoritesEmpty =>
      'Все още няма любими. Докоснете звездата до станция, за да я добавите.';

  @override
  String get msgKeepOneRegion => 'Поне един регион трябва да остане активиран.';

  @override
  String get msgPlayError => 'Тази станция не може да бъде пусната.';

  @override
  String get titleAllStations => 'Всички станции';

  @override
  String get contentDescriptionClear => 'Изчисти';

  @override
  String get contentDescriptionFavorite => 'Добави в любими';

  @override
  String get contentDescriptionUnfavorite => 'Премахни от любими';

  @override
  String get titleLegal => 'Правно';

  @override
  String get privacyPolicy => 'Политика за поверителност';

  @override
  String get termsOfService => 'Условия за ползване';

  @override
  String get titleAbout => 'Относно';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get privacyBody =>
      'Balkan Radio не събира, не съхранява и не споделя лични данни. Няма профил, няма проследяване, няма аналитика и няма реклами.\n\nЛюбими станции, активирани региони, тема и език се запазват само на това устройство.\n\nСписъците със станции и аудио потоците се изтеглят директно от сървъри на трети страни. Както при всяка интернет заявка, тези сървъри могат да видят вашия IP адрес.';

  @override
  String get termsBody =>
      'Приложението е безплатно и се предоставя във вида, в който е, без каквато и да е гаранция.\n\nВсички станции са публични интернет потоци, собственост на трети страни. Приложението не ги хоства, не ги контролира и не ги подкрепя, а тяхната достъпност и съдържание могат да се променят по всяко време.\n\nСписъците със станции се актуализират от хранилището на проекта в GitHub. Не използвайте приложението за незаконни действия.';

  @override
  String get msgStorageError =>
      'Настройката не може да бъде запазена. Опитайте отново.';

  @override
  String get msgPlaybackInterrupted => 'Потокът е прекъснат.';

  @override
  String get titleDesign => 'Дизайн';

  @override
  String get designClassic => 'Класичен';

  @override
  String get designCyber => 'Cyberpunk';

  @override
  String get designModern => 'Modern';

  @override
  String get labelNowPlaying => 'В момента свири';

  @override
  String get labelSleepTimer => 'Таймер за сън';

  @override
  String get sleepOff => 'Изключи';

  @override
  String get sleepCloseApp => 'Затвори приложението';
}
