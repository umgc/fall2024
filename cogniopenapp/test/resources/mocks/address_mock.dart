import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

final mockPosition = Position(
    latitude: -77.1517459,
    longitude: 39.0903002,
    timestamp: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    accuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0);

final mockPlacemark = Placemark(
    administrativeArea: 'Maryland',
    country: 'United States',
    isoCountryCode: 'US',
    locality: 'Rockville',
    name: '501',
    postalCode: '20850',
    street: '501 Hungerford Dr',
    subAdministrativeArea: 'Montgomery County',
    subLocality: '',
    subThoroughfare: '501',
    thoroughfare: 'Hungerford Drive');

class MockGeolocatorPlatform extends Mock with MockPlatformInterfaceMixin implements GeolocatorPlatform {
  @override
  Future<LocationPermission> requestPermission() => Future.value(LocationPermission.whileInUse);

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) =>
      Future.value(mockPosition);
}

class MockGeocodingPlatform extends Mock with MockPlatformInterfaceMixin implements GeocodingPlatform {
  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude, {
    String? localeIdentifier,
  }) async {
    return [mockPlacemark];
  }
}
