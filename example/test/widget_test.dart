import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders the debug center button', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('打开调试中心'), findsOneWidget);
  });
}
