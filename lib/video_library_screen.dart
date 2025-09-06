import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  List<FileSystemEntity> _videos = [];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadVideos();
    }
  }

  Future<void> _loadVideos() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    setState(() {
      _videos = files.where((file) => file.path.endsWith('.mp4')).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Library'),
      ),
      body: kIsWeb
          ? const Center(
              child: Text('Video library is not available on web.'),
            )
          : ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return ListTile(
                  title: Text(video.path.split('/').last),
                );
              },
            ),
    );
  }
}
