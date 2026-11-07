import 'package:audio_service/audio_service.dart';

import '../data/station_manager.dart';
import '../models/radio_station.dart';

/// Root id the Android Auto client is given by audio_service (hardcoded
/// in its Java layer as "root").
const String carRootId = 'root';

const String _regionPrefix = 'region:';

/// Browse tree for Android Auto: root -> region folders -> playable stations.
///
/// Pure function, so the tree can be tested without a platform audio player.
List<MediaItem> carBrowseChildren(
  String parentMediaId,
  List<RadioStation> stations,
) {
  if (parentMediaId == carRootId) {
    final present = {for (final s in stations) s.region.toLowerCase()};
    return [
      for (final region in StationManager.regions)
        if (present.contains(region))
          MediaItem(
            id: '$_regionPrefix$region',
            title: _title(region),
            playable: false,
          ),
    ];
  }
  if (parentMediaId.startsWith(_regionPrefix)) {
    final region = parentMediaId.substring(_regionPrefix.length);
    return [
      for (final station in stations)
        if (station.region.toLowerCase() == region) carStationItem(station),
    ];
  }
  return const [];
}

/// The app name, shown when a station publishes no song title.
const String appDisplayName = 'Balkan Radio';

/// The media item for a station.
///
/// The song title goes into `title`: that is the big line the system media
/// panel draws in the notification and on the lock screen, and it is the line
/// that scrolls when the text does not fit (the same slot every music app
/// uses for the song). The station name moves to `artist`, and the region
/// stays in `album`, the third line on the lock screen.
///
/// A station that publishes no song keeps the station name in `title` and
/// the app name in `artist`, so "Balkan Radio" is still visible.
MediaItem carStationItem(RadioStation station, {String? nowPlaying}) {
  final song = (nowPlaying == null || nowPlaying.isEmpty) ? null : nowPlaying;
  return MediaItem(
    id: station.streamUrl,
    title: song ?? station.name,
    // The lock screen media panel prefers DISPLAY_TITLE over TITLE for the
    // song line, so the same song goes into both.
    displayTitle: song ?? station.name,
    album: station.region,
    artist: song == null ? appDisplayName : station.name,
    playable: true,
  );
}

String _title(String region) => region[0].toUpperCase() + region.substring(1);
