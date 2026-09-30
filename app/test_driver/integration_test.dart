import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves screenshots taken by integration_test/app_flow_test.dart into
/// ../store/graphics/screenshots/ (or \$E2E_SHOTS_DIR).
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Platform.environment['E2E_SHOTS_DIR'] ?? '../store/graphics/screenshots';
      final file = File('$dir/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
