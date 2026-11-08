# Balkan Radio

Android radio streaming app for the Balkans — **73 stations, 8 regions**, no ads, no accounts, no tracking.

Built with Flutter 3.47 / Dart 3.13, Material 3.

> **AI note:** this app was written in pair-programming with an AI assistant (Hermes Agent).
> Architecture, UI and every line of Dart/Kotlin in this repository were produced with AI help and
> then built, installed and verified on a real Android 16 device.

## Features

- **Streaming** — 73 public radio streams across Albania, Bosnia, Bulgaria, Croatia, Greece, Macedonia, Montenegro and Serbia
- **Background playback** — foreground media service with notification controls (`audio_service` + `just_audio`)
- **Song names** — the current track is shown when the station publishes one (7 stations today: Play, Melodia FM, RadioBoss, My Music Radio, Top Albanian Radio, Otvoreni Live, Otvoreni Chill)
- **Scrolling title** — a long song name scrolls like a news ticker in the mini player; in the media notification it goes into the title slot, which is the row Android scrolls
- **Favorites** — pinned to the top of every list, alphabetical inside each group
- **Search** — by station name or region, in the language of the interface
- **Sleep timer** — 5 to 90 minutes, with an option to close the app when it runs out
- **In-app update** — checks `version.json` on the repository and hands the downloaded APK to the system installer
- **Four designs** — Classic, Modern, Cyberpunk and Abstract, each with a light and a dark palette
- **Light / dark / system theme**, plus 9 UI languages that follow the system by default
- **Offline cache** — the station list is cached and bundled as a fallback, so the UI opens instantly and works without network
- **Android Auto** — the station tree is browsable from the car (regions → stations)
- **Landscape** — the station list and the full player reflow for a short viewport
- **Accessibility** — every control has a semantic label, contrast is unit-tested (≥ 4.5:1 in both themes)
- **Honest errors** — a dead or blocked stream shows a message instead of spinning forever

## Languages

English (source), Serbian, Bosnian, Croatian, Montenegrin, Macedonian, Albanian, Bulgarian, Greek.
Translations live in `lib/l10n/app_<code>.arb`; the app code stays English and every string is looked up
through `AppLocalizations`. Serbian resolves to `sr_Latn` so the Latin script matches the strings.

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

| Region | Stations |
|---|---|
| Serbia | 20 |
| Greece | 16 |
| Macedonia | 11 |
| Croatia | 10 |
| Montenegro | 6 |
| Albania | 4 |
| Bosnia and Herzegovina | 4 |
| Bulgaria | 2 |

`lib/data/station_repository.dart` holds the same 73 stations as the offline fallback. It mirrors
`stations/*.json`, so when you add a station there, add it here too.

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

The release build is signed with the debug key — it is meant to be sideloaded, not published in a store.
Replace `signingConfig` before distributing it anywhere else.

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
  services/
    audio_handler.dart      AudioService + just_audio bridge
    now_playing_service.dart     song names from the stations' own endpoints
    car_browse.dart         Android Auto browse tree
    update_service.dart     checks version.json and downloads the new APK
  ui/
    bold/                   the four designs: home, player, theme, widgets
    screens/                settings, legal pages, update dialog
stations/                   one JSON file per region, the source of truth
privacy.html                public privacy policy
terms.html                  public terms of use
release.sh                  bump → analyze → test → build → publish
```

## Tests

```sh
flutter analyze
flutter test
```

73 tests across 10 files: the theme contrast, the search focus behaviour, the responsive layout,
the mini player, the notification metadata, the Android Auto tree and the update flow.

## Privacy

No account, no analytics, no ads, no third-party SDKs. Favorites, theme and language are stored on the device
only. Streams are fetched directly from the broadcasters, who can see your IP address like any other web request.
The full privacy policy and terms of service are inside the app (Settings → Legal), in all 9 languages, and as
[`privacy.html`](privacy.html) and [`terms.html`](terms.html) in this repository.

## Releases

APKs are published on the [releases page](https://github.com/BeliVukOF/BalkanRadio/releases). The last one is
**1.3.21** (version code 35).

`./release.sh` does the whole flow: it bumps the version, runs the analyzer and the tests, builds the release
APK, updates `version.json` with the new size and checksum, commits, pushes, creates the GitHub release and
verifies the uploaded file. `--dry-run` stops before the commit.

## License

MIT — see [`LICENSE`](LICENSE).
