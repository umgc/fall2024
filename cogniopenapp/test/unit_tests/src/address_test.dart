/* Tests the CogniOpen Address class
     1. Uses Mockito to intercept questions to the Global Positioning System (GPS)
     2. Uses Mockito to intercept queries to reverse geocoding web services
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cogniopenapp/src/address.dart';
import '../../resources/mocks/address_mock.dart';

void main() {
  test('U-1-1: Making sure that location and address are obtainable', () async {
    GeolocatorPlatform.instance = MockGeolocatorPlatform();
    GeocodingPlatform.instance = MockGeocodingPlatform();
    var physicalAddress = "";
    await Address.whereIAm(isTesting: true)
        .then((String address) => physicalAddress = address);
    expect(
        physicalAddress, "501 Hungerford Dr, Rockville, Maryland, 20850, US");
  });
}
