import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../food&beverages/tickets_screen.dart';

class Supportteam extends StatefulWidget {
  const Supportteam({super.key});
  @override
  _SupportteamState createState() => _SupportteamState();
}

class _SupportteamState extends State<Supportteam> {
  bool isDrawerOpen = false;
  int selectedIndex = -1;

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  // Using a map to manage FAQ states more efficiently
  final Map<String, bool> _faqStates = {
    'Coupons & Offers': false,
    'General Enquiry': false,
    'Orders/Products Related': false,
    'Payment Related': false,
    'Feedback & Suggestions': false,
  };

  void _toggleFAQ(String key) {
    setState(() {
      _faqStates[key] = !_faqStates[key]!;
    });
  }

  Future<void> _makeSupportCall() async {
    const supportNumber = 'tel:+919063888450';
    if (await canLaunchUrl(Uri.parse(supportNumber))) {
      await launchUrl(Uri.parse(supportNumber));
    } else {
      throw 'Could not launch $supportNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: const Text("Support Center"),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Support Options Cards
                    // _buildSupportOptions(),
                    // SizedBox(height: 24.h),

                    // FAQ Section
                    _buildFAQSection(),
                    SizedBox(height: 24.h),

                    // Quick Actions
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB15DC6), Color(0xFF4A43C9)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   "Support Center",
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 18.sp,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    SizedBox(height: 4.h),
                    Text(
                      "We're here to help you 24/7",
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // SizedBox(height: 16.h),
          // // Support Stats
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     _buildStatItem("15 Min", "Avg Response"),
          //     _buildStatItem("24/7", "Available"),
          //     _buildStatItem("98%", "Satisfaction"),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Support",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSupportCard(
                icon: Icons.phone_in_talk,
                title: "Call Support",
                subtitle: "Instant help",
                color: Color(0xFF4CAF50),
                onTap: _makeSupportCall,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSupportCard(
                icon: Icons.chat_bubble,
                title: "Live Chat",
                subtitle: "24/7 Available",
                color: Color(0xFF2196F3),
                onTap: () {
                  // Add live chat functionality
                },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "${_faqStates.length} Topics",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ..._faqStates.keys.map((key) => _buildFAQItem(key)),
      ],
    );
  }

  Widget _buildFAQItem(String title) {
    bool isExpanded = _faqStates[title]!;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Color(0xFF6C63FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getFAQIcon(title),
            color: Color(0xFF6C63FF),
            size: 16.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.grey[500],
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: _buildFAQContent(title),
          ),
        ],
        onExpansionChanged: (bool expanded) {
          _toggleFAQ(title);
        },
      ),
    );
  }

  IconData _getFAQIcon(String title) {
    switch (title) {
      case "Coupons & Offers":
        return Icons.local_offer;
      case "General Enquiry":
        return Icons.help_outline;
      case "Orders/Products Related":
        return Icons.shopping_bag;
      case "Payment Related":
        return Icons.payment;
      case "Feedback & Suggestions":
        return Icons.feedback;
      default:
        return Icons.help;
    }
  }

  Widget _buildFAQContent(String title) {
    List<String> faqItems = [];

    switch (title) {
      case "Coupons & Offers":
        faqItems = [
          "Coupon not working / expired coupon",
          "How do I apply a coupon?",
          "Why can't I use multiple offers?",
        ];
        break;
      case "General Enquiry":
        faqItems = [
          "How do I sign up or log in?",
          "Can I change my email or phone number?",
          "How do I delete my account?",
        ];
        break;
      case "Orders/Products Related":
        faqItems = [
          "How do I place or cancel an order?",
          "What if I received the wrong item?",
          "How to track my order?",
        ];
        break;
      case "Payment Related":
        faqItems = [
          "My payment failed, what should I do?",
          "How do I request a refund?",
          "What payment methods are supported?",
        ];
        break;
      case "Feedback & Suggestions":
        faqItems = [
          "How do I submit feedback?",
          "Where can I suggest new features?",
          "Is my feedback rewarded?",
        ];
        break;
      default:
        faqItems = ["No FAQs available for this section."];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        faqItems.length,
        (index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                margin: EdgeInsets.only(top: 6.h, right: 8.w),
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  faqItems[index],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            // "Ticket Management",
            "TableServices",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSupportCard(
                icon: Icons.list_alt,
                title: "View Tickets",
                subtitle: "Check existing tickets",
                color: Color(0xFFFF9800),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('userId') ?? 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketListScreen(userId: userId),
                    ),
                  );
                },
              ),
              // child: _buildActionButton(
              //   icon: Icons.list_alt,
              //   title: "View Tickets",
              //   subtitle: "Check existing tickets",
              //   color: Color(0xFFFF9800),
              //   onTap: () async {
              //     final prefs = await SharedPreferences.getInstance();
              //     final userId = prefs.getInt('userId') ?? 0;
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => TicketListScreen(userId: userId),
              //       ),
              //     );
              //   },
              // ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSupportCard(
                icon: Icons.phone_in_talk,
                title: "Call Support",
                subtitle: "Instant help",
                color: Color(0xFF4CAF50),
                onTap: _makeSupportCall,
              ),
              // child: _buildActionButton(
              //   icon: Icons.add_circle,
              //   title: "Raise Ticket",
              //   subtitle: "Create new ticket",
              //   color: Color(0xFF6C63FF),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => CreateTicketScreen(),
              //       ),
              //     );
              //   },
              // ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
          ],
        ),
      ),
    );
  }
}
