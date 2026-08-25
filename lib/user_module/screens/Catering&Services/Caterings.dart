import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../API/catering_authservice.dart';
import '../../Models/caterings/banner_model.dart';
import '../../Models/caterings/packages_model.dart';
import '../../widgets/catering/cartbutton.dart';
import 'Catering_vedor_screen.dart';
import 'customised_menu.dart';

class CateringsPage extends StatefulWidget {
  @override
  _CateringsPageState createState() => _CateringsPageState();
}

class _CateringsPageState extends State<CateringsPage> {
  List<Package> packages = [];
  Set<int> expandedPackages = {};
  late Future<List<catering_BannerModel>> _bannersFuture;
  ValueNotifier<Map<String, int>> cartItems = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _bannersFuture = catering_authservice.fetchBanners();
  }

  Future<void> _fetchPackages() async {
    final data = await catering_authservice.fetchTopRatedPackages();
    if (!mounted) return; // ✅ safety
    setState(() {
      packages = data;
    });
  }

  // 🔹 Microphone / Audio

  Widget build(BuildContext context) {
    return SizedBox(
      height: 420.h, // or MediaQuery height fraction
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: const Color(0xFFFF7043),
              tabs: const [
                Tab(text: "Packages"),
                Tab(text: "Custom Menu"),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [buildpackagedcards(), CustomisedMenu()],
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }

  Widget buildpackagedcards() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(   // ✅ VERY IMPORTANT
            child: _buildtopcaterers(),
          ),
        ],
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

  Widget _buildtopcaterers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Text(
            "Top Caterers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(   // ✅ FIXED
          child: FutureBuilder<List<catering_BannerModel>>(
            future: _bannersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No banners available"));
              }

              final banners = snapshot.data!;

              return ListView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(
                            vendorId: banner.vendorId.toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: banner.companyBanner.startsWith("http")
                                  ? Image.network(
                                banner.companyBanner,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                                  : Image.memory(
                                base64Decode(banner.companyBanner),
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                banner.companyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "(${formatDistance(banner.distance)})",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
