import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';

class LeaveRequestForm extends StatefulWidget {
  @override
  _LeaveRequestFormState createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startDateTimeController = TextEditingController();
  final TextEditingController _endDateTimeController = TextEditingController();

  String? leaveType;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to close the keyboard when tapping outside
  void _closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Start from today
      firstDate: DateTime.now(), // Limit date picker to today or later
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF673AB7), // Deep Purple for date picker
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF673AB7), // Match buttons
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.deepPurple,
                accentColor: Color(0xFF673AB7),
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final DateTime fullDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Format DateTime to show only hours and minutes
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(fullDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Leave',
          style: TextStyle(color: Colors.white), // Ensure title is white
        ),
        centerTitle: true,
        elevation: 5,
        backgroundColor: const Color(0xFF673AB7),
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
      ),
      body: GestureDetector(
        onTap: _closeKeyboard, // Close keyboard on tapping outside
        child: FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShadowedBox(
                    child: DropdownButtonFormField<String>(
                      value: leaveType,
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      items: ['Sick', 'Vacation', 'Personal']
                          .map(
                            (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                          .toList(),
                      onChanged: (value) => setState(() => leaveType = value),
                      validator: (value) =>
                      value == null ? 'Please select a leave type' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildShadowedBox(
                    child: TextFormField(
                      controller: _startDateTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date & Time',
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(_startDateTimeController),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a start date & time'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildShadowedBox(
                    child: TextFormField(
                      controller: _endDateTimeController,
                      decoration: const InputDecoration(
                        labelText: 'End Date & Time',
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(_endDateTimeController),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select an end date & time'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildShadowedBox(
                    child: TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please provide a reason'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          DateTime? startDate =
                          DateTime.tryParse(_startDateTimeController.text);
                          DateTime? endDate =
                          DateTime.tryParse(_endDateTimeController.text);

                          if (startDate != null &&
                              endDate != null &&
                              startDate.isBefore(endDate)) {
                            context.read<LeaveBloc>().add(
                              RequestLeave(
                                startDate: _startDateTimeController.text,
                                endDate: _endDateTimeController.text,
                                reason: _reasonController.text,
                                leaveType: leaveType!,
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Leave request submitted')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Start date must be before the end date.')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Submit Leave',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShadowedBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
