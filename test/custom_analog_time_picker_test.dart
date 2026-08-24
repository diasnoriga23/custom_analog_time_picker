import 'package:flutter_test/flutter_test.dart';
import 'package:custom_analog_time_picker/custom_analog_time_picker.dart';

void main() {
  testWidgets('CustomTimePickerStyle initializes with default values',
      (WidgetTester tester) async {
    const style = CustomTimePickerStyle();

    expect(style.cancelText, 'CANCEL');
    expect(style.acceptText, 'OK');
    expect(style.minuteInterval, 5);
  });
}
