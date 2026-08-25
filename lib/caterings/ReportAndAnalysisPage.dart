import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Navigation pages
import '../CateringModels/DashboardModel.dart';
import '../Report&Analysis/screens/reports_screen.dart';
import '../food&beverages/Report&Analysis.dart';
import '../widgets_helper/Home_screen_1.dart';

// Add enum for vertical selection
enum CateringReportVertical { food, catering }

class ReportAndAnalysisPagecatering extends StatefulWidget {
  const ReportAndAnalysisPagecatering({super.key});

  @override
  State<ReportAndAnalysisPagecatering> createState() =>
      _ReportAndAnalysisPageState();
}

class _ReportAndAnalysisPageState extends State<ReportAndAnalysisPagecatering> {
  int _selectedIndex = 0;
  bool isLoading = true;
  bool isLoadingCustom = false;
  bool isLoadingDetailed = false;
  DashboardModel? dashboardData;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  String vendorId = '1';
  String errorMessage = '';
  bool showDatePickerModal = false;
  String activeView = 'financial';
  bool showWeekDetails = false;
  int? selectedBarIndex;
  int? selectedPieIndex;

  // Add vertical selection
  CateringReportVertical _selectedVertical = CateringReportVertical.catering;

  // Colors
  final Map<String, Color> colors = {
    'primary': const Color(0xFF7c3aed),
    'secondary': const Color(0xFF10b981),
    'accent': const Color(0xFFf59e0b),
    'danger': const Color(0xFFef4444),
    'info': const Color(0xFF3b82f6),
    'success': const Color(0xFF10b981),
  };

  @override
  void initState() {
    super.initState();
    _initializeDateControllers();
    _loadVendorId();
  }

