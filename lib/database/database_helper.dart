import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pkl_tracker_local.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE presensi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        jamMasuk TEXT,
        jamPulang TEXT,
        status TEXT NOT NULL,
        keterangan TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE logbook (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        jamMulai TEXT NOT NULL,
        jamSelesai TEXT NOT NULL,
        kegiatan TEXT NOT NULL,
        kompetensi TEXT NOT NULL,
        kendala TEXT,
        solusi TEXT
      )
    ''');
  }

  Future<void> hapusSemuaTabel() async {
    final db = await database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    for (final row in tables) {
      final tableName = row['name'] as String;
      await db.execute('DROP TABLE IF EXISTS $tableName');
    }

    await _createTables(db, 1);
  }
}