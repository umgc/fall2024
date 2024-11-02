import 'package:clearassistapp/src/database/app_seed_data.dart';
import 'package:clearassistapp/src/database/model/media.dart';
import 'package:clearassistapp/src/database/repository/audio_repository.dart';
import 'package:clearassistapp/src/database/repository/photo_repository.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const tableLocations = 'locations';
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textNullableType = 'TEXT';
    const floatType = 'FLOAT';

    final mediaColumns = [
      '${MediaFields.id} $idType',
      '${MediaFields.title} $textNullableType',
      '${MediaFields.description} $textNullableType',
      '${MediaFields.tags} $textNullableType',
      '${MediaFields.timestamp} $integerType',
      '${MediaFields.physicalAddress} $textNullableType',
      '${MediaFields.storageSize} $integerType',
      '${MediaFields.isFavorited} $boolType',
    ];

    await db.execute('''
      CREATE TABLE $tableAudios (
        ${mediaColumns.join(',\n')},
        ${AudioFields.audioFileName} $textType,
        ${AudioFields.transcriptFileName} $textNullableType,
        ${AudioFields.summary} $textNullableType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePhotos (
        ${mediaColumns.join(',\n')},
        ${PhotoFields.photoFileName} $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLocations (
        id $idType,
        latitude $floatType,
        longitude $floatType,
        address $textNullableType,
        timestamp $integerType
      )
    ''');

    final appSeedData = AppSeedData();
    appSeedData.loadAppSeedData();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
