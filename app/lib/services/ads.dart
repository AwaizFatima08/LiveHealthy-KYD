import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

/// AdMob banner "Home banner" in app "LiveHealthy: Know Your Disease"
/// (ca-app-pub-2087846699268567~1254923561, account homilabs.smc@gmail.com).
/// Debug and profile builds use Google's test adaptive banner.
const String _liveBannerId = 'ca-app-pub-2087846699268567/9432796487';
const String _testBannerId = 'ca-app-pub-3940256099942544/9214589741';
const String bannerAdUnitId = kReleaseMode ? _liveBannerId : _testBannerId;

/// Consent first (Google UMP), then the Mobile Ads SDK. Ads never block
/// reading: if consent or the SDK fails, the app simply shows no banner.
class AdsController extends ChangeNotifier {
  /// False in widget tests and anywhere the ad SDK must not run.
  final bool enabled;
  AdsController({this.enabled = true});
  AdsController.off() : enabled = false;

  bool _ready = false;
  bool _privacyOptionsRequired = false;

  /// True once consent is resolved and ads may be requested.
  bool get ready => enabled && _ready;

  /// Whether Settings must offer "Ad privacy choices" (EEA/UK users).
  bool get privacyOptionsRequired => enabled && _privacyOptionsRequired;

  Future<void> init() async {
    if (!enabled) return;
    try {
      final done = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          if (!done.isCompleted) done.complete();
        },
        (_) {
          // Offline or error: fall back to whatever consent is stored.
          if (!done.isCompleted) done.complete();
        },
      );
      await done.future;

      final status = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      _privacyOptionsRequired = status == PrivacyOptionsRequirementStatus.required;

      if (await ConsentInformation.instance.canRequestAds()) {
        await MobileAds.instance.initialize();
        _ready = true;
      }
    } catch (e) {
      debugPrint('Ads unavailable: $e');
    }
    notifyListeners();
  }

  Future<void> showPrivacyOptions() async {
    if (!enabled) return;
    ConsentForm.showPrivacyOptionsForm((_) {});
  }
}

/// Anchored adaptive banner. Only on Home and Settings: never on a topic,
/// section, reference, "When to see a doctor" or onboarding screen, so an
/// ad is never placed next to medical advice.
class BannerSlot extends StatefulWidget {
  const BannerSlot({super.key});

  @override
  State<BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;
  int? _requestedWidth;

  Future<void> _load(int width) async {
    _requestedWidth = width;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      MediaQuery.orientationOf(context),
      width,
    );
    if (!mounted || size == null) return;
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    setState(() => _ad = ad);
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AdsController>().ready) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.truncate();
        if (_requestedWidth == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _requestedWidth == null) _load(width);
          });
        }
        final ad = _ad;
        if (ad == null || !_loaded) return const SizedBox.shrink();
        return SafeArea(
          top: false,
          child: SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        );
      },
    );
  }
}
