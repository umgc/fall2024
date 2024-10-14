import 'package:cogniopenapp/src/utils/directory_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../resources/fake_path_provider_platform.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = FakePathProviderPlatform();
    DirectoryManager.instance.initializeDirectories();
  });

  test('U-15-1: verify all directores were created', () {
    expect(DirectoryManager.instance.rootDirectory, isNot(null));
    expect(DirectoryManager.instance.photosDirectory, isNot(null));
    expect(DirectoryManager.instance.videosDirectory, isNot(null));
    expect(DirectoryManager.instance.audiosDirectory, isNot(null));
    expect(DirectoryManager.instance.videoStillsDirectory, isNot(null));
    expect(DirectoryManager.instance.videoThumbnailsDirectory, isNot(null));
    expect(DirectoryManager.instance.tmpDirectory, isNot(null));
  });
}
