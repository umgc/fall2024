import 'package:flutter/services.dart';

class SmsSender {
  // Define the MethodChannel for communicating with native Android code/logic.
  static const MethodChannel smsChannel = MethodChannel('smsChannel');

  // Sends an SMS with the specified phone number and message.
  Future<void> sendSms(String phoneNumber, String message) async {
    try {
      // Invoke the 'sendSms' method on the native side using the specified parameters listed below.
      final result = await smsChannel.invokeMethod<String>('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      print(result ??
          "SMS sent successfully."); // Print success or error message.
    } on PlatformException catch (e) {
      print(
          "Failed to send SMS: ${e.code}, '${e.message}'"); // Logs the error message.
    }
  }
}
