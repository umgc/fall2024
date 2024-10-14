import 'package:cogniopenapp/src/database/model/media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaFields', () {
    // MediaFields values tests:

    test('U-4-1: MediaFields.values should contain the correct field names', () {
      expect(MediaFields.values, isA<List<String>>());
      expect(MediaFields.values, hasLength(8));
      expect(MediaFields.values, contains(MediaFields.id));
      expect(MediaFields.values, contains(MediaFields.title));
      expect(MediaFields.values, contains(MediaFields.description));
      expect(MediaFields.values, contains(MediaFields.tags));
      expect(MediaFields.values, contains(MediaFields.timestamp));
      expect(MediaFields.values, contains(MediaFields.physicalAddress));
      expect(MediaFields.values, contains(MediaFields.storageSize));
      expect(MediaFields.values, contains(MediaFields.isFavorited));
    });

    test('U-4-2: MediaFields values should be the correct field names', () {
      expect(MediaFields.id, '_id');
      expect(MediaFields.title, 'title');
      expect(MediaFields.description, 'description');
      expect(MediaFields.tags, 'tags');
      expect(MediaFields.timestamp, 'timestamp');
      expect(MediaFields.physicalAddress, 'physicalAddress');
      expect(MediaFields.storageSize, 'storage_size');
      expect(MediaFields.isFavorited, 'is_favorited');
    });
  });

  // Note that Media is an abstract class and is tested via sub classes: Audio, Photo, and Video
}
