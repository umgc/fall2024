import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockCameraPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CameraPlatform {
  @override
  Future<void> initializeCamera(
    int? cameraId, {
    ImageFormatGroup? imageFormatGroup = ImageFormatGroup.unknown,
  }) async =>
      super.noSuchMethod(Invocation.method(
        #initializeCamera,
        <Object?>[cameraId],
        <Symbol, dynamic>{
          #imageFormatGroup: imageFormatGroup,
        },
      ));

  @override
  Future<void> dispose(int? cameraId) async {
    return super.noSuchMethod(Invocation.method(#dispose, <Object?>[cameraId]));
  }

  @override
  Future<List<CameraDescription>> availableCameras() =>
      Future<List<CameraDescription>>.value(mockAvailableCameras);

  @override
  Future<int> createCamera(
    CameraDescription description,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) =>
      Future<int>.value(mockInitializeCamera);

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      Stream<CameraInitializedEvent>.value(mockOnCameraInitializedEvent);

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      Stream<DeviceOrientationChangedEvent>.value(
          mockOnDeviceOrientationChangedEvent);
}

List<CameraDescription> get mockAvailableCameras => <CameraDescription>[
      const CameraDescription(
          name: 'camBack',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90),
      const CameraDescription(
          name: 'camFront',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 180),
    ];

int get mockInitializeCamera => 13;

CameraInitializedEvent get mockOnCameraInitializedEvent =>
    const CameraInitializedEvent(
      13,
      75,
      75,
      ExposureMode.auto,
      true,
      FocusMode.auto,
      true,
    );

DeviceOrientationChangedEvent get mockOnDeviceOrientationChangedEvent =>
    const DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);

class MockCameraDescription extends CameraDescription {
  /// Creates a new camera description with the given properties.
  const MockCameraDescription()
      : super(
          name: 'Test',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        );

  @override
  CameraLensDirection get lensDirection => CameraLensDirection.back;

  @override
  String get name => 'back';
}
