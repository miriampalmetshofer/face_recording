import 'dart:async';

import 'package:flutter/material.dart';

class RecordingScreen extends StatefulWidget {
  final String task;
  final String device;
  final String name;

  const RecordingScreen({
    super.key,
    required this.task,
    required this.name,
    required this.device,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  Timer? _timer;
  int _remainingTime = 5;
  bool _isRecording = false;

  void _startTimer() {
    setState(() {
      _isRecording = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });
    // TODO: Save the video
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Placeholder', style: TextStyle(fontSize: 16)),
              ),
              Text('$_remainingTime s', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isRecording ? null : _startTimer,
                child: const Text('Start Recording'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
