import 'dart:math';

import 'package:attendence_system/features/app_background.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<double> _moodHistory = [0.66, 1.0, 1.0, 0.66, 1.0];
  final double _performanceScore = 85;

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
                child: SingleChildScrollView(child: _buildProfileContent())),
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
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        Positioned.fill(
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
                  const SizedBox(height: 12),
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

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHappinessCard(),
          const SizedBox(height: 20),
          AccessCard(),
          const SizedBox(height: 20),
          _buildPerformanceIndicator(),
          const SizedBox(height: 20),
          _buildStatsRow(),
          // const SizedBox(height: 20),
          // _buildActionButtons(),
        ],
      ),
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
          Text(
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
          style: TextStyle(
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
              style: TextStyle(
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.edit, "Edit Profile", () {}),
        _buildActionButton(Icons.notifications, "Reminders", () {}),
        _buildActionButton(Icons.settings, "Settings", () {}),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Function() onTap) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: Icon(icon, color: primaryColor, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
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
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }
}


class AccessCard extends StatefulWidget {
  const AccessCard({super.key});

  @override
  State<AccessCard> createState() => _AccessCardState();
}

class _AccessCardState extends State<AccessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _toggleCard() {
    if (_isFrontVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFrontVisible = !_isFrontVisible);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final rotation = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation);

          return Stack(
            children: [
              Transform(
                transform: transform,
                alignment: Alignment.center,
                child: rotation > pi / 2
                    ? Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildBack(),
                )
                    : _buildFront(),
              ),
              // Flip Button at the Top Right Corner
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: _toggleCard,
                  icon: const Icon(Icons.flip),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
              // Wallet Button at the Bottom Left Corner
              Positioned(
                bottom: 8,
                left: 8,
                child: ElevatedButton.icon(
                  onPressed: () => _addToWallet(context),
                  icon: const Icon(Icons.credit_card),
                  label: const Text("Wallet"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return _buildCard(
      child: Column(
        children: [
          Image.asset(
            "assets/ministry_logo.png",
            height: 50,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "مصطفى موسى الزعبي",
                      style: TextStyle(color: primaryColor, fontSize: 10),
                    ),
                    Text(
                      "مبرمج",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "MOSTAFA MOUSA AL ZOUBI",
                      style: TextStyle(color: primaryColor, fontSize: 10),
                    ),
                    Text(
                      "Programmer",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "الرقم الوظيفي : 581795",
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              Image.asset(
                "assets/user_profile.jpg",
                height: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _buildCard(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            QrImageView(
              data: 'This is a simple QR code',
              version: QrVersions.auto,
              size: 50,
              gapless: false,
            ),
            const SizedBox(height: 10),
            const Text(
              "هذه البطاقة التعريفية ملك وزارة الاقتصاد.\n في حال العثور على هذه البطاقة، يرجى ارسالها الى ص.ب 3625\n دبي الامارات العربية المتحدة او الاتصال على الرقم 800-1222",
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
              textAlign: TextAlign.end,
            ),

            const Text(
              "Valid until\n2025",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.nfc, color: lightGray),
                  const SizedBox(width: 8),
                  const Text(
                    "Tap to use",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return SizedBox(
      width: 400,
      height: 230,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2),
          ],
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: child,
      ),
    );
  }

  void _addToWallet(BuildContext context) {
    // Wallet integration implementation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

