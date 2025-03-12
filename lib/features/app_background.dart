import 'package:flutter/material.dart';

import '../main.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your existing background elements
        Positioned(
          top: 150,
          left: -50,
          child: _buildDecorativeCircle(200, primaryColor.withOpacity(0.2)),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _buildDecorativeCircle(300, primaryColor.withOpacity(0.3)),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(height: 100, color: primaryColor),
        ),

        // Content placeholder
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}