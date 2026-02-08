import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/providers/user_provider.dart';
import 'package:service_connect/theme/app_theme.dart';

class ProfessionalSignupScreen extends ConsumerStatefulWidget {
  const ProfessionalSignupScreen({super.key});

  @override
  ConsumerState<ProfessionalSignupScreen> createState() => _ProfessionalSignupScreenState();
}

class _ProfessionalSignupScreenState extends ConsumerState<ProfessionalSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _serviceCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Professional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mobile'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Service Category'),
                value: _serviceCategory,
                items: ['Plumber', 'Electrician', 'Carpenter', 'Painter', 'Cleaner']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _serviceCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a service category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: AppTheme.primaryColor,
                strokeWidth: 2,
                dashPattern: const [8, 4],
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.upload,
                        color: AppTheme.primaryColor,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Upload ID',
                        style: TextStyle(fontSize: 18, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref.read(userRoleProvider.notifier).state = UserRole.pro;
                    context.go('/pro-dashboard');
                  }
                },
                child: const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
