import 'package:moet_hub/features/reports/domain/entities/report_model.dart';
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
  final DateFormat _dfShort = DateFormat('dd/MM/yyyy', 'en');
  final DateFormat _dfLong = DateFormat('EEE, MMM d, yyyy', 'en');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dispatchFetch(
        fromDate: DateTime.utc(2025, 1, 1),
        toDate: DateTime.now(),
      );
    });
  }

  // ---------------- Helpers ----------------


  void _dispatchFetch({required DateTime fromDate, required DateTime toDate}) {
    context.read<ReportBloc>().add(
      ReportEvent.fetchReport(
        fromDate: _dfShort.format(fromDate),
        toDate: _dfShort.format(toDate),
      ),
    );
  }

  DateTime _fromDateForFilter(DateTime now) {
    switch (_selectedFilter) {
      case "Last 7 Days":
        return now.subtract(const Duration(days: 7));
      case "Last 30 Days":
        return now.subtract(const Duration(days: 30));
      case "All":
      default:
        return  now.subtract(const Duration(days: 120));
    }
  }

  String _currentRangeText() {
    final now = DateTime.now();
    final from = _fromDateForFilter(now);
    return '${_dfLong.format(from)}  —  ${_dfLong.format(now)}';
  }

  Future<void> _onRefresh() async {
    final now = DateTime.now();
    _dispatchFetch(fromDate: _fromDateForFilter(now), toDate: now);
  }

  Color _statusColor(String status, String lateIn, String earlyOut) {
    final s = status.trim().toUpperCase();
    final hasLateIn = lateIn.trim().isNotEmpty;
    final hasEarlyOut = earlyOut.trim().isNotEmpty;
    if (s == 'ABSENT') return Colors.red;
    if (s == 'PRESENT' && (hasEarlyOut || hasLateIn)) return Colors.orange;
    if (s == 'PRESENT') return Colors.green;
    return Colors.grey;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _HeaderCard(
            title: 'Reports'.tr(),
            subtitle: _currentRangeText(),
            child: _buildFilterChips(),
          ),

          const SizedBox(height: 16),
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
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportLoaded) {
                  if (state.report.isEmpty) {
                    return _EmptyState(
                      message: 'No records in this period.'.tr(),
                      onRefresh: _onRefresh,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: state.report.length,
                      itemBuilder: (context, index) => _buildAttendanceCard(state.report[index]),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() => Wrap(
    alignment: WrapAlignment.center,
    spacing: 8,
    runSpacing: 8,
    children: [
      _buildChip("All", Icons.calendar_month),
      _buildChip("Last 7 Days", Icons.calendar_view_week),
      _buildChip("Last 30 Days", Icons.event),
    ],
  );

  Widget _buildChip(String label, IconData icon) {
    return ChoiceChip(
      showCheckmark: false, // ← hide the default checkmark
      avatar: Icon(
        icon,
        size: 18,
        color: _selectedFilter == label ? Colors.white : primaryColor,
      ),
      label: Text(
        label.tr(),
        style: TextStyle(
          color: _selectedFilter == label ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: _selectedFilter == label,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: _selectedFilter == label ? primaryColor : Colors.grey.shade400,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      selectedColor: primaryColor,
      backgroundColor: Colors.white,
      pressElevation: 0,
      onSelected: (selected) {
        if (!selected) return;
        setState(() => _selectedFilter = label);
        final now = DateTime.now();
        _dispatchFetch(fromDate: _fromDateForFilter(now), toDate: now);
      },
    );
  }


  Widget _buildAttendanceCard(Report record) {
    final color = _statusColor(record.status, record.lateIn, record.earlyOut);
    final dateText = _dfLong.format(record.pdate);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Cap the right chip to ~40% of the card width
        final double chipMaxWidth = constraints.maxWidth * 0.40;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            border: Border.all(color: color.withOpacity(0.25), width: 1),
          ),
          child: Stack(
            children: [
              // Accent stripe
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LEFT: date & times (wrap when tight)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: .2),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _tinyCapsule(
                                icon: Icons.login,
                                iconColor: Colors.green,
                                text: 'chkInTime'.tr(namedArgs: {'chkinTime': record.checkIn}),
                              ),
                              _tinyCapsule(
                                icon: Icons.logout,
                                iconColor: Colors.red,
                                text: 'chkOutTime'.tr(namedArgs: {'chkoutTime': record.checkOut}),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // RIGHT: status chip (capped + scales down)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: chipMaxWidth),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildStatusChip(record.status, record.lateIn, record.earlyOut),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _tinyCapsule({required IconData icon, required Color iconColor, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

        ],
      ),
    );
  }

  // -------- status chip (from your latest) --------
  Widget _buildStatusChip(String status, String lateIn, String earlyOut) {
    final s = status.trim().toUpperCase();
    final hasLateIn = lateIn.trim().isNotEmpty;
    final hasEarlyOut = earlyOut.trim().isNotEmpty;

    String mainLabel;
    String? detail;
    Color baseColor;
    IconData icon;

    if (s == 'ABSENT') {
      mainLabel = 'Absent';
      baseColor = Colors.red;
      icon = Icons.cancel_rounded;
    } else if (s == 'PRESENT') {
      if (hasEarlyOut || hasLateIn) {
        if (hasEarlyOut) {
          mainLabel = 'Early Out';
          detail = earlyOut.trim();
        } else {
          mainLabel = 'Late In';
          detail = lateIn.trim();
        }
        baseColor = Colors.orange;
        icon = Icons.access_time_filled_rounded;
      } else {
        mainLabel = 'Present';
        baseColor = Colors.green;
        icon = Icons.check_circle_rounded;
      }
    } else {
      mainLabel = status.trim().isEmpty ? 'Unknown' : status;
      baseColor = Colors.grey;
      icon = Icons.help_rounded;
    }

    final gradient = LinearGradient(
      colors: [baseColor.withOpacity(0.85), baseColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const textColor = Colors.white;

    return Tooltip(
      message: detail != null && detail!.isNotEmpty ? '$mainLabel: $detail' : mainLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColor.withOpacity(0.85), baseColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Flexible( // let title shrink first
              child: Text(
                mainLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (detail != null && detail!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 72), // small badge cap
                  child: Text(
                    detail!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );


  }
}

// ---------- small reusable widgets ----------

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + date range
          Row(
            children: [
              Icon(Icons.insights_rounded, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: child),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRefresh;

  const _EmptyState({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
