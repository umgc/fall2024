import 'dart:io';

import 'package:clearassistapp/src/database/model/contact.dart';
import 'package:clearassistapp/src/database/repository/contact_repository.dart';
import 'package:clearassistapp/src/utils/directory_manager.dart';
import 'package:clearassistapp/src/utils/file_manager.dart';
import 'package:clearassistapp/src/utils/logger.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactController {
  ContactController._();

  static Future<ContactModel?> addSeedContact({
    required Name displayName,
    String? nickName,
    Email? address,
    required Phone number,
    required File contactFile,
  }) async {
    try {
      DateTime timestamp = DateTime.now();
      String contactFileExtension =
          FileManager().getFileExtensionFromFile(contactFile);
      String contactFileName = FileManager().generateFileName(
        ContactFields.contactName,
        timestamp,
        contactFileExtension,
      );
      int contactFileSize = FileManager.calculateFileSizeInBytes(contactFile);
      ContactModel newContact = ContactModel(
        name: displayName,
        phoneNum: number,
        nickName: nickName,
        eMail: address,
      );
      ContactModel createdContact =
          await ContactRepository.instance.create(newContact);
      await FileManager.addFileToFilesystem(
        contactFile,
        DirectoryManager.instance.contactsDirectory.path,
        contactFileName,
      );
      return createdContact;
    } catch (e) {
      appLogger.severe('Contact Controller -- Error adding contact: $e');
      return null;
    }
  }

  static Future<ContactModel?> addContact({
    required Name newName,
    String? newNickName,
    required Phone newNum,
    Email? newEmail,
    required File contactFile,
  }) async {
    try {
      String contactFileName = FileManager.getFileName(contactFile.path);
      int contactFileSize = FileManager.calculateFileSizeInBytes(contactFile);
      DateTime timestamp =
          DateTime.parse(FileManager.getFileTimestamp(contactFile.path));
      ContactModel newContact = ContactModel(
        nickName: newNickName ?? "",
        name: newName,
        phoneNum: newNum,
        eMail: newEmail,
      );
      ContactModel createdContact =
          await ContactRepository.instance.create(newContact);
      return createdContact;
    } catch (e) {
      appLogger.severe('Contact Controller -- Error adding contact: $e');
      return null;
    }
  }

  static Future<ContactModel?> updateContact({
    required int id,
    Name? newName,
    String? newNickName,
    Email? newEmail,
    Phone? newNumber,
  }) async {
    try {
      final existingContact = await ContactRepository.instance.read(id);
      final updatedContact = existingContact.copy(
        potentialName: newName ?? existingContact.name,
        potentialNickName: newNickName ?? existingContact.nickName,
        potentialMail: newEmail ?? existingContact.eMail,
        potentialPhone: newNumber ?? existingContact.phoneNum,
      );
      await ContactRepository.instance.update(updatedContact);
      return updatedContact;
    } catch (e) {
      appLogger.severe('Contact Controller -- Error updating contact: $e');
      return null;
    }
  }

  static Future<ContactModel?> removeContact(int id) async {
    try {
      final existingContact = await ContactRepository.instance.read(id);
      await ContactRepository.instance.delete(id);
      final contactFilePath =
          '${DirectoryManager.instance.contactsDirectory.path}/${existingContact.name}';
      await FileManager.removeFileFromFilesystem(contactFilePath);
      return existingContact;
    } catch (e) {
      appLogger.severe('Contact Controller -- Error removing contact: $e');
      return null;
    }
  }
}
