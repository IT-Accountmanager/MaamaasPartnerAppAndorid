import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../API/Apiclient.dart';
import '../../API/Promotion_authservice.dart';

import '../Api/Promotion_services.dart';
import '../Models/food&beverages/CampaignAnalytics.dart';
import '../Models/food&beverages/CampaignRequest.dart';
import 'create_promotion_screen.dart';

// ----------------------------- Animated Circular Progress -----------------------------
class AnimatedCircularProgress extends StatefulWidget {
  final double value;
  final String label;
  final double size;
  final Color color;
  final Duration duration;

  const AnimatedCircularProgress({
    super.key,
    required this.value,
    required this.label,
    this.size = 120,
    this.color = Colors.blue,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
      _animation = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _CircleProgressPainter(
                  progress: _animation.value,
                  backgroundColor: Colors.grey.shade200,
                  progressColor: widget.color,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      NumberFormat.percentPattern().format(_animation.value),
                      style: TextStyle(
                        fontSize: widget.size * 0.18,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: widget.size * 0.1,
                        color: Colors.grey.shade600,
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
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = size.width * 0.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    paint.color = backgroundColor;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      2 * 3.1416,
      false,
      paint,
    );

    paint.color = progressColor;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -3.1416 / 2,
      2 * 3.1416 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ----------------------------- Animated Count -----------------------------
class AnimatedCount extends StatefulWidget {
  final int target;
  final Duration duration;
  final TextStyle? style;

  const AnimatedCount({
    super.key,
    required this.target,
    this.duration = const Duration(milliseconds: 1500),
    this.style,
  });

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentDisplay = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation =
        Tween<double>(begin: 0, end: widget.target.toDouble()).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
        )..addListener(
          () => setState(() => _currentDisplay = _animation.value.round()),
        );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _controller.forward(from: 0);
      _animation = Tween<double>(begin: 0, end: widget.target.toDouble())
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
          );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      NumberFormat.compact().format(_currentDisplay),
      style:
          widget.style ??
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

// ----------------------------- Campaign List Screen -----------------------------
class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  List<CampaignRequest> _campaigns = [];
  bool _isLoading = true;
  String? _error;

  static final List<List<Color>> _cardGradients = [
    [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
  ];

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final campaigns = await PromotionAuthService.fetchUserCampaigns();

      // Filter: only ACTIVE or COMPLETED
      final filtered = campaigns
          .where((c) => c.status == 'ACTIVE' || c.status == 'COMPLETED')
          .toList();

      // Sort: ACTIVE first, then COMPLETED
      filtered.sort((a, b) {
        int getPriority(String? status) {
          if (status == 'ACTIVE') return 0;
          if (status == 'COMPLETED') return 1;
          return 2;
        }

        return getPriority(a.status).compareTo(getPriority(b.status));
      });

      setState(() {
        _campaigns = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campaigns',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatePromotionScreen(),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.add, size: 26, color: Colors.black87),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.trending_up, size: 22, color: Colors.black),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _campaigns.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No active or completed campaigns',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _campaigns.length,
              itemBuilder: (context, index) {
                final campaign = _campaigns[index];
                final gradient = _cardGradients[index % _cardGradients.length];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CampaignDetailScreen(campaignId: campaign.id!),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'campaign_${campaign.id}',
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child:
                                        campaign.imageUrl != null &&
                                            campaign.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            campaign.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      campaign.campaignName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildChip(Icons.flag, campaign.goal),
                                    const SizedBox(height: 8),
                                    _buildChip(Icons.share, campaign.medium),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.blueGrey[700],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${DateFormat.MMMd().format(DateTime.parse(campaign.startDate))} – ${DateFormat.MMMd().format(DateTime.parse(campaign.endDate))} · ${DateTime.parse(campaign.startDate).year}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.blueGrey[400],
                              ),
                            ],
                          ),
                        ),
                        // Status chip at top‑right
                        Positioned(
                          top: 16,
                          right: 16,
                          child: _buildStatusChip(campaign.status ?? 'UNKNOWN'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey[700]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    switch (status) {
      case 'ACTIVE':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.play_circle_filled;
        break;
      case 'COMPLETED':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        icon = Icons.check_circle;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        icon = Icons.help;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------- Campaign Detail Screen -----------------------------
class CampaignDetailScreen extends StatefulWidget {
  final int campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  CampaignRequest? _campaign;
  CampaignAnalytics? _analytics;
  bool _isLoading = true;
  String? _error;

  static const Color primaryAccent = Color(0xFF5E72E4);
  static const Color secondaryAccent = Color(0xFF2DCE89);
  static const Color accentOrange = Color(0xFFFB6340);
  static const Color accentRed = Color(0xFFF5365C);
  static const Color accentPurple = Color(0xFF8965E0);
  static const Color accentBlue = Color(0xFF11CDEF);
  static const Color neutralGrey = Color(0xFF8898AA);

  BoxDecoration get _glassDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
  );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final campaigns = await PromotionAuthService.fetchUserCampaigns();
      final campaignData = campaigns.firstWhere(
        (c) => c.id == widget.campaignId,
      );
      _campaign = campaignData;

      _analytics = await PromotionAuthService.fetchCampaignAnalytics(
        widget.campaignId,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _campaign == null || _analytics == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: ${_error ?? 'Campaign not found'}')),
      );
    }

    final campaign = _campaign!;
    final analytics = _analytics!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [Colors.grey.shade50, Colors.grey.shade200],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  campaign.campaignName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                background: Hero(
                  tag: 'campaign_${campaign.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty
                          ? Image.network(
                              campaign.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[800]),
                            )
                          : Container(color: Colors.grey[800]),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAnimatedCard(
                    child: Container(
                      decoration: _glassDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetaChip(
                                    Icons.calendar_today,
                                    'Start',
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(campaign.startDate),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildMetaChip(
                                    Icons.calendar_today,
                                    'End',
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(campaign.endDate),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildMetaChip(
                              Icons.share,
                              'Channels',
                              campaign.medium,
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Performance'),
                  const SizedBox(height: 16),
                  _buildAnimatedCard(
                    child: Container(
                      decoration: _glassDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnimatedCircularProgress(
                            value: analytics.viewRate,
                            label: 'View Rate',
                            color: primaryAccent,
                          ),
                          AnimatedCircularProgress(
                            value: analytics.likeRate,
                            label: 'Like Rate',
                            color: secondaryAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Key Metrics'),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildEnhancedMetricCard(
                        'Total Views',
                        analytics.totalViews,
                        Icons.visibility,
                        primaryAccent,
                      ),
                      _buildEnhancedMetricCard(
                        'Unique Viewers',
                        analytics.uniqueViewers,
                        Icons.people,
                        accentPurple,
                      ),
                      _buildEnhancedMetricCard(
                        'Total Likes',
                        analytics.totalLikes,
                        Icons.thumb_up,
                        secondaryAccent,
                      ),
                      _buildEnhancedMetricCard(
                        'Total Shares',
                        analytics.totalShares,
                        Icons.share,
                        accentBlue,
                      ),
                      _buildEnhancedMetricCard(
                        'Total Dismissals',
                        analytics.totalDismissals,
                        Icons.cancel,
                        accentRed,
                      ),
                      _buildEnhancedMetricCard(
                        'Avg Duration',
                        '${analytics.avgViewDuration.toStringAsFixed(1)}s',
                        Icons.timer,
                        accentOrange,
                        isNumber: false,
                      ),
                      _buildEnhancedMetricCard(
                        'Avg Scroll',
                        '${analytics.avgScrollDepth.toStringAsFixed(1)}%',
                        Icons.swipe,
                        accentPurple,
                        isNumber: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Interaction Breakdown'),
                  const SizedBox(height: 16),
                  _buildAnimatedCard(
                    child: Container(
                      decoration: _glassDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: analytics.interactionBreakdown.entries.map((
                          entry,
                        ) {
                          final total = analytics.interactionBreakdown.values
                              .fold(0, (sum, val) => sum + val);
                          final percentage = total > 0
                              ? entry.value / total
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    entry.key[0].toUpperCase() +
                                        entry.key.substring(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: percentage),
                                        duration: const Duration(
                                          milliseconds: 1000,
                                        ),
                                        curve: Curves.easeOutQuad,
                                        builder: (context, value, child) {
                                          return Container(
                                            height: 10,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.5 *
                                                value,
                                            decoration: BoxDecoration(
                                              color: _getColorForInteraction(
                                                entry.key,
                                              ).withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      _getColorForInteraction(
                                                        entry.key,
                                                      ).withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  NumberFormat.compact().format(entry.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${(percentage * 100).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuad,
      builder: (context, double opacity, childWidget) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A202C),
        ),
      ),
    );
  }

  Widget _buildMetaChip(
    IconData icon,
    String label,
    String value, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A5568)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF2D3748),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A202C),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMetricCard(
    String label,
    dynamic value,
    IconData icon,
    Color color, {
    bool isNumber = true,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuad,
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: 0.9 + 0.1 * opacity, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: isNumber
                        ? AnimatedCount(
                            target: value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          )
                        : Text(
                            value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForInteraction(String key) {
    switch (key) {
      case 'click':
        return primaryAccent;
      case 'like':
        return secondaryAccent;
      case 'share':
        return accentOrange;
      case 'dismiss':
        return accentRed;
      default:
        return neutralGrey;
    }
  }
}
