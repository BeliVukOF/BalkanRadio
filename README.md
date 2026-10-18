# Balkan Radio (Flutter)

Flutter client for the Balkan Radio station catalogue. Station lists are fetched
from this repository's [`stations/`](stations) folder and cached on the device,
so the app also works offline.

- 8 regions, 68 stations, search, favourites
- Light / dark / system theme, 9 UI languages / system language
- Material 3, accessible labels, no tracking, no ads

## Build

```sh
flutter pub get
flutter run            # debug on a connected device
flutter build apk --release
```

The Android side needs `INTERNET`, `FOREGROUND_SERVICE` and cleartext HTTP,
because part of the public streams is still served over plain HTTP.
