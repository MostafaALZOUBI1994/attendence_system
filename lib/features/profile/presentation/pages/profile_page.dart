import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moet_hub/features/reports/domain/entities/report_model.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/injection.dart';
import '../../../../core/local_services/local_services.dart';
import '../../../../core/utils/Initials.dart';
import '../../../../core/utils/base64_utils.dart';
import '../../../../core/widgets/avatar_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../mood/presentation/bloc/mood_bloc.dart';
import '../../../reports/presentation/bloc/report_bloc.dart'; // ⬅️ read attendance here
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/access_card.dart';
import '../widgets/health_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final List<double> _moodHistory = [0.66, 1.0, 1.0, 0.66, 1.0];

  late final AnimationController _scoreController;
  late Animation<double> _scoreAnim; // 0..100

  double get _averageMood {
    if (_moodHistory.isEmpty) return 0.0;
    return _moodHistory.reduce((a, b) => a + b) / _moodHistory.length;
  }

  String get _mostFrequentMood {
    final frequency = <double, int>{};
    for (var mood in _moodHistory) {
      frequency[mood] = (frequency[mood] ?? 0) + 1;
    }
    return frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key.toString();
  }

  @override
  void initState() {
    super.initState();

    // Fetch data
    context.read<AuthBloc>().add(const AuthEvent.getProfileData());
    context.read<ProfileBloc>().add(const ProfileEvent.fetchProfileData());
    context.read<MoodBloc>().add(const MoodEvent.fetchMoodHistory());

    // Gauge animation setup; we’ll animate to the computed % after first frame
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    )..addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    // Read ReportBloc once (already fetched) and animate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = _attendancePercentFromReportBloc(context); // 0..100
      _animateScoreTo(p);
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  void _animateScoreTo(double target) {
    final begin = _scoreAnim.value;
    _scoreAnim = Tween<double>(begin: begin, end: target.clamp(0, 100)).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );
    _scoreController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final localeSvc = getIt<LocalService>();
    final isArabic = localeSvc.getSavedLocale().languageCode == 'ar';

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UnAuthenticated) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
        ),
        // Optional: re-animate gauge when reports refresh (e.g., pull-to-refresh)
        BlocListener<ReportBloc, ReportState>(
          listenWhen: (_, s) => s.maybeWhen(loaded: (_, __) => true, orElse: () => false),
          listener: (context, state) {
            final p = state.maybeWhen(
              loaded: (report, _) => _attendancePercent(report),
              orElse: () => 0.0,
            );
            _animateScoreTo(p);
          },
        ),
      ],
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 1.0],
            colors: [Color(0xFFEEF5FF), Color(0xFFEAF2FF), Color(0xFFF7F9FC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Directionality(
              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _topBar(isArabic: isArabic, localeSvc: localeSvc),
                  const SizedBox(height: 6),
                  _headerCard(isArabic: isArabic),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildProfileContent(context),
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

  // ───────────────────────── Attendance % from reports ─────────────────────────

  String _emojiFor(String? mood) {
    switch ((mood ?? '').toLowerCase()) {
      case 'happy':   return '😀';
      case 'neutral': return '😐';
      case 'sad':     return '😞';
      case 'angry':   return '😡';
      default:        return '—';
    }
  }

  Widget _moodTile({required String title, required String label}) {
    final emoji = _emojiFor(label);
    return _glass(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
  double _attendancePercentFromReportBloc(BuildContext ctx) {
    final state = ctx.read<ReportBloc>().state;
    return state.maybeWhen(
      loaded: (report, _) => _attendancePercent(report),
      orElse: () => 0.0,
    );
  }

  double _attendancePercent(List<Report> reports) {
    if (reports.isEmpty) return 0.0;

    final total  = reports.length;
    final absent = reports.where((r) => r.status == 'ABSENT').length;
    final present = total - absent;

    return (present / total * 100).clamp(0.0, 100.0);
  }


  // ───────────────────────── UI Pieces ─────────────────────────

  Widget _glass({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1, offset: Offset(0, 4))],
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _topBar({required bool isArabic, required LocalService localeSvc}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            final newLocale = isArabic ? const Locale('en') : const Locale('ar');
            await context.setLocale(newLocale);
            await localeSvc.saveLocale(newLocale);
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(isArabic ? '🇬🇧' : '🇦🇪', style: const TextStyle(fontSize: 20)),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.read<AuthBloc>().add(SignOut()),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.logout, color: primaryColor, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _headerCard({required bool isArabic}) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.maybeWhen(
          success: (employee) {
            final name = isArabic ? employee.employeeNameInAr : employee.employeeNameInEn;
            final role = isArabic ? employee.employeeTitleInAr : employee.employeeNameInEn; // keep as your current fallback
            final department = isArabic ? employee.departmentInAr : employee.departmentInEn;
            final directManager = employee.directManager.split(',').first.replaceFirst('CN=', '').trim();


            return _glass(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                children: [
                  CircleAvatarOrInitials(
                    base64: employee.empImageUrl,
                    fullName: employee.employeeNameInEn,
                    radius: 44,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(role, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(directManager, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(department, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
                ],
              ),
            );
          },
          orElse: () => _glass(
            child: Row(
              children: const [
                CircleAvatar(radius: 24, backgroundColor: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Skeleton(height: 14, width: 140),
                      SizedBox(height: 8),
                      _Skeleton(height: 12, width: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final localeSvc = getIt<LocalService>();
    final isArabic = localeSvc.getSavedLocale().languageCode == 'ar';

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              );
            } else if (profileState is ProfileLoaded) {
              final employee = authState.maybeWhen(success: (data) => data, orElse: () => null);
              final healthData = profileState.healthData;
              if (employee == null) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _happinessCard(),
                  const SizedBox(height: 12),
                  _performanceCard(), // animated gauge
                  const SizedBox(height: 12),
                  AccessCard(employee: employee, isArabic: isArabic),
                  const SizedBox(height: 12),
                  HealthCard(healthData: healthData),
                  const SizedBox(height: 12),
                  const SizedBox(height: 28),
                ],
              );
            } else if (profileState is ProfileError) {
              return _glass(
                child: Text(
                  profileState.message,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  // Sentiment
  Widget _happinessCard() {
    return Builder(
      builder: (context) {
        // Safe helper to pull a label whether your bloc returns String or an object with .mood
        String labelFrom(dynamic x) {
          if (x == null) return '--';
          if (x is String) return x;
          try { return (x as dynamic).mood as String; } catch (_) { return x.toString(); }
        }

        final state = context.watch<MoodBloc>().state;

        final total = state.maybeWhen(
          historyLoaded: (list, _, __) => list.length,
          orElse: () => 0,
        );

        final lastLabel = state.maybeWhen(
          historyLoaded: (_, last, __) => labelFrom(last),
          orElse: () => '--',
        );

        final freqLabel = state.maybeWhen(
          historyLoaded: (_, __, most) => labelFrom(most),
          orElse: () => '--',
        );


        return _glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Text(
                'employeeSentiment'.tr(),
                style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _moodTile(title: 'lastMood'.tr(),  label: lastLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: _moodTile(title: 'mostFrequent'.tr(), label: freqLabel)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                //  namedArgs: {'chkinTime': record.checkIn}
                'basedOnCheckins'.tr(namedArgs: {'moods':total.toString()}),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _moodDisplay(String title, dynamic value) {
    final double moodValue = value is String ? double.parse(value) : (value as double);
    final String emoji = _getMoodEmoji(moodValue);
    final String label = _getMoodLabel(moodValue);

    return _glass(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _getMoodEmoji(double mood) {
    if (mood >= 0.9) return "😀";
    if (mood >= 0.6) return "😐";
    if (mood >= 0.3) return "😞";
    return "😡";
  }

  String _getMoodLabel(double mood) {
    if (mood >= 0.9) return "Happy";
    if (mood >= 0.6) return "Neutral";
    if (mood >= 0.3) return "Sad";
    return "Angry";
  }

  // Performance Gauge
  Widget _performanceCard() {
    final double value = _scoreAnim.value;

    return _glass(
      child: Column(
        children: [
          Text(
            "performance".tr(),
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                showTicks: false,
                showLabels: false,
                axisLineStyle: const AxisLineStyle(
                  thickness: 0.15,
                  thicknessUnit: GaugeSizeUnit.factor,
                  cornerStyle: CornerStyle.bothCurve,
                ),
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 0, endValue: 40, color: Colors.red,   startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                  GaugeRange(startValue: 40, endValue: 70, color: Colors.orange,startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                  GaugeRange(startValue: 70, endValue: 90, color: Colors.blue, startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                  GaugeRange(startValue: 90, endValue: 100,color: Colors.green,startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: value,
                    needleEndWidth: 4,
                    needleLength: 0.7,
                    knobStyle: const KnobStyle(knobRadius: 0.06),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      "${value.toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    angle: 90,
                    positionFactor: 0.75,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _performanceBadge(value),
        ],
      ),
    );
  }

  Widget _performanceBadge(double score) {
    // String badge = score >= 90
    //     ? "🎯 Early bird"
    //     : score >= 80
    //     ? "🦉 Night owl"
    //     : score >= 70
    //     ? "💼 Consistent Contributor"
    //     : "🚀 Needs Improvement";

    return Text(
      "attPer".tr(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blueGrey),
    );
  }

  // Stats
  Widget _statsRow() {
    return Row(
      children: [
        Expanded(child: _statCard(Icons.calendar_month, "Attendance", "98%")),
        const SizedBox(width: 12),
        Expanded(child: _statCard(Icons.beach_access, "Leaves Left", "12 days")),
      ],
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return _glass(
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 26),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

// Simple skeleton placeholder
class _Skeleton extends StatelessWidget {
  final double height;
  final double width;
  const _Skeleton({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
