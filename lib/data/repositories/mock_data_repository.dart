
import '../data/leave_request_model.dart';
import 'database_helper.dart';

class MockDataRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<void> saveLeaveRequest(LeaveRequest request) async {
    await _dbHelper.insertLeaveRequest(request.toJson());
  }

  Future<List<LeaveRequest>> getLeaveRequests() async {
    return await _dbHelper.getLeaveRequests();
  }
}
