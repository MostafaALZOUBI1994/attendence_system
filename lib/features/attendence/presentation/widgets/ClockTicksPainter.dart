import 'dart:math';
import 'package:flutter/material.dart';

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

