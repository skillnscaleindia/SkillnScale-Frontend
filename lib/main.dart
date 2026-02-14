import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/router/app_router.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_theme.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:service_connect/l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Locale provider for language switching
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe (Mobile only) — wrapped in try-catch
  // so a bad/missing key doesn't crash the whole app
  if (!kIsWeb) {
    try {
      Stripe.publishableKey = 'pk_test_mock_publishable_key';
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('⚠️ Stripe init failed (non-fatal): $e');
    }
  }

  // Initialize Auth Persistence
  final container = ProviderContainer();
  final authService = container.read(authServiceProvider);
  await authService.init();

  // Determine Initial Route
  String initialLocation = AppRoutes.landing;
  if (authService.isLoggedIn) {
    if (authService.userRole == 'pro') {
      initialLocation = AppRoutes.proDashboard;
    } else {
      initialLocation = AppRoutes.home;
    }
  }

  // Create Router with Initial Location
  final router = AppRouter.createRouter(initialLocation);

  // Lock Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Style Status Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ServiceConnectApp(router: router),
    ),
  );
}

class ServiceConnectApp extends ConsumerWidget {
  final GoRouter router;

  const ServiceConnectApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'SkillnScale',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
