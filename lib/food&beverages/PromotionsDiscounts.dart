import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/widgets_helper/food/footer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API/food_authservice.dart';
import '../Models/food&beverages/TopRestaurant.dart';
import '../Models/food&beverages/coupon_model.dart';

class PromotionDiscountPage extends StatefulWidget {
  const PromotionDiscountPage({super.key});

  @override
  State<PromotionDiscountPage> createState() => _PromotionDiscountPageState();
}

class _PromotionDiscountPageState extends State<PromotionDiscountPage> {
  List<Map<String, Coupon>> promotions = [];

  File? selectedImage;
  File? selectedVideo;

  List<Map<String, dynamic>> advertisements = [];
  bool isLoadingAds = true;

  Future<void> _onRefresh() async {
    debugPrint("🔄 Refresh triggered!");
    await _initializeData(); // load/refresh your data
    setState(() {}); // trigger rebuild after data is updated
  }

  Future<void> _initializeData() async {
    await fetchAdvertisements();
    await loadTopRestaurants();
  }

  @override
  void initState() {
    super.initState();
    _initializeData(); // Load data on page load
  }

  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  void submitTopRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 0;

    if (descriptionController.text.isEmpty ||
        amountController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      print("Please fill all fields");
      return;
    }

    TopRestaurant newTop = TopRestaurant(
      description: descriptionController.text,
      amount: double.tryParse(amountController.text) ?? 0,
      startDate: startDate!,
      endDate: endDate!,
      vendorId: vendorId,
    );

    final success = await TopRatedService.addTopRestaurant(newTop);

