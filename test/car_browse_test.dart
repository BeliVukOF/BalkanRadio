import 'package:balkan_radio/models/radio_station.dart';
import 'package:balkan_radio/services/car_browse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stations = [
    RadioStation(name: 'Belgrade 1', streamUrl: 'https://a/1', region: 'Serbia'),
    RadioStation(name: 'Art FM', streamUrl: 'https://a/2', region: 'Greece'),
    RadioStation(name: 'Kiss FM', streamUrl: 'https://a/3', region: 'Serbia'),
  ];

  test('car root lists only regions that actually have stations', () {
    final root = carBrowseChildren(carRootId, stations);
    // Order follows StationManager.regions, not the station list.
    expect(root.map((item) => item.id), ['region:greece', 'region:serbia']);
    expect(root.every((item) => item.playable == false), isTrue);
    expect(root.last.title, 'Serbia');
  });

  test('car region folder holds its stations, playable and addressable', () {
    final children = carBrowseChildren('region:serbia', stations);
    expect(children.map((item) => item.title), ['Belgrade 1', 'Kiss FM']);
    expect(children.every((item) => item.playable == true), isTrue);
    // id is the stream url, which is what playFromMediaId matches on.
    expect(children.first.id, 'https://a/1');
  });

  test('car browse returns nothing for unknown or empty parents', () {
    expect(carBrowseChildren('nope', stations), isEmpty);
    expect(carBrowseChildren('region:albania', stations), isEmpty);
    expect(carBrowseChildren(carRootId, const []), isEmpty);
  });
}
