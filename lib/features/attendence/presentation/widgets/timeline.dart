import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../../../core/constants/constants.dart';

class ProcessTimeline extends StatelessWidget {
  final int currentIndex;
  final List<ProcessStep> steps;

  const ProcessTimeline({super.key, required this.currentIndex, required this.steps});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: const ConnectorThemeData(space: 20.0, thickness: 5.0),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemExtentBuilder: (_, __) => (MediaQuery.of(context).size.width - 20) / steps.length,
          oppositeContentsBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Icon(steps[index].icon, color: _getColor(index)),
          ),
          contentsBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              steps[index].title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getColor(index),
              ),
            ),
          ),
          indicatorBuilder: (_, index) => _buildIndicator(index),
          connectorBuilder: (_, index, type) => _buildConnector(index, type),
          itemCount: steps.length,
        ),
      ),
    );
  }

  Color _getColor(int index) => index <= currentIndex ? primaryColor : Colors.grey;

  Widget _buildIndicator(int index) {
    return Stack(
      children: [
        CustomPaint(
          size: const Size(30, 30),
          painter: _BezierPainter(
            color: _getColor(index),
            drawStart: index > 0,
            drawEnd: index < currentIndex,
          ),
        ),
        DotIndicator(
          size: 30,
          color: _getColor(index),
          child: _buildIndicatorChild(index),
        ),
      ],
    );
  }

  Widget? _buildIndicatorChild(int index) {
    if (index == currentIndex) {
      return const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ));
    }
    return index < currentIndex
        ? const Icon(Icons.check, color: Colors.white, size: 15)
        : null;
  }

  Widget _buildConnector(int index, ConnectorType type) {
    if (index == 0) return const SizedBox.shrink();
    final colors = [
      Color.lerp(_getColor(index-1), _getColor(index), 0.5)!,
      _getColor(index)
    ];
    return DecoratedLineConnector(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: type == ConnectorType.start
            ? colors.reversed.toList()
            : colors),
      ),
    );
  }
}

class ProcessStep {
  final String title;
  final IconData icon;

  ProcessStep({required this.title, required this.icon});
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    double angle;
    Offset offset1;
    Offset offset2;

    Path path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius)
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}