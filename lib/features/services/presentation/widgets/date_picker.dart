import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';

class SimpleDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const SimpleDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _SimpleDatePickerState createState() => _SimpleDatePickerState();
}

class _SimpleDatePickerState extends State<SimpleDatePicker> {
  late DateTime _currentDate;
  late ScrollController _scrollController;
  late List<DateTime> _dates;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
    _dates = _generateDates();
    _scrollController = ScrollController(initialScrollOffset: _getInitialOffset());
  }

  List<DateTime> _generateDates() {
    return List.generate(7, (index) {
      return _today.subtract(Duration(days: 3)).add(Duration(days: index));
    });
  }

  double _getInitialOffset() {
    int selectedIndex = _dates.indexWhere((date) =>
    date.year == _currentDate.year &&
        date.month == _currentDate.month &&
        date.day == _currentDate.day
    );
    return selectedIndex * 80.0;
  }

  @override
  void didUpdateWidget(SimpleDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _currentDate = widget.selectedDate;
      _dates = _generateDates();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_getInitialOffset());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          DateTime date = _dates[index];
          bool isSelected = date == _currentDate;
          bool isWithinRange = date.isAfter(_today.subtract(Duration(days: 3))) &&
              date.isBefore(_today.add(Duration(days: 4)));

          return Opacity(
            opacity: isWithinRange ? 1.0 : 0.3,
            child: IgnorePointer(
              ignoring: !isWithinRange,
              child: Container(
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
                    if (isWithinRange) {
                      setState(() {
                        _currentDate = date;
                        widget.onDateSelected(date);
                      });
                      _scrollController.animateTo(
                        index * 80.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
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
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: isSelected ? Colors.white : primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
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