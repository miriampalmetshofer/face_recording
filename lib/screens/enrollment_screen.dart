import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:facerecording/services/camera_service.dart';
import 'package:facerecording/services/web_download_service_stub.dart'
    if (dart.library.html) 'package:facerecording/services/web_download_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:facerecording/config/app_config.dart';
import 'package:facerecording/widgets/clock_overlay.dart';

class EnrollmentScreen extends StatefulWidget {
  final String name;
  final String device;
  final String setting;

  const EnrollmentScreen({
    super.key,
    required this.name,
    required this.device,
    required this.setting,
  });

  @override
  _EnrollmentScreenState createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  bool _isRecording = false;
  late CameraService _cameraService;
  bool _isCameraServiceInitialized = false;
  bool _isClockwise = true;

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

      final formattedDate = AppConfig.getFormattedDateTime();
      final lowercaseName = widget.name.toLowerCase();
      final direction = _isClockwise ? 'cw' : 'ccw';
      final settingCode = AppConfig.getSettingCode(widget.setting);

      if (kIsWeb) {
        downloadVideoWeb(videoFile, '${lowercaseName}_enrollment_${settingCode}_$direction', formattedDate);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/${lowercaseName}_enrollment_${settingCode}_${direction}_$formattedDate.mp4';
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
                  Align(
                    alignment: Alignment(0.0, 0.3),
                    child: ClockOverlay(
                      durationSeconds: AppConfig.enrollmentDurationSeconds,
                      isRecording: _isRecording,
                      isClockwise: _isClockwise,
                    ),
                  ),
                ],
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isClockwise ? Icons.rotate_right : Icons.rotate_left),
                    onPressed: _isRecording
                        ? null
                        : () {
                            setState(() {
                              _isClockwise = !_isClockwise;
                            });
                          },
                    tooltip: _isClockwise ? 'Clockwise' : 'Counterclockwise',
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isRecording || !_isCameraServiceInitialized
                        ? null
                        : _startEnrollmentRecording,
                    child: Text(_isRecording ? 'Recording...' : 'Start Recording'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
