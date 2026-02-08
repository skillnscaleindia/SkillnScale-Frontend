import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/screens/auth/customer_signup_screen.dart';
import 'package:service_connect/screens/auth/professional_signup_screen.dart';
import 'package:service_connect/screens/customer/customer_home_screen.dart';
import 'package:service_connect/screens/landing_screen.dart';
import 'package:service_connect/screens/pro/pro_dashboard_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/signup/customer',
        builder: (context, state) => const CustomerSignupScreen(),
      ),
      GoRoute(
        path: '/signup/pro',
        builder: (context, state) => const ProfessionalSignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/pro-dashboard',
        builder: (context, state) => const ProDashboardScreen(),
      ),
    ],
  );
}
