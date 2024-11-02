import 'package:clearassistapp/src/database/model/media.dart';
import 'package:clearassistapp/src/database/model/media_type.dart';
import 'package:clearassistapp/src/database/model/photo.dart';
import 'package:clearassistapp/src/database/repository/photo_repository.dart';
import 'package:clearassistapp/src/utils/directory_manager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:clearassistapp/src/address.dart';
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
  const String photoFileName = 'test_photo.jpg';

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    DirectoryManager.instance.initializeDirectories();
  });

  group('Photo', () {
    // Photo constructor tests:

    test(
        'U-5-1: Photo constructor (with all parameters provided) should create a Photo object and initialize values correctly',
        () {
      final Photo photo = Photo(
        id: id,
        title: title,
        description: description,
        tags: tags,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        photoFileName: photoFileName,
      );

      expect(photo.id, id);
      expect(photo.mediaType, MediaType.photo);
      expect(photo.title, title);
      expect(photo.description, description);
      expect(photo.tags, tags);
      expect(photo.timestamp, timestamp);
      expect(photo.physicalAddress, physicalAddress);
      expect(photo.storageSize, storageSize);
      expect(photo.isFavorited, isFavorited);
      expect(photo.photoFileName, photoFileName);
      // TODO: Add check for photo.photo (ensure that the photo is loaded)
    });

    test(
        'U-5-2: Photo constructor (with only required parameters provided) should create a Photo object and initialize values correctly',
        () {
      final Photo photo = Photo(
        id: id,
        title: title,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        photoFileName: photoFileName,
      );

      expect(photo.id, id);
      expect(photo.mediaType, MediaType.photo);
      expect(photo.title, title);
      expect(photo.description, isNull);
      expect(photo.tags, isNull);
      expect(photo.timestamp, timestamp);
      expect(photo.physicalAddress, physicalAddress);
      expect(photo.storageSize, storageSize);
      expect(photo.isFavorited, isFavorited);
      expect(photo.photoFileName, photoFileName);
      // TODO: Add check for photo.photo (ensure that the photo is loaded)
    });

    // Photo.fromJson() tests:

    test(
        'U-5-3: Photo.fromJson should correctly create a Photo object from JSON (with all field values)',
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
        PhotoFields.photoFileName: photoFileName,
      };

      final Photo photo = Photo.fromJson(json);

      expect(photo.id, id);
      expect(photo.mediaType, MediaType.photo);
      expect(photo.title, title);
      expect(photo.description, description);
      expect(photo.tags, tags);
      expect(
          photo.timestamp,
          DateTime.fromMillisecondsSinceEpoch(
              timestamp.toUtc().millisecondsSinceEpoch,
              isUtc: true));
      expect(photo.physicalAddress, physicalAddress);
      expect(photo.storageSize, storageSize);
      expect(photo.isFavorited, isFavorited);
      expect(photo.photoFileName, photoFileName);
      // TODO: Add check for photo.photo (ensure that the photo is loaded)
    });

    test(
      'U-5-4: Photo.fromJson should correctly create a Photo object from JSON (with non-nullable field values only)',
      () {
        final Map<String, Object?> json = {
          MediaFields.id: id,
          MediaFields.title: title,
          MediaFields.timestamp: timestamp.toUtc().millisecondsSinceEpoch,
          MediaFields.physicalAddress: physicalAddress,
          MediaFields.storageSize: storageSize,
          MediaFields.isFavorited: 1,
          PhotoFields.photoFileName: photoFileName,
        };

        final Photo photo = Photo.fromJson(json);

        expect(photo.id, id);
        expect(photo.mediaType, MediaType.photo);
        expect(photo.title, title);
        expect(photo.description, isNull);
        expect(photo.tags, isNull);
        expect(
            photo.timestamp,
            DateTime.fromMillisecondsSinceEpoch(
                timestamp.toUtc().millisecondsSinceEpoch,
                isUtc: true));
        expect(photo.physicalAddress, physicalAddress);
        expect(photo.storageSize, storageSize);
        expect(photo.isFavorited, isFavorited);
        expect(photo.photoFileName, photoFileName);
        // TODO: Add check for photo.photo (ensure that the photo is loaded)
      },
    );

    test(
      'U-5-5: Photo.fromJson should throw a FormatException when given invalid JSON',
      () {
        final Map<String, Object?> json = {};

        expect(() => Photo.fromJson(json), throwsA(isA<FormatException>()));
      },
    );
  });

  // Photo.toJson() tests:

  test(
    'U-5-6: Photo.toJson should correctly serialize a Photo object (with all field values) to JSON',
    () {
      final Photo photo = Photo(
        id: id,
        title: title,
        description: description,
        tags: tags,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        photoFileName: photoFileName,
      );

      final Map<String, Object?> json = photo.toJson();

      expect(json, {
        MediaFields.id: id,
        MediaFields.title: title,
        MediaFields.description: description,
        MediaFields.tags: tags.join(','),
        MediaFields.timestamp: timestamp.toUtc().millisecondsSinceEpoch,
        MediaFields.physicalAddress: physicalAddress,
        MediaFields.storageSize: storageSize,
        MediaFields.isFavorited: 1,
        PhotoFields.photoFileName: photoFileName,
      });
    },
  );

  test(
    'U-5-7: Photo.toJson should correctly serialize a Photo object (with non-nullable field values only) to JSON',
    () {
      final Photo photo = Photo(
        id: id,
        title: title,
        timestamp: timestamp,
        physicalAddress: physicalAddress,
        storageSize: storageSize,
        isFavorited: isFavorited,
        photoFileName: photoFileName,
      );

      final Map<String, Object?> json = photo.toJson();

      expect(json, {
        MediaFields.id: id,
        MediaFields.title: title,
        MediaFields.description: null,
        MediaFields.tags: null,
        MediaFields.timestamp: timestamp.toUtc().millisecondsSinceEpoch,
        MediaFields.physicalAddress: physicalAddress,
        MediaFields.storageSize: storageSize,
        MediaFields.isFavorited: 1,
        PhotoFields.photoFileName: photoFileName,
      });
    },
  );
}
