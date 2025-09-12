import 'dart:async';
import 'package:facerecording/web_utils.dart'
    if (dart.library.html) 'package:facerecording/web_utils_web.dart';
import 'package:facerecording/camera_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:facerecording/app_config.dart';

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

    if (kIsWeb) {
      downloadVideoWeb(file, widget.name, widget.task);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Video downloaded.')));
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toIso8601String().replaceAll(':', '-');
      final path = '${directory.path}/${widget.name}_${widget.task}_$date.mp4';
      await file.saveTo(path);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video saved to: $path')));
    }

    if (_textEditingController.text.trim().isNotEmpty) {
      showDialog(
        context: context,
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
            Column(
              children: [
                Text(
                  'Stell dir vor, du wachst eines Morgens auf und das Internet existiert nicht mehr. '
                  'Schreibe eine kurze Geschichte darüber, wie dein Tag aussehen würde\n\n'
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
          ],
        ),
      ),
    );
  }
}
