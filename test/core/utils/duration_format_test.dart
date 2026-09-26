import 'package:app_muscu/core/utils/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatDuration affiche m:ss, et h:mm:ss au-delà d’une heure', () {
    expect(formatDuration(0), '0:00');
    expect(formatDuration(45), '0:45');
    expect(formatDuration(90), '1:30');
    expect(formatDuration(600), '10:00');
    expect(formatDuration(3725), '1:02:05');
  });
}
