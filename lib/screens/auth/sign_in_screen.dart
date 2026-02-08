import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:go_router/go_router.dart'; // Added GoRouter
import '../../services/mock_service.dart';
import '../../providers/user_provider.dart'; // Import Provider

class SignInScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await MockService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final profile = await MockService.getCurrentProfile();

      if (!mounted) return;

      if (profile != null) {
        // UPDATE: Using GoRouter and updating Provider State
        if (profile.isCustomer) {
           ref.read(userRoleProvider.notifier).state = UserRole.customer;
           context.go('/home');
        } else {
           ref.read(userRoleProvider.notifier).state = UserRole.pro;
           context.go('/pro-dashboard');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
