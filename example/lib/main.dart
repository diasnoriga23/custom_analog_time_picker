import 'package:flutter/material.dart';
import 'package:custom_analog_time_picker/custom_analog_time_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleHomeScreen(),
    );
  }
}

class ExampleHomeScreen extends StatefulWidget {
  const ExampleHomeScreen({super.key});

  @override
  State<ExampleHomeScreen> createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen> {
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Time Picker Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedTime != null
                  ? 'Selected: ${_selectedTime!.format(context)}'
                  : 'No time selected',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await showCustomTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  startActiveHour: 8,
                  startActiveMinute: 0,
                  endActiveHour: 17,
                  endActiveMinute: 0,
                );
                if (result != null) {
                  setState(() {
                    _selectedTime = result;
                  });
                }
              },
              child: const Text('Open Time Picker'),
            ),
          ],
        ),
      ),
    );
  }
}
