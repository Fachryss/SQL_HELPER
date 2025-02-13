import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'kindacode.db'),
      version: 3, // Tingkatkan versi untuk menambahkan kolom imageUrl
      onCreate: (Database database, int version) async {
        await database.execute("""
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            note TEXT,
            imageUrl TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE items ADD COLUMN imageUrl TEXT;");
        }
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<int> createItem(
      String title, String? description, String? note, String? imageUrl) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'note': note,
      'imageUrl': imageUrl
    };
    return db.insert('items', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateItem(int id, String title, String? description,
      String? note, String? imageUrl) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'note': note,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String()
    };
    return db.update('items', data, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    await db.delete('items', where: "id = ?", whereArgs: [id]);
  }
}
