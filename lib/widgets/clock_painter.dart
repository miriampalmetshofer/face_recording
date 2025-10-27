import 'dart:math';
import 'package:flutter/material.dart';
import 'package:facerecording/config/app_config.dart';

class ClockPainter extends CustomPainter {
  final double progress;
  final String instruction;
  final bool isClockwise;
  final bool isMobile;

  ClockPainter(this.progress, this.instruction, this.isClockwise, this.isMobile);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radiusScale = isMobile ? AppConfig.clockRadiusScaleMobile : AppConfig.clockRadiusScale;
    final radius = min(size.width / 2, size.height / 2) * radiusScale;
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConfig.clockStrokeWidth;

    canvas.drawCircle(center, radius, paint);

    // Calculate dot position
    final Offset dotPosition;
    if (progress < AppConfig.clockDotToCircleProgress) {
      // Phase 1: Dot moves from center straight up to circle outline
      final moveProgress = progress / AppConfig.clockDotToCircleProgress;
      final distanceFromCenter = radius * moveProgress;
      dotPosition = Offset(
        center.dx,
        center.dy - distanceFromCenter,
      );
    } else {
      // Phase 2: Dot moves around the circle perimeter
      // Normalize progress to 0-1 range for circle movement
      final circleProgress = (progress - AppConfig.clockDotToCircleProgress) /
                            (1.0 - AppConfig.clockDotToCircleProgress);
      // Start at top (-π/2) and go clockwise or counterclockwise
      final angle = isClockwise
          ? 2 * pi * circleProgress - pi / 2
          : -2 * pi * circleProgress - pi / 2;
      dotPosition = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    }

    // Draw the blue dot
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final dotRadius = isMobile ? AppConfig.clockDotRadiusMobile : AppConfig.clockDotRadius;
    canvas.drawCircle(dotPosition, dotRadius, dotPaint);

    // Draw head turning instructions
    final instructionPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw arrows
    _drawArrow(canvas, center, radius, 0, instructionPaint); // Right
    _drawArrow(canvas, center, radius, pi / 2, instructionPaint); // Down
    _drawArrow(canvas, center, radius, pi, instructionPaint); // Left
    _drawArrow(canvas, center, radius, 3 * pi / 2, instructionPaint); // Up
  }

  void _drawArrow(Canvas canvas, Offset center, double radius, double angle, Paint paint) {
    final arrowLength = AppConfig.clockArrowLength;
    final arrowAngle = pi / 6;

    final endPoint = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    final arrowP1 = Offset(
      endPoint.dx - arrowLength * cos(angle - arrowAngle),
      endPoint.dy - arrowLength * sin(angle - arrowAngle),
    );
    final arrowP2 = Offset(
      endPoint.dx - arrowLength * cos(angle + arrowAngle),
      endPoint.dy - arrowLength * sin(angle + arrowAngle),
    );

    canvas.drawLine(endPoint, arrowP1, paint);
    canvas.drawLine(endPoint, arrowP2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
