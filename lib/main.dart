import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/router/app_router.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_theme.dart';
import 'package:service_connect/services/mock_service.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:service_connect/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  // await MockService.initialize(); // Removed for Backend Integration
  
  // Initialize Auth Persistence
  // We need a temporary container to read the provider and init it
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

class ServiceConnectApp extends StatelessWidget {
  final GoRouter router;

  const ServiceConnectApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ServiceConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
