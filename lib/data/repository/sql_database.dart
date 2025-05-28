import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDatabase {
  static final SqlDatabase instance = SqlDatabase._init();
  static Database? _database;

  SqlDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fast_timer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timer_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        targetSeconds INTEGER NOT NULL,
        speed REAL NOT NULL,
        remainingSeconds INTEGER NOT NULL,
        isRunning INTEGER NOT NULL,
        progress REAL NOT NULL,
        lastStartTime TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE timer_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timerId INTEGER NOT NULL,
        targetSeconds INTEGER NOT NULL,
        speed REAL NOT NULL,
        recordedSeconds INTEGER NOT NULL,
        actualSeconds INTEGER NOT NULL,
        startedAt TEXT NOT NULL,
        endedAt TEXT NOT NULL,
        FOREIGN KEY (timerId) REFERENCES timer_items(id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
