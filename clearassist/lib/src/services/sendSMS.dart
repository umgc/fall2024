import 'package:flutter/services.dart';

class SmsSender {
  // Define the MethodChannel for communicating with native code
  static const _platform = MethodChannel('smsChannel');

  // Sends an SMS with the specified phone number and message
  Future<void> sendSms(String phoneNumber, String message) async {
    try {
      final result = await _platform.invokeMethod<String>('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      print(result ??
          "SMS sent successfully."); // Print success message or fallback
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'"); // Print error message
    }
  }
}
