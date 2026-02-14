import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final String deliveryMethod;

  const OTPVerificationScreen({
    super.key,
    required this.phone,
    required this.deliveryMethod,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpController.text.length < 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).verifyOtp(
            widget.phone,
            _otpController.text,
          );
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(
              widget.deliveryMethod == 'whatsapp' ? LucideIcons.messageSquare : LucideIcons.phone,
              size: 64,
              color: AppColors.accent,
            ),
            const SizedBox(height: 24),
            Text(
              'Enter verification code',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to your ${widget.deliveryMethod} at ${widget.phone}',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSubtitle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                errorText: _errorMessage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify and Continue'),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _isLoading ? null : () {
                // In a real app, trigger resend
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP resent successfully!')),
                );
              },
              child: const Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
