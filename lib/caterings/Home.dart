import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../Api/APIclient.dart';
import 'Account&Histort.dart';
import 'AddBannerPage.dart';
import 'EditAboutUsPage.dart';
import 'MenuManagement.dart';
import 'OrderManagement.dart';
import 'Profile.dart';
import 'PromotionsDiscounts.dart';
import 'ReportAndAnalysisPage.dart';
import 'leads.dart';

class CateringLandingPage extends StatefulWidget {
  const CateringLandingPage({super.key});

  @override
  State<CateringLandingPage> createState() => CateringLandingPageState();
}

class CateringLandingPageState extends State<CateringLandingPage> {
  bool isLoading = true;
  bool showKnowMore = false;
  bool _isMobile = false;
  int _selectedFooterIndex = 0;
  String companyName = "";
  String establishedYear = "";
  String companyLogo = "";
  String companyBanner = "";
  String aboutUs = "";
  String aboutUsImage = "";
  String mission = "";
  String vision = "";
  bool showGallery = false;

  bool _updateAvailable = false;

  final ImagePicker picker = ImagePicker();
  int _selectedIndex = 0;
  File? logoImage;
  File? bannerImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  List<dynamic> teamMembers = [];
  List<String> galleryImages = [];

  int vendorId = 0;
  String? _authToken;
  double _dailyRevenue = 0.0;
  int _dailyOrders = 0;
  double _averageRating = 0.0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    fetchBannerData();
    fetchTeamData();
    fetchAboutUsData();
    _loadVendorIdAndFetchStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMobile();
    });
  }

  void _checkMobile() {
    final width = MediaQuery.of(context).size.width;
    setState(() {
      _isMobile = width < 768;
    });
  }

  Future<void> _loadVendorIdAndFetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedVendorId = prefs.getInt('vendorId') ?? 0;
      _authToken =
          prefs.getString('authToken') ??
          prefs.getString('token') ??
          prefs.getString('accessToken');

      setState(() {
        vendorId = storedVendorId;
      });

      if (vendorId > 0 && _authToken != null) {
        await _fetchDashboardStats();
      } else {
        setState(() {
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading vendor ID: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _fetchDashboardStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Simulated API call - replace with actual catering API
      await Future.delayed(Duration(seconds: 1));

      // Mock data - replace with actual API call
      setState(() {
        _dailyRevenue = 12500.0;
        _dailyOrders = 8;
        _averageRating = 4.5;
        _isLoadingStats = false;
      });

      // Uncomment and replace with actual API call:
      /*
      final today = DateTime.now();
      final from = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final to = from;

      final url = 'YOUR_CATERING_API_URL?vendorId=$vendorId&fromDate=$from&toDate=$to';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dailyRevenue = (data['dailyRevenue'] ?? 0).toDouble();
          _dailyOrders = (data['dailyOrders'] ?? 0).toInt();
          _averageRating = (data['averageRating'] ?? 0).toDouble();
          _isLoadingStats = false;
        });
      }
      */
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> fetchBannerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt("vendorId");

      if (vendorId == null || vendorId == 0) {
        debugPrint("❌ Vendor ID not found");
        setState(() => isLoading = false);
        return;
      }

      final response = await ApiClient.get(
        "banner/get/$vendorId",
        service: "catering",
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        dynamic data =
            jsonResponse is Map<String, dynamic> &&
                jsonResponse.containsKey('data')
            ? jsonResponse['data']
            : jsonResponse;

        setState(() {
          companyName = data['companyName'] ?? '';
          establishedYear = data['establishedYear'] ?? '';
          companyLogo = data['companyLogo'] ?? '';
          companyBanner = data['companyBanner'] ?? '';

          if (companyLogo.isNotEmpty && !companyLogo.startsWith('http')) {
            companyLogo = "http://10.10.20.9:7007/$companyLogo";
          }

          if (companyBanner.isNotEmpty && !companyBanner.startsWith('http')) {
            companyBanner = "http://10.10.20.9:7007/$companyBanner";
          }

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("🔥 Exception: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTeamData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt("vendorId");

      if (vendorId == null || vendorId == 0) {
        debugPrint("❌ Vendor ID not found");
        return;
      }

      final response = await ApiClient.get(
        "team/getall/$vendorId", // ✅ dynamic here
        service: "catering",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          teamMembers = data.map((member) {
            String imagePath = member['image'] ?? '';

            if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
              if (imagePath.startsWith('/')) {
                imagePath = imagePath.substring(1);
              }

              member['image'] = "http://10.10.20.9:7007/$imagePath";
            }

            return member;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("🔥 Team API Exception: $e");
    }
  }

  Future<void> fetchAboutUsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt("vendorId");

      if (vendorId == null || vendorId == 0) {
        debugPrint("❌ Vendor ID not found");
        return;
      }

      final response = await ApiClient.get(
        "aboutus/$vendorId", // ✅ dynamic
        service: "catering",
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        setState(() {
          aboutUs = jsonResponse['aboutUs'] ?? '';
          aboutUsImage = jsonResponse['image'] ?? '';
          mission = jsonResponse['mission'] ?? '';
          vision = jsonResponse['vision'] ?? '';

          galleryImages = [];

          for (int i = 0; i <= 4; i++) {
            String key = i == 0 ? 'image' : 'image$i';
            String? imgUrl = jsonResponse[key];

            if (imgUrl != null && imgUrl.isNotEmpty) {
              if (!imgUrl.startsWith('http')) {
                if (imgUrl.startsWith('/')) {
                  imgUrl = imgUrl.substring(1);
                }
                imgUrl = "http://10.10.20.9:7007/$imgUrl";
              }
              galleryImages.add(imgUrl);
            }
          }

          if (aboutUsImage.isNotEmpty && !aboutUsImage.startsWith('http')) {
            if (aboutUsImage.startsWith('/')) {
              aboutUsImage = aboutUsImage.substring(1);
            }

            aboutUsImage = "http://10.10.20.9:7007/$aboutUsImage";
          }
        });
      } else {
        debugPrint("❌ Failed to load About Us: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🔥 About Us Exception: $e");
    }
  }

  // Header Section with Performance Today card - SAME UI as Food & Beverages
  Widget _buildHeaderSection() {
    if (_isLoadingStats) {
      return _buildLoadingShimmer();
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Today\'s Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A0947),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(DateTime.now()),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ],
          ),

          SizedBox(height: 16),

          // Performance Today Card
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7c3aed).withOpacity(0.1),
                  Color(0xFF10B981).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLiveStatItem(
                      'Revenue',
                      '₹${_dailyRevenue.toStringAsFixed(0)}',
                      Colors.green,
                      Icons.currency_rupee,
                    ),
                    _buildLiveStatItem(
                      'Bookings',
                      _dailyOrders.toString(),
                      Colors.blue,
                      Icons.event_available,
                    ),
                    _buildLiveStatItem(
                      'Rating',
                      _averageRating.toStringAsFixed(1),
                      Colors.orange,
                      Icons.star,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Live stat item widget - SAME UI as Food & Beverages
  Widget _buildLiveStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 150, height: 24, color: Colors.grey.shade200),
              Container(width: 100, height: 24, color: Colors.grey.shade200),
            ],
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _isMobile ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: _isMobile ? 3 : 2,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Offers Section - SAME UI as Food & Beverages
  Widget _buildOffersSection() {
    final PageController _pageController = PageController();
    int _currentPage = 0;
    Timer? _carouselTimer;

    void _stopAutoScroll() {
      _carouselTimer?.cancel();
      _carouselTimer = null;
    }

    void _startAutoScroll() {
      _stopAutoScroll();
      _carouselTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          int nextPage = _currentPage + 1;
          if (nextPage >= 3) {
            nextPage = 0;
          }
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });

    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            onPageChanged: (index) {
              _currentPage = index;
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: _isMobile ? 12 : 16),
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width - (_isMobile ? 24 : 32),
                  child: _buildCouponCard(index),
                ),
              );
            },
          ),

          // Page indicators
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(int index) {
    final List<Map<String, dynamic>> cateringCoupons = [
      {
        "headline": "Elegant Catering. Exceptional Value.",
        "title": "First Booking",
        "offer": "Get 15% OFF on Your First Catering Event!",
        "gradient": const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        "iconBg": Color(0xFFEEF2FF),
        "badge": "LIMITLESS",
      },
      {
        "headline": "Corporate Events. Premium Service.",
        "title": "Corporate Package",
        "offer": "Exclusive 20% OFF for Corporate Clients!",
        "gradient": const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        "iconBg": Color(0xFFEEF2FF),
        "badge": "LIMITLESS",
      },
      {
        "headline": "Wedding Perfection. Unforgettable Moments.",
        "title": "Wedding Package",
        "offer": "Special 25% OFF on Wedding Catering!",
        "gradient": const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF10B981)],
        ),
        "iconBg": Color(0xFFECFDF5),
        "badge": "HOT DEAL",
      },
    ];

    final data = cateringCoupons[index];

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
                Row(
                  children: [
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
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data["offer"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Links Section - SAME UI as Food & Beverages
  Widget _buildQuickLinks(BuildContext context) {
    final cateringModules = _getCateringModules();

    return Container(
      margin: EdgeInsets.all(_isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.apps, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Quick Links",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: cateringModules.length,
              itemBuilder: (context, index) {
                final module = cateringModules[index];
                Color color = Colors.purple; // Default color for catering

                // You can customize colors for different modules
                if (module['title'] == 'Menu Management')
                  color = Colors.red;
                else if (module['title'] == 'Order Management')
                  color = Colors.teal;
                else if (module['title'] == 'Promotions & Discounts')
                  color = Colors.amber;
                else if (module['title'] == 'Leads')
                  color = Colors.green;
                else if (module['title'] == 'Accounts & History')
                  color = Colors.deepPurple;
                else if (module['title'] == 'Reports & Analytics')
                  color = Colors.indigo;
                else if (module['title'] == 'Profile')
                  color = Colors.blue;

                return GestureDetector(
                  onTap: () => _navigateToModule(module, context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [color, color.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              module['icon'] as IconData,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            module['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF2A0947),
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCateringModules() {
    return [
      {
        'icon': Icons.restaurant_menu,
        'title': 'Menu Management',
        'page': const MenuManagementPage(),
      },
      {
        'icon': Icons.shopping_cart,
        'title': 'Order Management',
        'page': const OrderManagementPage(),
      },
      {
        'icon': Icons.discount,
        'title': 'Promotions & Discounts',
        'page': const PromotionsPage(),
      },
      {'icon': Icons.leaderboard, 'title': 'Leads', 'page': const LeadManagementPage ()},
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Accounts & History',
        'page': const CateringAccountHistoryPage(),
      },
      {
        'icon': Icons.pie_chart,
        'title': 'Reports & Analytics',
        'page': const ReportAndAnalysisPagecatering(),
      },
      // {
      //   'icon': Icons.person,
      //   'title': 'Profile',
      //   'page': const ProfilePage(),
      // },
      {
        'icon': Icons.add_a_photo,
        'title': 'Add Banner',
        'page': null,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBannerPage(
                vendorId: 1,
                onBannerSaved: (banner) {
                  fetchBannerData();
                },
              ),
            ),
          );
        },
      },
    ];
  }

  void _navigateToModule(
    Map<String, dynamic> module,
    BuildContext context,
  ) async {
    if (module['action'] != null) {
      module['action']();
      return;
    }

    if (module['page'] is Widget) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => module['page'] as Widget),
      );
    }
  }

  // Banner Section - Modified to match new UI structure
  // Widget _buildBannerSection() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     height: 260,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),
  //       image: DecorationImage(
  //         image: companyBanner.isNotEmpty
  //             ? NetworkImage(companyBanner)
  //             : const NetworkImage('https://via.placeholder.com/600x300'),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //     child: Stack(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(20),
  //             gradient: LinearGradient(
  //               colors: [Colors.black.withOpacity(0.6), Colors.transparent],
  //               begin: Alignment.bottomCenter,
  //               end: Alignment.topCenter,
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           top: 16,
  //           right: 16,
  //           left: 16,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Row(
  //                 children: [
  //                   CircleAvatar(
  //                     backgroundImage: companyLogo.isNotEmpty
  //                         ? NetworkImage(companyLogo)
  //                         : const NetworkImage(
  //                         'https://via.placeholder.com/100'),
  //                     radius: 30,
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(companyName.isNotEmpty
  //                           ? companyName
  //                           : "Catering Brand",
  //                           style: const TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 24,
  //                               fontWeight: FontWeight.bold)),
  //                       Text("Since ${establishedYear.isNotEmpty
  //                           ? establishedYear
  //                           : '----'}",
  //                           style:
  //                           const TextStyle(
  //                               color: Colors.white70, fontSize: 16)),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) =>
  //                           AddBannerPage(
  //                             vendorId: 1,
  //                             onBannerSaved: (banner) {
  //                               fetchBannerData();
  //                             },
  //                           ),
  //                     ),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.deepPurple,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(30),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   "Add Banner",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _isMobile = constraints.maxWidth < 768;

        return Container(
          decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
          child: SafeArea(
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                // CORRECTED SliverAppBar with proper properties
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  floating: true,
                  pinned: true,
                  expandedHeight: 70,
                  // safe height
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(color: Colors.white),
                    titlePadding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 8,
                    ),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Maamaas Catering Partner',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18, // 👈 reduced to avoid overflow
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeaderSection(),
                    _buildOffersSection(),
                    _buildQuickLinks(context),

                    //
                    // if (!isLoading)
                    //   Container(
                    //     child: _buildBannerSection(),
                    //   ),

                    // if (showKnowMore) ...[
                    //   _buildAboutUsSection(),
                    //   _buildMissionVisionSection(),
                    //   _buildTeamSection(),
                    //   if (showGallery) _buildGallerySection(),
                    // ],
                    SizedBox(height: 100),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Rest of your existing methods (Team, About Us, Mission Vision, Gallery sections)
  // Widget _buildAboutUsSection() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.3),
  //           blurRadius: 6,
  //           offset: const Offset(2, 2),
  //         )
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               "About Us",
  //               style: TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color(0xFFB15DC6),
  //               ),
  //             ),
  //             ElevatedButton.icon(
  //               onPressed: () async {
  //                 final updated = await Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => EditAboutUsPage(
  //                       vendorId: 1,
  //                       existingData: {
  //                         "aboutUsId": 0,
  //                         "aboutUs": "",
  //                         "vendorId": 1,
  //                         "image": "",
  //                         "image1": "",
  //                         "image2": "",
  //                         "image3": "",
  //                         "image4": "",
  //                         "mission": "",
  //                         "vision": "",
  //                       },
  //                     ),
  //                   ),
  //                 );
  //                 if (updated == true) {
  //                   fetchAboutUsData();
  //                 }
  //               },
  //               icon: const Icon(Icons.edit, color: Colors.white),
  //               label: const Text("Edit", style: TextStyle(color: Colors.white)),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.deepPurple,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(30),
  //                 ),
  //                 padding: const EdgeInsets.symmetric(
  //                     horizontal: 16, vertical: 10),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         if (aboutUsImage.isNotEmpty)
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(12),
  //             child: Image.network(
  //               aboutUsImage,
  //               height: 180,
  //               width: double.infinity,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         const SizedBox(height: 12),
  //         if (aboutUs.isNotEmpty)
  //           Text(
  //             aboutUs,
  //             style: const TextStyle(fontSize: 15, color: Colors.black87),
  //           ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildMissionVisionSection() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.3),
  //           blurRadius: 6,
  //           offset: const Offset(2, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               "Our Commitments",
  //               style: TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color(0xFFB15DC6),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         if (mission.isNotEmpty)
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 "Our Mission",
  //                 style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.deepPurple),
  //               ),
  //               const SizedBox(height: 6),
  //               Text(
  //                 mission,
  //                 style: const TextStyle(fontSize: 15, color: Colors.black87),
  //               ),
  //               const SizedBox(height: 12),
  //             ],
  //           ),
  //         if (vision.isNotEmpty)
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 "Our Vision",
  //                 style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.deepPurple),
  //               ),
  //               const SizedBox(height: 6),
  //               Text(
  //                 vision,
  //                 style: const TextStyle(fontSize: 15, color: Colors.black87),
  //               ),
  //             ],
  //           ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildTeamSection() {
  //   if (teamMembers.isEmpty) {
  //     return const Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Center(
  //         child: Text(
  //           "No team members found.",
  //           style: TextStyle(fontSize: 16, color: Colors.grey),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Our Team",
  //           style: TextStyle(
  //             fontSize: 22,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFFB15DC6),
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         SizedBox(
  //           height: 190,
  //           child: ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             itemCount: teamMembers.length,
  //             itemBuilder: (context, index) {
  //               final member = teamMembers[index];
  //               return Container(
  //                 width: 130,
  //                 margin: const EdgeInsets.symmetric(horizontal: 8),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(12),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.grey.withOpacity(0.3),
  //                       blurRadius: 4,
  //                       offset: const Offset(2, 2),
  //                     )
  //                   ],
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     ClipRRect(
  //                       borderRadius:
  //                       const BorderRadius.vertical(top: Radius.circular(12)),
  //                       child: Image.network(
  //                         member['image'] ?? '',
  //                         height: 110,
  //                         width: 130,
  //                         fit: BoxFit.cover,
  //                         errorBuilder: (context, error, stackTrace) => Image.asset(
  //                           'assets/images/user_placeholder.png',
  //                           height: 110,
  //                           width: 130,
  //                           fit: BoxFit.cover,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 6),
  //                     Text(
  //                       member['name'] ?? 'Unknown',
  //                       style: const TextStyle(
  //                           fontWeight: FontWeight.bold, fontSize: 14),
  //                     ),
  //                     Text(
  //                       member['role'] ?? '',
  //                       style: const TextStyle(color: Colors.grey, fontSize: 12),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildGallerySection() {
  //   if (!showGallery) return const SizedBox.shrink();
  //
  //   if (galleryImages.isEmpty) {
  //     return const Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Center(
  //         child: Text(
  //           "No gallery images found.",
  //           style: TextStyle(fontSize: 16, color: Colors.grey),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Gallery",
  //           style: TextStyle(
  //             fontSize: 22,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFFB15DC6),
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         GridView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 2,
  //             crossAxisSpacing: 8,
  //             mainAxisSpacing: 8,
  //           ),
  //           itemCount: galleryImages.length,
  //           itemBuilder: (context, index) {
  //             return GestureDetector(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => Scaffold(
  //                       backgroundColor: Colors.black,
  //                       appBar: AppBar(
  //                         backgroundColor: Colors.black,
  //                         title: const Text("Gallery View"),
  //                       ),
  //                       body: Center(
  //                         child: InteractiveViewer(
  //                           child: Image.network(
  //                             galleryImages[index],
  //                             fit: BoxFit.contain,
  //                             errorBuilder: (context, error, stack) => const Icon(
  //                               Icons.broken_image,
  //                               color: Colors.white,
  //                               size: 100,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(12),
  //                 child: Image.network(
  //                   galleryImages[index],
  //                   fit: BoxFit.cover,
  //                   errorBuilder: (context, error, stack) => Container(
  //                     color: Colors.grey[200],
  //                     child: const Icon(Icons.image_not_supported,
  //                         color: Colors.grey, size: 40),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Bottom Navigation Bar - SAME UI as Food & Beverages
  Widget? _buildFooter() {
    return BottomNavigationBar(
      currentIndex: _selectedFooterIndex,
      onTap: (index) {
        setState(() {
          _selectedFooterIndex = index;
          // Handle navigation similar to Food & Beverages
          switch (index) {
            case 0: // Home
              // Already on home
              break;
            case 1: // Orders
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderManagementPage()),
              );
              break;
            case 2: // Menu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuManagementPage()),
              );
              break;
            case 3: // Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              break;
          }
        });
      },
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFB15DC6),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  // Drawer - SAME UI as Food & Beverages
  // Drawer _buildDrawer(BuildContext context) {
  //   return Drawer(
  //     width: MediaQuery.of(context).size.width * 0.75,
  //     child: SafeArea(
  //       child: Container(
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             colors: [Color(0xFFFFFDFD), Color(0xFFF0EEF1)],
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             _buildDrawerHeader(),
  //             Expanded(child: _buildDrawerMenu(context)),
  //             _buildDrawerFooter(context),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  //   Widget _buildDrawerHeader() {
  //     return Container(
  //       height: 180,
  //       decoration: BoxDecoration(
  //         color: Colors.deepPurple,
  //         borderRadius: BorderRadius.only(
  //           bottomLeft: Radius.circular(20),
  //           bottomRight: Radius.circular(20),
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.3),
  //             blurRadius: 10,
  //             offset: Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Stack(
  //         children: [
  //           Positioned(
  //             right: -20,
  //             top: -20,
  //             child: Icon(
  //               Icons.event_seat,
  //               size: 120,
  //               color: Colors.white.withOpacity(0.3),
  //             ),
  //           ),
  //           Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Container(
  //                   width: 80,
  //                   height: 80,
  //                   decoration: BoxDecoration(
  //                     color: Color(0xFF2A0947),
  //                     shape: BoxShape.circle,
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.3),
  //                         blurRadius: 8,
  //                         offset: Offset(0, 4),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Icon(Icons.restaurant, color: Colors.amber, size: 40),
  //                 ),
  //                 SizedBox(height: 12),
  //                 Text(
  //                   "MAAMAA'S CATERING",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                     letterSpacing: 1.5,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   Widget _buildDrawerMenu(BuildContext context) {
  //     final drawerItems = [
  //       {
  //         'icon': Icons.dashboard,
  //         'title': 'Dashboard',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => CateringLandingPage(),
  //       },
  //       {
  //         'icon': Icons.restaurant_menu,
  //         'title': 'Menu Management',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => const MenuManagementPage(),
  //       },
  //       {
  //         'icon': Icons.shopping_cart,
  //         'title': 'Order Management',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => const OrderManagementPage(),
  //       },
  //       {
  //         'icon': Icons.discount,
  //         'title': 'Promotions & Discounts',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => const PromotionsPage(),
  //       },
  //       {
  //         'icon': Icons.leaderboard,
  //         'title': 'Leads',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => const LeadsPage(),
  //       },
  //       {
  //         'icon': Icons.account_balance_wallet,
  //         'title': 'Accounts & History',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => const AccountHistoryPage(),
  //       },
  //       {
  //         'icon': Icons.pie_chart,
  //         'title': 'Reports & Analytics',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => const ReportAndAnalysisPage(),
  //       },
  //       {
  //         'icon': Icons.person,
  //         'title': 'Profile',
  //         'color': Color(0xFFB15DC6),
  //         'backgroundColor': Color(0xFFF3E5F5),
  //         'pageBuilder': () => const ProfilePage(),
  //       },
  //     ];
  //
  //     return ListView(
  //       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
  //       children: drawerItems.map((item) {
  //         return Container(
  //           margin: const EdgeInsets.only(bottom: 12),
  //           decoration: BoxDecoration(
  //             color: item['backgroundColor'] as Color,
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.08),
  //                 blurRadius: 4,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: ListTile(
  //             leading: Container(
  //               width: 40,
  //               height: 40,
  //               decoration: BoxDecoration(
  //                 color: item['color'] as Color,
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Icon(
  //                 item['icon'] as IconData,
  //                 color: Colors.white,
  //                 size: 20,
  //               ),
  //             ),
  //             title: Text(
  //               item['title'] as String,
  //               style: TextStyle(
  //                 color: Colors.black,
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             trailing: Icon(
  //               Icons.chevron_right,
  //               color: item['color'] as Color,
  //             ),
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               final pageBuilder = item['pageBuilder'] as Widget Function();
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (_) => pageBuilder()),
  //               );
  //             },
  //           ),
  //         );
  //       }).toList(),
  //     );
  //   }
  //
  //   Widget _buildDrawerFooter(BuildContext context) {
  //     return Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: Colors.black.withOpacity(0.2),
  //         borderRadius: const BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             width: 40,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: Colors.amber,
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: const Icon(Icons.person, color: Color(0xFF2A0947)),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   "Catering Admin",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Text(
  //                   "admin@maamaas.com",
  //                   style: TextStyle(
  //                     color: Colors.white.withOpacity(0.7),
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           IconButton(
  //             icon: Icon(Icons.logout, color: Colors.white.withOpacity(0.7)),
  //             onPressed: () async {
  //               // Handle logout
  //             },
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  // Main build method - using the same structure
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _buildHomeContent(),
      bottomNavigationBar: _buildFooter(),
      // Floating action button for Know More
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     setState(() {
      //       showKnowMore = !showKnowMore;
      //     });
      //   },
      //   icon: Icon(showKnowMore ? Icons.expand_less : Icons.expand_more),
      //   label: Text(showKnowMore ? "Show Less" : "Know More"),
      //   backgroundColor: Color(0xFFB15DC6),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
