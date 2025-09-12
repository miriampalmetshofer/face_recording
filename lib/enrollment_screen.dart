import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:facerecording/camera_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EnrollmentScreen extends StatefulWidget {
  final String name;
  final String device;
  final String task = "enrollment";

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
      await Future.delayed(const Duration(seconds: 15));
      XFile? videoFile = await _cameraService.stopVideoRecording();

      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/${widget.name}_enrollment_${DateTime.now()}.mp4';
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
          title: const Text('Enrollment'),
          content: const Text('Enrollment abgeschlossen!'),
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
      appBar: AppBar(title: const Text('Enrollment')),
      body: Center(
        child: Column(
          children: [
            if (_isCameraServiceInitialized)
              Expanded(child: _cameraService.buildPreview())
            else
              const Expanded(child: Center(child: CircularProgressIndicator())),
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
