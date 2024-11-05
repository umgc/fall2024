import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectEmergencyContactsScreen extends StatefulWidget {
  @override
  _SelectEmergencyContactsScreenState createState() =>
      _SelectEmergencyContactsScreenState();
}

class _SelectEmergencyContactsScreenState
    extends State<SelectEmergencyContactsScreen> {
  List<Contact> allContacts = [];
  List<Contact> emergencyContacts = [];
  List<Contact> selectedEmergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedContacts = prefs.getStringList('emergency_contacts');

      setState(() {
        allContacts = contacts.toList();

        emergencyContacts = allContacts.where((contact) {
          final name = contact.displayName?.toLowerCase() ?? '';
          return name.contains('emergency');
        }).toList();

        if (savedContacts != null) {
          selectedEmergencyContacts = allContacts.where((contact) {
            final contactInfo =
                "${contact.displayName}|${contact.phones?.isNotEmpty == true ? contact.phones!.first.value : ''}";
            return savedContacts.contains(contactInfo);
          }).toList();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Permission to access contacts is required.")),
      );
    }
  }

  String _cleanName(String name) {
    return name.trim();
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (selectedEmergencyContacts.contains(contact)) {
        selectedEmergencyContacts.remove(contact);
      } else {
        selectedEmergencyContacts.add(contact);
      }
    });
  }

  Future<void> _saveSelectedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contactDetails = selectedEmergencyContacts.map((contact) {
      String displayName = contact.displayName ?? "Unknown";
      String phone = contact.phones?.isNotEmpty ?? false
          ? contact.phones!.first.value!
          : "NoNumber";
      return "$displayName|$phone";
    }).toList();

    await prefs.setStringList('emergency_contacts', contactDetails);
    Navigator.pop(context, selectedEmergencyContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Emergency Contacts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSelectedContacts,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Detected Emergency Contacts",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          if (selectedEmergencyContacts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saved Emergency Contacts",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: selectedEmergencyContacts.length,
                    itemBuilder: (context, index) {
                      final contact = selectedEmergencyContacts[index];
                      return ListTile(
                        title: Text(
                          _cleanName(contact.displayName ?? "Unknown"),
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          contact.phones?.isNotEmpty == true
                              ? contact.phones!.first.value!
                              : "No Number",
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = emergencyContacts[index];
                final isSelected = selectedEmergencyContacts.contains(contact);
                return ListTile(
                  title: Text(
                    _cleanName(contact.displayName ?? "Unknown"),
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected ? Colors.blue : null,
                  ),
                  onTap: () => _toggleContactSelection(contact),
                );
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "All Contacts",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allContacts.length,
              itemBuilder: (context, index) {
                final contact = allContacts[index];
                final isSelected = selectedEmergencyContacts.contains(contact);
                return ListTile(
                  title: Text(
                    contact.displayName ?? "Unknown",
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected ? Colors.blue : null,
                  ),
                  onTap: () => _toggleContactSelection(contact),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
