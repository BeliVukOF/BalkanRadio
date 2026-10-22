# Balkan Radio

Android radio streaming app for the Balkans — **68 stations, 8 regions**, no ads, no accounts, no tracking.

Built with Flutter 3.47 / Dart 3.13, Material 3.

> **AI note:** this app was written in pair-programming with an AI assistant (Hermes Agent).
> Architecture, UI and every line of Dart/Kotlin in this repository were produced with AI help and
> then built, installed and verified on a real Android 16 device.

## Features

- **Streaming** — 68 public radio streams across Albania, Bosnia, Bulgaria, Croatia, Greece, Macedonia, Montenegro and Serbia
- **Background playback** — foreground media service with notification controls (`audio_service` + `just_audio`)
- **Favorites** — pinned to the top of every list, alphabetical inside each group
- **Search** — by station name or region
- **Light / dark / system theme**, plus 9 UI languages that follow the system by default
- **Offline cache** — the station list is cached, the UI opens instantly and works without network
- **Accessibility** — every control has a semantic label, contrast is unit-tested (≥ 4.5:1 in both themes)
- **Honest errors** — a dead or blocked stream shows a message instead of spinning forever

## Languages

English (source), Serbian, Bosnian, Croatian, Montenegrin, Macedonian, Albanian, Bulgarian, Greek.
Translations live in `lib/l10n/app_<code>.arb`; the app code stays English and every string is looked up
through `AppLocalizations`.

## Station data (over-the-air update)

The station catalogue lives in [`stations/`](stations) as one JSON file per region:

```json
[
  { "name": "Art FM", "streamUrl": "https://i2.streams.ovh:2200/ssl/artfm?mp=/stream", "region": "Greece" }
]
```

The app fetches these files from `raw.githubusercontent.com/BeliVukOF/BalkanRadio/main/stations/<region>.json`
on start (and from **Settings → Check for new stations**). To add, remove or replace a station:

1. edit the matching `stations/<region>.json`
2. commit and push to `main`
3. the app picks it up on the next launch — **no new APK needed**

Both `http://` and `https://` streams are supported (cleartext is enabled for the legacy shoutcast servers).

## Build

```sh
flutter pub get
flutter run                    # debug on a connected device
flutter build apk --release    # ~60 MB universal APK
```

Requirements: Flutter 3.47+, Android SDK 36, JDK 17. `minSdk` is 24 (Android 7), `targetSdk` 36 (Android 16),
with `arm64-v8a`, `armeabi-v7a` and `x86_64` native libraries.

**Release builds keep R8 disabled on purpose** (`android/app/build.gradle.kts`): minification strips the
Pigeon bridge that `shared_preferences` looks up at runtime, which silently kills every setting.

## Project structure

```
lib/
  main.dart                 app shell: theme mode + locale driven by the provider
  l10n/                     .arb files + generated AppLocalizations
  models/radio_station.dart
  data/
    station_manager.dart    network fetch + offline cache
    station_repository.dart bundled fallback list
    region_preferences.dart all persisted user settings
  providers/radio_provider.dart   playback state, filters, sorting, prefs
  services/audio_handler.dart     AudioService + just_audio bridge
  ui/
    screens/                home, station list, now playing, settings, legal
    widgets/                station avatar, gradient play button, mini player
    theme/app_theme.dart    one seed colour, explicit light/dark surfaces
```

## Privacy

No account, no analytics, no ads, no third-party SDKs. Favorites, theme and language are stored on the device
only. Streams are fetched directly from the broadcasters, who can see your IP address like any other web request.
The full privacy policy and terms of service are inside the app (Settings → Legal), in all 9 languages.

## License

No license file yet — the code is public for reading and building, all rights reserved by the author.
protection test 1792705644
