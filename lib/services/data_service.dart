import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/service_category.dart';
import '../models/service_request.dart';

final dataServiceProvider = Provider<DataService>((ref) {
  return DataService(ref);
});

final categoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  return ref.read(dataServiceProvider).getServiceCategories();
});

final customerBookingsProvider = FutureProvider<List<ServiceRequest>>((ref) async {
  return ref.read(dataServiceProvider).getCustomerRequests("");
});

class DataService {
  final Ref _ref;

  DataService(this._ref);

  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/services/categories');
      final List<dynamic> data = response.data;
      return data.map((json) => ServiceCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<ServiceRequest> createServiceRequest({
    required String categoryId,
    required String title,
    required String description,
    required String location,
    required DateTime scheduledDate,
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      // Map Frontend ServiceRequest params to Backend BookingCreate
      // Note: Backend expects "service_id" which usually is specific item, 
      // but here we use categoryId as a placeholder or title.
      // We'll pass title/description in notes or map appropriately.
      
      final response = await apiClient.client.post('/bookings/', data: {
        "service_id": categoryId, // Using category as service_id for now
        "scheduled_at": scheduledDate.toIso8601String(),
        "address": location,
        "notes": "$title: $description", // Combine title/desc into notes
      });

      return _mapBookingToServiceRequest(response.data);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<ServiceRequest>> getCustomerRequests(String customerId) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/bookings/');
      final List<dynamic> data = response.data;
      return data.map((json) => _mapBookingToServiceRequest(json)).toList();
    } catch (e) {
      throw Exception('Failed to load history: $e');
    }
  }
  
  Future<List<ServiceRequest>> getPendingRequests() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/bookings/pending');
      final List<dynamic> data = response.data;
      return data.map((json) => _mapBookingToServiceRequest(json)).toList();
    } catch (e) {
      throw Exception('Failed to load pending jobs: $e');
    }
  }

  Future<void> acceptServiceRequest(String requestId, String professionalId) async {
     try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.client.post('/bookings/$requestId/accept');
    } catch (e) {
      throw Exception('Failed to accept job: $e');
    }
  }

  // Mapper
  ServiceRequest _mapBookingToServiceRequest(Map<String, dynamic> json) {
    // Backend: id, user_id, service_id, scheduled_at, address, notes, status, total_amount, created_at
    // Frontend: id, customerId, categoryId, title, description, location, status, scheduledDate, price, createdAt
    
    final notes = json['notes'] as String? ?? "";
    final parts = notes.split(": ");
    final title = parts.isNotEmpty ? parts[0] : "Service Request";
    final description = parts.length > 1 ? parts.sublist(1).join(": ") : notes;

    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['user_id'].toString(),
      professionalId: json['pro_id']?.toString(),
      categoryId: json['service_id'] as String, // Using service_id as category
      title: title,
      description: description,
      location: json['address'] as String,
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduled_at'] as String),
      price: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['created_at'] as String), // Mock updated_at
    );
  }
}
