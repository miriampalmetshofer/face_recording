import 'dart:async';
import 'package:facerecording/services/web_download_service_stub.dart'
    if (dart.library.html) 'package:facerecording/services/web_download_service.dart';
import 'package:facerecording/services/camera_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:facerecording/config/app_config.dart';

class RecordingScreen extends StatefulWidget {
  final String task;
  final String device;
  final String name;
  final String setting;

  const RecordingScreen({
    super.key,
    required this.task,
    required this.name,
    required this.device,
    required this.setting,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late CameraService _cameraService;
  bool _isCameraInitialized = false;
  Timer? _timer;
  int _remainingTime = AppConfig.recordingDurationSeconds;
  bool _isRecording = false;
  final TextEditingController _textEditingController = TextEditingController();

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
      _remainingTime = AppConfig.recordingDurationSeconds;
    });

    final formattedDate = AppConfig.getFormattedDateTime();
    final lowercaseName = widget.name.toLowerCase();
    final settingCode = widget.setting;

    if (kIsWeb) {
      downloadVideoWeb(file, '${lowercaseName}_$settingCode', formattedDate);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Video downloaded.')));
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${lowercaseName}_${settingCode}_$formattedDate.mp4';
      await file.saveTo(path);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video saved to: $path')));
    }

    if (_textEditingController.text.trim().isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(
            "Danke das wars! Möchtest du deinen Text behalten?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: _textEditingController.text),
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Text in Zwischenablage kopiert!'),
                  ),
                );
              },
              child: const Text("Ja, in Zwischenablage kopieren."),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Nein danke."),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraService.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConfig.recordingScreenMaxWidth),
                child: Column(
                  children: [
                Text(
                  '${AppConfig.getTaskInstruction(widget.task)}\n\n'
                  'Verbleibende Zeit: $_remainingTime s',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Show text area only while recording
                if (_isRecording)
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: "Beginne hier zu schreiben...",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                if (!_isRecording && _isCameraInitialized)
                  ElevatedButton(
                    onPressed: _startTimer,
                    child: const Text('Start Recording'),
                  ),
              ],
            ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
