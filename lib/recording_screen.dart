import 'dart:async';
import 'package:facerecording/web_utils.dart' if (dart.library.html) 'package:facerecording/web_utils_web.dart';

import 'package:facerecording/camera_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  late CameraService _cameraService;
  bool _isCameraInitialized = false;
  Timer? _timer;
  int _remainingTime = 5;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _cameraService = getCameraService();
    _cameraService.initialize().then((_) {
      setState(() {
        _isCameraInitialized = true;
      });
    });
  }

  void _startTimer() {
    if (!_isCameraInitialized) {
      return;
    }
    _startRecording();
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

  Future<void> _startRecording() async {
    await _cameraService.startVideoRecording();
  }

  void _stopRecording() async {
    if (!_isCameraInitialized) {
      return;
    }
    _timer?.cancel();
    final file = await _cameraService.stopVideoRecording();
    setState(() {
      _isRecording = false;
    });

    if (kIsWeb) {
      downloadVideoWeb(file, widget.name, widget.task);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video downloaded.'),
        ),
      );
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${widget.name}_${widget.task}_${DateTime.now()}.mp4';
      await file.saveTo(path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video saved to: $path'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraService.dispose();
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isCameraInitialized)
                SizedBox(
                  width: 300,
                  height: 300,
                  child: _cameraService.buildPreview(),
                )
              else
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Placeholder',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Text(
                '$_remainingTime s',
                style: TextStyle(fontSize: 16),
              ),
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
