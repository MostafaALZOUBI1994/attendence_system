import 'package:flutter/material.dart';

import '../constants/constants.dart';

class Initials extends StatelessWidget {
  const Initials(this.name);
  final String name;
  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
    return Text(
      initials.isEmpty ? '👤' : initials,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: secondaryColor),
    );
  }
}