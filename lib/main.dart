import 'package:attendence_system/data/repositories/database_helper.dart';
import 'package:attendence_system/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/attendence/presentation/bloc/attendance_bloc.dart';
import 'features/leave/presentation/bloc/leave_bloc.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AttendanceBloc()),
        BlocProvider(create: (_) => LeaveBloc(DatabaseHelper.instance)),
      ],
      child: MaterialApp(
        title: 'Attendance System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:  DashboardPage(),
      ),
    );
  }
}

