// import 'dart:async';
// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:maamaas_app/screens/login_page.dart';
// import 'package:maamaas_app/screens/newscreens/foodmainscreen.dart';
// import 'package:maamaas_app/screens/newscreens/newmainscreen.dart';
// import 'package:maamaas_app/screens/orders_screen.dart';
// import 'package:maamaas_app/screens/wallet_screen.dart';
// import 'package:maamaas_app/widgets/Global_loader.dart';
// import 'package:maamaas_app/widgets/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'API/Auth_service.dart';
// import 'screens/addressmodel_provider.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
//
//
//
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   // print("📩 Background message: ${message.messageId}");
// }
//
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// //
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// //
// //   final prefs = await SharedPreferences.getInstance();
// //   final userId = prefs.getInt('userId') ?? 0;
// //   if (kReleaseMode) {
// //     // debugPrint = (String? message, {int? wrapWidth}) {};
// //   }
// //   ApiClient.initialize();
// //   ApiClient.onSessionExpired = handleSessionExpired;
// //
// //   runApp(
// //     ProviderScope(
// //       overrides: [userIdProvider.overrideWithValue(userId)],
// //
// //       child: MyApp(navigatorKey: navigatorKey),
// //     ),
// //   );
// // }
//
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // 🔒 Hold first Flutter frame
// //   WidgetsBinding.instance.deferFirstFrame();
// //
// //   await Firebase.initializeApp();
// //   final prefs = await SharedPreferences.getInstance();
// //   final userId = prefs.getInt('userId') ?? 0;
// //
// //   runApp(
// //     ProviderScope(
// //       overrides: [userIdProvider.overrideWithValue(userId)],
// //       child: MyApp(navigatorKey: navigatorKey),
// //     ),
// //   );
// //
// //   // 🔓 Release frame after app is ready
// //   WidgetsBinding.instance.allowFirstFrame();
// // }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 🔒 Preserve the native splash
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
//
//   await Firebase.initializeApp();
//   final prefs = await SharedPreferences.getInstance();
//   final userId = prefs.getInt('userId') ?? 0;
//
//   runApp(
//     ProviderScope(
//       overrides: [userIdProvider.overrideWithValue(userId)],
//       child: MyApp(navigatorKey: navigatorKey),
//     ),
//   );
// }
//
// // class MyApp extends StatelessWidget {
// //   final GlobalKey<NavigatorState> navigatorKey;
// //   const MyApp({super.key, required this.navigatorKey});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ScreenUtilInit(
// //       designSize: const Size(375, 812),
// //       minTextAdapt: true,
// //       splitScreenMode: true,
// //       builder: (context, child) {
// //         return MaterialApp(
// //           navigatorKey: navigatorKey,
// //           debugShowCheckedModeBanner: false,
// //           // showPerformanceOverlay: true,
// //           home: SplashScreen(),
// //           theme: ThemeData(
// //             textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 14.sp)),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// class MyApp extends StatelessWidget {
//   final GlobalKey<NavigatorState> navigatorKey;
//   const MyApp({super.key, required this.navigatorKey});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           navigatorKey: navigatorKey,
//           debugShowCheckedModeBanner: false,
//            showPerformanceOverlay: true,
//
//           // Use MaterialApp's built-in transition
//           theme: ThemeData(
//             textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 14.sp)),
//             pageTransitionsTheme: const PageTransitionsTheme(
//               builders: {
//                 TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
//                 TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//               },
//             ),
//           ),
//
//           // Set initial route to your animated splash
//           initialRoute: '/',
//           routes: {
//             '/': (context) => const AttractiveLoadingScreen(),
//             '/login': (context) => LoginPage(),
//             '/home': (context) => MainScreenfood(),
//           },
//
//           onGenerateRoute: (settings) {
//             // Add fade transition for all routes
//             return PageRouteBuilder(
//               settings: settings,
//               pageBuilder: (_, __, ___) {
//                 switch (settings.name) {
//                   case '/login':
//                     return LoginPage();
//                   case '/home':
//                     return MainScreenfood();
//                   default:
//                     return const AttractiveLoadingScreen();
//                 }
//               },
//               transitionsBuilder: (_, animation, __, child) {
//                 return FadeTransition(
//                   opacity: animation,
//                   child: child,
//                 );
//               },
//               transitionDuration: const Duration(milliseconds: 300),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// class SplashScreen extends ConsumerStatefulWidget {
//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends ConsumerState<SplashScreen> {
//
//   bool _showSplash = true;
//   @override
//   // void initState() {
//   //   super.initState();
//   //   setupFCM();
//   //   _initDynamicLinks();
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     _handleStartUp();
//   //   });
//   // }
//
//   // void initState() {
//   //   super.initState();
//   //
//   //   // Remove native splash immediately
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     FlutterNativeSplash.remove();
//   //   });
//   //
//   //   setupFCM();
//   //   _initDynamicLinks();
//   //   _handleStartUp();
//   // }
//
//   void initState() {
//     super.initState();
//
//     // Remove native splash immediately
//     Future.microtask(() => FlutterNativeSplash.remove());
//
//     // Start your initialization
//     _initializeApp();
//   }
//   Future<void> _initializeApp() async {
//     // Do all your initialization
//     setupFCM();
//     _initDynamicLinks();
//
//     final prefs = await SharedPreferences.getInstance();
//     bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     bool locationSet = prefs.getBool('locationSet') ?? false;
//
//     if (isLoggedIn && !locationSet) {
//       await _showLocationBottomSheet();
//     } else if (isLoggedIn && locationSet) {
//       _autoUpdateLocation();
//     }
//
//     // Navigate after a minimum delay for smooth UX
//     await Future.delayed(const Duration(milliseconds: 1500));
//
//     if (mounted) {
//       checkLoginStatus();
//     }
//   }
//
//   void _initDynamicLinks() async {
//     // ignore: deprecated_member_use
//     FirebaseDynamicLinks.instance.onLink
//         .listen((PendingDynamicLinkData? data) {
//           final Uri? deepLink = data?.link;
//           _handleDeepLink(deepLink);
//         })
//         .onError((error) {
//           // print('Dynamic link failed: $error');
//         });
//     // ignore: deprecated_member_use
//     final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks
//         // ignore: deprecated_member_use
//         .instance
//         // ignore: deprecated_member_use
//         .getInitialLink();
//     final Uri? deepLink = initialLink?.link;
//     _handleDeepLink(deepLink);
//   }
//
//   void _handleDeepLink(Uri? deepLink) {
//     if (deepLink != null && deepLink.path.contains('reset')) {
//       final token = deepLink.queryParameters['token'];
//       if (token != null && mounted) {
//         // Navigate directly to Reset Password screen
//         Navigator.pushNamed(context, '/reset-password', arguments: token);
//       }
//     }
//   }
//
//   Future<void> _handleStartUp() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     bool locationSet = prefs.getBool('locationSet') ?? false;
//
//     if (isLoggedIn && !locationSet) {
//       // Show only first time after login
//       await _showLocationBottomSheet();
//     } else if (isLoggedIn && locationSet) {
//       // Auto update location silently
//       _autoUpdateLocation();
//     }
//
//     if (mounted) {
//       checkLoginStatus();
//     }
//   }
//
//   Future<void> _autoUpdateLocation() async {
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         // ignore: deprecated_member_use
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       // ✅ Use Riverpod ref here
//       final success = await ref
//           .read(addressProvider.notifier)
//           .updateLocationFromPosition(pos);
//
//       if (!success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to auto-update location")),
//         );
//       }
//     } catch (e) {
//       // print("Auto location update failed: $e");
//     }
//   }
//
//   Future<void> _showLocationBottomSheet() {
//     return showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: false,
//       enableDrag: false,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         bool isLocalLoading = false; // Local variable for bottom sheet
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return LayoutBuilder(
//               builder: (context, constraints) {
//                 final screenHeight = constraints.maxHeight;
//                 final screenWidth = constraints.maxWidth;
//
//                 return SizedBox(
//                   height: screenHeight * 0.45,
//                   width: double.infinity,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.06,
//                       vertical: screenHeight * 0.02,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.map_outlined,
//                           size: screenHeight * 0.12,
//                           color: Colors.blueAccent,
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//                         Text(
//                           "Enable Location TableServices",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.055,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: screenHeight * 0.015),
//                         Flexible(
//                           child: Text(
//                             "We need your location to show nearby restaurants and deliver your orders.",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.04,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//
//                         /// ✅ Location button with working spinner
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: isLocalLoading
//                                 ? null
//                                 : () async {
//                                     setModalState(() => isLocalLoading = true);
//                                     try {
//                                       final pos = await _getCurrentLocation();
//                                       if (pos != null) {
//                                         final success =
//                                             await _handleUpdateLocation(pos);
//                                         if (success && context.mounted) {
//                                           Navigator.pop(context);
//                                         }
//                                       }
//                                     } finally {
//                                       if (context.mounted) {
//                                         setModalState(
//                                           () => isLocalLoading = false,
//                                         );
//                                       }
//                                     }
//                                   },
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 vertical: screenHeight * 0.02,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: isLocalLoading
//                                   ? [
//                                       const SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Text(
//                                         "Updating location...",
//                                         style: TextStyle(
//                                           fontSize: screenWidth * 0.045,
//                                         ),
//                                       ),
//                                     ]
//                                   : [
//                                       Icon(
//                                         Icons.my_location,
//                                         size: screenWidth * 0.06,
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Text(
//                                         "Allow Location Access",
//                                         style: TextStyle(
//                                           fontSize: screenWidth * 0.045,
//                                         ),
//                                       ),
//                                     ],
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: screenHeight * 0.015),
//                         Text(
//                           "You must enable location to continue",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.035,
//                             color: Colors.redAccent,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<Position?> _getCurrentLocation() async {
//     // 1️⃣ Check if GPS is ON
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       return null; // Wait for user to enable it
//     }
//
//     // 2️⃣ Check app permission
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // User pressed "Deny" → show a snack bar
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Location permission is required to continue"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return null;
//       }
//     }
//
//     // 3️⃣ If deniedForever → open app settings
//     if (permission == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Enable location permission from App Settings"),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return null;
//     }
//
//     // 4️⃣ All good → get location
//     return await Geolocator.getCurrentPosition(
//       // ignore: deprecated_member_use
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }
//
//   Future<bool> _handleUpdateLocation(Position position) async {
//     final success = await AuthService.updateLocation(position);
//
//     if (!mounted) return false;
//
//     if (success) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('locationSet', true); // <-- store flag
//     }
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           success ? "✅ Location updated" : "❌ Failed to update location",
//         ),
//         backgroundColor: success ? Colors.green : Colors.red,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//     return success;
//   }
//
//   void checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     if (isLoggedIn) {
//       // Before navigating to HomePage
//       bool locationSet = prefs.getBool('locationSet') ?? false;
//
//       if (!locationSet) {
//         await _showLocationBottomSheet();
//       } else {
//         _autoUpdateLocation();
//       }
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MainScreenfood()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//       );
//     }
//   }
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   Future<void> setupFCM() async {
//     final fcm = FirebaseMessaging.instance;
//
//     // Request notification permissions
//     await fcm.requestPermission(alert: true, badge: true, sound: true);
//
//     // Get FCM token
//     String? token = await fcm.getToken();
//     // print("🔥 FCM Token: $token");
//
//     if (token != null) {
//       // Check login status
//       final isLoggedIn = await AuthService.isLoggedIn(); // implement this
//       if (isLoggedIn) {
//         // Send token to API every app launch if user is logged in
//         await AuthService.registerFcmToken(token);
//       } else {
//         // Store token locally for sending after login
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('fcm_token', token);
//       }
//     }
//
//     // Handle token refresh
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//       final isLoggedIn = await AuthService.isLoggedIn();
//       if (isLoggedIn) {
//         await AuthService.registerFcmToken(newToken);
//       } else {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('fcm_token', newToken);
//       }
//     });
//
//     // Foreground notification
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // print('📨 Foreground message: ${message.notification?.title}');
//       _showLocalNotification(message);
//     });
//
//     // Background notification tap
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // print('➡️ Notification opened from background');
//       _handleNotification(message);
//     });
//
//     // Terminated state notification
//     final initialMessage = await fcm.getInitialMessage();
//     if (initialMessage != null) {
//       // print('🚀 App opened via terminated notification');
//       _handleNotification(initialMessage);
//     }
//   }
//
//   // Call this after user logs in
//   Future<void> sendStoredFcmTokenAfterLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('fcm_token');
//     if (token != null) {
//       await AuthService.registerFcmToken(token);
//       // Optionally clear stored token after sending
//       await prefs.remove('fcm_token');
//     }
//   }
//
//   void _handleNotification(RemoteMessage message) {
//     final data = message.data;
//     final notificationType = data['notificationType'] ?? '';
//
//
//     Widget targetScreen;
//
//     switch (notificationType.toUpperCase()) {
//       case 'ORDER':
//         targetScreen = OrdersScreen();
//         break;
//       case 'WALLET':
//         targetScreen = WalletScreen();
//         break;
//       case 'FOOD':
//         targetScreen = MainScreennew();
//         break;
//       default:
//         targetScreen = MainScreennew();
//     }
//
//     GlobalLoader.navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (_) => targetScreen),
//     );
//   }
//
//   void _showLocalNotification(RemoteMessage message) {
//     final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     final notification = message.notification;
//     final android = message.notification?.android;
//
//     if (notification != null && android != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'High Importance Notifications',
//             channelDescription: 'Used for important notifications.',
//             importance: Importance.max,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//           ),
//         ),
//         payload: jsonEncode(message.data), // 👈 store data for later
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Match your native splash color
//       body: AnimatedOpacity(
//         opacity: _showSplash ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 500),
//         child: const AttractiveLoadingScreen(),
//       ),
//     );
//   }
// }
//
// class AppSession {
//   static bool locationRequested = false;
// }
//
// class AttractiveLoadingScreen extends StatefulWidget {
//   const AttractiveLoadingScreen({super.key});
//
//   @override
//   State<AttractiveLoadingScreen> createState() =>
//       _AttractiveLoadingScreenState();
// }
//
// class _AttractiveLoadingScreenState extends State<AttractiveLoadingScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   final List<String> _loadingTips = [
//     "Finding the best restaurants near you...",
//     "Discovering premium catering services...",
//     "Browsing fresh groceries for you...",
//     "Preparing your multi-service experience...",
//     "Almost ready! Your one-stop solution for food, catering & groceries...",
//     "Good things take time, just like quality food and service...",
//   ];
//
//   int _currentTipIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _animation = Tween<double>(
//       begin: 0.9,
//       end: 1.1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     // Change tip every 3 seconds
//     _changeTipPeriodically();
//     // Timer(const Duration(seconds: 4), () {
//     //   if (mounted) {
//     //     FlutterNativeSplash.remove();  // Reveals your animated Flutter screen
//     //   }
//     // });
//   }
//
//   void _changeTipPeriodically() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           _currentTipIndex = (_currentTipIndex + 1) % _loadingTips.length;
//         });
//         _changeTipPeriodically();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Animated multi-service icon
//           ScaleTransition(
//             scale: _animation,
//             child: Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(60),
//                 boxShadow: [
//                   BoxShadow(
//                     // ignore: deprecated_member_use
//                     color: const Color(0xFFB15DC6).withOpacity(0.2),
//                     blurRadius: 15,
//                     spreadRadius: 2,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Restaurant/Food icon
//                   const Icon(
//                     Icons.restaurant_menu,
//                     size: 40,
//                     color: Color(0xFFB15DC6),
//                   ),
//                   // Catering icon (top right)
//                   Positioned(
//                     top: 15,
//                     right: 15,
//                     child: Icon(
//                       Icons.celebration,
//                       size: 25,
//                       color: Colors.orange[700],
//                     ),
//                   ),
//                   // Groceries icon (bottom left)
//                   Positioned(
//                     bottom: 15,
//                     left: 15,
//                     child: Icon(
//                       Icons.shopping_basket,
//                       size: 25,
//                       color: Colors.green[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 30),
//
//           // App name/tagline
//           Text(
//             "Food ",
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.5,
//             ),
//           ),
//
//           const SizedBox(height: 30),
//
//           // Custom progress indicator with multi-color theme
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 width: 200,
//                 height: 10,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return Container(
//                     width: 200 * _controller.value,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFFB15DC6), // Purple for food
//                           Color(0xFFFF9800), // Orange for catering
//                           Color(0xFF4CAF50), // Green for groceries
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 30),
//
//           // Loading text with animation
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 500),
//             child: Text(
//               _loadingTips[_currentTipIndex],
//               key: ValueKey<int>(_currentTipIndex),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[700],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Multi-colored dots animation representing all services
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildServiceDot(0, const Color(0xFFB15DC6), Icons.restaurant),
//               _buildServiceDot(1, const Color(0xFFFF9800), Icons.celebration),
//               _buildServiceDot(
//                 2,
//                 const Color(0xFF4CAF50),
//                 Icons.shopping_basket,
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 40),
//
//           // Floating icons representing all three services
//           SizedBox(
//             height: 100,
//             child: Stack(
//               children: [
//                 // Food icons
//                 _buildFloatingIcon(
//                   Icons.local_pizza,
//                   0.2,
//                   0.1,
//                   const Color(0xFFB15DC6),
//                 ),
//                 _buildFloatingIcon(
//                   Icons.emoji_food_beverage,
//                   0.1,
//                   0.5,
//                   const Color(0xFFB15DC6),
//                 ),
//
//                 // Catering icons
//                 _buildFloatingIcon(Icons.celebration, 0.8, 0.2, Colors.orange),
//                 _buildFloatingIcon(Icons.event, 0.9, 0.6, Colors.orange),
//
//                 // Grocery icons
//                 _buildFloatingIcon(
//                   Icons.shopping_basket,
//                   0.3,
//                   0.8,
//                   Colors.green,
//                 ),
//                 _buildFloatingIcon(
//                   Icons.local_grocery_store,
//                   0.7,
//                   0.9,
//                   Colors.green,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildServiceDot(int index, Color color, IconData icon) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 500),
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       width: 35,
//       height: 35,
//       decoration: BoxDecoration(
//         color: _controller.value > index / 3
//             // ignore: deprecated_member_use
//             ? color.withOpacity(0.2)
//             : Colors.grey[300],
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: _controller.value > index / 3 ? color : Colors.grey[300]!,
//           width: 2,
//         ),
//       ),
//       child: Icon(
//         icon,
//         size: 18,
//         color: _controller.value > index / 3 ? color : Colors.grey[400],
//       ),
//     );
//   }
//
//   Widget _buildFloatingIcon(
//     IconData icon,
//     double left,
//     double top,
//     Color color,
//   ) {
//     return Positioned(
//       left: MediaQuery.of(context).size.width * left,
//       top: MediaQuery.of(context).size.height * 0.1 + top * 60,
//       child: ScaleTransition(
//         scale: Tween<double>(begin: 0.8, end: 1.2).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: Interval((left + top) / 2, 1.0, curve: Curves.easeInOut),
//           ),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             // ignore: deprecated_member_use
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//             // ignore: deprecated_member_use
//             border: Border.all(color: color.withOpacity(0.3), width: 1),
//           ),
//           // ignore: deprecated_member_use
//           child: Icon(icon, size: 24, color: color.withOpacity(0.8)),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:maamaas_app/screens/login_page.dart';
// import 'package:maamaas_app/screens/newscreens/foodmainscreen.dart';
// import 'package:maamaas_app/widgets/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'API/Auth_service.dart';
// import 'screens/addressmodel_provider.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
//
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }
//
// void main() async {
//   // 1. Hold native splash
//   WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.instance);
//
//   // 2. Hide system UI immediately
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       systemNavigationBarColor: Colors.transparent,
//     ),
//   );
//
//   // 3. Initialize Firebase
//   await Firebase.initializeApp();
//
//   // 4. Get user data
//   final prefs = await SharedPreferences.getInstance();
//   final userId = prefs.getInt('userId') ?? 0;
//
//   runApp(
//     ProviderScope(
//       overrides: [userIdProvider.overrideWithValue(userId)],
//       child: MyApp(navigatorKey: navigatorKey),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   final GlobalKey<NavigatorState> navigatorKey;
//   const MyApp({super.key, required this.navigatorKey});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           navigatorKey: navigatorKey,
//           debugShowCheckedModeBanner: false,
//           home: const AppInitializer(),
//           theme: ThemeData(
//             textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 14.sp)),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // New AppInitializer widget that handles the transition
// class AppInitializer extends ConsumerStatefulWidget {
//   const AppInitializer({super.key});
//
//   @override
//   ConsumerState<AppInitializer> createState() => _AppInitializerState();
// }
//
// class _AppInitializerState extends ConsumerState<AppInitializer> {
//   bool _showSplash = true;
//   bool _initializing = true;
//   Widget? _nextScreen;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }
//
//   Future<void> _initializeApp() async {
//     try {
//       // 1. Remove native splash IMMEDIATELY
//       FlutterNativeSplash.remove();
//
//       // 2. Run initialization in parallel
//       await Future.wait([
//         _setupFCM(),
//         _initDynamicLinks(),
//         _checkLoginStatus(),
//       ], eagerError: true);
//     } catch (e) {
//       print("Initialization error: $e");
//     } finally {
//       // 3. Prepare next screen
//       final prefs = await SharedPreferences.getInstance();
//       final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//       final locationSet = prefs.getBool('locationSet') ?? false;
//
//       Widget targetScreen;
//
//       if (isLoggedIn) {
//         if (!locationSet) {
//           // Show location sheet first, then home
//           targetScreen = LocationPromptScreen(
//             onLocationSet: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => MainScreenfood()),
//               );
//             },
//           );
//         } else {
//           targetScreen = MainScreenfood();
//         }
//       } else {
//         targetScreen = LoginPage();
//       }
//
//       setState(() {
//         _nextScreen = targetScreen;
//         _initializing = false;
//
//         // Show attractive loading screen for at least 1 second
//         Future.delayed(const Duration(seconds: 1), () {
//           if (mounted) {
//             setState(() {
//               _showSplash = false;
//             });
//           }
//         });
//       });
//     }
//   }
//
//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     final locationSet = prefs.getBool('locationSet') ?? false;
//
//     if (isLoggedIn && locationSet) {
//       await _autoUpdateLocation();
//     }
//   }
//
//   Future<void> _autoUpdateLocation() async {
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       await ref.read(addressProvider.notifier).updateLocationFromPosition(pos);
//     } catch (e) {
//       // Silent fail
//     }
//   }
//
//   Future<void> _setupFCM() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission(alert: true, badge: true, sound: true);
//     String? token = await fcm.getToken();
//
//     if (token != null) {
//       final isLoggedIn = await AuthService.isLoggedIn();
//       if (isLoggedIn) {
//         await AuthService.registerFcmToken(token);
//       } else {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('fcm_token', token);
//       }
//     }
//   }
//
//   Future<void> _initDynamicLinks() async {
//     FirebaseDynamicLinks.instance.onLink
//         .listen((PendingDynamicLinkData? data) {
//       final Uri? deepLink = data?.link;
//       _handleDeepLink(deepLink);
//     }).onError((error) {});
//
//     final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
//     _handleDeepLink(initialLink?.link);
//   }
//
//   void _handleDeepLink(Uri? deepLink) {
//     if (deepLink != null && deepLink.path.contains('reset')) {
//       final token = deepLink.queryParameters['token'];
//       if (token != null && mounted) {
//         Navigator.pushNamed(context, '/reset-password', arguments: token);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_showSplash) {
//       // Show attractive loading screen
//       return const AttractiveLoadingScreen();
//     } else if (_nextScreen != null) {
//       // Show the next screen directly
//       return _nextScreen!;
//     } else {
//       // Fallback
//       return Container(color: Colors.white);
//     }
//   }
// }
//
// // LocationPromptScreen Widget
// class LocationPromptScreen extends StatefulWidget {
//   final VoidCallback onLocationSet;
//
//   const LocationPromptScreen({
//     super.key,
//     required this.onLocationSet,
//   });
//
//   @override
//   State<LocationPromptScreen> createState() => _LocationPromptScreenState();
// }
//
// class _LocationPromptScreenState extends State<LocationPromptScreen> {
//   bool _isLoading = false;
//
//   Future<void> _handleLocationPermission() async {
//     setState(() => _isLoading = true);
//
//     try {
//       // Check location permission
//       LocationPermission permission = await Geolocator.checkPermission();
//
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         await Geolocator.openAppSettings();
//         return;
//       }
//
//       if (permission == LocationPermission.whileInUse ||
//           permission == LocationPermission.always) {
//
//         // Get current position
//         final position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//
//         // Update location via API
//         final success = await AuthService.updateLocation(position);
//
//         if (success && mounted) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setBool('locationSet', true);
//           widget.onLocationSet();
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("Failed to update location"),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Location error: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.location_on_outlined,
//                 size: 100.h,
//                 color: Colors.blueAccent,
//               ),
//               SizedBox(height: 30.h),
//               Text(
//                 "Enable Location TableServices",
//                 style: TextStyle(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 15.h),
//               Text(
//                 "We need your location to show nearby restaurants and deliver your orders.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   color: Colors.black54,
//                 ),
//               ),
//               SizedBox(height: 30.h),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _handleLocationPermission,
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16.h),
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 20.h,
//                         height: 20.h,
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       Text(
//                         "Setting up location...",
//                         style: TextStyle(fontSize: 16.sp),
//                       ),
//                     ],
//                   )
//                       : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.my_location, size: 20.w),
//                       SizedBox(width: 12.w),
//                       Text(
//                         "Allow Location Access",
//                         style: TextStyle(fontSize: 16.sp),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 15.h),
//               if (!_isLoading)
//                 TextButton(
//                   onPressed: () {
//                     // Skip for now, go to home
//                     widget.onLocationSet();
//                   },
//                   child: Text(
//                     "Skip for now",
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Keep your existing AttractiveLoadingScreen class as is (no changes needed)
//
// // Keep your existing AttractiveLoadingScreen class as is
// class AttractiveLoadingScreen extends StatefulWidget {
//   const AttractiveLoadingScreen({super.key});
//
//   @override
//   State<AttractiveLoadingScreen> createState() =>
//       _AttractiveLoadingScreenState();
// }
//
// class _AttractiveLoadingScreenState extends State<AttractiveLoadingScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   final List<String> _loadingTips = [
//     "Finding the best restaurants near you...",
//     "Discovering premium catering services...",
//     "Browsing fresh groceries for you...",
//     "Preparing your multi-service experience...",
//     "Almost ready! Your one-stop solution for food, catering & groceries...",
//     "Good things take time, just like quality food and service...",
//   ];
//   int _currentTipIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _animation = Tween<double>(
//       begin: 0.9,
//       end: 1.1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _changeTipPeriodically();
//   }
//
//   void _changeTipPeriodically() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           _currentTipIndex = (_currentTipIndex + 1) % _loadingTips.length;
//         });
//         _changeTipPeriodically();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Important: Set background color
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ScaleTransition(
//               scale: _animation,
//               child: Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(60),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFFB15DC6).withOpacity(0.2),
//                       blurRadius: 15,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     const Icon(
//                       Icons.restaurant_menu,
//                       size: 40,
//                       color: Color(0xFFB15DC6),
//                     ),
//                     Positioned(
//                       top: 15,
//                       right: 15,
//                       child: Icon(
//                         Icons.celebration,
//                         size: 25,
//                         color: Colors.orange[700],
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 15,
//                       left: 15,
//                       child: Icon(
//                         Icons.shopping_basket,
//                         size: 25,
//                         color: Colors.green[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             Text(
//               "Food ",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[700],
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//             const SizedBox(height: 30),
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 200,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 AnimatedBuilder(
//                   animation: _controller,
//                   builder: (context, child) {
//                     return Container(
//                       width: 200 * _controller.value,
//                       height: 10,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [
//                             Color(0xFFB15DC6),
//                             Color(0xFFFF9800),
//                             Color(0xFF4CAF50),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 500),
//               child: Text(
//                 _loadingTips[_currentTipIndex],
//                 key: ValueKey<int>(_currentTipIndex),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[700],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildServiceDot(0, const Color(0xFFB15DC6), Icons.restaurant),
//                 _buildServiceDot(1, const Color(0xFFFF9800), Icons.celebration),
//                 _buildServiceDot(
//                   2,
//                   const Color(0xFF4CAF50),
//                   Icons.shopping_basket,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//             SizedBox(
//               height: 100,
//               child: Stack(
//                 children: [
//                   _buildFloatingIcon(
//                     Icons.local_pizza,
//                     0.2,
//                     0.1,
//                     const Color(0xFFB15DC6),
//                   ),
//                   _buildFloatingIcon(
//                     Icons.emoji_food_beverage,
//                     0.1,
//                     0.5,
//                     const Color(0xFFB15DC6),
//                   ),
//                   _buildFloatingIcon(
//                     Icons.celebration,
//                     0.8,
//                     0.2,
//                     Colors.orange,
//                   ),
//                   _buildFloatingIcon(Icons.event, 0.9, 0.6, Colors.orange),
//                   _buildFloatingIcon(
//                     Icons.shopping_basket,
//                     0.3,
//                     0.8,
//                     Colors.green,
//                   ),
//                   _buildFloatingIcon(
//                     Icons.local_grocery_store,
//                     0.7,
//                     0.9,
//                     Colors.green,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceDot(int index, Color color, IconData icon) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 500),
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       width: 35,
//       height: 35,
//       decoration: BoxDecoration(
//         color: _controller.value > index / 3
//             ? color.withOpacity(0.2)
//             : Colors.grey[300],
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: _controller.value > index / 3 ? color : Colors.grey[300]!,
//           width: 2,
//         ),
//       ),
//       child: Icon(
//         icon,
//         size: 18,
//         color: _controller.value > index / 3 ? color : Colors.grey[400],
//       ),
//     );
//   }
//
//   Widget _buildFloatingIcon(
//     IconData icon,
//     double left,
//     double top,
//     Color color,
//   ) {
//     return Positioned(
//       left: MediaQuery.of(context).size.width * left,
//       top: MediaQuery.of(context).size.height * 0.1 + top * 60,
//       child: ScaleTransition(
//         scale: Tween<double>(begin: 0.8, end: 1.2).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: Interval((left + top) / 2, 1.0, curve: Curves.easeInOut),
//           ),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//             border: Border.all(color: color.withOpacity(0.3), width: 1),
//           ),
//           child: Icon(icon, size: 24, color: color.withOpacity(0.8)),
//         ),
//       ),
//     );
//   }
// }
//
// class AppSession {
//   static bool locationRequested = false;
// }