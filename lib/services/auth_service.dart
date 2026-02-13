import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../providers/user_provider.dart';
import 'api_client.dart';
import '../models/user_profile.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  SharedPreferences? _prefs;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._ref);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userRoleKey = 'userRole';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userIdKey = 'userId';
  static const String _homeAddressKey = 'homeAddress';
  static const String _workAddressKey = 'workAddress';

  bool get isLoggedIn => _prefs?.getBool(_isLoggedInKey) ?? false;
  String get userRole => _prefs?.getString(_userRoleKey) ?? 'customer';
  String? get userName => _prefs?.getString(_userNameKey);
  String? get userEmail => _prefs?.getString(_userEmailKey);
  String? get userId => _prefs?.getString(_userIdKey);

  Future<void> login(String role) async {
    await _prefs?.setBool(_isLoggedInKey, true);
    await _prefs?.setString(_userRoleKey, role);
    
    // Update provider state
    final userRoleEnum = role == 'professional' ? UserRole.pro : UserRole.customer;
    _ref.read(userRoleProvider.notifier).state = userRoleEnum;
  }

  Future<UserRole> signIn(String email, String password) async {
    try {
      final apiClient = _ref.read(apiClientProvider);

      // 1. Login to get Token
      final response = await apiClient.client.post('/auth/login/json', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      await apiClient.saveToken(token, refreshToken);

      // 2. Fetch User Profile
      final meResponse = await apiClient.client.get('/users/me');
      final userData = meResponse.data;

      // Map Backend User to Frontend UserProfile
      // Backend: id(int), role(customer/pro), full_name(str)
      // Frontend expects: id(String), user_type(customer/professional)
      final backendRole = userData['role'];
      final frontendRole = backendRole == 'pro' ? 'professional' : 'customer';

      // Create a minimal UserProfile from backend data
      final profile = UserProfile(
        id: userData['id'].toString(),
        userType: frontendRole,
        fullName: userData['full_name'] ?? 'User',
        email: userData['email'], // Add email to UserProfile if needed, or ignore
        createdAt: DateTime.now(), // Mock if missing
        updatedAt: DateTime.now(), // Mock if missing
      );

      // 3. Persist Login & user info
      await login(frontendRole);
      await _prefs?.setString(_userNameKey, userData['full_name'] ?? 'User');
      await _prefs?.setString(_userEmailKey, userData['email'] ?? '');
      await _prefs?.setString(_userIdKey, userData['id'].toString());

      return frontendRole == 'professional' ? UserRole.pro : UserRole.customer;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['detail'] ?? 'Login failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'customer' or 'pro'
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      
      // 1. Create User
      await apiClient.client.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      });

      // 2. Auto Login after signup
      await signIn(email, password);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['detail'] ?? 'Signup failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<void> logout() async {
    await _prefs?.clear();
    await _ref.read(apiClientProvider).deleteToken();
    _ref.read(userRoleProvider.notifier).state = UserRole.customer;
  }

  // Address Persistence
  Future<void> saveAddress(String type, String address) async {
    if (type.toLowerCase() == 'home') {
      await _prefs?.setString(_homeAddressKey, address);
    } else if (type.toLowerCase() == 'work') {
      await _prefs?.setString(_workAddressKey, address);
    }
  }

  String? getAddress(String type) {
    if (type.toLowerCase() == 'home') {
      return _prefs?.getString(_homeAddressKey);
    } else if (type.toLowerCase() == 'work') {
      return _prefs?.getString(_workAddressKey);
    }
    return null;
  }
}
