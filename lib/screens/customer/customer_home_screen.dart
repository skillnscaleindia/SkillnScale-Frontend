import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/data/fake_data.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_connect/services/location_service.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:service_connect/services/data_service.dart';
import 'package:service_connect/models/service_category.dart';
import 'package:service_connect/models/service_request.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  DateTime? _lastPressedAt;
  String _currentAddress = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    // 1. Check if there is a saved home address
    final authService = ref.read(authServiceProvider);
    final savedHome = authService.getAddress('home');
    
    if (savedHome != null) {
      if (mounted) setState(() => _currentAddress = savedHome);
    }

    // 2. Fetch current GPS location
    final locationService = LocationService();
    await locationService.getCurrentLocation();
    
    if (locationService.currentAddress != null) {
      if (mounted) setState(() => _currentAddress = locationService.currentAddress!);
    } else {
       if (savedHome == null && mounted) setState(() => _currentAddress = 'Set Location');
    }
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: $_currentAddress'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(authServiceProvider).saveAddress('home', _currentAddress);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved as Home')),
                );
              },
              child: const Text('Save as Home'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.read(authServiceProvider).saveAddress('work', _currentAddress);
                Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved as Work')),
                );
              },
              child: const Text('Save as Work'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Press back again to exit')),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Top Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(LucideIcons.user, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${ref.read(authServiceProvider).userName ?? 'User'} 👋',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: _showAddressDialog,
                              child: Row(
                                children: [
                                  Icon(LucideIcons.mapPin, size: 12, color: theme.textTheme.bodySmall?.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    _currentAddress,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Icon(Icons.arrow_drop_down, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                        ),
                        child: Icon(LucideIcons.bell, size: 20, color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GestureDetector(
                    onTap: () {
                      // Could navigate to a search screen
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 20, color: AppColors.lightSubtitle),
                          const SizedBox(width: 12),
                          Text(
                            'Search for services...',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: AppColors.lightSubtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Promo Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildPromoBanner(context),
                ),
              ),
              // Section: Services
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'What are you looking for?',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              // Services Grid
              categoriesAsync.when(
                data: (categories) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = categories[index];
                        // Parse color from string 0xFF... or use default
                        Color bgColor = AppColors.serviceCategoryColors[index % AppColors.serviceCategoryColors.length];
                        Color iconColor = AppColors.serviceCategoryIconColors[index % AppColors.serviceCategoryIconColors.length];
                        
                        if (service.color != null) {
                           try {
                             bgColor = Color(int.parse(service.color!));
                             // Make icon darker or white based on bg? 
                             // Backend sends "color" which is likely the BG color.
                           } catch (_) {}
                        }

                        return _buildServiceItem(
                          context,
                          service: service,
                          bgColor: bgColor,
                          iconColor: iconColor,
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
              ),

              // Active Job Card
              bookingsAsync.when(
                data: (bookings) {
                   final activeBooking = bookings.firstWhere(
                     (b) => b.isAccepted || b.isInProgress, 
                     orElse: () => ServiceRequest(id: '', customerId: '', categoryId: '', title: '', description: '', location: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), status: 'none'),
                   );
                   
                   if (activeBooking.status != 'none') {
                     return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: _buildActiveJobCard(context, activeBooking),
                        ),
                      );
                   }
                   return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              
              // Recent Bookings Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'Popular Near You',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                   height: 140,
                   child: ListView.builder(
                     scrollDirection: Axis.horizontal,
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     itemCount: 3,
                     itemBuilder: (context, index) {
                       final titles = ['AC Service & Repair', 'Home Deep Cleaning', 'Electrician'];
                       final icons = [LucideIcons.thermometer, LucideIcons.sparkles, LucideIcons.plug];
                       final ratings = ['4.8', '4.9', '4.7'];
                       final bookings = ['12K+ bookings', '8K+ bookings', '15K+ bookings'];
                       return Container(
                         width: 160,
                         margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: theme.colorScheme.surface,
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(
                             color: theme.colorScheme.outline.withOpacity(0.15),
                           ),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Container(
                               width: 40,
                               height: 40,
                               decoration: BoxDecoration(
                                 color: AppColors.serviceCategoryColors[index],
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               child: Icon(
                                 icons[index],
                                 size: 20,
                                 color: AppColors.serviceCategoryIconColors[index],
                               ),
                             ),
                             const Spacer(),
                             Text(
                               titles[index],
                               style: theme.textTheme.titleMedium,
                               maxLines: 2,
                               overflow: TextOverflow.ellipsis,
                             ),
                             const SizedBox(height: 4),
                             Row(
                               children: [
                                 const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                                 const SizedBox(width: 2),
                                 Text(
                                   ratings[index],
                                   style: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
                                 ),
                                 const SizedBox(width: 6),
                                 Text(
                                   bookings[index],
                                   style: theme.textTheme.labelSmall,
                                 ),
                               ],
                             ),
                           ],
                         ),
                       );
                     },
                   ),
                 ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final banner = FakeData.promoBanners[0];
    return InkWell(
      onTap: () => context.push(AppRoutes.offerServices),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: banner.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: banner.gradientColors[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(banner.icon, size: 32, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context, {
    required ServiceCategory service,
    required Color bgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.request, extra: service),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            // Use local icon mapping or dynamic if backend provides valid icon name
            child: Icon(_getIcon(service.icon), size: 24, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            service.name,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  IconData _getIcon(String? iconName) {
     switch(iconName) {
       case 'sparkles': return LucideIcons.sparkles;
       case 'wrench': return LucideIcons.wrench;
       case 'zap': return LucideIcons.zap;
       case 'paint-roller': return LucideIcons.paintRoller;
       // Add more
       default: return LucideIcons.info;
     }
  }

  Widget _buildActiveJobCard(BuildContext context, ServiceRequest booking) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.tracking),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.userCheck, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    booking.isInProgress ? 'Pro Working' : 'Pro Assigned',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Track',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
