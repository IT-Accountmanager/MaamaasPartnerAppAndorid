// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
//
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
//
// import '../Api/food_authservice.dart';
// import '../Models/food&beverages/ticket_model.dart';
//
// class TicketListScreen extends StatefulWidget {
//   final int userId;
//
//   const TicketListScreen({Key? key, required this.userId}) : super(key: key);
//
//   @override
//   _TicketListScreenState createState() => _TicketListScreenState();
// }
//
// class _TicketListScreenState extends State<TicketListScreen> {
//   late Future<List<Ticket>> _futureTickets;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureTickets = food_authservice.fetchTicketsByUser();
//   }
//
//   Future<void> _refreshTickets() async {
//     setState(() {
//       _futureTickets = food_authservice.fetchTicketsByUser();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           "My Tickets",
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header Stats
//             _buildHeaderStats(),
//             // Tickets List
//             Expanded(
//               child: FutureBuilder<List<Ticket>>(
//                 future: _futureTickets,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return _buildLoadingState();
//                   } else if (snapshot.hasError) {
//                     return _buildErrorState();
//                   }
//
//                   final tickets = (snapshot.data ?? []).reversed.toList();
//
//                   if (tickets.isEmpty) {
//                     return _buildEmptyState();
//                   }
//
//                   return RefreshIndicator(
//                     onRefresh: _refreshTickets,
//                     backgroundColor: Colors.white,
//                     color: Color(0xFF6C63FF),
//                     child: ListView.separated(
//                       padding: EdgeInsets.all(16.w),
//                       itemCount: tickets.length,
//                       separatorBuilder: (context, index) =>
//                           SizedBox(height: 12.h),
//                       itemBuilder: (context, index) {
//                         final ticket = tickets[index];
//                         return _buildTicketCard(context, ticket);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(0xFFFF6B35),
//         child: Icon(Icons.add, size: 28.sp, color: Colors.white),
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => CreateTicketScreen()),
//           );
//           if (result == true) {
//             _refreshTickets();
//           }
//         },
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderStats() {
//     return FutureBuilder<List<Ticket>>(
//       future: _futureTickets,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return SizedBox();
//         }
//
//         final tickets = snapshot.data ?? [];
//         final openTickets = tickets.where((t) => t.status == 'OPEN').length;
//         final inProgressTickets = tickets
//             .where((t) => t.status == 'IN_PROGRESS')
//             .length;
//
//         return Container(
//           margin: EdgeInsets.all(16.w),
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFFB15DC6), Color(0xFF4A43C9)],
//             ),
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem(openTickets, "Open", Icons.pending_actions),
//               _buildStatItem(inProgressTickets, "In Progress", Icons.update),
//               _buildStatItem(
//                 tickets.length,
//                 "Total",
//                 Icons.confirmation_number,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildStatItem(int count, String label, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: EdgeInsets.all(8.w),
//           decoration: BoxDecoration(
//             // ignore: deprecated_member_use
//             color: Colors.white.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white, size: 18.sp),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           count.toString(),
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           label,
//           style: TextStyle(
//             // ignore: deprecated_member_use
//             color: Colors.white.withOpacity(0.9),
//             fontSize: 12.sp,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
//             strokeWidth: 3,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'Loading your tickets...',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64.sp, color: Colors.grey[400]),
//           SizedBox(height: 16.h),
//           Text(
//             'Failed to load tickets',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Please check your connection and try again',
//             style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 16.h),
//           ElevatedButton(
//             onPressed: _refreshTickets,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFF6C63FF),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//             ),
//             child: Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120.w,
//             height: 120.h,
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.confirmation_number_outlined,
//               size: 48.sp,
//               color: Colors.grey[400],
//             ),
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             'No tickets yet',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[600],
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Create your first ticket to get support',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 24.h),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => CreateTicketScreen()),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFFFF6B35),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//             ),
//             child: Text('Create First Ticket'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTicketCard(BuildContext context, Ticket ticket) {
//     final dateFormat = DateFormat('MMM dd, yyyy');
//     final timeFormat = DateFormat('hh:mm a');
//     final statusColor = _getStatusColor(ticket.status);
//     final statusIcon = _getStatusIcon(ticket.status);
//
//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16.r),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => TicketDetailScreen(ticket: ticket),
//             ),
//           );
//         },
//         child: Container(
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with status and type
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       ticket.ticketType,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16.sp,
//                         color: Colors.grey[800],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 12.w,
//                       vertical: 6.h,
//                     ),
//                     decoration: BoxDecoration(
//                       // ignore: deprecated_member_use
//                       color: statusColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20.r),
//                       // ignore: deprecated_member_use
//                       border: Border.all(color: statusColor.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(statusIcon, size: 14.sp, color: statusColor),
//                         SizedBox(width: 6.w),
//                         Text(
//                           ticket.status.toUpperCase(),
//                           style: TextStyle(
//                             color: statusColor,
//                             fontSize: 11.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12.h),
//
//               // Ticket ID and Order ID
//               Row(
//                 children: [
//                   _buildInfoItem(
//                     Icons.confirmation_number,
//                     'Ticket ID: ${ticket.id}',
//                   ),
//                   if (ticket.orderId != 0) ...[
//                     SizedBox(width: 16.w),
//                     _buildInfoItem(
//                       Icons.receipt_long,
//                       'Order: ${ticket.orderId}',
//                     ),
//                   ],
//                 ],
//               ),
//               SizedBox(height: 8.h),
//
//               // Date and time
//               Row(
//                 children: [
//                   _buildInfoItem(
//                     Icons.calendar_today,
//                     dateFormat.format(ticket.createdAt.toLocal()),
//                   ),
//                   SizedBox(width: 16.w),
//                   _buildInfoItem(
//                     Icons.access_time,
//                     timeFormat.format(ticket.createdAt.toLocal()),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12.h),
//
//               // Message preview
//               Text(
//                 ticket.message.length > 80
//                     ? '${ticket.message.substring(0, 80)}...'
//                     : ticket.message,
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   color: Colors.grey[700],
//                   height: 1.4,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//
//               // View details button
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 6.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'View Details',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(width: 4.w),
//                       Icon(
//                         Icons.arrow_forward_ios,
//                         size: 12.sp,
//                         color: Colors.grey[600],
//                       ),
//                     ],
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
//   Widget _buildInfoItem(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14.sp, color: Colors.grey[500]),
//         SizedBox(width: 4.w),
//         Text(
//           text,
//           style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//         ),
//       ],
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'OPEN':
//         return Color(0xFF4CAF50);
//       case 'IN_PROGRESS':
//         return Color(0xFFFF9800);
//       case 'RESOLVED':
//         return Color(0xFF2196F3);
//       case 'REJECTED':
//         return Color(0xFFF44336);
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData _getStatusIcon(String status) {
//     switch (status.toUpperCase()) {
//       case 'OPEN':
//         return Icons.lock_open;
//       case 'IN_PROGRESS':
//         return Icons.autorenew;
//       case 'RESOLVED':
//         return Icons.check_circle;
//       case 'REJECTED':
//         return Icons.cancel;
//       default:
//         return Icons.help;
//     }
//   }
// }
//
// class TicketDetailScreen extends StatelessWidget {
//   final Ticket ticket;
//   const TicketDetailScreen({required this.ticket});
//
//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
//     final statusColor = _getStatusColor(ticket.status);
//     final statusIcon = _getStatusIcon(ticket.status);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           'Ticket Details',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 1,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isSmallScreen = constraints.maxWidth < 350;
//             final isLargeScreen = constraints.maxWidth > 600;
//
//             return SingleChildScrollView(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12.w : 16.w,
//                 vertical: 16.h,
//               ),
//               child: Column(
//                 children: [
//                   // Ticket Overview Card
//                   _buildOverviewCard(
//                     ticket,
//                     statusColor,
//                     statusIcon,
//                     dateFormat,
//                     isSmallScreen,
//                     isLargeScreen,
//                   ),
//                   SizedBox(height: 16.h),
//
//                   // Message Card
//                   _buildMessageCard(ticket, isSmallScreen),
//                   SizedBox(height: 16.h),
//
//                   // Attachment Card
//                   if (ticket.attachmentUrl != null &&
//                       ticket.attachmentUrl!.isNotEmpty)
//                     _buildAttachmentCard(ticket, isSmallScreen),
//
//                   // Admin Response Card
//                   if (ticket.adminResponse != null)
//                     _buildAdminResponseCard(ticket, isSmallScreen),
//
//                   // Bottom spacing for safe area
//                   SizedBox(height: 20.h),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOverviewCard(
//     Ticket ticket,
//     Color statusColor,
//     IconData statusIcon,
//     DateFormat dateFormat,
//     bool isSmallScreen,
//     bool isLargeScreen,
//   ) {
//     return Card(
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isSmallScreen ? 16.r : 20.r),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 16.w : 20.w),
//         child: Column(
//           children: [
//             // Status and Type - Responsive layout
//             if (isSmallScreen) ...[
//               // Vertical layout for small screens
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     ticket.ticketType,
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 12.h),
//                   _buildStatusBadge(
//                     statusColor,
//                     statusIcon,
//                     ticket.status,
//                     isSmallScreen,
//                   ),
//                 ],
//               ),
//             ] else ...[
//               // Horizontal layout for larger screens
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       ticket.ticketType,
//                       style: TextStyle(
//                         fontSize: isLargeScreen ? 22.sp : 20.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey[800],
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   _buildStatusBadge(
//                     statusColor,
//                     statusIcon,
//                     ticket.status,
//                     isSmallScreen,
//                   ),
//                 ],
//               ),
//             ],
//             SizedBox(height: 20.h),
//
//             // Responsive Grid for details
//             _buildResponsiveDetailsGrid(
//               ticket,
//               dateFormat,
//               isSmallScreen,
//               isLargeScreen,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusBadge(
//     Color statusColor,
//     IconData statusIcon,
//     String status,
//     bool isSmallScreen,
//   ) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isSmallScreen ? 12.w : 16.w,
//         vertical: isSmallScreen ? 6.h : 8.h,
//       ),
//       decoration: BoxDecoration(
//         // ignore: deprecated_member_use
//         color: statusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20.r),
//         // ignore: deprecated_member_use
//         border: Border.all(color: statusColor.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             statusIcon,
//             size: isSmallScreen ? 14.sp : 16.sp,
//             color: statusColor,
//           ),
//           SizedBox(width: isSmallScreen ? 4.w : 8.w),
//           Text(
//             ticket.status.toUpperCase(),
//             style: TextStyle(
//               color: statusColor,
//               fontSize: isSmallScreen ? 10.sp : 13.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResponsiveDetailsGrid(
//     Ticket ticket,
//     DateFormat dateFormat,
//     bool isSmallScreen,
//     bool isLargeScreen,
//   ) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final gridWidth = constraints.maxWidth;
//         final crossAxisCount = gridWidth > 400 ? 2 : 1;
//         final childAspectRatio = gridWidth > 400
//             ? (isLargeScreen ? 4.0 : 3.5)
//             : 2.5;
//
//         return GridView.count(
//           crossAxisCount: crossAxisCount,
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           crossAxisSpacing: isSmallScreen ? 8.w : 12.w,
//           mainAxisSpacing: isSmallScreen ? 8.h : 12.h,
//           childAspectRatio: childAspectRatio,
//           children: [
//             _buildDetailItem(
//               Icons.confirmation_number,
//               'Ticket ID',
//               ticket.id.toString(),
//               isSmallScreen,
//             ),
//             if (ticket.orderId != 0)
//               _buildDetailItem(
//                 Icons.receipt_long,
//                 'Order ID',
//                 ticket.orderId.toString(),
//                 isSmallScreen,
//               ),
//             _buildDetailItem(
//               Icons.calendar_today,
//               'Created',
//               dateFormat.format(ticket.createdAt.toLocal()),
//               isSmallScreen,
//             ),
//             if (ticket.status == 'RESOLVED' || ticket.status == 'REJECTED')
//               _buildDetailItem(
//                 Icons.calendar_today,
//                 'Resolved',
//                 dateFormat.format(ticket.resolvedAt!.toLocal()),
//                 isSmallScreen,
//               ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildDetailItem(
//     IconData icon,
//     String label,
//     String value,
//     bool isSmallScreen,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(isSmallScreen ? 10.r : 12.r),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       padding: EdgeInsets.all(isSmallScreen ? 10.w : 12.w),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(isSmallScreen ? 5.w : 6.w),
//             decoration: BoxDecoration(
//               // ignore: deprecated_member_use
//               color: Color(0xFF6C63FF).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               size: isSmallScreen ? 14.sp : 16.sp,
//               color: Color(0xFF6C63FF),
//             ),
//           ),
//           SizedBox(width: isSmallScreen ? 8.w : 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 10.sp : 11.sp,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 11.sp : 12.sp,
//                     color: Colors.grey[800],
//                     fontWeight: FontWeight.w600,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageCard(Ticket ticket, bool isSmallScreen) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isSmallScreen ? 16.r : 20.r),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 16.w : 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(isSmallScreen ? 6.w : 8.w),
//                   decoration: BoxDecoration(
//                     // ignore: deprecated_member_use
//                     color: Color(0xFFFF6B35).withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.description,
//                     size: isSmallScreen ? 16.sp : 18.sp,
//                     color: Color(0xFFFF6B35),
//                   ),
//                 ),
//                 SizedBox(width: isSmallScreen ? 8.w : 12.w),
//                 Text(
//                   'Description',
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 15.sp : 16.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: isSmallScreen ? 12.h : 16.h),
//             Text(
//               ticket.message,
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 13.sp : 14.sp,
//                 height: 1.6,
//                 color: Colors.grey[700],
//               ),
//               textAlign: TextAlign.left,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAttachmentCard(Ticket ticket, bool isSmallScreen) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isSmallScreen ? 16.r : 20.r),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 16.w : 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(isSmallScreen ? 6.w : 8.w),
//                   decoration: BoxDecoration(
//                     // ignore: deprecated_member_use
//                     color: Color(0xFF4CAF50).withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.attach_file,
//                     size: isSmallScreen ? 16.sp : 18.sp,
//                     color: Color(0xFF4CAF50),
//                   ),
//                 ),
//                 SizedBox(width: isSmallScreen ? 8.w : 12.w),
//                 Text(
//                   'Attachment',
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 15.sp : 16.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: isSmallScreen ? 12.h : 16.h),
//             Center(
//               child: _buildAttachmentWidget(
//                 ticket.attachmentUrl,
//                 isSmallScreen,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAdminResponseCard(Ticket ticket, bool isSmallScreen) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isSmallScreen ? 16.r : 20.r),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 16.w : 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(isSmallScreen ? 6.w : 8.w),
//                   decoration: BoxDecoration(
//                     // ignore: deprecated_member_use
//                     color: Color(0xFF2196F3).withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.support_agent,
//                     size: isSmallScreen ? 16.sp : 18.sp,
//                     color: Color(0xFF2196F3),
//                   ),
//                 ),
//                 SizedBox(width: isSmallScreen ? 8.w : 12.w),
//                 Text(
//                   'Admin Response',
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 15.sp : 16.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: isSmallScreen ? 12.h : 16.h),
//             Container(
//               padding: EdgeInsets.all(isSmallScreen ? 12.w : 16.w),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(
//                   isSmallScreen ? 10.r : 12.r,
//                 ),
//                 border: Border.all(color: Colors.blue[100]!),
//               ),
//               child: Text(
//                 ticket.adminResponse!,
//                 style: TextStyle(
//                   fontSize: isSmallScreen ? 13.sp : 14.sp,
//                   height: 1.6,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAttachmentWidget(String? attachmentUrl, bool isSmallScreen) {
//     if (attachmentUrl == null || attachmentUrl.isEmpty) {
//       return const SizedBox();
//     }
//
//     final imageSize = isSmallScreen ? 120.w : 150.w;
//
//     if (attachmentUrl.startsWith('data:image')) {
//       try {
//         final base64Str = attachmentUrl.split(',').last.trim();
//         final bytes = base64Decode(base64Str);
//         return Container(
//           width: imageSize,
//           height: imageSize,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(isSmallScreen ? 10.r : 12.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 6,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(isSmallScreen ? 10.r : 12.r),
//             child: Image.memory(bytes, fit: BoxFit.cover),
//           ),
//         );
//       } catch (e) {
//         return Container(
//           width: imageSize,
//           height: imageSize,
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(isSmallScreen ? 10.r : 12.r),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error,
//                 color: Colors.grey[400],
//                 size: isSmallScreen ? 24.sp : 32.sp,
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 'Invalid image',
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: isSmallScreen ? 10.sp : 12.sp,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//
//     return Container(
//       width: imageSize,
//       height: imageSize,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(isSmallScreen ? 10.r : 12.r),
//         color: Colors.grey[200],
//       ),
//       child: Center(
//         child: CircularProgressIndicator(
//           color: Color(0xFF6C63FF),
//           strokeWidth: 2,
//         ),
//       ),
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'OPEN':
//         return Color(0xFF4CAF50);
//       case 'IN_PROGRESS':
//         return Color(0xFFFF9800);
//       case 'RESOLVED':
//         return Color(0xFF2196F3);
//       case 'REJECTED':
//         return Color(0xFFF44336);
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData _getStatusIcon(String status) {
//     switch (status.toUpperCase()) {
//       case 'OPEN':
//         return Icons.lock_open;
//       case 'IN_PROGRESS':
//         return Icons.autorenew;
//       case 'RESOLVED':
//         return Icons.check_circle;
//       case 'REJECTED':
//         return Icons.cancel;
//       default:
//         return Icons.help;
//     }
//   }
// }
//
// class CreateTicketScreen extends StatefulWidget {
//   final String? orderId;
//   const CreateTicketScreen({Key? key, this.orderId}) : super(key: key);
//
//   @override
//   State<CreateTicketScreen> createState() => _CreateTicketScreenState();
// }
//
// class _CreateTicketScreenState extends State<CreateTicketScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _messageController = TextEditingController();
//
//   String? _selectedCategory;
//   bool _loading = false;
//
//   XFile? _pickedImage;
//
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _pickedImage = image;
//       });
//     }
//   }
//
//   Future<String> _getBase64Image() async {
//     if (_pickedImage != null) {
//       final bytes = await File(_pickedImage!.path).readAsBytes();
//       return base64Encode(bytes);
//     }
//     return "";
//   }
//
//   Future<void> _submitTicket() async {
//     setState(() => _loading = true);
//
//     final attachmentBase64 = await _getBase64Image();
//
//     final success = await food_authservice.createTicket(
//       orderId: widget.orderId?.toString(),
//       message: _messageController.text,
//       category: _selectedCategory,
//       attachmentBase64: attachmentBase64,
//     );
//
//     setState(() => _loading = false);
//
//     if (!mounted) return;
//
//     if (success) {
//       Navigator.pop(context, true);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('✅ Ticket created successfully'),
//           backgroundColor: Color(0xFF4CAF50),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('❌ Failed to create ticket'),
//           backgroundColor: Color(0xFFF44336),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           "Raise New Ticket",
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         // backgroundColor: Color(0xFF6C63FF),
//         // elevation: 0,
//         // shape: RoundedRectangleBorder(
//         //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
//         // ),
//         // iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Category Dropdown
//                         if (widget.orderId == null) ...[
//                           Text(
//                             'Category',
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           SizedBox(height: 8.h),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12.r),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black12,
//                                   blurRadius: 4,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: DropdownButtonFormField<String>(
//                               value: _selectedCategory,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16.w,
//                                   vertical: 12.h,
//                                 ),
//                               ),
//                               items:
//                                   [
//                                     'DELIVERY_ISSUE',
//                                     'PAYMENT_PROBLEM',
//                                     'WRONG_ORDER',
//                                     'SERVICE_QUALITY',
//                                     'OTHER',
//                                   ].map((String value) {
//                                     return DropdownMenuItem<String>(
//                                       value: value,
//                                       child: Text(
//                                         value.replaceAll('_', ' '),
//                                         style: TextStyle(fontSize: 14.sp),
//                                       ),
//                                     );
//                                   }).toList(),
//                               onChanged: (newValue) {
//                                 setState(() => _selectedCategory = newValue);
//                               },
//                               validator: (value) {
//                                 if (value == null)
//                                   return 'Please select a category';
//                                 return null;
//                               },
//                               icon: Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Color(0xFF6C63FF),
//                               ),
//                               dropdownColor: Colors.white,
//                             ),
//                           ),
//                           SizedBox(height: 20.h),
//                         ],
//
//                         // Description
//                         Text(
//                           'Description',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                         SizedBox(height: 8.h),
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.r),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 4,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             controller: _messageController,
//                             maxLines: 5,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12.r),
//                                 borderSide: BorderSide.none,
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                               hintText: 'Describe your issue in detail...',
//                               contentPadding: EdgeInsets.all(16.w),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a description';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 24.h),
//
//                         // Attachment Section
//                         Text(
//                           'Attachment',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                         SizedBox(height: 12.h),
//                         Row(
//                           children: [
//                             // Attachment Button
//                             ElevatedButton.icon(
//                               onPressed: _pickImage,
//                               icon: Icon(Icons.attach_file, size: 18.sp),
//                               label: Text(
//                                 'Add Attachment',
//                                 style: TextStyle(fontSize: 13.sp),
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.white,
//                                 foregroundColor: Color(0xFF6C63FF),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 16.w,
//                                   vertical: 12.h,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   side: BorderSide(color: Color(0xFF6C63FF)),
//                                 ),
//                                 elevation: 2,
//                               ),
//                             ),
//                             SizedBox(width: 16.w),
//
//                             // Image Preview
//                             if (_pickedImage != null)
//                               Stack(
//                                 children: [
//                                   Container(
//                                     width: 80.w,
//                                     height: 80.h,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[100],
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       border: Border.all(
//                                         color: Colors.grey[300]!,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(11.r),
//                                       child: Image.file(
//                                         File(_pickedImage!.path),
//                                         fit: BoxFit.cover,
//                                         errorBuilder:
//                                             (context, error, stackTrace) =>
//                                                 Center(
//                                                   child: Icon(
//                                                     Icons.error,
//                                                     color: Colors.red,
//                                                     size: 24.sp,
//                                                   ),
//                                                 ),
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: -8,
//                                     right: -8,
//                                     child: IconButton(
//                                       icon: Container(
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Colors.red[400],
//                                         ),
//                                         padding: EdgeInsets.all(4),
//                                         child: Icon(
//                                           Icons.close,
//                                           size: 14.sp,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           _pickedImage = null;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Submit Button
//                 SizedBox(height: 20.h),
//                 Container(
//                   width: double.infinity,
//                   height: 56.h,
//                   child: ElevatedButton(
//                     onPressed: _loading
//                         ? null
//                         : () {
//                             if (_formKey.currentState!.validate()) {
//                               _submitTicket();
//                             }
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFFF6B35),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16.r),
//                       ),
//                       elevation: 4,
//                       // ignore: deprecated_member_use
//                       shadowColor: Color(0xFFFF6B35).withOpacity(0.3),
//                     ),
//                     child: _loading
//                         ? SizedBox(
//                             width: 20.w,
//                             height: 20.h,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : Text(
//                             'Submit Ticket',
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../Api/food_authservice.dart';
import '../Models/food&beverages/ticket_model.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _K {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFB15DC6);
  static const accentDark = Color(0xFF8B3FA0);
  static const accentLight = Color(0xFFF5E8FA);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const greenDark = Color(0xFF059669);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFEDD5);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x14000000);

  static LinearGradient get gradient => const LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return green;
      case 'IN_PROGRESS':
        return amber;
      case 'RESOLVED':
        return blue;
      case 'REJECTED':
        return red;
      default:
        return text2;
    }
  }

  static Color statusBg(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return greenLight;
      case 'IN_PROGRESS':
        return amberLight;
      case 'RESOLVED':
        return blueLight;
      case 'REJECTED':
        return redLight;
      default:
        return border;
    }
  }

  static IconData statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Icons.lock_open_rounded;
      case 'IN_PROGRESS':
        return Icons.autorenew_rounded;
      case 'RESOLVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}

