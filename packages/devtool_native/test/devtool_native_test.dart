import 'package:devtool_native/devtool_native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('crash invokes the channel; throws without a native handler', () async {
    const NativeCrashChannel channel = NativeCrashChannel();
    // In tests there is no native side, so the channel call throws.
    await expectLater(channel.crash(), throwsA(isA<MissingPluginException>()));
  });
}
