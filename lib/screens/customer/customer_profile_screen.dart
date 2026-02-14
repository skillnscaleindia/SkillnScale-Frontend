import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:service_connect/l10n/app_localizations.dart';
import 'package:service_connect/main.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(LucideIcons.user, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authService.userName ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (authService.userEmail != null && authService.userEmail!.isNotEmpty)
                              ? authService.userEmail!
                              : authService.userPhone ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.pencil, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Language Switcher
            _buildSectionHeader(context, l10n.language),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(
                      context: context,
                      ref: ref,
                      label: 'English',
                      flag: '🇬🇧',
                      locale: const Locale('en'),
                      isSelected: currentLocale.languageCode == 'en',
                    ),
                  ),
                  Expanded(
                    child: _buildLanguageButton(
                      context: context,
                      ref: ref,
                      label: 'हिन्दी',
                      flag: '🇮🇳',
                      locale: const Locale('hi'),
                      isSelected: currentLocale.languageCode == 'hi',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Section
            _buildSectionHeader(context, 'General'),
            const SizedBox(height: 8),
            _buildSettingsCard(theme, [
              _SettingItem(
                icon: LucideIcons.calendarCheck,
                title: l10n.bookingHistory,
                onTap: () => context.go('/history'),
              ),
              _SettingItem(
                icon: LucideIcons.creditCard,
                title: l10n.paymentMethod,
                onTap: () {},
              ),
              _SettingItem(
                icon: LucideIcons.mapPin,
                title: l10n.setLocation,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'Support'),
            const SizedBox(height: 8),
            _buildSettingsCard(theme, [
              _SettingItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              _SettingItem(
                icon: LucideIcons.shield,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _SettingItem(
                icon: LucideIcons.info,
                title: 'About Us',
                onTap: () {},
              ),
            ]),
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
                          onPressed: () async {
                            Navigator.pop(context);
                            await ref.read(authServiceProvider).logout();
                            if (context.mounted) {
                              context.go(AppRoutes.landing);
                            }
                          },
                          child: const Text(
                            'Log Out',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(LucideIcons.logOut, size: 18, color: AppColors.error),
                label: Text(l10n.logout),
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

  Widget _buildLanguageButton({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required String flag,
    required Locale locale,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).state = locale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: AppColors.lightSubtitle,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18, color: AppColors.accent),
                ),
                title: Text(item.title, style: theme.textTheme.titleMedium),
                trailing: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.lightSubtitle,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              ),
              if (index < items.length - 1)
                Divider(
                  height: 0.5,
                  indent: 68,
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}