import 'package:devtool_h5/devtool_h5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders URL/header/UA/JS inputs and the open button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: H5ConsolePage(
          webViewFactory: (_) => const SizedBox(),
        ),
      ),
    );

    // URL, Header, User-Agent, JavaScript = 4 text fields.
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('打开'), findsOneWidget);
    expect(find.text('H5 任意门'), findsOneWidget);
  });
}
