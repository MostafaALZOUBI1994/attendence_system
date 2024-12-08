import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/data/leave_request_model.dart';
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
            return _buildLeaveList(state.leaveRequests);
          } else if (state is LeaveRequestFailure) {
            return _buildLeaveList(state.currentLeaves);
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Widget _buildLeaveList(List<LeaveRequest> leaves) {
    return leaves.isEmpty
        ? const Center(child: Text('No leave requests found.'))
        : ListView.builder(
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return ListTile(
          title: Text(leave.leaveType),
          subtitle: Text('${leave.startDate} to ${leave.endDate}'),
          trailing: Text(leave.reason),
        );
      },
    );
  }
}