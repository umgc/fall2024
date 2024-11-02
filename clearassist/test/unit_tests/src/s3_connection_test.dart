import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../resources/mocks/s3_connection_test.mocks.dart';

//@GenerateNiceMocks([MockSpec<S3Bucket>()])
//@GenerateNiceMocks([MockSpec<S3>()])
void main() {
  final s3Bucket = MockS3Bucket();

  test('U-6-1: add audio to S3', () async {
    s3Bucket.createBucket;
    expect(s3Bucket.connection, null);
    expect(s3Bucket.toString(), "MockS3Bucket");

    Future<String> result = Future.value('testAudio');

    when(s3Bucket.addAudioToS3(
            'testAudio', '/assets/test_images/Sea waves.mp4'))
        .thenAnswer((_) => result);

    await expectLater(
        s3Bucket.addAudioToS3('testAudio', '/assets/test_images/Sea waves.mp4'),
        result);

    verifyNever(s3Bucket.addAudioToS3('testAudio', 'somelocalPath'));
  });

  test('U-6-2: add video to S3', () async {
    s3Bucket.createBucket;
    expect(s3Bucket.connection, null);
    expect(s3Bucket.toString(), "MockS3Bucket");

    Future<String> result = Future.value('testVideo');

    when(s3Bucket.addVideoToS3(
            'testVideo', '/assets/test_images/1MinuteSampleVideo.mp4'))
        .thenAnswer((_) => result);

    await expectLater(
        s3Bucket.addVideoToS3(
            'testVideo', '/assets/test_images/1MinuteSampleVideo.mp4'),
        result);

    verifyNever(s3Bucket.addVideoToS3('testVideo2', 'somelocalPath'));
  });
}
