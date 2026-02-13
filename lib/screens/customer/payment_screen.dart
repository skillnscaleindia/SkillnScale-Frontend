import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/services/data_service.dart';
import 'package:service_connect/services/payment_service.dart';
import 'package:service_connect/l10n/app_localizations.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? bookingData;
  const PaymentScreen({this.bookingData, super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'upi';
  final _upiController = TextEditingController();
  bool _processing = false;

  double get _amount {
    final price = widget.bookingData?['agreed_price'] ??
        widget.bookingData?['total_amount'] ??
        0;
    return (price as num).toDouble();
  }

  String get _serviceName {
    return widget.bookingData?['notes'] as String? ?? 'Service Booking';
  }

  String get _bookingId {
    return widget.bookingData?['id'] as String? ?? '';
  }

  Future<void> _processPayment() async {
    setState(() => _processing = true);

    try {
      if (_selectedMethod == 'card') {
        await _handleStripePayment();
      } else {
        // Simulate other payment methods
        await Future.delayed(const Duration(seconds: 2));
        _onPaymentSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _handleStripePayment() async {
    final paymentService = ref.read(paymentServiceProvider);
    
    // 1. Initialize Sheet
    await paymentService.initPaymentSheet(bookingId: _bookingId);
    
    // 2. Present Sheet
    await paymentService.presentPaymentSheet();
    
    _onPaymentSuccess();
  }

  void _onPaymentSuccess() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Payment successful!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
      
      final route = AppRoutes.tracking.replaceFirst(':id', _bookingId);
      context.push(route);
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payment)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.totalAmount,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _serviceName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Payment Methods
                  Text(l10n.paymentMethod,
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    theme: theme,
                    icon: LucideIcons.smartphone,
                    title: l10n.upi,
                    subtitle: 'Google Pay, PhonePe, Paytm',
                    value: 'upi',
                  ),
                  const SizedBox(height: 10),

                  // UPI ID Input (show when UPI selected)
                  if (_selectedMethod == 'upi')
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.15),
                        ),
                      ),
                      child: TextField(
                        controller: _upiController,
                        decoration: InputDecoration(
                          hintText: l10n.enterUpiId,
                          prefixText: '  ',
                          suffixIcon: Icon(LucideIcons.atSign,
                              size: 18, color: AppColors.accent),
                          border: InputBorder.none,
                          hintStyle: theme.textTheme.bodyMedium!
                              .copyWith(color: AppColors.lightSubtitle),
                        ),
                      ),
                    ),

                  _buildPaymentOption(
                    theme: theme,
                    icon: LucideIcons.creditCard,
                    title: l10n.creditCard,
                    subtitle: '**** **** **** 4242',
                    value: 'card',
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    theme: theme,
                    icon: LucideIcons.banknote,
                    title: l10n.cash,
                    subtitle: l10n.payAfterService,
                    value: 'cash',
                  ),

                  // Cash Note
                  if (_selectedMethod == 'cash')
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.info,
                              size: 18, color: Colors.amber[700]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pay ₹${_amount.toStringAsFixed(0)} in cash directly to the professional after service completion.',
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: Colors.amber[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Pay Button
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _processing ? null : _processPayment,
                child: _processing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _selectedMethod == 'cash'
                            ? 'Confirm Booking'
                            : '${l10n.payNow} ₹${_amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.06)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : theme.colorScheme.outline.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.1)
                    : theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color:
                    isSelected ? AppColors.accent : AppColors.lightSubtitle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.lightSubtitle,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
