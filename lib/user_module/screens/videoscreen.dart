import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maamaaspartner/user_module/API/food_authservice.dart';
import 'package:maamaaspartner/user_module/screens/Food&beverages/menu_screen.dart';
import 'package:maamaaspartner/user_module/screens/professional_user/Main_screen.dart' show MainScreen;
import 'package:video_player/video_player.dart';
import '../Models/advertisement_model.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  List<Advertisement> ads = [];

  final Map<int, VideoPlayerController> _videoControllers = {};
  int _currentPage = 0;
  final Set<int> _likedVideos = {};
  bool isLoading = true;
  final Map<int, int> _imageDisplayTime = {};

  @override
  void initState() {
    super.initState();
    // _initializeVideo(_currentPage);
    // _startAutoScrollTimer();
    _fetchAdvertisements();
  }

  Future<void> _fetchAdvertisements() async {
    setState(() => isLoading = true);

    try {
      final fetchedAds = await food_Authservice.fetchAdvertisements();

      // ✅ Filter ONLY vertical ads
      ads = fetchedAds
          .where(
            (ad) =>
                ad.resolution!.toLowerCase() == "vertical",
          )
          .toList();

      if (!mounted || ads.isEmpty) return;

      // ✅ Initialize first item ONLY if it's a video
      if (ads[0].type.toLowerCase() == 'video') {
        await _initializeVideo(0);
      }

      _startAutoScrollTimer(); // ✅ SAFE
    } catch (e) {
      debugPrint("❌ Error loading advertisements: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel(); // ✅ IMPORTANT

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || ads.isEmpty) return;

      final currentItem = ads[_currentPage];

      if (currentItem.type == 'image') {
        _imageDisplayTime[_currentPage] =
            (_imageDisplayTime[_currentPage] ?? 0) + 1;
      }

      if (_getCurrentPlaybackTime() >= currentItem.duration) {
        _autoScrollToNext();
      }
    });
  }

  num _getCurrentPlaybackTime() {
    final currentItem = ads[_currentPage];

    if (currentItem.type == 'video') {
      final controller = _videoControllers[_currentPage];
      if (controller != null && controller.value.isInitialized) {
        return controller.value.position.inSeconds.toDouble();
      }
    }

    // For images, we need to track time manually
    return _imageDisplayTime[_currentPage] ?? 0;
  }

  void _autoScrollToNext() {
    if (_currentPage < ads.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(0); // Loop back to start
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (ads.isEmpty) return;
    if (index < 0 || index >= ads.length) return;
    if (_videoControllers.containsKey(index)) return;

    if (ads[index].type != 'video') return; // ✅ VERY IMPORTANT

    final url = ads[index].mediaUrl;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await controller.initialize();
      controller
        ..setLooping(false)
        ..setVolume(1.0)
        ..play();

      if (mounted) {
        setState(() {
          _videoControllers[index] = controller;
        });
      }
    } catch (e) {
      debugPrint("❌ Video init failed: $url\n$e");
    }
  }

  void _pauseVideo(int index) {
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]!.pause();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _videoControllers.forEach((key, controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  void _cleanupControllers(int currentIndex) {
    _videoControllers.keys
        .where((i) => (i - currentIndex).abs() > 1)
        .toList()
        .forEach((i) {
          _videoControllers[i]?.dispose();
          _videoControllers.remove(i);
        });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MainScreen()),
            ),
          ),
          title: const Text(""),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ads.isEmpty
            ? Center(
                child: Text(
                  "No Ads available",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                itemCount: ads.length,
                onPageChanged: (index) {
                  _pauseVideo(_currentPage);
                  _currentPage = index;
                  _cleanupControllers(index);
                  _initializeVideo(index);

                  if (index + 1 < ads.length) {
                    _initializeVideo(index + 1);
                  }
                  if (index - 1 >= 0) {
                    _initializeVideo(index - 1);
                  }
                },
                itemBuilder: (context, index) {
                  return _buildMediaItem(
                    ads[index],
                    index,
                    _likedVideos.contains(index),
                  );
                },
              ),
        // bottomNavigationBar: food_foooter(),
      ),
    );
  }

  Widget _buildMediaItem(Advertisement mediaItem, int index, bool isLiked) {
    return GestureDetector(
      onTap: () {
        if (mediaItem.type == 'video') {
          final controller = _videoControllers[index];
          if (controller != null) {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
            setState(() {});
          }
        }
      },
      child: Stack(
        children: [
          _buildMediaContent(mediaItem, index),
          // Positioned(
          //   left: 16,
          //   top: 10,
          //   child: Row(
          //     children: [
          //       const CircleAvatar(
          //         radius: 18,
          //         backgroundImage: AssetImage("assets/MAAMAAS.jpeg"),
          //       ),
          //       const SizedBox(width: 8),
          //       TextButton(
          //         onPressed: () {
          //           // debugPrint("Maamaas House clicked");
          //         },
          //         child: Text(
          //           mediaItem.title,
          //           style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //       // const SizedBox(width: 70),
                // OutlinedButton(
                //   style: OutlinedButton.styleFrom(
                //     side: const BorderSide(color: Colors.white),
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 4,
                //     ),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //   ),
                //   onPressed: () {
                //     debugPrint("Follow clicked");
                //   },
                //   child: const Text(
                //     "Follow",
                //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                //   ),
                // ),
          //     ],
          //   ),
          // ),
          // Positioned(
          //   left: 16,
          //   right: 16,
          //   top: 40,
          //   child: GestureDetector(
          //     onTap: () async {
          //
          //
          //       await Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (_) => MainScreen(),
          //         ),
          //       );
          //     },
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 12,
          //       ),
          //       decoration: BoxDecoration(
          //         // ignore: deprecated_member_use
          //         color: Colors.white.withOpacity(0.95),
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: const [
          //           // Text(
          //           //   "Get Dishes",
          //           //   style: TextStyle(
          //           //     fontSize: 16,
          //           //     fontWeight: FontWeight.bold,
          //           //     color: Colors.black,
          //           //   ),
          //           // ),
          //           Icon(
          //             Icons.arrow_back_ios,
          //             size: 18,
          //             color: Colors.black,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // 📩 Enquiry button
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: GestureDetector(
              onTap: () async {
                if (mediaItem.vendorId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vendor not available")),
                  );
                  return;
                }

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuScreen(vendorId: mediaItem.vendorId),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Get Dishes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ▶️ Play icon overlay (only for videos when paused)
          if (mediaItem.type == 'video' &&
              _videoControllers[index] != null &&
              !_videoControllers[index]!.value.isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, size: 64, color: Colors.white70),
            ),

          // 📊 Progress bar (only for videos)
          if (mediaItem.type == 'video' && _videoControllers[index] != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 10,
              child: VideoProgressIndicator(
                _videoControllers[index]!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  backgroundColor: Colors.white54,
                  bufferedColor: Colors.grey,
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),

          // Image duration indicator
          if (mediaItem.type == 'image')
            Positioned(
              left: 16,
              right: 16,
              bottom: 10,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final progress =
                        (_imageDisplayTime[index] ?? 0) / (mediaItem.duration);
                    return Stack(
                      children: [
                        // Background
                        Container(
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Progress
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

          // ❤️💬↗️ Like, Comment, Share
          // Positioned(
          //   right: 16,
          //   bottom: 120,
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       // ❤️ Like
          //       IconButton(
          //         icon: Icon(
          //           isLiked ? Icons.favorite : Icons.favorite_border,
          //           color: isLiked ? Colors.red : Colors.white,
          //           size: 32,
          //         ),
          //         onPressed: () {
          //           setState(() {
          //             if (isLiked) {
          //               _likedVideos.remove(index);
          //             } else {
          //               _likedVideos.add(index);
          //             }
          //           });
          //           ScaffoldMessenger.of(
          //             context,
          //           ).showSnackBar(const SnackBar(content: Text('Liked ❤️')));
          //         },
          //       ),
          //       const SizedBox(height: 16),
          //
          //       // 💬 Comment
          //       IconButton(
          //         icon: const Icon(
          //           Icons.chat_bubble_outline,
          //           color: Colors.white,
          //           size: 30,
          //         ),
          //         onPressed: () => _openComments(context),
          //       ),
          //       const SizedBox(height: 16),
          //
          //       // ↗️ Share
          //       IconButton(
          //         icon: const Icon(Icons.share, color: Colors.white, size: 30),
          //         onPressed: () {
          //           // ignore: deprecated_member_use
          //           Share.share(
          //             "Check out this reel! 🎥\nhttps://yourserver.com/media/$index",
          //             subject: "Cool Reel from Maamaas House",
          //           );
          //         },
          //       ),
          //     ],
          //   ),
          // ),

          // Media type indicator
          // Positioned(
          //   left: 16,
          //   top: 60,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //     decoration: BoxDecoration(
          //       color: Colors.black54,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Row(
          //       children: [
          //         Icon(
          //           mediaItem.type == 'video' ? Icons.videocam : Icons.image,
          //           color: Colors.white,
          //           size: 14,
          //         ),
          //         const SizedBox(width: 4),
          //         Text(
          //           mediaItem.type == 'video' ? 'Video' : 'Image',
          //           style: const TextStyle(color: Colors.white, fontSize: 12),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(Advertisement mediaItem, int index) {
    if (mediaItem.type == 'video') {
      final controller = _videoControllers[index];

      if (controller != null && controller.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        );
      }

      return const Center(child: CircularProgressIndicator());
    }

    // IMAGE
    return SizedBox.expand(
      child: Image.network(
        mediaItem.mediaUrl,
        fit: BoxFit.cover, // 👈 use cover for reels
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) {
          return const Center(child: Icon(Icons.broken_image, size: 50));
        },
      ),
    );
  }

  void _openComments(BuildContext context) {
    final TextEditingController _commentController = TextEditingController();
    final List<String> _comments = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: 400,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "Comments",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              _comments[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.white24)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Add a comment...",
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              if (_commentController.text.trim().isNotEmpty) {
                                setModalState(() {
                                  _comments.add(_commentController.text.trim());
                                  _commentController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
