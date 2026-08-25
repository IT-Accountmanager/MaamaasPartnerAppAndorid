import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../API/food_authservice.dart';
import '../../Models/advertisement_model.dart';
import '../enquiryscreen.dart';
import '../eventsPage.dart';

class ReelsScreennew extends StatefulWidget {
  const ReelsScreennew({Key? key}) : super(key: key);

  @override
  State<ReelsScreennew> createState() => _ReelsScreennewState();
}

class _ReelsScreennewState extends State<ReelsScreennew> {
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, int> _imageDisplayTime = {};

  Timer? _autoScrollTimer;

  List<Advertisement> ads = [];
  bool isLoading = true;
  int _currentPage = 0;
  int _selectedCategory = 1;

  final Set<int> _likedVideos = {};

  final Map<int, String> _categoryEnumMap = {
    1: "ALL",
    2: "FOOD",
    3: "EDUCATION",
    4: "JOBS",
    5: "REAL_ESTATE",
    6: "OFFERS",
    7: "ONLINE_COURSES",
    8: "BAKERY",
  };

  final List<Map<String, dynamic>> _categories = [
    {"id": 0, "name": "Add", "icon": Icons.add},
    {"id": 1, "name": "All", "icon": Icons.apps},
    {"id": 2, "name": "Food", "icon": Icons.fastfood},
    {"id": 3, "name": "Education", "icon": Icons.cast_for_education},
    {"id": 4, "name": "Jobs", "icon": Icons.work},
    {"id": 5, "name": "Real Estate", "icon": Icons.real_estate_agent},
    {"id": 6, "name": "Offers", "icon": Icons.local_offer},
    {"id": 7, "name": "Courses", "icon": Icons.read_more},
    {"id": 8, "name": "Bakery", "icon": Icons.cake},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();
  }

  Future<void> _fetchAdvertisements() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    // cleanup old state
    _autoScrollTimer?.cancel();
    _imageDisplayTime.clear();
    _videoControllers.forEach((_, c) => c.dispose());
    _videoControllers.clear();
    _currentPage = 0;

    try {
      // ✅ CORRECT: instantiate service
      final service = food_Authservice();
      final List<Advertisement> result = await food_Authservice
          .fetchAdvertisements();

      final String selectedType = _categoryEnumMap[_selectedCategory] ?? "ALL";

      ads = result.where((ad) {
        final resolution = ad.resolution.toLowerCase();
        final adType = ad.advertisementType.toUpperCase();

        return resolution == 'vertical' &&
            (selectedType == "ALL" || adType == selectedType);
      }).toList();

      // init first video
      if (ads.isNotEmpty && ads.first.type == 'video') {
        await _initializeVideo(0);
      }

      _startAutoScrollTimer();
    } catch (e, s) {
      debugPrint("❌ API Error: $e");
      debugPrintStack(stackTrace: s);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || ads.isEmpty) return;

      final ad = ads[_currentPage];
      final elapsed = _getPlaybackTime();

      if (elapsed >= ad.duration) {
        _nextPage();
      }
    });
  }

  num _getPlaybackTime() {
    final ad = ads[_currentPage];
    if (ad.type == 'video') {
      final controller = _videoControllers[_currentPage];
      return controller?.value.position.inSeconds ?? 0;
    }
    return _imageDisplayTime[_currentPage] =
        (_imageDisplayTime[_currentPage] ?? 0) + 1;
  }

  void _nextPage() {
    if (_currentPage < ads.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (_videoControllers.containsKey(index)) return;
    if (ads[index].type != 'video') return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(ads[index].mediaUrl),
    );

    await controller.initialize();
    controller
      ..setLooping(false)
      ..play();

    _videoControllers[index] = controller;
    setState(() {});
  }

  void _pauseVideo(int index) {
    final controller = _videoControllers[index];
    if (controller != null) {
      controller.pause();
      controller.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    _videoControllers.clear();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildCategoryBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: ads.length,
              onPageChanged: (index) {
                _pauseVideo(_currentPage);
                _currentPage = index;
                _initializeVideo(index);
              },
              itemBuilder: (_, index) => _buildMediaItem(ads[index], index),
            ),
    );
  }

  PreferredSizeWidget _buildCategoryBar() {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 90,
      title: SizedBox(
        height: 80, // ✅ REQUIRED
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final c = _categories[index];
            final selected = c["id"] == _selectedCategory;

            return GestureDetector(
              onTap: () {
                if (c["id"] == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateEventPage()),
                  );
                } else {
                  setState(() => _selectedCategory = c["id"]);
                  _fetchAdvertisements();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: selected
                          ? Colors.red
                          : Colors.grey.shade300,
                      child: Icon(c["icon"], color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c["name"],
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaItem(Advertisement ad, int index) {
    return Stack(
      fit: StackFit.expand, // ✅ take full screen
      children: [
        // 🔹 MEDIA (CENTERED)
        Center(
          child: ad.type == 'video'
              ? _buildVideo(ad, index)
              : Image.network(
            ad.mediaUrl,
            fit: BoxFit.cover, // full screen like reels
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // 🔹 RIGHT ACTION BUTTONS
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  _likedVideos.contains(index)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _likedVideos.contains(index)
                        ? _likedVideos.remove(index)
                        : _likedVideos.add(index);
                  });
                },
              ),
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 30),
                onPressed: () => Share.share(ad.mediaUrl),
              ),
            ],
          ),
        ),

        // 🔹 ENQUIRY BUTTON
        Positioned(
          left: 16,
          right: 16,
          bottom: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EnquiryFormScreen()),
            ),
            child: const Text(
              "Get Enquiry",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideo(Advertisement ad, int index) {
    final controller = _videoControllers[index];

    if (controller == null || !controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }


}
