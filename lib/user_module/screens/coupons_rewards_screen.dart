// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/Auth_service.dart';
import '../Models/coupon_model.dart';
import '../Models/profile_model.dart';

class CouponsAndRewards extends StatefulWidget {
  const CouponsAndRewards({super.key});

  @override
  State<CouponsAndRewards> createState() => _CouponsAndRewardsState();
}

class _CouponsAndRewardsState extends State<CouponsAndRewards>
    with SingleTickerProviderStateMixin {
  bool isDrawerOpen = false;
  int selectedIndex = -1;
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Colors
  final Color _primaryColor = const Color(0xFFB15DC6);
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Coupons"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Enhanced Tab Bar
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TabBar(
                controller: _tabController,
                labelColor: _primaryColor,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: "Coupons"),
                  Tab(text: "Refer & Earn"),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(const CouponsTab()),
                _buildTabContent(const ReferEarnTab()),
              ],
            ),
            // Expanded(
            //   child: CouponsTab(),
          ),
        ],
      ),
      // bottomNavigationBar: SafeArea(top: false, child: home_footer()),
    );
  }

  Widget _buildTabContent(Widget child) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(padding: EdgeInsets.all(16.w), child: child),
    );
  }
}

class CouponsTab extends StatefulWidget {
  const CouponsTab({super.key});

  @override
  State<CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<CouponsTab> {
  // List<dynamic> coupons = [];
  bool isLoading = true;
  List<CouponModel> coupons = [];

  @override
  void initState() {
    super.initState();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    try {
      final data = await AuthService.fetchCoupons();
      setState(() {
        coupons = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveDiscountToStorage(double discountPercentage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('appliedDiscount', discountPercentage);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 $discountPercentage% discount applied!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  bool isCouponExpired(String endDate) {
    try {
      final expiry = DateTime.parse(endDate);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return false;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(const Color(0xFFB15DC6)),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading Coupons...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_num_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No Coupons Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later for exciting offers!',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          /// Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB15DC6).withOpacity(0.1),
                  const Color(0xFF4A44B5).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  color: const Color(0xFF6C63FF),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '${coupons.length} Coupons Available',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          /// Coupons Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              double width = constraints.maxWidth;

              if (width > 900) {
                crossAxisCount = 4;
              } else if (width > 600) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                shrinkWrap: true, // 🔑 important
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.9,
                ),
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  final coupon = coupons[index];

                  return DiscountCard(
                    discountText: coupon.discountPercentage.toString(),
                    promoCode: coupon.code,
                    startDate: coupon.startDate.toIso8601String(),
                    endDate: coupon.endDate.toIso8601String(),
                    isExpired: coupon.isExpired,
                    couponType: coupon.couponType,
                    minimumOrderValue: coupon.minimumOrderValue,
                    discountType: coupon.discountType,
                    onApply: coupon.isExpired
                        ? null
                        : () async {
                            await saveDiscountToStorage(
                              coupon.discountPercentage,
                            );
                          },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class DiscountCard extends StatelessWidget {
  final String discountText;
  final String promoCode;
  final VoidCallback? onApply;
  final String startDate;
  final String endDate;
  final bool isExpired;
  final String couponType;
  final double minimumOrderValue;
  final String discountType;

  const DiscountCard({
    required this.discountText,
    required this.promoCode,
    required this.startDate,
    required this.endDate,
    required this.isExpired,
    this.onApply,
    required this.couponType,
    required this.minimumOrderValue,
    required this.discountType,
    super.key,
  });

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB15DC6).withOpacity(0.05),
                    const Color(0xFF4A44B5).withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    couponType,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Discount Percentage
                // Center(
                //   child: Text(
                //     discountText == "PERCENTAGE"
                //         ? "${discountText}% OFF"
                //         : "₹${discountText} OFF",
                //     style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 16,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
                Center(
                  child: Text(
                    discountType == "PERCENTAGE"
                        ? "${discountText}% OFF"
                        : "₹${discountText} OFF",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Promo Code
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        promoCode,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  minimumOrderValue <= 0
                      ? "Applicable on any order"
                      : "Min order ₹${minimumOrderValue.toInt()}",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                SizedBox(height: 5.h),
                // Validity
                Text(
                  'Valid until ${_formatDate(endDate)}',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Expired Overlay
          if (isExpired)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.highlight_off_rounded,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'EXPIRED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReferEarnTab extends StatefulWidget {
  const ReferEarnTab({super.key});

  @override
  State<ReferEarnTab> createState() => _ReferEarnTabState();
}

class _ReferEarnTabState extends State<ReferEarnTab> {
  late Future<UserProfile_model?> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = AuthService.fetchUserProfileData();
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    String referralCode, {
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == "Copy Code") {
          Clipboard.setData(ClipboardData(text: referralCode));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Referral code copied: $referralCode"),
              backgroundColor: const Color(0xFFB15DC6),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        } else if (label == "Share") {
          const appLink =
              "https://play.google.com/store/apps/details?id=com.maamaas.app";
          final message =
              "🎉 Join Maamaas using my referral code: $referralCode\n\n"
              "📲 Download the app here: $appLink";

          Share.share(message);
        }
      },
      icon: Icon(icon, size: 18.sp),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF6C63FF) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF6C63FF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : const Color(0xFF6C63FF),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
      ),
    );
  }

  Widget _buildStep(
    IconData icon,
    String title,
    String subtitle,
    int stepNumber,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        // ignore: duplicate_ignore
        // ignore: deprecated_member_use
        color: const Color(0xFFB15DC6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        // ignore: duplicate_ignore
        // ignore: deprecated_member_use
        border: Border.all(color: const Color(0xFFB15DC6).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Icon(icon, size: 24.sp, color: const Color(0xFF6C63FF)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile_model?>(
      future: _futureProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFB15DC6),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Loading referral info...',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60.sp, color: Colors.grey[400]),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load referral code',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final referralCode = snapshot.data!.referralCode;

        return Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFB15DC6), const Color(0xFF4A44B5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                // boxShadow: [
                //   BoxShadow(
                //     // ignore: duplicate_ignore
                //     // ignore: deprecated_member_use
                //     color: const Color(0xFFB15DC6).withOpacity(0.3),
                //     blurRadius: 20,
                //     offset: const Offset(0, 10),
                //   ),
                // ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard_rounded,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Refer & Earn Rewards",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Invite friends and get exclusive rewards when they sign up!",
                    style: TextStyle(
                      fontSize: 14.sp,
                      // ignore: duplicate_ignore
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Referral Code Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    // ignore: duplicate_ignore
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Your Referral Code",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        // ignore: duplicate_ignore
                        // ignore: deprecated_member_use
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      // ignore: duplicate_ignore
                      // ignore: deprecated_member_use
                      color: const Color(0xFFB15DC6).withOpacity(0.05),
                    ),
                    child: Center(
                      child: Text(
                        referralCode,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C63FF),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          Icons.copy_rounded,
                          "Copy Code",
                          referralCode,
                          isPrimary: false,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionButton(
                          Icons.share_rounded,
                          "Share",
                          referralCode,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // How it Works Section
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    // ignore: duplicate_ignore
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How it Works",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildStep(
                    Icons.person_add_alt_1_rounded,
                    "Share your referral code",
                    "Send your code to friends and family",
                    1,
                  ),
                  _buildStep(
                    Icons.how_to_reg_rounded,
                    "Friends sign up",
                    "They use your code when registering",
                    2,
                  ),
                  _buildStep(
                    Icons.card_giftcard_rounded,
                    "You earn rewards",
                    "Get exclusive rewards when they join",
                    3,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
