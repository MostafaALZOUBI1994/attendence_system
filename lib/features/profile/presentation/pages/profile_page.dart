import 'dart:async';
import 'package:attendence_system/features/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../../core/constants/constants.dart';
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
    context.read<ProfileBloc>().add(const ProfileEvent.fetchProfileData());
    _animatePerformanceScore();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: AppBackground(
        child: Column(
          children: [
            _buildProfileHeader(),
            Expanded(
                child: SingleChildScrollView(child: _buildProfileContent(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        Container(
          height: 270,
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        const Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/user_profile.jpg'),
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Mostafa ALZOUBI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Senior Developer",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
         // final profileData = state.profileData;
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
          const Text(
            "Performance Indicator",
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
                  GaugeRange(startValue: 40, endValue: 70, color: Colors.orange),
                  GaugeRange(startValue: 70, endValue: 90, color: Colors.blue),
                  GaugeRange(startValue: 90, endValue: 100, color: Colors.green),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(value: _performanceScore),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      "$_performanceScore%",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

