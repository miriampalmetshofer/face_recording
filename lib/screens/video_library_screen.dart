import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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
      _videos.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => _onShareVideo(video.path),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteVideo(video),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _confirmDeleteVideo(FileSystemEntity video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Video'),
          content: Text('Are you sure you want to delete ${video.path.split('/').last}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteVideo(video);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteVideo(FileSystemEntity video) async {
    try {
      await video.delete();
      _loadVideos(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video ${video.path.split('/').last} deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete video: $e')),
      );
    }
  }

  void _onShareVideo(String videoPath) async {
    final File file = File(videoPath);
    final result = await ImageGallerySaver.saveFile(file.path, isReturnPathOfIOS: true);

    if (result['isSuccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video saved to gallery")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save video")),
      );
    }
  }

}
