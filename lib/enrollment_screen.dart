import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:facerecording/camera_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:facerecording/app_config.dart';
import 'package:facerecording/clock_overlay.dart';

class EnrollmentScreen extends StatefulWidget {
  final String name;
  final String device;

  const EnrollmentScreen({super.key, required this.name, required this.device});

  @override
  _EnrollmentScreenState createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  bool _isRecording = false;
  late CameraService _cameraService;
  bool _isCameraServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _cameraService = getCameraService();
    _cameraService.initialize().then((_) {
      setState(() {
        _isCameraServiceInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _startEnrollmentRecording() async {
    if (!_cameraService.isInitialized) {
      await _cameraService.initialize();
    }

    setState(() {
      _isRecording = true;
    });

    try {
      await _cameraService.startVideoRecording();
      await Future.delayed(const Duration(seconds: AppConfig.enrollmentDurationSeconds));
      XFile? videoFile = await _cameraService.stopVideoRecording();
      final date = DateTime.now().toIso8601String().replaceAll(':', '-');

      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/${widget.name}_${widget.device}_enrollment_$date.mp4';
        await videoFile.saveTo(path);
      }
      _showEnrollmentCompleteAlert();
        } catch (e) {
      print('Error during enrollment recording: $e');
      // Handle error, e.g., show a SnackBar
    } finally {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _showEnrollmentCompleteAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enrollment process'),
          content: const Text('Enrollment process finished!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrollment process')),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: _isCameraServiceInitialized
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  _cameraService.buildPreview(),
                  ClockOverlay(
                    durationSeconds: AppConfig.enrollmentDurationSeconds,
                    isRecording: _isRecording,
                  ),
                ],
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isRecording || !_isCameraServiceInitialized
                    ? null
                    : _startEnrollmentRecording,
                child: Text(_isRecording ? 'Recording...' : 'Start Recording'),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
