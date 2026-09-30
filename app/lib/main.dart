import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/content_repository.dart';
import 'services/tool_launcher.dart';
import 'services/update_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final firestore = await _initFirebase();
  final info = await PackageInfo.fromPlatform();

  final repository = ContentRepository(
    bundle: rootBundle,
    cacheDir: () async {
      try {
        return await getApplicationSupportDirectory();
      } catch (_) {
        return null;
      }
    },
  );
  await repository.load();

  final updates = UpdateService(
    firestore: firestore,
    repository: repository,
    prefs: prefs,
    appBuild: int.tryParse(info.buildNumber) ?? 1,
  );

  runApp(
    KnowYourDiseaseApp(
      settings: AppSettings(prefs),
      repository: repository,
      updates: updates,
      appVersion: '${info.version} (${info.buildNumber})',
    ),
  );
  // Online-only, at most once a day, never blocks reading (§7).
  unawaited(updates.checkForUpdates());
}

/// Firebase is only used for content updates and crash reports. If it fails
/// to start, the app still works fully from bundled content.
Future<FirebaseFirestore?> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    final crashlytics = FirebaseCrashlytics.instance;
    // Crash reports only (D4), and none from debug builds.
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    // Debug builds (and tests) keep Flutter's own error handling, so errors
    // show up in the console and fail tests instead of vanishing.
    if (!kDebugMode) {
      FlutterError.onError = crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    }
    final db = FirebaseFirestore.instance;
    // Downloaded content is stored by ContentRepository; Firestore's own
    // cache would only serve stale copies back to the update check.
    db.settings = const Settings(persistenceEnabled: false);
    _useEmulatorIfRequested(db);
    return db;
  } catch (e) {
    debugPrint('Firebase unavailable, bundled content only: $e');
    return null;
  }
}

/// Debug-only: `--dart-define=FIRESTORE_EMULATOR_HOST=10.0.2.2` reads content
/// from a local emulator. Ignored in release builds.
void _useEmulatorIfRequested(FirebaseFirestore db) {
  const host = String.fromEnvironment('FIRESTORE_EMULATOR_HOST');
  if (host.isEmpty || kReleaseMode) return;
  db.useFirestoreEmulator(host, 8086);
  debugPrint('Using Firestore emulator at $host');
}

/// All dependencies are passed in, so tests can build the whole app.
class KnowYourDiseaseApp extends StatelessWidget {
  final AppSettings settings;
  final ContentRepository repository;
  final UpdateService? updates;
  final ToolLauncher toolLauncher;
  final String appVersion;

  const KnowYourDiseaseApp({
    super.key,
    required this.settings,
    required this.repository,
    this.updates,
    this.toolLauncher = const ToolLauncher(),
    this.appVersion = '',
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>.value(value: settings),
        ChangeNotifierProvider<ContentRepository>.value(value: repository),
        Provider<UpdateService?>.value(value: updates),
        Provider<ToolLauncher>.value(value: toolLauncher),
        Provider<AppVersion>.value(value: AppVersion(appVersion)),
      ],
      child: Consumer<AppSettings>(
        builder: (context, s, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(languageCode: s.languageCode),
            locale: Locale(s.languageCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) {
              // The reader's text size multiplies the phone's own font
              // setting, capped so layouts stay usable.
              final mq = MediaQuery.of(context);
              final system = mq.textScaler.scale(1);
              final scale = (system * s.textSize.factor).clamp(1.0, 2.0);
              return MediaQuery(data: mq.copyWith(textScaler: TextScaler.linear(scale)), child: child!);
            },
            home: s.disclaimerAccepted ? const HomeScreen() : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

/// Wrapper so the version string has its own provider type.
class AppVersion {
  final String value;
  const AppVersion(this.value);
}
