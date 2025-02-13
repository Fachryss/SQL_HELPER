import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'kindacode.db'),
      version: 2, // Versi ditingkatkan untuk memperbarui tabel
      onCreate: (Database database, int version) async {
        await database.execute("""
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            note TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE items ADD COLUMN note TEXT;");
        }
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> createItem(String title, String? description, String? note) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': description, 'note': note};
    return db.insert('items', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateItem(int id, String title, String? description, String? note) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'note': note,
      'createdAt': DateTime.now().toIso8601String()
    };
    return db.update('items', data, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    await db.delete('items', where: "id = ?", whereArgs: [id]);
  }
}
