

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final AudioPlayer _audioPlayer = AudioPlayer();

  static bool _isPlaying = false;
  static bool _isSoundEnabled = true;

  static const String channelId = 'school_bell_channel';
  static const String channelName = 'School Bell Notifications';

  static const AndroidInitializationSettings _androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  static const InitializationSettings _initSettings = InitializationSettings(
    android: _androidInitSettings,
  );

  static Future<void> initialize() async {
    debugPrint('🔔 NotificationService.initialize() started');

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();

    debugPrint('🔥 FCM Token: $token');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token ?? '');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'New order notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('zomato_order_ringtone'),
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(_initSettings);

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    debugPrint('✅ NotificationService initialized');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('');
      debugPrint('══════════════════════════════════════');
      debugPrint('📩 FCM MESSAGE RECEIVED');
      debugPrint('══════════════════════════════════════');

      debugPrint('📦 message.data = ${message.data}');

      final data = message.data;

      debugPrint('📌 eventType        = ${data['eventType']}');
      debugPrint('📌 notificationType = ${data['notificationType']}');
      debugPrint('📌 orderId          = ${data['orderId']}');
      debugPrint('📌 vendorId         = ${data['vendorId']}');
      debugPrint('📌 amount           = ${data['amount']}');

      final bool isNewOrder =
          data['eventType'] == 'VENDOR_NEW_ORDER' &&
          data['notificationType'] == 'VENDOR_ORDER';

      debugPrint('🔍 isNewOrder = $isNewOrder');

      if (isNewOrder) {
        debugPrint('🚨🚨 NEW ORDER RECEIVED 🚨🚨');
        debugPrint('🆔 Order #${data['orderId']}');
        debugPrint('💰 Amount: ${data['amount']}');

        try {
          debugPrint('🔊 Playing order sound...');

          await _playOrderSound();

          debugPrint('✅ Order sound started');
        } catch (e, stackTrace) {
          debugPrint('❌ Failed to play order sound');
          debugPrint('❌ Error: $e');
          debugPrint('❌ StackTrace: $stackTrace');
        }
      } else {
        debugPrint('ℹ️ Not a new-order event. Sound will NOT play.');
      }

      try {
        await _showNotification(message);
        debugPrint('✅ Notification shown');
      } catch (e) {
        debugPrint('❌ Notification display failed: $e');
      }

      debugPrint('══════════════════════════════════════');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('👆 Notification tapped');
      debugPrint('📦 Tap data: ${message.data}');

      await _stopSound();

      debugPrint('🔇 Order sound stopped');
    });
  }

  static Future<void> _playOrderSound() async {
    if (!_isSoundEnabled || _isPlaying) return;

    try {
      _isPlaying = true;

      await _audioPlayer.play(AssetSource('zomato_order_ringtone.mp3'));
    } catch (e) {
      debugPrint('Sound error: $e');
      _isPlaying = false;
    }
  }

  static Future<void> _stopSound() async {
    if (!_isPlaying) return;

    await _audioPlayer.stop();
    _isPlaying = false;
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final String title =
        message.notification?.title ?? message.data['title'] ?? 'New Order';
    final String body =
        message.notification?.body ??
        message.data['body'] ??
        'You have a new order';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('zomato_order_ringtone'),
          enableVibration: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: message.data['orderId'] ?? 'order',
    );
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('order_ringtone'),
          enableVibration: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload ?? 'order',
    );
  }

  static Future<void> triggerOrderSound() async {
    await _playOrderSound();
  }

  static Future<void> stopOrderSound() async {
    await _stopSound();
  }

  static void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;

    if (!enabled) {
      _stopSound();
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await _localNotifications.initialize(_initSettings);
    await _showNotification(message);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('🔔 Background/terminated message received: ${message.data}');

  await NotificationService.handleBackgroundMessage(message);
}
