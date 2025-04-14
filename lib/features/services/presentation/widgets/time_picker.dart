import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class SafeTimePicker extends StatefulWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const SafeTimePicker({
    Key? key,
    required this.selectedTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  _SafeTimePickerState createState() => _SafeTimePickerState();
}

class _SafeTimePickerState extends State<SafeTimePicker> {
  late TimeOfDay _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.selectedTime;
  }

  void _showTimePicker() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: primaryColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (newTime != null && mounted) {
      setState(() {
        _currentTime = newTime;
        widget.onTimeSelected(newTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              _currentTime.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}