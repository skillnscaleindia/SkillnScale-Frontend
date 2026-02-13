import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_connect/services/api_client.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService(ref));

class NotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> init() async {
    try {
      // Request Permissions
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
        
        // Setup Local Notifications
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosSettings = DarwinInitializationSettings();
        const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
        await _localNotifications.initialize(initSettings);

        // Get Token
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _registerToken(token);
        }

        // Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);

        // Foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _showLocalNotification(message);
        });
      }
    } catch (e) {
      print('Notification init failed (Firebase config likely missing): $e');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _ref.read(apiClientProvider).client.post(
        '/notifications/device-token',
        data: {
          'token': token,
          'platform': Platform.operatingSystem,
        },
      );
      print('Device token registered');
    } catch (e) {
      print('Failed to register token: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
