// sos_permissions.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart'; // Ensure this is correctly installed
import '../services/sendSMS.dart';

/// Checks and requests SMS and Contacts permissions.
Future<bool> checkAndRequestPermissions(BuildContext context) async {
  if (await Permission.contacts.request().isGranted &&
      await Permission.sms.request().isGranted) {
    return true; // Both permissions granted
  } else {
    _showPermissionDeniedDialog(context);
    return false;
  }
}

/// Retrieves emergency contacts labeled with "ICE" or "Emergency".
Future<List<String>> getEmergencyContactNumbers(BuildContext context) async {
  List<String> emergencyNumbers = [];

  if (await checkAndRequestPermissions(context)) {
    final contacts = await ContactsService.getContacts(withThumbnails: false);
    for (var contact in contacts) {
      if (contact.displayName != null &&
          (contact.displayName!.toLowerCase().contains("ice") ||
              contact.displayName!.toLowerCase().contains("emergency"))) {
        for (var phone in contact.phones!) {
          final formattedNumber = formatPhoneNumber(phone.value);
          if (formattedNumber != null) {
            emergencyNumbers.add(formattedNumber);
          }
        }
      }
    }
  }

  if (emergencyNumbers.isEmpty) {
    _showErrorDialog(context, "No emergency contacts found.");
  }

  return emergencyNumbers;
}

/// Formats a phone number with +1 at the beginning, if not already present.
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

/// Sends the SOS SMS message to emergency contacts after ensuring permission.
Future<void> sendSosSms(BuildContext context) async {
  final emergencyNumbers = await getEmergencyContactNumbers(context);
  final message =
      "This is a TEST for an APP - NOT REAL - SOS message. Please respond as soon as possible.";
  final smsSender = SmsSender();

  if (emergencyNumbers.isNotEmpty) {
    for (var phoneNumber in emergencyNumbers) {
      try {
        await smsSender.sendSms('8106102137', message);
        print("SOS SMS sent to $phoneNumber!");
      } catch (e) {
        print("Failed to send SOS SMS to '$phoneNumber': $e");
        _showErrorDialog(context,
            "Failed to send SOS message to $phoneNumber. Please try again.");
      }
    }
    _showSuccessDialog(context);
  } else {
    print("No emergency contacts found. SOS SMS not sent.");
  }
}

/// Shows a dialog to inform the user about permission requirements.
void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permissions Required',
          style: TextStyle(color: Colors.black)),
      content: const Text(
        'Please enable SMS and Contacts permissions to use this feature.',
        style: TextStyle(color: Colors.black),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// Shows a dialog to direct the user to settings if permission is permanently denied.
void _showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('SMS Permission Permanently Denied',
          style: TextStyle(color: Colors.black)),
      content: const Text(
          'Please enable SMS permissions from your device settings to use this feature.',
          style: TextStyle(color: Colors.black)),
      actions: <Widget>[
        TextButton(
          child: const Text('Settings', style: TextStyle(color: Colors.black)),
          onPressed: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// Shows a confirmation dialog after a successful SOS message.
void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('SOS Sent', style: TextStyle(color: Colors.black)),
      content: const Text(
        'Your SOS message has been sent successfully to all emergency contacts.',
        style: TextStyle(color: Colors.black),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// Shows an error dialog if the SOS message fails to send.
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
