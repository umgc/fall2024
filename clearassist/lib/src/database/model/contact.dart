import 'package:logging/logging.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:aws_client/backup_storage_2018_04_10.dart';
import 'package:clearassistapp/src/utils/directory_manager.dart';
import 'package:clearassistapp/src/utils/file_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

var logger = Logger("Contact");
class Contact {

    Name name;
    Phone phoneNum;
    Email? eMail;
  // Contact({
  //   int? id,
//     String displayName,
//     int photo?,
//     int List? thumbnail,
    // required Name name,
    // required Phone phone,
    // List<Email> emails,
//     List<Address> addresses,
//     List<Note> notes,
  // }) 

  Contact(Name newName, Phone newPhone, Email newEmail ){
   name = newName;
   phoneNum = newPhone;
   eMail = newEmail;
  }

/*  @override
  Photo copy({
    int? id,
    String? title,
    String? description,
    List<String>? tags,
    DateTime? timestamp,
    String? physicalAddress,
    int? storageSize,
    bool? isFavorited,
    String? photoFileName,
  }) =>
      Photo(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        timestamp: timestamp ?? this.timestamp,
        physicalAddress: physicalAddress ?? this.physicalAddress,
        storageSize: storageSize ?? this.storageSize,
        isFavorited: isFavorited ?? this.isFavorited,
        photoFileName: photoFileName ?? this.photoFileName,
      );

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
      PhotoFields.photoFileName: photoFileName,
    };
  }

  static Photo fromJson(Map<String, Object?> json) {
    try {
      return Photo(
        id: json[MediaFields.id] as int?,
        title: json[MediaFields.title] as String?,
        description: json[MediaFields.description] as String?,
        tags: (json[MediaFields.tags] as String?)?.split(','),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (json[MediaFields.timestamp] as int),
          isUtc: true,
        ),
        physicalAddress: json[MediaFields.physicalAddress] as String,
        storageSize: json[MediaFields.storageSize] as int,
        isFavorited: json[MediaFields.isFavorited] == 1,
        photoFileName: json[PhotoFields.photoFileName] as String,
      );
    } catch (e) {
      throw FormatException('Error parsing JSON for Photo: $e');
    }
  }

  Future<void> _loadPhoto() async {
    photo = FileManager.loadImage(
      DirectoryManager.instance.photosDirectory.path,
      photoFileName,
    );
  }
}*/

class Name { 
  String first = ""; String last = ""; 
  Name (String f, String l) {
    if(f.isAlphabet()){ first = f;}
    if(l.isAlphabet()){ last = l;}
    if(first.isEmpty && last.isEmpty){ throw IllegalArgumentException(message: "No valid names supplied. Please use only alphabetical characters.");} 
    else {logger.info("First name: $first. Last name: $last");}
  }
}
class Phone { String number = ''; PhoneLabel? label = PhoneLabel.main; 
  Phone(String potentialNum, PhoneLabel newLabel){
    if(potentialNum.isPhone()){
      number = potentialNum;
      logger.info("$number was accepted as a legal number");
    } else {throw IllegalArgumentException(message: "Phone number supplied is invalid.");}
    if(newLabel != null){ label = newLabel;}
  }
}
class Email { String address = ''; EmailLabel? label; 
  Email(String add, EmailLabel? newLabel){ 
    if(add.isEmail()){ address = add; }
    else{ throw IllegalArgumentException(message: "Email was invalid."); }
    if(newLabel != null){ label = newLabel; }
  }
}
class Address { String address; AddressLabel? label; 
  Address(String newAdd, AddressLabel? newLabel){

  }
}
class Note { String note; }