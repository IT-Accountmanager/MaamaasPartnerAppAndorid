import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maamaaspartner/user_module/screens/saved_address.dart';
import 'package:maamaaspartner/user_module/screens/support_team.dart';
import 'package:maamaaspartner/user_module/screens/wallet_screen.dart';
import 'package:media_compressor/media_compressor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login_screen.dart';
import '../API/Auth_service.dart';
import '../Models/profile_model.dart';
import '../widgets/profileavataor.dart';
import '../widgets/version_text.dart';
import 'Favorites.dart';
import 'Food&beverages/table_bookings.dart';
import 'Food&beverages/tablecart.dart';
import 'account_delete.dart';
import 'coupons_rewards_screen.dart';
import 'login_page.dart';
import 'orders_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isLoading = false;
  Uint8List? _selectedImageBytes;
  String? _fetchedImageUrl;
  String _verificationStatus = "complted";

  @override
  void initState() {
    super.initState();
    initilize();
    // _loadProfileImage();
  }

  void initilize() {
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    final profile = await AuthService.fetchUserProfileData();
    if (profile != null && mounted) {
      setState(() {
        _fetchedImageUrl = profile.image; // must match backend field name
      });
    }
  }

  Future<void> _uploadImage(BuildContext context, File profileImage) async {
    try {
      // print("🔄 Starting profile image upload...");
      // print("📁 File path: ${profileImage.path}");

      if (!profileImage.existsSync()) {
        // print("❌ File does not exist");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("❌ Image file not found")));
        return;
      }

      // print("📦 File size: ${profileImage.lengthSync()} bytes");

      final bool success = await AuthService.updateProfileImage(profileImage);

      // print("📨 Upload response success: $success");

      if (success) {
        // print("✅ Profile image uploaded successfully");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Profile image updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // print("🔄 Reloading profile image...");
        _loadProfileImage(); // Refresh after success
      } else {
        // print("❌ Upload failed (API returned false)");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Failed to update profile image"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // print("🔥 Exception during image upload");
      // print("❌ Error: $e");
      // print("📌 StackTrace: $stack");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error uploading image: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    const secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll();

    // debugPrint("🔒 Logged out — cleared user data & tokens");

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage1()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FutureBuilder<UserProfile_model?>(
                future: AuthService.fetchUserProfileData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const Text("Failed to load user profile");
                  }

                  final user = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          UploadableProfileAvatar(
                            heroTag: "profile_pic",
                            imageBytes: _selectedImageBytes,
                            networkImageUrl: _fetchedImageUrl,
                            onImageSelected: (File imageFile) async {
                              final result =
                              await MediaCompressor.compressImage(
                                ImageCompressionConfig(
                                  path: imageFile.path,
                                  quality: 80,
                                  maxWidth: 1920,
                                  maxHeight: 1080,
                                ),
                              );

                              if (result.isSuccess) {
                                final compressedFile = File(result.path!);

                                await imageFile.length();
                                await compressedFile.length();

                                await _uploadImage(context, compressedFile);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ Image compression failed"),
                                  ),
                                );
                              }
                            },
                          ),

                          if (_isLoading)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        user.emailId,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        user.mobileNumber.isNotEmpty
                            ? user.mobileNumber
                            : 'N/A',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(color: Colors.black),
          Expanded(child: SidebarMenu(verificationStatus: _verificationStatus)),
          const Divider(),
          VersionText(),
        ],
      ),
    );
  }
}

class SidebarMenu extends StatefulWidget {
  final String verificationStatus;

  const SidebarMenu({Key? key, required this.verificationStatus})
      : super(key: key);

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  List<Map<String, dynamic>> sidebarItems = [];
  String userType = "PERSONAL";
  int? seatingId;

  // Default location text

  @override
  void initState() {
    super.initState();
    _loadSidebarItems();
  }

  void _loadSidebarItems() async {
    await getUserType(); // ensure seatingId is loaded first
    final items = await getSidebarItems();
    setState(() {
      sidebarItems = items;
    });
  }

  Future<void> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    userType = prefs.getString('userType') ?? "PERSONAL";
    seatingId = prefs.getInt('id');
  }

  Future<List<Map<String, dynamic>>> getSidebarItems() async {
    await getUserType();

    final items = [
      {'icon': Icons.shopping_cart, 'title': 'Orders', 'page': OrdersScreen()},
      {'icon': Icons.wallet, 'title': 'Wallet', 'page': WalletScreen()},
      {
        'icon': Icons.table_restaurant,
        'title': 'Table Bookings',
        'page': TableBookings(),
      },
      {
        'icon': Icons.shopping_cart,
        'title': 'Table cart',
        'page': tablecart(seatingId: seatingId ?? 0),
      },
      {
        'icon': Icons.location_on,
        'title': 'Address Book',
        'page': SavedAddress(
          onAddressSelected: (city, pincode, state, lat, lng, id) {
            setState(() {});
          },
        ),
      },
      {'icon': Icons.favorite, 'title': 'Favorite', 'page': Favorites()},
      {
        'icon': Icons.notifications,
        'title': 'Rewards & Coupons',
        'page': CouponsAndRewards(),
      },
      {
        'icon': Icons.support_agent,
        'title': 'Support Team',
        'page': Supportteam(),
      },
      {'icon': Icons.account_box, 'title': 'Account', 'page': AccountScreen()},

      {'icon': Icons.logout, 'title': 'Logout', 'logout': true},
    ];

    return items;
  }

  Future<void> logout(BuildContext context) async {
    // debugPrint("🧨 UI logout() CALLED");

    await AuthService.logout();

    // debugPrint("🧨 UI logout() AFTER AuthService.logout");

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage1()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sidebarItems.length,
      itemBuilder: (context, index) {
        final item = sidebarItems[index];
        return ListTile(
          leading: Icon(item['icon']),
          title: Text(item['title']),
          onTap: () async {
            // debugPrint("🖱 Sidebar item tapped: ${item['title']}");

            if (item['logout'] as bool? ?? false) {
              await logout(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['page']),
              );
            }
          },
        );
      },
    );
  }
}



