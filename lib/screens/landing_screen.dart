import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100),
          const Center(
            child: Text(
              'ServiceConnect',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: InkWell(
              onTap: () => context.push('/signup/customer'),
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.house, size: 64, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'I need a Service',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => context.push('/signup/pro'),
              child: Card(
                margin: const EdgeInsets.all(16),
                color: AppTheme.darkGreyColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.briefcase, size: 64, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'I am a Professional',
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement Sign In
            },
            child: const Text('Already have an account? Sign In'),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
