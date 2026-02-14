import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/providers/user_provider.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/services/auth_service.dart';

class ProfessionalSignupScreen extends ConsumerStatefulWidget {
  const ProfessionalSignupScreen({super.key});

  @override
  ConsumerState<ProfessionalSignupScreen> createState() =>
      _ProfessionalSignupScreenState();
}

class _ProfessionalSignupScreenState
    extends ConsumerState<ProfessionalSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _serviceCategory;
  String _deliveryMethod = 'sms';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authServiceProvider).signUp(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          role: 'pro',
          serviceCategory: _serviceCategory,
          deliveryMethod: _deliveryMethod,
        );
        if (mounted) {
          context.push(AppRoutes.otpVerification, extra: {
            'phone': _phoneController.text.trim(),
            'deliveryMethod': _deliveryMethod,
          });
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Signup failed: $e')),
           );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Top gradient header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44B09E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Become a\nProfessional 🛠️',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Grow your business with us',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text('Full Name', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(LucideIcons.user, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Email', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(LucideIcons.mail, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Password', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Create a password',
                        prefixIcon: Icon(LucideIcons.lock, size: 20),
                      ),
                      validator: (value) {
                         if (value == null || value.length < 6) return 'Min 6 characters';
                         return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Mobile Number', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your mobile number',
                        prefixIcon: Icon(LucideIcons.phone, size: 20),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('OTP Delivery Method', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _deliveryMethod = 'sms'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _deliveryMethod == 'sms' 
                                  ? AppColors.accent.withOpacity(0.1) 
                                  : Colors.transparent,
                                border: Border.all(
                                  color: _deliveryMethod == 'sms' 
                                    ? AppColors.accent 
                                    : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.phone, 
                                    color: _deliveryMethod == 'sms' ? AppColors.accent : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SMS',
                                    style: TextStyle(
                                      color: _deliveryMethod == 'sms' ? AppColors.accent : Colors.grey,
                                      fontWeight: _deliveryMethod == 'sms' ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _deliveryMethod = 'whatsapp'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _deliveryMethod == 'whatsapp' 
                                  ? const Color(0xFF25D366).withOpacity(0.1) 
                                  : Colors.transparent,
                                border: Border.all(
                                  color: _deliveryMethod == 'whatsapp' 
                                    ? const Color(0xFF25D366) 
                                    : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.messageSquare, 
                                    color: _deliveryMethod == 'whatsapp' ? const Color(0xFF25D366) : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'WhatsApp',
                                    style: TextStyle(
                                      color: _deliveryMethod == 'whatsapp' ? const Color(0xFF25D366) : Colors.grey,
                                      fontWeight: _deliveryMethod == 'whatsapp' ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Service Category', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Select your specialty',
                        prefixIcon: Icon(LucideIcons.briefcase, size: 20),
                      ),
                      value: _serviceCategory,
                      items: [
                        'Plumber',
                        'Electrician',
                        'Carpenter',
                        'Painter',
                        'Cleaner',
                        'Salon',
                        'AC Repair',
                        'Pest Control',
                      ]
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _serviceCategory = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a category';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text('Upload ID Proof', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(14),
                      color: AppColors.accent,
                      strokeWidth: 1.5,
                      dashPattern: const [8, 4],
                      child: Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.upload,
                                color: AppColors.accent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap to upload your ID',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Aadhaar, PAN, or Driving License',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.lightSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        child: _isLoading 
                           ? const CircularProgressIndicator(color: Colors.white)
                           : const Text('Submit Application', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
