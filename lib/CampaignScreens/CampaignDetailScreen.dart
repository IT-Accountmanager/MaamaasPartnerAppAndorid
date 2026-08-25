// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../API/Apiclient.dart';
// import '../CampaignModel/CampaignAnalytics.dart';
// import '../CampaignModel/CampaignRequest.dart';
// import '../CampaignModel/CouponStats.dart';
// import '../CampaignService/Promotion_authservice.dart';
// import 'create_promotion_screen.dart';
//
// // ─── Design Tokens ────────────────────────────────────────────────────────────
// const _cBg = Color(0xFFF5F7FA);
// const _cWhite = Color(0xFFFFFFFF);
// const _cBorder = Color(0xFFEEEFF5);
// const _cText1 = Color(0xFF1A202C);
// const _cText2 = Color(0xFF6B7280);
// const _cText3 = Color(0xFFB0B3C1);
// const _cShadow = Color(0x0A000000);
//
// const _cPrimary = Color(0xFF5E72E4);
// const _cGreen = Color(0xFF2DCE89);
// const _cOrange = Color(0xFFFB6340);
// const _cRed = Color(0xFFF5365C);
// const _cPurple = Color(0xFF8965E0);
// const _cBlue = Color(0xFF11CDEF);
// const _cGrey = Color(0xFF8898AA);
// const _cAccent = Color(0xFFFF5722);
//
// const _kGrad = LinearGradient(
//   colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// // ─── Animated Circular Progress ────────────────────────────────────────────
// class AnimatedCircularProgress extends StatefulWidget {
//   final double value;
//   final String label;
//   final double size;
//   final Color color;
//   final Duration duration;
//
//   const AnimatedCircularProgress({
//     super.key,
//     required this.value,
//     required this.label,
//     this.size = 120,
//     this.color = Colors.blue,
//     this.duration = const Duration(milliseconds: 1500),
//   });
//
//   @override
//   State<AnimatedCircularProgress> createState() =>
//       _AnimatedCircularProgressState();
// }
//
// class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: widget.duration);
//     _anim = Tween<double>(
//       begin: 0,
//       end: widget.value,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad));
//     _ctrl.forward();
//   }
//
//   @override
//   void didUpdateWidget(covariant AnimatedCircularProgress old) {
//     super.didUpdateWidget(old);
//     if (old.value != widget.value) {
//       _ctrl.forward(from: 0);
//       _anim = Tween<double>(
//         begin: 0,
//         end: widget.value,
//       ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad));
//     }
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => SizedBox(
//         width: widget.size,
//         height: widget.size,
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             CustomPaint(
//               painter: _CircleProgressPainter(
//                 progress: _anim.value,
//                 backgroundColor: Colors.grey.shade200,
//                 progressColor: widget.color,
//               ),
//             ),
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     NumberFormat.percentPattern().format(_anim.value),
//                     style: TextStyle(
//                       fontSize: widget.size * 0.18,
//                       fontWeight: FontWeight.bold,
//                       color: widget.color,
//                     ),
//                   ),
//                   Text(
//                     widget.label,
//                     style: TextStyle(
//                       fontSize: widget.size * 0.1,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _CircleProgressPainter extends CustomPainter {
//   final double progress;
//   final Color backgroundColor, progressColor;
//   _CircleProgressPainter({
//     required this.progress,
//     required this.backgroundColor,
//     required this.progressColor,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..strokeWidth = size.width * 0.1
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//     paint.color = backgroundColor;
//     canvas.drawArc(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       0,
//       2 * 3.1416,
//       false,
//       paint,
//     );
//     paint.color = progressColor;
//     canvas.drawArc(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       -3.1416 / 2,
//       2 * 3.1416 * progress,
//       false,
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant _CircleProgressPainter old) =>
//       old.progress != progress;
// }
//
// // ─── Animated Count ────────────────────────────────────────────────────────
// class AnimatedCount extends StatefulWidget {
//   final int target;
//   final Duration duration;
//   final TextStyle? style;
//   const AnimatedCount({
//     super.key,
//     required this.target,
//     this.duration = const Duration(milliseconds: 1500),
//     this.style,
//   });
//   @override
//   State<AnimatedCount> createState() => _AnimatedCountState();
// }
//
// class _AnimatedCountState extends State<AnimatedCount>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;
//   int _display = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: widget.duration);
//     _anim = Tween<double>(begin: 0, end: widget.target.toDouble()).animate(
//       CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad),
//     )..addListener(() => setState(() => _display = _anim.value.round()));
//     _ctrl.forward();
//   }
//
//   @override
//   void didUpdateWidget(covariant AnimatedCount old) {
//     super.didUpdateWidget(old);
//     if (old.target != widget.target) {
//       _ctrl.forward(from: 0);
//       _anim = Tween<double>(
//         begin: 0,
//         end: widget.target.toDouble(),
//       ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad));
//     }
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => Text(
//     NumberFormat.compact().format(_display),
//     style:
//         widget.style ??
//         const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//   );
// }
//
// // ─── Simple Campaign Detail Screen (NO ANALYTICS) ────────────────────────────
// class SimpleCampaignDetailScreen extends StatelessWidget {
//   final CampaignRequest campaign;
//
//   const SimpleCampaignDetailScreen({super.key, required this.campaign});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _cBg,
//       appBar: AppBar(
//         backgroundColor: _cWhite,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: _cBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _cBorder),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 16,
//               color: _cText1,
//             ),
//           ),
//         ),
//         title: Text(
//           campaign.campaignName,
//           style: const TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w700,
//             color: _cText1,
//             letterSpacing: -0.3,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(height: 1, color: _cBorder),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.fromLTRB(
//           16,
//           16,
//           16,
//           24 + MediaQuery.of(context).padding.bottom,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Image.network(
//                   campaign.imageUrl!,
//                   height: 200,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     height: 200,
//                     color: Colors.grey[300],
//                     child: const Icon(
//                       Icons.broken_image,
//                       size: 50,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),
//
//             Container(
//               decoration: BoxDecoration(
//                 color: _cWhite,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _cShadow,
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'CAMPAIGN INFORMATION',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: _cText2,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _infoRow(
//                       Icons.numbers,
//                       'Campaign ID',
//                       campaign.id?.toString() ?? 'N/A',
//                     ),
//                     _infoRow(
//                       Icons.title,
//                       'Campaign Name',
//                       campaign.campaignName,
//                     ),
//                     _infoRow(Icons.flag, 'Goal', campaign.goal),
//                     if (campaign.subGoal != null &&
//                         campaign.subGoal!.isNotEmpty)
//                       _infoRow(
//                         Icons.flag_outlined,
//                         'Sub Goal',
//                         campaign.subGoal!,
//                       ),
//
//                     _infoRow(
//                       Icons.calendar_today,
//                       'Start Date',
//                       DateFormat.yMMMd().format(
//                         DateTime.parse(campaign.startDate),
//                       ),
//                     ),
//                     _infoRow(
//                       Icons.calendar_today,
//                       'End Date',
//                       DateFormat.yMMMd().format(
//                         DateTime.parse(campaign.endDate),
//                       ),
//                     ),
//                     _infoRow(
//                       Icons.attach_money,
//                       'Total Budget',
//                       campaign.totalBudget != null
//                           ? '₹${campaign.totalBudget!.toStringAsFixed(2)}'
//                           : 'Not specified',
//                     ),
//
//                     if (campaign.discountPercentage != null &&
//                         campaign.discountPercentage! > 0)
//                       _infoRow(
//                         Icons.local_offer,
//                         'Discount',
//                         '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
//                       ),
//
//                     _infoRowWithStatus(
//                       Icons.campaign,
//                       'Campaign Status',
//                       campaign.status ?? 'Unknown',
//                     ),
//                     _infoRowWithStatus(
//                       Icons.payment,
//                       'Payment Status',
//                       campaign.paymentStatus ?? 'Pending',
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _infoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: _cAccent),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: _cText2,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: _cText1,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _infoRowWithStatus(IconData icon, String label, String status) {
//     Color statusColor;
//     switch (status.toUpperCase()) {
//       case 'ACTIVE':
//         statusColor = _cGreen;
//         break;
//       case 'COMPLETED':
//         statusColor = _cBlue;
//         break;
//       case 'PENDING':
//         statusColor = _cOrange;
//         break;
//       case 'PAID':
//         statusColor = _cGreen;
//         break;
//       case 'UNPAID':
//         statusColor = _cRed;
//         break;
//       default:
//         statusColor = _cGrey;
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: _cAccent),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: _cText2,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 status,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: statusColor,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Coupon Analytics Screen ─────────────────────────────────────────────────
// class CouponAnalyticsScreen extends StatefulWidget {
//   final int campaignId;
//   final String campaignName;
//
//   const CouponAnalyticsScreen({
//     super.key,
//     required this.campaignId,
//     required this.campaignName,
//   });
//
//   @override
//   State<CouponAnalyticsScreen> createState() => _CouponAnalyticsScreenState();
// }
//
// class _CouponAnalyticsScreenState extends State<CouponAnalyticsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _cBg,
//       appBar: AppBar(
//         backgroundColor: _cWhite,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: _cBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _cBorder),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 16,
//               color: _cText1,
//             ),
//           ),
//         ),
//         title: Text(
//           '${widget.campaignName} - Coupon Stats',
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//             color: _cText1,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(height: 1, color: _cBorder),
//         ),
//       ),
//       body: FutureBuilder<CouponStats>(
//         future: PromotionAuthService.fetchCouponStats(widget.campaignId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
//             );
//           }
//
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline_rounded,
//                     size: 48,
//                     color: Color(0xFFEF4444),
//                   ),
//                   const SizedBox(height: 14),
//                   Text(
//                     'Error: ${snapshot.error}',
//                     style: const TextStyle(fontSize: 14, color: _cText2),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {});
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: _kGrad,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Text(
//                         'Retry',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (!snapshot.hasData || snapshot.data!.users.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: _cBg,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: _cBorder),
//                     ),
//                     child: const Icon(
//                       Icons.local_offer_outlined,
//                       size: 36,
//                       color: _cText3,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'No coupon usage yet',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _cText1,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   const Text(
//                     'Users haven\'t used coupons for this campaign',
//                     style: TextStyle(fontSize: 13, color: _cText2),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final stats = snapshot.data!;
//           return SingleChildScrollView(
//             padding: EdgeInsets.fromLTRB(
//               16,
//               16,
//               16,
//               24 + MediaQuery.of(context).padding.bottom,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Summary Cards
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildSummaryCard(
//                         'Total Users',
//                         stats.totalUsers.toString(),
//                         Icons.people,
//                         _cPurple,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildSummaryCard(
//                         'Total Discount',
//                         '₹${stats.totalDiscount.toStringAsFixed(2)}',
//                         Icons.discount,
//                         _cGreen,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Users List Title
//                 const Text(
//                   'COUPON USERS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: _cText2,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Users List
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: stats.users.length,
//                   itemBuilder: (context, index) {
//                     final user = stats.users[index];
//                     return _buildUserCard(user);
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSummaryCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _cWhite,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: _cShadow,
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 20, color: color),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(title, style: const TextStyle(fontSize: 12, color: _cText2)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUserCard(CouponUser user) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _cWhite,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: _cShadow, blurRadius: 8, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _cAccent.withOpacity(0.1),
//                 ),
//                 child: const Icon(Icons.person, color: _cAccent, size: 28),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _formatName(user.userName),
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: _cText1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: _kGrad,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   '₹${user.discountAmount.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Divider(color: _cBorder),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDetailChip(Icons.code, 'Code: ${user.code}'),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _buildDetailChip(
//                   user.couponType == 'FLAT'
//                       ? Icons.attach_money
//                       : Icons.percent,
//                   user.couponType,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _buildDetailChip(
//                   user.discountType == 'PERCENTAGE'
//                       ? Icons.percent
//                       : Icons.attach_money,
//                   user.discountType,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatName(String name) {
//     if (name.isEmpty) return '';
//     return name
//         .toLowerCase()
//         .split(' ')
//         .map(
//           (word) =>
//               word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
//         )
//         .join(' ');
//   }
//
//   Widget _buildDetailChip(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: _cBg,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: _cAccent),
//           const SizedBox(width: 4),
//           Flexible(
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 11, color: _cText2),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Campaign List Screen with Back Button and Tabs ─────────────────────────
// class CampaignListScreen extends StatefulWidget {
//   const CampaignListScreen({super.key});
//   @override
//   State<CampaignListScreen> createState() => _CampaignListScreenState();
// }
//
// class _CampaignListScreenState extends State<CampaignListScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   List<CampaignRequest> _campaigns = [];
//   List<CampaignRequest> _filteredCampaigns = [];
//   bool _isLoadingCampaigns = true;
//   String? _campaignsError;
//
//   // Filter states
//   String _selectedDateFilter = 'All Time';
//   String _selectedGoalFilter = 'All Goals';
//   DateTimeRange? _customDateRange;
//
//   final List<String> _dateFilters = [
//     'Today',
//     'Yesterday',
//     'This Week',
//     'This Month',
//     'Custom',
//     'All Time',
//   ];
//   final List<String> _goalFilters = [
//     'All Goals',
//     'BRANDING',
//     'DISCOUNT',
//     'LEADS',
//   ];
//
//   static final _gradients = [
//     [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
//     [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
//     [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
//     [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
//     [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)],
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _fetchCampaigns();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchCampaigns() async {
//     setState(() {
//       _isLoadingCampaigns = true;
//       _campaignsError = null;
//     });
//     try {
//       final campaigns = await PromotionAuthService.fetchUserCampaigns();
//       setState(() {
//         _campaigns = campaigns;
//         _filteredCampaigns = campaigns;
//         _isLoadingCampaigns = false;
//       });
//       _applyFilters();
//     } catch (e) {
//       setState(() {
//         _campaignsError = e.toString();
//         _isLoadingCampaigns = false;
//       });
//     }
//   }
//
//   void _applyFilters() {
//     List<CampaignRequest> filtered = List.from(_campaigns);
//     filtered = _applyDateFilter(filtered);
//     if (_selectedGoalFilter != 'All Goals') {
//       filtered = filtered
//           .where((c) => c.goal.toUpperCase() == _selectedGoalFilter)
//           .toList();
//     }
//     setState(() => _filteredCampaigns = filtered);
//   }
//
//   List<CampaignRequest> _applyDateFilter(List<CampaignRequest> campaigns) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//
//     switch (_selectedDateFilter) {
//       case 'Today':
//         return campaigns.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.year == today.year &&
//               startDate.month == today.month &&
//               startDate.day == today.day;
//         }).toList();
//       case 'Yesterday':
//         final yesterday = today.subtract(const Duration(days: 1));
//         return campaigns.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.year == yesterday.year &&
//               startDate.month == yesterday.month &&
//               startDate.day == yesterday.day;
//         }).toList();
//       case 'This Week':
//         final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
//         return campaigns.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.isAfter(
//                 startOfWeek.subtract(const Duration(days: 1)),
//               ) &&
//               startDate.isBefore(startOfWeek.add(const Duration(days: 7)));
//         }).toList();
//       case 'This Month':
//         final startOfMonth = DateTime(today.year, today.month, 1);
//         final endOfMonth = DateTime(today.year, today.month + 1, 0);
//         return campaigns.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.isAfter(
//                 startOfMonth.subtract(const Duration(days: 1)),
//               ) &&
//               startDate.isBefore(endOfMonth.add(const Duration(days: 1)));
//         }).toList();
//       case 'Custom':
//         if (_customDateRange != null) {
//           return campaigns.where((c) {
//             final startDate = DateTime.parse(c.startDate);
//             return startDate.isAfter(
//                   _customDateRange!.start.subtract(const Duration(days: 1)),
//                 ) &&
//                 startDate.isBefore(
//                   _customDateRange!.end.add(const Duration(days: 1)),
//                 );
//           }).toList();
//         }
//         return campaigns;
//       default:
//         return campaigns;
//     }
//   }
//
//   Future<void> _showCustomDatePicker() async {
//     final result = await showDialog<DateTimeRange>(
//       context: context,
//       builder: (context) => CustomDateRangePicker(
//         initialStartDate: _customDateRange?.start,
//         initialEndDate: _customDateRange?.end,
//       ),
//     );
//     if (result != null) {
//       setState(() {
//         _customDateRange = result;
//         _selectedDateFilter = 'Custom';
//       });
//       _applyFilters();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//     );
//
//     return Scaffold(
//       backgroundColor: _cBg,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: Container(
//           color: _cWhite,
//           child: SafeArea(
//             child: Row(
//               children: [
//                 if (Navigator.of(context).canPop())
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       margin: const EdgeInsets.all(8),
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _cBg,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: _cBorder),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back_ios_new_rounded,
//                         size: 16,
//                         color: _cText1,
//                       ),
//                     ),
//                   ),
//                 Expanded(
//                   child: TabBar(
//                     controller: _tabController,
//                     indicatorColor: _cAccent,
//                     indicatorWeight: 3,
//                     labelColor: _cAccent,
//                     unselectedLabelColor: _cText2,
//                     labelStyle: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     unselectedLabelStyle: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     tabs: const [
//                       Tab(text: 'CAMPAIGNS'),
//                       Tab(text: 'ANALYTICS'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [_buildCampaignsTab(), const CampaignAnalyticsListScreen()],
//       ),
//     );
//   }
//
//   Widget _buildCampaignsTab() {
//     if (_isLoadingCampaigns) {
//       return const Center(
//         child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
//       );
//     }
//     if (_campaignsError != null) {
//       return _buildCampaignsErrorState();
//     }
//
//     return Column(
//       children: [
//         Container(
//           color: _cWhite,
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: _cBorder),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: _selectedDateFilter,
//                       isExpanded: true,
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       icon: const Icon(Icons.arrow_drop_down, color: _cAccent),
//                       items: _dateFilters
//                           .map(
//                             (filter) => DropdownMenuItem(
//                               value: filter,
//                               child: Text(filter),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           if (value == 'Custom') {
//                             _showCustomDatePicker();
//                           } else {
//                             setState(() {
//                               _selectedDateFilter = value;
//                               _customDateRange = null;
//                             });
//                             _applyFilters();
//                           }
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: _cBorder),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: _selectedGoalFilter,
//                       isExpanded: true,
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       icon: const Icon(Icons.arrow_drop_down, color: _cAccent),
//                       items: _goalFilters
//                           .map(
//                             (filter) => DropdownMenuItem(
//                               value: filter,
//                               child: Text(filter),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           setState(() => _selectedGoalFilter = value);
//                           _applyFilters();
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: _filteredCampaigns.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.filter_alt_off,
//                         size: 48,
//                         color: _cText3,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'No campaigns match the filters',
//                         style: TextStyle(fontSize: 14, color: _cText2),
//                       ),
//                       const SizedBox(height: 20),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _selectedDateFilter = 'All Time';
//                             _selectedGoalFilter = 'All Goals';
//                             _customDateRange = null;
//                           });
//                           _applyFilters();
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: _kGrad,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Text(
//                             'Clear Filters',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   color: _cAccent,
//                   onRefresh: _fetchCampaigns,
//                   child: ListView.builder(
//                     padding: EdgeInsets.fromLTRB(
//                       16,
//                       16,
//                       16,
//                       24 + MediaQuery.of(context).padding.bottom,
//                     ),
//                     itemCount: _filteredCampaigns.length,
//                     itemBuilder: (_, i) => _buildSimpleCampaignCard(
//                       _filteredCampaigns[i],
//                       _gradients[i % _gradients.length],
//                     ),
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSimpleCampaignCard(
//     CampaignRequest campaign,
//     List<Color> gradient,
//   ) {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => SimpleCampaignDetailScreen(campaign: campaign),
//         ),
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradient,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: _cShadow,
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Hero(
//                     tag: 'campaign_${campaign.id}',
//                     child: Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: _cWhite, width: 3),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ClipOval(
//                         child:
//                             campaign.imageUrl != null &&
//                                 campaign.imageUrl!.isNotEmpty
//                             ? Image.network(
//                                 campaign.imageUrl!,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, __, ___) => Container(
//                                   color: Colors.grey[300],
//                                   child: const Icon(
//                                     Icons.broken_image,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               )
//                             : Container(
//                                 color: Colors.grey[300],
//                                 child: const Icon(
//                                   Icons.image,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           campaign.campaignName,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: _cText1,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         _buildChip(Icons.flag, campaign.goal),
//                         const SizedBox(height: 6),
//                         _buildChip(Icons.share, campaign.medium),
//                         if (campaign.discountPercentage != null &&
//                             campaign.discountPercentage! > 0)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 6),
//                             child: _buildChip(
//                               Icons.local_offer,
//                               '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
//                             ),
//                           ),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 13,
//                               color: Colors.blueGrey[700],
//                             ),
//                             const SizedBox(width: 5),
//                             Flexible(
//                               child: Text(
//                                 '${DateFormat.MMMd().format(DateTime.parse(campaign.startDate))} – ${DateFormat.MMMd().format(DateTime.parse(campaign.endDate))}',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.blueGrey[800],
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     size: 15,
//                     color: Colors.blueGrey[400],
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 14,
//               right: 14,
//               child: _buildStatusChip(campaign.status ?? 'UNKNOWN'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildChip(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: _cWhite.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: Colors.blueGrey[700]),
//           const SizedBox(width: 5),
//           Flexible(
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusChip(String status) {
//     Color bg, text;
//     IconData icon;
//     switch (status) {
//       case 'ACTIVE':
//         bg = Colors.green.shade50;
//         text = Colors.green.shade800;
//         icon = Icons.play_circle_filled;
//         break;
//       case 'COMPLETED':
//         bg = Colors.blue.shade50;
//         text = Colors.blue.shade800;
//         icon = Icons.check_circle;
//         break;
//       default:
//         bg = Colors.grey.shade200;
//         text = Colors.grey.shade800;
//         icon = Icons.help;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _cWhite.withOpacity(0.5)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: text),
//           const SizedBox(width: 5),
//           Text(
//             status,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: text,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCampaignsErrorState() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(
//           Icons.error_outline_rounded,
//           size: 48,
//           color: Color(0xFFEF4444),
//         ),
//         const SizedBox(height: 14),
//         Text(
//           'Error: $_campaignsError',
//           style: const TextStyle(fontSize: 14, color: _cText2),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 20),
//         GestureDetector(
//           onTap: _fetchCampaigns,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: _kGrad,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Text(
//               'Retry',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// // ─── Campaign Analytics List Screen (WITH Metrics Cards + Filter) ─────────────────────────
// // ─── Campaign Analytics List Screen (Filter Sticky, Cards + Campaigns Scroll Together) ─────────────────────────
// class CampaignAnalyticsListScreen extends StatefulWidget {
//   const CampaignAnalyticsListScreen({super.key});
//   @override
//   State<CampaignAnalyticsListScreen> createState() => _CampaignAnalyticsListScreenState();
// }
//
//
// class _CampaignAnalyticsListScreenState extends State<CampaignAnalyticsListScreen> {
//   List<CampaignRequest> _campaigns = [];
//   List<CampaignRequest> _filteredCampaigns = [];
//   bool _isLoading = true;
//   bool _isLoadingAnalytics = true;
//   String? _error;
//
//
//   // Analytics metrics
//   int _totalReach = 0;
//   int _totalViews = 0;
//   int _totalClicks = 0;
//   int _totalLeads = 0;
//
//
//   String _selectedAnalyticsDateFilter = 'All';
//   final List<String> _analyticsDateFilters = ['Today', 'Yesterday', 'This Week', 'This Month', 'All'];
//
//
//   static final _gradients = [
//     [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
//     [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
//     [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
//     [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
//     [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)],
//   ];
//
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//
//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true;
//       _isLoadingAnalytics = true;
//       _error = null;
//     });
//     try {
//       final results = await Future.wait([
//         PromotionAuthService.fetchUserCampaigns(),
//         PromotionAuthService.fetchCustomerCampaignAnalytics(),
//       ]);
//
//
//       final campaigns = results[0] as List<CampaignRequest>;
//       final analytics = results[1] as Map<String, dynamic>;
//
//
//       _totalReach = analytics['totalReach'] ?? 0;
//       _totalViews = analytics['totalViews'] ?? 0;
//       _totalClicks = analytics['totalClicks'] ?? 0;
//       _totalLeads = analytics['totalLeads'] ?? 0;
//
//
//       final filtered = campaigns.where((c) => c.status == 'ACTIVE' || c.status == 'COMPLETED').toList();
//       filtered.sort((a, b) {
//         int p(String? s) {
//           if (s == 'ACTIVE') return 0;
//           if (s == 'COMPLETED') return 1;
//           return 2;
//         }
//         return p(a.status).compareTo(p(b.status));
//       });
//
//
//       setState(() {
//         _campaigns = filtered;
//         _filteredCampaigns = filtered;
//         _isLoading = false;
//         _isLoadingAnalytics = false;
//       });
//       _applyAnalyticsDateFilter();
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//         _isLoadingAnalytics = false;
//       });
//     }
//   }
//
//
//   void _applyAnalyticsDateFilter() {
//     List<CampaignRequest> filtered = List.from(_campaigns);
//
//
//     if (_selectedAnalyticsDateFilter == 'All') {
//       setState(() => _filteredCampaigns = filtered);
//       return;
//     }
//
//
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//
//
//     switch (_selectedAnalyticsDateFilter) {
//       case 'Today':
//         filtered = filtered.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.year == today.year && startDate.month == today.month && startDate.day == today.day;
//         }).toList();
//         break;
//       case 'Yesterday':
//         final yesterday = today.subtract(const Duration(days: 1));
//         filtered = filtered.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.year == yesterday.year && startDate.month == yesterday.month && startDate.day == yesterday.day;
//         }).toList();
//         break;
//       case 'This Week':
//         final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
//         filtered = filtered.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && startDate.isBefore(startOfWeek.add(const Duration(days: 7)));
//         }).toList();
//         break;
//       case 'This Month':
//         final startOfMonth = DateTime(today.year, today.month, 1);
//         final endOfMonth = DateTime(today.year, today.month + 1, 0);
//         filtered = filtered.where((c) {
//           final startDate = DateTime.parse(c.startDate);
//           return startDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) && startDate.isBefore(endOfMonth.add(const Duration(days: 1)));
//         }).toList();
//         break;
//     }
//     setState(() => _filteredCampaigns = filtered);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2));
//     }
//     if (_error != null) {
//       return _buildErrorState();
//     }
//
//
//     return Column(
//       children: [
//         // --- STICKY FILTER DROPDOWN (Always visible at top) ---
//         Container(
//           color: _cWhite,
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Container(
//                 width: 140,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: _cBorder),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _selectedAnalyticsDateFilter,
//                     isExpanded: true,
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     icon: const Icon(Icons.arrow_drop_down, color: _cAccent, size: 20),
//                     dropdownColor: _cWhite,
//                     style: const TextStyle(color: _cText1, fontSize: 13),
//                     items: _analyticsDateFilters.map((filter) {
//                       return DropdownMenuItem(
//                         value: filter,
//                         child: Text(filter, style: const TextStyle(fontSize: 13)),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() => _selectedAnalyticsDateFilter = value);
//                         _applyAnalyticsDateFilter();
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//
//         // --- SCROLLABLE CONTENT (Header + Cards + Campaigns) ---
//         Expanded(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//                   child: const Text(
//                     'CAMPAIGN PERFORMANCE',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _cText2,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                 ),
//
//
//                 // 4 Metric Cards
//                 if (_isLoadingAnalytics)
//                   const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2)),
//                   )
//                 else
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(child: _buildMetricCard('Total Reach', _totalReach, const Color(0xFF5E72E4))),
//                             const SizedBox(width: 12),
//                             Expanded(child: _buildMetricCard('Total Views', _totalViews, const Color(0xFF2DCE89))),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(child: _buildMetricCard('Total Clicks', _totalClicks, const Color(0xFFFB6340))),
//                             const SizedBox(width: 12),
//                             Expanded(child: _buildMetricCard('Total Leads', _totalLeads, const Color(0xFF8965E0))),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//
//                 // Campaigns List
//                 if (_filteredCampaigns.isEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(32.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: _cBg,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: _cBorder),
//                           ),
//                           child: const Icon(Icons.analytics_outlined, size: 36, color: _cText3),
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'No active or completed campaigns',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _cText1),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           'No campaigns found for $_selectedAnalyticsDateFilter',
//                           style: const TextStyle(fontSize: 13, color: _cText2),
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: _filteredCampaigns.length,
//                     itemBuilder: (_, i) => _buildAnalyticsCard(_filteredCampaigns[i], _gradients[i % _gradients.length]),
//                   ),
//
//
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Widget _buildMetricCard(String title, int value, Color color) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: const Duration(milliseconds: 800),
//       curve: Curves.easeOutQuad,
//       builder: (_, v, w) => Opacity(
//         opacity: v,
//         child: Transform.scale(scale: 0.9 + 0.1 * v, child: w),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _cWhite,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.15),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           border: Border.all(color: _cBorder.withOpacity(0.5), width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AnimatedCount(
//                 target: value,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: _cText1,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildAnalyticsCard(CampaignRequest campaign, List<Color> gradient) {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => CampaignDetailScreen(campaignId: campaign.id!),
//         ),
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradient,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: _cShadow,
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Hero(
//                     tag: 'campaign_${campaign.id}',
//                     child: Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: _cWhite, width: 3),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ClipOval(
//                         child: campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty
//                             ? Image.network(
//                           campaign.imageUrl!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => Container(
//                             color: Colors.grey[300],
//                             child: const Icon(Icons.broken_image, color: Colors.grey),
//                           ),
//                         )
//                             : Container(
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.image, color: Colors.grey),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           campaign.campaignName,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: _cText1,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         _buildChip(Icons.flag, campaign.goal),
//                         const SizedBox(height: 6),
//                         _buildChip(Icons.share, campaign.medium),
//                         if (campaign.discountPercentage != null && campaign.discountPercentage! > 0)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 6),
//                             child: _buildChip(
//                               Icons.local_offer,
//                               '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
//                             ),
//                           ),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Icon(Icons.calendar_today, size: 13, color: Colors.blueGrey[700]),
//                             const SizedBox(width: 5),
//                             Flexible(
//                               child: Text(
//                                 '${DateFormat.MMMd().format(DateTime.parse(campaign.startDate))} – ${DateFormat.MMMd().format(DateTime.parse(campaign.endDate))}',
//                                 style: TextStyle(fontSize: 12, color: Colors.blueGrey[800]),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, size: 15, color: Colors.blueGrey[400]),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 14,
//               right: 14,
//               child: _buildStatusChip(campaign.status ?? 'UNKNOWN'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildChip(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: _cWhite.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: Colors.blueGrey[700]),
//           const SizedBox(width: 5),
//           Flexible(
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildStatusChip(String status) {
//     Color bg, text;
//     IconData icon;
//     switch (status) {
//       case 'ACTIVE':
//         bg = Colors.green.shade50;
//         text = Colors.green.shade800;
//         icon = Icons.play_circle_filled;
//         break;
//       case 'COMPLETED':
//         bg = Colors.blue.shade50;
//         text = Colors.blue.shade800;
//         icon = Icons.check_circle;
//         break;
//       default:
//         bg = Colors.grey.shade200;
//         text = Colors.grey.shade800;
//         icon = Icons.help;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _cWhite.withOpacity(0.5)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: text),
//           const SizedBox(width: 5),
//           Text(
//             status,
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildErrorState() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
//         const SizedBox(height: 14),
//         Text(
//           'Error: $_error',
//           style: const TextStyle(fontSize: 14, color: _cText2),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 20),
//         GestureDetector(
//           onTap: _fetchData,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: _kGrad,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Text(
//               'Retry',
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
//
//
//
//
// // ─── Campaign Detail Screen (WITH Analytics & Coupon Support) ─────────────────
// class CampaignDetailScreen extends StatefulWidget {
//   final int campaignId;
//   const CampaignDetailScreen({super.key, required this.campaignId});
//   @override
//   State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
// }
//
// class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
//   CampaignRequest? _campaign;
//   CampaignAnalytics? _analytics;
//   bool _isLoading = true;
//   String? _error;
//
//   static const _cPrimAcc = Color(0xFF5E72E4);
//   static const _cSecAcc = Color(0xFF2DCE89);
//   static const _cOr = Color(0xFFFB6340);
//   static const _cRd = Color(0xFFF5365C);
//   static const _cPu = Color(0xFF8965E0);
//   static const _cBl = Color(0xFF11CDEF);
//   static const _cGr = Color(0xFF8898AA);
//
//   BoxDecoration get _glass => BoxDecoration(
//     borderRadius: BorderRadius.circular(24),
//     gradient: LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//       colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
//     ),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.08),
//         blurRadius: 20,
//         offset: const Offset(0, 8),
//       ),
//     ],
//     border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final campaigns = await PromotionAuthService.fetchUserCampaigns();
//       _campaign = campaigns.firstWhere((c) => c.id == widget.campaignId);
//       _analytics = await PromotionAuthService.fetchCampaignAnalytics(
//         widget.campaignId,
//       );
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: _cWhite,
//           title: const Text('Loading...', style: TextStyle(color: _cText1)),
//           elevation: 0,
//         ),
//         body: const Center(
//           child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
//         ),
//       );
//     }
//     if (_error != null || _campaign == null || _analytics == null) {
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: _cWhite,
//           title: const Text('Error', style: TextStyle(color: _cText1)),
//           elevation: 0,
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline_rounded,
//                 size: 48,
//                 color: Color(0xFFEF4444),
//               ),
//               const SizedBox(height: 14),
//               Text(
//                 'Error: ${_error ?? 'Campaign not found'}',
//                 style: const TextStyle(color: _cText2),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: _fetchData,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: _kGrad,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Text(
//                     'Retry',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     final campaign = _campaign!;
//
//     // Check if subGoal is "coupons" - if yes, show coupon analytics
//     if (campaign.subGoal?.toLowerCase() == 'coupons') {
//       return CouponAnalyticsScreen(
//         campaignId: widget.campaignId,
//         campaignName: campaign.campaignName,
//       );
//     }
//
//     final analytics = _analytics!;
//
//     // Regular analytics for non-coupon campaigns
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment.topLeft,
//             radius: 1.2,
//             colors: [Colors.grey.shade50, Colors.grey.shade200],
//           ),
//         ),
//         child: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               expandedHeight: 240,
//               pinned: true,
//               backgroundColor: _cWhite,
//               foregroundColor: _cWhite,
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Text(
//                   campaign.campaignName,
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     shadows: const [
//                       Shadow(color: Colors.black54, blurRadius: 8),
//                     ],
//                   ),
//                 ),
//                 background: Hero(
//                   tag: 'campaign_${campaign.id}',
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty
//                           ? Image.network(
//                               campaign.imageUrl!,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) =>
//                                   Container(color: Colors.grey[800]),
//                             )
//                           : Container(color: Colors.grey[800]),
//                       Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.transparent,
//                               Colors.black.withOpacity(0.8),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.fromLTRB(
//                 20,
//                 20,
//                 20,
//                 24 + MediaQuery.of(context).padding.bottom,
//               ),
//               sliver: SliverList(
//                 delegate: SliverChildListDelegate([
//                   _animCard(
//                     child: Container(
//                       decoration: _glass,
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _metaChip(
//                                     Icons.calendar_today,
//                                     'Start',
//                                     DateFormat.yMMMd().format(
//                                       DateTime.parse(campaign.startDate),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: _metaChip(
//                                     Icons.calendar_today,
//                                     'End',
//                                     DateFormat.yMMMd().format(
//                                       DateTime.parse(campaign.endDate),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 14),
//                             _metaChip(
//                               Icons.share,
//                               'Channels',
//                               campaign.medium,
//                               fullWidth: true,
//                             ),
//                             if (campaign.subGoal != null &&
//                                 campaign.subGoal!.isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 14),
//                                 child: _metaChip(
//                                   Icons.flag_outlined,
//                                   'Sub Goal',
//                                   campaign.subGoal!,
//                                   fullWidth: true,
//                                 ),
//                               ),
//                             if (campaign.discountPercentage != null &&
//                                 campaign.discountPercentage! > 0)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 14),
//                                 child: _metaChip(
//                                   Icons.local_offer,
//                                   'Discount',
//                                   '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
//                                   fullWidth: true,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   _sectionTitle(context, 'Performance'),
//                   const SizedBox(height: 14),
//                   _animCard(
//                     child: Container(
//                       decoration: _glass,
//                       padding: const EdgeInsets.all(20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           AnimatedCircularProgress(
//                             value: analytics.viewRate,
//                             label: 'View Rate',
//                             color: _cPrimAcc,
//                           ),
//                           AnimatedCircularProgress(
//                             value: analytics.likeRate,
//                             label: 'Like Rate',
//                             color: _cSecAcc,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 28),
//                   _sectionTitle(context, 'Key Metrics'),
//                   const SizedBox(height: 14),
//                   GridView.count(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 14,
//                     mainAxisSpacing: 14,
//                     childAspectRatio: 1.4,
//                     children: [
//                       _metricCard(
//                         'Total Views',
//                         analytics.totalViews,
//                         Icons.visibility,
//                         _cPrimAcc,
//                       ),
//                       _metricCard(
//                         'Unique Viewers',
//                         analytics.uniqueViewers,
//                         Icons.people,
//                         _cPu,
//                       ),
//                       _metricCard(
//                         'Total Likes',
//                         analytics.totalLikes,
//                         Icons.thumb_up,
//                         _cSecAcc,
//                       ),
//                       _metricCard(
//                         'Total Shares',
//                         analytics.totalShares,
//                         Icons.share,
//                         _cBl,
//                       ),
//                       _metricCard(
//                         'Dismissals',
//                         analytics.totalDismissals,
//                         Icons.cancel,
//                         _cRd,
//                       ),
//                       _metricCard(
//                         'Avg Duration',
//                         '${analytics.avgViewDuration.toStringAsFixed(1)}s',
//                         Icons.timer,
//                         _cOr,
//                         isNumber: false,
//                       ),
//                       _metricCard(
//                         'Avg Scroll',
//                         '${analytics.avgScrollDepth.toStringAsFixed(1)}%',
//                         Icons.swipe,
//                         _cPu,
//                         isNumber: false,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 28),
//                   _sectionTitle(context, 'Interaction Breakdown'),
//                   const SizedBox(height: 14),
//                   _animCard(
//                     child: Container(
//                       decoration: _glass,
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: analytics.interactionBreakdown.entries.map((
//                           entry,
//                         ) {
//                           final total = analytics.interactionBreakdown.values
//                               .fold(0, (s, v) => s + v);
//                           final pct = total > 0 ? entry.value / total : 0.0;
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Row(
//                               children: [
//                                 SizedBox(
//                                   width: 80,
//                                   child: Text(
//                                     entry.key[0].toUpperCase() +
//                                         entry.key.substring(1),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14,
//                                       color: Color(0xFF2D3748),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Stack(
//                                     children: [
//                                       Container(
//                                         height: 10,
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey.shade300,
//                                           borderRadius: BorderRadius.circular(
//                                             5,
//                                           ),
//                                         ),
//                                       ),
//                                       TweenAnimationBuilder<double>(
//                                         tween: Tween(begin: 0, end: pct),
//                                         duration: const Duration(
//                                           milliseconds: 1000,
//                                         ),
//                                         curve: Curves.easeOutQuad,
//                                         builder: (_, v, __) => Container(
//                                           height: 10,
//                                           width:
//                                               MediaQuery.of(
//                                                 context,
//                                               ).size.width *
//                                               0.5 *
//                                               v,
//                                           decoration: BoxDecoration(
//                                             color: _colorForKey(
//                                               entry.key,
//                                             ).withOpacity(0.8),
//                                             borderRadius: BorderRadius.circular(
//                                               5,
//                                             ),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: _colorForKey(
//                                                   entry.key,
//                                                 ).withOpacity(0.3),
//                                                 blurRadius: 4,
//                                                 offset: const Offset(0, 2),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   NumberFormat.compact().format(entry.value),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                     color: Color(0xFF2D3748),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   '(${(pct * 100).toStringAsFixed(1)}%)',
//                                   style: TextStyle(
//                                     color: Colors.grey.shade700,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _animCard({required Widget child}) => TweenAnimationBuilder<double>(
//     tween: Tween(begin: 0, end: 1),
//     duration: const Duration(milliseconds: 600),
//     curve: Curves.easeOutQuad,
//     builder: (_, v, w) => Opacity(
//       opacity: v,
//       child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: w),
//     ),
//     child: child,
//   );
//
//   Widget _sectionTitle(BuildContext ctx, String title) => Text(
//     title,
//     style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
//       fontWeight: FontWeight.bold,
//       color: const Color(0xFF1A202C),
//     ),
//   );
//
//   Widget _metaChip(
//     IconData icon,
//     String label,
//     String value, {
//     bool fullWidth = false,
//   }) => Container(
//     width: fullWidth ? double.infinity : null,
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(0.4),
//       borderRadius: BorderRadius.circular(40),
//       border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 8,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Row(
//       mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
//       children: [
//         Icon(icon, size: 16, color: const Color(0xFF4A5568)),
//         const SizedBox(width: 6),
//         Text(
//           '$label: ',
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//             color: Color(0xFF2D3748),
//           ),
//         ),
//         Flexible(
//           child: Text(
//             value,
//             style: const TextStyle(
//               color: Color(0xFF1A202C),
//               fontWeight: FontWeight.w500,
//               fontSize: 13,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _metricCard(
//     String label,
//     dynamic value,
//     IconData icon,
//     Color color, {
//     bool isNumber = true,
//   }) => TweenAnimationBuilder<double>(
//     tween: Tween(begin: 0, end: 1),
//     duration: const Duration(milliseconds: 800),
//     curve: Curves.easeOutQuad,
//     builder: (_, v, w) => Opacity(
//       opacity: v,
//       child: Transform.scale(scale: 0.9 + 0.1 * v, child: w),
//     ),
//     child: Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.9),
//             Colors.white.withOpacity(0.7),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.15),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//           BoxShadow(
//             color: Colors.white.withOpacity(0.5),
//             blurRadius: 4,
//             offset: const Offset(-2, -2),
//           ),
//         ],
//         border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 18, color: color),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: isNumber
//                       ? AnimatedCount(
//                           target: value,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: color,
//                           ),
//                         )
//                       : Text(
//                           value,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: color,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 5),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Color(0xFF718096),
//                 fontWeight: FontWeight.w500,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
//
//   Color _colorForKey(String key) {
//     switch (key) {
//       case 'click':
//         return _cPrimAcc;
//       case 'like':
//         return _cSecAcc;
//       case 'share':
//         return _cOr;
//       case 'dismiss':
//         return _cRd;
//       default:
//         return _cGr;
//     }
//   }
// }
//
// // ─── Custom Date Range Picker Dialog ─────────────────────────────────────────
// class CustomDateRangePicker extends StatefulWidget {
//   final DateTime? initialStartDate;
//   final DateTime? initialEndDate;
//   const CustomDateRangePicker({
//     super.key,
//     this.initialStartDate,
//     this.initialEndDate,
//   });
//
//   @override
//   State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
// }
//
// class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
//   DateTime? _startDate;
//   DateTime? _endDate;
//   final DateFormat _displayFormat = DateFormat('dd-MM-yyyy');
//   final TextEditingController _startController = TextEditingController();
//   final TextEditingController _endController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _startDate = widget.initialStartDate;
//     _endDate = widget.initialEndDate;
//     if (_startDate != null)
//       _startController.text = _displayFormat.format(_startDate!);
//     if (_endDate != null)
//       _endController.text = _displayFormat.format(_endDate!);
//   }
//
//   @override
//   void dispose() {
//     _startController.dispose();
//     _endController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectStartDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _startDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _startDate = picked;
//         _startController.text = _displayFormat.format(_startDate!);
//         if (_endDate != null && _endDate!.isBefore(_startDate!)) {
//           _endDate = _startDate;
//           _endController.text = _displayFormat.format(_endDate!);
//         }
//       });
//     }
//   }
//
//   Future<void> _selectEndDate() async {
//     if (_startDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select Start Date first')),
//       );
//       return;
//     }
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? _startDate!,
//       firstDate: _startDate!,
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _endDate = picked;
//         _endController.text = _displayFormat.format(_endDate!);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: const Text(
//         'Select Date Range',
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             readOnly: true,
//             onTap: _selectStartDate,
//             controller: _startController,
//             decoration: InputDecoration(
//               labelText: 'Start Date',
//               hintText: 'dd-mm-yyyy',
//               prefixIcon: const Icon(Icons.calendar_today, color: _cAccent),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: _cBorder),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: _cBorder),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: _cAccent, width: 2),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             readOnly: true,
//             onTap: _selectEndDate,
//             controller: _endController,
//             decoration: InputDecoration(
//               labelText: 'End Date',
//               hintText: 'dd-mm-yyyy',
//               prefixIcon: const Icon(Icons.calendar_today, color: _cAccent),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: _cBorder),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: _cBorder),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: _cAccent, width: 2),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel', style: TextStyle(color: _cGrey)),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_startDate != null && _endDate != null) {
//               Navigator.pop(
//                 context,
//                 DateTimeRange(start: _startDate!, end: _endDate!),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Please select both Start Date and End Date'),
//                 ),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _cAccent,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: const Text('Apply'),
//         ),
//       ],
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API/Apiclient.dart';
import '../CampaignModel/CampaignAnalytics.dart';
import '../CampaignModel/CampaignRequest.dart';
import '../CampaignModel/CouponStats.dart';
import '../CampaignService/Promotion_authservice.dart';
import 'create_promotion_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _cBg = Color(0xFFF8F9FC);
const _cWhite = Color(0xFFFFFFFF);
const _cBorder = Color(0xFFEEF0F6);
const _cText1 = Color(0xFF0F1535);
const _cText2 = Color(0xFF6B7280);
const _cText3 = Color(0xFFB8BBC8);
const _cShadow = Color(0x0D000000);

const _cPrimary = Color(0xFF5E72E4);
const _cGreen = Color(0xFF2DCE89);
const _cOrange = Color(0xFFFB6340);
const _cRed = Color(0xFFF5365C);
const _cPurple = Color(0xFF8965E0);
const _cBlue = Color(0xFF11CDEF);
const _cGrey = Color(0xFF8898AA);
const _cAccent = Color(0xFFFF5722);

const _kGrad = LinearGradient(
  colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Shared Widgets ───────────────────────────────────────────────────────────

/// Standard back button used in all custom app bars.
Widget _backBtn(BuildContext context) => GestureDetector(
  onTap: () => Navigator.pop(context),
  child: Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: _cBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _cBorder),
      boxShadow: [
        BoxShadow(color: _cShadow, blurRadius: 6, offset: const Offset(0, 2)),
      ],
    ),
    child: const Icon(
      Icons.arrow_back_ios_new_rounded,
      size: 15,
      color: _cText1,
    ),
  ),
);

/// Divider below custom headers.
PreferredSizeWidget _headerDivider() => PreferredSize(
  preferredSize: const Size.fromHeight(1),
  child: Container(height: 1, color: _cBorder),
);

// ─── Animated Circular Progress ──────────────────────────────────────────────
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
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCircularProgress old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.forward(from: 0);
      _anim = Tween<double>(
        begin: 0,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _CircleProgressPainter(
                progress: _anim.value,
                backgroundColor: Colors.grey.shade200,
                progressColor: widget.color,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    NumberFormat.percentPattern().format(_anim.value),
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
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor, progressColor;
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
  bool shouldRepaint(covariant _CircleProgressPainter old) =>
      old.progress != progress;
}

// ─── Animated Count ───────────────────────────────────────────────────────────
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
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _display = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.target.toDouble()).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad),
    )..addListener(() => setState(() => _display = _anim.value.round()));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCount old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _ctrl.forward(from: 0);
      _anim = Tween<double>(
        begin: 0,
        end: widget.target.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
    NumberFormat.compact().format(_display),
    style:
        widget.style ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// SIMPLE CAMPAIGN DETAIL SCREEN
// ════════════════════════════════════════════════════════════════════════════
class SimpleCampaignDetailScreen extends StatelessWidget {
  final CampaignRequest campaign;
  const SimpleCampaignDetailScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _cBg,
        // ── Custom App Bar (SafeArea handled by Scaffold + AppBar) ──
        appBar: AppBar(
          backgroundColor: _cWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(child: _backBtn(context)),
          ),
          title: Text(
            campaign.campaignName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _cText1,
              letterSpacing: -0.3,
            ),
          ),
          bottom: _headerDivider(),
        ),
        body: SafeArea(
          top: false, // AppBar already handles top safe area
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Image ──
                if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      campaign.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: _cBorder,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: _cText3,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // ── Info Card ──
                _InfoCard(campaign: campaign),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CampaignRequest campaign;
  const _InfoCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(
            color: _cShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _cAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'CAMPAIGN INFORMATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _cAccent,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _infoRow(
              Icons.numbers,
              'Campaign ID',
              campaign.id?.toString() ?? 'N/A',
            ),
            _divider(),
            _infoRow(Icons.title, 'Campaign Name', campaign.campaignName),
            _divider(),
            _infoRow(Icons.flag, 'Goal', campaign.goal),
            if (campaign.subGoal != null && campaign.subGoal!.isNotEmpty) ...[
              _divider(),
              _infoRow(Icons.flag_outlined, 'Sub Goal', campaign.subGoal!),
            ],
            _divider(),
            _infoRow(
              Icons.calendar_today,
              'Start Date',
              DateFormat.yMMMd().format(DateTime.parse(campaign.startDate)),
            ),
            _divider(),
            _infoRow(
              Icons.calendar_today,
              'End Date',
              DateFormat.yMMMd().format(DateTime.parse(campaign.endDate)),
            ),
            _divider(),
            _infoRow(
              Icons.attach_money,
              'Total Budget',
              campaign.totalBudget != null
                  ? '₹${campaign.totalBudget!.toStringAsFixed(2)}'
                  : 'Not specified',
            ),
            if (campaign.discountPercentage != null &&
                campaign.discountPercentage! > 0) ...[
              _divider(),
              _infoRow(
                Icons.local_offer,
                'Discount',
                '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
              ),
            ],
            _divider(),
            _infoRowWithStatus(
              Icons.campaign,
              'Campaign Status',
              campaign.status ?? 'Unknown',
            ),
            _divider(),
            _infoRowWithStatus(
              Icons.payment,
              'Payment Status',
              campaign.paymentStatus ?? 'Pending',
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: _cBorder, indent: 32, endIndent: 0);

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _cAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _cAccent),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _cText2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _cText1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWithStatus(IconData icon, String label, String status) {
    Color statusColor;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        statusColor = _cGreen;
        break;
      case 'COMPLETED':
        statusColor = _cBlue;
        break;
      case 'PENDING':
        statusColor = _cOrange;
        break;
      case 'PAID':
        statusColor = _cGreen;
        break;
      case 'UNPAID':
        statusColor = _cRed;
        break;
      default:
        statusColor = _cGrey;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _cAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _cAccent),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _cText2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COUPON ANALYTICS SCREEN
// ════════════════════════════════════════════════════════════════════════════
class CouponAnalyticsScreen extends StatefulWidget {
  final int campaignId;
  final String campaignName;
  const CouponAnalyticsScreen({
    super.key,
    required this.campaignId,
    required this.campaignName,
  });
  @override
  State<CouponAnalyticsScreen> createState() => _CouponAnalyticsScreenState();
}

class _CouponAnalyticsScreenState extends State<CouponAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _cBg,
        appBar: AppBar(
          backgroundColor: _cWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(child: _backBtn(context)),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.campaignName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _cText1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Coupon Analytics',
                style: TextStyle(fontSize: 11, color: _cText2),
              ),
            ],
          ),
          bottom: _headerDivider(),
        ),
        body: SafeArea(
          top: false,
          child: FutureBuilder<CouponStats>(
            future: PromotionAuthService.fetchCouponStats(widget.campaignId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: _cAccent,
                    strokeWidth: 2,
                  ),
                );
              }
              if (snapshot.hasError) {
                return _CouponErrorState(
                  error: snapshot.error.toString(),
                  onRetry: () => setState(() {}),
                );
              }
              if (!snapshot.hasData || snapshot.data!.users.isEmpty) {
                return const _CouponEmptyState();
              }

              final stats = snapshot.data!;
              return _CouponBody(stats: stats);
            },
          ),
        ),
      ),
    );
  }
}

