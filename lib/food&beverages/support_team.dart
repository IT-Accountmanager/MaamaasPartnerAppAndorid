// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:maamaaspartner/food&beverages/tickets_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class Supportteam extends StatefulWidget {
//   const Supportteam({super.key});
//   @override
//   _SupportteamState createState() => _SupportteamState();
// }
//
// class _SupportteamState extends State<Supportteam> {
//   bool isDrawerOpen = false;
//   int selectedIndex = -1;
//
//   void toggleDrawer() {
//     setState(() {
//       isDrawerOpen = !isDrawerOpen;
//     });
//   }
//
//   // Using a map to manage FAQ states more efficiently
//   final Map<String, bool> _faqStates = {
//     'Coupons & Offers': false,
//     'General Enquiry': false,
//     'Orders/Products Related': false,
//     'Payment Related': false,
//     'Feedback & Suggestions': false,
//   };
//
//   void _toggleFAQ(String key) {
//     setState(() {
//       _faqStates[key] = !_faqStates[key]!;
//     });
//   }
//
//   Future<void> _makeSupportCall() async {
//     const supportNumber = 'tel:+919652030425';
//     if (await canLaunchUrl(Uri.parse(supportNumber))) {
//       await launchUrl(Uri.parse(supportNumber));
//     } else {
//       throw 'Could not launch $supportNumber';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(60.h),
//         child: AppBar(
//           title: const Text(
//             "Support Team",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           iconTheme: IconThemeData(color: Colors.black),
//         ),
//       ),
//       backgroundColor: Colors.grey[50],
//       body: Column(
//         children: [
//           // Header Section
//           _buildHeader(),
//           // Main Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//               child: Column(
//                 children: [
//                   // Support Options Cards
//                   _buildSupportOptions(),
//                   SizedBox(height: 24.h),
//
//                   // FAQ Section
//                   _buildFAQSection(),
//                   SizedBox(height: 24.h),
//
//                   // Quick Actions
//                   _buildQuickActions(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: SafeArea(top: false, child: home_footer()),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFB15DC6), Color(0xFF4A43C9)],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24.r),
//           bottomRight: Radius.circular(24.r),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(12.r),
//                 decoration: BoxDecoration(
//                   // ignore: deprecated_member_use
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.support_agent,
//                   color: Colors.white,
//                   size: 24.sp,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Support Center",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       "We're here to help you 24/7",
//                       style: TextStyle(
//                         // ignore: deprecated_member_use
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           // SizedBox(height: 16.h),
//           // // Support Stats
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.spaceAround,
//           //   children: [
//           //     _buildStatItem("15 Min", "Avg Response"),
//           //     _buildStatItem("24/7", "Available"),
//           //     _buildStatItem("98%", "Satisfaction"),
//           //   ],
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupportOptions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Quick Support",
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         SizedBox(height: 12.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildSupportCard(
//                 icon: Icons.phone_in_talk,
//                 title: "Call Support",
//                 subtitle: "Instant help",
//                 color: Color(0xFF4CAF50),
//                 onTap: _makeSupportCall,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: _buildSupportCard(
//                 icon: Icons.chat_bubble,
//                 title: "Live Chat",
//                 subtitle: "24/7 Available",
//                 color: Color(0xFF2196F3),
//                 onTap: () {
//                   // Add live chat functionality
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSupportCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.all(8.r),
//               decoration: BoxDecoration(
//                 // ignore: deprecated_member_use
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: color, size: 20.sp),
//             ),
//             SizedBox(height: 12.h),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               subtitle,
//               style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFAQSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Frequently Asked Questions",
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//               decoration: BoxDecoration(
//                 // ignore: deprecated_member_use
//                 color: Color(0xFF6C63FF).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Text(
//                 "${_faqStates.length} Topics",
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   color: Color(0xFF6C63FF),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16.h),
//         ..._faqStates.keys.map((key) => _buildFAQItem(key)),
//       ],
//     );
//   }
//
//   Widget _buildFAQItem(String title) {
//     bool isExpanded = _faqStates[title]!;
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 8.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
//         ],
//       ),
//       child: ExpansionTile(
//         tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//         leading: Container(
//           width: 32.w,
//           height: 32.h,
//           decoration: BoxDecoration(
//             // ignore: deprecated_member_use
//             color: Color(0xFF6C63FF).withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             _getFAQIcon(title),
//             color: Color(0xFF6C63FF),
//             size: 16.sp,
//           ),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey[800],
//           ),
//         ),
//         trailing: Icon(
//           isExpanded ? Icons.expand_less : Icons.expand_more,
//           color: Colors.grey[500],
//         ),
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: _buildFAQContent(title),
//           ),
//         ],
//         onExpansionChanged: (bool expanded) {
//           _toggleFAQ(title);
//         },
//       ),
//     );
//   }
//
//   IconData _getFAQIcon(String title) {
//     switch (title) {
//       case "Coupons & Offers":
//         return Icons.local_offer;
//       case "General Enquiry":
//         return Icons.help_outline;
//       case "Orders/Products Related":
//         return Icons.shopping_bag;
//       case "Payment Related":
//         return Icons.payment;
//       case "Feedback & Suggestions":
//         return Icons.feedback;
//       default:
//         return Icons.help;
//     }
//   }
//
//   Widget _buildFAQContent(String title) {
//     List<String> faqItems = [];
//
//     switch (title) {
//       case "Coupons & Offers":
//         faqItems = [
//           "Coupon not working / expired coupon",
//           "How do I apply a coupon?",
//           "Why can't I use multiple offers?",
//         ];
//         break;
//       case "General Enquiry":
//         faqItems = [
//           "How do I sign up or log in?",
//           "Can I change my email or phone number?",
//           "How do I delete my account?",
//         ];
//         break;
//       case "Orders/Products Related":
//         faqItems = [
//           "How do I place or cancel an order?",
//           "What if I received the wrong item?",
//           "How to track my order?",
//         ];
//         break;
//       case "Payment Related":
//         faqItems = [
//           "My payment failed, what should I do?",
//           "How do I request a refund?",
//           "What payment methods are supported?",
//         ];
//         break;
//       case "Feedback & Suggestions":
//         faqItems = [
//           "How do I submit feedback?",
//           "Where can I suggest new features?",
//           "Is my feedback rewarded?",
//         ];
//         break;
//       default:
//         faqItems = ["No FAQs available for this section."];
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: List.generate(
//         faqItems.length,
//         (index) => Padding(
//           padding: EdgeInsets.symmetric(vertical: 8.h),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 4.w,
//                 height: 4.w,
//                 margin: EdgeInsets.only(top: 6.h, right: 8.w),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF6C63FF),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   faqItems[index],
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.grey[700],
//                     height: 1.4,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickActions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Ticket Management",
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         SizedBox(height: 12.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildActionButton(
//                 icon: Icons.list_alt,
//                 title: "View Tickets",
//                 subtitle: "Check existing tickets",
//                 color: Color(0xFFFF9800),
//                 onTap: () async {
//                   final prefs = await SharedPreferences.getInstance();
//                   final userId = prefs.getInt('userId') ?? 0;
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => TicketListScreen(userId: userId),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: _buildActionButton(
//                 icon: Icons.add_circle,
//                 title: "Raise Ticket",
//                 subtitle: "Create new ticket",
//                 color: Color(0xFF6C63FF),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CreateTicketScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.r),
//               decoration: BoxDecoration(
//                 // ignore: deprecated_member_use
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: color, size: 20.sp),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     subtitle,
//                     style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaaspartner/food&beverages/tickets_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);

  static LinearGradient get gradient => const LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Supportteam ─────────────────────────────────────────────────────────────
class Supportteam extends StatefulWidget {
  const Supportteam({super.key});
  @override
  _SupportteamState createState() => _SupportteamState();
}

class _SupportteamState extends State<Supportteam> {
  final Map<String, bool> _faqStates = {
    'Coupons & Offers': false,
    'General Enquiry': false,
    'Orders/Products Related': false,
    'Payment Related': false,
    'Feedback & Suggestions': false,
  };

  void _toggleFAQ(String key) =>
      setState(() => _faqStates[key] = !_faqStates[key]!);

  Future<void> _makeSupportCall() async {
    const supportNumber = 'tel:+919652030425';
    final uri = Uri.parse(supportNumber);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Column(
                  children: [
                    _buildSupportOptions(),
                    SizedBox(height: 22.h),
                    _buildFAQSection(),
                    SizedBox(height: 22.h),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
      decoration: const BoxDecoration(
        color: _T.white,
        border: Border(bottom: BorderSide(color: _T.border, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: _T.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _T.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: _T.text1,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support Team',
                  style: TextStyle(
                    color: _T.text1,
                    fontWeight: FontWeight.w800,
                    fontSize: 17.sp,
                    letterSpacing: -0.3,
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  // ── Support banner ────────────────────────────────────────────────────────────
  Widget _buildSupportBanner() {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: _T.gradient,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _T.accent.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Available 24/7 — We\'re always here',
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bannerStat('24/7', 'Available'),
              SizedBox(height: 6.h),
              _bannerStat('98%', 'Satisfaction'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        label,
        style: TextStyle(color: Colors.white60, fontSize: 9.sp),
      ),
    ],
  );

  // ── Support Options ───────────────────────────────────────────────────────────
  Widget _buildSupportOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSupportBanner(),
        SizedBox(height: 18.h),
        _sectionLabel('Quick Support'),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildSupportCard(
                icon: Icons.phone_in_talk_rounded,
                title: 'Call Support',
                subtitle: 'Instant help',
                color: _T.green,
                bgColor: _T.greenLight,
                onTap: _makeSupportCall,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSupportCard(
                icon: Icons.chat_bubble_rounded,
                title: 'Live Chat',
                subtitle: '24/7 Available',
                color: _T.blue,
                bgColor: _T.blueLight,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            const BoxShadow(
              color: _T.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: color, size: 19.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _T.text1,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.sp, color: _T.text2),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: _T.gradient,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Connect →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAQ Section ───────────────────────────────────────────────────────────────
  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionLabel('Frequently Asked Questions')),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: _T.accentLight,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                '${_faqStates.length} Topics',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _T.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ..._faqStates.keys.map((key) => _buildFAQItem(key)),
      ],
    );
  }

  Widget _buildFAQItem(String title) {
    final isExpanded = _faqStates[title]!;
    return GestureDetector(
      onTap: () => _toggleFAQ(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isExpanded ? _T.accent.withOpacity(0.25) : _T.border,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded ? _T.accent.withOpacity(0.08) : _T.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: isExpanded ? _T.accentLight : _T.bg,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(
                        color: isExpanded
                            ? _T.accent.withOpacity(0.25)
                            : _T.border,
                      ),
                    ),
                    child: Icon(
                      _getFAQIcon(title),
                      color: isExpanded ? _T.accent : _T.text2,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: isExpanded ? _T.accent : _T.text1,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? _T.accent : _T.text3,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Expanded content
            if (isExpanded) ...[
              Container(
                height: 1,
                color: _T.border,
                margin: EdgeInsets.symmetric(horizontal: 14.w),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
                child: _buildFAQContent(title),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getFAQIcon(String title) {
    switch (title) {
      case 'Coupons & Offers':
        return Icons.local_offer_rounded;
      case 'General Enquiry':
        return Icons.help_outline_rounded;
      case 'Orders/Products Related':
        return Icons.shopping_bag_rounded;
      case 'Payment Related':
        return Icons.payment_rounded;
      case 'Feedback & Suggestions':
        return Icons.feedback_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Widget _buildFAQContent(String title) {
    final Map<String, List<String>> faqData = {
      'Coupons & Offers': [
        'Coupon not working / expired coupon',
        'How do I apply a coupon?',
        'Why can\'t I use multiple offers?',
      ],
      'General Enquiry': [
        'How do I sign up or log in?',
        'Can I change my email or phone number?',
        'How do I delete my account?',
      ],
      'Orders/Products Related': [
        'How do I place or cancel an order?',
        'What if I received the wrong item?',
        'How to track my order?',
      ],
      'Payment Related': [
        'My payment failed, what should I do?',
        'How do I request a refund?',
        'What payment methods are supported?',
      ],
      'Feedback & Suggestions': [
        'How do I submit feedback?',
        'Where can I suggest new features?',
        'Is my feedback rewarded?',
      ],
    };

    final items = faqData[title] ?? ['No FAQs available.'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18.r,
                    height: 18.r,
                    margin: EdgeInsets.only(top: 1.h),
                    decoration: BoxDecoration(
                      color: _T.accentLight,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: _T.accent,
                      size: 13.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _T.text2,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Quick Actions / Ticket Management ─────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Ticket Management'),
        SizedBox(height: 10.h),
        _buildTicketAction(
          icon: Icons.list_alt_rounded,
          title: 'View Tickets',
          subtitle: 'Check existing support tickets',
          color: _T.amber,
          bgColor: _T.amberLight,
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getInt('userId') ?? 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TicketListScreen(userId: userId),
              ),
            );
          },
        ),
        SizedBox(height: 10.h),
        _buildTicketAction(
          icon: Icons.add_circle_outline_rounded,
          title: 'Raise New Ticket',
          subtitle: 'Create a new support request',
          color: _T.accent,
          bgColor: _T.accentLight,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateTicketScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            const BoxShadow(
              color: _T.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _T.text1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.sp, color: _T.text2),
                  ),
                ],
              ),
            ),
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                gradient: _T.gradient,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared ────────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String title) => Row(
    children: [
      Container(
        width: 3,
        height: 16,
        decoration: BoxDecoration(
          gradient: _T.gradient,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      SizedBox(width: 8.w),
      Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: _T.text1,
        ),
      ),
    ],
  );
}
