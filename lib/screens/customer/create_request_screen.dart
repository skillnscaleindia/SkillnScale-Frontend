import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_connect/router/app_routes.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/models/service_category.dart';
import 'package:service_connect/services/data_service.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_connect/services/upload_service.dart';

// Category-specific placeholder hints
const Map<String, String> _categoryHints = {
  'plumbing': 'e.g., Kitchen tap is leaking and needs replacement',
  'electrician': 'e.g., Power socket not working in the bedroom',
  'cleaning': 'e.g., Need deep cleaning for 2BHK apartment',
  'painting': 'e.g., Walls have cracks and need repainting',
  'ac_repair': 'e.g., AC not cooling properly, needs gas refill',
  'salon': 'e.g., Need a haircut and facial at home',
  'pest_control': 'e.g., Cockroach infestation in kitchen area',
  'carpentry': 'e.g., Wardrobe door hinge is broken',
};

class CreateRequestScreen extends ConsumerStatefulWidget {
  final ServiceCategory? category;
  
  const CreateRequestScreen({super.key, this.category});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isImmediate = true;
  final List<String> _photos = [];
  bool _hasChanges = false;
  bool _isSubmitting = false;

  // ─── Validation state ──────────────────────────────────────────
  Timer? _debounce;
  bool _isValidating = false;
  bool? _isDescriptionValid;
  String? _validationMessage;
  String? _validationSuggestion;

  @override
  void dispose() {
    _descriptionController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ─── Debounced AI validation ───────────────────────────────────
  void _onDescriptionChanged(String text) {
    setState(() {
      _hasChanges = true;
      // Reset validation while typing
      _isDescriptionValid = null;
      _validationMessage = null;
    });

    _debounce?.cancel();
    if (text.trim().length < 3) return; // Don't validate very short input

    _debounce = Timer(const Duration(milliseconds: 800), () {
      _validateDescription(text.trim());
    });
  }

  Future<void> _validateDescription(String text) async {
    if (!mounted) return;
    setState(() => _isValidating = true);

    try {
      final result = await ref.read(dataServiceProvider).validateDescription(
        categoryId: widget.category?.id ?? 'general',
        description: text,
      );

      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _isDescriptionValid = result['is_valid'] == true;
        _validationMessage = result['message'] as String?;
        _validationSuggestion = result['suggestion'] as String?;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _isDescriptionValid = true; // Don't block on error
      });
    }
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

  // 1-hour time slots from 8 AM to 8 PM
  static const List<int> _slotStartHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];

  String _slotLabel(int hour) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    return '$h $suffix';
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isSubmitting = true); // Show loading
      try {
        final url = await ref.read(uploadServiceProvider).uploadFile(image);
        setState(() {
          _photos.add(url);
          _hasChanges = true;
          _isSubmitting = false;
        });
      } catch (e) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      }
    }
  }
  
  Future<void> _submitRequest() async {
    if (_descriptionController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please describe your issue')),
       );
       return;
    }

    // Block if AI said description is invalid
    if (_isDescriptionValid == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationMessage ?? 'Please enter a relevant description'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final authService = ref.read(authServiceProvider);
      final address = authService.getAddress('home') ?? "123 Main St (Default)"; 

      final scheduledDate = _isImmediate 
          ? DateTime.now() 
          : DateTime(
              _selectedDate?.year ?? DateTime.now().year,
              _selectedDate?.month ?? DateTime.now().month,
              _selectedDate?.day ?? DateTime.now().day,
              _selectedTimeSlot != null
                  ? _slotStartHours.firstWhere((h) => _slotLabel(h) == _selectedTimeSlot, orElse: () => 9)
                  : 9,
              0,
            );

      final result = await ref.read(dataServiceProvider).createServiceRequest(
        categoryId: widget.category?.id ?? "general",
        title: widget.category?.name ?? "General Request",
        description: _descriptionController.text,
        location: address,
        scheduledDate: scheduledDate,
        urgency: _isImmediate ? 'immediate' : 'scheduled',
      );
      
      if (!mounted) return;
      
      final requestId = result['id'] as String?;
      
      ref.refresh(customerBookingsProvider);
      
      // Navigate to AI-matched professionals
      if (requestId != null) {
        context.push(AppRoutes.matchedPros, extra: {
          'requestId': requestId,
          'categoryName': widget.category?.name ?? 'Service',
        });
      } else {
        context.go(AppRoutes.home);
      }
      
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
    final categoryId = widget.category?.id ?? '';
    final hintText = _categoryHints[categoryId] ?? 'What do you need help with?';

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
                onChanged: _onDescriptionChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintMaxLines: 2,
                  suffixIcon: _buildValidationIcon(),
                ),
              ),
              // ─── Validation feedback ───────────────────────────
              _buildValidationFeedback(theme),
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
                  ],
                ),
                const SizedBox(height: 12),
                Text('Select Time Slot', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _slotStartHours.map((hour) {
                    final label = _slotLabel(hour);
                    final isSelected = _selectedTimeSlot == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTimeSlot = selected ? label : null;
                          _hasChanges = true;
                        });
                      },
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    );
                  }).toList(),
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

  // ─── Validation icon in text field ──────────────────────────────
  Widget? _buildValidationIcon() {
    if (_isValidating) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_isDescriptionValid == true) {
      return const Icon(LucideIcons.checkCircle, color: Colors.green, size: 20);
    }
    if (_isDescriptionValid == false) {
      return const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 20);
    }
    return null;
  }

  // ─── Validation feedback message below text field ──────────────
  Widget _buildValidationFeedback(ThemeData theme) {
    if (_validationMessage == null || _validationMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    final isValid = _isDescriptionValid == true;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isValid
              ? Colors.green.withOpacity(0.08)
              : AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isValid
                ? Colors.green.withOpacity(0.3)
                : AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isValid ? LucideIcons.sparkles : LucideIcons.info,
              size: 16,
              color: isValid ? Colors.green : AppColors.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _validationMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isValid ? Colors.green.shade700 : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_validationSuggestion != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _validationSuggestion!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightSubtitle,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
          (url) => Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.accent.withOpacity(0.1),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
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
