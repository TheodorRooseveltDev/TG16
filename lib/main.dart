import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meta_sdk/flutter_meta_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Lock to portrait mode for iOS
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: LuxurLoungeApp(),
    ),
  );

  // Fire-and-forget Meta SDK init so UI isn't blocked.
  unawaited(_initMetaSdk());
}

Future<void> _initMetaSdk() async {
  try {
    final sdk = FlutterMetaSdk();
    await sdk.setAutoLogAppEventsEnabled(true);
    await sdk.activateApp();
  } catch (_) {}
}
