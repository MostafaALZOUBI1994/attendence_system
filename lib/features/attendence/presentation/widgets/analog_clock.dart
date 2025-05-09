import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../../core/constants/constants.dart';

/// Draws hour numbers around the clock face.
class _HourNumberPainter extends CustomPainter {
  final Color numberColor;
  _HourNumberPainter({required this.numberColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;
    final textStyle = TextStyle(color: numberColor, fontSize: 20, fontWeight: FontWeight.bold);
    for (int h = 1; h <= 12; h++) {
      final angle = (h / 12) * 2 * pi - pi / 2;
      final tp = TextPainter(
        text: TextSpan(text: h.toString(), style: textStyle),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final pos = center + Offset(cos(angle), sin(angle)) * radius - Offset(tp.width/2, tp.height/2);
      tp.paint(canvas, pos);
    }
  }

  @override bool shouldRepaint(_) => false;
}

/// Draws tick marks for hours and minutes.
class ClockTicksPainter extends CustomPainter {
  final Color tickColor;
  ClockTicksPainter({required this.tickColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);
    final outer = size.width/2;
    for (int i = 0; i < 60; i++) {
      final angle = 2*pi*i/60 - pi/2;
      final isHour = i%5==0;
      final r1 = outer - (isHour?20:10);
      final r2 = outer;
      final paint = Paint()
        ..color = tickColor.withOpacity(isHour?1:0.5)
        ..strokeWidth = isHour?3:1.5;
      canvas.drawLine(
        center + Offset(cos(angle)*r1, sin(angle)*r1),
        center + Offset(cos(angle)*r2, sin(angle)*r2),
        paint,
      );
    }
  }
  @override bool shouldRepaint(_) => false;
}

/// Draws event markers and labels.
class _EventMarkerPainter extends CustomPainter {
  final List<int> timestamps;
  final Color markerColor;
  _EventMarkerPainter({required this.timestamps, required this.markerColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);
    final outer = size.width/2 - 40;

    for (var ts in timestamps) {
      final dt = DateTime.fromMillisecondsSinceEpoch(ts);
      final angle = ((dt.hour%12)+dt.minute/60)/12*2*pi - pi/2;
      final pos = center + Offset(cos(angle)*outer, sin(angle)*outer);
      canvas.drawCircle(pos, 6, Paint()..color=markerColor);
    }
  }
  @override bool shouldRepaint(_) => true;
}

/// A refined analog clock with gradient ring, numbers, ticks, countdown, icon, and event markers.
class AnalogAttendanceClock extends StatelessWidget {
  final List<int> eventTimestamps;
  final Gradient ringGradient;
  final VoidCallback? onCheckIn;

  const AnalogAttendanceClock({
    Key? key,
    required this.eventTimestamps,
    this.ringGradient = primaryGradient,
    this.onCheckIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCheckIn,
      child: Container(
        width: 300, height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ringGradient,
        ),
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(4,4)),
              BoxShadow(color: Colors.white70, blurRadius: 8, offset: Offset(-4,-4)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: Size.infinite, painter: ClockTicksPainter(tickColor: primaryColor)),
              CustomPaint(size: Size.infinite, painter: _HourNumberPainter(numberColor: secondaryColor)),
              CustomPaint(size: Size.infinite, painter: _EventMarkerPainter(timestamps: eventTimestamps, markerColor: primaryColor)),
            ],
          ),
        ),
      ),
    );
  }
}
