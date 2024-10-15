import 'package:aws_client/managed_blockchain_2018_09_24.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ContactDisplay extends StatefulWidget {
  const ContactDisplay({super.key});
  @override
  State<ContactDisplay> createState() {
    return _ContactsDisplay();
  }
}

class _ContactsDisplay extends State<ContactDisplay> {
  //From phone contacts, register contact for emergency messages.
  void testContactPull() {
    setState(() {
      Future<Contact> contact = retrieveContactList();
    });
  }

  @override
  Widget build(context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      const SizedBox(height: 20),
      TextButton(
          onPressed: testContactPull,
          style: TextButton.styleFrom(
            // padding: EdgeInsets.all(10),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 28,
            ),
          ),
          child: const Text('Roll Dice',
              style: TextStyle(fontSize: 28, color: Colors.white))),
    ]);
  }

  late Future<Contact>
      contact; //= await FlutterContacts.getContact(contacts.first.id);
  late List<Contact> contactList;

  Future<Contact> retrieveContactList() async {
    // Get all contacts (fully fetched)
    if (await FlutterContacts.requestPermission()) {
      return contact = (await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true)) as Future<Contact>;
    } else {
      throw IllegalActionException(
          message:
              "This application cannot register contacts without your permission.");
    }
  }

  void registerContact() async {
    // Request contact permission
    if (await FlutterContacts.requestPermission()) {
      // Open external contact app to view/edit/pick/insert contacts.
      // await FlutterContacts.openExternalView(contact.id);//May need modification
      final contact = await FlutterContacts.openExternalPick();
      print(contact.toString());
    }
  }

  void removeContactRegistration() {}
}

// class Contact {
//     String displayName;
//     int List? photo;
//     int List? thumbnail;
//     Name name;
//     List<Phone> phones;
//     List<Email> emails;
//     List<Address> addresses;
//     List<Note> notes;
//     List<Group> groups;

// }
// class Name { String first; String last; }
// class Phone { String number; PhoneLabel label; }
// class Email { String address; EmailLabel label; }
// class Address { String address; AddressLabel label; }
// class Note { String note; }

