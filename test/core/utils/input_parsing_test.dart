import 'package:app_muscu/core/utils/input_parsing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseDecimal accepte la virgule ou le point', () {
    expect(parseDecimal('82,5'), 82.5);
    expect(parseDecimal('82.5'), 82.5);
    expect(parseDecimal(' 100 '), 100);
    expect(parseDecimal(''), isNull);
    expect(parseDecimal('abc'), isNull);
    expect(parseDecimal('-5'), isNull);
  });

  test('parseInteger', () {
    expect(parseInteger('8'), 8);
    expect(parseInteger(''), isNull);
    expect(parseInteger('8,5'), isNull);
  });

  test('parseDuration accepte « m:ss » ou des secondes', () {
    expect(parseDuration('1:30'), 90);
    expect(parseDuration('0:45'), 45);
    expect(parseDuration('45'), 45);
    expect(parseDuration('1:75'), isNull);
    expect(parseDuration('1:2:3'), isNull);
    expect(parseDuration(''), isNull);
  });
}
