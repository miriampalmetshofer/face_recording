import 'dart:async';
import 'package:flutter/material.dart';
import 'package:facerecording/config/app_config.dart';
import 'package:facerecording/widgets/clock_painter.dart';

class ClockOverlay extends StatefulWidget {
  final int durationSeconds;
  final bool isRecording;
  final bool isClockwise;

  const ClockOverlay({
    super.key,
    required this.durationSeconds,
    required this.isRecording,
    required this.isClockwise,
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
      painter: ClockPainter(_progress, _instruction, widget.isClockwise),
      child: Container(),
    );
  }
}
