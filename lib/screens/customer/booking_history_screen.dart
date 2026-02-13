import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.accent.withOpacity(0.1),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(context, 'active', theme),
            _buildBookingList(context, 'completed', theme),
            _buildBookingList(context, 'cancelled', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, String type, ThemeData theme) {
    final bookings = _getMockBookings(type);
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendar,
              size: 56,
              color: AppColors.lightSubtitle.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No $type bookings',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: AppColors.lightSubtitle,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(context, booking, type, theme);
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Map<String, String> booking,
    String type,
    ThemeData theme,
  ) {
    final statusColor = type == 'active'
        ? AppColors.info
        : type == 'completed'
            ? AppColors.success
            : AppColors.error;

    final statusIcon = type == 'active'
        ? LucideIcons.clock
        : type == 'completed'
            ? Icons.check_circle_outline
            : Icons.cancel_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getServiceIcon(booking['service']!),
                  size: 22,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['service']!,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking['professional']!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: AppColors.lightSubtitle),
                    const SizedBox(width: 6),
                    Text(booking['date']!, style: theme.textTheme.bodySmall),
                  ],
                ),
                Text(
                  booking['price']!,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          if (type == 'active')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.tracking.replaceFirst(':id', booking['id']!),
                  ),
                  icon: const Icon(LucideIcons.mapPin, size: 16),
                  label: const Text('Track Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    if (service.toLowerCase().contains('plumb')) return LucideIcons.wrench;
    if (service.toLowerCase().contains('elect')) return LucideIcons.plug;
    if (service.toLowerCase().contains('clean')) return LucideIcons.sparkles;
    if (service.toLowerCase().contains('paint')) return LucideIcons.paintbrush;
    if (service.toLowerCase().contains('ac')) return LucideIcons.thermometer;
    return LucideIcons.wrench;
  }

  List<Map<String, String>> _getMockBookings(String type) {
    if (type == 'active') {
      return [
        {'id': 'booking_123', 'service': 'Plumbing Repair', 'professional': 'Rajesh Kumar', 'date': '12 Feb 2026', 'price': '\$50'},
      ];
    } else if (type == 'completed') {
      return [
        {'id': 'booking_456', 'service': 'AC Service', 'professional': 'Suresh Singh', 'date': '8 Feb 2026', 'price': '\$75'},
        {'id': 'booking_789', 'service': 'Electrical Wiring', 'professional': 'Amit Patel', 'date': '2 Feb 2026', 'price': '\$120'},
      ];
    } else {
      return [
        {'id': 'booking_000', 'service': 'House Cleaning', 'professional': 'Anjali Sharma', 'date': '29 Jan 2026', 'price': '\$40'},
      ];
    }
  }
}