class _CouponErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _CouponErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _cRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: _cRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(fontSize: 14, color: _cText2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _PrimaryButton(label: 'Retry', onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _CouponEmptyState extends StatelessWidget {
  const _CouponEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _cBg,
              shape: BoxShape.circle,
              border: Border.all(color: _cBorder),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 36,
              color: _cText3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No coupon usage yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _cText1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Users haven't used coupons for this campaign",
            style: TextStyle(fontSize: 13, color: _cText2),
          ),
        ],
      ),
    );
  }
}

class _CouponBody extends StatelessWidget {
  final CouponStats stats;
  const _CouponBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Summary row
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Users',
                value: stats.totalUsers.toString(),
                icon: Icons.people_alt_rounded,
                color: _cPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Discount',
                value: '₹${stats.totalDiscount.toStringAsFixed(2)}',
                icon: Icons.discount_rounded,
                color: _cGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Section label
        const _SectionLabel(text: 'COUPON USERS'),
        const SizedBox(height: 12),
        ...stats.users.map((u) => _UserCard(user: u)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(
            color: _cShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: _cText2)),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final CouponUser user;
  const _UserCard({required this.user});

  String _formatName(String name) {
    if (name.isEmpty) return '';
    return name
        .toLowerCase()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _cAccent.withOpacity(0.8),
                        _cAccent.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatName(user.userName),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _cText1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: _kGrad,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _cAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '₹${user.discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: _cBorder, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _DetailChip(Icons.code, 'Code: ${user.code}')),
                const SizedBox(width: 6),
                Expanded(
                  child: _DetailChip(
                    user.couponType == 'FLAT'
                        ? Icons.attach_money
                        : Icons.percent,
                    user.couponType,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _DetailChip(
                    user.discountType == 'PERCENTAGE'
                        ? Icons.percent
                        : Icons.attach_money,
                    user.discountType,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _cBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _cAccent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: _cText2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CAMPAIGN LIST SCREEN
// ════════════════════════════════════════════════════════════════════════════
class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});
  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<CampaignRequest> _campaigns = [];
  List<CampaignRequest> _filteredCampaigns = [];
  bool _isLoadingCampaigns = true;
  String? _campaignsError;

  String _selectedDateFilter = 'All Time';
  String _selectedGoalFilter = 'All Goals';
  DateTimeRange? _customDateRange;

  final List<String> _dateFilters = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Custom',
    'All Time',
  ];
  final List<String> _goalFilters = [
    'All Goals',
    'BRANDING',
    'DISCOUNT',
    'LEADS',
  ];

  static final _gradients = [
    [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
    [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
    [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
    [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
    [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _fetchCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCampaigns() async {
    setState(() {
      _isLoadingCampaigns = true;
      _campaignsError = null;
    });
    try {
      final campaigns = await PromotionAuthService.fetchUserCampaigns();
      setState(() {
        _campaigns = campaigns;
        _filteredCampaigns = campaigns;
        _isLoadingCampaigns = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _campaignsError = e.toString();
        _isLoadingCampaigns = false;
      });
    }
  }

  void _applyFilters() {
    List<CampaignRequest> filtered = List.from(_campaigns);
    filtered = _applyDateFilter(filtered);
    if (_selectedGoalFilter != 'All Goals') {
      filtered = filtered
          .where((c) => c.goal.toUpperCase() == _selectedGoalFilter)
          .toList();
    }
    setState(() => _filteredCampaigns = filtered);
  }

  List<CampaignRequest> _applyDateFilter(List<CampaignRequest> campaigns) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedDateFilter) {
      case 'Today':
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        }).toList();
      case 'Yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.year == yesterday.year &&
              d.month == yesterday.month &&
              d.day == yesterday.day;
        }).toList();
      case 'This Week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              d.isBefore(startOfWeek.add(const Duration(days: 7)));
        }).toList();
      case 'This Month':
        final startOfMonth = DateTime(today.year, today.month, 1);
        final endOfMonth = DateTime(today.year, today.month + 1, 0);
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              d.isBefore(endOfMonth.add(const Duration(days: 1)));
        }).toList();
      case 'Custom':
        if (_customDateRange != null) {
          return campaigns.where((c) {
            final d = DateTime.parse(c.startDate);
            return d.isAfter(
                  _customDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                d.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
          }).toList();
        }
        return campaigns;
      default:
        return campaigns;
    }
  }

  Future<void> _showCustomDatePicker() async {
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => CustomDateRangePicker(
        initialStartDate: _customDateRange?.start,
        initialEndDate: _customDateRange?.end,
      ),
    );
    if (result != null) {
      setState(() {
        _customDateRange = result;
        _selectedDateFilter = 'Custom';
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _cBg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Custom App Bar with Chip-style Tabs (matching FinanceScreen) ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: _cWhite,
                  border: Border(bottom: BorderSide(color: _cBorder)),
                ),
                child: Row(
                  children: [
                    // Back button
                    if (Navigator.of(context).canPop())
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _cBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _cBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 15,
                            color: _cText1,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),

                    // Scrollable tab chips
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildTabChip(label: 'CAMPAIGNS', index: 0),
                            const SizedBox(width: 6),
                            _buildTabChip(label: 'ANALYTICS', index: 1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _CampaignsTabContent(), // Extracted to StatefulWidget
                    CampaignAnalyticsListScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab chip builder - EXACT logic from FinanceScreen
  Widget _buildTabChip({required String label, required int index}) {
    final isActive = _tabController.index == index;

    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors
                    .green // 🟢 selected (like FinanceScreen)
              : const Color(0xFFE66D33), // 🟧 default/orange
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white, // ⚪ always white (like FinanceScreen)
          ),
        ),
      ),
    );
  }
}

