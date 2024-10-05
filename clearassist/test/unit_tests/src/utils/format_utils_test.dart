import 'package:clearassistapp/src/utils/format_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testDateTime = DateTime.parse('2023-10-05 00:00:00Z');
  test('U-17-1: testing getStorageSizeString KB', () {
    //KB
    expect(FormatUtils.getStorageSizeString(1024), '1.00 KB');
  });

  test('U-17-2: testing getStorageSizeString Bytes', () {
    //Bytes
    expect(FormatUtils.getStorageSizeString(512), '512.00 Bytes');
  });

  test('U-17-3: testing getStorageSizeString MB', () {
    //MB
    expect(FormatUtils.getStorageSizeString(10000000), '9.54 MB');
  });

  test('U-17-4: testing getStorageSizeString GB', () {
    //GB
    expect(FormatUtils.getStorageSizeString(10000000000), '9.31 GB');
  });

  test('U-17-5: testing getDateTimeString valid DateTime', () {
    //regular datetime
    expect(FormatUtils.getDateTimeString(testDateTime), '2023-10-05 00:00:00');
  });

  test('U-17-6: testing getDateTimeString null DateTime', () {
    //null
    expect(FormatUtils.getDateTimeString(null), 'Date Unknown');
  });

  test('U-17-7: testing getDateString, valid Date', () {
    //regular datetime
    expect(
        FormatUtils.getDateString(testDateTime), 'October 5th, 2023 12:00 AM');
  });

  test('U-17-8: testing getDateString, null date', () {
    //null
    expect(FormatUtils.getDateString(null), 'N/A');
  });

  test('U-17-9: testing calculateDifference, using today as day', () {
    //null
    expect(FormatUtils.calculateDifference(DateTime.now()), 0);
  });
}
