import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/constants.dart';

class MoodCheckJoystick extends StatefulWidget {
  final Function(String) onCheckInWithMood;

  const MoodCheckJoystick({required this.onCheckInWithMood, Key? key})
      : super(key: key);

  @override
  _MoodCheckJoystickState createState() => _MoodCheckJoystickState();
}

class _MoodCheckJoystickState extends State<MoodCheckJoystick>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, dynamic>> _moods = [
    {'lottie': 'assets/lottie/happy.json', 'label': 'Happy', 'angle': 90.0},
    {'lottie': 'assets/lottie/neutral.json', 'label': 'Neutral', 'angle': 0.0},
    {'lottie': 'assets/lottie/sad.json', 'label': 'Sad', 'angle': 270.0},
    {'lottie': 'assets/lottie/angry.json', 'label': 'Angry', 'angle': 180.0},
  ];
  String _selectedMood = 'Happy';
  Offset _offset = Offset.zero;
  final double _maxDragDistance = 60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      _offset += details.delta;
      final distance = _offset.distance;
      if (distance > _maxDragDistance) {
        _offset = _offset.scale(_maxDragDistance / distance, _maxDragDistance / distance);
      }

      final angle = (_offset.direction * 180 / pi + 360) % 360;
      _selectedMood = _moods
          .map((m) => {
        'mood': m,
        'diff': (m['angle'] - angle).abs() % 360,
      })
          .reduce((a, b) => a['diff'] < b['diff'] ? a : b)['mood']['label'];
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    widget.onCheckInWithMood(_selectedMood);
    _animateReset();
  }

  void _handleTap() {
    widget.onCheckInWithMood(_selectedMood);
  }

  void _animateReset() {
    final Animation<Offset> resetAnimation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    resetAnimation.addListener(() {
      setState(() {
        _offset = resetAnimation.value;
      });
    });

    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _offset = Offset.zero;
      });
    });
  }

  String _getMoodAsset(String moodLabel) {
    return _moods.firstWhere((m) => m['label'] == moodLabel)['lottie'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryColor.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
          radius: 1.2,
          stops: const [0.4, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._moods.map((mood) {
            final angle = mood['angle'] * (pi / 180);
            return Positioned(
              left: 110 + 80 * cos(angle) - 24,
              top: 110 + 80 * sin(angle) - 24,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.9,
                  end: 1.1,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(
                      0.2,
                      0.8,
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
                child: AnimatedOpacity(
                  opacity: _selectedMood == mood['label'] ? 1 : 0.6,
                  duration: const Duration(milliseconds: 200),
                  child: Lottie.asset(
                    mood['lottie'],
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),

          Positioned(
            left: 75 + _offset.dx,
            top: 75 + _offset.dy,
            child: GestureDetector(
              onPanUpdate: _handleDragUpdate,
              onPanEnd: _handleDragEnd,
              onTap: _handleTap,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Lottie.asset(
                  _getMoodAsset(_selectedMood),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