  void _initializeDateControllers() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    fromDateController.text = dateFormat.format(fromDate);
    toDateController.text = dateFormat.format(toDate);
  }

  Future<void> _loadVendorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dynamic vendorIdValue = prefs.get('vendorId');

      if (vendorIdValue != null) {
        vendorId = vendorIdValue.toString();
        print('✅ Loaded vendorId: $vendorId');
      } else {
        vendorId = '1';
        print('⚠️ No vendorId found, using default: $vendorId');
      }

      await fetchCustomDashboardData();
    } catch (e) {
      print('❌ Error loading vendorId: $e');
      vendorId = '1';
      await fetchCustomDashboardData();
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('🔑 Token retrieved: ${token != null ? 'Yes' : 'No'}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  Future<void> fetchCustomDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final token = await _getToken();

    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "Authentication token not found. Please log in again.";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session expired. Please log in again."),
          backgroundColor: Colors.red,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacementNamed('/login');
      });

      return;
    }

    print('🆔 Using vendorId: $vendorId');

    if (fromDate.isAfter(toDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("From date cannot be after to date")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url =
        Uri.parse(
          // 'http://staging.maamaas.com:8080/catering/api/dashboard/custom',
          'http://staging.maamaas.com:8080/catering/api/dashboard/custom',
        ).replace(
          queryParameters: {
            'vendorId': vendorId,
            'fromDate': fromDateController.text,
            'toDate': toDateController.text,
          },
        );

    print('📊 Fetching custom dashboard from: $url');
    print(
      '📅 Date range: ${fromDateController.text} to ${toDateController.text}',
    );

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'accept': '*/*',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📊 Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Response Data: $data');

        setState(() {
          dashboardData = DashboardModel.fromJson(data);
          isLoading = false;
        });

        print('✅ Dashboard data loaded successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data loaded for period: ${dashboardData?.period ?? ''}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('🚫 Authentication error: ${response.statusCode}');

        setState(() {
          isLoading = false;
          errorMessage = "Authentication failed. Please log in again.";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Authentication failed. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed('/login');
        });
      } else {
        print('❌ Server error: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');

        setState(() {
          isLoading = false;
          errorMessage = "Server error: ${response.statusCode}";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server error: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Network error: $e');
      setState(() {
        isLoading = false;
        errorMessage = "Network error: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getDaysDifference(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₹${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  void _handleViewToggle(String view) {
    setState(() {
      activeView = view;
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
        fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate,
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
        toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleDateRangeApply() {
    fetchCustomDashboardData();
    setState(() {
      showDatePickerModal = false;
    });
  }

  void _handleDateRangeCancel() {
    setState(() {
      showDatePickerModal = false;
    });
  }

  // Add method for vertical chips
  Widget _buildVerticalChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: CateringReportVertical.values.map((vertical) {
          final isSelected = _selectedVertical == vertical;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedVertical = vertical);
                _handleVerticalSelection(vertical);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? _getVerticalColor(vertical)
                          : Colors.white,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: _getVerticalColor(vertical).withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? _getVerticalColor(vertical)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _verticalIcon(vertical),
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : _getVerticalColor(vertical),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getShortLabel(vertical),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? _getVerticalColor(vertical)
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getShortLabel(CateringReportVertical v) {
    switch (v) {
      case CateringReportVertical.food:
        return "Food";
      case CateringReportVertical.catering:
        return "Catering";
    }
  }

  IconData _verticalIcon(CateringReportVertical v) {
    switch (v) {
      case CateringReportVertical.food:
        return Icons.fastfood;
      case CateringReportVertical.catering:
        return Icons.restaurant;
    }
  }

  Color _getVerticalColor(CateringReportVertical v) {
    switch (v) {
      case CateringReportVertical.food:
        return const Color(0xFFB15DC6);
      case CateringReportVertical.catering:
        return const Color(0xFF2196F3);
    }
  }

  void _handleVerticalSelection(CateringReportVertical vertical) {
    if (vertical == CateringReportVertical.food) {
      // Navigate to the food report page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReportsScreen()),
      );
    } else {
      // For catering, just refresh the current data
      print('Selected vertical: Catering');
      fetchCustomDashboardData();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeWrapper()),
    );
  }

  // Custom Range Selector
  Widget _buildCustomRangeSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showDatePickerModal = !showDatePickerModal;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors['primary']!, const Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'Custom Range',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () => _exportReport(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors['primary'],
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: colors['primary']!.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'Export',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  void _exportReport() {
    if (dashboardData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No data to export"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final exportData = {
      'period': dashboardData?.period ?? '',
      'totalRevenue': dashboardData?.totalRevenue ?? 0,
      'totalOrders': dashboardData?.totalOrders ?? 0,
      'totalCustomers': dashboardData?.totalCustomers ?? 0,
      'successRate': dashboardData?.successRate ?? '0%',
      'dailyRevenue': dashboardData?.todayRevenue ?? 0,
      'dailyOrders': dashboardData?.todayOrders ?? 0,
      'topSellingItems': dashboardData?.topSellingItems
          .map((item) => {'item': item.item, 'quantity': item.quantity})
          .toList(),
      'paymentDistribution': dashboardData?.paymentDistribution
          .map(
            (payment) => {
              'method': payment.method,
              'count': payment.count,
              'percentage': payment.percentage,
            },
          )
          .toList(),
    };

    final jsonString = jsonEncode(exportData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report exported successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    print('📤 Export Data: $jsonString');
  }

  // View Toggles
  Widget _buildViewToggles() {
    final views = [
      {'key': 'financial', 'label': 'Financial', 'color': colors['success']!},
      {'key': 'revenue', 'label': 'Revenue', 'color': Colors.blue},
      {'key': 'orders', 'label': 'Orders', 'color': const Color(0xFF9c27b0)},
      {'key': 'rating', 'label': 'Rating', 'color': Colors.orange},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: views.map((view) {
          final isSelected = activeView == view['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => _handleViewToggle(view['key'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? view['color'] as Color
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (view['color'] as Color).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    view['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748b),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // FIXED: Single Card with all metrics horizontally scrollable
  Widget _buildMetricsCard() {
    if (isLoading && dashboardData == null) {
      return _buildLoadingShimmer();
    }

    double getTotalRevenue() {
      return dashboardData?.totalRevenue ?? 0;
    }

    int getTotalOrders() {
      return dashboardData?.totalOrders ?? 0;
    }

    String getSuccessRate() {
      return dashboardData?.successRate ?? "0%";
    }

    int getTotalCustomers() {
      return dashboardData?.totalCustomers ?? 0;
    }

    int getDailyOrders() {
      return dashboardData?.todayOrders ?? 0;
    }

    double getDailyRevenue() {
      return dashboardData?.todayRevenue ?? 0;
    }

    List<Map<String, dynamic>> getMetricsData() {
      switch (activeView) {
        case 'financial':
          return [
            {
              'title': 'Total Revenue',
              'value': _formatCurrency(getTotalRevenue()),
              'icon': Icons.currency_rupee,
              'color': colors['success']!,
            },
            {
              'title': 'Total Orders',
              'value': getTotalOrders().toString(),
              'icon': Icons.shopping_bag,
              'color': colors['info']!,
            },
            {
              'title': 'Success Rate',
              'value': getSuccessRate(),
              'icon': Icons.trending_up,
              'color': const Color(0xFF8b5cf6),
            },
            {
              'title': 'Total Customers',
              'value': getTotalCustomers().toString(),
              'icon': Icons.people,
              'color': Colors.orange,
            },
          ];
        case 'revenue':
          return [
            {
              'title': 'Total Revenue',
              'value': _formatCurrency(getTotalRevenue()),
              'icon': Icons.currency_rupee,
              'color': colors['success']!,
            },
            {
              'title': 'Daily Revenue',
              'value': _formatCurrency(getDailyRevenue()),
              'icon': Icons.attach_money,
              'color': Colors.green,
            },
            {
              'title': 'Success Rate',
              'value': getSuccessRate(),
              'icon': Icons.trending_up,
              'color': const Color(0xFF8b5cf6),
            },
            {
              'title': 'Customers',
              'value': getTotalCustomers().toString(),
              'icon': Icons.people,
              'color': Colors.orange,
            },
          ];
        case 'orders':
          return [
            {
              'title': 'Total Orders',
              'value': getTotalOrders().toString(),
              'icon': Icons.shopping_bag,
              'color': Colors.blue,
            },
            {
              'title': 'Daily Orders',
              'value': getDailyOrders().toString(),
              'icon': Icons.today,
              'color': Colors.green,
            },
            {
              'title': 'Success Rate',
              'value': getSuccessRate(),
              'icon': Icons.trending_up,
              'color': const Color(0xFF8b5cf6),
            },
            {
              'title': 'Customers',
              'value': getTotalCustomers().toString(),
              'icon': Icons.people,
              'color': Colors.orange,
            },
          ];
        default:
          return [
            {
              'title': 'Revenue',
              'value': _formatCurrency(getTotalRevenue()),
              'icon': Icons.currency_rupee,
              'color': colors['success']!,
            },
            {
              'title': 'Orders',
              'value': getTotalOrders().toString(),
              'icon': Icons.shopping_bag,
              'color': Colors.blue,
            },
            {
              'title': 'Success',
              'value': getSuccessRate(),
              'icon': Icons.trending_up,
              'color': const Color(0xFF8b5cf6),
            },
            {
              'title': 'Customers',
              'value': getTotalCustomers().toString(),
              'icon': Icons.people,
              'color': Colors.orange,
            },
          ];
      }
    }

    final metricsData = getMetricsData();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and date range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activeView == 'financial'
                      ? 'Financial Overview'
                      : activeView == 'revenue'
                      ? 'Revenue Analysis'
                      : activeView == 'orders'
                      ? 'Orders Analysis'
                      : 'Rating Analysis',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A0947),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${DateFormat('MMM dd').format(fromDate)} - ${DateFormat('MMM dd').format(toDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // SINGLE CARD with horizontally scrollable metrics
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors['primary']!.withOpacity(0.05),
                  colors['secondary']!.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Title inside the card
                Text(
                  activeView == 'financial'
                      ? 'Key Metrics'
                      : activeView == 'revenue'
                      ? 'Revenue Metrics'
                      : activeView == 'orders'
                      ? 'Order Metrics'
                      : 'Rating Metrics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),

                // Horizontally scrollable metrics
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: metricsData.map((metric) {
                      return Container(
                        width: 120, // Fixed width for each metric
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon with background
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (metric['color'] as Color).withOpacity(
                                  0.15,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                metric['icon'] as IconData,
                                size: 24,
                                color: metric['color'] as Color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Value
                            Text(
                              metric['value'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: metric['color'] as Color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Title
                            Text(
                              metric['title'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Loading Shimmer
  Widget _buildLoadingShimmer() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 120, height: 20, color: Colors.grey.shade200),
              Container(width: 80, height: 20, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(width: 100, height: 16, color: Colors.grey.shade200),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 16,
                              color: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 50,
                              height: 12,
                              color: Colors.grey.shade200,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Date Picker Modal
  Widget _buildDatePickerModal() {
    if (!showDatePickerModal) return Container();

    return Positioned(
      top: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe2e8f0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFe2e8f0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF94a3b8),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(fromDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1e293b),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: const Text(
                    'to',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFe2e8f0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF94a3b8),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(toDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1e293b),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFf8fafc),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_getDaysDifference(fromDate, toDate)} days',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748b)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleDateRangeApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['primary'],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoadingCustom
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Apply',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleDateRangeCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFe2e8f0)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748b)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Performance Summary Card (Top section)
  Widget _buildPerformanceSummary() {
    if (dashboardData == null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: const Center(
          child: Text('No data available for selected period'),
        ),
      );
    }

    final totalRevenue = dashboardData?.totalRevenue ?? 0.0;
    final totalOrders = dashboardData?.totalOrders ?? 0;
    final successRate = dashboardData?.successRate ?? "0%";
    final totalCustomers = dashboardData?.totalCustomers ?? 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Performance Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A0947),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${DateFormat('MMM dd').format(fromDate)} - ${DateFormat('MMM dd').format(toDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Single scrollable card for summary
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors['primary']!.withOpacity(0.1),
                  colors['secondary']!.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Quick Overview',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSummaryMetric(
                        'Revenue',
                        _formatCurrency(totalRevenue),
                        colors['success']!,
                        Icons.currency_rupee,
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryMetric(
                        'Orders',
                        totalOrders.toString(),
                        colors['info']!,
                        Icons.shopping_bag,
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryMetric(
                        'Success',
                        successRate,
                        const Color(0xFF8b5cf6),
                        Icons.trending_up,
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryMetric(
                        'Customers',
                        totalCustomers.toString(),
                        Colors.orange,
                        Icons.people,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 26, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Top Selling Items Chart
  Widget _buildTopSellingItemsChart() {
    if (dashboardData == null || dashboardData!.topSellingItems.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.bar_chart, size: 50, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  "No top selling items data available",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  "Period: ${dashboardData?.period ?? 'No period'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = dashboardData!.topSellingItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final colors = [
        Colors.green,
        Colors.orange,
        Colors.blue,
        Colors.purple,
        Colors.red,
        Colors.teal,
        Colors.pink,
        Colors.indigo,
      ];
      return {
        "label": item.item,
        "quantity": item.quantity,
        "color": colors[index % colors.length],
      };
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Top Selling Items",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Period: ${dashboardData?.period ?? ''}",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                        reservedSize: 25,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < items.length) {
                            final label =
                                items[value.toInt()]["label"] as String;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label.length > 6
                                    ? '${label.substring(0, 6)}...'
                                    : label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final color = item["color"] as Color;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (item["quantity"] as num).toDouble(),
                          color: color,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: items.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (e["color"] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: e["color"] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        e["label"] as String,
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${e["quantity"]})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Payment Distribution Pie Chart
  Widget _buildPaymentDistributionPieChart() {
    if (dashboardData == null || dashboardData!.paymentDistribution.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  size: 50,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Payment data will appear here",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  "Select a date range to view payment breakdown",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final payments = dashboardData!.paymentDistribution;
    final totalPayments = payments.fold<int>(
      0,
      (sum, payment) => sum + (payment.count),
    );

    final paymentData = payments.asMap().entries.map((entry) {
      final index = entry.key;
      final payment = entry.value;
      final colors = [
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.red,
      ];

      final percentageString = payment.percentage.toString();
      final cleanedPercentage = percentageString.replaceAll('%', '');
      final percentageValue = double.tryParse(cleanedPercentage) ?? 0;

      return {
        "label": payment.method.toString().replaceAll('_', ' '),
        "count": payment.count,
        "percentage": payment.percentage.toString(),
        "percentageValue": percentageValue,
        "color": colors[index % colors.length],
      };
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Payment Distribution",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Period: ${dashboardData?.period ?? ''}",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  centerSpaceColor: Colors.grey[50],
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          selectedPieIndex = null;
                          return;
                        }
                        selectedPieIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: paymentData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final e = entry.value;
                    final bool isSelected = selectedPieIndex == index;

                    return PieChartSectionData(
                      color: e["color"] as Color,
                      value: e["percentageValue"] as double,
                      title: "${e["count"]}",
                      radius: isSelected ? 60 : 50,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      titlePositionPercentageOffset: 0.6,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    "Total: $totalPayments",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...paymentData.map((payment) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: payment["color"] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                payment["label"] as String,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          Text(
                            "${payment["count"]} (${payment["percentage"]})",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _navigateToHome, // Navigate directly to home
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Report & Analysis",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            _buildVerticalChips(),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarHeight: 90, // Adjusted height to accommodate the chips
      ),
      body: Column(
        children: [
          // Custom Range Selector at the top
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: _buildCustomRangeSelector(),
          ),

          // Main Content Area
          Expanded(
            child: Stack(
              children: [
                // Main content
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7c3aed),
                        ),
                      )
                    : errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 50,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: fetchCustomDashboardData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors['primary'],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchCustomDashboardData,
                        color: colors['primary'],
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            _buildPerformanceSummary(),
                            const SizedBox(height: 16),
                            _buildViewToggles(),
                            const SizedBox(height: 16),
                            _buildMetricsCard(),
                            const SizedBox(height: 16),
                            _buildTopSellingItemsChart(),
                            const SizedBox(height: 16),
                            _buildPaymentDistributionPieChart(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                // Date picker modal overlay
                if (showDatePickerModal) _buildDatePickerModal(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
