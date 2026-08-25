import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../Api/promotion_Authservice.dart';
import '../CampaignScreens/create_promotion_screen.dart'
    show CampaignDetailScreen, CreatePromotionScreen;
import '../Models/food&beverages/promotions_model.dart';
import '../Promotion&Marketing/CreateCampaignScreen.dart';
import '../Report&Analysis/widgets/theme.dart';
import '../user_module/screens/enquiryscreen.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _R {
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0x33B15DC6);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const red = Color(0xFFEF4444);
  static const amber = Color(0xFFF59E0B);
  static const green = Color(0xFF10B981);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFFB0B3C1);

  static LinearGradient get gradient => const LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── ReelsScreen ─────────────────────────────────────────────────────────────
class ReelsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed; // Add callback parameter
  const ReelsScreen({super.key, this.onBackPressed});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, int> _imageDisplayTime = {};
  final Map<int, Size> _imageSizes = {};

  Timer? _autoScrollTimer;

  List<Campaign> campaigns = [];
  bool isLoading = true;
  int _currentPage = 0;

  Interest? _selectedInterest;
  final List<Interest> _allInterests = Interest.values;

  final Map<int, int> _watchDuration = {};
  DateTime? _videoStartTime;
  final Set<int> _likedVideos = {};
  final Set<int> _sentCampaignAnalytics = {};
  final Set<int> _savedVideos = {};

  final ScrollController _catScrollController = ScrollController();

  // ── Category bar height constant ──────────────────────────────────────────────
  static const double _catBarHeight = 70.0;

  final Map<Interest, IconData> _interestIcons = {
    Interest.JOBS: Icons.work_rounded,
    Interest.FOOD: Icons.fastfood_rounded,
    Interest.EDUCATION: Icons.school_rounded,
    Interest.OFFERS: Icons.local_offer_rounded,
    Interest.REAL_ESTATE: Icons.home_work_rounded,
    Interest.ONLINE_COURSES: Icons.menu_book_rounded,
    Interest.BAKERY: Icons.cake_rounded,
    Interest.HEALTH: Icons.health_and_safety_rounded,
    Interest.TRAVEL: Icons.flight_rounded,
    Interest.ENTERTAINMENT: Icons.movie_rounded,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _fetchCampaigns();
  }

  Set<Interest> _getAvailableInterests() {
    if (campaigns.isEmpty) return {};

    final availableInterests = <Interest>{};
    for (final campaign in campaigns) {
      if (campaign.interests != null) {
        availableInterests.addAll(campaign.interests!);
      }
    }
    return availableInterests;
  }

  Future<void> _fetchCampaigns() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    _autoScrollTimer?.cancel();
    _imageDisplayTime.clear();
    _imageSizes.clear();
    _videoControllers.forEach((_, c) => c.dispose());
    _videoControllers.clear();
    _currentPage = 0;

    if (_pageController.hasClients) _pageController.jumpToPage(0);

    try {
      final result = await promotion_Authservice.fetchcampaign();
      campaigns = result.where((campaign) {
        if (campaign.status != Status.ACTIVE) return false;
        if (campaign.approvalStatus != ApprovalStatus.APPROVED) return false;
        if (campaign.addDisplayPosition != AddDisplayPosition.ADD_SCREEN)
          return false;
        if (_selectedInterest != null)
          return campaign.interests?.contains(_selectedInterest) ?? false;
        return true;
      }).toList();

      if (campaigns.isNotEmpty &&
          (campaigns.first.mediaType ?? '').toLowerCase() == "video") {
        await _initializeVideo(0);
      }
      _startAutoScrollTimer();
    } catch (e) {
      debugPrint("❌ Campaign API Error: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || campaigns.isEmpty || _currentPage >= campaigns.length)
        return;
      final campaign = campaigns[_currentPage];
      if ((campaign.mediaType ?? '').toLowerCase() == "image") {
        if (_getPlaybackTime() >= 5) _nextPage();
      }
    });
  }

  num _getPlaybackTime() {
    if (campaigns.isEmpty || _currentPage >= campaigns.length) return 0;
    final campaign = campaigns[_currentPage];
    if ((campaign.mediaType ?? '').toLowerCase() == 'video') {
      return _videoControllers[_currentPage]?.value.position.inSeconds ?? 0;
    }
    _imageDisplayTime[_currentPage] =
        (_imageDisplayTime[_currentPage] ?? 0) + 1;
    return _imageDisplayTime[_currentPage]!;
  }

  void _nextPage() {
    if (_currentPage < campaigns.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _initializeVideo(int index) async {
    final url = campaigns[index].imageUrl ?? '';
    if (!isVideo(url) || _videoControllers.containsKey(index)) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller
      ..setLooping(false)
      ..play();
    _videoControllers[index] = controller;
    setState(() {});
  }

  void _pauseVideo(int index) {
    _videoControllers[index]?.pause();
    _videoControllers[index]?.seekTo(Duration.zero);
  }

  int _calculateWatchDuration(int index) {
    if (_videoStartTime == null) return 0;
    final seconds = DateTime.now().difference(_videoStartTime!).inSeconds;
    _watchDuration[index] = seconds;
    return seconds;
  }

  double _calculateScrollDepth(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) return 0;
    final total = controller.value.duration.inSeconds;
    final watched = controller.value.position.inSeconds;
    return total == 0 ? 0 : (watched / total) * 100;
  }

  double _calculateImageScrollDepth(int index) {
    return ((_imageDisplayTime[index] ?? 0) / 5) * 100;
  }

  Future<Map<String, dynamic>> _buildPayload(int campaignId) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "campaignId": campaignId,
      "customerId": prefs.getString('customerId'),
    };
  }

  Future<void> _sendAnalytics(int index) async {
    if (campaigns.isEmpty || index >= campaigns.length) return;
    final campaign = campaigns[index];
    if (_sentCampaignAnalytics.contains(campaign.campaignId)) return;
    final isVideoMedia = isVideo(campaign.imageUrl);
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      "campaignId": campaign.campaignId,
      "customerId": prefs.getString('customerId'),
      "distanceKm": 0,
      "durationSeconds": _calculateWatchDuration(index),
      "scrollDepthPercent":
          (isVideoMedia
                  ? _calculateScrollDepth(index)
                  : _calculateImageScrollDepth(index))
              .clamp(0, 100)
              .toInt(),
      "deviceType": "ANDROID",
    };
    try {
      await promotion_Authservice.sendViewAnalytics(payload);
      _sentCampaignAnalytics.add(campaign.campaignId!);
    } catch (e) {
      debugPrint("❌ Analytics Error: $e");
    }
  }

  bool isVideo(String? url) {
    if (url == null) return false;
    return url.toLowerCase().endsWith(".mp4") ||
        url.toLowerCase().contains(".mp4?");
  }

  Future<Size> _getImageSize(String url) async {
    if (_imageSizes.containsKey(url.hashCode)) {
      return _imageSizes[url.hashCode]!;
    }
    final Completer<Size> completer = Completer();
    final Image image = Image.network(url);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) {
              final size = Size(
                info.image.width.toDouble(),
                info.image.height.toDouble(),
              );
              _imageSizes[url.hashCode] = size;
              completer.complete(size);
            },
            onError: (exception, stackTrace) {
              completer.completeError(exception);
            },
          ),
        );
    return completer.future;
  }

  @override
  void dispose() {
    _sendAnalytics(_currentPage);
    _autoScrollTimer?.cancel();
    for (final c in _videoControllers.values) c.dispose();
    _videoControllers.clear();
    _pageController.dispose();
    _catScrollController.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _R.black,
      body: Column(
        children: [
          Container(
            color: _R.white,
            padding: EdgeInsets.only(top: topPadding + 8, bottom: 8),
            width: double.infinity,
            child: Row(
              children: [
                // Back Arrow Button (Left) - UPDATED with callback
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onBackPressed != null) {
                      widget
                          .onBackPressed!(); // Call the callback to go to HomeWrapper
                    } else {
                      Navigator.pop(context); // Fallback to pop if no callback
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: rpBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: rpBorder),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 15,
                      color: rpText1,
                    ),
                  ),
                ),

                Expanded(child: _buildScrollableCategories()),

                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePromotionScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: _R.gradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _R.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: _R.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildScrollableCategories() {
    final availableInterests = _getAvailableInterests();

    if (campaigns.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredInterests = _allInterests
        .where((interest) => availableInterests.contains(interest))
        .toList();

    return SizedBox(
      height: _catBarHeight,

      child: ListView(
        controller: _catScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildCategoryChip(null, 'All', Icons.apps_rounded),
          ...filteredInterests.map(
            (interest) => _buildCategoryChip(
              interest,
              interest.name.replaceAll('_', ' '),
              _interestIcons[interest] ?? Icons.category_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Interest? interest, String title, IconData icon) {
    final isSelected = _selectedInterest == interest;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedInterest = interest);
        _fetchCampaigns();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: isSelected ? _R.gradient : null,
                color: isSelected ? null : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _R.accent : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _R.accent.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? _R.white : const Color(0xFF6B7280),
                size: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? _R.accent : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (isLoading) return _buildLoading();
    if (campaigns.isEmpty) return _buildEmpty();

    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      itemCount: campaigns.length,
      onPageChanged: (index) async {
        await _sendAnalytics(_currentPage);
        _pauseVideo(_currentPage);
        _currentPage = index;
        _videoStartTime = DateTime.now();
        _initializeVideo(index);
        setState(() {});
      },
      itemBuilder: (_, index) => _buildMediaItem(campaigns[index], index),
    );
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: _R.gradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_circle_rounded,
            color: _R.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Loading campaigns...',
          style: TextStyle(
            color: _R.text2,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: _R.accentLight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.movie_filter_rounded, color: _R.accent, size: 34),
        ),
        const SizedBox(height: 16),
        const Text(
          'No campaigns found',
          style: TextStyle(
            color: _R.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Try a different category',
          style: TextStyle(color: _R.text2, fontSize: 12),
        ),
      ],
    ),
  );

  // ── Media Item ────────────────────────────────────────────────────────────────
  Widget _buildMediaItem(Campaign campaign, int index) {
    final url = campaign.imageUrl ?? '';
    final isVid = isVideo(url);
    final isActive = index == _currentPage;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: _R.black),
        if (isVid) _buildVideoWidget(index) else _buildFullImage(url),
        if (isVid && isActive) _buildVideoProgress(index),
        Positioned(
          right: 12,
          bottom: 140,
          child: _buildActionButtons(campaign, index),
        ),
        Positioned(
          left: 16,
          right: 80,
          bottom: 50,
          child: _buildCampaignInfo(campaign),
        ),
        if (campaign.goal == Goal.LEADS)
          Positioned(
            left: 16,
            right: 80,
            bottom: 120,
            child: _buildEnquiryButton(),
          ),
      ],
    );
  }

  // Widget _buildFullImage(String url) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       return FutureBuilder<Size>(
  //         future: _getImageSize(url),
  //         builder: (context, snapshot) {
  //           if (!snapshot.hasData) {
  //             return const Center(
  //               child: CircularProgressIndicator(
  //                 color: _R.accent,
  //                 strokeWidth: 2,
  //               ),
  //             );
  //           }
  //
  //           final imageSize = snapshot.data!;
  //           final availableWidth = constraints.maxWidth;
  //           final availableHeight = constraints.maxHeight;
  //           final imageRatio = imageSize.width / imageSize.height;
  //           final screenRatio = availableWidth / availableHeight;
  //
  //           double displayWidth;
  //           double displayHeight;
  //
  //           if (imageRatio > screenRatio) {
  //             displayWidth = availableWidth;
  //             displayHeight = availableWidth / imageRatio;
  //           } else {
  //             displayHeight = availableHeight;
  //             displayWidth = availableHeight * imageRatio;
  //           }
  //
  //           return Center(
  //             child: SizedBox(
  //               width: displayWidth,
  //               height: displayHeight,
  //               child: Image.network(
  //                 url,
  //                 fit: BoxFit.contain,
  //                 loadingBuilder: (context, child, loadingProgress) {
  //                   if (loadingProgress == null) return child;
  //                   return Center(
  //                     child: CircularProgressIndicator(
  //                       color: _R.accent,
  //                       strokeWidth: 2,
  //                       value: loadingProgress.expectedTotalBytes != null
  //                           ? loadingProgress.cumulativeBytesLoaded /
  //                                 loadingProgress.expectedTotalBytes!
  //                           : null,
  //                     ),
  //                   );
  //                 },
  //                 errorBuilder: (context, error, stackTrace) => Container(
  //                   color: Colors.grey[900],
  //                   child: const Center(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(
  //                           Icons.broken_image_rounded,
  //                           color: Colors.white38,
  //                           size: 60,
  //                         ),
  //                         SizedBox(height: 12),
  //                         Text(
  //                           'Failed to load image',
  //                           style: TextStyle(
  //                             color: Colors.white54,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildFullImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.fill,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: _R.accent,
            strokeWidth: 2,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_rounded, color: Colors.white38, size: 60),
              SizedBox(height: 12),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoWidget(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: _R.black,
        child: const Center(
          child: CircularProgressIndicator(color: _R.accent, strokeWidth: 2),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
          if (!controller.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_filled_rounded,
                color: Colors.white54,
                size: 72,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoProgress(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized)
      return const SizedBox();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: VideoProgressIndicator(
        controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          playedColor: _R.accent,
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white10,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildActionButtons(Campaign campaign, int index) {
    return Column(
      children: [
        _actionButton(
          icon: _likedVideos.contains(index)
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: _likedVideos.contains(index) ? _R.red : _R.white,
          count: (campaign.likesCount ?? 0).toInt(),
          onTap: () async {
            HapticFeedback.lightImpact();
            final payload = await _buildPayload(campaign.campaignId!);
            await promotion_Authservice.sendlikeAnalytics(payload);
            setState(() {
              if (_likedVideos.contains(index)) {
                _likedVideos.remove(index);
                campaigns[index].likesCount =
                    (campaigns[index].likesCount ?? 1) - 1;
              } else {
                _likedVideos.add(index);
                campaigns[index].likesCount =
                    (campaigns[index].likesCount ?? 0) + 1;
              }
            });
          },
        ),
        const SizedBox(height: 18),
        _actionButton(
          icon: Icons.remove_red_eye_rounded,
          color: _R.white,
          count: (campaign.viewsCount ?? 0).toInt(),
        ),
        const SizedBox(height: 18),
        _actionButton(
          icon: Icons.reply_rounded,
          color: _R.white,
          count: (campaign.sharesCount ?? 0).toInt(),
          onTap: () async {
            await Share.share(campaign.imageUrl ?? '');
            final payload = await _buildPayload(campaign.campaignId!);
            await promotion_Authservice.sendshareAnalytics(payload);
            setState(
              () => campaigns[index].sharesCount =
                  (campaigns[index].sharesCount ?? 0) + 1,
            );
          },
        ),
        const SizedBox(height: 18),
        _actionButton(
          icon: _savedVideos.contains(index)
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: _savedVideos.contains(index) ? _R.amber : _R.white,
          count: (campaign.savesCount ?? 0).toInt(),
          onTap: () async {
            HapticFeedback.lightImpact();
            final payload = await _buildPayload(campaign.campaignId!);
            await promotion_Authservice.sendsaveAnalytics(payload);
            setState(() {
              if (_savedVideos.contains(index)) {
                _savedVideos.remove(index);
                campaigns[index].savesCount =
                    (campaigns[index].savesCount ?? 1) - 1;
              } else {
                _savedVideos.add(index);
                campaigns[index].savesCount =
                    (campaigns[index].savesCount ?? 0) + 1;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required int count,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: _R.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignInfo(Campaign campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          campaign.campaignName ?? '',
          style: const TextStyle(
            color: _R.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        if ((campaign.description ?? '').isNotEmpty)
          Text(
            campaign.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
      ],
    );
  }

  Widget _buildEnquiryButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EnquiryFormScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        decoration: BoxDecoration(
          gradient: _R.gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _R.accent.withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_rounded, color: _R.white, size: 17),
            SizedBox(width: 8),
            Text(
              'Get Enquiry',
              style: TextStyle(
                color: _R.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
