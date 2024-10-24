import 'package:clearassistapp/src/utils/directory_manager.dart';
import 'package:clearassistapp/src/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:clearassistapp/src/database/model/audio.dart';
import 'package:clearassistapp/src/database/repository/audio_repository.dart';
import 'package:clearassistapp/src/database/model/photo.dart';
import 'package:clearassistapp/src/database/repository/photo_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import '../../../resources/fake_path_provider_platform.dart';

const unitTestAudioTitle = "Unit Test Audio";
const unitTestPhotoTitle = "Unit Test Photo";
const unitTestVideoTitle = "Unit Test Video";

final unitTestAudio = Audio(
    title: unitTestAudioTitle,
    description: 'Unit Test Audio Description',
    tags: ['almond', 'cashew', 'raisin'],
    timestamp: DateTime(2023, 10, 20, 8, 26),
    physicalAddress: "501 Hungerford Dr, Rockville, Maryland, 20850, US",
    audioFileName: 'unit_test_audio.mp4',
    storageSize: 1000000,
    isFavorited: false,
    summary: "Unit Test Audio Summary");

final unitTestPhoto = Photo(
    title: unitTestPhotoTitle,
    description: 'Unit Test Photo Description',
    tags: ['sun', 'moon', 'star'],
    timestamp: DateTime(2023, 10, 20, 8, 26),
    physicalAddress: "501 Hungerford Dr, Rockville, Maryland, 20850, US",
    photoFileName: 'unit_test_photo.png',
    storageSize: 1000000,
    isFavorited: false);

/// Initialize sqflite for test.
void sqfliteTestInit() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory
  databaseFactory = databaseFactoryFfi;
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteTestInit();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  await DirectoryManager.instance.initializeDirectories();
  final db = await AppDatabase.instance.database;

  group('adding to database (db)', () {
    test('U-13-1: adding audio to db', () async {
      await db.execute(
          "DELETE FROM $tableAudios WHERE title='$unitTestAudioTitle'");
      var audioTableQueryResult = await db.query(tableAudios,
          groupBy: "title", where: "title in ('$unitTestAudioTitle')");
      expect(audioTableQueryResult.length, 0);
      await AudioRepository.instance.create(unitTestAudio);
      audioTableQueryResult = await db.query(tableAudios,
          groupBy: "title", where: "title in ('$unitTestAudioTitle')");
      expect(audioTableQueryResult.length, 1);
      await db.execute(
          "DELETE FROM $tableAudios WHERE title='$unitTestAudioTitle'");
    });
    test('U-13-2: adding photo to db', () async {
      await db.execute(
          "DELETE FROM $tablePhotos WHERE title='$unitTestPhotoTitle'");
      var photoTableQueryResult = await db.query(tablePhotos,
          groupBy: "title", where: "title in ('$unitTestPhotoTitle')");
      expect(photoTableQueryResult.length, 0);
      await PhotoRepository.instance.create(unitTestPhoto);
      photoTableQueryResult = await db.query(tablePhotos,
          groupBy: "title", where: "title in ('$unitTestPhotoTitle')");
      expect(photoTableQueryResult.length, 1);
      await db.execute(
          "DELETE FROM $tablePhotos WHERE title='$unitTestPhotoTitle'");
    });
  });
}
