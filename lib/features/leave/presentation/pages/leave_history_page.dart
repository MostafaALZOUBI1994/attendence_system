import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';

class LeaveHistoryPage extends StatelessWidget {
  const LeaveHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (BlocProvider.of<LeaveBloc>(context).state is LeaveInitial) {
      BlocProvider.of<LeaveBloc>(context).add(FetchLeaves());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Leave History')),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          if (state is LeaveInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LeaveLoaded) {
            final leaves = state.leaveRequests;
            return ListView.builder(
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                final leave = leaves[index];
                return ListTile(
                  title: Text(leave.leaveType),
                  subtitle: Text('${leave.startDate} ${leave.startTime} to ${leave.endDate} ${leave.endTime}'),
                  trailing: Text(leave.reason),
                );
              },
            );
          } else if (state is LeaveRequestFailure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
