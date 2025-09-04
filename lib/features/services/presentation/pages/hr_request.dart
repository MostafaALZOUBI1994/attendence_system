import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // BackdropFilter

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/injection.dart';
import '../../../../core/local_services/local_services.dart';

// Reports (for allowed dates and auto-fill)
import '../../../reports/domain/entities/report_model.dart';
import '../../../reports/presentation/bloc/report_bloc.dart';

// Services (existing)
import '../../domain/entities/eleave_entity.dart';
import '../../domain/entities/permission_types_entity.dart';
import '../bloc/services_bloc.dart';
import '../widgets/date_picker.dart'; // <- SimpleDatePicker (updated in next file)
import '../widgets/time_picker.dart';
import 'base_screen.dart';

class HRRequestScreen extends StatefulWidget {
  const HRRequestScreen({Key? key}) : super(key: key);

  @override
  State<HRRequestScreen> createState() => _HRRequestScreenState();
}

class _HRRequestScreenState extends State<HRRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  File? _attachment;

  bool _isLeaveRequest = true;
  String _selectedType = '';

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  late AnimationController _bgAnim;
  late Animation<double> _waveAnim;

  @override
  void initState() {
    super.initState();
    _bgAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat(reverse: true);
    _waveAnim = CurvedAnimation(parent: _bgAnim, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      titleKey: 'hrReq',
      child: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _waveAnim,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0, -1 + _waveAnim.value * 0.2),
                    end: Alignment(0, 1 - _waveAnim.value * 0.2),
                    colors: [
                      primaryColor.withOpacity(0.12),
                      primaryColor.withOpacity(0.04),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              );
            },
          ),

          BlocConsumer<ServicesBloc, ServicesState>(
            listener: _blocListener,
            builder: (context, state) {
              if (state is LoadSuccess) {
                _initSelectedType(state.leaveTypes);
                final percent = _calculateRemainingHours(state.leaveBalance);
                final duration = _formatDuration();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          children: [
                            _GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: _Header(
                                leaveBalance: state.leaveBalance,
                                percent: percent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _GlassCard(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 10),
                              child: _buildRequestToggle(),
                            ),
                            const SizedBox(height: 16),
                            _GlassCard(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 18, 16, 10),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionTitle('levType'.tr()),
                                    const SizedBox(height: 8),
                                    _LeaveTypeChips(
                                      types: state.leaveTypes,
                                      selected: _selectedType,
                                      onSelected: (v) =>
                                          setState(() => _selectedType = v),
                                    ),
                                    const SizedBox(height: 16),
                                    _SectionTitle('date'.tr()),
                                    const SizedBox(height: 8),
                                    BlocBuilder<ReportBloc, ReportState>(
                                      builder: (context, reportState) {
                                        final isLoaded =
                                            reportState is ReportLoaded;
                                        return _DateCard(
                                          date: _selectedDate,
                                          onTap: isLoaded
                                              ? () async {
                                                  await _pickDate(
                                                    initial: _selectedDate,
                                                    onPicked: (d) => setState(
                                                        () =>
                                                            _selectedDate = d),
                                                  );
                                                }
                                              : () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Report data is loading...')),
                                                  );
                                                },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _SectionTitle('time'.tr()),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _TimeCard(
                                            label: 'from'.tr(),
                                            time: _fromTime,
                                            onTap: () async {
                                              await _pickTime(
                                                initial: _fromTime,
                                                onPicked: (t) => setState(
                                                    () => _fromTime = t),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _TimeCard(
                                            label: 'to'.tr(),
                                            time: _toTime,
                                            onTap: () async {
                                              await _pickTime(
                                                initial: _toTime,
                                                onPicked: (t) =>
                                                    setState(() => _toTime = t),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _DurationPill(duration: duration),
                                    const SizedBox(height: 18),
                                    _SectionTitle(_isLeaveRequest
                                        ? 'res'.tr()
                                        : 'crrRes'.tr()),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _reasonController,
                                      maxLines: 4,
                                      textInputAction: TextInputAction.newline,
                                      decoration: _inputDecoration(
                                        hint: 'entRes'.tr(),
                                        icon: Icons.edit_rounded,
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'plsEntRes'.tr()
                                              : null,
                                    ),
                                    const SizedBox(height: 18),
                                    _SectionTitle('attachments'.tr()),
                                    const SizedBox(height: 8),
                                    _attachment == null
                                        ? _AttachmentDrop(
                                            onPick: _pickAttachment)
                                        : _AttachmentPreview(
                                            file: _attachment!,
                                            onRemove: () => setState(
                                                () => _attachment = null),
                                          ),
                                    const SizedBox(height: 14),
                                    _SubtleDivider(),
                                    const SizedBox(height: 8),
                                    _TinyTips(
                                      text: _isLeaveRequest
                                          ? '• ${'levType'.tr()}  • ${'date'.tr()}  • ${'time'.tr()}  • ${'res'.tr()}'
                                          : '• ${'attCorr'.tr()}  • ${'date'.tr()}  • ${'time'.tr()}  • ${'crrRes'.tr()}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 110), // space for CTA
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),

          // Sticky submit bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _GlassCard(
                  blur: 16,
                  color: Colors.white.withOpacity(0.7),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PrimaryCTA(
                          label: 'subReq'.tr(),
                          onTap: _submitForm,
                          icon: Icons.send_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SecondaryIconBtn(
                        tooltip: 'attachments'.tr(),
                        icon: Icons.attach_file_rounded,
                        onTap: _pickAttachment,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Logic / helpers ----------

  void _blocListener(BuildContext context, ServicesState state) {
    state.maybeWhen(
      error: (msg) => _dialog(context, DialogType.error, 'oops', msg),
      submissionSuccess: (msg) => _dialog(
        context,
        DialogType.success,
        'success',
        msg,
        onOk: () => context.read<ServicesBloc>().add(const LoadData()),
      ),
      submissionFailure: (msg) =>
          _dialog(context, DialogType.error, 'oops', msg),
      orElse: () {},
    );
  }

  void _dialog(
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

  // ---- Allowed dates from ReportBloc.filteredReport & date-only utility
  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Set<DateTime> _allowedDatesFromFiltered() {
    final st = context.read<ReportBloc>().state; // non-listening
    final filtered = st.whenOrNull(
          loaded: (report, filteredReport) => filteredReport,
        ) ??
        const <Report>[];
    return filtered.map((r) => _dOnly(r.pdate)).toSet();
  }

  // ---- Parse and time math helpers
  TimeOfDay _parseHHmm(String s) {
    if (s.isEmpty) return const TimeOfDay(hour: 0, minute: 0);
    final parts = s.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  Duration _parseDurHHmm(String s) {
    if (s.isEmpty) return Duration.zero;
    final parts = s.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return Duration(hours: h, minutes: m);
  }

  TimeOfDay _addTOD(TimeOfDay t, Duration d) {
    final total = t.hour * 60 + t.minute + d.inMinutes;
    final norm = ((total % (24 * 60)) + (24 * 60)) % (24 * 60);
    return TimeOfDay(hour: norm ~/ 60, minute: norm % 60);
  }

  TimeOfDay _subTOD(TimeOfDay t, Duration d) => _addTOD(t, -d);

  Report? _findReportFor(DateTime date) {
    final st = context.read<ReportBloc>().state; // non-listening
    final list =
        st.whenOrNull(loaded: (all, filtered) => all) ?? const <Report>[];
    final day = _dOnly(date);
    for (final r in list) {
      if (_dOnly(r.pdate) == day) return r;
    }
    return null;
  }

  Future<void> _applyAutoTimesForDate(DateTime date) async {
    final rep = _findReportFor(date);
    if (rep == null) return;

    final lateStr = rep.lateIn.trim();
    final earlyStr = rep.earlyOut.trim();
    final hasLate = lateStr.isNotEmpty && lateStr != '00:00';
    final hasEarly = earlyStr.isNotEmpty && earlyStr != '00:00';

    final checkIn = _parseHHmm(rep.checkIn);
    final checkOut = _parseHHmm(rep.checkOut);
    final lateDur = _parseDurHHmm(lateStr);
    final earlyDur = _parseDurHHmm(earlyStr);

    Future<void> useLateIn() async {
      setState(() {
        _fromTime = _subTOD(checkIn, lateDur);
        _toTime = checkIn;
      });
    }

    Future<void> useEarlyOut() async {
      setState(() {
        _fromTime = checkOut;
        _toTime = _addTOD(checkOut, earlyDur);
      });
    }

    if (hasLate && hasEarly) {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _BottomSheetWrap(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.login_rounded),
                title: Text('Use Late In ($lateStr)'),
                onTap: () {
                  Navigator.pop(context);
                  useLateIn();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text('Use Early Out ($earlyStr)'),
                onTap: () {
                  Navigator.pop(context);
                  useEarlyOut();
                },
              ),
            ],
          ),
        ),
      );
    } else if (hasEarly) {
      await useEarlyOut();
    } else if (hasLate) {
      await useLateIn();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No late/early data for this day.'.tr())),
      );
    }
  }

  // ---- Open date bottom sheet with allowedDates
  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final allowed = _allowedDatesFromFiltered();
    if (allowed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No days with late/early found.'.tr())),
      );
      return;
    }

    final init = allowed.contains(_dOnly(initial)) ? initial : allowed.first;

    // Build a date→issue map (“Late In” / “Early Out”) from filtered reports
    Map<DateTime, String> _issuesFromFiltered() {
      final st = context.read<ReportBloc>().state;
      final filtered = st.whenOrNull(
        loaded: (report, filteredReport) => filteredReport,
      ) ??
          const <Report>[];
      final map = <DateTime, String>{};
      for (final rep in filtered) {
        final day = DateTime(rep.pdate.year, rep.pdate.month, rep.pdate.day);
        final lateStr = rep.lateIn.trim();
        final earlyStr = rep.earlyOut.trim();
        final hasLate = lateStr.isNotEmpty && lateStr != '00:00';
        final hasEarly = earlyStr.isNotEmpty && earlyStr != '00:00';
        if (hasLate) {
          map[day] = 'Late In';
        } else if (hasEarly) {
          map[day] = 'Early Out';
        }
      }
      return map;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomSheetWrap(
        child: SimpleDatePicker(
          selectedDate: init,
          allowedDates: allowed,
          issues: _issuesFromFiltered(), // pass in the issues map
          onDateSelected: (d) async {
            await _applyAutoTimesForDate(d); // auto-fill times based on issue
            onPicked(d);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }


  void _initSelectedType(List<PermissionTypesEntity> types) {
    if (_selectedType.isEmpty && types.isNotEmpty) {
      _selectedType = types.first.permissionCode;
    }
  }

  Widget _buildRequestToggle() {
    return LayoutBuilder(
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: _SegmentBtn(
                icon: Icons.beach_access_rounded,
                label: 'levReq'.tr(),
                selected: _isLeaveRequest,
                onTap: () => setState(() => _isLeaveRequest = true),
              ),
            ),
            // const SizedBox(width: 8),
            // Expanded(
            //   child: _SegmentBtn(
            //     icon: Icons.edit_calendar_rounded,
            //     label: 'attCorr'.tr(),
            //     selected: !_isLeaveRequest,
            //     onTap: () => setState(() => _isLeaveRequest = false),
            //   ),
            // ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.75),
      suffixIcon: Icon(icon, color: primaryColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _attachment = File(picked.path));
  }

  Future<void> _pickTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomSheetWrap(
        child: SafeTimePicker(
          selectedTime: initial,
          onTimeSelected: (t) {
            onPicked(t);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final dur = _formatDuration();
    final attachmentB64 = await _fileToBase64(_attachment);
    final date = DateFormat('dd/MM/yyyy', 'en').format(_selectedDate);

    context.read<ServicesBloc>().add(
          ServicesEvent.submitRequest(
            dateDayType: date,
            fromTime: _formatTimeOfDay(_fromTime),
            toTime: _formatTimeOfDay(_toTime),
            duration: dur,
            reason: _reasonController.text,
            attachment: attachmentB64 ?? '',
            eLeaveType: _selectedType,
          ),
        );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDuration() {
    final fm = _fromTime.hour * 60 + _fromTime.minute;
    final tm = _toTime.hour * 60 + _toTime.minute;
    int diff = tm - fm;
    if (diff < 0) diff += 24 * 60;
    final h = (diff ~/ 60).toString().padLeft(2, '0');
    final m = (diff % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<String?> _fileToBase64(File? f) async {
    if (f == null) return null;
    final bytes = await f.readAsBytes();
    return base64Encode(bytes);
  }

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

// ----------------------- UI atoms & pieces -----------------------

class _Header extends StatelessWidget {
  const _Header({required this.leaveBalance, required this.percent});

  final EleaveEntity leaveBalance;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Align(
                alignment: Alignment.topRight,
                child:
                    Icon(Icons.blur_on_rounded, size: 120, color: primaryColor),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('levBal'.tr(),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _LegendDot(color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                          '${'available'.tr()}: ${leaveBalance.noOfHrsAvailable}',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _LegendDot(color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text(
                        '${'allowed'.tr()}: ${leaveBalance.noOfHrsAllowed}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircularPercentIndicator(
              radius: 72,
              lineWidth: 10,
              percent: percent,
              animation: true,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    leaveBalance.noOfHrsAvailable,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('hrs'.tr(),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: Colors.grey[600])),
                ],
              ),
              progressColor: primaryColor,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ],
    );
  }
}

class _SegmentBtn extends StatelessWidget {
  const _SegmentBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? primaryColor : Colors.white.withOpacity(0.7);
    final fg = selected ? Colors.white : Colors.black87;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: selected ? primaryColor : Colors.grey.shade300),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveTypeChips extends StatelessWidget {
  const _LeaveTypeChips({
    required this.types,
    required this.selected,
    required this.onSelected,
  });

  final List<PermissionTypesEntity> types;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = getIt<LocalService>().getSavedLocale().languageCode;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in types)
          ChoiceChip(
            label:
                Text(locale == 'ar' ? t.permissionNameAR : t.permissionNameEN),
            selected: selected == t.permissionCode,
            onSelected: (_) => onSelected(t.permissionCode),
            selectedColor: primaryColor.withOpacity(0.15),
            labelStyle: TextStyle(
              color: selected == t.permissionCode ? primaryColor : null,
              fontWeight: selected == t.permissionCode
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: selected == t.permissionCode
                      ? primaryColor
                      : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = DateFormat('EEE, dd MMM yyyy').format(date);
    return _PillButton(icon: Icons.event_rounded, label: d, onTap: onTap);
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard(
      {required this.label, required this.time, required this.onTap});

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = time.format(context);
    return _PillButton(icon: Icons.schedule_rounded, label: '$t', onTap: onTap);
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
              const Icon(Icons.chevron_right_rounded, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill({required this.duration});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timelapse_rounded, color: Colors.black87),
          const SizedBox(width: 8),
          Text('${'duration'.tr()}: $duration',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        ],
      ),
    );
  }
}

class _AttachmentDrop extends StatelessWidget {
  const _AttachmentDrop({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return DottedBorderContainer(
      onTap: onPick,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_upload_rounded, size: 32),
          const SizedBox(height: 8),
          Text('noFileChs'.tr(),
              style: TextStyle(
                  color: Colors.grey[700], fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('attachments'.tr(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          AspectRatio(
              aspectRatio: 16 / 9, child: Image.file(file, fit: BoxFit.cover)),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white.withOpacity(0.85),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close_rounded, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedBorderContainer extends StatelessWidget {
  const DottedBorderContainer({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade400, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PrimaryCTA extends StatelessWidget {
  const _PrimaryCTA({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon ?? Icons.send_rounded),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _SecondaryIconBtn extends StatelessWidget {
  const _SecondaryIconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.attach_file_rounded, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding,
    this.blur = 12,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _BottomSheetWrap extends StatelessWidget {
  const _BottomSheetWrap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      blur: 20,
      color: Colors.white.withOpacity(0.95),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: child,
    );
  }
}

class _TinyTips extends StatelessWidget {
  const _TinyTips({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 12, color: Colors.grey[600], letterSpacing: 0.2));
  }
}

class _SubtleDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.grey.withOpacity(0.25), height: 1);
  }
}
