import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_connect/router/app_router.dart';
import 'package:service_connect/theme/app_theme.dart';

void main() {
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
