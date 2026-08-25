import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maamaaspartner/user_module/API/grocery_authservice.dart';
import 'package:maamaaspartner/user_module/screens/Fresh&Groceries/grocerystore_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/grocery/grocery_banner_model.dart';
import '../Advideo.dart';

class stores extends StatefulWidget {
  @override
  _storesState createState() => _storesState();
}

class _storesState extends State<stores> {
  bool isDrawerOpen = false;
  String selectedMainFilter = 'None';
  String? selectedSubFilter;
  String? selectedCity;
  String? selectedService;
  String? currentLocation;
  String? currentAddress = "Fetching...";

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> filterOptionsMap = {
    'Select Vertical': [
      'Food&Beverages ',
      'catering&TableServices',
      'Logistics&supply',
      'Fresh&Groceries',
    ],
    'Select City': {
      'Hyderabad': ['Madhapur', 'Gachibowli', 'Kukatpally'],
      'Bengaluru': ['Koramangala', 'Whitefield', 'Indiranagar'],
      'Chennai': ['T Nagar', 'Velachery', 'Anna Nagar'],
      'Mumbai': ['Andheri', 'Bandra', 'Juhu'],
    },
    'Select location': ['Current Location', 'Add location', 'Home', 'Office'],
    'Select Outlet Type': [
      'Hotel',
      'Restaurant',
      'Cafe',
      'Bar / Pub / Lounge',
      'Bakery / Dessert Shop',
      'Cloud Kitchen / Virtual Kitchen',
      'Food&beverages Court',
      'Street Food/ Quick Bite',
    ],
    'Service Type': ['DINE_IN', 'TABLE_DINE_IN', 'TAKEAWAY' /*'DELIVERY'*/],
  };

  final Map<String, String> serviceToApiMap = {
    'Dine-In': 'DINE_IN',
    'Takeaway': 'TAKEAWAY',
    'Delivery': 'DELIVERY',
    'TABLE DINE-IN': 'TABLE_DINE_IN',
  };


  // 🔹 Microphone / Audio

