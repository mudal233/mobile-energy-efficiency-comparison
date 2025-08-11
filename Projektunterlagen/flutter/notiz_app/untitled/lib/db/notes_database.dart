import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      content TEXT,
      category TEXT,
      created_at TEXT
    )
    ''');
  }

  Future<void> insertNote(Note note) async {
    final db = await instance.database;
    await db.insert('notes', note.toMap());
  }

  Future<List<Note>> fetchAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'created_at DESC');
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<void> deleteAllNotes() async {
    final db = await instance.database;
    await db.delete('notes');
  }

  Future<void> deleteNotesByCategory(String category) async {
    final db = await instance.database;
    await db.delete('notes', where: 'category = ?', whereArgs: [category]);
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<Map<String, int>> getCategoryStats() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as count FROM notes GROUP BY category
    ''');

    return {
      for (var row in result)
        row['category'] as String: row['count'] as int,
    };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  Future<int> updateNoteByTitle(String title, String newContent, String newCategory) async {
    final db = await instance.database;

    return await db.update(
      'notes',
      {
        'content': newContent,
        'category': newCategory,
      },
      where: 'title = ?',
      whereArgs: [title],
    );
  }

}
