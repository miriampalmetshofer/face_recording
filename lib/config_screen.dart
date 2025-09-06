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

  final _devices = ['Desktop', 'Mobile'];
  final _tasks = ['Task 1', 'Task 2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to the recording screen
              },
              child: const Text('Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
