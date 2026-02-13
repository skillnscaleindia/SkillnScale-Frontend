import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api/v1', // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for Web
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token;
        if (kIsWeb) {
          _prefs ??= await SharedPreferences.getInstance();
          token = _prefs!.getString('auth_token');
        } else {
          token = await _storage.read(key: 'auth_token');
        }
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString('auth_token', token);
    } else {
      await _storage.write(key: 'auth_token', value: token);
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove('auth_token');
    } else {
      await _storage.delete(key: 'auth_token');
    }
  }

  Dio get client => _dio;
}
