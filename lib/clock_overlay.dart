
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:facerecording/app_config.dart';

class ClockOverlay extends StatefulWidget {
  final int durationSeconds;
  final bool isRecording;

  const ClockOverlay({
    super.key,
    required this.durationSeconds,
    required this.isRecording,
  });

  @override
  _ClockOverlayState createState() => _ClockOverlayState();
}

class _ClockOverlayState extends State<ClockOverlay> {
  late Timer _timer;
  double _progress = 0.0;
  String _instruction = "Look Straight";

  @override
  void initState() {
    super.initState();
    if (widget.isRecording) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(ClockOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startTimer();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _timer.cancel();
      setState(() {
        _progress = 0.0;
        _instruction = "Look Straight";
      });
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    const tickDuration = Duration(milliseconds: 100);
    final totalTicks = widget.durationSeconds * 1000 / tickDuration.inMilliseconds;
    int currentTick = 0;

    _timer = Timer.periodic(tickDuration, (timer) {
      setState(() {
        _progress = currentTick / totalTicks;
        if (_progress < AppConfig.headTurnRightThreshold) {
          _instruction = "Turn your head to the right";
        } else if (_progress < AppConfig.headTurnLeftThreshold) {
          _instruction = "Turn your head to the left";
        } else if (_progress < AppConfig.headTurnUpThreshold) {
          _instruction = "Turn your head up";
        } else {
          _instruction = "Turn your head down";
        }
      });
      currentTick++;
      if (currentTick > totalTicks) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClockPainter(_progress, _instruction),
      child: Container(),
    );
  }
}

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
