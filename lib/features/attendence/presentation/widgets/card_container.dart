import 'package:flutter/material.dart';

/// A small helper to build cards with padding and rounded corners.
class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double minHeight;

  const CardContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.minHeight = 72, // give tiles a gentle minimum height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}