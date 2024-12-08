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
    final path = join(dbPath, 'attendance.db'); // Use the same database file
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create the attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        status TEXT
      )
    ''');

    // Create the leave_requests table (kept intact)
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

  // Insert attendance record
  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.insert('attendance', attendance);
  }

  // Get all attendance records
  Future<List<Map<String, dynamic>>> getAttendance() async {
    final db = await database;
    return await db.query('attendance');
  }

  // Insert leave request record (kept intact)
  Future<int> insertLeaveRequest(Map<String, dynamic> request) async {
    final db = await database;
    return await db.insert('leave_requests', request);
  }

  // Get all leave request records (kept intact)
  Future<List<LeaveRequest>> getLeaveRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('leave_requests');

    return List.generate(maps.length, (i) {
      return LeaveRequest.fromJson(maps[i]);
    });
  }
}
