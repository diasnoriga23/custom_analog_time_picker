# Custom Analog Time Picker

A customizable 24-hour analog time picker dialog for Flutter applications with operational hours restriction, minute intervals, custom styling, and overnight shift validation.

## Features

- 🕒 **24-Hour Analog Clock**: Dual-ring layout for 00:00 to 23:59 selection.
- ⚡ **Time Restrictions**: Restrict hour and minute selections within custom operational hours.
- 🌙 **Overnight Shift Ready**: Safely handles cross-midnight time ranges.
- 🎨 **Fully Customizable**: Style header, hand color, background, and text colors.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  custom_analog_time_picker: ^1.0.0
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:custom_analog_time_picker/custom_analog_time_picker.dart';

Future<void> _selectTime(BuildContext context) async {
  final TimeOfDay? picked = await showCustomTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    startActiveHour: 8,
    startActiveMinute: 0,
    endActiveHour: 17,
    endActiveMinute: 0,
    style: const CustomTimePickerStyle(
      headerBackgroundColor: Colors.blue,
      activeHandColor: Colors.blue,
      buttonTextColor: Colors.blue,
    ),
  );

  if (picked != null) {
    debugPrint("Selected time: ${picked.format(context)}");
  }
}
```

## Additional Information

For issues, feature requests, or contributions, please visit the [GitHub Repository](https://github.com/diasnoriga23/custom_analog_time_picker).
