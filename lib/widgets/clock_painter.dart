import 'dart:math';
import 'package:flutter/material.dart';
import 'package:facerecording/config/app_config.dart';

class ClockPainter extends CustomPainter {
  final double progress;
  final String instruction;

  ClockPainter(this.progress, this.instruction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) * AppConfig.clockRadiusScale;
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConfig.clockStrokeWidth;

    canvas.drawCircle(center, radius, paint);

    final handAngle = 2 * pi * progress - pi / 2;
    final handEndPoint = Offset(
      center.dx + radius * cos(handAngle),
      center.dy + radius * sin(handAngle),
    );
    final handPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = AppConfig.clockHandStrokeWidth;
    canvas.drawLine(center, handEndPoint, handPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: instruction,
        style: const TextStyle(color: Colors.white, fontSize: AppConfig.clockInstructionFontSize),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2,
            center.dy - radius - textPainter.height - 10));

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
