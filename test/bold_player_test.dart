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

  test('sleep countdown prints mm:ss below an hour and h mm above', () {
    expect(formatSleepRemaining(const Duration(minutes: 4, seconds: 7)), '4:07');
    expect(formatSleepRemaining(const Duration(minutes: 59, seconds: 59)), '59:59');
    expect(formatSleepRemaining(const Duration(hours: 1, minutes: 5)), '1h 05m');
    expect(formatSleepRemaining(Duration.zero), '0:00');
  });

  test('empty list has no index', () {
    expect(stepStationIndex(0, 1, 0), -1);
  });
}
