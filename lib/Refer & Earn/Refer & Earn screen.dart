// import 'package:flutter/material.dart';
//
//
// class ReferScreen extends StatelessWidget {
//   const ReferScreen({super.key});
//
//   static const Color primaryOrange = Color(0xFFE9692C);
//   static const Color lightOrangeBg = Color(0xFFFBE3D7);
//   static const Color pageBg = Color(0xFFFFF8F5);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: pageBg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top App Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Container(
//                       width: 42,
//                       height: 42,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.arrow_back_ios_new,
//                           size: 18,
//                           color: Colors.black87,
//                         ),
//                         onPressed: () => Navigator.maybePop(context),
//                       ),
//                     ),
//                   ),
//                   const Text(
//                     'Refer',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Scrollable content
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//                 children: [
//                   // Hero gradient card
//                   _buildHeroCard(),
//
//                   const SizedBox(height: 16),
//
//                   // Referral code + buttons card
//                   _buildCodeCard(),
//
//                   const SizedBox(height: 16),
//
//                   // Stats row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildStatCard(
//                           icon: Icons.people_alt_rounded,
//                           iconBg: const Color(0xFFE7E1FB),
//                           iconColor: const Color(0xFF7C5CFC),
//                           value: '12',
//                           label: 'Referred',
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: _buildStatCard(
//                           icon: Icons.emoji_events_rounded,
//                           iconBg: const Color(0xFFFCEBD3),
//                           iconColor: const Color(0xFFE8A23D),
//                           value: '₹60',
//                           label: 'Cashback',
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // How it works card
//                   _buildHowItWorksCard(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ---------------- Hero Card ----------------
//   Widget _buildHeroCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFE9692C), Color(0xFFD8551C)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: primaryOrange.withOpacity(0.3),
//             blurRadius: 24,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // Decorative circles
//           Positioned(
//             top: -40,
//             right: -30,
//             child: _circle(160, Colors.white.withOpacity(0.08)),
//           ),
//           Positioned(
//             bottom: -50,
//             right: 20,
//             child: _circle(110, Colors.white.withOpacity(0.06)),
//           ),
//
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Gift icon
//               Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: const Icon(
//                   Icons.card_giftcard_rounded,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Invite Friends,\nEarn Rewards',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontWeight: FontWeight.w800,
//                   height: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Share your code and unlock exclusive '
//                 'benefits for you and your friends.',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.9),
//                   fontSize: 15,
//                   height: 1.4,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _circle(double size, Color color) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//     );
//   }
//
//   // ---------------- Code Card ----------------
//   Widget _buildCodeCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Code box
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 24),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: lightOrangeBg,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Text(
//               'MAAMAAU220',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 4,
//                 color: primaryOrange,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Buttons row
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(
//                     Icons.copy_all_outlined,
//                     size: 20,
//                     color: primaryOrange,
//                   ),
//                   label: const Text(
//                     'Copy Code',
//                     style: TextStyle(
//                       color: primaryOrange,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 16,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     backgroundColor: lightOrangeBg,
//                     side: BorderSide.none,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(
//                     Icons.share_rounded,
//                     size: 20,
//                     color: Colors.white,
//                   ),
//                   label: const Text(
//                     'Share Now',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 16,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryOrange,
//                     elevation: 4,
//                     shadowColor: primaryOrange.withOpacity(0.4),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- Stat Card ----------------
//   Widget _buildStatCard({
//     required IconData icon,
//     required Color iconBg,
//     required Color iconColor,
//     required String value,
//     required String label,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
//             child: Icon(icon, color: iconColor, size: 24),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w800,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- How it Works ----------------
//   Widget _buildHowItWorksCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'How it Works',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w800,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildStep(
//             number: '1',
//             title: 'Share your code',
//             description: 'Send your unique code to friends & family',
//             icon: Icons.ios_share_rounded,
//             isLast: false,
//           ),
//           _buildStep(
//             number: '2',
//             title: 'Friends sign up',
//             description: 'They register using your referral code',
//             icon: Icons.person_add_alt_1_rounded,
//             isLast: false,
//           ),
//           _buildStep(
//             number: '3',
//             title: 'Both earn rewards',
//             description: 'You and your friend get exclusive benefits',
//             icon: Icons.star_rounded,
//             isLast: true,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStep({
//     required String number,
//     required String title,
//     required String description,
//     required IconData icon,
//     required bool isLast,
//   }) {
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Number circle + connecting line
//           Column(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: primaryOrange,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text(
//                   number,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               if (!isLast)
//                 Expanded(
//                   child: Container(
//                     width: 2,
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     color: lightOrangeBg,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 16),
//
//           // Icon box
//           Container(
//             width: 48,
//             height: 48,
//             margin: const EdgeInsets.only(top: 2),
//             decoration: BoxDecoration(
//               color: lightOrangeBg,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(icon, color: primaryOrange, size: 22),
//           ),
//           const SizedBox(width: 16),
//
//           // Text
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 2),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../Api/APIclient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services.dart';
import 'model.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  static const Color primaryOrange = Color(0xFFE9692C);
  static const Color lightOrangeBg = Color(0xFFFBE3D7);
  static const Color pageBg = Color(0xFFFFF8F5);

  String? _referralCode;
  bool _isLoading = true;
  String? _errorMessage;
  VendorReferralResponse? _vendorData;
  int _referredCount = 0;
  double _cashbackAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
    _loadReferralStats();
  }

  Future<void> _loadReferralData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');

      if (vendorId == null) {
        setState(() {
          _errorMessage = "Vendor ID not found. Please login again.";
          _isLoading = false;
        });
        return;
      }

      final vendorData = await ReferralService.getVendorByReferralCode(
        vendorId,
      );

      if (vendorData != null && mounted) {
        setState(() {
          _vendorData = vendorData;
          _referralCode = vendorData.referralCodeUsed;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load referral data";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error loading data: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadReferralStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');

      if (vendorId == null) return;

      final statsResponse = await ApiClient.get(
        "subscription/api/vendor/referral/stats/$vendorId",
        service: 'subscription',
        requiresAuth: true,
      );

      if (statsResponse.statusCode == 200 && mounted) {
        final Map<String, dynamic> statsData = statsResponse.body.isNotEmpty
            ? jsonDecode(statsResponse.body)
            : {};

        setState(() {
          _referredCount = statsData['referredCount'] ?? 0;
          _cashbackAmount = (statsData['cashbackAmount'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _referredCount = 0;
          _cashbackAmount = 0.0;
        });
      }
    }
  }

  Future<void> _copyCode() async {
    if (_referralCode != null && _referralCode!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _referralCode!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Referral code copied to clipboard!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _shareCode() async {
    if (_referralCode != null && _referralCode!.isNotEmpty) {
      await Share.share(
        'Use my referral code: $_referralCode to get exciting rewards!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                  ),
                  const Text(
                    'Refer',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryOrange,
                        ),
                      ),
                    )
                  : _errorMessage != null
                  ? _buildErrorWidget()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        // Hero gradient card
                        _buildHeroCard(),

                        const SizedBox(height: 16),

                        // Referral code + buttons card
                        _buildCodeCard(),

                        const SizedBox(height: 16),

                        // Stats row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.people_alt_rounded,
                                iconBg: const Color(0xFFE7E1FB),
                                iconColor: const Color(0xFF7C5CFC),
                                value: _referredCount.toString(),
                                label: 'Referred',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.emoji_events_rounded,
                                iconBg: const Color(0xFFFCEBD3),
                                iconColor: const Color(0xFFE8A23D),
                                value: '₹${_cashbackAmount.toStringAsFixed(0)}',
                                label: 'Cashback',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // How it works card
                        _buildHowItWorksCard(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _loadReferralData();
              _loadReferralStats();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ---------------- Hero Card ----------------
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9692C), Color(0xFFD8551C)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -30,
            child: _circle(160, Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -50,
            right: 20,
            child: _circle(110, Colors.white.withOpacity(0.06)),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gift icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Invite Friends,\nEarn Rewards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share your code and unlock exclusive '
                'benefits for you and your friends.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ---------------- Code Card ----------------
  Widget _buildCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Code box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: lightOrangeBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _referralCode ?? 'No referral code found',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: primaryOrange,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyCode,
                  icon: const Icon(
                    Icons.copy_all_outlined,
                    size: 20,
                    color: primaryOrange,
                  ),
                  label: const Text(
                    'Copy Code',
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: lightOrangeBg,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareCode,
                  icon: const Icon(
                    Icons.share_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Share Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    elevation: 4,
                    shadowColor: primaryOrange.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Stat Card ----------------
  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ---------------- How it Works ----------------
  Widget _buildHowItWorksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it Works',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildStep(
            number: '1',
            title: 'Share your code',
            description: 'Send your unique code to friends & family',
            icon: Icons.ios_share_rounded,
            isLast: false,
          ),
          _buildStep(
            number: '2',
            title: 'Friends sign up',
            description: 'They register using your referral code',
            icon: Icons.person_add_alt_1_rounded,
            isLast: false,
          ),
          _buildStep(
            number: '3',
            title: 'Both earn rewards',
            description: 'You and your friend get exclusive benefits',
            icon: Icons.star_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number circle + connecting line
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: lightOrangeBg,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Icon box
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: lightOrangeBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryOrange, size: 22),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
