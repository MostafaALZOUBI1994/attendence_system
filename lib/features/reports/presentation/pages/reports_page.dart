import 'package:attendence_system/features/reports/domain/entities/report_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../bloc/report_bloc.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportBloc>().add(
        ReportEvent.fetchReport(
          fromDate: '01/01/2025',
          toDate: DateFormat('dd/MM/yyyy', 'en').format(DateTime.now()),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(),
              const SizedBox(height: 20),
              Expanded(
                child: BlocConsumer<ReportBloc, ReportState>(
                  listener: (context, state) {
                    if (state is ReportError) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Oops',
                        desc: state.message,
                        btnOkOnPress: () {},
                      ).show();
                    }
                  },
                  builder: (context, state) {
                    if (state is ReportLoading) {
                      return const Center(
                          child: CircularProgressIndicator());
                    } else if (state is ReportLoaded) {
                      return ListView.builder(
                        itemCount: state.report.length,
                        itemBuilder: (context, index) {
                          return _buildAttendanceCard(
                              state.report[index]);
                        },
                      );
                    }
                    // for both initial and error states, just show nothing (dialog handled above)
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


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

  Widget _buildChip(String label) {
    final formatter = DateFormat('dd/MM/yyyy', 'en');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(
          label.tr(),
          style: TextStyle(
            color: _selectedFilter == label ? Colors.white : Colors.black,
          ),
        ),
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
        onSelected: (selected) async {
          if (selected) {
            setState(() => _selectedFilter = label);
            final now = DateTime.now();
            DateTime? fromDate;
            DateTime toDate = now;

            switch (label) {
              case "All":
                fromDate = DateTime.utc(2025, 1, 1);
                break;
              case "Last 7 Days":
                fromDate = now.subtract(const Duration(days: 7));
                break;
              case "Last 30 Days":
                fromDate = now.subtract(const Duration(days: 30));
                break;
            }

            // Format dates safely
            final formattedFromDate = fromDate != null
                ? formatter.format(fromDate)
                : formatter.format(DateTime.utc(2025, 1, 1)); // Default if null

            final formattedToDate = formatter.format(toDate);

            context.read<ReportBloc>().add(
                  ReportEvent.fetchReport(
                    fromDate: formattedFromDate,
                    toDate: formattedToDate,
                  ),
                );
          }
        },
      ),
    );
  }

  Widget _buildAttendanceCard(Report record) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 5,
        color: Colors.white.withOpacity(0.8),
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
                    DateFormat('MMMM d, yyyy').format(record.pdate),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.login, color: Colors.green),
                    const SizedBox(width: 5),
                    Text('chkInTime'.tr(namedArgs: { 'chkinTime': record.checkIn}) )
                  ]),
                  Row(children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 5),
                    Text('chkOutTime'.tr(namedArgs: { 'chkoutTime': record.checkOut}) )
                  ]),
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
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
