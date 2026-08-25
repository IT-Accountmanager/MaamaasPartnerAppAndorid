import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/user_module/API/food_authservice.dart';
import '../Models/ticket_model.dart';
import '../widgets/provider.dart';

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
    _futureTickets = food_Authservice.fetchTicketsByUser();
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _futureTickets = food_Authservice.fetchTicketsByUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Tickets",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Stats
            _buildHeaderStats(),
            // Tickets List
            Expanded(
              child: FutureBuilder<List<Ticket>>(
                future: _futureTickets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  final tickets = (snapshot.data ?? []).reversed.toList();

                  if (tickets.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshTickets,
                    backgroundColor: Colors.white,
                    color: Color(0xFF6C63FF),
                    child: ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: tickets.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return _buildTicketCard(context, ticket);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFF6B35),
        child: Icon(Icons.add, size: 28.sp, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTicketScreen()),
          );
          if (result == true) {
            _refreshTickets();
          }
        },
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  Widget _buildHeaderStats() {
    return FutureBuilder<List<Ticket>>(
      future: _futureTickets,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox();
        }

        final tickets = snapshot.data ?? [];
        final openTickets = tickets.where((t) => t.status == 'OPEN').length;
        final inProgressTickets = tickets
            .where((t) => t.status == 'IN_PROGRESS')
            .length;
        final resolved = tickets.where((t) => t.status == 'RESOLVED').length;

        return Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB15DC6), Color(0xFF4A43C9)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                tickets.length,
                "Total",
                Icons.confirmation_number,
              ),
              _buildStatItem(openTickets, "Open", Icons.pending_actions),
              _buildStatItem(inProgressTickets, "In Progress", Icons.update),
              _buildStatItem(resolved, "Resolved", Icons.check_circle_outline),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(int count, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading your tickets...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Failed to load tickets',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please check your connection and try again',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _refreshTickets,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              size: 48.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No tickets yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first ticket to get support',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTicketScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text('Create First Ticket'),
          ),
        ],
      ),
    );
  }

  String formatTicketType(String value) {
    return value
        .toLowerCase()
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final statusColor = _getStatusColor(ticket.status);
    final statusIcon = _getStatusIcon(ticket.status);

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(ticket: ticket),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      formatTicketType(ticket.ticketType),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      // ignore: deprecated_member_use
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14.sp, color: statusColor),
                        SizedBox(width: 6.w),
                        Text(
                          ticket.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Ticket ID and Order ID
              Row(
                children: [
                  _buildInfoItem(
                    Icons.confirmation_number,
                    'Ticket ID: ${ticket.id}',
                  ),
                  if (ticket.orderId != 0) ...[
                    SizedBox(width: 16.w),
                    _buildInfoItem(
                      Icons.receipt_long,
                      'Order: ${ticket.orderId}',
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.h),

              // Date and time
              Row(
                children: [
                  _buildInfoItem(
                    Icons.calendar_today,
                    dateFormat.format(ticket.createdAt.toLocal()),
                  ),
                  SizedBox(width: 16.w),
                  _buildInfoItem(
                    Icons.access_time,
                    timeFormat.format(ticket.createdAt.toLocal()),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Message preview
              Text(
                ticket.message.length > 80
                    ? '${ticket.message.substring(0, 80)}...'
                    : ticket.message,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),

              // View details button
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey[500]),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Color(0xFF4CAF50);
      case 'IN_PROGRESS':
        return Color(0xFFFF9800);
      case 'RESOLVED':
        return Color(0xFF2196F3);
      case 'REJECTED':
        return Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Icons.lock_open;
      case 'IN_PROGRESS':
        return Icons.autorenew;
      case 'RESOLVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final statusColor = _getStatusColor(ticket.status);
    final statusIcon = _getStatusIcon(ticket.status);

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Ticket Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(color: Color(0xFF64748B)),
        shape: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 350;
            final padding = EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.w : 20.w,
              vertical: 16.h,
            );

            return CustomScrollView(
              slivers: [
                // Header section with ticket ID
                SliverToBoxAdapter(
                  child: Padding(
                    padding: padding.copyWith(bottom: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ticket #${ticket.id}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            _buildStatusBadge(
                              statusColor,
                              statusIcon,
                              ticket.status,
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),
                        Text(
                          formatTicketType(ticket.ticketType),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Status badge
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: EdgeInsets.symmetric(horizontal: padding.horizontal),
                //     child:
                //   ),
                // ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // Details grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: padding.copyWith(top: 0),
                    child: _buildDetailsGrid(ticket, dateFormat, isSmallScreen),
                  ),
                ),

                // Description section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: padding,
                    child: _buildMessageCard(ticket, isSmallScreen),
                  ),
                ),

                // Attachment section
                if (ticket.attachmentUrl != null &&
                    ticket.attachmentUrl!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: padding,
                      child: _buildAttachmentCard(ticket, isSmallScreen),
                    ),
                  ),

                // Admin response section
                if (ticket.adminResponse != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: padding,
                      child: _buildAdminResponseCard(ticket, isSmallScreen),
                    ),
                  ),

                // Bottom spacing
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  String formatTicketType(String value) {
    return value
        .toLowerCase()
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  Widget _buildStatusBadge(
    Color statusColor,
    IconData statusIcon,
    String status,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        // ignore: deprecated_member_use
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 18.sp, color: statusColor),
          SizedBox(width: 8.w),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(
    Ticket ticket,
    DateFormat dateFormat,
    bool isSmallScreen,
  ) {
    final items = [
      _buildDetailItem(
        Icons.calendar_month_rounded,
        'Created',
        dateFormat.format(ticket.createdAt.toLocal()),
        Color(0xFF8B5CF6),
      ),
      if (ticket.orderId != 0)
        _buildDetailItem(
          Icons.receipt_long_rounded,
          'Order ID',
          ticket.orderId.toString(),
          Color(0xFF10B981),
        ),
      if (ticket.status == 'RESOLVED' || ticket.status == 'REJECTED')
        _buildDetailItem(
          Icons.check_circle_rounded,
          'Resolved',
          dateFormat.format(ticket.resolvedAt!.toLocal()),
          Color(0xFF3B82F6),
        ),
    ];

    return GridView.count(
      crossAxisCount: isSmallScreen ? 1 : 1,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: isSmallScreen ? 4.5 : 3.5,
      children: items,
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Ticket ticket, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Text(
            ticket.message,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: Color(0xFF475569),
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentCard(Ticket ticket, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Column(
            children: [
              _buildAttachmentWidget(ticket.attachmentUrl!, isSmallScreen),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminResponseCard(Ticket ticket, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Color(0xFF3B82F6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 18.sp,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Admin Response',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Color(0xFFDBEAFE), width: 1.5),
          ),
          child: Text(
            (ticket.adminResponse ?? '').replaceAll("_", " "),
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: Color(0xFF1E40AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentWidget(String attachmentUrl, bool isSmallScreen) {
    final size = isSmallScreen ? 100.w : 120.w;

    if (attachmentUrl.startsWith("data:image")) {
      try {
        final base64Str = attachmentUrl.split(',').last.trim();
        final bytes = base64Decode(base64Str);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFFF1F5F9), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
        );
      } catch (_) {
        return _buildErrorPlaceholder(size);
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFFF1F5F9), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.network(
          attachmentUrl,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, loading) {
            if (loading == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B5CF6),
                strokeWidth: 2.5,
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildErrorPlaceholder(size),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_rounded, color: Color(0xFF94A3B8), size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            'Unable to load',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Color(0xFF3B82F6);
      case 'IN_PROGRESS':
        return Color(0xFFF59E0B);
      case 'RESOLVED':
        return Color(0xFF10B981);
      case 'REJECTED':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
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

class CreateTicketScreen extends ConsumerStatefulWidget {
  final int? orderId;
  const CreateTicketScreen({Key? key, this.orderId}) : super(key: key);

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String? _selectedCategory;
  bool _loading = false;

  XFile? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    debugPrint("🟢 Received orderId: ${widget.orderId}");
    if (widget.orderId != null) {
      _selectedCategory = 'DELIVERY_ISSUE'; // ✅ default, but editable
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  File? _pickedFileAsIoFile() {
    if (_pickedImage == null) return null;
    return File(_pickedImage!.path);
  }

  //
  Future<void> _submitTicket(String userId) async {
    debugPrint("📤 Submitting ticket");
    debugPrint("OrderId: ${widget.orderId}");
    debugPrint("Category: $_selectedCategory");
    debugPrint("Message: ${_messageController.text}");

    setState(() => _loading = true);

    final successResponse = await food_Authservice.createTicket(
      orderId: widget.orderId,
      message: _messageController.text,
      category: _selectedCategory,
      attachmentFile: _pickedFileAsIoFile(), // ✅ File?
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (successResponse.statusCode >= 200 && successResponse.statusCode < 300) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Ticket created successfully'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Failed to create ticket'),
          backgroundColor: const Color(0xFFF44336),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Raise New Ticket",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Dropdown
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white, // ✅ no disabled color
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),

                            items:
                                const [
                                  'DELIVERY_ISSUE',
                                  'PAYMENT_PROBLEM',
                                  'WRONG_ORDER',
                                  'SERVICE_QUALITY',
                                  'OTHER',
                                ].map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value.replaceAll('_', ' ')),
                                  );
                                }).toList(),

                            onChanged: (value) {
                              setState(() => _selectedCategory = value);
                            },

                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Description
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _messageController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Describe your issue in detail...',
                              contentPadding: EdgeInsets.all(16.w),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Attachment Section
                        Text(
                          'Attachment',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            // Attachment Button
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.attach_file, size: 18.sp),
                              label: Text(
                                'Add Attachment',
                                style: TextStyle(fontSize: 13.sp),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF6C63FF),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(color: Color(0xFF6C63FF)),
                                ),
                                elevation: 2,
                              ),
                            ),
                            SizedBox(width: 16.w),

                            // Image Preview
                            if (_pickedImage != null)
                              Stack(
                                children: [
                                  Container(
                                    width: 80.w,
                                    height: 80.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(11.r),
                                      child: Image.file(
                                        File(_pickedImage!.path),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Center(
                                                  child: Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 24.sp,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: IconButton(
                                      icon: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red[400],
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          size: 14.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _pickedImage = null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _submitTicket(userId.toString());
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 4,
                      // ignore: deprecated_member_use
                      shadowColor: Color(0xFFFF6B35).withOpacity(0.3),
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Submit Ticket',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
