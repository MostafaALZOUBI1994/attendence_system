import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../attendence/presentation/pages/attendance_page.dart';
import '../../../leave/presentation/bloc/leave_bloc.dart';
import '../../../leave/presentation/bloc/leave_event.dart';
import '../../../leave/presentation/bloc/leave_state.dart';
import '../../../leave/presentation/pages/leave_request_form.dart';
import '../../../leave/presentation/pages/leave_history_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF673AB7);
  int totalLeaveDays = 0;
  late AnimationController _controller;
  late Animation<double> _pieChartAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pieChartAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 25),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 25, end: 50),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 50, end: 75),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 75, end: 100),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _cardsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
    context.read<LeaveBloc>().add(FetchLeaves());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appTitle, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          if (state is LeaveLoaded) {
            totalLeaveDays = state.leaveRequests
                .map((leave) => DateTimeRange(
              start: DateTime.parse(leave.startDate),
              end: DateTime.parse(leave.endDate),
            ).duration.inDays + 1)
                .reduce((a, b) => a + b);
          } else if (state is LeaveRequestFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
            totalLeaveDays = state.currentLeaves
                .map((leave) => DateTimeRange(
              start: DateTime.parse(leave.startDate),
              end: DateTime.parse(leave.endDate),
            ).duration.inDays + 1)
                .fold(0, (a, b) => a + b);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(seconds: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.welcomeMessage,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${Strings.todayLabel} ${DateFormat('EEE, MMM d').format(DateTime.now())}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.5),
                    end: Offset.zero,
                  ).animate(_cardsAnimation),
                  child: FadeTransition(
                    opacity: _cardsAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryCard(
                          title: Strings.daysWorkedTitle,
                          value: "22",
                          color: Colors.green,
                        ),
                        _buildSummaryCard(
                          title: Strings.leaveBalanceTitle,
                          value: (30 - totalLeaveDays).toString(),
                          color: Colors.blue,
                        ),
                        _buildSummaryCard(
                          title: Strings.pendingRequestsTitle,
                          value: "2",
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  Strings.attendanceOverviewTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Center(
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(_cardsAnimation),
                    child: AnimatedBuilder(
                      animation: _pieChartAnimation,
                      builder: (context, child) {
                        final workedDaysPercentage = ((300 - totalLeaveDays) / 300) * 100;
                        final leaveDaysPercentage = (totalLeaveDays / 300) * 100;

                        final animatedWorkedValue = (workedDaysPercentage * _pieChartAnimation.value) / 100;
                        final animatedLeaveValue = (leaveDaysPercentage * _pieChartAnimation.value) / 100;

                        return SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sections: [
                                    PieChartSectionData(
                                      value: animatedWorkedValue,
                                      color: Colors.blue,
                                      radius: 50,
                                      title: '',
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: animatedLeaveValue,
                                      color: Colors.orange,
                                      radius: 50,
                                      title: '',
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 100 - (animatedWorkedValue + animatedLeaveValue),
                                      color: Colors.grey.withOpacity(0.2),
                                      radius: 50,
                                      title: '',
                                      showTitle: false,
                                    ),
                                  ],
                                  centerSpaceRadius: 60,
                                  sectionsSpace: 4,
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Present\n${(workedDaysPercentage * (_pieChartAnimation.value / 100)).toStringAsFixed(1)}%',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Leave\n${(leaveDaysPercentage * (_pieChartAnimation.value / 100)).toStringAsFixed(1)}%',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  Strings.quickActionsTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      icon: Icons.check_circle_outline,
                      label: Strings.markAttendanceLabel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AttendancePage()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.calendar_today,
                      label: Strings.requestLeaveLabel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LeaveRequestForm()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.history,
                      label: Strings.leaveHistoryLabel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LeaveHistoryPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        width: 110,
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeOut,
              tween: Tween(begin: 0, end: double.parse(value)),
              builder: (context, value, child) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 24,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryColor,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}