import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';

class SimpleDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Set<DateTime>? allowedDates;
  /// NEW: optional map of date-only → issue (“Late In” or “Early Out”)
  final Map<DateTime, String>? issues;

  const SimpleDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    this.allowedDates,
    this.issues,
  }) : super(key: key);

  @override
  _SimpleDatePickerState createState() => _SimpleDatePickerState();
}

class _SimpleDatePickerState extends State<SimpleDatePicker> {
  late DateTime _currentDate;
  late ScrollController _scrollController;
  late List<DateTime> _dates;

  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _currentDate = _dOnly(widget.selectedDate);
    _dates = _generateDates();
    // default to first allowed if current is not in list
    if (_dates.isNotEmpty && !_dates.contains(_currentDate)) {
      _currentDate = _dates.first;
    }
    _scrollController = ScrollController(
      initialScrollOffset: _getInitialOffset(),
    );
  }

  List<DateTime> _generateDates() {
    if (widget.allowedDates != null && widget.allowedDates!.isNotEmpty) {
      final list = widget.allowedDates!
          .map(_dOnly)
          .toSet()
          .toList()
        ..sort();
      return list;
    }
    // fallback: 7-day window centered on today
    final today = _dOnly(DateTime.now());
    return List.generate(
      7,
          (index) => today.subtract(const Duration(days: 3)).add(Duration(days: index)),
    );
  }

  double _getInitialOffset() {
    final idx = _dates.indexWhere((d) => d == _currentDate);
    // each card is 80 px wide, so scroll offset uses 80.0
    return (idx >= 0 ? idx : 0) * 80.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_dates.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No available days',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = date == _currentDate;

          // Look up the issue for this date (if any)
          String? issue;
          Color? issueColor;
          if (widget.issues != null) {
            final key = _dOnly(date);
            issue = widget.issues![key];
            if (issue != null) {
              if (issue == 'Late In') {
                issueColor = Colors.red.shade400;
              } else if (issue == 'Early Out') {
                issueColor = Colors.orange.shade400;
              } else {
                issueColor = Colors.green.shade400;
              }
            }
          }

          return Container(
            width: 80, // keep width consistent with scroll offset
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                setState(() => _currentDate = date);
                widget.onDateSelected(date);
                _scrollController.animateTo(
                  index * 80.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day} / ${date.month}',
                    style: TextStyle(
                      fontSize: 20,
                      color: isSelected ? Colors.white : primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (issue != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: issueColor ?? Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        issue,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
