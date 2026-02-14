import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/screens/auth/customer_signup_screen.dart';
import 'package:service_connect/screens/auth/professional_signup_screen.dart';
import 'package:service_connect/screens/auth/otp_verification_screen.dart';
import 'package:service_connect/screens/auth/sign_in_screen.dart';
import 'package:service_connect/screens/customer/booking_history_screen.dart';
import 'package:service_connect/screens/customer/chat_screen.dart';
import 'package:service_connect/screens/customer/matched_professionals_screen.dart';
import 'package:service_connect/screens/customer/create_request_screen.dart';
import 'package:service_connect/screens/customer/customer_home_screen.dart';
import 'package:service_connect/screens/customer/customer_profile_screen.dart';
import 'package:service_connect/screens/customer/customer_shell.dart';
import 'package:service_connect/screens/customer/offer_services_screen.dart';
import 'package:service_connect/screens/customer/payment_screen.dart';
import 'package:service_connect/screens/customer/professional_profile_screen.dart';
import 'package:service_connect/screens/customer/quotes_screen.dart';
import 'package:service_connect/screens/customer/radar_search_screen.dart';
import 'package:service_connect/screens/customer/review_screen.dart';
import 'package:service_connect/screens/customer/track_professional_screen.dart';
import 'package:service_connect/screens/landing_screen.dart';
import 'package:service_connect/screens/pro/pro_active_job_screen.dart';
import 'package:service_connect/screens/pro/pro_dashboard_screen.dart';
import 'package:service_connect/screens/pro/pro_job_details_screen.dart';
import 'package:service_connect/screens/pro/pro_profile_screen.dart';
import 'package:service_connect/models/service_category.dart';

import 'app_routes.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.landing,
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: AppRoutes.customerSignup,
          builder: (context, state) => const CustomerSignupScreen(),
        ),
        GoRoute(
          path: AppRoutes.proSignup,
          builder: (context, state) => const ProfessionalSignupScreen(),
        ),
        GoRoute(
          path: AppRoutes.otpVerification,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return OTPVerificationScreen(
              phone: data['phone'],
              deliveryMethod: data['deliveryMethod'],
            );
          },
        ),
        ShellRoute(
          builder: (context, state, child) => CustomerShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const CustomerHomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.customerProfile,
              builder: (context, state) => const CustomerProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) => const BookingHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.request,
          builder: (context, state) {
             final category = state.extra as ServiceCategory?;
             return CreateRequestScreen(category: category);
          },
        ),
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) => const RadarSearchScreen(),
        ),
        GoRoute(
          path: AppRoutes.quotes,
          builder: (context, state) => const QuotesScreen(),
        ),
        GoRoute(
          path: AppRoutes.review,
          builder: (context, state) => const ReviewScreen(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (context, state) => ChatScreen(roomId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: AppRoutes.payment,
          builder: (context, state) {
            final bookingData = state.extra as Map<String, dynamic>?;
            return PaymentScreen(bookingData: bookingData);
          },
        ),
        GoRoute(
          path: AppRoutes.matchedPros,
          builder: (context, state) {
            final data = state.extra as Map<String, String>? ?? {};
            return MatchedProfessionalsScreen(
              requestId: data['requestId'] ?? '',
              categoryName: data['categoryName'] ?? 'Service',
            );
          },
        ),
        GoRoute(
          path: AppRoutes.tracking,
          builder: (context, state) => TrackProfessionalScreen(bookingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: AppRoutes.proDashboard,
          builder: (context, state) => const ProDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.proJobDetails,
          builder: (context, state) => ProJobDetailsScreen(jobId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: AppRoutes.proActiveJob,
          builder: (context, state) => const ProActiveJobScreen(),
        ),
        GoRoute(
          path: AppRoutes.proProfile,
          builder: (context, state) => const ProProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.offerServices,
          builder: (context, state) => const OfferServicesScreen(),
        ),
        GoRoute(
          path: AppRoutes.professionalProfile,
          builder: (context, state) => ProfessionalProfileScreen(proId: state.pathParameters['proId']!),
        ),
      ],
    );
  }
}