    if (success) {
      print("Top restaurant added!");
      loadTopRestaurants(); // refresh the list
    } else {
      print("Failed to add top restaurant");
    }
  }

  bool isLoadingTopRestaurants = true;
  List<dynamic> topRestaurants = [];
  Future<void> loadTopRestaurants() async {
    setState(() => isLoadingTopRestaurants = true);

    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId');

    if (vendorId == null) {
      setState(() => isLoadingTopRestaurants = false);
      return;
    }

    final data = await TopRestaurantService.getTopRestaurants(vendorId);

    setState(() {
      topRestaurants = data;
      isLoadingTopRestaurants = false;
    });
  }

  Future<void> fetchAdvertisements() async {
    setState(() => isLoadingAds = true);

    final ads = await food_authservice.fetchAdvertisements();

    setState(() {
      advertisements = ads;
      isLoadingAds = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Promotions & Discounts",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Color(0xFF6C63FF),
          displacement: 40,
          strokeWidth: 3,
          onRefresh: _onRefresh,
          child: Column(
            children: [
              // TabBar moved here
              Container(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: "Coupons"),
                    Tab(text: "Advertisement"),
                    Tab(text: "Top Restaurant"),
                  ],
                ),
              ),
              // Expanded TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCouponsTab(context),
                    _buildAdvertisementTab(context),
                    _buildTopRestaurantTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget _buildCouponsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Coupon>>(
              future: food_authservice.fetchCoupons(),
              builder: (context, snapshot) {
                // 🔹 Debug: log connection state
                if (kDebugMode) {
                  debugPrint(
                    "📡 FutureBuilder state: ${snapshot.connectionState}",
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (kDebugMode) debugPrint("⏳ Loading coupons...");
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  if (kDebugMode) {
                    debugPrint("❌ Error fetching coupons: ${snapshot.error}");
                  }
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  if (kDebugMode) {
                    debugPrint("⚠️ No coupons found in API response.");
                  }
                  return const Center(child: Text("No coupons available"));
                }

                // ✅ Success
                final promotions = snapshot.data!;
                if (kDebugMode) {
                  debugPrint(
                    "✅ Coupons fetched successfully: ${promotions.length}",
                  );
                  for (var i = 0; i < promotions.length; i++) {
                    debugPrint(
                      "🔸 Coupon ${i + 1}: ${promotions[i].couponCode}",
                    );
                  }
                }

                return ListView.builder(
                  itemCount: promotions.length,
                  itemBuilder: (context, index) {
                    final promo = promotions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ⭐ UPDATED: Full width image like Advertisement tab
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: _buildCouponImageFullWidth(
                              promo.image,
                              promo.couponCode,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Coupon Code: ${promo.couponCode}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "From: ${formatDateTime(promo.startDate)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Valid Until: ${formatDateTime(promo.endDate)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Amount: ${promo.amount}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                Text("Description: ${promo.description}"),

                                // const SizedBox(height: 8),
                                const SizedBox(height: 8),
                                // ✅ Pay button
                                if (promo.paymentStatus ==
                                    PaymentStatus.PENDING)
                                  SizedBox(
                                    width: double.infinity, // full width button
                                    child: ElevatedButton(
                                      onPressed: () {
                                        CouponPayment().payCoupon(
                                          context,
                                          promo,
                                        );
                                        // Navigate to payment page or call payment function
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF67B95F,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text("Pay"),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (kDebugMode)
                debugPrint("🟢 Navigating to RequestCouponPage...");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestCouponPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF67B95F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 110,
                vertical: 14,
              ),
            ),
            child: const Text("Request a Coupon"),
          ),
        ],
      ),
    );
  }

  String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(
        dateString,
      ).toLocal(); // Convert to local time
      final formatter = DateFormat(
        'dd MMM yyyy, hh:mm a',
      ); // Example: 13 Nov 2025, 02:45 PM
      return formatter.format(date);
    } catch (e) {
      return dateString; // fallback in case parsing fails
    }
  }

  // ⭐ NEW: Full width image widget for coupons (same as advertisement)
  Widget _buildCouponImageFullWidth(String imageData, String couponCode) {
    try {
      if (imageData.isEmpty) {
        debugPrint("⚠️ No image data for $couponCode");
        return Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 40, color: Colors.grey[500]),
              SizedBox(height: 8),
              Text('No Image', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        );
      }

      // 🧩 CASE 1: base64 image
      if (imageData.startsWith('data:image') || imageData.length > 200) {
        debugPrint("🖼️ Loading base64 image for $couponCode");
        final base64Str = imageData.contains(',')
            ? imageData.split(',')[1]
            : imageData;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: double.infinity,
          fit: BoxFit.cover, // Changed from contain to cover for better display
          errorBuilder: (_, __, ___) {
            debugPrint("⚠️ Invalid base64 image for $couponCode");
            return Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                  SizedBox(height: 8),
                  Text(
                    'Invalid Image',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        );
      }

      // 🧩 CASE 2: network image (http/https)
      if (imageData.startsWith('http')) {
        debugPrint("🌐 Loading network image for $couponCode → $imageData");
        return Image.network(
          imageData,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            debugPrint("⚠️ Failed to load network image for $couponCode");
            return Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        );
      }

      // 🧩 CASE 3: relative path
      debugPrint("🖼️ Relative image path for $couponCode → $imageData");
      final fixedUrl = "http://10.10.20.9:6363/$imageData";
      return Image.network(
        fixedUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          debugPrint("⚠️ Failed to load relative path image for $couponCode");
          return Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                SizedBox(height: 8),
                Text(
                  'Image not found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("❌ Exception displaying image for $couponCode: $e");
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 40, color: Colors.grey[500]),
            SizedBox(height: 8),
            Text(
              'Error loading image',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMediaWidget(String url) {
    Widget _buildDefaultPlaceholder() {
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey[500]),
            SizedBox(height: 8),
            Text('No Media', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().endsWith('.mov')) {
      // Video placeholder
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.videocam, size: 50, color: Colors.black54),
        ),
      );
    } else if (url.startsWith('http')) {
      // Image from network
      return Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _buildDefaultPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else if (url.isNotEmpty) {
      // Relative path or invalid
      final fixedUrl = "http://10.10.20.9:6363/$url";
      return Image.network(
        fixedUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _buildDefaultPlaceholder();
        },
      );
    } else {
      // Empty URL - show default placeholder
      return _buildDefaultPlaceholder();
    }
  }

  Widget _buildAdvertisementTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: advertisements.isEmpty
                ? const Center(
                    child: Text(
                      "No Advertisement Data Yet",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: advertisements.length,
                    itemBuilder: (context, index) {
                      final ad = advertisements[index];

                      final mediaUrl = ad['mediaUrl'] ?? '';
                      final title = ad['title'] ?? '';
                      final description = ad['description'] ?? '';
                      final amount = (ad['amount'] ?? 0).toString();
                      final startDate = ad['startDate'] ?? '';
                      final endDate = ad['endDate'] ?? '';
                      final paymentStatus = ad['paymentStatus'] ?? 'PENDING';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMediaWidget1(mediaUrl),

                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Title: $title",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text("Description: $description"),
                                  Text("Amount: ₹$amount"),
                                  Text(
                                    "Valid: ${formatDateTime(startDate)} - ${formatDateTime(endDate)}",
                                  ),
                                  Text(
                                    "Payment Status: $paymentStatus",
                                    style: TextStyle(
                                      color: paymentStatus == "PAID"
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  if (paymentStatus == "PENDING")
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          debugPrint(
                                            "🔄 Pay Now clicked for advertisement:",
                                          );
                                          debugPrint("🔸 ID: ${ad['id']}");
                                          debugPrint("🔸 Title: $title");
                                          debugPrint("🔸 Amount: $amount");
                                          debugPrint(
                                            "🔸 Payment Status: $paymentStatus",
                                          );

                                          AdvertisementPayment()
                                              .payAdvertisement(context, ad);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: const Text(
                                          "Pay Now",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          _bottomButton(
            text: "Request Advertisement",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestAdvertisementPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaWidget1(String mediaUrl) {
    if (mediaUrl.isEmpty) return const SizedBox();

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Image.network(
        mediaUrl,
        width: double.infinity,
        fit: BoxFit.contain, // shows full uploaded image
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Icon(Icons.broken_image, size: 60),
          );
        },
      ),
    );
  }

  Widget _buildTopRestaurantTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: isLoadingTopRestaurants
                ? const Center(child: CircularProgressIndicator())
                : topRestaurants.isEmpty
                ? const Center(
                    child: Text(
                      "No Top Restaurant Data Yet",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: topRestaurants.length,
                    itemBuilder: (context, index) {
                      final item = topRestaurants[index];

                      // -------------------------------
                      // CORRECT PAYMENT STATUS
                      // -------------------------------
                      final paymentStatus = item['paymentStatus'] ?? "UNKNOWN";

                      // -------------------------------
                      // PERFECT AMOUNT FORMAT
                      // -------------------------------
                      final dynamic amount = item['amount'];
                      String displayAmount = "0.00";

                      if (amount != null) {
                        if (amount is int) {
                          displayAmount = amount.toStringAsFixed(0);
                        } else if (amount is double) {
                          displayAmount = amount.toStringAsFixed(2);
                        } else if (amount is String) {
                          displayAmount =
                              double.tryParse(amount)?.toStringAsFixed(2) ??
                              "0.00";
                        }
                      }

                      // -------------------------------
                      // PERFECT DATE FORMAT
                      // -------------------------------
                      String formattedStart = _formatDate(item['startDate']);
                      String formattedEnd = _formatDate(item['endDate']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Description: ${item['description'] ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              /// ⭐ Amount
                              Text("Amount: ₹$displayAmount"),

                              /// ⭐ Valid Date Range
                              Text("Valid: $formattedStart → $formattedEnd"),

                              /// ⭐ Status & IDs
                              Text("Payment Status: $paymentStatus"),
                              Text(
                                "Transaction ID: ${item['transactionId'] ?? ''}",
                              ),
                              Text("Order ID: ${item['orderId'] ?? ''}"),

                              /// ⭐ Show PAY NOW only if pending
                              if (paymentStatus == "PENDING")
                                ElevatedButton(
                                  onPressed: () {
                                    TopRestaurantPayment().payTopRestaurant(
                                      context,
                                      item,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF67B95F),
                                  ),
                                  child: const Text("Pay Now"),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          /// Bottom Button
          _bottomButton(
            text: "Request Top Restaurant",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestTopRestaurantPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// -----------------------------------------
  /// ⭐ Perfect Date Formatting Function
  /// -----------------------------------------
  String _formatDate(dynamic dateValue) {
    if (dateValue == null || dateValue.toString().isEmpty) return "-";

    try {
      DateTime date = DateTime.parse(dateValue.toString());
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year}  "
          "${date.hour % 12 == 0 ? 12 : date.hour % 12}:"
          "${date.minute.toString().padLeft(2, '0')} "
          "${date.hour >= 12 ? "PM" : "AM"}";
    } catch (e) {
      return dateValue.toString(); // fallback
    }
  }

  // --------------------------------------------------------------------
  // ✅ REUSABLE BUTTON
  // --------------------------------------------------------------------
  Widget _bottomButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF67B95F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}

// --------------------------------------------------------------------
// ✅ REQUEST COUPON PAGE (UPDATED)
// --------------------------------------------------------------------
class RequestCouponPage extends StatefulWidget {
  const RequestCouponPage({super.key});

  @override
  State<RequestCouponPage> createState() => _RequestCouponPageState();
}

class _RequestCouponPageState extends State<RequestCouponPage> {
  final TextEditingController couponController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController validDateController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController minimumOrderValueController =
      TextEditingController(text: "0");

  String discountType = "PERCENTAGE";
  String couponType = "FLAT";
  String? selectedFile;
  File? selectedImage;

  DateTime? parseDate(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      return DateFormat("yyyy-MM-dd").parse(text);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitPromotion() async {
    final startDate = parseDate(startDateController.text);
    final endDate = parseDate(validDateController.text);

    XFile? imageXFile;
    if (selectedImage != null) {
      imageXFile = XFile(selectedImage!.path);
    }

    final success = await food_authservice.createPromotion(
      couponCode: couponController.text,
      description: descriptionController.text,
      discount: double.tryParse(discountController.text) ?? 0,
      discountType: discountType,
      couponType: couponType,
      minimumOrderValue: double.tryParse(minimumOrderValueController.text) ?? 0,
      startDate: startDate,
      endDate: endDate,
      imageFile: imageXFile,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promotion created successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create promotion")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request a Coupon"),
        backgroundColor: const Color(0xFF67B95F),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Coupon Code *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: couponController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Coupon Code",
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Description *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Description",
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Discount Type *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: discountType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                  value: "PERCENTAGE",
                  child: Text("Percentage"),
                ),
                DropdownMenuItem(
                  value: "FIXED_AMOUNT",
                  child: Text("Fixed Amount"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  discountType = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            const Text(
              "Coupon Type *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: couponType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "FLAT", child: Text("Flat")),
                DropdownMenuItem(value: "UPTO", child: Text("Upto")),
              ],
              onChanged: (value) {
                setState(() {
                  couponType = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            const Text(
              "Discount*",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: discountType == "PERCENTAGE"
                    ? "Enter discount percentage"
                    : "Enter discount amount",
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Minimum Order Value",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: minimumOrderValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter minimum order value",
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Start Date *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: startDateController,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select Start Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    startDateController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            const Text(
              "Valid Date *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: validDateController,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select Valid Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    validDateController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            const Text(
              "Coupon Image",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 500,
              height: 100,
              child: ImageUploadWidget(
                onImageSelected: (File image) {
                  setState(() {
                    selectedImage = image;
                  });
                },
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _submitPromotion();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Coupon request submitted successfully!"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF67B95F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Submit Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestAdvertisementPage extends StatefulWidget {
  const RequestAdvertisementPage({super.key});

  @override
  State<RequestAdvertisementPage> createState() =>
      _RequestAdvertisementPageState();
}

class _RequestAdvertisementPageState extends State<RequestAdvertisementPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedType = "IMAGE";
  String selectedResolution = "HORIZONTAL"; // ✅ NEW

  File? selectedImage;
  File? selectedVideo;
  bool isLoading = false;

  /// Pick Image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        selectedImage = File(img.path);
        selectedType = "IMAGE";
        selectedVideo = null;
      });
    }
  }

  /// Pick Video
  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        selectedVideo = File(video.path);
        selectedType = "VIDEO";
        selectedImage = null;
      });
    }
  }

  /// Submit Advertisement
  Future<void> submitAdvertisement() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (selectedType == "IMAGE" && selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    if (selectedType == "VIDEO" && selectedVideo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a video")));
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt("vendorId");

      if (vendorId == null) {
        throw Exception("Vendor ID not found");
      }

      final adId = await AdvertisementService.postAdvertisement(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        startDate: startDateController.text.trim(),
        endDate: endDateController.text.trim(),
        amount: amount,
        type: selectedType,
        resolution: selectedResolution, // ✅ PASS HERE
        image: selectedImage,
        video: selectedVideo,
        vendorId: vendorId,
      );

      if (adId != null && adId > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Advertisement submitted successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Advertisement"),
        backgroundColor: const Color(0xFF67B95F),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField("Title *", controller: titleController),
                _buildTextField(
                  "Description *",
                  controller: descriptionController,
                  maxLines: 3,
                ),

                _buildMediaTypeSelection(),

                _buildResolutionSelection(), // ✅ NEW

                if (selectedType == "IMAGE") ...[
                  _buildUploadButton("Upload Image *", onTap: pickImage),
                  if (selectedImage != null)
                    _buildFileInfo("Image selected:", selectedImage!.path),
                ],

                if (selectedType == "VIDEO") ...[
                  _buildUploadButton("Upload Video *", onTap: pickVideo),
                  if (selectedVideo != null)
                    _buildFileInfo("Video selected:", selectedVideo!.path),
                ],

                _buildDateField("Start Date *", startDateController),
                _buildDateField("End Date *", endDateController),

                _buildTextField(
                  "Amount *",
                  controller: amountController,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResolutionSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resolution *",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text("Horizontal"),
                  value: "HORIZONTAL",
                  groupValue: selectedResolution,
                  onChanged: (value) =>
                      setState(() => selectedResolution = value!),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text("Vertical"),
                  value: "VERTICAL",
                  groupValue: selectedResolution,
                  onChanged: (value) =>
                      setState(() => selectedResolution = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixText: keyboardType == TextInputType.number ? "₹ " : null,
        ),
      ),
    );
  }

  Widget _buildMediaTypeSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Media Type *",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text("Image"),
                  value: "IMAGE",
                  groupValue: selectedType,
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text("Video"),
                  value: "VIDEO",
                  groupValue: selectedType,
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text =
                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          }
        },
      ),
    );
  }

  Widget _buildUploadButton(String text, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(onPressed: onTap, child: Text(text)),
    );
  }

  Widget _buildFileInfo(String label, String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label ${path.split('/').last}",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : submitAdvertisement,
        child: const Text("Submit Request"),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    amountController.dispose();
    super.dispose();
  }
}

// --------------------------------------------------------------------
// ✅ REQUEST TOP RESTAURANT PAGE
// --------------------------------------------------------------------
class RequestTopRestaurantPage extends StatefulWidget {
  const RequestTopRestaurantPage({super.key});

  @override
  State<RequestTopRestaurantPage> createState() =>
      _RequestTopRestaurantPageState();
}

class _RequestTopRestaurantPageState extends State<RequestTopRestaurantPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  void submitTopRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 0;

    final description = descriptionController.text.trim();
    final amountText = amountController.text.trim();

    if (description.isEmpty ||
        amountText.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    TopRestaurant newTop = TopRestaurant(
      description: description,
      amount: amount,
      startDate: startDate!,
      endDate: endDate!,
      vendorId: vendorId,
    );

    final success = await TopRatedService.addTopRestaurant(newTop);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Top restaurant added!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add top restaurant")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Top Restaurant"),
        backgroundColor: const Color(0xFF67B95F),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Description *", controller: descriptionController),
            _input("Amount *", controller: amountController, isNumber: true),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => startDate = picked);
                  },
                  child: Text(
                    startDate == null
                        ? "Pick Start Date"
                        : startDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => endDate = picked);
                  },
                  child: Text(
                    endDate == null
                        ? "Pick End Date"
                        : endDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitTopRestaurant,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF67B95F),
              ),
              child: const Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label, {
    TextEditingController? controller,
    bool isNumber = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Widget _uploadBtn(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ElevatedButton(onPressed: () {}, child: Text(text)),
  );
}

class CouponPayment {
  final Razorpay _razorpay = Razorpay();

  void payCoupon(BuildContext context, Coupon promo) async {
    try {
      final amount = (promo.amount).toDouble();

      // 1️⃣ Create order on backend
      final orderId = await food_authservice.createOrder(amount);

      if (orderId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to create order")));
        return;
      }

      // 2️⃣ Prepare Razorpay checkout options
      var options = {
        'key': 'rzp_live_TJDvykibQEsCuN', // 🔹 use live key in production
        'order_id': orderId,
        'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
        'name': 'Order Payment',
        'description': promo.couponCode,
        'theme': {'color': '#3399cc'},
        // Optional prefill
        // 'prefill': {'contact': '9999999999', 'email': 'user@email.com'},
      };

      // 3️⃣ Razorpay callbacks
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
        PaymentSuccessResponse response,
      ) async {
        debugPrint("✅ Payment Success: ${response.paymentId}");

        // Capture payment
        bool captured = await food_authservice.capturePayment(
          paymentId: response.paymentId!,
          amount: promo.amount,
        );

        if (captured) {
          await food_authservice.updateCouponPayment(
            promo.vendorRequirementCouponId,
            response.paymentId!,
            orderId,
          );

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Payment successful!")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment capture failed")),
          );
        }

        _razorpay.clear();
      });

      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
        PaymentFailureResponse response,
      ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: ${response.message}")),
        );
        _razorpay.clear();
      });

      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
        ExternalWalletResponse response,
      ) {
        debugPrint("External Wallet: ${response.walletName}");
      });

      // 4️⃣ Open Razorpay checkout
      _razorpay.open(options);
    } catch (e) {
      debugPrint("❌ Payment error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment error: $e")));
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}

