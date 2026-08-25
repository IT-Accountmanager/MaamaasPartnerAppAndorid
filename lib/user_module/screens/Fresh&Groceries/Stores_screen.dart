import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaaspartner/user_module/screens/Fresh&Groceries/grocerystore_screen.dart';
import '../../API/Auth_service.dart';
import '../../API/grocery_authservice.dart';
import '../../Models/coupon_model.dart';
import '../../Models/grocery/grocery_banner_model.dart';
import '../../widgets/profiledrawer.dart';
import '../Advideo.dart';
import '../saved_address.dart';

class stores extends StatefulWidget {
  @override
  _storesState createState() => _storesState();
}

class _storesState extends State<stores> {
  String _currentLocation = "Fetching location...";
  List<grocery_Banner> banners = [];

  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    fetchBanners();
  }

  void fetchBanners() async {
    try {
      final result = await grocery_authservice().fetchBanners();
      setState(() {
        banners = result;
      });
    } catch (e) {
      print("Error fetching banners: $e");
    }
  }

  void _changeLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedAddress(
          onAddressSelected: (city, pincode, state, lat, lng, id) {
            setState(() {
              _currentLocation =
                  "$city, $state "
                  "- $pincode";
            });
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    debugPrint("🔄 Refresh triggered!");
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _initializeData());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Stack(children: [_buildBody()]),
      ),
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
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: GestureDetector(
            onTap: () => openProfileDrawer(context),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.grey.shade500,
              child: Icon(Icons.person, color: Colors.black87, size: 22.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Color(0xFF6C63FF),
      displacement: 40,
      strokeWidth: 3,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildVideoSection()),
          SliverToBoxAdapter(child: CouponsOffersSection()),
          SliverToBoxAdapter(child: _buildNearbyRestaurantsSection()),
        ],
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

  Widget _buildNearbyRestaurantsSection() {
    return Column(
      children: [
        _buildSectionHeader(
          "Top Brands for you",
          Icons.location_on,
          const Color(0xFF6C63FF),
        ),
        NearbyRestaurentBannersWidget(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              // ignore: duplicate_ignore
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class NearbyRestaurentBannersWidget extends StatefulWidget {
  final String? orderType;

  const NearbyRestaurentBannersWidget({super.key, this.orderType});

  @override
  State<NearbyRestaurentBannersWidget> createState() =>
      _NearbyRestaurentBannersWidgetState();
}

class _NearbyRestaurentBannersWidgetState
    extends State<NearbyRestaurentBannersWidget> {
  double _maxCardHeight = 0;
  static const double _minCardHeight = 180;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<grocery_Banner>>(
      future: grocery_authservice().fetchBanners(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSection();
        }

        if (snapshot.hasError) {
          return _buildErrorSection("Error loading nearby restaurants");
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection("No nearby restaurants found");
        }

        final List<grocery_Banner> filtered = widget.orderType == null
            ? snapshot.data! // 👈 SHOW ALL
            : snapshot.data!
                  .where((b) => b.orderTypes.contains(widget.orderType))
                  .toList();

        if (filtered.isEmpty) {
          return _buildEmptySection("No matches for this order type");
        }

        return _buildHorizontalList(filtered);
      },
    );
  }

  Widget _buildLoadingSection() {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6C63FF)),
            SizedBox(height: 12.h),
            Text(
              "Loading nearby restaurants...",
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40.sp, color: Colors.grey[400]),
            SizedBox(height: 10.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 40.sp, color: Colors.grey[400]),
            SizedBox(height: 10.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
  // ---------------- RESPONSIVE SCROLL + GRID ----------------

  Widget _buildHorizontalList(List<grocery_Banner> banners) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 12.w;
        final double horizontalPadding = 24.w;
        final double cardWidth =
            (constraints.maxWidth - horizontalPadding - spacing) / 2;

        return SizedBox(
          // 🔥 ALWAYS give height
          height: _maxCardHeight > 0 ? _maxCardHeight : _minCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: banners.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (context, index) {
              return _MeasuredCard(
                width: cardWidth,
                onHeight: (h) {
                  if (h > _maxCardHeight) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _maxCardHeight = h);
                      }
                    });
                  }
                },
                child: _buildNearbyRestaurantCard(banners[index]),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------- CARD UI ----------------

  Widget _buildNearbyRestaurantCard(grocery_Banner banner) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => store_Screen(vendorId: banner.vendorId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Responsive image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: banner.companyBanner.isNotEmpty
                    ? Image.network(
                        banner.companyBanner,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                      )
                    : _buildPlaceholderIcon(),
              ),
            ),

            // 🔹 Content
            Padding(
              padding: EdgeInsets.all(1.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Company name
                  Text(
                    banner.companyName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Type
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       banner.Type.isNotEmpty
                  //           ? banner.Type[0].toUpperCase() +
                  //           banner.Type.substring(1).toLowerCase()
                  //           : "",
                  //       style: TextStyle(
                  //         fontSize: 11.sp,
                  //         color: const Color(0xFF6C63FF),
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //       maxLines: 1,
                  //       overflow: TextOverflow.ellipsis,
                  //     ),
                  //     Spacer(),
                  //     Text(
                  //       "(${formatDistance(banner.distance)})",
                  //       style: TextStyle(
                  //         fontSize: 11.sp,
                  //         color: const Color(0xFF6C63FF),
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 12.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          "${banner.addressLine}, ${banner.city}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDistance(num distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.restaurant, size: 28.sp, color: Colors.grey[400]),
      ),
    );
  }
}

