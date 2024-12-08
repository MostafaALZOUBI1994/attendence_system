import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        title: const Text('Leave History',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: const Color(0xFF673AB7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
    if (leaves.isEmpty) {
      return const Center(
        child: Text(
          'No leave requests found.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: leaves.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return _buildAnimatedCard(context, leave, index);
      },
    );
  }

  Widget _buildAnimatedCard(BuildContext context, LeaveRequest leave, int index) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), // Slide from below
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF673AB7),
                child: Text(
                  leave.leaveType[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.leaveType,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(leave.startDate)} to ${_formatDate(leave.endDate)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.reason,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('MMM dd, yyyy').format(parsedDate);
  }
}