// ─── TicketListScreen ─────────────────────────────────────────────────────────
class TicketListScreen extends StatefulWidget {
  final int userId;
  const TicketListScreen({Key? key, required this.userId}) : super(key: key);
  @override
  _TicketListScreenState createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late Future<List<Ticket>> _futureTickets;

  @override
  void initState() {
    super.initState();
    _futureTickets = food_authservice.fetchTicketsByUser();
  }

  void _refreshTickets() =>
      setState(() => _futureTickets = food_authservice.fetchTicketsByUser());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<Ticket>>(
                future: _futureTickets,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return _buildLoader();
                  if (snap.hasError) return _buildError();
                  final tickets = (snap.data ?? []).reversed.toList();
                  return Column(
                    children: [
                      _buildStatsBar(snap.data ?? []),
                      Expanded(
                        child: tickets.isEmpty
                            ? _buildEmpty()
                            : RefreshIndicator(
                                onRefresh: () async => _refreshTickets(),
                                color: _K.accent,
                                child: ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    16.w,
                                    8.h,
                                    16.w,
                                    80.h,
                                  ),
                                  itemCount: tickets.length,
                                  itemBuilder: (_, i) =>
                                      _buildTicketCard(tickets[i]),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateTicketScreen()),
          );
          if (result == true) _refreshTickets();
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: _K.gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _K.accent.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
    decoration: const BoxDecoration(
      color: _K.white,
      border: Border(bottom: BorderSide(color: _K.border, width: 1)),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: _K.bg,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _K.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: _K.text1,
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
                'My Tickets',
                style: TextStyle(
                  color: _K.text1,
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

  // ── Stats bar ────────────────────────────────────────────────────────────────
  Widget _buildStatsBar(List<Ticket> tickets) {
    final open = tickets.where((t) => t.status == 'OPEN').length;
    final inProgress = tickets.where((t) => t.status == 'IN_PROGRESS').length;
    final total = tickets.length;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: _K.gradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _K.accent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem(Icons.pending_actions_rounded, open, 'Open'),
          _divider(),
          _statItem(Icons.autorenew_rounded, inProgress, 'In Progress'),
          _divider(),
          _statItem(Icons.confirmation_number_rounded, total, 'Total'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, int count, String label) => Expanded(
    child: Column(
      children: [
        Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, color: Colors.white, size: 17.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 10.sp),
        ),
      ],
    ),
  );

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withOpacity(0.2),
    margin: EdgeInsets.symmetric(horizontal: 8.w),
  );

  // ── Ticket card ──────────────────────────────────────────────────────────────
  Widget _buildTicketCard(Ticket ticket) {
    final sColor = _K.statusColor(ticket.status);
    final sBg = _K.statusBg(ticket.status);
    final sIcon = _K.statusIcon(ticket.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: _K.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _K.border),
          boxShadow: [
            const BoxShadow(
              color: _K.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card header
            Container(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
              decoration: BoxDecoration(
                color: sColor.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: sBg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(sIcon, color: sColor, size: 18.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.ticketType,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: _K.text1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Ticket #${ticket.id}',
                          style: TextStyle(fontSize: 10.sp, color: _K.text2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: sBg,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: sColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sIcon, size: 11.sp, color: sColor),
                        SizedBox(width: 4.w),
                        Text(
                          ticket.status,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: sColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Card body
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta row
                  Row(
                    children: [
                      _metaChip(
                        Icons.calendar_today_rounded,
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(ticket.createdAt.toLocal()),
                      ),
                      SizedBox(width: 8.w),
                      _metaChip(
                        Icons.access_time_rounded,
                        DateFormat(
                          'hh:mm a',
                        ).format(ticket.createdAt.toLocal()),
                      ),
                      if (ticket.orderId != 0) ...[
                        SizedBox(width: 8.w),
                        _metaChip(
                          Icons.receipt_long_rounded,
                          'Order #${ticket.orderId}',
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Message preview
                  Text(
                    ticket.message.length > 90
                        ? '${ticket.message.substring(0, 90)}...'
                        : ticket.message,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _K.text2,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // View details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: _K.gradient,
                          borderRadius: BorderRadius.circular(9.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: _K.bg,
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: _K.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.sp, color: _K.text3),
        SizedBox(width: 3.w),
        Text(
          text,
          style: TextStyle(fontSize: 10.sp, color: _K.text2),
        ),
      ],
    ),
  );

  Widget _buildLoader() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: _K.gradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.confirmation_number_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Loading tickets...',
          style: TextStyle(color: _K.text2, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: EdgeInsets.all(32.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _K.redLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: _K.red,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Failed to load tickets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _K.text1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check your connection and try again',
            style: TextStyle(fontSize: 12, color: _K.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _refreshTickets,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: _K.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: EdgeInsets.all(32.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: _K.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _K.accent.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tickets yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _K.text1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your first ticket to get support',
            style: TextStyle(fontSize: 12, color: _K.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateTicketScreen()),
              );
              if (result == true) _refreshTickets();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: _K.gradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _K.accent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Create First Ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── TicketDetailScreen ───────────────────────────────────────────────────────
class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final sColor = _K.statusColor(ticket.status);
    final sBg = _K.statusBg(ticket.status);
    final sIcon = _K.statusIcon(ticket.status);
    final dateFormat = DateFormat('dd MMM yyyy · hh:mm a');

    return Scaffold(
      backgroundColor: _K.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              decoration: const BoxDecoration(
                color: _K.white,
                border: Border(bottom: BorderSide(color: _K.border, width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: _K.bg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: _K.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: _K.text1,
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
                          'Ticket Details',
                          style: TextStyle(
                            color: _K.text1,
                            fontWeight: FontWeight.w800,
                            fontSize: 17.sp,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Ticket #${ticket.id}',
                          style: TextStyle(color: _K.text2, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: sBg,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: sColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sIcon, size: 11.sp, color: sColor),
                        SizedBox(width: 4.w),
                        Text(
                          ticket.status,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: sColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                child: Column(
                  children: [
                    // Overview card
                    _infoCard(
                      icon: Icons.confirmation_number_rounded,
                      iconColor: _K.accent,
                      iconBg: _K.accentLight,
                      title: ticket.ticketType,
                      children: [
                        _infoRow(
                          Icons.tag_rounded,
                          'Ticket ID',
                          '#${ticket.id}',
                        ),
                        if (ticket.orderId != 0)
                          _infoRow(
                            Icons.receipt_long_rounded,
                            'Order ID',
                            '#${ticket.orderId}',
                          ),
                        _infoRow(
                          Icons.calendar_today_rounded,
                          'Created',
                          dateFormat.format(ticket.createdAt.toLocal()),
                        ),
                        if (ticket.status == 'RESOLVED' ||
                            ticket.status == 'REJECTED')
                          _infoRow(
                            Icons.task_alt_rounded,
                            'Resolved',
                            dateFormat.format(ticket.resolvedAt!.toLocal()),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Description card
                    _infoCard(
                      icon: Icons.description_rounded,
                      iconColor: _K.orange,
                      iconBg: _K.orangeLight,
                      title: 'Description',
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: _K.bg,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: _K.border),
                          ),
                          child: Text(
                            ticket.message,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _K.text2,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Attachment card
                    if (ticket.attachmentUrl != null &&
                        ticket.attachmentUrl!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoCard(
                        icon: Icons.attach_file_rounded,
                        iconColor: _K.green,
                        iconBg: _K.greenLight,
                        title: 'Attachment',
                        children: [_buildAttachment(ticket.attachmentUrl)],
                      ),
                    ],

                    // Admin response card
                    if (ticket.adminResponse != null) ...[
                      SizedBox(height: 12.h),
                      _infoCard(
                        icon: Icons.support_agent_rounded,
                        iconColor: _K.blue,
                        iconBg: _K.blueLight,
                        title: 'Admin Response',
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: _K.blueLight.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: _K.blue.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              ticket.adminResponse!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: _K.text2,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _K.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _K.border),
        boxShadow: [
          const BoxShadow(
            color: _K.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _K.text1,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _K.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 14, color: _K.text3),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: _K.text2)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _K.text1,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildAttachment(String? url) {
    if (url == null || url.isEmpty) return const SizedBox();
    if (url.startsWith('data:image')) {
      try {
        final bytes = base64Decode(url.split(',').last.trim());
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
          ),
        );
      } catch (_) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: _K.redLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: _K.red),
          ),
        );
      }
    }
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _K.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _K.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _K.accent, strokeWidth: 2),
      ),
    );
  }
}

// ─── CreateTicketScreen ───────────────────────────────────────────────────────
class CreateTicketScreen extends StatefulWidget {
  final String? orderId;
  const CreateTicketScreen({Key? key, this.orderId}) : super(key: key);
  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String? _selectedCategory;
  bool _loading = false;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = img);
  }

  Future<String> _getBase64Image() async {
    if (_pickedImage == null) return '';
    final bytes = await File(_pickedImage!.path).readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _submitTicket() async {
    setState(() => _loading = true);
    final base64 = await _getBase64Image();
    final success = await food_authservice.createTicket(
      orderId: widget.orderId?.toString(),
      message: _messageController.text,
      category: _selectedCategory,
      attachmentBase64: base64,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ticket created successfully ✅',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: _K.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to create ticket',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _K.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              decoration: const BoxDecoration(
                color: _K.white,
                border: Border(bottom: BorderSide(color: _K.border, width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: _K.bg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: _K.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: _K.text1,
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
                          'Raise New Ticket',
                          style: TextStyle(
                            color: _K.text1,
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
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selector chips
                      if (widget.orderId == null) ...[
                        _fieldLabel('Issue Category'),
                        SizedBox(height: 8.h),
                        _buildCategoryChips(),
                        SizedBox(height: 18.h),
                      ],

                      // Description field
                      _fieldLabel('Description'),
                      SizedBox(height: 8.h),
                      Container(
                        decoration: BoxDecoration(
                          color: _K.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: _K.border),
                          boxShadow: [
                            const BoxShadow(
                              color: _K.shadow,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _messageController,
                          maxLines: 5,
                          style: TextStyle(fontSize: 13.sp, color: _K.text1),
                          decoration: InputDecoration(
                            hintText: 'Describe your issue in detail...',
                            hintStyle: TextStyle(
                              color: _K.text3,
                              fontSize: 13.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14.r),
                          ),
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'Please enter a description'
                              : null,
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // Attachment
                      _fieldLabel('Attachment (Optional)'),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: _K.accentLight,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: _K.accent.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.attach_file_rounded,
                                    color: _K.accent,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Add Image',
                                    style: TextStyle(
                                      color: _K.accent,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_pickedImage != null) ...[
                            SizedBox(width: 12.w),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.file(
                                    File(_pickedImage!.path),
                                    width: 70.r,
                                    height: 70.r,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _pickedImage = null),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: _K.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Submit button
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: GestureDetector(
                onTap: _loading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) _submitTicket();
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: _loading ? null : _K.gradient,
                    color: _loading ? _K.border : null,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: _loading
                        ? null
                        : [
                            BoxShadow(
                              color: _K.accent.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: _K.text2,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Row(
    children: [
      Container(
        width: 3,
        height: 14,
        decoration: BoxDecoration(
          gradient: _K.gradient,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      SizedBox(width: 7.w),
      Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: _K.text1,
        ),
      ),
    ],
  );

  Widget _buildCategoryChips() {
    final categories = [
      'DELIVERY_ISSUE',
      'PAYMENT_PROBLEM',
      'WRONG_ORDER',
      'SERVICE_QUALITY',
      'OTHER',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: isSelected ? _K.gradient : null,
              color: isSelected ? null : _K.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: isSelected ? _K.accent : _K.border),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _K.accent.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              cat.replaceAll('_', ' '),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _K.text2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
