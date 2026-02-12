import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';

class ProActiveJobScreen extends StatefulWidget {
  const ProActiveJobScreen({super.key});

  @override
  State<ProActiveJobScreen> createState() => _ProActiveJobScreenState();
}

class _ProActiveJobScreenState extends State<ProActiveJobScreen> {
  final _codeController = TextEditingController();
  Timer? _timer;
  int _seconds = 0;
  bool _started = false;

  void _start() {
    if (_codeController.text != '4589') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _started = true);
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => setState(() => _seconds++),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Job'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_started) ...[
              // Verification
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.keyRound,
                  size: 36,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Start Code',
                style: theme.textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask the customer for their 4-digit code',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: AppColors.lightSubtitle,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                style: theme.textTheme.displayMedium!.copyWith(
                  letterSpacing: 12,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '• • • •',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _start,
                  child: const Text(
                    'Verify & Start',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ] else ...[
              // Timer
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.2),
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${Duration(seconds: _seconds).inMinutes.toString().padLeft(2, '0')}:${(Duration(seconds: _seconds).inSeconds % 60).toString().padLeft(2, '0')}',
                    style: theme.textTheme.displayLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Job In Progress',
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              SlideAction(
                onSubmit: () {
                  _timer?.cancel();
                  context.go(AppRoutes.proDashboard);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job Completed! 🎉'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  return null;
                },
                text: 'Slide to Finish',
                innerColor: AppColors.accent,
                outerColor: AppColors.accent.withOpacity(0.12),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}