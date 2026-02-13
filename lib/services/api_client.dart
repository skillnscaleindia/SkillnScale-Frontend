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
          baseUrl: 'http://localhost:8000/api/v1',
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
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Attempt refresh
          try {
            print("Token expired, attempting refresh...");
            String? refreshToken;
            if (kIsWeb) {
              _prefs ??= await SharedPreferences.getInstance();
              refreshToken = _prefs!.getString('refresh_token');
            } else {
              refreshToken = await _storage.read(key: 'refresh_token');
            }

            if (refreshToken != null) {
              // Create a new Dio instance to avoid interceptor loop
              final refreshDio = Dio(BaseOptions(
                baseUrl: _dio.options.baseUrl,
                headers: {'Content-Type': 'application/json'},
              ));
              
              final response = await refreshDio.post('/auth/refresh', data: {
                'refresh_token': refreshToken,
              });
              
              final newAccessToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];
              
              await saveToken(newAccessToken, newRefreshToken);
              
              // Retry original request
              final opts = e.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              final clonedRequest = await _dio.fetch(opts);
              return handler.resolve(clonedRequest);
            }
          } catch (refreshError) {
            print("Token refresh failed: $refreshError");
            // Logout if refresh fails
            await deleteToken();
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<void> saveToken(String accessToken, String refreshToken) async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString('auth_token', accessToken);
      await _prefs!.setString('refresh_token', refreshToken);
    } else {
      await _storage.write(key: 'auth_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove('auth_token');
      await _prefs!.remove('refresh_token');
    } else {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
    }
  }

  Dio get client => _dio;
}
