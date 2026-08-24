import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Defines the active selection mode for the analog time picker.
enum TimePickerMode {
  /// Hour selection mode (00 to 23).
  hour,

  /// Minute selection mode (00 to 59).
  minute,
}

/// Visual theme and styling configuration for [CustomTimePickerWidget].
///
/// Allows customization of colors, text styles, button labels,
/// and display intervals for the clock dial.
class CustomTimePickerStyle {
  /// Background color of the top header displaying the selected time.
  final Color headerBackgroundColor;

  /// Text color of the active time unit (hour/minute) in the header.
  final Color headerSelectedTextColor;

  /// Text color of the inactive time unit in the header.
  final Color headerUnselectedTextColor;

  /// Background color of the analog clock face dial.
  final Color clockBackgroundColor;

  /// Color of the clock hand line and the selected number indicator circle.
  final Color activeHandColor;

  /// Text color for selectable (active) numbers on the clock face.
  final Color activeTextColor;

  /// Text color for disabled (out-of-range) numbers on the clock face.
  final Color disabledTextColor;

  /// Color for action buttons ([cancelText] and [acceptText]).
  final Color buttonTextColor;

  /// Label for the cancellation button. Defaults to `'BATAL'`.
  final String cancelText;

  /// Label for the confirmation button. Defaults to `'OK'`.
  final String acceptText;

  /// Numerical interval for displaying minute marks on the dial (e.g., 5 for 0, 5, 10, ...).
  final int minuteInterval;

  /// Creates a styling configuration for the custom analog time picker.
  const CustomTimePickerStyle({
    this.headerBackgroundColor = const Color(0xFF2196F3),
    this.headerSelectedTextColor = Colors.white,
    this.headerUnselectedTextColor = const Color(0x99FFFFFF),
    this.clockBackgroundColor = const Color(0xFFEDEDED),
    this.activeHandColor = const Color(0xFF2196F3),
    this.activeTextColor = Colors.black87,
    this.disabledTextColor = Colors.black26,
    this.buttonTextColor = const Color(0xFF2196F3),
    this.cancelText = 'BATAL',
    this.acceptText = 'OK',
    this.minuteInterval = 5,
  });
}

/// Displays a custom 24-hour analog time picker dialog.
///
/// Restricts operational hours using [startActiveHour], [startActiveMinute],
/// [endActiveHour], and [endActiveMinute]. Supports cross-midnight (overnight)
/// time ranges automatically.
///
/// Returns the selected [TimeOfDay], or `null` if the dialog is canceled.
Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  required int startActiveHour,
  required int startActiveMinute,
  required int endActiveHour,
  required int endActiveMinute,
  final Color? backgroundColor,
  bool Function(TimeOfDay pickedTime)? onValidate,
  CustomTimePickerStyle style = const CustomTimePickerStyle(),
}) {
  return showDialog<TimeOfDay>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 310,
          child: CustomTimePickerWidget(
            initialTime: initialTime,
            startActiveHour: startActiveHour,
            startActiveMinute: startActiveMinute,
            endActiveHour: endActiveHour,
            endActiveMinute: endActiveMinute,
            onValidate: onValidate,
            style: style,
          ),
        ),
      );
    },
  );
}

/// Core interactive widget rendering the 24-hour analog time picker dialog layout.
class CustomTimePickerWidget extends StatefulWidget {
  /// Initially highlighted time when the dialog opens.
  final TimeOfDay initialTime;

  /// Starting operational hour (0-23).
  final int startActiveHour;

  /// Starting operational minute (0-59).
  final int startActiveMinute;

  /// Ending operational hour (0-23).
  final int endActiveHour;

  /// Ending operational minute (0-59).
  final int endActiveMinute;

  /// Optional validation callback invoked when the user confirms their selection.
  /// Returning `false` prevents the dialog from closing.
  final bool Function(TimeOfDay pickedTime)? onValidate;

  /// Styling configuration for colors, text, and dial layout.
  final CustomTimePickerStyle style;

  /// Creates an instance of [CustomTimePickerWidget].
  const CustomTimePickerWidget({
    super.key,
    required this.initialTime,
    required this.startActiveHour,
    required this.startActiveMinute,
    required this.endActiveHour,
    required this.endActiveMinute,
    this.onValidate,
    required this.style,
  });

  @override
  State<CustomTimePickerWidget> createState() => _CustomTimePickerWidgetState();
}

class _CustomTimePickerWidgetState extends State<CustomTimePickerWidget> {
  late TimeOfDay _selectedTime;
  TimePickerMode _currentMode = TimePickerMode.hour;

