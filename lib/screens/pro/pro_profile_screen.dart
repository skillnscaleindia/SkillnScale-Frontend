import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';

class ProProfileScreen extends ConsumerWidget {
  const ProProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.read(authServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header (New)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(LucideIcons.user, color: AppColors.accent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authService.userName ?? 'Professional',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (authService.userEmail != null && authService.userEmail!.isNotEmpty)
                              ? authService.userEmail!
                              : authService.userPhone ?? '',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Earnings Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.wallet, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Total Earnings',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '\$1,250',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This month',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              children: [
                _buildStatTile(theme, '47', 'Jobs Done', LucideIcons.briefcase),
                const SizedBox(width: 12),
                _buildStatTile(theme, '4.8', 'Rating', Icons.star_rounded),
                const SizedBox(width: 12),
                _buildStatTile(theme, '95%', 'Completion', Icons.check_circle_outline),
              ],
            ),
            const SizedBox(height: 24),
            // Settings
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Accepting Jobs', style: theme.textTheme.titleMedium),
                    subtitle: const Text('Toggle to stop receiving new job requests'),
                    value: true,
                    onChanged: (v) {},
                    activeColor: AppColors.success,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  Divider(height: 0.5, indent: 16, endIndent: 16, color: theme.colorScheme.outline.withOpacity(0.1)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.user, size: 18, color: AppColors.accent),
                    ),
                    title: Text('Edit Profile', style: theme.textTheme.titleMedium),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.lightSubtitle),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    onTap: () {},
                  ),
                  Divider(height: 0.5, indent: 68, color: theme.colorScheme.outline.withOpacity(0.1)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.help_outline, size: 18, color: AppColors.accent),
                    ),
                    title: Text('Help & Support', style: theme.textTheme.titleMedium),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.lightSubtitle),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out?'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.go(AppRoutes.landing);
                          },
                          child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(LucideIcons.logOut, size: 18, color: AppColors.error),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(ThemeData theme, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
