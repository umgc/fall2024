import 'package:logging/logging.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:io';

var logger = Logger("Contact");

class ContactModel {
  final Name name;
  final Phone phoneNum;
  final Email? eMail;
  final String? nickName;
  int? id;
  File? contactFile;
//     int photo?,
//     int List? thumbnail,
  // required Name name,
  // required Phone phone,
//     List<Note> notes,
  // })

  ContactModel(
      {required this.name,
      required this.phoneNum,
      this.eMail,
      this.nickName,
      this.id,
      this.contactFile});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNum': phoneNum,
      'eMail': eMail,
      'nickName': nickName,
      'id': id,
      'file': contactFile
    };
  }

  ContactModel copy({
    Name? potentialName,
    Phone? potentialPhone,
    Email? potentialMail,
    String? potentialNickName,
    int? potentialID,
  }) =>
      ContactModel(
        id: potentialID ?? id,
        name: potentialName ?? name,
        phoneNum: potentialPhone ?? phoneNum,
        eMail: potentialMail ?? eMail,
        nickName: potentialNickName ?? nickName,
      );

  static ContactModel fromJson(Map<String, Object?> json) {
    try {
      return ContactModel(
        id: json['id'] as int?,
        phoneNum: json['phoneNum'] as Phone,
        eMail: json['eMail'] as Email?,
        nickName: json['nickName'] as String?,
        name: json['name'] as Name,
        contactFile: json['contact'] as File,
      );
    } catch (e) {
      throw FormatException('Error parsing JSON: $e');
    }
  }
}