class CouponsOffersSection extends StatelessWidget {
  CouponsOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CouponModel>>(
      future: AuthService.fetchCoupons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 140,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
                const SizedBox(height: 8),
                Text(
                  "Failed to load offers",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final coupons = snapshot.data!
            .where((c) => c.active && !c.isExpired)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.local_offer_outlined,
            //         size: 20,
            //         color: Color(0xFF6B7280),
            //       ),
            //       SizedBox(width: 8),
            //       Text(
            //         "Offers & Coupons",
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.w600,
            //           color: Color(0xFF111827),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // SizedBox(
            //   height: 140,
            //   child: ListView.separated(
            //     padding: const EdgeInsets.symmetric(horizontal: 20),
            //     scrollDirection: Axis.horizontal,
            //     physics: const BouncingScrollPhysics(),
            //     itemCount: coupons.length + 2,
            //     separatorBuilder: (_, __) => const SizedBox(width: 16),
            //     itemBuilder: (context, index) {
            //       const double cardWidth = 280;
            //
            //       if (index < coupons.length) {
            //         return SizedBox(
            //           width: cardWidth,
            //           child: CouponCard(coupon: coupons[index], index: index)
            //         );
            //       }
            //
            //       return SizedBox(
            //         width: cardWidth,
            //         child: _staticCouponCard(index - coupons.length),
            //       );
            //     },
            //   ),
            // ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 3, // 👈 number of static cards
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  const double cardWidth = 280;

                  return SizedBox(
                    width: cardWidth,
                    child: _staticCouponCard(index),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  final List<Map<String, dynamic>> staticCoupons = [
    {
      "headline": "Authentic Taste. Fantastic Savings.",
      "title": "First Order",
      "offer": "Get Flat ₹25 OFF on Your First Order!",
      // "description": "",
      "type": "REFER",
      // "icon": Icons.group_add_outlined,
      "gradient": const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
      ),
      "iconBg": Color(0xFFEEF2FF),
      "badge": "LIMITLESS",
    },
    {
      "headline": "Invite Friends. Unlock Rewards.",
      "title": "Refer & Earn",
      "offer": "Earn ₹25 Cashback Per Referral!",
      // "description": "",
      "type": "REFER",
      // "icon": Icons.group_add_outlined,
      "gradient": const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      ),
      "iconBg": Color(0xFFEEF2FF),
      "badge": "LIMITLESS",
    },
    {
      "headline": "Recharge More. Earn More.",
      "title": "Wallet Recharge",
      "offer": "Get a Flat 10% Cashback!",
      // "description": "",
      "type": "WALLET",
      // "icon": Icons.account_balance_wallet_outlined,
      "gradient": const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF059669), Color(0xFF10B981)],
      ),
      "iconBg": Color(0xFFECFDF5),
      "badge": "HOT DEAL",
    },
  ];

  Widget _staticCouponCard(int index) {
    final data = staticCoupons[index];

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: data["gradient"] as LinearGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //     color: data["iconBg"] as Color,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: Icon(
                    //     data["icon"] as IconData,
                    //     size: 20,
                    //     color:
                    //     (data["gradient"] as LinearGradient).colors.first,
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data["headline"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Badge
                    // Container(
                    //   padding:
                    //   const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Text(
                    //     data["badge"],
                    //     style: const TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 10,
                    //       fontWeight: FontWeight.w700,
                    //       letterSpacing: 0.6,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                // const Spacer(),
                const SizedBox(height: 6),

                // Offer
                Text(
                  data["offer"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                // Description
                // Text(
                //   data["description"],
                //   style: TextStyle(
                //     color: Colors.white.withOpacity(0.9),
                //     fontSize: 13,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasuredCard extends StatefulWidget {
  final Widget child;
  final double width;
  final ValueChanged<double> onHeight;

  const _MeasuredCard({
    required this.child,
    required this.width,
    required this.onHeight,
  });

  @override
  State<_MeasuredCard> createState() => _MeasuredCardState();
}

class _MeasuredCardState extends State<_MeasuredCard> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        widget.onHeight(box.size.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Container(key: _key, child: widget.child),
    );
  }
}
