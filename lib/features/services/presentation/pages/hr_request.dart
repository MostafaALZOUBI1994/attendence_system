import 'dart:io';
import 'package:attendence_system/features/services/domain/entities/permission_types_entity.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/constants.dart';
import '../../../app_background.dart';
import '../../domain/entities/eleave_entity.dart';
import '../bloc/services_bloc.dart';
import '../widgets/date_picker.dart';
import '../widgets/time_picker.dart';

class HRRequestScreen extends StatefulWidget {
  const HRRequestScreen({Key? key}) : super(key: key);

  @override
  State<HRRequestScreen> createState() => _HRRequestScreenState();
}

class _HRRequestScreenState extends State<HRRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _attachment;
  final TextEditingController _reasonController = TextEditingController();
  bool _isLeaveRequest = true;
  String _selectedType = "";
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicesBloc, ServicesState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'Error',
              desc: message,
              btnOkOnPress: () {},
            ).show();
          },
          submissionSuccess: (message) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'Success',
              desc: message,
              btnOkOnPress: () {
                context.read<ServicesBloc>().add(const LoadData());
              },
            ).show();
          },
          submissionFailure: (message) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'Error',
              desc: message,
              btnOkOnPress: () {},
            ).show();
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
       Widget baseContent;
        if (state is LoadSuccess) {
          if (_selectedType.isEmpty && state.leaveTypes.isNotEmpty) {
            _selectedType = state.leaveTypes.first.permissionCode;
          }
          baseContent = Scaffold(
            appBar: AppBar(
              title: const Text("HR Request",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: AppBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(state.leaveBalance),
                    const SizedBox(height: 20),
                    _buildRequestToggle(),
                    const SizedBox(height: 20),
                    _buildForm(state.leaveTypes),
                  ],
                ),
              ),
            ),
          );
        } else {
        baseContent = Scaffold(
            appBar: AppBar(
              title: const Text("HR Request",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: AppBackground(
              child: Center(
                child: Text("Please wait..."),
              ),
            ),
          );
        }

        // Now, if the state is loading, we overlay a modal barrier with a CircularProgressIndicator.
        return Stack(
          children: [
            baseContent,
            if (state.maybeWhen(loading: () => true, orElse: () => false))
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }


  Widget _buildHeader(EleaveEntity leaveBalance) {
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
          const Text("Leave Balance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 12,
            percent: _calculateRemainingHours(leaveBalance),
            animation: true,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  leaveBalance.noOfHrsAvailable,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text("Monthly Allowance", style: TextStyle(color: Colors.grey)),
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
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isLeaveRequest = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLeaveRequest ? primaryColor : Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text(
              "Leave Request",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isLeaveRequest = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isLeaveRequest ? primaryColor : Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text(
              "Attendance Correction",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildForm(List<PermissionTypesEntity> leaveTypes) {
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
              _buildDropdownField(leaveTypes),
              const SizedBox(height: 20),
              _buildDateTimeRow(),
              const SizedBox(height: 20),
              _buildInputField(
                label: _isLeaveRequest ? "Reason" : "Correction Reason",
                controller: _reasonController,
                hint: "Enter your reason...",
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? "Please enter a reason" : null,
                maxLines: 3, icon: Icons.access_time_filled_rounded,
              ),
              const SizedBox(height: 20),
              _buildAttachmentSection(),
              const SizedBox(height: 20),
              _buildSubmitButton(),

            ]
          ),
        ),
      ),
    );
  }


  Widget _buildInputField({
    required String label,
    String? text,
    required IconData icon,
    VoidCallback? onTap,
    TextEditingController? controller,
    String? hint,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      readOnly: onTap != null,
      controller: controller ?? TextEditingController(text: text ?? ""),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: Icon(icon, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _buildDropdownField(List<PermissionTypesEntity> leaveTypes) {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: leaveTypes
          .map((type) => DropdownMenuItem(
        value: type.permissionCode,
        child: Text(type.permissionNameEN),
      ))
          .toList(),
      onChanged: (value) => setState(() => _selectedType = value!),
      decoration: InputDecoration(
        labelText: "Leave Type",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? "Please select a leave type" : null,
    );
  }

  Widget _buildDateTimeRow() {
    return Column(
      children: [
        SimpleDatePicker(
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SafeTimePicker(
                selectedTime: _fromTime,
                onTimeSelected: (time) => setState(() => _fromTime = time),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SafeTimePicker(
                selectedTime: _toTime,
                onTimeSelected: (time) => setState(() => _toTime = time),
              ),
            ),
          ],
        ),
      ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: const Center(
        child: Text("Submit Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final duration = _calculateDuration();

      context.read<ServicesBloc>().add(
        ServicesEvent.submitRequest(
          dateDayType: "Tomorrow",
          fromTime: _formatTimeOfDay(_fromTime),
          toTime: _formatTimeOfDay(_toTime),
          duration: duration,
          reason: _reasonController.text,
          attachment: _attachment?.path ?? "",
          eLeaveType: _selectedType,
        ),
      );
    }
  }
  String _calculateDuration() {
    double from = toDouble(_fromTime);
    double to = toDouble(_toTime);

    double durationInHours = to - from;

    int totalMinutes = (durationInHours * 60).toInt();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }
  double toDouble(TimeOfDay myTime) =>
      myTime.hour + myTime.minute / 60.0;

  double _calculateRemainingHours(EleaveEntity leaveBalance) {
    try {
      final available = _parseTimeString(leaveBalance.noOfHrsAvailable);
      final allowed = _parseTimeString(leaveBalance.noOfHrsAllowed);

      if (allowed <= 0) return 0.0;
      return (available / allowed).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0; // Handle invalid format
    }
  }
  double _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hours = double.parse(parts[0]);
    final minutes = double.parse(parts[1]) / 60.0;
    return hours + minutes;
  }
}