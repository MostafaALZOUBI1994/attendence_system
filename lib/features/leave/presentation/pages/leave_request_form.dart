import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';

class LeaveRequestForm extends StatefulWidget {
  @override
  _LeaveRequestFormState createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? leaveType;

  // Function to show time picker
  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      controller.text = selectedTime.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Leave'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: leaveType,
                decoration: InputDecoration(labelText: 'Leave Type'),
                items: ['Sick', 'Vacation', 'Personal']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    leaveType = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a leave type' : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: 'Start Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _startDateController.text = date.toIso8601String();
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a start date'
                    : null,
              ),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(labelText: 'End Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _endDateController.text = date.toIso8601String();
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select an end date'
                    : null,
              ),
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(labelText: 'Start Time'),
                readOnly: true,
                onTap: () => _selectTime(_startTimeController),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please select a time' : null,
              ),
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(labelText: 'End Time'),
                readOnly: true,
                onTap: () => _selectTime(_endTimeController),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please select a time' : null,
              ),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(labelText: 'Reason'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please provide a reason' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Extract DateTime from the text controllers
                    DateTime? startDate = DateTime.tryParse(_startDateController.text);
                    DateTime? endDate = DateTime.tryParse(_endDateController.text);

                    if (startDate != null && endDate != null) {
                      if (startDate.isBefore(endDate)) {
                        // Dispatch the event to request leave
                        context.read<LeaveBloc>().add(
                          RequestLeave(
                            startDate: _startDateController.text,
                            endDate: _endDateController.text,
                            startTime: _startTimeController.text,
                            endTime: _endTimeController.text,
                            reason: _reasonController.text,
                            leaveType: leaveType!,
                          ),
                        );

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Leave request submitted')),
                        );
                      } else {
                        // Show error if start date is after end date
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Start date should be before end date.')),
                        );
                      }
                    } else {
                      // Handle the case where parsing failed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid date format')),
                      );
                    }
                  }
                },
                child: Text('Submit Leave'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
