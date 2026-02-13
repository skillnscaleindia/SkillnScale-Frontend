import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/models/service_category.dart';
import 'package:service_connect/services/data_service.dart';
import 'package:service_connect/services/auth_service.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  final ServiceCategory? category;
  
  const CreateRequestScreen({super.key, this.category});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isImmediate = true;
  final List<String> _photos = [];
  bool _hasChanges = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickPhoto() async {
    // Simulate adding a photo
    setState(() {
      _photos.add('photo_${_photos.length + 1}');
      _hasChanges = true;
    });
  }
  
  Future<void> _submitRequest() async {
    if (_descriptionController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please describe your issue')),
       );
       return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final authService = ref.read(authServiceProvider);
      // Use saved home address or default
      final address = authService.getAddress('home') ?? "123 Main St (Default)"; 

      final scheduledDate = _isImmediate 
          ? DateTime.now() 
          : DateTime(
              _selectedDate?.year ?? DateTime.now().year,
              _selectedDate?.month ?? DateTime.now().month,
              _selectedDate?.day ?? DateTime.now().day,
              _selectedTime?.hour ?? 9,
              _selectedTime?.minute ?? 0,
            );

      await ref.read(dataServiceProvider).createServiceRequest(
        categoryId: widget.category?.id ?? "general",
        title: widget.category?.name ?? "General Request",
        description: _descriptionController.text,
        location: address,
        scheduledDate: scheduledDate,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request created successfully!')),
      );
      
      // Navigate to tracking or home (invalidate providers to refresh)
      ref.refresh(customerBookingsProvider);
      
      // Go to home first, then tracking? Or just tracking.
      // But tracking needs active job.
      
      context.go(AppRoutes.home);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to create request: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('You have unsaved changes. Do you want to discard them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (result == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category?.name ?? 'New Request'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text('Describe your issue', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                onChanged: (_) => setState(() => _hasChanges = true),
                decoration: const InputDecoration(
                  hintText: 'What do you need help with?',
                ),
              ),
              const SizedBox(height: 24),
              // Photo Upload
              Text('Add Photos', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('(Optional) Helps professionals understand the issue',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              _buildPhotoGrid(theme),
              const SizedBox(height: 24),
              // Schedule
              Text('When do you need it?', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildScheduleChip(
                      label: 'Now',
                      icon: LucideIcons.zap,
                      isSelected: _isImmediate,
                      onTap: () => setState(() => _isImmediate = true),
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScheduleChip(
                      label: 'Schedule',
                      icon: LucideIcons.calendar,
                      isSelected: !_isImmediate,
                      onTap: () => setState(() => _isImmediate = false),
                      theme: theme,
                    ),
                  ),
                ],
              ),
              if (!_isImmediate) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(LucideIcons.calendar, size: 20),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select Date',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: _selectedDate != null
                                  ? theme.colorScheme.onSurface
                                  : AppColors.lightSubtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(LucideIcons.clock, size: 20),
                          ),
                          child: Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Select Time',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: _selectedTime != null
                                  ? theme.colorScheme.onSurface
                                  : AppColors.lightSubtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  child: _isSubmitting 
                     ? const CircularProgressIndicator(color: Colors.white)
                     : const Text('Find Professionals', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(ThemeData theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._photos.map(
          (photo) => Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.accent.withOpacity(0.1),
            ),
            child: const Icon(LucideIcons.image, color: AppColors.accent),
          ),
        ),
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.3),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              color: AppColors.accent.withOpacity(0.05),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.camera, size: 22, color: AppColors.accent),
                SizedBox(height: 4),
                Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.lightSubtitle,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.accent : AppColors.lightSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
