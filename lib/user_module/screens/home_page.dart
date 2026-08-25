import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:maamaaspartner/user_module/API/Auth_service.dart';
import 'package:maamaaspartner/user_module/screens/saved_address.dart';
import 'Advideo.dart';
import 'verticals/vertical type2.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = "";
  int _currentIndex = 0;
  String _currentLocation = "Fetching location...";
  bool _updateAvailable = false;
  AppUpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    _loadLocationFromAPI();
    _checkForUpdate();
  }

  void _loadLocationFromAPI() async {
    final location = await AuthService.fetchCurrentLocation();

    if (!mounted) return;

    if (location != null) {
      setState(() {
        _currentLocation = location.address;
      });
    } else {
      setState(() {
        _currentLocation = "Fetching location...";
      });

      // show dialog after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateLocationDialog();
      });
    }
  }

  void _showUpdateLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8.w),
              Text("Location Required"),
            ],
          ),
          content: const Text(
            "We couldn't detect your location. Please update your location to continue.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Later"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _changeLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB15DC6),
              ),
              child: const Text("Update Location"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkForUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();

      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        setState(() {
          _updateAvailable = true;
        });
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  void _startFlexibleUpdate() async {
    if (_updateInfo != null) {
      try {
        await InAppUpdate.performImmediateUpdate();
      } catch (e) {
        debugPrint("Error starting update: $e");
      }
    }
  }

  void _changeLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedAddress(
          onAddressSelected: (city, pincode, state, lat, lng, id) {
            setState(() {
              _currentLocation = "$city, $state - $pincode";
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.blueAccent,
          displacement: 40,
          strokeWidth: 3,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          child: ListView(
            // padding: EdgeInsets.all(16),
            children: [
              _buildVideoSection(),
              // VideoPreviewContainer(),
              const SizedBox(height: 16),
              // QuickAccessScroll5(),
              Vertical(),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(child: VideoPreviewContainer()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
      automaticallyImplyLeading: false,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Location",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: _changeLocation,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _currentLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFB15DC6),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),

      /// 🔔 ACTIONS
      // actions: [
      //   Padding(
      //     padding: EdgeInsets.only(right: 12.w),
      //     child: GestureDetector(
      //       onTap: () => openProfileDrawer(context),
      //       child: CircleAvatar(
      //         radius: 18.r,
      //         backgroundColor: Colors.grey.shade500,
      //         child: Icon(Icons.person, color: Colors.black87, size: 22.sp),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}
