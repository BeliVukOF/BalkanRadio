import '../l10n/app_localizations.dart';

/// Region names in the station data are English; translate them for display.
String regionLabel(AppLocalizations l10n, String region) => switch (region) {
      'Albania' => l10n.menuAlbania,
      'Bosnia' => l10n.menuBosnia,
      'Bulgaria' => l10n.menuBulgaria,
      'Croatia' => l10n.menuCroatia,
      'Greece' => l10n.menuGreece,
      'Macedonia' => l10n.menuMacedonia,
      'Montenegro' => l10n.menuMontenegro,
      'Serbia' => l10n.menuSerbia,
      _ => region,
    };
