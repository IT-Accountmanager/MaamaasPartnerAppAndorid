
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/user_module/screens/tickets_screen.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Api/APIclient.dart';
import '../API/Apiclient.dart';
import '../API/catering_authservice.dart';
import '../Models/caterings/catering_enquiry_model.dart';
import '../Models/caterings/enquiry_order_model.dart';
import '../Models/caterings/orders_model.dart';
import '../Models/caterings/vendor_quotation_model.dart';


class CateringOrdersScreen extends StatefulWidget {
  const CateringOrdersScreen({super.key});


  @override
  _CateringOrdersScreenState createState() => _CateringOrdersScreenState();
}


class _CateringOrdersScreenState extends State<CateringOrdersScreen> {
  bool _isLoading = true;
  List<dynamic> _combinedList = [];
  String _selectedFilter =
      'order'; // Default to 'order', 'enquiry', or 'enquiry_order'


  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    try {
      final orders = await catering_authservice.getAllCateringOrders();
      final enquiries = await catering_authservice.getAllEnquiries();
      final leadOrders = await _getLeadOrders();


      _combinedList = [
        ...orders.map((o) => _CombinedItem(type: 'order', data: o)),
        ...enquiries.map((e) => _CombinedItem(type: 'enquiry', data: e)),
        ...leadOrders.map(
              (lo) => _CombinedItem(type: 'enquiry_order', data: lo),
        ),
      ];


      _combinedList.sort((a, b) {
        final dateA = _extractDate(a.data);
        final dateB = _extractDate(b.data);
        return dateB.compareTo(dateA);
      });


      setState(() => _isLoading = false);
    } catch (e) {
      // debugPrint("❌ Error loading data: $e");
      setState(() => _isLoading = false);
    }
  }


  Future<List<dynamic>> _getLeadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');


      print('🟡 _getLeadOrders() started');
      print('👤 Retrieved userId: $userId');


      if (userId == null) {
        print('❌ No userId found');
        return [];
      }


      final response = await ApiClient.get(
        '/api/user/leadorderpayment/user/$userId',
        service: 'catering',
      );


      print('📡 API response status: ${response.statusCode}');
      print('📦 API response body: ${response.body}');


      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('✅ Parsed list length: ${jsonList.length}');


        // Debug first item if exists
        if (jsonList.isNotEmpty) {
          print('🔍 First item: ${jsonList.first}');
          print(
            '🔍 First item eventTime type: ${jsonList.first['eventTime'].runtimeType}',
          );
          print(
            '🔍 First item eventTime value: "${jsonList.first['eventTime']}"',
          );
        }


        return jsonList.map((json) => EnquiryOrder.fromJson(json)).toList();
      }


      print('❌ API error: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching lead orders: $e');
      print('❌ Error type: ${e.runtimeType}');
      return [];
    }
  }


  DateTime _extractDate(dynamic data) {
    try {
      if (data is CateringOrder) {
        return DateTime.tryParse(data.orderDateTime as String) ??
            DateTime(1970);
      } else if (data is CateringEnquiry) {
        return DateTime.tryParse(data.createdAt) ?? DateTime(1970);
      } else if (data is EnquiryOrder) {
        return DateTime.tryParse(data.createdAt) ?? DateTime(1970);
      }
    } catch (e) {
      // debugPrint("Error parsing date: $e");
    }
    return DateTime(1970);
  }


  List<dynamic> get _filteredList {
    return _combinedList.where((item) => item.type == _selectedFilter).toList();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _combinedList.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 12, // slight reduction for scroll
        right: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Row(
            children: [
              _buildFilterChip('Orders', 'order'),
              SizedBox(width: 8.w),
              _buildFilterChip('Enquiries', 'enquiry'),
              // SizedBox(width: 8.w),
              // _buildFilterChip('Enquiry Orders', 'enquiry_order'),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? _getChipColor(value) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: _getChipColor(value), width: 2)
              : null,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _getChipColor(value).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getChipIcon(value),
              size: 16.w,
              color: isSelected ? Colors.white : _getChipColor(value),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : _getChipColor(value),
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }


  IconData _getChipIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'enquiry':
        return Icons.mark_email_read_outlined;
      case 'enquiry_order':
        return Icons.request_quote_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }


  Color _getChipColor(String type) {
    switch (type) {
      case 'order':
        return Colors.green;
      case 'enquiry':
        return Colors.blue;
      case 'enquiry_order':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }


  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.w,
            height: 60.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFFF6B35),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading ${_getLoadingText()}...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  String _getLoadingText() {
    switch (_selectedFilter) {
      case 'order':
        return 'orders';
      case 'enquiry':
        return 'enquiries';
      case 'enquiry_order':
        return 'enquiry orders';
      default:
        return 'orders';
    }
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getEmptyStateIcon(), size: 100.w, color: Colors.grey[300]),
          SizedBox(height: 24.h),
          Text(
            _getEmptyStateTitle(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _getEmptyStateSubtitle(),
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getChipColor(_selectedFilter),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Refresh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  IconData _getEmptyStateIcon() {
    switch (_selectedFilter) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'enquiry':
        return Icons.help_outline_rounded;
      case 'enquiry_order':
        return Icons.request_quote_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }


  String _getEmptyStateTitle() {
    switch (_selectedFilter) {
      case 'order':
        return 'No orders found';
      case 'enquiry':
        return 'No enquiries found';
      case 'enquiry_order':
        return 'No enquiry orders found';
      default:
        return 'No orders found';
    }
  }


  String _getEmptyStateSubtitle() {
    switch (_selectedFilter) {
      case 'order':
        return 'Your orders will appear here';
      case 'enquiry':
        return 'Your enquiries will appear here';
      case 'enquiry_order':
        return 'Your enquiry orders will appear here';
      default:
        return 'Your orders will appear here';
    }
  }


  Widget _buildContent() {
    final filteredList = _filteredList;


    return Column(
      children: [
        // Results Count
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Text(
                '${filteredList.length} ${_getResultsCountText(filteredList.length)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: _getChipColor(_selectedFilter),
            child: filteredList.isEmpty
                ? _buildNoResultsForFilter()
                : ListView.separated(
              reverse: true,
              itemCount: filteredList.length,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              separatorBuilder: (context, index) =>
                  SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildItemCard(item);
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildItemCard(_CombinedItem item) {
    switch (item.type) {
      case 'order':
        return CateringOrderCard(
          order: item.data,
          onRatingSubmitted: _loadData,
        );
      case 'enquiry':
        return EnquiryCard(enquiry: item.data);
      case 'enquiry_order':
        return EnquiryOrderCard(order: item.data);
      default:
        return const SizedBox();
    }
  }


  String _getResultsCountText(int count) {
    switch (_selectedFilter) {
      case 'order':
        return count == 1 ? 'order' : 'orders';
      case 'enquiry':
        return count == 1 ? 'enquiry' : 'enquiries';
      case 'enquiry_order':
        return count == 1 ? 'enquiry order' : 'enquiry orders';
      default:
        return count == 1 ? 'order' : 'orders';
    }
  }


  Widget _buildNoResultsForFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getEmptyStateIcon(), size: 80.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            _getNoResultsTitle(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _getNoResultsSubtitle(),
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  String _getNoResultsTitle() {
    switch (_selectedFilter) {
      case 'order':
        return 'No orders';
      case 'enquiry':
        return 'No enquiries';
      case 'enquiry_order':
        return 'No enquiry orders';
      default:
        return 'No orders';
    }
  }


  String _getNoResultsSubtitle() {
    switch (_selectedFilter) {
      case 'order':
        return 'You don\'t have any orders yet';
      case 'enquiry':
        return 'You don\'t have any enquiries yet';
      case 'enquiry_order':
        return 'You don\'t have any enquiry orders yet';
      default:
        return 'You don\'t have any orders yet';
    }
  }
}


class _CombinedItem {
  final String type; // 'order', 'enquiry', or 'enquiry_order'
  final dynamic data;


  _CombinedItem({required this.type, required this.data});
}


class EnquiryOrderCard extends StatelessWidget {
  final EnquiryOrder order;


  const EnquiryOrderCard({super.key, required this.order});


  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EnquiryOrderDetailsScreen(order: order),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Badge and Status - FIXED OVERFLOW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LEFT: Enquiry Order badge
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w, // Reduced from 10.w
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple[400]!, Colors.purple[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.request_quote_outlined,
                              size: 12.w, // Reduced from 14.w
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w), // Reduced from 6.w
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                'ORDER #${order.id}',
                                style: TextStyle(
                                  fontSize: 9.sp, // Reduced from 10.sp
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    // RIGHT: Status
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.35,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w, // Reduced from 8.w
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.orderStatus),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                order.orderStatus.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8.sp, // Reduced from 9.sp
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 2.w), // Reduced from 4.w
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 8.w, // Reduced from 10.w
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 16.h),


                // Customer Info
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 16.w,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            order.eventType,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),


                // Date and Time - FIXED OVERFLOW
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_outlined,
                        formatDate(order.createdAt),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time_outlined,
                        order.formattedEventTime,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),


                // Event Info
                _buildInfoRow(Icons.event, 'Event Date', order.eventDate),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  Icons.location_city,
                  'Location',
                  '${order.city}, ${order.state}',
                ),


                // Plate Counts
                if (order.vegPlates > 0 ||
                    order.nonVegPlates > 0 ||
                    order.mixedPlates > 0)
                  Column(
                    children: [
                      SizedBox(height: 16.h),
                      Wrap(
                        spacing: 6.w, // Reduced from 8.w
                        runSpacing: 6.h, // Reduced from 8.h
                        children: [
                          if (order.vegPlates > 0)
                            _buildPlateCount(
                              'Veg',
                              order.vegPlates,
                              Colors.green,
                            ),
                          if (order.nonVegPlates > 0)
                            _buildPlateCount(
                              'Non-Veg',
                              order.nonVegPlates,
                              Colors.red,
                            ),
                          if (order.mixedPlates > 0)
                            _buildPlateCount(
                              'Mixed',
                              order.mixedPlates,
                              Colors.orange,
                            ),
                        ],
                      ),
                    ],
                  ),


                SizedBox(height: 16.h),


                // Total Amount - FIXED OVERFLOW
                Container(
                  padding: EdgeInsets.all(12.w), // Reduced from 16.w
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[50]!, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12), // Reduced from 16
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          "Total Amount",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp, // Reduced from 14.sp
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          "₹${order.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp, // Reduced from 18.sp
                            color: Colors.green[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.w, color: Colors.grey[600]), // Reduced from 16.w
        SizedBox(width: 4.w), // Reduced from 6.w
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp, // Reduced from 13.sp
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }


  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: Colors.grey[600]), // Reduced from 16.w
        SizedBox(width: 6.w), // Reduced from 8.w
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12.sp, // Reduced from 13.sp
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: 4.w), // Reduced from 4.w
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp, // Reduced from 13.sp
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }


  Widget _buildPlateCount(String type, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$type: $count',
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


// Enquiry Order Details Screen
class EnquiryOrderDetailsScreen extends StatelessWidget {
  final EnquiryOrder order;


  const EnquiryOrderDetailsScreen({super.key, required this.order});


  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }


  void _downloadInvoice() async {
    final pdf = pw.Document();


    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);


    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'ENQUIRY ORDER INVOICE',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),


          pw.Text('Order ID: #${order.id}'),
          pw.Text('Lead ID: #${order.leadId}'),
          pw.Text('Quotation ID: #${order.quotationId}'),
          pw.Text('Order Date: ${formatDate(order.createdAt)}'),
          pw.Text('Payment Method: ${order.paymentMethod}'),
          pw.Text('Payment Type: ${order.paymentType}'),
          pw.Text('Transaction ID: ${order.razorpayPaymentId}'),
          pw.Text('Event Date: ${order.eventDate}'),
          pw.Text('Event Time: ${order.formattedEventTime}'),
          pw.Text('Location: ${order.city}, ${order.state}'),
          pw.SizedBox(height: 16),
          pw.Divider(),


          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text(
              'Customer Details',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Name: ${order.fullName}'),
          pw.Text('Email: ${order.email}'),
          pw.Text('Phone: ${order.phoneNumber}'),
          pw.SizedBox(height: 16),


          pw.Center(
            child: pw.Text(
              'Order Items',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 10),


          ...order.items.map(
                (item) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [pw.Text("• "), pw.Text(item)]),
                pw.SizedBox(height: 4),
              ],
            ),
          ),


          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text(
              'Plate Counts',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          if (order.vegPlates > 0) pw.Text('Veg Plates: ${order.vegPlates}'),
          if (order.nonVegPlates > 0)
            pw.Text('Non-Veg Plates: ${order.nonVegPlates}'),
          if (order.mixedPlates > 0)
            pw.Text('Mixed Plates: ${order.mixedPlates}'),
          pw.SizedBox(height: 16),


          if (order.additionalRequests.isNotEmpty) ...[
            pw.Center(
              child: pw.Text(
                'Additional Requests',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(order.additionalRequests),
            pw.SizedBox(height: 16),
          ],


          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'Bill Summary',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Amount'),
              pw.Text("₹${order.amount.toStringAsFixed(2)}"),
            ],
          ),
          pw.Divider(),


          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              'Thank you for your order!',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'Visit Again!',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );


    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Enquiry Order #${order.id}"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Enquiry Order #${order.id}",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Chip(
                label: Text(
                  order.orderStatus.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _getStatusColor(order.orderStatus),
              ),
            ],
          ),
          SizedBox(height: 16.h),


          // Order Details
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  _infoRow(
                    Icons.calendar_today,
                    "Order Date",
                    formatDate(order.createdAt),
                  ),
                  _infoRow(
                    Icons.access_time,
                    "Event Time",
                    order.formattedEventTime,
                  ),
                  _infoRow(Icons.event, "Event Date", order.eventDate),
                  _infoRow(Icons.category, "Event Type", order.eventType),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),


          // Customer Details
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.blue.shade50,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Details",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _infoRow(Icons.person, "Name", order.fullName),
                  _infoRow(Icons.email, "Email", order.email),
                  _infoRow(Icons.phone, "Phone", order.phoneNumber),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),


          // Location Details
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.green.shade50,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _infoRow(Icons.location_city, "City", order.city),
                  _infoRow(Icons.map, "State", order.state),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),


          // Order Items
          if (order.items.isNotEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Items",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...order.items.map(
                          (item) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16.w,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),


          if (order.items.isNotEmpty) SizedBox(height: 16.h),


          // Plate Counts
          if (order.vegPlates > 0 ||
              order.nonVegPlates > 0 ||
              order.mixedPlates > 0)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.purple.shade50,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Plate Counts",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 8.h,
                      children: [
                        if (order.vegPlates > 0)
                          _plateCountChip('Veg', order.vegPlates, Colors.green),
                        if (order.nonVegPlates > 0)
                          _plateCountChip(
                            'Non-Veg',
                            order.nonVegPlates,
                            Colors.red,
                          ),
                        if (order.mixedPlates > 0)
                          _plateCountChip(
                            'Mixed',
                            order.mixedPlates,
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


          if (order.vegPlates > 0 ||
              order.nonVegPlates > 0 ||
              order.mixedPlates > 0)
            SizedBox(height: 16.h),


          // Additional Requests
          if (order.additionalRequests.isNotEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.teal.shade50,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Additional Requests",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      order.additionalRequests,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),


          if (order.additionalRequests.isNotEmpty) SizedBox(height: 16.h),


          // Payment Details
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.indigo.shade50,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Details",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _infoRow(
                    Icons.payment,
                    "Payment Method",
                    order.paymentMethod,
                  ),
                  _infoRow(
                    Icons.credit_card,
                    "Payment Type",
                    order.paymentType,
                  ),
                  _infoRow(Icons.badge, "Payment Status", order.paymentStatus),
                  SizedBox(height: 8.h),
                  Divider(),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800,
                        ),
                      ),
                      Text(
                        "₹${order.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),


          // Download Invoice Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.purple[700]!, Colors.purple[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: Icon(Icons.receipt_long, size: 20.sp, color: Colors.white),
              label: Text(
                "Download Invoice",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                elevation: 0,
              ),
              onPressed: _downloadInvoice,
            ),
          ),


          SizedBox(height: 20.h),


          // Raise Ticket Button
          _buildActiveTicket(context),
        ],
      ),
    );
  }


  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _plateCountChip(String type, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$type: $count',
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActiveTicket(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Need Help?",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Having issues with this order?",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            Text(
              "Raise a ticket and our support team will help you",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTicketScreen(orderId: order.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                backgroundColor: Colors.orange[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Raise Ticket",
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Now add all your existing classes from the original code
// Starting with CateringOrderCard


class CateringOrderCard extends StatelessWidget {
  final CateringOrder order;
  final VoidCallback? onRatingSubmitted;


  const CateringOrderCard({
    super.key,
    required this.order,
    this.onRatingSubmitted,
  });


  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }


  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }


  @override
  Widget build(BuildContext context) {
    final isDelivered = order.orderStatus == OrderStatus.delivered;
    final hasRating = order.rating > 0;


    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsFullScreen(
                  order: order,
                  onRatingSubmitted: onRatingSubmitted,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Badge and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LEFT: Order badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 14.w,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'ORDER:#${order.id}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),


                    // RIGHT: Status
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.orderStatus),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            order.orderStatus.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12.w,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 16.h),


                // Date and Time
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.calendar_today_outlined,
                      formatDate(order.orderDateTime),
                    ),
                    SizedBox(width: 16.w),
                    _buildInfoItem(
                      Icons.access_time_outlined,
                      formatTime(order.orderDateTime),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),


                // Items Preview
                ...order.items
                    .take(2)
                    .map(
                      (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.name} (${item.quantity})",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "₹${item.price}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (order.items.length > 2)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      "+ ${order.items.length - 2} more items",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),


                // Rating Section for Delivered Orders
                if (isDelivered) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rate_rounded,
                          size: 16.w,
                          color: Colors.orange[700],
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            hasRating
                                ? 'You rated this order ${order.rating} stars'
                                : 'Rate your order experience',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                        if (!hasRating)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rate Now',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],


                // Total Amount
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[50]!, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        "₹${order.total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


Color _getStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.confirmed:
      return Colors.blue;
    case OrderStatus.preparing:
      return Colors.orange;
    case OrderStatus.ready:
      return Colors.purple;
    case OrderStatus.delivered:
      return Colors.green;
    case OrderStatus.cancelled:
      return Colors.red;
  }
}


class OrderDetailsFullScreen extends StatefulWidget {
  final CateringOrder order;
  final VoidCallback? onRatingSubmitted;


  const OrderDetailsFullScreen({
    super.key,
    required this.order,
    this.onRatingSubmitted,
  });


  @override
  State<OrderDetailsFullScreen> createState() => _OrderDetailsFullScreenState();
}


class _OrderDetailsFullScreenState extends State<OrderDetailsFullScreen> {
  bool _isSubmittingRating = false;


  Future<void> _downloadInvoice() async {
    final data = await catering_authservice().fetchOrderById(widget.order.id);
    if (data == null) return;


    final pdfBytes = await generateCateringInvoice(data);
    await downloadPdf(pdfBytes, "Invoice_${widget.order.id}.pdf");
  }


  Future<void> downloadPdf(Uint8List pdfBytes, String fileName) async {
    try {
      // Get external storage directory (Downloads folder on Android)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // optional: to save directly in Downloads folder
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/Download";
        directory = Directory(newPath);
      } else {
        // iOS documents directory
        directory = await getApplicationDocumentsDirectory();
      }


      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }


      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);


      // Write PDF bytes to file
      await file.writeAsBytes(pdfBytes);


      // Open the PDF file
      await OpenFile.open(filePath);


      // print("PDF saved at: $filePath");
    } catch (e) {
      // print("Error saving PDF: $e");
    }
  }


  Future<Uint8List> generateCateringInvoice(Map<String, dynamic> data) async {
    final pdf = pw.Document();


    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);


    final imageBytes = await rootBundle.load('assets/MAAMAAS.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());


    String formatAmount(dynamic value) {
      if (value == null) return '0.00';
      return double.tryParse(value.toString())?.toStringAsFixed(2) ?? '0.00';
    }


    final List items = List.from(data['items'] ?? []);


    pw.Widget keyValue(String key, String value, {bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start, // 👈 important
          children: [
            pw.SizedBox(
              width: 90, // 👈 fixed width for label
              child: pw.Text(
                key,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              // 👈 allows wrapping
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }


    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ================= HEADER =================
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(width: 60, height: 60, child: pw.Image(image)),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'MAAMAAS CATERING',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'CATERING INVOICE',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Divider(),


          // ================= ORDER + EVENT INFO =================
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LEFT SIDE - ORDER DETAILS
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue(
                        'Order ID',
                        data['orderId']?.toString() ?? 'N/A',
                      ),
                      keyValue('Order Date', data['orderDate'] ?? 'N/A'),
                      keyValue(
                        'Payment Method',
                        data['paymentMethod'] ?? 'N/A',
                      ),
                      keyValue(
                        'Transaction ID',
                        data['transactionId'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),


                pw.SizedBox(width: 20),


                // RIGHT SIDE - EVENT DETAILS
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue('Event Type', data['eventType'] ?? 'N/A'),
                      keyValue('Event Date', data['eventDate'] ?? 'N/A'),
                      keyValue('Event Time', data['eventTime'] ?? 'N/A'),
                      keyValue('Guests', data['people']?.toString() ?? '0'),
                      keyValue('Location', data['location'] ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ),


          pw.SizedBox(height: 20),


          // ================= ITEMS TABLE =================
          pw.Text(
            'Catering Items',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),


          pw.TableHelper.fromTextArray(
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
            headers: ['#', 'Item', 'Qty', 'Price', 'Total'],
            data: List.generate(items.length, (index) {
              final item = items[index];
              return [
                (index + 1).toString(),
                item['name'] ?? 'N/A',
                item['quantity'].toString(),
                "₹${formatAmount(item['price'])}",
                "₹${formatAmount(item['totalPrice'])}",
              ];
            }),
          ),


          pw.SizedBox(height: 20),


          // ================= BILL SUMMARY =================
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 240,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Billing Summary',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),


                  keyValue('Sub Total', "₹${formatAmount(data['subtotal'])}"),
                  keyValue('SGST', "₹${formatAmount(data['sgst'])}"),
                  keyValue('CGST', "₹${formatAmount(data['cgst'])}"),
                  keyValue(
                    'Platform Fee',
                    "₹${formatAmount(data['platformFeeAmount'])}",
                  ),


                  pw.Divider(height: 12),


                  keyValue(
                    'Grand Total',
                    "₹${formatAmount(data['total'])}",
                    bold: true,
                  ),
                ],
              ),
            ),
          ),


          pw.SizedBox(height: 30),


          // ================= FOOTER =================
          pw.Center(
            child: pw.Text(
              'Thank you for choosing MAAMAAS Catering TableServices',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );


    return pdf.save();
  }


  Future<void> _submitRating(int rating) async {
    setState(() {
      _isSubmittingRating = true;
    });


    try {
      // If you have a text field later, you can replace this
      final feedback = "No feedback";


      await catering_authservice.submitUserFeedback(
        orderId: widget.order.id,
        feedback: feedback,
        rating: rating,
      );


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your $rating★ rating!'),
          backgroundColor: Colors.green,
        ),
      );


      widget.onRatingSubmitted?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit feedback. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingRating = false;
      });
    }
  }


  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }


  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat(
      'dd MMM yyyy',
    ).format(widget.order.orderDateTime);
    final formattedTime = DateFormat(
      'hh:mm a',
    ).format(widget.order.orderDateTime);


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Order #${widget.order.id}"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${widget.order.id}",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Chip(
                label: Text(
                  widget.order.orderStatus.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _getStatusColor(widget.order.orderStatus),
              ),
            ],
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  _infoRow(Icons.calendar_today, "Date", formattedDate),
                  _infoRow(Icons.access_time, "Time", formattedTime),
                ],
              ),
            ),
          ),


          const SizedBox(height: 16),


          SizedBox(height: 14.h),
          Text(
            "Delivery Details",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),


          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  _infoRow(
                    Icons.event,
                    "Catering Date",
                    widget.order.cateringDate,
                  ),
                  _infoRow(
                    Icons.schedule,
                    "Catering Time",
                    widget.order.cateringTime,
                  ),
                  _infoRow(
                    Icons.person,
                    "Name",
                    widget.order.deliveryUserName?.toUpperCase() ?? "",
                  ),


                  _infoRow(Icons.phone, "Mobile", widget.order.mobileNo),
                  _infoRow(
                    Icons.location_on,
                    "Address",
                    widget.order.deliveryAddress,
                  ),
                ],
              ),
            ),
          ),


          // Order Items
          _buildDetailCard(
            title: "Order Items",
            children: [
              ...widget.order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Qty: ${item.quantity}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            "₹${item.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (item.packageItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item.packageItems.map((pkgItem) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  "• ${pkgItem.itemName}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),


          const SizedBox(height: 16),


          // Price Breakdown
          _buildDetailCard(
            title: "Price Breakdown",
            children: [
              _buildPriceRow("Subtotal", widget.order.subtotal),
              _buildPriceRow("SGST", widget.order.sgst),
              _buildPriceRow("CGST", widget.order.cgst),
              _buildPriceRow("Platform Fee", widget.order.platformFeeAmount),
              _buildPriceRow("Delivery Fee", widget.order.deliveryFee),
              const Divider(height: 24),
              _buildPriceRow("Total Amount", widget.order.total, isTotal: true),
            ],
          ),


          const SizedBox(height: 20),
          if (widget.order.orderStatus == "DELIVERED") _buildRatingSection(),
          const SizedBox(height: 10),


          // Download Invoice Button
          if (widget.order.orderStatus == "DELIVERED")
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.receipt_long,
                  size: 20.sp,
                  color: Colors.white,
                ),
                label: Text(
                  "Download Invoice",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  elevation: 0,
                ),
                onPressed: () => _downloadInvoice(),
              ),
            ),


          const SizedBox(height: 20),


          _buildActiveTicket(context),
        ],
      ),
    );
  }


  Widget _infoRow(
      IconData icon,
      String label,
      String value, {
        Color? valueColor,
        bool isBold = false,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: valueColor ?? Colors.black87,
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


  Widget _buildRatingSection() {
    final hasRating = widget.order.rating > 0;


    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasRating) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      "Thank you for your rating!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.order.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.orange,
                          size: 32,
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${widget.order.rating}/5 Stars",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                "How was your order experience?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              Center(child: _buildRatingStars()),
              SizedBox(height: 16),
              if (_isSubmittingRating)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildRatingStars() {
    int selectedRating = 0;


    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                    _submitRating(selectedRating);
                  },
                  child: Icon(
                    index < selectedRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.orange,
                    size: 40,
                  ),
                );
              }),
            ),
            // SizedBox(height: 8),
            // Text(
            //   selectedRating == 0
            //       ? "Tap to rate"
            //       : "Submit ${selectedRating} star${selectedRating > 1 ? 's' : ''}?",
            //   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            // ),
          ],
        );
      },
    );
  }


  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }


  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActiveTicket(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Need Help?",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Having issues with this order?",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateTicketScreen(orderId: widget.order.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                backgroundColor: Colors.orange[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Raise Ticket",
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class EnquiryCard extends StatefulWidget {
  final CateringEnquiry enquiry;
  const EnquiryCard({super.key, required this.enquiry});


  @override
  State<EnquiryCard> createState() => _EnquiryCardState();
}


class _EnquiryCardState extends State<EnquiryCard> {
  bool _isExpanded = false;


  String get leadId => widget.enquiry.id.toString();


  @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: () => Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (_) => EnquiryDetailsScreen(enquiry: enquiry),
  //           ),
  //         ),
  //         borderRadius: BorderRadius.circular(20),
  //         child: Padding(
  //           padding: EdgeInsets.all(20.w),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Header with Badge
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Container(
  //                     padding: EdgeInsets.symmetric(
  //                       horizontal: 12.w,
  //                       vertical: 6.h,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: [Colors.blue[400]!, Colors.blue[600]!],
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                       ),
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Text(
  //                           'ENQUIRY #${enquiry.id}',
  //                           style: TextStyle(
  //                             fontSize: 11.sp,
  //                             fontWeight: FontWeight.w700,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Container(
  //                     padding: EdgeInsets.symmetric(
  //                       horizontal: 12.w,
  //                       vertical: 6.h,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[100],
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Text(
  //                           enquiry.eventType,
  //                           style: TextStyle(
  //                             color: Colors.black,
  //                             fontSize: 12.sp,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         Icon(
  //                           Icons.arrow_forward_ios,
  //                           size: 12.w,
  //                           color: Colors.black,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 16.h),
  //
  //               // Customer Info
  //               Row(
  //                 children: [
  //                   Container(
  //                     padding: EdgeInsets.all(8.w),
  //                     decoration: BoxDecoration(
  //                       color: Colors.orange[50],
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: Icon(
  //                       Icons.person_outline,
  //                       size: 16.w,
  //                       color: Colors.orange[700],
  //                     ),
  //                   ),
  //                   SizedBox(width: 12.w),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           enquiry.fullName,
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w600,
  //                             fontSize: 14.sp,
  //                           ),
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                         SizedBox(height: 2.h),
  //                         Text(
  //                           enquiry.eventType,
  //                           style: TextStyle(
  //                             color: Colors.grey[600],
  //                             fontSize: 12.sp,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 16.h),
  //
  //               // Event Details
  //               Column(
  //                 children: [
  //                   _buildInfoItem(
  //                     Icons.calendar_today_outlined,
  //                     enquiry.eventDate,
  //                   ),
  //                   SizedBox(height: 16.w),
  //                   _buildInfoItem(
  //                     Icons.access_time_outlined,
  //                     enquiry.eventTime,
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 16.h),
  //
  //               // Plate Count
  //               Wrap(
  //                 spacing: 8.w,
  //                 runSpacing: 8.h,
  //                 children: [
  //                   if (enquiry.vegPlates > 0)
  //                     _buildPlateCount('Veg', enquiry.vegPlates, Colors.green),
  //                   if (enquiry.nonVegPlates > 0)
  //                     _buildPlateCount(
  //                       'Non-Veg',
  //                       enquiry.nonVegPlates,
  //                       Colors.red,
  //                     ),
  //                   if (enquiry.mixedPlates > 0)
  //                     _buildPlateCount(
  //                       'Mixed',
  //                       enquiry.mixedPlates,
  //                       Colors.orange,
  //                     ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    final enquiry = widget.enquiry;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),


          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EnquiryDetailsScreen(enquiry: enquiry),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ENQ#${enquiry.id}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // setState(() {
                          //   _isExpanded = !_isExpanded;
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EnquiryDetailsScreen(enquiry: enquiry),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // 👈 important to avoid stretching
                            children: [
                              Text(
                                enquiry.eventType,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_right,
                                size: 18.w,
                                color: Colors.black,
                              ),
                              // AnimatedRotation(
                              //   turns: _isExpanded ? 0.5 : 0,
                              //   duration: const Duration(milliseconds: 300),
                              //   child: Icon(
                              //     Icons.keyboard_arrow_down,
                              //     size: 18.w,
                              //     color: Colors.black,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.calendar_today_outlined,
                        enquiry.eventDate,
                      ),
                      SizedBox(width: 16.w),
                      _buildInfoItem(
                        Icons.access_time_outlined,
                        enquiry.eventTime,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),


                  // if (_isExpanded) ...[
                  //   Wrap(
                  //     spacing: 8.w,
                  //     runSpacing: 8.h,
                  //     children: [
                  //       if (enquiry.vegPlates > 0)
                  //         _buildPlateCount(
                  //           'Veg',
                  //           enquiry.vegPlates,
                  //           Colors.green,
                  //         ),
                  //       if (enquiry.nonVegPlates > 0)
                  //         _buildPlateCount(
                  //           'Non-Veg',
                  //           enquiry.nonVegPlates,
                  //           Colors.red,
                  //         ),
                  //       if (enquiry.mixedPlates > 0)
                  //         _buildPlateCount(
                  //           'Mixed',
                  //           enquiry.mixedPlates,
                  //           Colors.orange,
                  //         ),
                  //     ],
                  //   ),
                  //   VendorQuotationContent(
                  //     leadId: enquiry.id.toString(),
                  //     items: enquiry.items,
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildExpandedRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }


  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Widget _buildPlateCount(String type, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$type: $count',
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class EnquiryDetailsScreen extends StatefulWidget {
  final CateringEnquiry enquiry;


  const EnquiryDetailsScreen({super.key, required this.enquiry});


  @override
  State<EnquiryDetailsScreen> createState() => _EnquiryDetailsScreenState();
}


class _EnquiryDetailsScreenState extends State<EnquiryDetailsScreen> {
  late String leadId;


  @override
  void initState() {
    super.initState();
    leadId = widget.enquiry.id.toString();
  }


  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Enquiry #${widget.enquiry.id}"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildDetailCard(
              icon: Icons.person_outline,
              iconColor: Colors.purple,
              children: [
                _buildDetailRow(
                  "Full Name",
                  widget.enquiry.fullName.toUpperCase(),
                ),
                _buildDetailRow("Email", widget.enquiry.email),
                _buildDetailRow("Phone", widget.enquiry.phoneNumber),


                _buildDetailRow("Event Type", widget.enquiry.eventType),
                _buildDetailRow(
                  "Event Date",
                  formatDate(widget.enquiry.eventDate),
                ),
                _buildDetailRow(
                  "Event Time",
                  formatTime(widget.enquiry.eventTime),
                ),


                _buildDetailRow("Address", widget.enquiry.fullAddress),
                _buildDetailRow(
                  "City",
                  capitalizeFirst(widget.enquiry.city ?? ""),
                ),
                _buildDetailRow(
                  "State",
                  capitalizeFirst(widget.enquiry.state ?? ""),
                ),
                _buildDetailRow(
                  "Country",
                  capitalizeFirst(widget.enquiry.country ?? ""),
                ),
                SizedBox(height: 10),


                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (widget.enquiry.vegPlates > 0)
                      _buildPlateCount(
                        'Veg',
                        widget.enquiry.vegPlates,
                        Colors.green,
                      ),
                    if (widget.enquiry.nonVegPlates > 0)
                      _buildPlateCount(
                        'Non-Veg',
                        widget.enquiry.nonVegPlates,
                        Colors.red,
                      ),
                    if (widget.enquiry.mixedPlates > 0)
                      _buildPlateCount(
                        'Mixed',
                        widget.enquiry.mixedPlates,
                        Colors.orange,
                      ),
                  ],
                ),
              ],
            ),


            if (widget.enquiry.items.isNotEmpty)
              _buildItemsCard(widget.enquiry.items),
            SizedBox(height: 10),


            _buildAddOnsCard(widget.enquiry.addOns),


            VendorQuotationContent(leadId: leadId, items: widget.enquiry.items),
          ],
        ),
      ),
    );
  }


  Widget _buildPlateCount(String type, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$type: $count',
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAddOnsCard(List<AddOn> addOns) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.add_circle_outline, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Add-ons",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),


            ...addOns.map((addOn) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        addOn.addOnType.replaceAll('_', ' '),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),


                    Text(
                      "Qty: ${addOn.quantity}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }


  Widget _buildItemsCard(List<String> items) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.list_alt_outlined, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Requested Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),


            ...items.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 14)),
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


  // 🔹 Helper: Builds a section card
  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...children],
        ),
      ),
    );
  }


  // 🔹 Helper: Builds a single detail row
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }


  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString; // fallback if parse fails
    }
  }


  String formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return timeString; // fallback if parse fails
    }
  }
}