// Extracted to separate widget to maintain state properly
class _CampaignsTabContent extends StatefulWidget {
  const _CampaignsTabContent();

  @override
  State<_CampaignsTabContent> createState() => _CampaignsTabContentState();
}

class _CampaignsTabContentState extends State<_CampaignsTabContent> {
  List<CampaignRequest> _campaigns = [];
  List<CampaignRequest> _filteredCampaigns = [];
  bool _isLoading = true;
  String? _error;

  String _selectedDateFilter = 'All Time';
  String _selectedGoalFilter = 'All Goals';
  DateTimeRange? _customDateRange;

  final List<String> _dateFilters = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Custom',
    'All Time',
  ];
  final List<String> _goalFilters = [
    'All Goals',
    'BRANDING',
    'DISCOUNT',
    'LEADS',
  ];

  static final _gradients = [
    [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
    [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
    [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
    [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
    [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)],
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
      setState(() {
        _campaigns = campaigns;
        _filteredCampaigns = campaigns;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<CampaignRequest> filtered = List.from(_campaigns);
    filtered = _applyDateFilter(filtered);
    if (_selectedGoalFilter != 'All Goals') {
      filtered = filtered
          .where((c) => c.goal.toUpperCase() == _selectedGoalFilter)
          .toList();
    }
    setState(() => _filteredCampaigns = filtered);
  }

  List<CampaignRequest> _applyDateFilter(List<CampaignRequest> campaigns) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedDateFilter) {
      case 'Today':
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        }).toList();
      case 'Yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.year == yesterday.year &&
              d.month == yesterday.month &&
              d.day == yesterday.day;
        }).toList();
      case 'This Week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              d.isBefore(startOfWeek.add(const Duration(days: 7)));
        }).toList();
      case 'This Month':
        final startOfMonth = DateTime(today.year, today.month, 1);
        final endOfMonth = DateTime(today.year, today.month + 1, 0);
        return campaigns.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              d.isBefore(endOfMonth.add(const Duration(days: 1)));
        }).toList();
      case 'Custom':
        if (_customDateRange != null) {
          return campaigns.where((c) {
            final d = DateTime.parse(c.startDate);
            return d.isAfter(
                  _customDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                d.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
          }).toList();
        }
        return campaigns;
      default:
        return campaigns;
    }
  }

  Future<void> _showCustomDatePicker() async {
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => CustomDateRangePicker(
        initialStartDate: _customDateRange?.start,
        initialEndDate: _customDateRange?.end,
      ),
    );
    if (result != null) {
      setState(() {
        _customDateRange = result;
        _selectedDateFilter = 'Custom';
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Filter Bar
        Container(
          color: _cWhite,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: _DropdownFilter(
                  value: _selectedDateFilter,
                  items: _dateFilters,
                  onChanged: (v) {
                    if (v == 'Custom') {
                      _showCustomDatePicker();
                    } else {
                      setState(() {
                        _selectedDateFilter = v!;
                        _customDateRange = null;
                      });
                      _applyFilters();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownFilter(
                  value: _selectedGoalFilter,
                  items: _goalFilters,
                  onChanged: (v) {
                    setState(() => _selectedGoalFilter = v!);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _cBorder),

        // Campaign List
        Expanded(
          child: _filteredCampaigns.isEmpty
              ? _buildNoResultsState()
              : RefreshIndicator(
                  color: _cAccent,
                  onRefresh: _fetchCampaigns,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: _filteredCampaigns.length,
                    itemBuilder: (_, i) => _buildCampaignCard(
                      _filteredCampaigns[i],
                      _gradients[i % _gradients.length],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCampaignCard(CampaignRequest campaign, List<Color> gradient) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SimpleCampaignDetailScreen(campaign: campaign),
        ),
      ),
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
              color: _cShadow,
              blurRadius: 14,
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
                    child: _CampaignAvatar(imageUrl: campaign.imageUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.campaignName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _cText1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MiniChip(Icons.flag, campaign.goal),
                        const SizedBox(height: 5),
                        _MiniChip(Icons.share, campaign.medium),
                        if (campaign.discountPercentage != null &&
                            campaign.discountPercentage! > 0) ...[
                          const SizedBox(height: 5),
                          _MiniChip(
                            Icons.local_offer,
                            '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.blueGrey[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${DateFormat.MMMd().format(DateTime.parse(campaign.startDate))} – ${DateFormat.MMMd().format(DateTime.parse(campaign.endDate))}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.blueGrey[300],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _StatusChip(status: campaign.status ?? 'UNKNOWN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _cBg,
              shape: BoxShape.circle,
              border: Border.all(color: _cBorder),
            ),
            child: const Icon(Icons.filter_alt_off, size: 32, color: _cText3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No campaigns match the filters',
            style: TextStyle(fontSize: 14, color: _cText2),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            label: 'Clear Filters',
            onTap: () {
              setState(() {
                _selectedDateFilter = 'All Time';
                _selectedGoalFilter = 'All Goals';
                _customDateRange = null;
              });
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _cRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: _cRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(fontSize: 14, color: _cText2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _PrimaryButton(label: 'Retry', onTap: _fetchCampaigns),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CAMPAIGN ANALYTICS LIST SCREEN
// ════════════════════════════════════════════════════════════════════════════
class CampaignAnalyticsListScreen extends StatefulWidget {
  const CampaignAnalyticsListScreen({super.key});
  @override
  State<CampaignAnalyticsListScreen> createState() =>
      _CampaignAnalyticsListScreenState();
}

class _CampaignAnalyticsListScreenState
    extends State<CampaignAnalyticsListScreen> {
  List<CampaignRequest> _campaigns = [];
  List<CampaignRequest> _filteredCampaigns = [];
  bool _isLoading = true;
  bool _isLoadingAnalytics = true;
  String? _error;

  int _totalReach = 0;
  int _totalViews = 0;
  int _totalClicks = 0;
  int _totalLeads = 0;

  String _selectedAnalyticsDateFilter = 'All';
  final List<String> _analyticsDateFilters = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'All',
  ];

  static final _gradients = [
    [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
    [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
    [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
    [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
    [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)],
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _isLoadingAnalytics = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        PromotionAuthService.fetchUserCampaigns(),
        PromotionAuthService.fetchCustomerCampaignAnalytics(),
      ]);

      final campaigns = results[0] as List<CampaignRequest>;
      final analytics = results[1] as Map<String, dynamic>;

      _totalReach = analytics['totalReach'] ?? 0;
      _totalViews = analytics['totalViews'] ?? 0;
      _totalClicks = analytics['totalClicks'] ?? 0;
      _totalLeads = analytics['totalLeads'] ?? 0;

      final filtered = campaigns
          .where((c) => c.status == 'ACTIVE' || c.status == 'COMPLETED')
          .toList();
      filtered.sort((a, b) {
        int p(String? s) {
          if (s == 'ACTIVE') return 0;
          if (s == 'COMPLETED') return 1;
          return 2;
        }

        return p(a.status).compareTo(p(b.status));
      });

      setState(() {
        _campaigns = filtered;
        _filteredCampaigns = filtered;
        _isLoading = false;
        _isLoadingAnalytics = false;
      });
      _applyAnalyticsDateFilter();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingAnalytics = false;
      });
    }
  }

  void _applyAnalyticsDateFilter() {
    List<CampaignRequest> filtered = List.from(_campaigns);
    if (_selectedAnalyticsDateFilter == 'All') {
      setState(() => _filteredCampaigns = filtered);
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedAnalyticsDateFilter) {
      case 'Today':
        filtered = filtered.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        }).toList();
        break;
      case 'Yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        filtered = filtered.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.year == yesterday.year &&
              d.month == yesterday.month &&
              d.day == yesterday.day;
        }).toList();
        break;
      case 'This Week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        filtered = filtered.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              d.isBefore(startOfWeek.add(const Duration(days: 7)));
        }).toList();
        break;
      case 'This Month':
        final startOfMonth = DateTime(today.year, today.month, 1);
        final endOfMonth = DateTime(today.year, today.month + 1, 0);
        filtered = filtered.where((c) {
          final d = DateTime.parse(c.startDate);
          return d.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              d.isBefore(endOfMonth.add(const Duration(days: 1)));
        }).toList();
        break;
    }
    setState(() => _filteredCampaigns = filtered);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _cRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: _cRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(fontSize: 14, color: _cText2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _PrimaryButton(label: 'Retry', onTap: _fetchData),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── Sticky Filter ──
        Container(
          color: _cWhite,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: _DropdownFilter(
                  value: _selectedAnalyticsDateFilter,
                  items: _analyticsDateFilters,
                  onChanged: (v) {
                    setState(() => _selectedAnalyticsDateFilter = v!);
                    _applyAnalyticsDateFilter();
                  },
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _cBorder),

        // ── Scrollable body ──
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label
                const _SectionLabel(text: 'CAMPAIGN PERFORMANCE'),
                const SizedBox(height: 14),

                // Metric cards
                if (_isLoadingAnalytics)
                  const Center(
                    child: CircularProgressIndicator(
                      color: _cAccent,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Reach',
                          value: _totalReach,
                          color: _cPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Views',
                          value: _totalViews,
                          color: _cGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Clicks',
                          value: _totalClicks,
                          color: _cOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Leads',
                          value: _totalLeads,
                          color: _cPurple,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Campaign cards
                if (_filteredCampaigns.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _cBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: _cBorder),
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              size: 32,
                              color: _cText3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No active or completed campaigns',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _cText1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No campaigns for $_selectedAnalyticsDateFilter',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _cText2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    _filteredCampaigns.length,
                    (i) => _buildAnalyticsCard(
                      _filteredCampaigns[i],
                      _gradients[i % _gradients.length],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(CampaignRequest campaign, List<Color> gradient) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CampaignDetailScreen(campaignId: campaign.id!),
        ),
      ),
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
              color: _cShadow,
              blurRadius: 14,
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
                    child: _CampaignAvatar(imageUrl: campaign.imageUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.campaignName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _cText1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MiniChip(Icons.flag, campaign.goal),
                        const SizedBox(height: 5),
                        _MiniChip(Icons.share, campaign.medium),
                        if (campaign.discountPercentage != null &&
                            campaign.discountPercentage! > 0) ...[
                          const SizedBox(height: 5),
                          _MiniChip(
                            Icons.local_offer,
                            '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.blueGrey[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${DateFormat.MMMd().format(DateTime.parse(campaign.startDate))} – ${DateFormat.MMMd().format(DateTime.parse(campaign.endDate))}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.blueGrey[300],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _StatusChip(status: campaign.status ?? 'UNKNOWN'),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CAMPAIGN DETAIL SCREEN (With Analytics & Coupon Support)
// ════════════════════════════════════════════════════════════════════════════
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

  static const _cPrimAcc = Color(0xFF5E72E4);
  static const _cSecAcc = Color(0xFF2DCE89);
  static const _cOr = Color(0xFFFB6340);
  static const _cRd = Color(0xFFF5365C);
  static const _cPu = Color(0xFF8965E0);
  static const _cBl = Color(0xFF11CDEF);
  static const _cGr = Color(0xFF8898AA);

  BoxDecoration get _glass => BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.white.withOpacity(0.85),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.07),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
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
      _campaign = campaigns.firstWhere((c) => c.id == widget.campaignId);
      _analytics = await PromotionAuthService.fetchCampaignAnalytics(
        widget.campaignId,
      );
      setState(() => _isLoading = false);
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
        backgroundColor: _cBg,
        appBar: AppBar(
          backgroundColor: _cWhite,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(child: _backBtn(context)),
          ),
          title: const Text(
            'Loading...',
            style: TextStyle(color: _cText1, fontSize: 17),
          ),
          bottom: _headerDivider(),
        ),
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null || _campaign == null || _analytics == null) {
      return Scaffold(
        backgroundColor: _cBg,
        appBar: AppBar(
          backgroundColor: _cWhite,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(child: _backBtn(context)),
          ),
          title: const Text(
            'Error',
            style: TextStyle(color: _cText1, fontSize: 17),
          ),
          bottom: _headerDivider(),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _cRd.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 36,
                      color: _cRd,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${_error ?? 'Campaign not found'}',
                    style: const TextStyle(color: _cText2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _PrimaryButton(label: 'Retry', onTap: _fetchData),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final campaign = _campaign!;

    // If subGoal is coupons → route to coupon analytics
    if (campaign.subGoal?.toLowerCase() == 'coupons') {
      return CouponAnalyticsScreen(
        campaignId: widget.campaignId,
        campaignName: campaign.campaignName,
      );
    }

    final analytics = _analytics!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [Color(0xFFF0F2F5), Color(0xFFE4E7EE)],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              // ── Hero SliverAppBar ──
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: _cWhite,
                foregroundColor: Colors.white,
                // SafeArea handled by SliverAppBar's built-in padding
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                  child: _backBtn(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    campaign.campaignName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                  background: Hero(
                    tag: 'campaign_${campaign.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        campaign.imageUrl != null &&
                                campaign.imageUrl!.isNotEmpty
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
                                Colors.black.withOpacity(0.75),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Detail Body ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Meta card
                    _animCard(
                      child: Container(
                        decoration: _glass,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _metaChip(
                                    Icons.calendar_today,
                                    'Start',
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(campaign.startDate),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _metaChip(
                                    Icons.calendar_today,
                                    'End',
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(campaign.endDate),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _metaChip(
                              Icons.share,
                              'Channels',
                              campaign.medium,
                              fullWidth: true,
                            ),
                            if (campaign.subGoal != null &&
                                campaign.subGoal!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _metaChip(
                                Icons.flag_outlined,
                                'Sub Goal',
                                campaign.subGoal!,
                                fullWidth: true,
                              ),
                            ],
                            if (campaign.discountPercentage != null &&
                                campaign.discountPercentage! > 0) ...[
                              const SizedBox(height: 12),
                              _metaChip(
                                Icons.local_offer,
                                'Discount',
                                '${campaign.discountPercentage!.toStringAsFixed(0)}% OFF',
                                fullWidth: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(context, 'Performance'),
                    const SizedBox(height: 14),

                    // Performance circles
                    _animCard(
                      child: Container(
                        decoration: _glass,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AnimatedCircularProgress(
                              value: analytics.viewRate,
                              label: 'View Rate',
                              color: _cPrimAcc,
                            ),
                            AnimatedCircularProgress(
                              value: analytics.likeRate,
                              label: 'Like Rate',
                              color: _cSecAcc,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _sectionTitle(context, 'Key Metrics'),
                    const SizedBox(height: 14),

                    // Metrics grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.4,
                      children: [
                        _metricCard(
                          'Total Views',
                          analytics.totalViews,
                          Icons.visibility,
                          _cPrimAcc,
                        ),
                        _metricCard(
                          'Unique Viewers',
                          analytics.uniqueViewers,
                          Icons.people,
                          _cPu,
                        ),
                        _metricCard(
                          'Total Likes',
                          analytics.totalLikes,
                          Icons.thumb_up,
                          _cSecAcc,
                        ),
                        _metricCard(
                          'Total Shares',
                          analytics.totalShares,
                          Icons.share,
                          _cBl,
                        ),
                        _metricCard(
                          'Dismissals',
                          analytics.totalDismissals,
                          Icons.cancel,
                          _cRd,
                        ),
                        _metricCard(
                          'Avg Duration',
                          '${analytics.avgViewDuration.toStringAsFixed(1)}s',
                          Icons.timer,
                          _cOr,
                          isNumber: false,
                        ),
                        _metricCard(
                          'Avg Scroll',
                          '${analytics.avgScrollDepth.toStringAsFixed(1)}%',
                          Icons.swipe,
                          _cPu,
                          isNumber: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _sectionTitle(context, 'Interaction Breakdown'),
                    const SizedBox(height: 14),

                    // Breakdown bars
                    _animCard(
                      child: Container(
                        decoration: _glass,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: analytics.interactionBreakdown.entries.map((
                            e,
                          ) {
                            final total = analytics.interactionBreakdown.values
                                .fold(0, (s, v) => s + v);
                            final pct = total > 0 ? e.value / total : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      e.key[0].toUpperCase() +
                                          e.key.substring(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: _cText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0, end: pct),
                                          duration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          curve: Curves.easeOutQuad,
                                          builder: (_, v, __) => Container(
                                            height: 10,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.5 *
                                                v,
                                            decoration: BoxDecoration(
                                              color: _colorForKey(
                                                e.key,
                                              ).withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    NumberFormat.compact().format(e.value),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _cText1,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${(pct * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      color: _cText2,
                                      fontSize: 11,
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
      ),
    );
  }

  Widget _animCard({required Widget child}) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeOutQuad,
    builder: (_, v, w) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: w),
    ),
    child: child,
  );

  Widget _sectionTitle(BuildContext ctx, String title) => Text(
    title,
    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: _cText1,
    ),
  );

  Widget _metaChip(
    IconData icon,
    String label,
    String value, {
    bool fullWidth = false,
  }) => Container(
    width: fullWidth ? double.infinity : null,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
    ),
    child: Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _cText2),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: _cText2,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: _cText1,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _metricCard(
    String label,
    dynamic value,
    IconData icon,
    Color color, {
    bool isNumber = true,
  }) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOutQuad,
    builder: (_, v, w) => Opacity(
      opacity: v,
      child: Transform.scale(scale: 0.9 + 0.1 * v, child: w),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.85),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: isNumber
                    ? AnimatedCount(
                        target: value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: _cText2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  Color _colorForKey(String key) {
    switch (key) {
      case 'click':
        return _cPrimAcc;
      case 'like':
        return _cSecAcc;
      case 'share':
        return _cOr;
      case 'dismiss':
        return _cRd;
      default:
        return _cGr;
    }
  }
}

// ─── Shared Small Widgets ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _cAccent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cAccent.withOpacity(0.15)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _cAccent,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuad,
      builder: (_, v, w) => Opacity(
        opacity: v,
        child: Transform.scale(scale: 0.9 + 0.1 * v, child: w),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _cWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _cBorder),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCount(
              target: value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _cText1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _cWhite.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blueGrey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    IconData icon;
    switch (status) {
      case 'ACTIVE':
        bg = Colors.green.shade50;
        text = Colors.green.shade800;
        icon = Icons.play_circle_filled;
        break;
      case 'COMPLETED':
        bg = Colors.blue.shade50;
        text = Colors.blue.shade800;
        icon = Icons.check_circle;
        break;
      default:
        bg = Colors.grey.shade200;
        text = Colors.grey.shade800;
        icon = Icons.help;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignAvatar extends StatelessWidget {
  final String? imageUrl;
  const _CampaignAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _cWhite, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cWhite,
        border: Border.all(color: _cBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _cAccent,
            size: 20,
          ),
          dropdownColor: _cWhite,
          style: const TextStyle(
            color: _cText1,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        decoration: BoxDecoration(
          gradient: _kGrad,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _cAccent.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CUSTOM DATE RANGE PICKER DIALOG  (unchanged functionality)
// ════════════════════════════════════════════════════════════════════════════
class CustomDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  const CustomDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });
  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _displayFormat = DateFormat('dd-MM-yyyy');
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    if (_startDate != null)
      _startController.text = _displayFormat.format(_startDate!);
    if (_endDate != null)
      _endController.text = _displayFormat.format(_endDate!);
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startController.text = _displayFormat.format(_startDate!);
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
          _endController.text = _displayFormat.format(_endDate!);
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Start Date first')),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endController.text = _displayFormat.format(_endDate!);
      });
    }
  }

  InputDecoration _fieldDecor(String label) => InputDecoration(
    labelText: label,
    hintText: 'dd-mm-yyyy',
    prefixIcon: const Icon(Icons.calendar_today, color: _cAccent, size: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _cBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _cBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _cAccent, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _cWhite,
      title: const Text(
        'Select Date Range',
        style: TextStyle(fontWeight: FontWeight.bold, color: _cText1),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            readOnly: true,
            onTap: _selectStartDate,
            controller: _startController,
            decoration: _fieldDecor('Start Date'),
          ),
          const SizedBox(height: 14),
          TextField(
            readOnly: true,
            onTap: _selectEndDate,
            controller: _endController,
            decoration: _fieldDecor('End Date'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: _cGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startDate != null && _endDate != null) {
              Navigator.pop(
                context,
                DateTimeRange(start: _startDate!, end: _endDate!),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both Start Date and End Date'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _cAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Apply',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
