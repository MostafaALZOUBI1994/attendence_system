import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data/leave_request_model.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leave_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        leaveType TEXT,
        startDate TEXT,
        endDate TEXT,
        reason TEXT,
        status TEXT
      )
    ''');
  }

  Future<int> insertLeaveRequest(Map<String, dynamic> request) async {
    final db = await database;
    return await db.insert('leave_requests', request);
  }

  Future<List<LeaveRequest>> getLeaveRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('leave_requests');

    return List.generate(maps.length, (i) {
      return LeaveRequest.fromJson(maps[i]);
    });
  }
}
