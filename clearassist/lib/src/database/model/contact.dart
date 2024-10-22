import 'package:logging/logging.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:aws_client/backup_storage_2018_04_10.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

var logger = Logger("Contact");

class ContactModel {
  final Name name;
  final Phone phoneNum;
  final Email? eMail;
  final String? nickName;
  int? id;
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
      this.id});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNum': phoneNum,
      'eMail': eMail,
      'nickName': nickName
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
  // static ContactModel fromJson(Map<String, Object?> json) {
  //   try {
  //     return ContactModel(
  //       id: json[id] as int?,
  //       phoneNum: json[phone] as Phone,
  //       eMail: json[eMail] as Email?,
  //       nickName: json[nickName] as String?,
  //       name: json[name] as Name,
  //       timestamp: DateTime.fromMillisecondsSinceEpoch(
  //         (json[ContactFields.timestamp] as int),
  //         isUtc: true,
  //       ),
  //       contactFileName: json[AudioFields.audioFileName] as String,
  //     );
  //   } catch (e) {
  //     throw FormatException('Error parsing JSON: $e');
  //   }
  // }
}

class Name {
  String first = "";
  String last = "";
  Name(String f, String l) {
    if (f.isAlphabet()) {
      first = f;
    }
    if (l.isAlphabet()) {
      last = l;
    }
    if (first.isEmpty && last.isEmpty) {
      throw IllegalArgumentException(
          message:
              "No valid names supplied. Please use only alphabetical characters.");
    } else {
      logger.info("First name: $first. Last name: $last");
    }
  }
}

class Phone {
  String number = '';
  PhoneLabel? label = PhoneLabel.main;
  Phone(String potentialNum, PhoneLabel newLabel) {
    if (potentialNum.isPhone()) {
      number = potentialNum;
      logger.info("$number was accepted as a legal number");
    } else {
      throw IllegalArgumentException(
          message: "Phone number supplied is invalid.");
    }
    if (newLabel != null) {
      label = newLabel;
    }
  }
}

class Email {
  String eAddress = '';
  EmailLabel? label;
  Email(String add, EmailLabel? newLabel) {
    if (add.isEmail()) {
      eAddress = add;
    } else {
      throw IllegalArgumentException(message: "Email was invalid.");
    }
    if (newLabel != null) {
      label = newLabel;
    }
  }
}

class Note {
  String note = "";
  Note(String newNote) {
    note = newNote;
  }
}