class TopRestaurantPayment {
  final Razorpay _razorpay = Razorpay();
  final PaymentService paymentService = PaymentService();

  void payTopRestaurant(BuildContext context, Map<String, dynamic> item) async {
    try {
      final amount = (item['amount'] ?? 0).toDouble();
      final id = item['topratedId'] ?? 0;

      if (id == 0) {
        showError(context, "Invalid Top Restaurant ID");
        return;
      }
      if (amount <= 0) {
        showError(context, "Invalid amount");
        return;
      }

      final orderId = await food_authservice.createOrder(amount);
      if (orderId == null) {
        showError(context, "Failed to create Razorpay order");
        return;
      }

      var options = {
        'key': 'rzp_live_TJDvykibQEsCuN',
        'order_id': orderId,
        'amount': (amount * 100).toInt(),
        'name': 'Top Restaurant Payment',
        'description': item['description'] ?? '',
      };

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
        PaymentSuccessResponse response,
      ) async {
        print("✅ Payment Success: ${response.paymentId}");

        bool captured = await food_authservice.capturePayment(
          paymentId: response.paymentId!,
          amount: amount,
        );

        if (!captured) {
          showError(context, "Capture failed");
          return;
        }

        bool updated = await paymentService.updateTopRestaurantPayment(
          id: id,
          transactionId: response.paymentId!,
          orderId: orderId,
        );

        if (updated) {
          showSuccess(context, "Payment completed!");
        } else {
          showError(context, "Payment captured but update failed");
        }

        _razorpay.clear();
      });

      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
        PaymentFailureResponse response,
      ) {
        showError(context, "Payment failed: ${response.message}");
        _razorpay.clear();
      });

      _razorpay.open(options);
    } catch (e) {
      showError(context, "Payment error: $e");
    }
  }

  void dispose() {
    _razorpay.clear();
  }

  void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class ImageUploadWidget extends StatefulWidget {
  final Function(File) onImageSelected;

  const ImageUploadWidget({super.key, required this.onImageSelected});

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.onImageSelected(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.upload, size: 40, color: Colors.grey),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            selectedImage != null ? "Image Selected" : "No file chosen",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class VideoUploadWidget extends StatefulWidget {
  final Function(File) onVideoSelected;

  const VideoUploadWidget({super.key, required this.onVideoSelected});

  @override
  State<VideoUploadWidget> createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget> {
  File? _video;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
      widget.onVideoSelected(_video!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: pickVideo,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: _video != null
                ? const Icon(Icons.videocam, size: 40, color: Colors.black)
                : const Center(
                    child: Icon(
                      Icons.upload_file,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _video != null ? "Video Selected" : "No video chosen",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
