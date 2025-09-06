import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class CameraService {
  Future<void> initialize();
  Widget buildPreview();
  Future<void> startVideoRecording();
  Future<XFile> stopVideoRecording();
  void dispose();
  bool get isInitialized;
}

class MobileAndWebCameraService implements CameraService {
  late CameraController _controller;

  @override
  Future<void> initialize() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    await _controller.initialize();
  }

  @override
  Widget buildPreview() {
    return CameraPreview(_controller);
  }

  @override
  Future<void> startVideoRecording() async {
    await _controller.startVideoRecording();
  }

  @override
  Future<XFile> stopVideoRecording() async {
    return await _controller.stopVideoRecording();
  }

  @override
  void dispose() {
    _controller.dispose();
  }

  @override
  bool get isInitialized => _controller.value.isInitialized;
}

CameraService getCameraService() {
  if (kIsWeb || Platform.isIOS) {
    return MobileAndWebCameraService();
  } else {
    throw UnsupportedError('Platform not supported');
  }
}
