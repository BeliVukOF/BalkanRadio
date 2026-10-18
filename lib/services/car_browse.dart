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

MediaItem carStationItem(RadioStation station) => MediaItem(
      id: station.streamUrl,
      title: station.name,
      album: station.region,
      artist: 'Balkan Radio',
      playable: true,
    );

String _title(String region) => region[0].toUpperCase() + region.substring(1);