class VendorQuotationContent extends StatefulWidget {
  final String leadId;
  final List<String> items;


  const VendorQuotationContent({
    super.key,
    required this.leadId,
    required this.items,
  });


  @override
  State<VendorQuotationContent> createState() => _VendorQuotationContentState();
}


class _VendorQuotationContentState extends State<VendorQuotationContent> {
  List<VendorQuotation> quotations = [];
  bool isLoading = false;


  bool isPrepaid = true;
  late Razorpay _razorpay;
  bool _isLoading = false;
  bool _paymentCompleted = false;
  VendorQuotation? _selectedQuotation;


  String? errorMessage;


  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadQuotations();
  }


  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("✅ Payment Success: ${response.paymentId}");

    try {
      // 1️⃣ Capture
      try {
        final captured = await catering_authservice.capturePayment(
          paymentId: response.paymentId!,
          amount: _selectedQuotation!.grandTotal,
        );
        debugPrint("💰 Capture status: $captured");
      } catch (e) {
        debugPrint("⚠️ Capture API failed (ignored): $e");
      }

      // 2️⃣ Record Payment
      await _recordPayment(
        'PREPAID',
        'Online_Payment',
        razorpayPaymentId: response.paymentId,
        razorpayOrderId: response.orderId,
        razorpaySignature: response.signature,
      );

      // ✅ 3️⃣ REFRESH QUOTATIONS HERE
      await _loadQuotations();

      // 4️⃣ Hide Pay Now button
      if (mounted) {
        setState(() {
          _paymentCompleted = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Payment record failed: $e");

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error - Code: ${response.code}');
    debugPrint('❌ Payment Error - Message: ${response.message}');


    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }


  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('👛 External Wallet: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }


  void _openRazorpayCheckout(double amount, String orderId) {
    var options = {
      'key': 'rzp_test_TJECsclCivENpY',
      'amount': (_selectedQuotation!.grandTotal * 100).toInt(),
      'name': 'Maamaas App',
      'description': 'Catering Order Payment',
      'currency': 'INR',
      'prefill': {'contact': '9999999999', 'email': 'customer@email.com'},
    };


    try {
      _razorpay.open(options);
      debugPrint('✅ Razorpay checkout opened');
    } catch (e) {
      debugPrint('❌ Razorpay error: $e');
      setState(() => _isLoading = false);
    }
  }


  Future<void> _recordPayment(
      String paymentType,
      String paymentMethod, {
        String? razorpayPaymentId,
        String? razorpayOrderId,
        String? razorpaySignature,
      }) async {
    debugPrint('📝 Recording payment:');
    debugPrint('  - Type: $paymentType');
    debugPrint('  - Method: $paymentMethod');


    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');
      final quotation = _selectedQuotation!;


      debugPrint('📦 Extracted data:');
      debugPrint('  - quotationId: ${quotation.quotationId}');
      debugPrint('  - leadId: ${quotation.leadId}');
      debugPrint('  - userId: ${quotation.userId}');
      debugPrint('  - amount: ${quotation.grandTotal}');


      if (quotation.quotationId == null ||
          quotation.leadId == null ||
          customerId == null) {
        debugPrint(
          '❌ Missing required info - quotationId: ${quotation.quotationId}, leadId: ${quotation.leadId}, customerId: $customerId',
        );
        throw Exception('Missing required information');
      }


      final queryParams = <String, String>{
        'quotationId': quotation.quotationId.toString(),
        'leadId': quotation.leadId.toString(),
        'customerId': customerId,
        'amount': quotation.grandTotal.toStringAsFixed(2),
        'paymentType': paymentType,
        'paymentMethod': paymentMethod, // ✅ ADD THIS BACK
        if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
        if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
        if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
      };


      debugPrint('🔗 Query params: $queryParams');


      final endpoint =
          'api/user/quotation/payment?${Uri(queryParameters: queryParams).query}';
      debugPrint('🌐 API Endpoint: $endpoint');
      debugPrint('🚀 Calling ApiClient.post...');


      final response = await ApiClient.post(endpoint, {}, service: 'catering');
      debugPrint('📡 API Response - Status: ${response.statusCode}');
      debugPrint('📡 API Response - Body: ${response.body}');


      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Payment recorded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment: PREPAID (Online)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('❌ API Error - Status: ${response.statusCode}');
        throw Exception(
          'Failed to record payment - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _recordPayment: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      debugPrint('🏁 Payment recording complete');
      setState(() => _isLoading = false);
    }
  }


  void _confirmOrder(VendorQuotation quotation) async {
    setState(() {
      _isLoading = true;
      _selectedQuotation = quotation;
    });


    final orderId = await catering_authservice.createOrder(
      quotation.quotedAmount,
    );


    _openRazorpayCheckout(quotation.quotedAmount, orderId!);
  }


  Future<void> _loadQuotations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });


    try {
      final result = await catering_authservice.loadQuotations(
        leadId: widget.leadId,
      );


      setState(() {
        quotations = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'selected':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'paid':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }


  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'selected':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'paid':
        return Icons.payment;
      default:
        return Icons.help;
    }
  }


  Widget _buildQuotationCard(VendorQuotation quotation) {
    final status = quotation.status.toUpperCase();
    final paymentStatus = quotation.paymentStatus?.toUpperCase();

    return Card(
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 Vendor Name + Status Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quotation.vendorName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    /// Quotation Status Chip
                    if (status != "SUBMITTED")
                      Chip(
                        label: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                        _getStatusColor(status).withOpacity(0.1),
                        avatar: Icon(
                          _getStatusIcon(status),
                          size: 14,
                          color: _getStatusColor(status),
                        ),
                      ),

                    const SizedBox(height: 6),

                    /// Payment Status Chip
                    if (paymentStatus != null)
                      Chip(
                        label: Text(
                          paymentStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                        _getPaymentStatusColor(paymentStatus),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            _buildKeyValue('Total Plates', quotation.totalPlates),
            _buildKeyValue('Veg / Plate', quotation.vegPerPlatePrice),
            _buildKeyValue('Non-Veg / Plate', quotation.nonVegPerPlatePrice),
            _buildKeyValue('Mixed / Plate', quotation.mixedPerPlatePrice),

            /// 🔹 Add Ons
            if (quotation.addOnPrices.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Add-Ons",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...quotation.addOnPrices.map((addOn) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatAddOnType(addOn.addOnType),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        "₹${addOn.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 16),

            /// 🔹 Quoted Amount Highlight
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Quoted Amount",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${quotation.quotedAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// 🔹 Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// View Breakdown (Only if SELECTED)
                if (status == "SELECTED")
                  OutlinedButton(
                    onPressed: () {
                      _showQuotationDetailsBottomSheet(context, quotation);
                    },
                    child: const Text("View Price Breakdown"),
                  ),

                /// Accept Button
                if (status == "SUBMITTED")
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final success =
                        await catering_authservice
                            .selectQuotation(quotation.quotationId);

                        if (success) {
                          await _loadQuotations();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Quotation accepted successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),

                /// Pay Now Button
                if (status == "SELECTED" &&
                    paymentStatus != "SUCCESS")
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _confirmOrder(quotation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Pay Now'),
                  ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Color _getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'INITIATED':
        return Colors.blue;
      case 'REFUNDED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatAddOnType(String type) {
    return type
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
    )
        .join(' ');
  }


  void _showQuotationDetailsBottomSheet(
      BuildContext context,
      VendorQuotation quotation,
      ) {
    final double total =
        quotation.quotedAmount +
            quotation.cgstAmount +
            quotation.sgstAmount +
            quotation.platformFee +
            quotation.deliveryFee;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Drag Indicator
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),


                const Text(
                  "Quotation Price Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),


                const SizedBox(height: 20),


                _buildDetailRow("Quoted Amount", quotation.quotedAmount),
                _buildDetailRow("CGST", quotation.cgstAmount),
                _buildDetailRow("SGST", quotation.sgstAmount),
                _buildDetailRow("Platform Fee", quotation.platformFee),
                _buildDetailRow("Delivery Fee", quotation.deliveryFee),


                const Divider(height: 30),


                _buildDetailRow("Grand Total", total, isBold: true),


                const SizedBox(height: 20),


                /// Pay Now Button
                Row(
                  children: [
                    if (quotation.status.toUpperCase() == "SELECTED") ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                            Navigator.pop(context);
                            _confirmOrder(quotation);
                          },

                          child: const Text(
                            "Pay Now",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),


                      const SizedBox(width: 12), // ✅ correct spacing
                    ],


                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildDetailRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildKeyValue(String label, num value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value is double ? value.toStringAsFixed(2) : value.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0), // matches outer screen padding
      child: isLoading || errorMessage != null || quotations.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Vendor Quotations',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have any vendor quotations yet',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ) // icons, text etc inside column
          : RefreshIndicator(
        onRefresh: _loadQuotations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Vendor Quotations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 12),
              Column(
                children: quotations
                    .map((q) => _buildQuotationCard(q))
                    .toList(),
              ),
              const SizedBox(
                height: 24,
              ), // 👈 important for pull-to-refresh
            ],
          ),
        ),
      ),
    );
  }
}


class AppStyles {
  static EdgeInsets get cardPadding => EdgeInsets.all(16.w);
  static EdgeInsets get sectionPadding => EdgeInsets.symmetric(vertical: 8.h);
  static TextStyle get titleStyle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static TextStyle get subtitleStyle =>
      TextStyle(fontSize: 14.sp, color: Colors.grey[600]);
}

