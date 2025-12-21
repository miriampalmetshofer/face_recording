import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:facerecording/config/app_config.dart';
import 'package:permission_handler/permission_handler.dart';

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
    print('=== CAMERA INITIALIZATION START ===');

     // Let the camera plugin handle permissions natively - just try to access the camera
    print('Attempting to access cameras...');
    final cameras = await availableCameras();
    print('Found ${cameras.length} cameras');

    CameraDescription? frontCamera;
    for (var camera in cameras) {
      print('Camera: ${camera.name}, lens: ${camera.lensDirection}, sensorOrientation: ${camera.sensorOrientation}');
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }

    final selectedCamera = frontCamera ?? cameras.first;
    print('Selected camera: ${selectedCamera.name}');
    print('Creating controller with ResolutionPreset.medium, audio: false, NO FPS (testing)');

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      // TEMPORARILY REMOVED to test if fps: 30 is causing the issue
      // fps: AppConfig.cameraFps,
    );

    print('Calling controller.initialize()...');
    await _controller.initialize();

    print('Controller initialized!');
    print('isInitialized: ${_controller.value.isInitialized}');
    print('isRecordingVideo: ${_controller.value.isRecordingVideo}');
    print('isStreamingImages: ${_controller.value.isStreamingImages}');
    print('previewSize: ${_controller.value.previewSize}');
    print('errorDescription: ${_controller.value.errorDescription}');
    print('=== CAMERA INITIALIZATION COMPLETE ===');
  }

  @override
  Widget buildPreview() {
    if (!_controller.value.isInitialized) {
      print('buildPreview: Controller NOT initialized');
      return const Center(child: CircularProgressIndicator());
    }

    print('buildPreview: Building camera preview');
    print('  previewSize: ${_controller.value.previewSize}');
    print('  aspectRatio: ${_controller.value.aspectRatio}');
    print('  isStreamingImages: ${_controller.value.isStreamingImages}');
    print('  errorDescription: ${_controller.value.errorDescription}');

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

    print('  SizedBox dimensions: ${!kIsWeb ? "${size.height} x ${size.width}" : "${size.width} x ${size.height}"}');
    return FittedBox(fit: BoxFit.cover, child: preview);
  }

  @override
  Future<void> startVideoRecording() async {
    print('=== START VIDEO RECORDING ===');
    print('BEFORE - isRecordingVideo: ${_controller.value.isRecordingVideo}');
    print('BEFORE - isStreamingImages: ${_controller.value.isStreamingImages}');
    print('BEFORE - errorDescription: ${_controller.value.errorDescription}');

    await _controller.startVideoRecording();

    // Wait a moment for state to update
    await Future.delayed(const Duration(milliseconds: 100));

    print('AFTER - isRecordingVideo: ${_controller.value.isRecordingVideo}');
    print('AFTER - isStreamingImages: ${_controller.value.isStreamingImages}');
    print('AFTER - errorDescription: ${_controller.value.errorDescription}');
    print('=== RECORDING STARTED ===');
  }

  @override
  Future<XFile> stopVideoRecording() async {
    print('=== STOP VIDEO RECORDING ===');
    print('BEFORE - isRecordingVideo: ${_controller.value.isRecordingVideo}');

    final file = await _controller.stopVideoRecording();

    print('Video path: ${file.path}');

    // Check file immediately
    final videoFile = File(file.path);
    if (await videoFile.exists()) {
      final size = await videoFile.length();
      print('File size IMMEDIATELY after stop: $size bytes');

      if (size == 0) {
        print('WARNING: Video file is EMPTY!');
        print('This means the camera is not actually capturing frames.');
        print('errorDescription: ${_controller.value.errorDescription}');
      }
    } else {
      print('ERROR: Video file does NOT exist at path: ${file.path}');
    }

    print('=== RECORDING STOPPED ===');
    return file;
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
