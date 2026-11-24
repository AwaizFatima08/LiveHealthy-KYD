import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/services/ads.dart';

void main() {
  test('ads may only be placed on Home and Settings', () {
    // A banner next to health information could read as medical advice, so
    // only these two screens may use BannerSlot.
    final users = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('services/ads.dart'))
        .where((f) => f.readAsStringSync().contains('BannerSlot('))
        .map((f) => f.path.replaceAll(r'\', '/'))
        .toSet();
    expect(users, {'lib/screens/home_screen.dart', 'lib/screens/settings_screen.dart'});
  });

  test('a disabled controller never shows ads or ad choices', () async {
    final ads = AdsController.off();
    await ads.init();
    expect(ads.ready, isFalse);
    expect(ads.privacyOptionsRequired, isFalse);
  });

  test('debug and test builds use Google test banner, never the live unit', () {
    expect(bannerAdUnitId, 'ca-app-pub-3940256099942544/9214589741');
  });
}
