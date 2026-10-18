import 'package:balkan_radio/ui/bold/bold_now_playing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('next/previous walk the list and wrap around', () {
    expect(stepStationIndex(0, 1, 5), 1);
    expect(stepStationIndex(4, 1, 5), 0);
    expect(stepStationIndex(0, -1, 5), 4);
    expect(stepStationIndex(-1, 1, 5), 1);
    expect(stepStationIndex(-1, -1, 5), 4);
  });

  test('empty list has no index', () {
    expect(stepStationIndex(0, 1, 0), -1);
  });
}
