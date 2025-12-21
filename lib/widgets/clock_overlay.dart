import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  Timer? _timer;
  double _progress = 0.0;

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
      _timer?.cancel();
      setState(() {
        _progress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
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
      });
      currentTick++;
      if (currentTick > totalTicks) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
    return CustomPaint(
      painter: ClockPainter(_progress, widget.isClockwise, isMobile),
      child: Container(),
    );
  }
}
