// lib/data/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // 🚀 NEW: For safe debug printing

class DatabaseHelper {
  // Singleton Pattern ensures only one instance of DB exists
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // 🚀 BEST PRACTICE: Define table names as constants to prevent typos
  static const String tableCategories = 'categories';
  static const String tableTasks = 'tasks';
  static const String tableSubtasks = 'subtasks';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('life_os_pro_v2.db'); // 🚀 Version 2 Database
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 2, // 🚀 Bumped version for Mood Tracker
        onCreate: _createDB,
        onUpgrade: _onUpgrade, // Handle updates without losing user data
        onConfigure: _onConfigure,
      );
    } catch (e) {
      debugPrint("🚀 Database Initialization Error: $e");
      rethrow;
    }
  }

  // Ensures Foreign Keys work properly in SQLite
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // 🚀 MIGRATION LOGIC: Updates DB schema without deleting existing user data
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      debugPrint("🚀 Migrating Database to Version 2...");
      await db.execute('ALTER TABLE $tableTasks ADD COLUMN mood_score INTEGER');
      await db.execute('ALTER TABLE $tableTasks ADD COLUMN mood_note TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // 1. Categories Table
    await db.execute('''
      CREATE TABLE $tableCategories (
        id $idType,
        name $textType,
        color_code $textType,
        icon_path TEXT
      )
    ''');

    // 2. Tasks Table
    await db.execute('''
      CREATE TABLE $tableTasks (
        id $idType,
        category_id INTEGER,
        title $textType,
        description TEXT,
        due_date $textType,
        priority $integerType,
        is_completed $integerType DEFAULT 0,
        repeat_rule TEXT,
        notification_id INTEGER,
        mood_score INTEGER, -- For FYP Mood Tracker Integration
        mood_note TEXT,     
        FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE CASCADE
      )
    ''');

    // 3. Subtasks Table
    await db.execute('''
      CREATE TABLE $tableSubtasks (
        id $idType,
        task_id INTEGER,
        title $textType,
        is_completed $integerType DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES $tableTasks (id) ON DELETE CASCADE
      )
    ''');

    await _insertDefaultCategories(db);
  }

  Future _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Study', 'color_code': '#6C63FF'},
      {'name': 'Health', 'color_code': '#4CAF50'},
      {'name': 'Work', 'color_code': '#FF9800'},
      {'name': 'Personal', 'color_code': '#E91E63'},
    ];

    for (var cat in defaultCategories) {
      await db.insert(tableCategories, cat);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}