import 'package:attendence_system/features/app_background.dart';
import 'package:attendence_system/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFilter = "All";

  final List<AttendanceRecord> _allRecords = [
    AttendanceRecord(date: DateTime(2025, 3, 1), checkIn: "08:30 AM", checkOut: "05:00 PM", status: "On Time"),
    AttendanceRecord(date: DateTime(2025, 3, 2), checkIn: "09:10 AM", checkOut: "05:15 PM", status: "Late"),
    AttendanceRecord(date: DateTime(2025, 3, 3), checkIn: "--", checkOut: "--", status: "Absent"),
  ];

  List<AttendanceRecord> get _filteredRecords {
    DateTime now = DateTime.now();
    if (_selectedFilter == "Last 7 Days") {
      return _allRecords.where((r) => r.date.isAfter(now.subtract(Duration(days: 7)))).toList();
    } else if (_selectedFilter == "Last 30 Days") {
      return _allRecords.where((r) => r.date.isAfter(now.subtract(Duration(days: 30)))).toList();
    }
    return _allRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Attendance History", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: Stack(
          children: [
            _buildBackground(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterChips(),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        return _buildAttendanceCard(_filteredRecords[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() => Stack(
    children: [
      Positioned(top: 100, left: -50, child: _buildDecorativeCircle(200, Color.fromRGBO(182, 138, 53, 0.2))),
      Positioned(bottom: -80, right: -80, child: _buildDecorativeCircle(250, Color.fromRGBO(182, 138, 53, 0.3))),
    ],
  );

  Widget _buildDecorativeCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _buildFilterChips() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildChip("All"),
      _buildChip("Last 7 Days"),
      _buildChip("Last 30 Days"),
    ],
  );

  Widget _buildChip(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: ChoiceChip(
      label: Text(label, style: TextStyle(color: _selectedFilter == label ? Colors.white : Colors.black)),
      selected: _selectedFilter == label,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: _selectedFilter == label ? Colors.white : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      selectedColor: primaryColor,
      backgroundColor: Colors.white,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = label);
        }
      },
    ),
  );

  Widget _buildAttendanceCard(AttendanceRecord record) => Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(record.date),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(children: [Icon(Icons.login, color: Colors.green), SizedBox(width: 5), Text("Check-In: ${record.checkIn}")]),
              Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 5), Text("Check-Out: ${record.checkOut}")]),
            ],
          ),
          _buildStatusChip(record.status),
        ],
      ),
    ),
  );

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case "On Time":
        color = Colors.green;
        break;
      case "Late":
        color = Colors.orange;
        break;
      case "Absent":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}

class AttendanceRecord {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String status;

  AttendanceRecord({required this.date, required this.checkIn, required this.checkOut, required this.status});
}
