import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/screens/auth/customer_signup_screen.dart';
import 'package:service_connect/screens/auth/professional_signup_screen.dart';
import 'package:service_connect/screens/customer/chat_screen.dart';
import 'package:service_connect/screens/customer/create_request_screen.dart';
import 'package:service_connect/screens/customer/customer_home_screen.dart';
import 'package:service_connect/screens/customer/customer_shell.dart';
import 'package:service_connect/screens/customer/payment_screen.dart';
import 'package:service_connect/screens/customer/quotes_screen.dart';
import 'package:service_connect/screens/customer/radar_search_screen.dart';
import 'package:service_connect/screens/customer/tracking_screen.dart';
import 'package:service_connect/screens/landing_screen.dart';
import 'package:service_connect/screens/pro/pro_dashboard_screen.dart';
import 'package:service_connect/screens/pro/pro_job_details_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
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
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/request',
            builder: (context, state) => const CreateRequestScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const RadarSearchScreen(),
          ),
          GoRoute(
            path: '/quotes',
            builder: (context, state) => const QuotesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(quoteId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const TrackingScreen(),
      ),
      GoRoute(
        path: '/pro-dashboard',
        builder: (context, state) => const ProDashboardScreen(),
      ),
      GoRoute(
        path: '/pro/job-details/:id',
        builder: (context, state) => ProJobDetailsScreen(jobId: state.pathParameters['id']!),
      ),
    ],
  );
}
