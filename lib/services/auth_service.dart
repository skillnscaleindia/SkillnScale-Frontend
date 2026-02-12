import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import 'mock_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  SharedPreferences? _prefs;

  AuthService(this._ref);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userRoleKey = 'userRole';
  static const String _homeAddressKey = 'homeAddress';
  static const String _workAddressKey = 'workAddress';

  bool get isLoggedIn => _prefs?.getBool(_isLoggedInKey) ?? false;
  String get userRole => _prefs?.getString(_userRoleKey) ?? 'customer';

  Future<void> login(String role) async {
    await _prefs?.setBool(_isLoggedInKey, true);
    await _prefs?.setString(_userRoleKey, role);
    
    // Update provider state
    final userRoleEnum = role == 'pro' ? UserRole.pro : UserRole.customer;
    _ref.read(userRoleProvider.notifier).state = userRoleEnum;
  }

  Future<UserRole> signIn(String email, String password) async {
    // 1. Authenticate with MockService
    await MockService.signIn(email: email, password: password);
    final profile = await MockService.getCurrentProfile();

    if (profile != null) {
      final roleStr = profile.isCustomer ? 'customer' : 'pro';
      final roleEnum = profile.isCustomer ? UserRole.customer : UserRole.pro;

      // 2. Persist Login
      await login(roleStr);

      return roleEnum;
    } else {
      throw Exception('Sign-in successful, but no profile found.');
    }
  }

  Future<void> logout() async {
    await _prefs?.clear();
    _ref.read(userRoleProvider.notifier).state = UserRole.customer; // Reset to default
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
