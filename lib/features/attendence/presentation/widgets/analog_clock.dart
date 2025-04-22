import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';

class AnalogAttendanceClock extends StatefulWidget {
  final List<int> eventTimestamps;
  final Color accentColor;
  final VoidCallback? onCheckIn;

  const AnalogAttendanceClock({
    Key? key,
    required this.eventTimestamps,
    this.accentColor = const Color(0xFF4A90E2),
    this.onCheckIn,
  }) : super(key: key);

  @override
  _AnalogAttendanceClockState createState() => _AnalogAttendanceClockState();
}

class _AnalogAttendanceClockState extends State<AnalogAttendanceClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.accentColor.withOpacity(0.1),
        ),
        child: CustomPaint(
          painter: _ClockPainter(
            now: _now,
            eventTimestamps: widget.eventTimestamps,
            accentColor: widget.accentColor,
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime now;
  final List<int> eventTimestamps;
  final Color accentColor;

  _ClockPainter({
    required this.now,
    required this.eventTimestamps,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawClockFace(canvas, center, radius);
    _drawClockHands(canvas, center, radius);
    _drawEventMarkers(canvas, center, radius);
    _drawGlassEffect(canvas, center, radius);
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * pi - pi / 2;
      final tickLength = i % 5 == 0 ? 18.0 : 12.0;
      // tick
      final p1 = center + Offset(cos(angle), sin(angle)) * (radius - 8);
      final p2 = center + Offset(cos(angle), sin(angle)) * (radius - tickLength);
      final tickPaint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = i % 5 == 0 ? 4 : 2
        ..color = accentColor.withOpacity(i % 5 == 0 ? 1.0 : 0.3);
      canvas.drawLine(p1, p2, tickPaint);
    }

  }

  void _drawClockFace(Canvas canvas, Offset center, double radius) {

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = accentColor;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // Draw hour numbers
    for (int hour = 1; hour <= 12; hour++) {
      final angle = (hour / 12) * 2 * pi - pi / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: hour.toString(),
          style: TextStyle(
            color: accentColor,
            fontSize: radius * 0.12,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final position = center +
          Offset(cos(angle), sin(angle)) * (radius * 0.75) -
          Offset(textPainter.width / 2, textPainter.height / 2);

      textPainter.paint(canvas, position);
    }
  }

  void _drawClockHands(Canvas canvas, Offset center, double radius) {
    final hourAngle = ((now.hour % 12) + now.minute / 60) * (2 * pi / 12) - pi / 2;
    final minuteAngle = (now.minute + now.second / 60) * (2 * pi / 60) - pi / 2;
    final secondAngle = now.second * (2 * pi / 60) - pi / 2;

    // Hour hand
    final hourHand = Paint()
      ..color = accentColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      center + Offset(cos(hourAngle), sin(hourAngle)) * (radius * 0.5),
      hourHand,
    );

    // Minute hand
    final minuteHand = Paint()
      ..color = accentColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      center + Offset(cos(minuteAngle), sin(minuteAngle)) * (radius * 0.7),
      minuteHand,
    );

    // Second hand
    final secondHand = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      center + Offset(cos(secondAngle), sin(secondAngle)) * (radius * 0.9),
      secondHand,
    );

    // Center pivot
    canvas.drawCircle(center, 8, Paint()..color = accentColor);
  }


  void _drawEventMarkers(Canvas canvas, Offset center, double radius) {
    for (var epoch in eventTimestamps) {
      final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
      final minuteAngle = (dt.minute / 60) * 2 * pi - pi / 2;

      // Inner marker position
      final markerRadius = radius * 0.90;
      final pos = center + Offset(cos(minuteAngle), sin(minuteAngle)) * markerRadius;

      // Draw marker
      final markerPaint = Paint()
        ..color = lightGray.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, radius * 0.06, markerPaint);

      // Draw time label
      final timeLabel = DateFormat('h:mm').format(dt);
      final textPainter = TextPainter(
        text: TextSpan(
          text: timeLabel,
          style: TextStyle(
            color: secondaryColor,
            fontSize: radius * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: radius * 0.2);

      final labelOffset = pos - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawGlassEffect(Canvas canvas, Offset center, double radius) {
    final glassPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        [
          accentColor.withOpacity(0.1),
          accentColor.withOpacity(0.05),
          Colors.transparent,
        ],
        [0.0, 0.8, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius * 0.9, glassPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
