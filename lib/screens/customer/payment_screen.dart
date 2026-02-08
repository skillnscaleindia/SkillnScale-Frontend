import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/theme/app_theme.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showPaymentSheet(context),
          child: const Text('Show Payment Sheet'),
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total: \$45', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile(
                title: const Text('Credit/Debit Card'),
                value: 'card',
                groupValue: 'card',
                onChanged: (value) {},
              ),
              RadioListTile(
                title: const Text('Cash'),
                value: 'cash',
                groupValue: 'card', // Change to a state variable
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/tracking'),
                  child: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
