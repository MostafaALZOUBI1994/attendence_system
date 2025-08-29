import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';

class SimpleDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  /// NEW: pass the allowed date-only values (year-month-day)
  final Set<DateTime>? allowedDates;

  const SimpleDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    this.allowedDates, // NEW
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
    _dates = _generateDates(); // from allowedDates if provided
    // if selected not in allowed, default to first allowed
    if (_dates.isNotEmpty && !_dates.contains(_currentDate)) {
      _currentDate = _dates.first;
    }
    _scrollController = ScrollController(initialScrollOffset: _getInitialOffset());
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
    // fallback: original 7-day window centered on today
    final today = _dOnly(DateTime.now());
    return List.generate(7, (index) => today.subtract(const Duration(days: 3)).add(Duration(days: index)));
  }

  double _getInitialOffset() {
    final idx = _dates.indexWhere((d) => d == _currentDate);
    return (idx >= 0 ? idx : 0) * 80.0;
  }

  @override
  void didUpdateWidget(covariant SimpleDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final selectedChanged = _dOnly(widget.selectedDate) != _currentDate;
    final allowedChanged = (oldWidget.allowedDates?.length ?? 0) != (widget.allowedDates?.length ?? 0)
        || (oldWidget.allowedDates != widget.allowedDates);

    if (selectedChanged || allowedChanged) {
      _currentDate = _dOnly(widget.selectedDate);
      _dates = _generateDates();
      if (_dates.isNotEmpty && !_dates.contains(_currentDate)) {
        _currentDate = _dates.first;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_getInitialOffset());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dates.isEmpty) {
      // safety: nothing allowed
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No available days',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
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

          return Container(
            width: 80,
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
                  const SizedBox(height: 8),
                  Text(
                    "${date.day} / ${date.month}",
                    style: TextStyle(
                      fontSize: 20,
                      color: isSelected ? Colors.white : primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
