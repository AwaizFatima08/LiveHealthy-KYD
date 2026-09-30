import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/links.dart';
import '../core/content/models.dart';

/// "Track it" (§9): opens the sibling app when installed, otherwise its
/// Play Store page.
class ToolLauncher {
  static const MethodChannel _channel = MethodChannel('livehealthy_kyd/apps');

  const ToolLauncher();

  Future<bool> isInstalled(ToolApp app) async {
    try {
      return await _channel.invokeMethod<bool>('isInstalled', {'package': app.packageName}) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns false if neither the app nor a store page could be opened.
  Future<bool> open(ToolApp app) async {
    try {
      final opened = await _channel.invokeMethod<bool>('open', {'package': app.packageName}) ?? false;
      if (opened) return true;
    } on PlatformException {
      // fall through to the store
    } on MissingPluginException {
      // fall through to the store
    }
    final market = Uri.parse('market://details?id=${app.packageName}');
    try {
      if (await launchUrl(market, mode: LaunchMode.externalApplication)) return true;
    } catch (_) {
      // no Play Store app; try the web page
    }
    return launchUrl(Uri.parse(Links.playStore(app.packageName)), mode: LaunchMode.externalApplication);
  }
}
