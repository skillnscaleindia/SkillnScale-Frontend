import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_profile.dart';
import '../models/service_category.dart';
import '../models/service_request.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
    String? phone,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await client.from('profiles').insert({
        'id': response.user!.id,
        'user_type': userType,
        'full_name': fullName,
        'phone': phone,
      });
    }

    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  static Future<UserProfile?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  static Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    await client.from('profiles').update(updates).eq('id', userId);
  }

  static Future<List<ServiceCategory>> getServiceCategories() async {
    final response = await client
        .from('service_categories')
        .select()
        .order('name');

    return (response as List)
        .map((json) => ServiceCategory.fromJson(json))
        .toList();
  }

  static Future<ServiceRequest> createServiceRequest(Map<String, dynamic> data) async {
    final response = await client
        .from('service_requests')
        .insert(data)
        .select()
        .single();

    return ServiceRequest.fromJson(response);
  }

  static Future<List<ServiceRequest>> getCustomerRequests(String customerId) async {
    final response = await client
        .from('service_requests')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceRequest.fromJson(json))
        .toList();
  }

  static Future<List<ServiceRequest>> getPendingRequests() async {
    final response = await client
        .from('service_requests')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceRequest.fromJson(json))
        .toList();
  }

  static Future<List<ServiceRequest>> getProfessionalRequests(String professionalId) async {
    final response = await client
        .from('service_requests')
        .select()
        .eq('professional_id', professionalId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceRequest.fromJson(json))
        .toList();
  }

  static Future<void> updateServiceRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    await client.from('service_requests').update(updates).eq('id', requestId);
  }

  static Future<void> acceptServiceRequest(
    String requestId,
    String professionalId,
  ) async {
    await client.from('service_requests').update({
      'professional_id': professionalId,
      'status': 'accepted',
    }).eq('id', requestId);
  }
}