  int get _startTotalMinutes =>
      widget.startActiveHour * 60 + widget.startActiveMinute;
  int get _endTotalMinutes =>
      widget.endActiveHour * 60 + widget.endActiveMinute;

  /// Checks if a given hour and minute combination falls within active operational bounds.
  bool _isTimeValid(int hour, int minute) {
    final total = hour * 60 + minute;
    if (_startTotalMinutes <= _endTotalMinutes) {
      // Standard daytime shift
      return total >= _startTotalMinutes && total <= _endTotalMinutes;
    } else {
      // Overnight / cross-midnight shift
      return total >= _startTotalMinutes || total <= _endTotalMinutes;
    }
  }

  /// Determines whether an entire hour is out of bounds and should be disabled on the dial.
  bool _isHourDisabled(int hour) {
    final startHourOfHour = hour * 60;
    final endHourOfHour = hour * 60 + 59;
    if (_startTotalMinutes <= _endTotalMinutes) {
      return endHourOfHour < _startTotalMinutes ||
          startHourOfHour > _endTotalMinutes;
    } else {
      return endHourOfHour < _startTotalMinutes &&
          startHourOfHour > _endTotalMinutes;
    }
  }

  /// Determines whether a specific minute mark is disabled.
  bool _isMinuteDisabled(int hour, int minute) {
    return !_isTimeValid(hour, minute);
  }

  @override
  void initState() {
    super.initState();
    if (!_isTimeValid(widget.initialTime.hour, widget.initialTime.minute)) {
      _selectedTime = TimeOfDay(
        hour: widget.startActiveHour,
        minute: widget.startActiveMinute,
      );
    } else {
      _selectedTime = widget.initialTime;
    }
  }

