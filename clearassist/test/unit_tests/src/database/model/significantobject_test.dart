import 'package:clearassistapp/src/database/model/significant_object.dart';
import 'package:clearassistapp/src/database/repository/significant_object_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const int id = 1;
  const String objectLabel = 'cat';
  const String customLabel = 'my cat';
  final int timestamp = DateTime.utc(2023, 10, 23).millisecondsSinceEpoch;
  const String imageFileName = 'cat.png';
  const double left = 10.0;
  const double top = 11.0;
  const double width = 150.5;
  const double height = 300.0;

  test(
      'U-11-1: SignificantObject constructor create a significant object model',
      () {
    final SignificantObject so = SignificantObject(
      id: id,
      objectLabel: objectLabel,
      customLabel: customLabel,
      timestamp: timestamp,
      imageFileName: imageFileName,
      left: left,
      top: top,
      width: width,
      height: height,
    );
    expect(so.id, id);
    expect(so.objectLabel, objectLabel);
    expect(so.timestamp, timestamp);
    expect(so.imageFileName, imageFileName);
    expect(so.left, left);
    expect(so.top, top);
    expect(so.width, width);
    expect(so.height, height);
  });

  test('U-11-2: create a significant object model from json', () {
    final Map<String, Object?> json = {
      SignificantObjectFields.id: id,
      SignificantObjectFields.objectLabel: objectLabel,
      SignificantObjectFields.timestamp: timestamp,
      SignificantObjectFields.imageFileName: imageFileName,
      SignificantObjectFields.left: left,
      SignificantObjectFields.top: top,
      SignificantObjectFields.width: width,
      SignificantObjectFields.height: height,
    };

    final SignificantObject so = SignificantObject.fromJson(json);
    expect(so.id, id);
    expect(so.objectLabel, objectLabel);
    expect(so.timestamp, timestamp);
    expect(so.imageFileName, imageFileName);
    expect(so.left, left);
    expect(so.top, top);
    expect(so.width, width);
    expect(so.height, height);
  });

  test('U-11-3: create JSON from a significant object model', () {
    final SignificantObject so = SignificantObject(
      id: id,
      objectLabel: objectLabel,
      customLabel: customLabel,
      timestamp: timestamp,
      imageFileName: imageFileName,
      left: left,
      top: top,
      width: width,
      height: height,
    );

    final Map<String, Object?> json = so.toJson();

    expect(json, {
      SignificantObjectFields.id: id,
      SignificantObjectFields.objectLabel: objectLabel,
      SignificantObjectFields.customLabel: customLabel,
      SignificantObjectFields.timestamp: timestamp,
      SignificantObjectFields.imageFileName: imageFileName,
      SignificantObjectFields.left: left,
      SignificantObjectFields.top: top,
      SignificantObjectFields.width: width,
      SignificantObjectFields.height: height,
    });
  });
}
