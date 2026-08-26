import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;
  static bool _isSoundEnabled = true;
  static const String channelId = 'vendor_order_channel_v2';
  static const String channelName = 'New Order Alerts';
  static const String channelDescription = 'Alerts for new vendor orders';
  static const AndroidInitializationSettings _androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  static const InitializationSettings _initSettings = InitializationSettings(
    android: _androidInitSettings,
  );

  static Future<void> initialize() async {
    debugPrint('');
    debugPrint('========================================');
    debugPrint('🔔 NotificationService.initialize()');
    debugPrint('========================================');

    try {
      debugPrint('🔐 Requesting notification permission...');

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '🔐 Authorization status: '
        '${settings.authorizationStatus}',
      );

      debugPrint('🔥 Getting FCM token...');

      final token = await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        debugPrint('✅ FCM token received');
        debugPrint('📱 FCM token length: ${token.length}');

        if (token.length > 10) {
          debugPrint(
            '📱 FCM token preview: '
            '${token.substring(0, 10)}...',
          );
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('fcmToken', token);

        debugPrint('💾 FCM token saved locally');
      } else {
        debugPrint('❌ FCM token is NULL or EMPTY');
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('');
        debugPrint('🔄 FCM TOKEN REFRESHED');
        debugPrint('📱 New token length: ${newToken.length}');

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('fcmToken', newToken);

        debugPrint('💾 Refreshed FCM token saved locally');
      });

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,

        playSound: true,

        sound: RawResourceAndroidNotificationSound('zomato_order_ringtone'),

        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.createNotificationChannel(channel);

      debugPrint('✅ Android notification channel created');

      await _localNotifications.initialize(
        _initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('✅ Local notifications initialized');

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      debugPrint('✅ Audio player configured for LOOP');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await _handleForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) async {
        debugPrint('');
        debugPrint('========================================');
        debugPrint('👆 NOTIFICATION TAPPED');
        debugPrint('========================================');

        debugPrint('📦 Tap data: ${message.data}');

        await _stopSound();

        debugPrint('🔇 Order ringtone stopped');
      });

      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('');
        debugPrint('========================================');
        debugPrint('🚀 APP OPENED FROM NOTIFICATION');
        debugPrint('========================================');

        debugPrint('📦 Initial data: ${initialMessage.data}');

        await _stopSound();
      }

      debugPrint('');
      debugPrint('========================================');
      debugPrint('✅ NotificationService INITIALIZED');
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('========================================');
      debugPrint('❌ NotificationService INIT ERROR');
      debugPrint('========================================');

      debugPrint('❌ Error: $e');
      debugPrint('❌ StackTrace: $stackTrace');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('');
    debugPrint('══════════════════════════════════════');
    debugPrint('📩 FCM MESSAGE RECEIVED - FOREGROUND');
    debugPrint('══════════════════════════════════════');

    debugPrint('📦 message.data = ${message.data}');

    debugPrint(
      '📌 eventType = '
      '${message.data['eventType']}',
    );

    debugPrint(
      '📌 notificationType = '
      '${message.data['notificationType']}',
    );

    debugPrint(
      '📌 orderId = '
      '${message.data['orderId']}',
    );

    debugPrint(
      '📌 vendorId = '
      '${message.data['vendorId']}',
    );

    debugPrint(
      '📌 amount = '
      '${message.data['amount']}',
    );

    final bool isNewOrder =
        message.data['eventType'] == 'VENDOR_NEW_ORDER' &&
        message.data['notificationType'] == 'VENDOR_ORDER';

    debugPrint('🔍 isNewOrder = $isNewOrder');

    if (isNewOrder) {
      debugPrint('');
      debugPrint('🚨🚨🚨 NEW ORDER RECEIVED 🚨🚨🚨');

      debugPrint('🆔 Order #${message.data['orderId']}');

      debugPrint('💰 Amount: ${message.data['amount']}');

      try {
        debugPrint('🔊 Starting order ringtone...');

        await _playOrderSound();

        debugPrint('✅ Order ringtone started');
      } catch (e, stackTrace) {
        debugPrint('❌ Failed to play order ringtone');

        debugPrint('❌ Error: $e');

        debugPrint('❌ StackTrace: $stackTrace');
      }
    } else {
      debugPrint('ℹ️ Not a new-order event.');

      debugPrint('ℹ️ Order ringtone will NOT play.');
    }

    try {
      await _showNotification(message);

      debugPrint('✅ Local notification shown');
    } catch (e, stackTrace) {
      debugPrint('❌ Notification display failed');

      debugPrint('❌ Error: $e');

      debugPrint('❌ StackTrace: $stackTrace');
    }

    debugPrint('══════════════════════════════════════');
  }

  static Future<void> _playOrderSound() async {
    if (!_isSoundEnabled) {
      debugPrint('🔇 Sound disabled - ringtone will NOT play');

      return;
    }

    if (_isPlaying) {
      debugPrint('🔊 Ringtone already playing');

      return;
    }

    try {
      _isPlaying = true;

      debugPrint('🔊 AudioPlayer starting...');

      await _audioPlayer.play(AssetSource('zomato_order_ringtone.mp3'));

      debugPrint('🔊 AudioPlayer playing ringtone in LOOP');
    } catch (e, stackTrace) {
      _isPlaying = false;

      debugPrint('❌ AudioPlayer error: $e');

      debugPrint('❌ StackTrace: $stackTrace');
    }
  }

  static Future<void> _stopSound() async {
    if (!_isPlaying) {
      debugPrint('🔇 Ringtone is not currently playing');

      return;
    }

    try {
      await _audioPlayer.stop();

      _isPlaying = false;

      debugPrint('🔇 Ringtone STOPPED');
    } catch (e) {
      debugPrint('❌ Error stopping ringtone: $e');
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final String title =
        message.notification?.title ?? message.data['title'] ?? 'New Order';

    final String body =
        message.notification?.body ??
        message.data['body'] ??
        'You have a new order';

    debugPrint('🔔 Notification title: $title');

    debugPrint('🔔 Notification body: $body');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,

          importance: Importance.max,
          priority: Priority.max,

          playSound: true,

          sound: RawResourceAndroidNotificationSound('zomato_order_ringtone'),

          enableVibration: true,

          ticker: 'New Order',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: message.data['orderId'] ?? 'order',
    );

    debugPrint('🔔 Local notification displayed');
  }

  static Future<void> _onNotificationTapped(
    NotificationResponse response,
  ) async {
    debugPrint('');
    debugPrint('========================================');
    debugPrint('👆 LOCAL NOTIFICATION TAPPED');
    debugPrint('========================================');

    debugPrint('📦 Payload: ${response.payload}');

    await _stopSound();

    debugPrint('🔇 Ringtone stopped after notification tap');
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

    debugPrint('🔊 Sound enabled = $enabled');

    if (!enabled) {
      _stopSound();
    }
  }

  static Future<void> dispose() async {
    try {
      await _stopSound();
      await _audioPlayer.dispose();

      debugPrint('🔔 NotificationService disposed');
    } catch (e) {
      debugPrint('❌ NotificationService dispose error: $e');
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('');
    debugPrint('========================================');
    debugPrint('🔔 BACKGROUND FCM MESSAGE');
    debugPrint('========================================');

    debugPrint('📦 Background data: ${message.data}');

    debugPrint('🔔 Background notification received');

    debugPrint(
      '🔔 Android notification channel sound: '
      'zomato_order_ringtone',
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('🔔 FIREBASE BACKGROUND HANDLER');
    debugPrint('========================================');

    debugPrint('📦 Data: ${message.data}');

    debugPrint(
      '📌 eventType: '
      '${message.data['eventType']}',
    );

    debugPrint(
      '📌 notificationType: '
      '${message.data['notificationType']}',
    );

    debugPrint(
      '📌 orderId: '
      '${message.data['orderId']}',
    );

    await NotificationService.handleBackgroundMessage(message);
  } catch (e, stackTrace) {
    debugPrint('❌ Background FCM handler error: $e');

    debugPrint('❌ StackTrace: $stackTrace');
  }
}
