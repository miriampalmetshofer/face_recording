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
    CameraDescription? frontCamera;
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }

    _controller = CameraController(
      frontCamera ?? cameras.first,
      ResolutionPreset.medium,
    );
    await _controller.initialize();
  }

  @override
  Widget buildPreview() {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final size = _controller.value.previewSize!;

    final preview = !kIsWeb
        ? SizedBox(
            width: size.height,
            height: size.width,
            child: CameraPreview(_controller),
          )
        : SizedBox(
            width: size.width,
            height: size.height,
            child: CameraPreview(_controller),
          );

    return FittedBox(fit: BoxFit.cover, child: preview);
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
