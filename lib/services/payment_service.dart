import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentService(apiClient);
});

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  Future<void> initPaymentSheet({required String bookingId}) async {
    try {
      // 1. Create Payment Intent on Backend
      final response = await _apiClient.client.post(
        '/payments/create-payment-intent',
        queryParameters: {'booking_id': bookingId},
      );

      final data = response.data;
      final clientSecret = data['client_secret'];
      
      // 2. Initialize Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SkillnScale',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF6750A4),
            ),
          ),
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize payment: $e');
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      if (e is StripeException) {
        throw Exception('Payment cancelled or failed: ${e.error.localizedMessage}');
      } else {
        throw Exception('Payment failed: $e');
      }
    }
  }
}
