import 'package:clearassistapp/src/database/app_database.dart';
import 'package:clearassistapp/src/database/model/contact.dart';

const String tableContacts = 'contacts';

class ContactFields {
  static final List<String> values = [
    id,
    contactName,
    nickName,
    phoneNum,
    eMail,
  ];
  static const String contactFileName = 'contact_file_name';

  static const String id = '_id';
  static const String contactName = 'contact_file_name';
  static const String nickName = 'nickName';
  static const String phoneNum = 'phoneNum';
  static const String eMail = 'eMail';
}

class ContactRepository {
  static final ContactRepository instance = ContactRepository._init();

  ContactRepository._init();

  Future<ContactModel> create(ContactModel contact) async {
    final db = await AppDatabase.instance.database;

    final id = await db.insert(tableContacts, contact.toJson());

    return contact.copy(potentialID: contact.id);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      tableContacts,
      where: '${ContactFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<ContactModel> read(int id) async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query(
      tableContacts,
      where: '${ContactFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ContactModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<ContactModel>> readAll() async {
    final db = await AppDatabase.instance.database;

    const orderBy = '${ContactFields.id} ASC';
    final result = await db.query(tableContacts, orderBy: orderBy);

    return result.map((json) => ContactModel.fromJson(json)).toList();
  }

  Future<int> update(ContactModel contact) async {
    final db = await AppDatabase.instance.database;

    return db.update(
      tableContacts,
      contact.toJson(),
      where: '${ContactFields.id} = ?',
      whereArgs: [contact.id],
    );
  }
}
