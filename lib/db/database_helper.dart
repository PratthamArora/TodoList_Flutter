import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolistflutter/model/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // singleton
  static Database _database;

  String noteTable = 'note_table';
  String columnId = 'id';
  String columnTitle = 'title';
  String columnDescription = 'description';
  String columnDate = 'Date';
  String columnPriority = 'Priority';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDB();
    }
    return _database;
  }

  Future<Database> initDB() async {
    // get path
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    // create DB
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDB);
    return notesDatabase;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnTitle TEXT,'
        '$columnDescription TEXT, $columnPriority INTEGER, $columnDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNotesList() async {
    Database db = await this.database;
    var result = await db.query(noteTable, orderBy: '$columnPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$columnId = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result = await db.delete(noteTable, where: '$columnId =$id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> list =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(list);
    return result;
  }
}
