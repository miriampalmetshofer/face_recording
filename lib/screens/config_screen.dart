import 'package:facerecording/screens/enrollment_screen.dart';
import 'package:facerecording/screens/recording_screen.dart';
import 'package:facerecording/screens/video_library_screen.dart';
import 'package:facerecording/config/app_config.dart';
import 'package:flutter/material.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _nameController = TextEditingController();
  String? _selectedDevice;
  String? _selectedTask;
  String? _selectedSetting;

  final _devices = ['Desktop', 'Mobile'];
  final _tasks = ['Task1', 'Task2'];
  final _settings = ['easy', 'angle', 'lighting'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VideoLibraryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConfig.configScreenMaxWidth),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDevice,
              hint: const Text('Select a Device'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDevice = newValue;
                });
              },
              items: _devices.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedTask,
              hint: const Text('Select a Task'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTask = newValue;
                });
              },
              items: _tasks.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSetting,
              hint: const Text('Select a Setting'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSetting = newValue;
                });
              },
              items: _settings.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_selectedTask != null &&
                    _selectedDevice != null &&
                    _selectedSetting != null &&
                    _nameController.text.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecordingScreen(
                        name: _nameController.text,
                        device: _selectedDevice!,
                        task: _selectedTask!,
                        setting: _selectedSetting!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Start Recording'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _selectedDevice != null &&
                    _selectedSetting != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EnrollmentScreen(
                        name: _nameController.text,
                        device: _selectedDevice!,
                        setting: _selectedSetting!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields for enrollment'),
                    ),
                  );
                }
              },
              child: const Text('Enrollment'),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
