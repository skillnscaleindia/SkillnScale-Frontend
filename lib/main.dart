import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_connect/router/app_router.dart';
import 'package:service_connect/theme/app_theme.dart';
import 'package:service_connect/services/mock_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mock Data
  await MockService.initialize();

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
    const ProviderScope(
      child: ServiceConnectApp(),
    ),
  );
}

class ServiceConnectApp extends StatelessWidget {
  const ServiceConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ServiceConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}