import 'package:cogniopenapp/src/database/model/media.dart';
import 'package:cogniopenapp/src/database/model/media_type.dart';
import 'package:cogniopenapp/src/database/model/video.dart';
import 'package:cogniopenapp/src/database/repository/video_repository.dart';
import 'package:cogniopenapp/src/utils/directory_manager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cogniopenapp/src/address.dart';
import '../../../../resources/mocks/address_mock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../../resources/fake_path_provider_platform.dart';

Future<void> main() async {
  const int id = 1;
  const String title = 'Test Title';
  const String description = 'Test Description';
  const List<String> tags = ['Tag1', 'Tag2'];
  final DateTime timestamp = DateTime.now();
  GeolocatorPlatform.instance = MockGeolocatorPlatform();
  GeocodingPlatform.instance = MockGeocodingPlatform();
  String physicalAddress = '';
  await Address.whereIAm(isTesting: true).then((String address) {
    physicalAddress = address;
  });
  const int storageSize = 1000;
  const bool isFavorited = true;
  const String videoFileName = 'test_video.mp4';
  const String thumbnailFileName = 'test_thumbnail.jpg';
  const String duration = '00:02:30';

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    DirectoryManager.instance.initializeDirectories();
  });

  group('Video', () {
    // Video constructor tests:

    test(
        'U-9-1: Video constructor (with all parameters provided) should create a Video object and initialize values correctly',
        () {
      final Video video = Video(
        id: id,
        title: title,
        description: description,
        tags: tags,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        videoFileName: videoFileName,
        thumbnailFileName: thumbnailFileName,
        duration: duration,
      );

      expect(video.id, id);
      expect(video.mediaType, MediaType.video);
      expect(video.title, title);
      expect(video.description, description);
      expect(video.tags, tags);
      expect(video.timestamp, timestamp);
      expect(video.physicalAddress, physicalAddress);
      expect(video.storageSize, storageSize);
      expect(video.isFavorited, isFavorited);
      expect(video.videoFileName, videoFileName);
      expect(video.thumbnailFileName, thumbnailFileName);
      expect(video.duration, duration);
    });

    test(
        'U-9-2: Video constructor (with only required parameters provided) should create a Video object and initialize values correctly',
        () {
      final Video video = Video(
        id: id,
        title: title,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        videoFileName: videoFileName,
        duration: duration,
      );

      expect(video.id, id);
      expect(video.mediaType, MediaType.video);
      expect(video.title, title);
      expect(video.description, isNull);
      expect(video.tags, isNull);
      expect(video.timestamp, timestamp);
      expect(video.physicalAddress, physicalAddress);
      expect(video.storageSize, storageSize);
      expect(video.isFavorited, isFavorited);
      expect(video.videoFileName, videoFileName);
      expect(video.thumbnailFileName, isNull);
      expect(video.duration, duration);
    });

    // Video.fromJson() tests:

    test(
        'U-9-3: Video.fromJson should correctly create a Video object from JSON (with all field values)',
        () {
      final Map<String, Object?> json = {
        MediaFields.id: id,
        MediaFields.title: title,
        MediaFields.description: description,
        MediaFields.tags: tags.join(','),
        MediaFields.timestamp: timestamp.toUtc().millisecondsSinceEpoch,
        MediaFields.physicalAddress: physicalAddress,
        MediaFields.storageSize: storageSize,
        MediaFields.isFavorited: 1,
        VideoFields.videoFileName: videoFileName,
        VideoFields.thumbnailFileName: thumbnailFileName,
        VideoFields.duration: duration,
      };

      final Video video = Video.fromJson(json);

      expect(video.id, id);
      expect(video.mediaType, MediaType.video);
      expect(video.title, title);
      expect(video.description, description);
      expect(video.tags, tags);
      expect(
          video.timestamp,
          DateTime.fromMillisecondsSinceEpoch(
              timestamp.toUtc().millisecondsSinceEpoch,
              isUtc: true));
      expect(video.physicalAddress, physicalAddress);
      expect(video.storageSize, storageSize);
      expect(video.isFavorited, isFavorited);
      expect(video.videoFileName, videoFileName);
      expect(video.thumbnailFileName, thumbnailFileName);
      expect(video.duration, duration);
    });

    test(
      'U-9-4: Video.fromJson should correctly create a Video object from JSON (with non-nullable field values only)',
      () {
        final Map<String, Object?> json = {
          MediaFields.id: id,
          MediaFields.title: title,
          MediaFields.timestamp: timestamp.toUtc().millisecondsSinceEpoch,
          MediaFields.physicalAddress: physicalAddress,
          MediaFields.storageSize: storageSize,
          MediaFields.isFavorited: 1,
          VideoFields.videoFileName: videoFileName,
          VideoFields.duration: duration,
        };

        final Video video = Video.fromJson(json);

        expect(video.id, id);
        expect(video.mediaType, MediaType.video);
        expect(video.title, title);
        expect(video.description, isNull);
        expect(video.tags, isNull);
        expect(
            video.timestamp,
            DateTime.fromMillisecondsSinceEpoch(
                timestamp.toUtc().millisecondsSinceEpoch,
                isUtc: true));
        expect(video.physicalAddress, physicalAddress);
        expect(video.storageSize, storageSize);
        expect(video.isFavorited, isFavorited);
        expect(video.videoFileName, videoFileName);
        expect(video.thumbnailFileName, isNull);
        expect(video.duration, duration);
      },
    );

    test(
      'U-9-5: Video.fromJson should throw a FormatException when given invalid JSON',
      () {
        final Map<String, Object?> json = {};

        expect(() => Video.fromJson(json), throwsA(isA<FormatException>()));
      },
    );
  });

  // Video.toJson() tests:

  test(
    'U-9-6: Video.toJson should correctly serialize a Video object (with all field values) to JSON',
    () {
      final Video video = Video(
        id: id,
        title: title,
        description: description,
        tags: tags,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        videoFileName: videoFileName,
        thumbnailFileName: thumbnailFileName,
        duration: duration,
      );

      final Map<String, Object?> json = video.toJson();

      expect(json, {
        MediaFields.id: id,
        MediaFields.title: title,
        MediaFields.description: description,
        MediaFields.tags: tags.join(','),
        MediaFields.timestamp: timestamp.toUtc().millisecondsSinceEpoch,
        MediaFields.physicalAddress: physicalAddress,
        MediaFields.storageSize: storageSize,
        MediaFields.isFavorited: 1,
        VideoFields.videoFileName: videoFileName,
        VideoFields.thumbnailFileName: thumbnailFileName,
        VideoFields.duration: duration,
      });
    },
  );

  test(
    'U-9-7: Video.toJson should correctly serialize a Video object (with non-nullable field values only) to JSON',
    () {
      final Video video = Video(
        id: id,
        title: title,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        videoFileName: videoFileName,
        duration: duration,
      );

      final Map<String, Object?> json = video.toJson();

      expect(json, {
        MediaFields.id: id,
        MediaFields.title: title,
        MediaFields.description: null,
        MediaFields.tags: null,
        MediaFields.timestamp: timestamp.toUtc().millisecondsSinceEpoch,
        MediaFields.physicalAddress: physicalAddress,
        MediaFields.storageSize: storageSize,
        MediaFields.isFavorited: 1,
        VideoFields.videoFileName: videoFileName,
        VideoFields.thumbnailFileName: null,
        VideoFields.duration: duration,
      });
    },
  );
}
