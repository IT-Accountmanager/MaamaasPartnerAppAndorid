// import 'dart:convert';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:maamaaspartner/user_module/widgets/provider.dart';
// import 'package:maamaaspartner/widgets_helper/Home_screen_1.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'API/Apiclient.dart';
// import 'Api/NotificationService.dart';
// import 'login_screen.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp();
//
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//
//   await NotificationService.initialize();
//
//   final prefs = await SharedPreferences.getInstance();
//
//   final customerId = prefs.getString('customerId') ?? '';
//
//   runApp(
//     ProviderScope(
//       overrides: [userIdProvider.overrideWithValue(customerId)],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(390, 844),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           title: "Maamaa's Partner",
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(
//             colorScheme: ColorScheme.fromSeed(
//               seedColor: const Color(0xFFE66D33),
//             ),
//             useMaterial3: true,
//           ),
//           home: const SplashScreen(), // Changed to SplashScreen
//         );
//       },
//     );
//   }
// }
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     getFCMToken();
//     _checkLoginStatus();
//   }
//
//   Future<void> _checkLoginStatus() async {
//     // Add delay to show splash screen
//     await Future.delayed(const Duration(seconds: 2));
//
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     final token = prefs.getString('token');
//     final vendorId = prefs.getInt('vendorId') ?? 0;
//
//     debugPrint('Login check:');
//     debugPrint('- isLoggedIn: $isLoggedIn');
//     debugPrint('- token exists: ${token != null}');
//     debugPrint('- vendorId: $vendorId');
//
//     if (isLoggedIn && token != null && vendorId > 0) {
//       debugPrint('✅ User is logged in, navigating to home...');
//       await _updateCurrentLocation();
//
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeWrapper()),
//       );
//     } else {
//       debugPrint('❌ User is not logged in, navigating to login...');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage1()),
//       );
//     }
//   }
//
//   Future<void> _updateCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) return;
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//
//       String address = '';
//       String city = '';
//
//       try {
//         final placemarks = await placemarkFromCoordinates(
//           position.latitude,
//           position.longitude,
//         );
//         if (placemarks.isNotEmpty) {
//           final place = placemarks.first;
//           address = '${place.street ?? ''}, ${place.subLocality ?? ''}'
//               .trim()
//               .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
//           city = place.locality ?? place.administrativeArea ?? '';
//         }
//       } catch (_) {}
//
//       final prefs = await SharedPreferences.getInstance();
//       final String customerId = prefs.getString('customerId') ?? '';
//
//       if (customerId.isEmpty) return;
//
//       final payload = {
//         "customerId": customerId,
//         "latitude": position.latitude,
//         "longitude": position.longitude,
//         "address": address,
//         "city": city,
//       };
//
//       final response = await ApiClient.post(
//         "api/user/curret/location/update",
//         payload,
//         service: "subscription",
//       );
//
//       debugPrint("📍 Location update → ${response.statusCode}: ${response.body}");
//     } catch (e) {
//       debugPrint("⚠️ Location update failed: $e");
//     }
//   }
//
//   Future<void> getFCMToken() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     // Request permission (important for Android 13+ / iOS)
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     debugPrint("Notification permission: ${settings.authorizationStatus}");
//
//     // Get token
//     String? token = await messaging.getToken();
//
//     debugPrint("🔥 FCM Token: $token");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE66D33), // Your app color
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Add your logo/image here
//             Icon(Icons.restaurant_menu, size: 100.w, color: Colors.white),
//             SizedBox(height: 20.h),
//             Text(
//               "Maamaa's Partner",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 32.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             const CircularProgressIndicator(color: Colors.white),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maamaaspartner/user_module/widgets/provider.dart';
import 'package:maamaaspartner/widgets_helper/Home_screen_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'API/Apiclient.dart';
import 'Api/NotificationService.dart';
import 'login_screen.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: "Maamaa's Partner",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE66D33),
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen — fast, non-blocking startup
// ─────────────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // ── Animations ──────────────────────────────────────────────────────────
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _scaleAnim = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // ── Start init tasks in parallel ────────────────────────────────────────
    // getFCMToken() and _checkLoginStatus() run concurrently.
    // No artificial delays — navigation happens as soon as prefs are read.
    Future.wait([_getFCMToken(), _checkLoginStatus()]);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Login check ───────────────────────────────────────────────────────────
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? token = prefs.getString('token');
    final int vendorId = prefs.getInt('vendorId') ?? 0;

    debugPrint('🔐 Login check:');
    debugPrint('   isLoggedIn : $isLoggedIn');
    debugPrint('   token      : ${token != null ? "exists" : "null"}');
    debugPrint('   vendorId   : $vendorId');

    // Ensure the widget is still in the tree before navigating
    if (!mounted) return;

    if (isLoggedIn && token != null && vendorId > 0) {
      debugPrint('✅ Logged in → navigating to Home');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeWrapper()),
      );

      // 🔥 Fire-and-forget: location update runs AFTER navigation.
      // The user is already on the home screen — no waiting here.
      _updateCurrentLocation();
    } else {
      debugPrint('❌ Not logged in → navigating to Login');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage1()),
      );
    }
  }

  Future<void> _updateCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      String address = '';
      String city = '';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = '${place.street ?? ''}, ${place.subLocality ?? ''}'
              .trim()
              .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
          city = place.locality ?? place.administrativeArea ?? '';
        }
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      final String customerId = prefs.getString('customerId') ?? '';

      if (customerId.isEmpty) return;

      final payload = {
        "customerId": customerId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "address": address,
        "city": city,
      };

      final response = await ApiClient.post(
        "api/user/curret/location/update",
        payload,
        service: "subscription",
      );

      debugPrint(
        "📍 Location update → ${response.statusCode}: ${response.body}",
      );
    } catch (e) {
      debugPrint("⚠️ Location update failed: $e");
    }
  }

  // ── FCM token ─────────────────────────────────────────────────────────────
  Future<void> _getFCMToken() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      final NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

      final String? token = await messaging.getToken();
      debugPrint('🔥 FCM Token: $token');

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
      }
    } catch (e) {
      debugPrint('⚠️ FCM token fetch failed: $e');
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE66D33),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 100.w, color: Colors.white),
                SizedBox(height: 20.h),
                Text(
                  "Maamaa's Partner",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