  void _openFilterBottomSheet() {
    Map<String, Set<String>> selectedFilters = {};

    String selectedCategory = selectedMainFilter != 'None'
        ? selectedMainFilter
        : filterOptionsMap.keys.first;

    if (selectedSubFilter != null && selectedSubFilter!.isNotEmpty) {
      selectedFilters[selectedCategory] = selectedSubFilter!
          .split(', ')
          .toSet();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Row(
                children: [
                  // Left panel: categories
                  Container(
                    width: 130,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: ListView(
                      children: filterOptionsMap.keys.map((category) {
                        bool isSelected = category == selectedCategory;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            color: isSelected ? Colors.purple.shade100 : null,
                            child: Text(
                              category,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.purple
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Right panel
                  Expanded(
                    child: Column(
                      children: [
                        // Filter options list
                        Expanded(
                          child: () {
                            final categoryData =
                            filterOptionsMap[selectedCategory];

                            // 🏙️ Special handling for 'City' type
                            if (selectedCategory == 'City' &&
                                categoryData is Map<String, List<String>>) {
                              return Column(
                                children: [
                                  // City list
                                  Expanded(
                                    child: ListView(
                                      children: categoryData.keys.map((city) {
                                        final isSelectedCity =
                                            city == selectedCity;
                                        return ListTile(
                                          title: Text(city),
                                          tileColor: isSelectedCity
                                              ? Colors.purple.shade50
                                              : null,
                                          onTap: () {
                                            setModalState(() {
                                              selectedCity = city;
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // Areas of selected city
                                  if (selectedCity != null)
                                    Expanded(
                                      child: ListView(
                                        children: categoryData[selectedCity]!.map((
                                            place,
                                            ) {
                                          final isChecked =
                                              selectedFilters[selectedCity!]
                                                  ?.contains(place) ??
                                                  false;
                                          return CheckboxListTile(
                                            title: Text(place),
                                            value: isChecked,
                                            onChanged: (checked) {
                                              setModalState(() {
                                                selectedFilters.putIfAbsent(
                                                  selectedCity!,
                                                      () => <String>{},
                                                );
                                                if (checked == true) {
                                                  selectedFilters[selectedCity!]!
                                                      .add(place);
                                                } else {
                                                  selectedFilters[selectedCity!]!
                                                      .remove(place);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              );
                            }
                            // 🌐 Nested categories (like Cuisine, Discounts)
                            else if (categoryData
                            is Map<String, List<String>>) {
                              return ListView(
                                children: categoryData.entries.map((entry) {
                                  final section = entry.key;
                                  final subOptions = entry.value;

                                  return ExpansionTile(
                                    title: Text(section),
                                    children: subOptions.map((subOption) {
                                      final isChecked =
                                          selectedFilters[section]?.contains(
                                            subOption,
                                          ) ??
                                              false;
                                      return CheckboxListTile(
                                        title: Text(subOption),
                                        value: isChecked,
                                        onChanged: (checked) {
                                          setModalState(() {
                                            selectedFilters.putIfAbsent(
                                              section,
                                                  () => <String>{},
                                            );
                                            if (checked == true) {
                                              selectedFilters[section]!.add(
                                                subOption,
                                              );
                                            } else {
                                              selectedFilters[section]!.remove(
                                                subOption,
                                              );
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  );
                                }).toList(),
                              );
                            }
                            // ✅ Standard list of options
                            else if (categoryData is List<String>) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: categoryData.length,
                                itemBuilder: (context, index) {
                                  final subOption = categoryData[index];
                                  final isChecked =
                                      selectedFilters[selectedCategory]
                                          ?.contains(subOption) ??
                                          false;

                                  return CheckboxListTile(
                                    title: Text(subOption),
                                    value: isChecked,
                                    onChanged: (checked) {
                                      setModalState(() {
                                        selectedFilters.putIfAbsent(
                                          selectedCategory,
                                              () => <String>{},
                                        );
                                        if (checked == true) {
                                          selectedFilters[selectedCategory]!
                                              .add(subOption);
                                        } else {
                                          selectedFilters[selectedCategory]!
                                              .remove(subOption);
                                        }
                                      });
                                    },
                                  );
                                },
                              );
                            }

                            // ❌ Unknown data type
                            return const Center(
                              child: Text('Invalid filter type.'),
                            );
                          }(),
                        ),

                        // Bottom Buttons
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    selectedFilters.clear();
                                  });
                                },
                                child: const Text(
                                  "Reset",
                                  style: TextStyle(color: Colors.purple),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    selectedMainFilter = selectedCategory;
                                    selectedSubFilter =
                                        selectedFilters[selectedCategory]?.join(
                                          ', ',
                                        ) ??
                                            '';

                                    if (selectedCategory == 'Service Type' &&
                                        selectedFilters['Service Type'] !=
                                            null &&
                                        selectedFilters['Service Type']!
                                            .isNotEmpty) {
                                      selectedService =
                                          selectedFilters['Service Type']!
                                              .first;
                                    }
                                  });

                                  if (selectedService != null &&
                                      selectedService!.isNotEmpty) {
                                    final prefs =
                                    await SharedPreferences.getInstance();
                                    await prefs.setString(
                                      'orderType',
                                      selectedService!,
                                    );
                                    debugPrint(
                                      'Saved orderType to prefs: $selectedService',
                                    );

                                    // await food_Authservice.createCart(
                                    //   selectedService!,
                                    // );
                                  } else {
                                    debugPrint(
                                      'selectedService is null or empty, not saving to prefs',
                                    );
                                  }

                                  Navigator.pop(context);
                                },
                                child: const Text("Apply"),
                              ),
                            ],
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
    );
  }

  String? mapToOrderType(String? service) {
    if (service == null) return null;
    final normalized = service.toLowerCase().replaceAll('-', '_');
    switch (normalized) {
      case "dine_in":
        return "DINE_IN";
      case "pickup":
      case "takeaway":
        return "TAKEAWAY";
      case "delivery":
        return "DELIVERY";
      case "table_dine_in":
        return "TABLE_DINE_IN"; // add this case explicitly
      default:
        return null;
    }
  }

  void onServiceSelected(String service) {
    setState(() {
      selectedService = service;
      debugPrint("Selected Service: $selectedService");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: customappBar(
        //   searchController: _searchController,
        //   onCameraTap: _openCamera,
        //   onMicTap: _startRecording,
        //   // onProfileTap: () => ProfileDrawer.open(context), // ✅ reusable
        // ),

        body: SafeArea(
          child: ListView(
            children: [
              VideoPreviewContainer(),

              SizedBox(
                height: 50, // Adjust height as needed
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Top Brands for you",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              FutureBuilder<List<grocery_Banner>>(
                future: grocery_authservice().fetchBanners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No banners found'));
                  }

                  final banners = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        // Show up to 4 banners directly
                        ...List.generate(
                          banners.length > 4 ? 4 : banners.length,
                              (index) => SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: _imageContainer(
                              context,
                              banners[index],
                              serviceSelected: false,
                              onServiceRequired: () {},
                            ),
                          ),
                        ),

                        // Optional "View All" card if more than 4 banners exist
                        if (banners.length > 4)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: _viewAllCard(context, banners),
                          ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  "Near By Restaurents 5KM",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<List<grocery_Banner>>(
                future: grocery_authservice().fetchBanners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No banners found');
                  }
                  final banners = snapshot.data!;
                  final mappedOrderType = mapToOrderType(selectedService);
                  debugPrint("Selected Service: $selectedService");
                  debugPrint("Mapped OrderType: $mappedOrderType");

                  final filteredBanners =
                  (mappedOrderType != null && mappedOrderType.isNotEmpty)
                      ? banners.where((banner) {
                    final orderTypes = List<String>.from(
                      banner.orderTypes,
                    );
                    debugPrint(
                      "Banner: ${banner.companyName}, orderTypes: $orderTypes",
                    );
                    return orderTypes.any(
                          (type) =>
                      type.toLowerCase() ==
                          mappedOrderType.toLowerCase(),
                    );
                  }).toList()
                      : banners;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        ...List.generate(
                          filteredBanners.length > 4
                              ? 4
                              : filteredBanners.length,
                              (index) => SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: _imageContainer(
                              context,
                              filteredBanners[index],
                              serviceSelected:
                              selectedService?.isNotEmpty ?? false,
                              onServiceRequired: () {
                                _openFilterBottomSheet();
                              },
                            ),
                          ),
                        ),
                        if (filteredBanners.length > 4)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: _viewAllCard(context, filteredBanners),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // bottomNavigationBar: food_foooter(
        //   onFilterTap: () => _openFilterBottomSheet(),
        // ),
      ),
    );
  }
}

Widget _imageContainer(
    BuildContext context,
    grocery_Banner banner, {
      required bool serviceSelected,
      required VoidCallback onServiceRequired,
    }) {
  return GestureDetector(
    onTap: () async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              store_Screen(vendorId: banner.vendorId),
        ),
      );
    },
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImage(banner.companyLogo),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              banner.companyName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 14),
                Expanded(
                  child: Text(
                    "${banner.addressLine}, ${banner.city}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _viewAllCard(BuildContext context, List<grocery_Banner> banners) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewAllScreen(banners: banners),
        ),
      );
    },
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        child: const Text(
          "View All",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    ),
  );
}

class ViewAllScreen extends StatelessWidget {
  final List<grocery_Banner> banners;

  const ViewAllScreen({Key? key, required this.banners}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String selectedService = '';
    final Map<String, String> serviceToApiMap = {
      'Dine In': 'DINE_IN',
      'Take Away': 'TAKEAWAY',
      'Delivery': 'DELIVERY',
    };
    final filteredBanners = selectedService.isNotEmpty
        ? banners.where((banner) {
      final selectedOrderType = serviceToApiMap[selectedService] ?? '';
      return banner.orderTypes.contains(selectedOrderType);
    }).toList()
        : banners;
    return Scaffold(
      appBar: AppBar(title: const Text("All Vendors")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Show 2 cards per row
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return _imageContainer(
            context,
            filteredBanners[index],
            serviceSelected: selectedService.isNotEmpty,
            onServiceRequired: () {}, // empty callback
          );
        },
      ),
    );
  }
}

class AutoScrollCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final bool useAssetImages;

  const AutoScrollCarousel({
    super.key,
    required this.imagePaths,
    this.useAssetImages = true, // Set to false to use NetworkImage
  });

  @override
  State<AutoScrollCarousel> createState() => _AutoScrollCarouselState();
}

class _AutoScrollCarouselState extends State<AutoScrollCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<grocery_Banner> _banners = [];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadBanners();
  }

  void _startAutoScroll() {
    if (widget.imagePaths.isEmpty) return; // ✅ nothing to scroll

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients && widget.imagePaths.isNotEmpty) {
        int nextPage = (_currentPage + 1) % widget.imagePaths.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await grocery_authservice.fetchBanner();
      if (!mounted) return;
      setState(() {
        _banners = banners;
      });
    } catch (e) {
      debugPrint("Failed to load banners: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (index) => setState(() {
                _currentPage = index;
              }),
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return GestureDetector(
                  onTap: () {
                    debugPrint("Tapped on banner $index");
                  },

                  child: Stack(
                    children: [
                      // Banner image (Base64 decode)
                      Image.memory(
                        base64Decode(banner.companyBanner),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),

                      // Gradient overlay
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              // ignore: deprecated_member_use
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),

                      Center(
                        child: SizedBox(
                          width:
                          MediaQuery.of(context).size.width *
                              0.8, // optional: control width
                          child: Text(
                            "${banner.companyName} • Est. ${banner.establishedYear}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 10,
                        left: 12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: MemoryImage(
                                base64Decode(banner.companyLogo),
                              ), // Base64 logo
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            bool isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFFB15DC6) : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }
}

Widget _buildImage(String imageData, {double height = 120}) {
  ImageProvider imageProvider;
  if (imageData.startsWith('http')) {
    imageProvider = NetworkImage(imageData);
  } else {
    imageProvider = MemoryImage(base64Decode(imageData));
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(8), // optional rounded corners
    child: Image(
      image: imageProvider,
      height: height,
      width: double.infinity, // take full width of parent
      fit: BoxFit.cover, // fill and crop nicely
    ),
  );
}

bool isBase64(String str) {
  return str.length > 100 && !str.startsWith('http') && !str.contains('://');
}

class ImageBanner extends StatefulWidget {
  const ImageBanner({super.key});

  @override
  State<ImageBanner> createState() => _ImageBannerState();
}

class _ImageBannerState extends State<ImageBanner> {
  final List<String> bannerImages = [
    "assets/gallery-img-3.jpg",
    "assets/gallery-img-5.jpg",
    "assets/gallery-img-6.jpg",
  ];

  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                bannerImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.blue
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
