import 'package:clearassistapp/src/database/model/location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const int id = 1;
  const double latitude = 90.51;
  const double longitude = 100.35;

  const String address = "123 Smith Lane Greenville, CT 12345";
  final DateTime timestamp = DateTime.utc(2023, 10, 23);

  test('U-10-1: Location constructor create a location object', () {
    final LocationDataModel location = LocationDataModel(
      id: id,
      latitude: latitude,
      longitude: longitude,
      address: address,
      timestamp: timestamp,
    );
    expect(location.id, id);
    expect(location.latitude, latitude);
    expect(location.longitude, longitude);
    expect(location.address, address);
    expect(location.timestamp, timestamp);
  });

  test('U-10-2: Create map from location', () {
    final LocationDataModel location = LocationDataModel(
      id: id,
      latitude: latitude,
      longitude: longitude,
      address: address,
      timestamp: timestamp,
    );

    final Map<String, Object?> json = location.toMap();

    expect(json, {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': '2023-10-23T00:00:00.000Z',
    });
  });

  test('U-10-3: Create location from map', () {
    final Map<String, Object?> json = {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toString(),
    };

    final LocationDataModel location = LocationDataModel.fromMap(json);

    expect(location.id, id);
    expect(location.latitude, latitude);
    expect(location.longitude, longitude);
    expect(location.address, address);
    expect(location.timestamp, timestamp);
  });
}
