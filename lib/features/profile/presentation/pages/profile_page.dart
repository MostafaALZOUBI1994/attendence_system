import 'dart:async';
import 'package:attendence_system/features/app_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/injection.dart';
import '../../../../core/local_services/local_services.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
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

class _ProfilePageState extends State<ProfilePage> {
  final List<double> _moodHistory = [0.66, 1.0, 1.0, 0.66, 1.0];
  late double _performanceScore = 0;
  final double _finalPerformanceScore = 85;

  double get _averageMood {
    if (_moodHistory.isEmpty) return 0.0;
    return _moodHistory.reduce((a, b) => a + b) / _moodHistory.length;
  }

  String get _mostFrequentMood {
    final frequency = <double, int>{};
    for (var mood in _moodHistory) {
      frequency[mood] = (frequency[mood] ?? 0) + 1;
    }
    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .toString();
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthEvent.getProfileData());
    context.read<ProfileBloc>().add(const ProfileEvent.fetchProfileData());
    _animatePerformanceScore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: AppBackground(
          child: Column(
            children: [
              _buildProfileHeader(),
              Expanded(
                  child: SingleChildScrollView(
                      child: _buildProfileContent(context))),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLangButton() {
    final localeSvc = getIt<LocalService>();
    final isArabic = localeSvc.currentLanguageCode == 'ar';

    Future<void> _toggleLocale() async {
      final newLocale = isArabic
          ? const Locale('en', 'US')
          : const Locale('ar', 'AE');
      await context.setLocale(newLocale);
      await localeSvc.saveLocale(newLocale);
    }

    // If we're in Arabic show the UK flag (to switch to EN), else show UAE flag.
    final flagEmoji = isArabic ? '🇬🇧' : '🇦🇪';

    return GestureDetector(
      onTap: _toggleLocale,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: Text(flagEmoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }




  Widget _buildProfileHeader() {
    final localeSvc = getIt<LocalService>();
    final isArabic = localeSvc.currentLanguageCode == 'ar';

    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final newLocale = isArabic
                          ? const Locale('en', 'US')
                          : const Locale('ar', 'AE');
                      await context.setLocale(newLocale);
                      await localeSvc.saveLocale(newLocale);
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text(
                        isArabic ? '🇬🇧' : '🇦🇪',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: (){
                      context.read<AuthBloc>().add(SignOut());
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.logout, color: primaryColor, size: 28),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Avatar, Name & Title
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return state.maybeWhen(
                  success: (loginData) {
                    final name = isArabic
                        ? loginData.empNameAR
                        : loginData.empName;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                          AssetImage('assets/user_profile.jpg'),
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'seniorDev'.tr(), // add this key to your JSON
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                  orElse: () =>
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileContent(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          final healthData = state.healthData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHappinessCard(),
                const SizedBox(height: 10),
                _buildPerformanceIndicator(),
                const SizedBox(height: 10),
                const AccessCard(),
                const SizedBox(height: 10),
                HealthCard(healthData: healthData),
                const SizedBox(height: 10),
                _buildStatsRow(),
              ],
            ),
          );
        } else if (state is ProfileError) {
          return Text(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHappinessCard() {
    final averageMood = _averageMood;
    final mostFrequent = _mostFrequentMood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Employee Sentiment",
            style: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _moodDisplay("Average Mood", averageMood),
              _moodDisplay("Most Frequent", mostFrequent),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Based on ${_moodHistory.length} check-ins",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _moodDisplay(String title, dynamic value) {
    double moodValue = value is String ? double.parse(value) : value;
    String emoji = _getMoodEmoji(moodValue);
    String label = _getMoodLabel(moodValue);

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(Icons.calendar_month, "Attendance", "98%"),
        _buildStatCard(Icons.health_and_safety, "Leaves Left", "12 days"),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
           Text(
            "performance".tr(),
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 0, endValue: 40, color: Colors.red),
                  GaugeRange(
                      startValue: 40, endValue: 70, color: Colors.orange),
                  GaugeRange(startValue: 70, endValue: 90, color: Colors.blue),
                  GaugeRange(
                      startValue: 90, endValue: 100, color: Colors.green),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(value: _performanceScore),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      "$_performanceScore%",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    angle: 90,
                    positionFactor: 0.8,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPerformanceBadge(),
        ],
      ),
    );
  }

  Widget _buildPerformanceBadge() {
    String badge = _performanceScore >= 90
        ? "🎯 Early bird"
        : _performanceScore >= 80
            ? "🦉 Night owl"
            : _performanceScore >= 70
                ? "💼 Consistent Contributor"
                : "🚀 Needs Improvement";

    return Text(
      "Badge: $badge",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  void _animatePerformanceScore() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_performanceScore >= _finalPerformanceScore) {
        timer.cancel();
      } else {
        setState(() {
          _performanceScore += 2;
          if (_performanceScore > _finalPerformanceScore) {
            _performanceScore = _finalPerformanceScore;
          }
        });
      }
    });
  }
}
