import 'dart:io';
import 'package:attendence_system/features/services/domain/entities/permission_types_entity.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/injection.dart';
import '../../../../core/local_services/local_services.dart';
import '../../domain/entities/eleave_entity.dart';
import '../bloc/services_bloc.dart';
import '../widgets/date_picker.dart';
import '../widgets/time_picker.dart';

class BaseScreen extends StatelessWidget {
  final String titleKey;
  final Widget child;

  const BaseScreen({
    Key? key,
    required this.titleKey,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/c1.png',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.7)),
            Container(color: Colors.white.withOpacity(0.25)),
            Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(titleKey.tr(), style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: SafeArea(
                top: true,
                bottom: false,
                child: child,
              ),
            ),
          ],
        ),
        // loading overlay
        BlocSelector<ServicesBloc, ServicesState, bool>(
          selector: (state) => state.maybeWhen(loading: () => true, orElse: () => false),
          builder: (context, isLoading) {
            if (!isLoading) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ],
    );
  }
}

class HRRequestScreen extends StatefulWidget {
  const HRRequestScreen({Key? key}) : super(key: key);

  @override
  State<HRRequestScreen> createState() => _HRRequestScreenState();
}

class _HRRequestScreenState extends State<HRRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  File? _attachment;
  bool _isLeaveRequest = true;
  String _selectedType = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      titleKey: 'hrReq',
      child: BlocConsumer<ServicesBloc, ServicesState>(
        listener: _blocListener,
        builder: (context, state) {
          if (state is LoadSuccess) {
            _initSelectedType(state.leaveTypes);
            return SingleChildScrollView(
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
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _blocListener(BuildContext context, ServicesState state) {
    state.maybeWhen(
      error: (msg) => _showDialog(context, DialogType.error, 'oops', msg),
      submissionSuccess: (msg) => _showDialog(
        context,
        DialogType.success,
        'success',
        msg,
        onOk: () => context.read<ServicesBloc>().add(const LoadData()),
      ),
      submissionFailure: (msg) => _showDialog(context, DialogType.error, 'oops', msg),
      orElse: () {},
    );
  }

  void _showDialog(
      BuildContext ctx,
      DialogType type,
      String titleKey,
      String desc, {
        VoidCallback? onOk,
      }) {
    AwesomeDialog(
      context: ctx,
      dialogType: type,
      animType: AnimType.rightSlide,
      title: titleKey.tr(),
      desc: desc,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  void _initSelectedType(List<PermissionTypesEntity> types) {
    if (_selectedType.isEmpty && types.isNotEmpty) {
      _selectedType = types.first.permissionCode;
    }
  }

  Widget _buildHeader(EleaveEntity leaveBalance) {
    final percent = _calculateRemainingHours(leaveBalance);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Text('levBal'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 12,
            percent: percent,
            animation: true,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(leaveBalance.noOfHrsAvailable, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildRequestToggle() => Row(
    children: [
      _toggleButton('levReq', true),
      const SizedBox(width: 8),
      _toggleButton('attCorr', false),
    ],
  );

  Expanded _toggleButton(String key, bool value) => Expanded(
    child: ElevatedButton(
      onPressed: () => setState(() => _isLeaveRequest = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isLeaveRequest == value ? primaryColor : Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(key.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildForm(List<PermissionTypesEntity> types) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 4,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildDropdownField(types),
          const SizedBox(height: 20),
          _buildDateTimeRow(),
          const SizedBox(height: 20),
          _buildInputField(
            label: _isLeaveRequest ? 'res'.tr() : 'crrRes'.tr(),
            controller: _reasonController,
            hint: 'entRes'.tr(),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'plsEntRes'.tr() : null,
            icon: Icons.access_time_filled_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _buildAttachmentSection(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ]),
      ),
    ),
  );

  Widget _buildInputField({
    required String label,
    String? text,
    required IconData icon,
    VoidCallback? onTap,
    TextEditingController? controller,
    String? hint,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) => TextFormField(
    readOnly: onTap != null,
    controller: controller ?? TextEditingController(text: text),
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

  Widget _buildDropdownField(List<PermissionTypesEntity> types) {
    final locale = getIt<LocalService>().getSavedLocale().languageCode;
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: types.map((t) {
        final name = locale == 'ar' ? t.permissionNameAR : t.permissionNameEN;
        return DropdownMenuItem(value: t.permissionCode, child: Text(name));
      }).toList(),
      onChanged: (v) => setState(() => _selectedType = v!),
      decoration: InputDecoration(
        labelText: 'levType'.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'plsSelectType'.tr() : null,
    );
  }

  Widget _buildDateTimeRow() => Column(
    children: [
      SimpleDatePicker(
        selectedDate: _selectedDate,
        onDateSelected: (d) => setState(() => _selectedDate = d),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: SafeTimePicker(selectedTime: _fromTime, onTimeSelected: (t) => setState(() => _fromTime = t)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SafeTimePicker(selectedTime: _toTime, onTimeSelected: (t) => setState(() => _toTime = t)),
          ),
        ],
      ),
    ],
  );

  Widget _buildAttachmentSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('attachments'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickAttachment,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: primaryColor), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _attachment?.path.split('/').last ?? 'noFileChs'.tr(),
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

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _attachment = File(picked.path));
  }

  Widget _buildSubmitButton() => ElevatedButton(
    onPressed: _submitForm,
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    child: Center(child: Text('subReq'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
  );

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final dur = _formatDuration();
    context.read<ServicesBloc>().add(
      ServicesEvent.submitRequest(
        dateDayType: 'Tomorrow',
        fromTime: _formatTimeOfDay(_fromTime),
        toTime: _formatTimeOfDay(_toTime),
        duration: dur,
        reason: _reasonController.text,
        attachment: _attachment?.path ?? '',
        eLeaveType: _selectedType,
      ),
    );
  }

  String _formatDuration() {
    final diff = toDouble(_toTime) - toDouble(_fromTime);
    final totalMin = (diff * 60).toInt();
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '\$hour:\$minute \$period';
  }

  double toDouble(TimeOfDay t) => t.hour + t.minute / 60.0;

  double _calculateRemainingHours(EleaveEntity lb) {
    try {
      final av = _parseTime(lb.noOfHrsAvailable);
      final al = _parseTime(lb.noOfHrsAllowed);
      return al <= 0 ? 0 : (av / al).clamp(0, 1);
    } catch (_) {
      return 0;
    }
  }

  double _parseTime(String s) {
    final p = s.split(':');
    return double.parse(p[0]) + double.parse(p[1]) / 60;
  }
}
