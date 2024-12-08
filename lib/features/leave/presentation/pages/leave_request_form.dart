import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';

class LeaveRequestForm extends StatefulWidget {
  @override
  _LeaveRequestFormState createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startDateTimeController = TextEditingController();
  final TextEditingController _endDateTimeController = TextEditingController();

  String? leaveType;

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateTimeController.dispose();
    _endDateTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime fullDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(fullDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveRequestFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        } else if (state is LeaveLoaded) {
          Navigator.pop(context); // Close form after successful request
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.requestLeaveTitle, style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF673AB7),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildShadowedBox(
                    child: DropdownButtonFormField<String>(
                      value: leaveType,
                      decoration: const InputDecoration(
                        labelText: Strings.leaveTypeLabel,
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      items: ['Sick', 'Vacation', 'Personal']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(() => leaveType = value),
                      validator: (value) =>
                      value == null ? Strings.selectLeaveTypeError : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildShadowedBox(
                    child: TextFormField(
                      controller: _startDateTimeController,
                      readOnly: true,
                      onTap: () => _selectDateTime(_startDateTimeController),
                      decoration: const InputDecoration(
                        labelText: Strings.startDateTimeLabel,
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? Strings.selectStartDateTimeError : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildShadowedBox(
                    child: TextFormField(
                      controller: _endDateTimeController,
                      readOnly: true,
                      onTap: () => _selectDateTime(_endDateTimeController),
                      decoration: const InputDecoration(
                        labelText: Strings.endDateTimeLabel,
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? Strings.selectEndDateTimeError : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildShadowedBox(
                    child: TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: Strings.reasonLabel,
                        labelStyle: TextStyle(color: Color(0xFF673AB7)),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? Strings.provideReasonError : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        DateTime? startDate = DateTime.tryParse(_startDateTimeController.text);
                        DateTime? endDate = DateTime.tryParse(_endDateTimeController.text);

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
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(Strings.startBeforeEndDateError)),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      Strings.submitLeaveButton,
                      style: TextStyle(fontSize: 18, color: Colors.white),
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

