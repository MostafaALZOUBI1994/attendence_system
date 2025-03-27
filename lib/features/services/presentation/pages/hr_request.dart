import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/constants.dart';
import '../../../app_background.dart';

class HRRequestScreen extends StatefulWidget {
  const HRRequestScreen({super.key});

  @override
  State<HRRequestScreen> createState() => _HRRequestScreenState();
}

class _HRRequestScreenState extends State<HRRequestScreen> {

  final _formKey = GlobalKey<FormState>();
  File? _attachment;

  final List<String> _leaveTypes = [
    "Private",
    "Official Work",
    "Fog Permission",
    "Sick Permission",
    "School Meeting",
    "Training"
  ];
  String _selectedType = "Private";
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _correctionDateController = TextEditingController();
  final TextEditingController _correctedTimeController = TextEditingController();
  final TextEditingController _correctionReasonController = TextEditingController();

  bool _isLeaveRequest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HR Request", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildRequestToggle(),
              const SizedBox(height: 20),
              _isLeaveRequest ? _buildLeaveRequestForm() : _buildAttendanceCorrectionForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Leave Balance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 12,
            percent: 0.8,
            animation: true,
            center: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "5 hrs",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Monthly Allowance", style: TextStyle(color: Colors.grey)),
              ],
            ),
            progressColor: primaryColor,
            backgroundColor: Colors.grey.shade300,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _isLeaveRequest = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLeaveRequest ? primaryColor : Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            "Leave Request",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _isLeaveRequest = false),
          style: ElevatedButton.styleFrom(
            backgroundColor: !_isLeaveRequest ? primaryColor : Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            "Attendance Correction",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveRequestForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(),
              const SizedBox(height: 20),
              _buildDateTimeRow(),
              const SizedBox(height: 20),
              _buildReasonField(),
              const SizedBox(height: 20),
              _buildAttachmentSection(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCorrectionForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCorrectionDateField(),
              const SizedBox(height: 20),
              _buildCorrectedTimeField(),
              const SizedBox(height: 20),
              _buildCorrectionReasonField(),
              const SizedBox(height: 20),
              _buildAttachmentSection(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: _leaveTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) => setState(() => _selectedType = value!),
      decoration: InputDecoration(
        labelText: "Leave Type",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(child: _buildDateField()),
        const SizedBox(width: 10),
        Expanded(child: _buildTimeField("From", _fromTime, (time) => setState(() => _fromTime = time))),
        const SizedBox(width: 10),
        Expanded(child: _buildTimeField("To", _toTime, (time) => setState(() => _toTime = time))),
      ],
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Date",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.calendar_today, color: primaryColor),
      ),
      controller: TextEditingController(text: DateFormat.yMd().format(_selectedDate)),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time, Function(TimeOfDay) onTimeSelected) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.access_time, color: primaryColor),
      ),
      controller: TextEditingController(text: time.format(context)),
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selectedTime != null) onTimeSelected(selectedTime);
      },
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Reason",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: "Enter your reason...",
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter a reason" : null,
    );
  }

  Widget _buildCorrectionDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Correction Date",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.calendar_today, color: primaryColor),
      ),
      controller: _correctionDateController,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _correctionDateController.text = DateFormat.yMd().format(date));
        }
      },
    );
  }

  Widget _buildCorrectedTimeField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Corrected Time",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.access_time, color: primaryColor),
      ),
      controller: _correctedTimeController,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _correctedTimeController.text = time.format(context));
        }
      },
    );
  }

  Widget _buildCorrectionReasonField() {
    return TextFormField(
      controller: _correctionReasonController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Reason for Correction",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: "Enter the reason for correction...",
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter a reason" : null,
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Attachments", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickAttachment,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _attachment?.path.split('/').last ?? "No file chosen",
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.attach_file, color: primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _attachment = File(pickedFile.path));
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Center(
        child: Text(
          "Submit Request",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: Text(_isLeaveRequest ? "Your leave request has been submitted" : "Your attendance correction request has been submitted"),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}