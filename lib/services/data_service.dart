import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // ─── Categories ──────────────────────────────────────
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

  // ─── Service Requests (NEW API) ──────────────────────
  /// Validate description using AI (Gemini) before creating request
  Future<Map<String, dynamic>> validateDescription({
    required String categoryId,
    required String description,
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.post(
        '/requests/validate-description',
        data: {
          'category_id': categoryId,
          'description': description,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      // If validation endpoint fails, allow submission (don't block user)
      return {'is_valid': true, 'message': '', 'suggestion': null};
    }
  }

  Future<Map<String, dynamic>> createServiceRequest({
    required String categoryId,
    required String title,
    required String description,
    required String location,
    required DateTime scheduledDate,
    String urgency = 'immediate',
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.post('/requests/', data: {
        'category_id': categoryId,
        'title': title,
        'description': description,
        'location': location,
        'scheduled_at': scheduledDate.toIso8601String(),
        'urgency': urgency,
      });
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to create request: $e');
    }
  }

  /// Get matched professionals with AI scores
  Future<List<Map<String, dynamic>>> getMatchedProfessionals(String requestId) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/requests/$requestId/matches');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }

  /// Get current user's requests
  Future<List<Map<String, dynamic>>> getMyRequests() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/requests/');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load requests: $e');
    }
  }

  // ─── Bookings (Legacy compat) ────────────────────────
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

  /// Update booking status (in_progress / completed)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.client.patch('/bookings/$bookingId/status', data: {
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  // ─── Reviews ─────────────────────────────────────────
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.client.post('/reviews/', data: {
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  // ─── Availability ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAvailability() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/availability/');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load availability: $e');
    }
  }

  Future<void> setAvailability({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.client.post('/availability/', data: {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
      });
    } catch (e) {
      throw Exception('Failed to set availability: $e');
    }
  }



  // ─── Dashboards (NEW API) ────────────────────────────
  Future<Map<String, dynamic>> getCustomerDashboard() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/customer/dashboard');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }

  Future<Map<String, dynamic>> getProDashboard() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/pro/dashboard');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }

  Future<void> updateProLocation(double lat, double lng) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.client.put('/pro/location', data: {
        'latitude': lat,
        'longitude': lng,
      });
    } catch (e) {
      print('Failed to update location: $e'); // Silent fail is ok for background updates
    }
  }

  /// Get professional location for a booking
  Future<Map<String, dynamic>> getBookingLocation(String bookingId) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/bookings/$bookingId/location');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('Failed to get location: $e');
      return {'latitude': null, 'longitude': null};
    }
  }

  // ─── Helper ──────────────────────────────────────────
  ServiceRequest _mapBookingToServiceRequest(Map<String, dynamic> json) {
    final notes = json['notes'] as String? ?? "";
    final parts = notes.split(": ");
    final title = parts.isNotEmpty ? parts[0] : "Service Request";
    final description = parts.length > 1 ? parts.sublist(1).join(": ") : notes;

    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['user_id'].toString(),
      professionalId: json['pro_id']?.toString(),
      categoryId: json['service_id'] as String,
      title: title,
      description: description,
      location: json['address'] as String,
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduled_at'] as String),
      price: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
