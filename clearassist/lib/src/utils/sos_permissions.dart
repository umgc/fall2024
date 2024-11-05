import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../services/sendSMS.dart';

const MethodChannel _platformChannel = MethodChannel('smsChannel');

// Checks and requests SMS and Contacts permissions if not already granted.
Future<bool> checkAndRequestPermissions(BuildContext context) async {
  bool permissionsGranted = true;

  // Request SMS permission to have the ability to send a message.
  if (!await Permission.sms.isGranted) {
    permissionsGranted &= await Permission.sms.request().isGranted;
  }

  // Request Contacts permission to have tha ability to access emergency contacts.
  if (!await Permission.contacts.isGranted) {
    permissionsGranted &= await Permission.contacts.request().isGranted;
  }

  if (!permissionsGranted) {
    _showPermissionDeniedDialog(context);
  }

  return permissionsGranted;
}

// Retrieves emergency contacts from the Android device, or SharedPreferences if unavailable.
Future<List<String>> getEmergencyContactNumbers(BuildContext context) async {
  List<String> emergencyNumbers = [];

  try {
// Retrieve emergency contacts.
    final List<dynamic> contacts =
        await _platformChannel.invokeMethod('getEmergencyContacts');
    emergencyNumbers = contacts.cast<String>();
  } on PlatformException catch (e) {
    print(
        "Failed to get emergency contacts from native platform: ${e.message}");
    _showErrorDialog(context, "Unable to access emergency contacts.");
  }

  if (emergencyNumbers.isEmpty) {
    // Use the SharedPreferences if no contacts return from the native device and instead use the user indicated saved contacts.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedContacts = prefs.getStringList('emergency_contacts');
    if (savedContacts != null) {
      emergencyNumbers = savedContacts
          .map((contact) {
            final contactParts = contact.split('|');
            return formatPhoneNumber(
                    contactParts.length == 2 ? contactParts[1] : null) ??
                "";
          })
          .where((number) => number.isNotEmpty)
          .toList();
    } else {
      _showErrorDialog(context, "No emergency contacts found.");
    }
  }

  return emergencyNumbers;
}

// Formats phone numbers to E.164 format (+1, then the number) - commented here so I can remember...
String? formatPhoneNumber(String? phoneNumber) {
  if (phoneNumber == null) return null;
  final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleanedNumber.startsWith('1') && cleanedNumber.length == 11) {
    return '+$cleanedNumber';
  } else if (cleanedNumber.length == 10) {
    return '+1$cleanedNumber';
  } else if (cleanedNumber.startsWith('+1')) {
    return cleanedNumber;
  } else {
    return null;
  }
}

// Sends the SOS message to all confirmed emergency contacts.
Future<void> sendSosSms(BuildContext context) async {
  final emergencyNumbers = await getEmergencyContactNumbers(context);

  if (emergencyNumbers.isNotEmpty) {
    bool confirmed = await _showConfirmationDialog(context, emergencyNumbers);

    if (confirmed) {
      final message =
          "This is a TEST for an APP - NOT REAL - SOS message. Please respond as soon as possible."; //Feel free to change if used for another implementation.
      final smsSender = SmsSender();

      for (var phoneNumber in emergencyNumbers) {
        try {
          await smsSender.sendSms(phoneNumber, message);
          print("SOS SMS sent to $phoneNumber!");
        } catch (e) {
          print("Failed to send SOS SMS to '$phoneNumber': $e");
          _showErrorDialog(context,
              "Failed to send SOS message to $phoneNumber. Please try again.");
        }
      }
      _showSuccessDialog(context);
    }
  } else {
    _showErrorDialog(context, "No emergency contacts found.");
  }
}

// This will show the confirmation dialog listing emergency numbers before sending the SOS message.
Future<bool> _showConfirmationDialog(
    BuildContext context, List<String> emergencyNumbers) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm SOS Message',
                style: TextStyle(color: Colors.black)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "The SOS message will be sent to the following contacts:",
                    style: TextStyle(color: Colors.black)),
                const SizedBox(height: 8),
                ...emergencyNumbers.map((number) =>
                    Text(number, style: const TextStyle(color: Colors.black))),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Confirm',
                    style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      ) ??
      false;
}

// This notifies/inform the user that permissions are required to send SOS messages.
void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permissions Required to Send SMS/SOS',
          style: TextStyle(color: Colors.black)),
      content: const Text(
          'Please enable SMS and Contacts permissions to use this feature.',
          style: TextStyle(color: Colors.black)),
      actions: <Widget>[
        TextButton(
          child: const Text('Settings', style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
        ),
        TextButton(
          child: const Text('OK', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

// This will show the user a success dialog after SOS message is sent.
void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('SOS Sent', style: TextStyle(color: Colors.black)),
      content: const Text(
          'Your SOS message has been sent successfully to all emergency contacts.',
          style: TextStyle(color: Colors.black)),
      actions: <Widget>[
        TextButton(
          child: const Text('OK', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

// This will show the user of any error dialog for failed SMS attempts.
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error', style: TextStyle(color: Colors.black)),
      content: Text(message, style: const TextStyle(color: Colors.black)),
      actions: <Widget>[
        TextButton(
          child: const Text('OK', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