  void _onHourChanged(int hour) {
    int newMinute = _selectedTime.minute;

    if (!_isTimeValid(hour, newMinute)) {
      if (hour == widget.startActiveHour) {
        newMinute = widget.startActiveMinute;
      } else if (hour == widget.endActiveHour) {
        newMinute = widget.endActiveMinute;
      }
    }

    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: newMinute);
    });
  }

  void _onHourSelectionComplete() {
    setState(() {
      _currentMode = TimePickerMode.minute;
    });
  }

  void _onMinuteChanged(int minute) {
    if (!_isMinuteDisabled(_selectedTime.hour, minute)) {
      setState(() {
        _selectedTime = TimeOfDay(hour: _selectedTime.hour, minute: minute);
      });
    }
  }

  void _submit() {
    if (widget.onValidate != null) {
      final isValid = widget.onValidate!(_selectedTime);
      if (!isValid) return;
    }
    Navigator.of(context).pop(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Teks Jam : Menit
        CustomTimePickerHeader(
          selectedTime: _selectedTime,
          activeMode: _currentMode,
          style: widget.style,
          onModeChanged: (mode) {
            setState(() {
              _currentMode = mode;
            });
          },
        ),

        // Dial Jam / Menit Analog
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: widget.style.clockBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: _currentMode == TimePickerMode.hour
                  ? HourAnalogClock(
                      selectedHour: _selectedTime.hour,
                      isHourDisabled: _isHourDisabled,
                      onHourSelected: _onHourChanged,
                      onHourSelectionComplete: _onHourSelectionComplete,
                      style: widget.style,
                    )
                  : MinuteAnalogClock(
                      selectedHour: _selectedTime.hour,
                      selectedMinute: _selectedTime.minute,
                      isMinuteDisabled: (minute) =>
                          _isMinuteDisabled(_selectedTime.hour, minute),
                      onMinuteSelected: _onMinuteChanged,
                      style: widget.style,
                    ),
            ),
          ),
        ),

        // Tombol Konfirmasi (Batal / OK)
        Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  widget.style.cancelText,
                  style: TextStyle(
                    color: widget.style.buttonTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _submit,
                child: Text(
                  widget.style.acceptText,
                  style: TextStyle(
                    color: widget.style.buttonTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Header widget displaying the current time digits and mode toggle triggers.
class CustomTimePickerHeader extends StatelessWidget {
  /// The current selected time.
  final TimeOfDay selectedTime;

  /// Active selection mode ([TimePickerMode.hour] or [TimePickerMode.minute]).
  final TimePickerMode activeMode;

  /// Visual styling configuration.
  final CustomTimePickerStyle style;

  /// Callback when the user taps on the hour or minute digits.
  final ValueChanged<TimePickerMode> onModeChanged;

  /// Creates a header display widget.
  const CustomTimePickerHeader({
    super.key,
    required this.selectedTime,
    required this.activeMode,
    required this.style,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hourText = selectedTime.hour.toString().padLeft(2, '0');
    final minuteText = selectedTime.minute.toString().padLeft(2, '0');

    return Container(
      color: style.headerBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onModeChanged(TimePickerMode.hour),
            child: Text(
              hourText,
              style: TextStyle(
                color: activeMode == TimePickerMode.hour
                    ? style.headerSelectedTextColor
                    : style.headerUnselectedTextColor,
                fontSize: 60,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              color: style.headerSelectedTextColor,
              fontSize: 60,
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            onTap: () => onModeChanged(TimePickerMode.minute),
            child: Text(
              minuteText,
              style: TextStyle(
                color: activeMode == TimePickerMode.minute
                    ? style.headerSelectedTextColor
                    : style.headerUnselectedTextColor,
                fontSize: 60,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Concentric 24-hour analog dial selector (inner ring 00-11, outer ring 12-23).
class HourAnalogClock extends StatelessWidget {
  /// Currently selected hour digit.
  final int selectedHour;

  /// Function to check if a given hour is disabled.
  final bool Function(int hour) isHourDisabled;

  /// Callback invoked when an hour selection changes.
  final ValueChanged<int> onHourSelected;

  /// Callback invoked when touch drag or tap ends.
  final VoidCallback onHourSelectionComplete;

  /// Visual styling configuration.
  final CustomTimePickerStyle style;

  /// Creates an analog hour dial.
  const HourAnalogClock({
    super.key,
    required this.selectedHour,
    required this.isHourDisabled,
    required this.onHourSelected,
    required this.onHourSelectionComplete,
    required this.style,
  });

  void _handleInteraction(
    Offset position,
    Offset center,
    double innerRadius,
    double outerRadius,
  ) {
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    double angle = math.atan2(dy, dx);
    angle = (angle + (math.pi / 2)) % (2 * math.pi);

    double hourBase = (angle / (2 * math.pi)) * 12;
    int hour = hourBase.round() % 12;

    final threshold = (innerRadius + outerRadius) / 2;
    bool isOuter = distance > threshold;

    int finalHour = isOuter ? hour + 12 : hour;

    if (!isHourDisabled(finalHour)) {
      onHourSelected(finalHour);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final center = Offset(size / 2, size / 2);
        final innerRadius = (size / 2) * 0.55;
        final outerRadius = (size / 2) * 0.85;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) => _handleInteraction(
            details.localPosition,
            center,
            innerRadius,
            outerRadius,
          ),
          onPanUpdate: (details) => _handleInteraction(
            details.localPosition,
            center,
            innerRadius,
            outerRadius,
          ),
          onPanEnd: (_) => onHourSelectionComplete(),
          onTapDown: (details) => _handleInteraction(
            details.localPosition,
            center,
            innerRadius,
            outerRadius,
          ),
          onTapUp: (_) => onHourSelectionComplete(),
          child: Stack(
            children: [
              ..._buildClockNumbers(innerRadius, outerRadius, center),
              CustomPaint(
                size: Size(size, size),
                painter: ClockHandPainter(
                  selectedValue: selectedHour,
                  center: center,
                  innerRadius: innerRadius,
                  outerRadius: outerRadius,
                  isHour: true,
                  style: style,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildClockNumbers(
    double innerRadius,
    double outerRadius,
    Offset center,
  ) {
    final numberFontSize = innerRadius * 0.23;
    List<Widget> numbers = [];

    for (int i = 0; i < 24; i++) {
      bool isDisabled = isHourDisabled(i);
      int baseHour = i % 12;
      double angle = (baseHour / 12 * 2 * math.pi) - (math.pi / 2);
      double radius = (i < 12) ? innerRadius : outerRadius;

      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);

      final formattedHourText = i.toString().padLeft(2, '0');

      numbers.add(
        Positioned(
          left: x - (numberFontSize * 1.5),
          top: y - numberFontSize,
          child: IgnorePointer(
            child: Container(
              width: numberFontSize * 3,
              height: numberFontSize * 2,
              alignment: Alignment.center,
              child: Text(
                formattedHourText,
                style: TextStyle(
                  color: isDisabled
                      ? style.disabledTextColor
                      : style.activeTextColor,
                  fontSize: numberFontSize,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return numbers;
  }
}

/// 60-minute analog dial selector (00 through 59).
class MinuteAnalogClock extends StatelessWidget {
  /// Currently selected hour value.
  final int selectedHour;

  /// Currently selected minute value.
  final int selectedMinute;

  /// Function to check if a minute mark is disabled.
  final bool Function(int minute) isMinuteDisabled;

  /// Callback when a minute value is selected.
  final ValueChanged<int> onMinuteSelected;

  /// Visual styling configuration.
  final CustomTimePickerStyle style;

  /// Creates an analog minute dial.
  const MinuteAnalogClock({
    super.key,
    required this.selectedHour,
    required this.selectedMinute,
    required this.isMinuteDisabled,
    required this.onMinuteSelected,
    required this.style,
  });

  void _handleInteraction(Offset position, Offset center, double radius) {
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    double angle = math.atan2(dy, dx);
    angle = (angle + (math.pi / 2)) % (2 * math.pi);

    double minuteBase = (angle / (2 * math.pi)) * 60;
    int minute = minuteBase.round() % 60;

    if (!isMinuteDisabled(minute)) {
      onMinuteSelected(minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final center = Offset(size / 2, size / 2);
        final radius = (size / 2) * 0.85;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) =>
              _handleInteraction(details.localPosition, center, radius),
          onPanUpdate: (details) =>
              _handleInteraction(details.localPosition, center, radius),
          onTapDown: (details) =>
              _handleInteraction(details.localPosition, center, radius),
          child: Stack(
            children: [
              ..._buildMinuteNumbers(radius, center),
              CustomPaint(
                size: Size(size, size),
                painter: ClockHandPainter(
                  selectedValue: selectedMinute,
                  center: center,
                  innerRadius: radius,
                  outerRadius: radius,
                  isHour: false,
                  style: style,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMinuteNumbers(double radius, Offset center) {
    final numberFontSize = radius * 0.16;
    List<Widget> numbers = [];

    final step = style.minuteInterval;
    for (int i = 0; i < 60; i += step) {
      bool isDisabled = isMinuteDisabled(i);
      double angle = (i / 60 * 2 * math.pi) - (math.pi / 2);
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);

      numbers.add(
        Positioned(
          left: x - (numberFontSize * 1.5),
          top: y - numberFontSize,
          child: IgnorePointer(
            child: Container(
              width: numberFontSize * 3,
              height: numberFontSize * 2,
              alignment: Alignment.center,
              child: Text(
                i.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: isDisabled
                      ? style.disabledTextColor
                      : style.activeTextColor,
                  fontSize: numberFontSize,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return numbers;
  }
}

/// Custom painter rendering the analog clock hand indicator line and selected digit bubble.
class ClockHandPainter extends CustomPainter {
  /// Selected numerical value (hour or minute).
  final int selectedValue;

  /// Center offset of the clock dial.
  final Offset center;

  /// Radius for inner circle rendering (hours 0-11).
  final double innerRadius;

  /// Radius for outer circle rendering (hours 12-23 or minutes).
  final double outerRadius;

  /// True for hour mode, false for minute mode.
  final bool isHour;

  /// Visual styling configuration.
  final CustomTimePickerStyle style;

  /// Creates a painter instance for drawing clock hands.
  ClockHandPainter({
    required this.selectedValue,
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
    required this.isHour,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final handPaint = Paint()
      ..color = style.activeHandColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = style.activeHandColor
      ..style = PaintingStyle.fill;

    double angle;
    double radius;

    if (isHour) {
      int baseHour = selectedValue % 12;
      angle = (baseHour / 12 * 2 * math.pi) - (math.pi / 2);
      radius = (selectedValue >= 12) ? outerRadius : innerRadius;
    } else {
      angle = (selectedValue / 60 * 2 * math.pi) - (math.pi / 2);
      radius = outerRadius;
    }

    final endX = center.dx + radius * math.cos(angle);
    final endY = center.dy + radius * math.sin(angle);
    final endPoint = Offset(endX, endY);

    canvas.drawLine(center, endPoint, handPaint);

    bool isCustomMinuteValue =
        !isHour && (selectedValue % style.minuteInterval != 0);

    double endCircleRadius;
    if (isHour) {
      endCircleRadius = innerRadius * 0.24;
    } else {
      endCircleRadius = outerRadius * (isCustomMinuteValue ? 0.12 : 0.16);
    }

    canvas.drawCircle(endPoint, endCircleRadius, circlePaint);
    canvas.drawCircle(center, 3.0, circlePaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final textString = selectedValue.toString().padLeft(2, '0');

    double fontSize;
    if (isHour) {
      fontSize = endCircleRadius * 0.85;
    } else {
      fontSize = endCircleRadius * (isCustomMinuteValue ? 0.8 : 0.9);
    }

    textPainter.text = TextSpan(
      text: textString,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();

    textPainter.paint(
      canvas,
      endPoint - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(ClockHandPainter oldDelegate) {
    return oldDelegate.selectedValue != selectedValue ||
        oldDelegate.isHour != isHour;
  }
}
