// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/material.dart';
// // import 'package:maamaaspartner/Api/food_authservice.dart';
// // import 'package:intl/intl.dart';
// // import '../Models/food&beverages/custom_model.dart';
// // import '../Models/food&beverages/detailed_statisticsresponse_model.dart';
// // import '../caterings/ReportAndAnalysisPage.dart';
// // import '../widgets_helper/Home_screen_1.dart' hide DailyStat;
// //
// // // Add enum for vertical selection
// // enum ReportVertical { food, catering }
// //
// // class ReportAnalysisPage extends StatefulWidget {
// //   const ReportAnalysisPage({Key? key}) : super(key: key);
// //
// //   @override
// //   State<ReportAnalysisPage> createState() => _ReportAnalysisPageState();
// // }
// //
// // class _ReportAnalysisPageState extends State<ReportAnalysisPage> {
// //   bool _showWeekDetails = false;
// //   int? _selectedBarIndex;
// //   int? _selectedPie;
// //   StatisticsResponse? _statistics;
// //   bool _isLoading = true;
// //   String _errorMessage = '';
// //   bool _isMobile = false;
// //   DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
// //   DateTime _endDate = DateTime.now();
// //   String _activeView = 'financial';
// //   bool _showMobileMenu = false;
// //   bool _showDatePicker = false;
// //   CustomStatisticsResponse? _customStatistics;
// //   bool _isLoadingCustom = false;
// //   DetailedStatisticsResponse? _detailedStatistics;
// //   bool _isLoadingDetailed = false;
// //
// //   // Add vertical selection
// //   ReportVertical _selectedVertical = ReportVertical.food;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchStatistics();
// //     _fetchCustomStatistics();
// //     _fetchDetailedStatistics();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _checkMobile();
// //     });
// //   }
// //
// //   void _checkMobile() {
// //     final width = MediaQuery.of(context).size.width;
// //     setState(() {
// //       _isMobile = width < 768;
// //     });
// //   }
// //
// //   Future<void> _fetchStatistics() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = '';
// //     });
// //
// //     final statistics = await food_authservice.fetchVendorStatistics();
// //
// //     setState(() {
// //       _isLoading = false;
// //
// //       if (statistics != null) {
// //         print(
// //           '✅ Main statistics loaded: Weekly Orders: ${statistics.weeklyOrders}, Weekly Revenue: ${statistics.weeklyRevenue}',
// //         );
// //       } else {
// //         _errorMessage = "Failed to load statistics";
// //       }
// //     });
// //   }
// //
// //   Future<void> _fetchCustomStatistics() async {
// //     try {
// //       final fromDate = DateFormat('yyyy-MM-dd').format(_startDate);
// //       final toDate = DateFormat('yyyy-MM-dd').format(_endDate);
// //
// //       final customStats = await food_authservice.fetchCustomStatistics(
// //         fromDate: fromDate,
// //         toDate: toDate,
// //       );
// //
// //       setState(() {
// //         _customStatistics = customStats;
// //       });
// //
// //       if (customStats != null) {
// //         print('✅ Custom statistics loaded for date range $fromDate to $toDate');
// //         print('   Total Orders: ${customStats.totalOrders}');
// //         print('   Total Revenue: ${customStats.totalRevenue}');
// //         print('   Average Rating: ${customStats.averageRating}');
// //       }
// //     } catch (e) {
// //       print('❌ Error fetching custom statistics: $e');
// //     }
// //   }
// //
// //   Future<void> _updateCustomStatistics() async {
// //     setState(() {
// //       _isLoadingCustom = true;
// //     });
// //
// //     await _fetchCustomStatistics();
// //
// //     setState(() {
// //       _isLoadingCustom = false;
// //     });
// //   }
// //
// //   Future<void> _fetchDetailedStatistics() async {
// //     setState(() {
// //       _isLoadingDetailed = true;
// //     });
// //
// //     try {
// //       final fromDate = DateFormat('yyyy-MM-dd').format(_startDate);
// //       final toDate = DateFormat('yyyy-MM-dd').format(_endDate);
// //
// //       print('🔄 Fetching detailed stats from: $fromDate to $toDate');
// //
// //       final detailedStats = await food_authservice.fetchDetailedStatistics(
// //         fromDate: fromDate,
// //         toDate: toDate,
// //       );
// //
// //       print('✅ fetchDetailedStatistics returned: ${detailedStats != null}');
// //
// //       setState(() {
// //         _detailedStatistics = detailedStats;
// //         _isLoadingDetailed = false;
// //       });
// //
// //       if (detailedStats != null) {
// //         print('✅ Detailed statistics loaded successfully');
// //         print('📊 Period: ${detailedStats.period}');
// //         print('🛒 Total Orders: ${detailedStats.totalOrders}');
// //         print('💰 Total Revenue: ${detailedStats.totalRevenue}');
// //         print('💰 Net Revenue: ${detailedStats.netRevenue}');
// //         print('💰 Gross Revenue: ${detailedStats.grossRevenue}');
// //         print(
// //           '🍽️ Dine-In Orders: ${detailedStats.orderTypeRevenueStats.dineIn.count}',
// //         );
// //         print(
// //           '🍽️ Dine-In Revenue: ${detailedStats.orderTypeRevenueStats.dineIn.revenue}',
// //         );
// //         print(
// //           '🥡 Takeaway Orders: ${detailedStats.orderTypeRevenueStats.takeaway.count}',
// //         );
// //         print(
// //           '🥡 Takeaway Revenue: ${detailedStats.orderTypeRevenueStats.takeaway.revenue}',
// //         );
// //         print(
// //           '🚚 Delivery Orders: ${detailedStats.orderTypeRevenueStats.delivery.count}',
// //         );
// //         print(
// //           '🚚 Delivery Revenue: ${detailedStats.orderTypeRevenueStats.delivery.revenue}',
// //         );
// //         print(
// //           '💳 Online Payment: ${detailedStats.paymentBreakdown.onlinePayment}',
// //         );
// //         print('💵 Cash: ${detailedStats.paymentBreakdown.cash}');
// //         print('👛 Wallet: ${detailedStats.paymentBreakdown.maamaasWallet}');
// //
// //         if (mounted) {
// //           setState(() {});
// //         }
// //       } else {
// //         print('❌ Detailed statistics is null!');
// //       }
// //     } catch (e) {
// //       print('❌ Error fetching detailed statistics: $e');
// //       setState(() {
// //         _isLoadingDetailed = false;
// //       });
// //     }
// //   }
// //
// //   final Map<String, LinearGradient> _gradients = {
// //     'primary': const LinearGradient(
// //       begin: Alignment.topLeft,
// //       end: Alignment.bottomRight,
// //       colors: [Color(0xFF667eea), Color(0xFF764ba2)],
// //     ),
// //   };
// //
// //   final Map<String, Color> _colors = {
// //     'primary': const Color(0xFF7c3aed),
// //     'secondary': const Color(0xFF10b981),
// //     'accent': const Color(0xFFf59e0b),
// //     'danger': const Color(0xFFef4444),
// //     'info': const Color(0xFF3b82f6),
// //     'success': const Color(0xFF10b981),
// //   };
// //
// //   int _getDaysDifference(DateTime start, DateTime end) {
// //     return end.difference(start).inDays + 1;
// //   }
// //
// //   String _formatCurrency(double amount) {
// //     if (amount >= 1000000) {
// //       return '₹${(amount / 1000000).toStringAsFixed(2)}M';
// //     } else if (amount >= 1000) {
// //       return '₹${(amount / 1000).toStringAsFixed(1)}K';
// //     }
// //     return '₹${amount.toStringAsFixed(0)}';
// //   }
// //
// //   void _handleDateRangeApply() {
// //     _fetchCustomStatistics();
// //     _fetchDetailedStatistics();
// //     setState(() {
// //       _showDatePicker = false;
// //     });
// //   }
// //
// //   void _handleDateRangeCancel() {
// //     setState(() {
// //       _showDatePicker = false;
// //     });
// //   }
// //
// //   void _showStartDatePicker() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: _startDate,
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime.now(),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         _startDate = picked;
// //       });
// //     }
// //   }
// //
// //   void _showEndDatePicker() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: _endDate,
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime.now(),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         _endDate = picked;
// //       });
// //     }
// //   }
// //
// //   Widget _buildSummaryCardsSection() {
// //     if (_isLoadingDetailed &&
// //         _detailedStatistics == null &&
// //         _customStatistics == null) {
// //       return _buildLoadingShimmer();
// //     }
// //
// //     double getTotalRevenue() {
// //       return _detailedStatistics?.totalRevenue ??
// //           _customStatistics?.totalRevenue ??
// //           0;
// //     }
// //
// //     int getTotalOrders() {
// //       return _detailedStatistics?.totalOrders ??
// //           _customStatistics?.totalOrders ??
// //           0;
// //     }
// //
// //     String getAverageRating() {
// //       return _detailedStatistics?.averageRating ??
// //           _customStatistics?.averageRating ??
// //           '0.00';
// //     }
// //
// //     double getDailyAverageRevenue() {
// //       final total = getTotalRevenue();
// //       final days = _getDaysDifference(_startDate, _endDate);
// //       return days > 0 ? total / days : 0;
// //     }
// //
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.all(16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Expanded(
// //                 child: Text(
// //                   'Performance Summary',
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFF2A0947),
// //                   ),
// //                 ),
// //               ),
// //               Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Text(
// //                     '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(_endDate)}',
// //                     style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
// //                   ),
// //                   SizedBox(width: 8),
// //                 ],
// //               ),
// //             ],
// //           ),
// //
// //           SizedBox(height: 16),
// //
// //           Container(
// //             margin: EdgeInsets.only(bottom: 16),
// //             padding: EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   Color(0xFF7c3aed).withOpacity(0.1),
// //                   Color(0xFF10B981).withOpacity(0.1),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(16),
// //               border: Border.all(color: Colors.grey.shade200, width: 1),
// //             ),
// //             child: Column(
// //               children: [
// //                 Text(
// //                   'Performance Overview',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.grey.shade800,
// //                   ),
// //                 ),
// //                 SizedBox(height: 12),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                   children: [
// //                     Expanded(
// //                       child: Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 4),
// //                         child: _buildLiveStatItem(
// //                           'Revenue',
// //                           _formatCurrency(getTotalRevenue()),
// //                           Colors.green,
// //                           Icons.currency_rupee,
// //                         ),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 4),
// //                         child: _buildLiveStatItem(
// //                           'Orders',
// //                           getTotalOrders().toString(),
// //                           Colors.blue,
// //                           Icons.shopping_bag,
// //                         ),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 4),
// //                         child: _buildLiveStatItem(
// //                           'Rating',
// //                           getAverageRating(),
// //                           Colors.orange,
// //                           Icons.star,
// //                         ),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 4),
// //                         child: _buildLiveStatItem(
// //                           'Daily Avg',
// //                           _formatCurrency(getDailyAverageRevenue()),
// //                           Colors.purple,
// //                           Icons.timeline,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFinancialCardsSection() {
// //     if (_isLoadingDetailed &&
// //         _detailedStatistics == null &&
// //         _customStatistics == null) {
// //       return _buildLoadingShimmer();
// //     }
// //
// //     double getTotalRevenue() {
// //       return _detailedStatistics?.totalRevenue ??
// //           _customStatistics?.totalRevenue ??
// //           0;
// //     }
// //
// //     int getTotalOrders() {
// //       return _detailedStatistics?.totalOrders ??
// //           _customStatistics?.totalOrders ??
// //           0;
// //     }
// //
// //     String getAverageRating() {
// //       return _detailedStatistics?.averageRating ??
// //           _customStatistics?.averageRating ??
// //           '0.00';
// //     }
// //
// //     double getNetProfit() {
// //       return _detailedStatistics?.netRevenue ?? 0;
// //     }
// //
// //     String getProfitMargin() {
// //       return _detailedStatistics?.profitMargin ?? '0%';
// //     }
// //
// //     double getGrossRevenue() {
// //       return _detailedStatistics?.grossRevenue ?? 0;
// //     }
// //
// //     double getDiscounts() {
// //       final gross = getGrossRevenue();
// //       final total = getTotalRevenue();
// //       return gross > total ? gross - total : 0;
// //     }
// //
// //     int getDineInOrders() {
// //       return _detailedStatistics?.orderTypeRevenueStats.dineIn.count ?? 0;
// //     }
// //
// //     int getTakeawayOrders() {
// //       return _detailedStatistics?.orderTypeRevenueStats.takeaway.count ?? 0;
// //     }
// //
// //     int getDeliveryOrders() {
// //       return _detailedStatistics?.orderTypeRevenueStats.delivery.count ?? 0;
// //     }
// //
// //     double getCashAmount() {
// //       return _detailedStatistics?.paymentBreakdown.cash ?? 0;
// //     }
// //
// //     double getOnlineAmount() {
// //       return _detailedStatistics?.paymentBreakdown.onlinePayment ?? 0;
// //     }
// //
// //     double getWalletAmount() {
// //       return _detailedStatistics?.paymentBreakdown.maamaasWallet ?? 0;
// //     }
// //
// //     int getCashTransactions() {
// //       final totalOrders = getTotalOrders();
// //       final totalRevenue = getTotalRevenue();
// //       final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
// //       return avgOrderValue > 0 ? (getCashAmount() / avgOrderValue).round() : 0;
// //     }
// //
// //     int getOnlineTransactions() {
// //       final totalOrders = getTotalOrders();
// //       final totalRevenue = getTotalRevenue();
// //       final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
// //       return avgOrderValue > 0
// //           ? (getOnlineAmount() / avgOrderValue).round()
// //           : 0;
// //     }
// //
// //     int getWalletTransactions() {
// //       final totalOrders = getTotalOrders();
// //       final totalRevenue = getTotalRevenue();
// //       final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
// //       return avgOrderValue > 0
// //           ? (getWalletAmount() / avgOrderValue).round()
// //           : 0;
// //     }
// //
// //     int getTotalTransactions() {
// //       return getCashTransactions() +
// //           getOnlineTransactions() +
// //           getWalletTransactions();
// //     }
// //
// //     int getTotalReviews() {
// //       return _detailedStatistics?.totalRatings ?? 0;
// //     }
// //
// //     String getResponseRate() {
// //       return '95%';
// //     }
// //
// //     String getResponseTime() {
// //       return '2 min';
// //     }
// //
// //     List<Map<String, dynamic>> getCardsData() {
// //       switch (_activeView) {
// //         case 'financial':
// //           return [
// //             {
// //               'title': 'Total Revenue',
// //               'value': _formatCurrency(getTotalRevenue()),
// //               'icon': Icons.attach_money,
// //               'color': _colors['success']!,
// //             },
// //             {
// //               'title': 'Net Profit',
// //               'value': _formatCurrency(getNetProfit()),
// //               'icon': Icons.account_balance_wallet,
// //               'color': _colors['info']!,
// //             },
// //             {
// //               'title': 'Profit Margin',
// //               'value': getProfitMargin(),
// //               'icon': Icons.trending_up,
// //               'color': const Color(0xFF8b5cf6),
// //             },
// //           ];
// //         case 'revenue':
// //           return [
// //             {
// //               'title': 'Total Revenue',
// //               'value': _formatCurrency(getTotalRevenue()),
// //               'icon': Icons.attach_money,
// //               'color': _colors['success']!,
// //             },
// //             {
// //               'title': 'Total Orders',
// //               'value': getTotalOrders().toString(),
// //               'icon': Icons.shopping_bag,
// //               'color': Colors.blue,
// //             },
// //             {
// //               'title': 'Discounts',
// //               'value': _formatCurrency(getDiscounts()),
// //               'icon': Icons.discount,
// //               'color': Colors.red,
// //             },
// //           ];
// //         case 'orders':
// //           return [
// //             {
// //               'title': 'Total Orders',
// //               'value': getTotalOrders().toString(),
// //               'icon': Icons.shopping_bag,
// //               'color': Colors.blue,
// //             },
// //             {
// //               'title': 'Dine-In',
// //               'value': getDineInOrders().toString(),
// //               'icon': Icons.restaurant,
// //               'color': Colors.green,
// //             },
// //             {
// //               'title': 'Takeaway',
// //               'value': getTakeawayOrders().toString(),
// //               'icon': Icons.takeout_dining,
// //               'color': Colors.orange,
// //             },
// //             {
// //               'title': 'Delivery',
// //               'value': getDeliveryOrders().toString(),
// //               'icon': Icons.delivery_dining,
// //               'color': Colors.purple,
// //             },
// //           ];
// //         // case 'payments':
// //         //   return [
// //         //     {
// //         //       'title': 'Transactions',
// //         //       'value': getTotalTransactions().toString(),
// //         //       'icon': Icons.payments,
// //         //       'color': _colors['primary']!,
// //         //     },
// //         //     {
// //         //       'title': 'Cash',
// //         //       'value': getCashTransactions().toString(),
// //         //       'icon': Icons.money,
// //         //       'color': Colors.green,
// //         //     },
// //         //     {
// //         //       'title': 'Online',
// //         //       'value': getOnlineTransactions().toString(),
// //         //       'icon': Icons.credit_card,
// //         //       'color': Colors.blue,
// //         //     },
// //         //     {
// //         //       'title': 'Wallet',
// //         //       'value': getWalletTransactions().toString(),
// //         //       'icon': Icons.wallet,
// //         //       'color': Colors.orange,
// //         //     },
// //         //   ];
// //         case 'rating':
// //           return [
// //             {
// //               'title': 'Overall Rating',
// //               'value': getAverageRating(),
// //               'icon': Icons.star,
// //               'color': Colors.orange,
// //             },
// //             {
// //               'title': 'Total Reviews',
// //               'value': getTotalReviews().toString(),
// //               'icon': Icons.reviews,
// //               'color': Colors.blue,
// //             },
// //             {
// //               'title': 'Response Rate',
// //               'value': getResponseRate(),
// //               'icon': Icons.speed,
// //               'color': Colors.green,
// //             },
// //             {
// //               'title': 'Response Time',
// //               'value': getResponseTime(),
// //               'icon': Icons.access_time,
// //               'color': Colors.purple,
// //             },
// //           ];
// //         default:
// //           return [
// //             {
// //               'title': 'Total Revenue',
// //               'value': _formatCurrency(getTotalRevenue()),
// //               'icon': Icons.attach_money,
// //               'color': _colors['success']!,
// //             },
// //             {
// //               'title': 'Total Orders',
// //               'value': getTotalOrders().toString(),
// //               'icon': Icons.shopping_bag,
// //               'color': Colors.blue,
// //             },
// //             {
// //               'title': 'Avg Rating',
// //               'value': getAverageRating(),
// //               'icon': Icons.star,
// //               'color': Colors.orange,
// //             },
// //           ];
// //       }
// //     }
// //
// //     final cardsData = getCardsData();
// //
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.all(16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Expanded(
// //                 child: Text(
// //                   _activeView == 'financial'
// //                       ? 'Financial Overview'
// //                       : _activeView == 'revenue'
// //                       ? 'Revenue Analysis'
// //                       : _activeView == 'orders'
// //                       ? 'Orders Analysis'
// //                       : _activeView == 'payments'
// //                       ? 'Payments Analysis'
// //                       : 'Rating Analysis',
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFF2A0947),
// //                   ),
// //                 ),
// //               ),
// //               Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Text(
// //                     '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(_endDate)}',
// //                     style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
// //                   ),
// //                   SizedBox(width: 8),
// //                 ],
// //               ),
// //             ],
// //           ),
// //
// //           SizedBox(height: 16),
// //
// //           Container(
// //             margin: EdgeInsets.only(bottom: 16),
// //             padding: EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   Color(0xFF7c3aed).withOpacity(0.1),
// //                   Color(0xFF10B981).withOpacity(0.1),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(16),
// //               border: Border.all(color: Colors.grey.shade200, width: 1),
// //             ),
// //             child: Column(
// //               children: [
// //                 Text(
// //                   _activeView == 'financial'
// //                       ? ''
// //                       : _activeView == 'revenue'
// //                       ? ''
// //                       : _activeView == 'orders'
// //                       ? ''
// //                       : _activeView == 'payments'
// //                       ? ''
// //                       : '',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.grey.shade800,
// //                   ),
// //                 ),
// //                 SizedBox(height: 12),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                   children: [
// //                     for (var i = 0; i < cardsData.length; i++)
// //                       Expanded(
// //                         child: Padding(
// //                           padding: EdgeInsets.symmetric(horizontal: 4),
// //                           child: _buildLiveStatItem(
// //                             cardsData[i]['title'] as String,
// //                             cardsData[i]['value'] as String,
// //                             cardsData[i]['color'] as Color,
// //                             cardsData[i]['icon'] as IconData,
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLiveStatItem(
// //     String label,
// //     String value,
// //     Color color,
// //     IconData icon,
// //   ) {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Container(
// //           width: _isMobile ? 36 : 40,
// //           height: _isMobile ? 36 : 40,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Icon(icon, size: _isMobile ? 18 : 20, color: color),
// //         ),
// //         SizedBox(height: 6),
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: _isMobile ? 13 : 14,
// //             fontWeight: FontWeight.w700,
// //             color: Colors.black87,
// //           ),
// //           maxLines: 1,
// //           overflow: TextOverflow.ellipsis,
// //           textAlign: TextAlign.center,
// //         ),
// //         SizedBox(height: 4),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: _isMobile ? 10 : 11,
// //             color: Colors.grey.shade600,
// //           ),
// //           maxLines: 1,
// //           overflow: TextOverflow.ellipsis,
// //           textAlign: TextAlign.center,
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildLoadingShimmer() {
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.all(16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Container(width: 150, height: 24, color: Colors.grey.shade200),
// //               Container(width: 100, height: 24, color: Colors.grey.shade200),
// //             ],
// //           ),
// //           SizedBox(height: 16),
// //           Container(
// //             padding: EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: Colors.grey.shade100,
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 for (int i = 0; i < 4; i++)
// //                   Expanded(
// //                     child: Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 4),
// //                       child: Column(
// //                         children: [
// //                           Container(
// //                             width: _isMobile ? 36 : 40,
// //                             height: _isMobile ? 36 : 40,
// //                             decoration: BoxDecoration(
// //                               color: Colors.grey.shade200,
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                           ),
// //                           SizedBox(height: 6),
// //                           Container(
// //                             width: 40,
// //                             height: _isMobile ? 11 : 12,
// //                             color: Colors.grey.shade200,
// //                           ),
// //                           SizedBox(height: 4),
// //                           Container(
// //                             width: 50,
// //                             height: _isMobile ? 9 : 10,
// //                             color: Colors.grey.shade200,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDatePickerModal() {
// //     if (!_showDatePicker) return Container();
// //
// //     return Positioned(
// //       top: 140,
// //       left: _isMobile ? 12 : 132,
// //       child: Container(
// //         width: _isMobile ? MediaQuery.of(context).size.width - 48 : 300,
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(color: const Color(0xFFe2e8f0)),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.06),
// //               blurRadius: 12,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: GestureDetector(
// //                     onTap: _showStartDatePicker,
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 8,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         border: Border.all(color: const Color(0xFFe2e8f0)),
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           const Icon(
// //                             Icons.calendar_today,
// //                             size: 16,
// //                             color: Color(0xFF94a3b8),
// //                           ),
// //                           const SizedBox(width: 8),
// //                           Text(
// //                             DateFormat('yyyy-MM-dd').format(_startDate),
// //                             style: const TextStyle(
// //                               fontSize: 12,
// //                               color: Color(0xFF1e293b),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 Container(
// //                   width: 16,
// //                   alignment: Alignment.center,
// //                   child: const Text(
// //                     'to',
// //                     style: TextStyle(fontSize: 11, color: Color(0xFF94a3b8)),
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: GestureDetector(
// //                     onTap: _showEndDatePicker,
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 8,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         border: Border.all(color: const Color(0xFFe2e8f0)),
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           const Icon(
// //                             Icons.calendar_today,
// //                             size: 16,
// //                             color: Color(0xFF94a3b8),
// //                           ),
// //                           const SizedBox(width: 8),
// //                           Text(
// //                             DateFormat('yyyy-MM-dd').format(_endDate),
// //                             style: const TextStyle(
// //                               fontSize: 12,
// //                               color: Color(0xFF1e293b),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 8),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFf8fafc),
// //                 borderRadius: BorderRadius.circular(4),
// //               ),
// //               child: Text(
// //                 '${_getDaysDifference(_startDate, _endDate)} days',
// //                 style: const TextStyle(fontSize: 15, color: Color(0xFF64748b)),
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: ElevatedButton(
// //                     onPressed: _handleDateRangeApply,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: _colors['primary'],
// //                       padding: const EdgeInsets.symmetric(vertical: 6),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                     ),
// //                     child: _isLoadingCustom
// //                         ? const SizedBox(
// //                             width: 16,
// //                             height: 16,
// //                             child: CircularProgressIndicator(
// //                               strokeWidth: 2,
// //                               color: Colors.white,
// //                             ),
// //                           )
// //                         : const Text(
// //                             'Apply',
// //                             style: TextStyle(fontSize: 12, color: Colors.white),
// //                           ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Expanded(
// //                   child: OutlinedButton(
// //                     onPressed: _handleDateRangeCancel,
// //                     style: OutlinedButton.styleFrom(
// //                       side: const BorderSide(color: Color(0xFFe2e8f0)),
// //                       padding: const EdgeInsets.symmetric(vertical: 6),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                     ),
// //                     child: const Text(
// //                       'Cancel',
// //                       style: TextStyle(fontSize: 12, color: Color(0xFF64748b)),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCustomRangeSelector() {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(6),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFf8fafc),
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: const Color(0xFFe2e8f0)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Expanded(
// //             child: GestureDetector(
// //               onTap: () {
// //                 setState(() {
// //                   _showDatePicker = !_showDatePicker;
// //                 });
// //               },
// //               child: Container(
// //                 margin: EdgeInsets.only(right: 8),
// //                 padding: EdgeInsets.symmetric(
// //                   horizontal: _isMobile ? 12 : 16,
// //                   vertical: _isMobile ? 12 : 14,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   gradient: _gradients['primary'],
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     const Icon(
// //                       Icons.calendar_today,
// //                       size: 20,
// //                       color: Colors.white,
// //                     ),
// //                     const SizedBox(width: 10),
// //                     Text(
// //                       _isMobile ? 'Custom Range' : 'Custom Date Range',
// //                       style: TextStyle(
// //                         fontSize: _isMobile ? 14 : 16,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: ElevatedButton(
// //               onPressed: () => print('Export clicked'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: _colors['primary'],
// //                 padding: EdgeInsets.symmetric(
// //                   horizontal: _isMobile ? 12 : 16,
// //                   vertical: _isMobile ? 12 : 14,
// //                 ),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 elevation: 4,
// //                 shadowColor: const Color(0xFF7c3aed).withOpacity(0.3),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Icon(Icons.download, size: 20, color: Colors.white),
// //                   const SizedBox(width: 10),
// //                   Text(
// //                     'Export Report',
// //                     style: TextStyle(
// //                       fontSize: _isMobile ? 14 : 16,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCustomRangeCards() {
// //     final totalRevenue = _customStatistics?.totalRevenue ?? 0.0;
// //     final totalOrders = _customStatistics?.totalOrders ?? 0;
// //     final avgRating =
// //         double.tryParse(_customStatistics?.averageRating ?? '0.00') ?? 0.0;
// //
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.all(16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
// //
// //           SizedBox(height: 16),
// //
// //           Container(
// //             margin: EdgeInsets.only(bottom: 16),
// //             padding: EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   Color(0xFF7c3aed).withOpacity(0.1),
// //                   Color(0xFF10B981).withOpacity(0.1),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(16),
// //               border: Border.all(color: Colors.grey.shade200, width: 1),
// //             ),
// //             child: Column(
// //               children: [
// //                 Text(
// //                   'Custom Range Performance',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.grey.shade800,
// //                   ),
// //                 ),
// //                 SizedBox(height: 12),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                   children: [
// //                     Expanded(
// //                       child: Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 4),
// //                         child: _buildLiveStatItem(
// //                           'Total Revenue',
// //                           _formatCurrency(totalRevenue),
// //                           Colors.green,
// //                           Icons.currency_rupee,
// //                         ),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 4),
// //                         child: _buildLiveStatItem(
// //                           'Total Orders',
// //                           totalOrders.toString(),
// //                           Colors.blue,
// //                           Icons.shopping_bag,
// //                         ),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 4),
// //                         child: _buildLiveStatItem(
// //                           'Avg Rating',
// //                           avgRating.toStringAsFixed(1),
// //                           Colors.orange,
// //                           Icons.star,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _handleViewToggle(String view) async {
// //     setState(() {
// //       _activeView = view;
// //     });
// //     if (view == 'orders' ||
// //         view == 'revenue' ||
// //         view == 'payments' ||
// //         view == 'rating') {
// //       await _fetchDetailedStatistics();
// //     }
// //   }
// //
// //   Widget _buildViewToggles() {
// //     final views = [
// //       {'key': 'financial', 'label': 'Financial', 'color': _colors['success']!},
// //       {'key': 'revenue', 'label': 'Revenue', 'color': Colors.blue},
// //       {'key': 'orders', 'label': 'Orders', 'color': const Color(0xFF9c27b0)},
// //       // {'key': 'payments', 'label': 'Payments', 'color': _colors['accent']!},
// //       {'key': 'rating', 'label': 'Rating', 'color': Colors.orange},
// //     ];
// //
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(6),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFf8fafc),
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: const Color(0xFFe2e8f0)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         physics: const BouncingScrollPhysics(),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.start,
// //           children: views.map((view) {
// //             final isSelected = _activeView == view['key'];
// //             return Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 4),
// //               child: GestureDetector(
// //                 onTap: () => _handleViewToggle(view['key'] as String),
// //                 child: Container(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: _isMobile ? 20 : 24,
// //                     vertical: _isMobile ? 10 : 12,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: isSelected
// //                         ? view['color'] as Color
// //                         : Colors.transparent,
// //                     borderRadius: BorderRadius.circular(12),
// //                     boxShadow: isSelected
// //                         ? [
// //                             BoxShadow(
// //                               color: (view['color'] as Color).withOpacity(0.4),
// //                               blurRadius: 12,
// //                               offset: const Offset(0, 4),
// //                             ),
// //                           ]
// //                         : null,
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       view['label'] as String,
// //                       style: TextStyle(
// //                         fontSize: _isMobile ? 13 : 14,
// //                         fontWeight: FontWeight.w600,
// //                         color: isSelected
// //                             ? Colors.white
// //                             : const Color(0xFF64748b),
// //                       ),
// //                       overflow: TextOverflow.ellipsis,
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             );
// //           }).toList(),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildOrdersRevenueGraph() {
// //     if (_detailedStatistics == null ||
// //         _detailedStatistics!.dailyStats.isEmpty) {
// //       if (_statistics == null) return Container();
// //
// //       List<FlSpot> generateWeeklyOrderSpots() {
// //         return List.generate(
// //           7,
// //           (index) => FlSpot(
// //             index.toDouble(),
// //             (_statistics!.weeklyOrders / 7 * (index + 1)).toDouble(),
// //           ),
// //         );
// //       }
// //
// //       List<FlSpot> generateWeeklyRevenueSpots() {
// //         return List.generate(
// //           7,
// //           (index) => FlSpot(
// //             index.toDouble(),
// //             (_statistics!.weeklyRevenue / 7 * (index + 1)).toDouble(),
// //           ),
// //         );
// //       }
// //
// //       return _buildChartWithData(
// //         generateWeeklyOrderSpots(),
// //         generateWeeklyRevenueSpots(),
// //       );
// //     }
// //
// //     final dailyStats = _detailedStatistics!.dailyStats;
// //     dailyStats.sort((a, b) => a.date.compareTo(b.date));
// //
// //     List<FlSpot> generateOrderSpotsFromDailyStats() {
// //       return dailyStats.asMap().entries.map((entry) {
// //         final index = entry.key;
// //         final stat = entry.value;
// //         return FlSpot(index.toDouble(), stat.orders.toDouble());
// //       }).toList();
// //     }
// //
// //     List<FlSpot> generateRevenueSpotsFromDailyStats() {
// //       return dailyStats.asMap().entries.map((entry) {
// //         final index = entry.key;
// //         final stat = entry.value;
// //         return FlSpot(index.toDouble(), stat.revenue);
// //       }).toList();
// //     }
// //
// //     return _buildChartWithData(
// //       generateOrderSpotsFromDailyStats(),
// //       generateRevenueSpotsFromDailyStats(),
// //       isDailyStats: true,
// //       dailyStats: dailyStats,
// //     );
// //   }
// //
// //   Widget _buildChartWithData(
// //     List<FlSpot> orderSpots,
// //     List<FlSpot> revenueSpots, {
// //     bool isDailyStats = false,
// //     List<DailyStat> dailyStats = const [],
// //   }) {
// //     final maxOrders = orderSpots.isNotEmpty
// //         ? orderSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
// //         : 0;
// //     final maxRevenue = revenueSpots.isNotEmpty
// //         ? revenueSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
// //         : 0;
// //
// //     return GestureDetector(
// //       onTap: () => setState(() => _showWeekDetails = !_showWeekDetails),
// //       child: Card(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //         elevation: 4,
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             children: [
// //               Text(
// //                 isDailyStats
// //                     ? "Daily Orders & Revenue"
// //                     : "Orders & Revenue Overview",
// //                 style: const TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //               AspectRatio(
// //                 aspectRatio: 1.7,
// //                 child: LineChart(
// //                   LineChartData(
// //                     gridData: FlGridData(show: true),
// //                     titlesData: FlTitlesData(
// //                       leftTitles: AxisTitles(
// //                         sideTitles: SideTitles(
// //                           showTitles: true,
// //                           interval: maxOrders > 20
// //                               ? (maxOrders / 4)
// //                               : (maxOrders / 2),
// //                           reservedSize: 40,
// //                           getTitlesWidget: (value, _) =>
// //                               Text('${value.toInt()}'),
// //                         ),
// //                       ),
// //                       rightTitles: AxisTitles(
// //                         sideTitles: SideTitles(
// //                           showTitles: true,
// //                           interval: maxRevenue > 1000
// //                               ? (maxRevenue / 4)
// //                               : (maxRevenue / 2),
// //                           reservedSize: 50,
// //                           getTitlesWidget: (value, _) =>
// //                               Text('₹${value.toInt()}'),
// //                         ),
// //                       ),
// //                       bottomTitles: AxisTitles(
// //                         sideTitles: SideTitles(
// //                           showTitles: true,
// //                           getTitlesWidget: (value, _) {
// //                             if (isDailyStats &&
// //                                 value.toInt() < dailyStats.length) {
// //                               final dateStr = dailyStats[value.toInt()].date;
// //                               final date = DateTime.tryParse(dateStr);
// //                               if (date != null) {
// //                                 return Text(
// //                                   DateFormat('MMM\ndd').format(date),
// //                                   textAlign: TextAlign.center,
// //                                   style: const TextStyle(fontSize: 10),
// //                                 );
// //                               }
// //                             } else if (!isDailyStats) {
// //                               switch (value.toInt()) {
// //                                 case 0:
// //                                   return const Text('Mon');
// //                                 case 2:
// //                                   return const Text('Wed');
// //                                 case 4:
// //                                   return const Text('Fri');
// //                                 case 6:
// //                                   return const Text('Sun');
// //                               }
// //                             }
// //                             return const Text('');
// //                           },
// //                         ),
// //                       ),
// //                       topTitles: const AxisTitles(
// //                         sideTitles: SideTitles(showTitles: false),
// //                       ),
// //                     ),
// //                     borderData: FlBorderData(show: true),
// //                     lineBarsData: [
// //                       LineChartBarData(
// //                         spots: orderSpots,
// //                         isCurved: true,
// //                         color: Colors.blue,
// //                         barWidth: 3,
// //                         dotData: FlDotData(
// //                           show: true,
// //                           getDotPainter: (spot, percent, barData, index) {
// //                             return FlDotCirclePainter(
// //                               radius: 4,
// //                               color: Colors.blue,
// //                               strokeWidth: 2,
// //                               strokeColor: Colors.white,
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                       LineChartBarData(
// //                         spots: revenueSpots,
// //                         isCurved: true,
// //                         color: Colors.orange,
// //                         barWidth: 3,
// //                         dotData: FlDotData(
// //                           show: true,
// //                           getDotPainter: (spot, percent, barData, index) {
// //                             return FlDotCirclePainter(
// //                               radius: 4,
// //                               color: Colors.orange,
// //                               strokeWidth: 2,
// //                               strokeColor: Colors.white,
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: const [
// //                   _LegendDot(color: Colors.blue, label: "Orders"),
// //                   SizedBox(width: 12),
// //                   _LegendDot(color: Colors.orange, label: "Revenue (₹)"),
// //                 ],
// //               ),
// //               const SizedBox(height: 8),
// //               if (_showWeekDetails && _detailedStatistics != null)
// //                 Container(
// //                   padding: const EdgeInsets.all(10),
// //                   decoration: BoxDecoration(
// //                     color: Colors.deepPurple.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         "Period: ${_detailedStatistics!.period}",
// //                         style: const TextStyle(fontWeight: FontWeight.bold),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text("Total Orders: ${_detailedStatistics!.totalOrders}"),
// //                       Text(
// //                         "Total Revenue: ₹${_detailedStatistics!.totalRevenue.toStringAsFixed(2)}",
// //                       ),
// //                       if (dailyStats.isNotEmpty) ...[
// //                         const SizedBox(height: 8),
// //                         const Text(
// //                           "Daily Breakdown:",
// //                           style: TextStyle(fontWeight: FontWeight.bold),
// //                         ),
// //                         ...dailyStats.map((stat) {
// //                           final date = DateTime.tryParse(stat.date);
// //                           return Text(
// //                             "${date != null ? DateFormat('MMM dd').format(date) : stat.date}: "
// //                             "${stat.orders} orders, ₹${stat.revenue.toStringAsFixed(2)}",
// //                           );
// //                         }).toList(),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTopSellingItemsChart() {
// //     if (_detailedStatistics != null &&
// //         _detailedStatistics!.topSellingByCategory.isNotEmpty) {
// //       final items = _detailedStatistics!.topSellingByCategory
// //           .asMap()
// //           .entries
// //           .map((entry) {
// //             final index = entry.key;
// //             final item = entry.value;
// //             final colors = [
// //               Colors.green,
// //               Colors.orange,
// //               Colors.blue,
// //               Colors.purple,
// //               Colors.red,
// //               Colors.teal,
// //               Colors.pink,
// //               Colors.indigo,
// //             ];
// //             return {
// //               "label": item.item,
// //               "orders": item.quantity,
// //               "category": item.category,
// //               "color": colors[index % colors.length],
// //             };
// //           })
// //           .toList();
// //
// //       return Card(
// //         elevation: 4,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             children: [
// //               const Text(
// //                 "Top Selling Items by Category",
// //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 "Period: ${_detailedStatistics!.period}",
// //                 style: const TextStyle(fontSize: 12, color: Colors.grey),
// //               ),
// //               const SizedBox(height: 12),
// //               AspectRatio(
// //                 aspectRatio: 1.7,
// //                 child: BarChart(
// //                   BarChartData(
// //                     borderData: FlBorderData(show: false),
// //                     gridData: FlGridData(show: false),
// //                     titlesData: FlTitlesData(
// //                       leftTitles: AxisTitles(
// //                         sideTitles: SideTitles(
// //                           showTitles: true,
// //                           getTitlesWidget: (value, _) =>
// //                               Text('${value.toInt()}'),
// //                           reservedSize: 30,
// //                         ),
// //                       ),
// //                       rightTitles: const AxisTitles(
// //                         sideTitles: SideTitles(showTitles: false),
// //                       ),
// //                       topTitles: const AxisTitles(
// //                         sideTitles: SideTitles(showTitles: false),
// //                       ),
// //                       bottomTitles: AxisTitles(
// //                         sideTitles: SideTitles(
// //                           showTitles: true,
// //                           getTitlesWidget: (value, _) {
// //                             if (value.toInt() >= 0 &&
// //                                 value.toInt() < items.length) {
// //                               final label =
// //                                   items[value.toInt()]["label"] as String;
// //                               return Text(
// //                                 label.length > 8
// //                                     ? '${label.substring(0, 8)}...'
// //                                     : label,
// //                                 textAlign: TextAlign.center,
// //                                 style: const TextStyle(fontSize: 10),
// //                               );
// //                             }
// //                             return const Text('');
// //                           },
// //                         ),
// //                       ),
// //                     ),
// //                     barGroups: items.asMap().entries.map((entry) {
// //                       final i = entry.key;
// //                       final item = entry.value;
// //                       final color = item["color"] as Color;
// //                       return BarChartGroupData(
// //                         x: i,
// //                         barRods: [
// //                           BarChartRodData(
// //                             toY: (item["orders"] as num).toDouble(),
// //                             color: color,
// //                             width: 22,
// //                             borderRadius: BorderRadius.circular(6),
// //                           ),
// //                         ],
// //                         showingTooltipIndicators: _selectedBarIndex == i
// //                             ? [0]
// //                             : [],
// //                       );
// //                     }).toList(),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Wrap(
// //                 alignment: WrapAlignment.center,
// //                 spacing: 8,
// //                 runSpacing: 4,
// //                 children: items.map((e) {
// //                   return Tooltip(
// //                     message:
// //                         "${e["label"]} (${e["category"]}) - ${e["orders"]} units",
// //                     child: _LegendDot(
// //                       color: e["color"] as Color,
// //                       label: e["label"] as String,
// //                     ),
// //                   );
// //                 }).toList(),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 "Total Items: ${items.length}",
// //                 style: const TextStyle(fontSize: 12, color: Colors.grey),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     if (_statistics == null || _statistics!.topSellingItems.isEmpty) {
// //       return Card(
// //         elevation: 4,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Center(
// //             child: Column(
// //               children: [
// //                 const Text("No top selling items data available"),
// //                 if (_detailedStatistics != null)
// //                   Text(
// //                     "Period: ${_detailedStatistics!.period}",
// //                     style: const TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       );
// //     }
// //
// //     final items = _statistics!.topSellingItems.asMap().entries.map((entry) {
// //       final index = entry.key;
// //       final item = entry.value;
// //       final colors = [
// //         Colors.green,
// //         Colors.orange,
// //         Colors.blue,
// //         Colors.purple,
// //         Colors.red,
// //       ];
// //       return {
// //         "label": item.name,
// //         "orders": item.count,
// //         "color": colors[index % colors.length],
// //       };
// //     }).toList();
// //
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             const Text(
// //               "Top Selling Items",
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 12),
// //             AspectRatio(
// //               aspectRatio: 1.7,
// //               child: BarChart(
// //                 BarChartData(
// //                   borderData: FlBorderData(show: false),
// //                   gridData: FlGridData(show: false),
// //                   titlesData: FlTitlesData(
// //                     leftTitles: const AxisTitles(
// //                       sideTitles: SideTitles(showTitles: false),
// //                     ),
// //                     rightTitles: const AxisTitles(
// //                       sideTitles: SideTitles(showTitles: false),
// //                     ),
// //                     topTitles: const AxisTitles(
// //                       sideTitles: SideTitles(showTitles: false),
// //                     ),
// //                     bottomTitles: AxisTitles(
// //                       sideTitles: SideTitles(
// //                         showTitles: true,
// //                         getTitlesWidget: (value, _) {
// //                           if (value.toInt() >= 0 &&
// //                               value.toInt() < items.length) {
// //                             final label =
// //                                 items[value.toInt()]["label"] as String;
// //                             return Text(
// //                               label.length > 10
// //                                   ? '${label.substring(0, 10)}...'
// //                                   : label,
// //                               textAlign: TextAlign.center,
// //                             );
// //                           }
// //                           return const Text('');
// //                         },
// //                       ),
// //                     ),
// //                   ),
// //                   barGroups: items.asMap().entries.map((entry) {
// //                     final i = entry.key;
// //                     final item = entry.value;
// //                     final color = item["color"] as Color;
// //                     return BarChartGroupData(
// //                       x: i,
// //                       barRods: [
// //                         BarChartRodData(
// //                           toY: (item["orders"] as num).toDouble(),
// //                           color: color,
// //                           width: 22,
// //                           borderRadius: BorderRadius.circular(6),
// //                         ),
// //                       ],
// //                       showingTooltipIndicators: _selectedBarIndex == i
// //                           ? [0]
// //                           : [],
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Wrap(
// //               alignment: WrapAlignment.center,
// //               children: items.map((e) {
// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 6),
// //                   child: _LegendDot(
// //                     color: e["color"] as Color,
// //                     label: e["label"] as String,
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPaymentDistributionPieChart() {
// //     // Always prefer _detailedStatistics over _statistics since it has payment breakdown
// //     if (_detailedStatistics != null) {
// //       final paymentBreakdown = _detailedStatistics!.paymentBreakdown;
// //
// //       final totalPayments =
// //           paymentBreakdown.onlinePayment +
// //           paymentBreakdown.cash +
// //           paymentBreakdown.maamaasWallet;
// //
// //       // Create payments list
// //       final payments = [
// //         {
// //           "label": "Online Payment",
// //           "amount": paymentBreakdown.onlinePayment,
// //           "percentage": totalPayments > 0
// //               ? ((paymentBreakdown.onlinePayment / totalPayments) * 100)
// //               : 0,
// //           "color": Colors.green,
// //         },
// //         {
// //           "label": "Cash",
// //           "amount": paymentBreakdown.cash,
// //           "percentage": totalPayments > 0
// //               ? ((paymentBreakdown.cash / totalPayments) * 100)
// //               : 0,
// //           "color": Colors.blue,
// //         },
// //         {
// //           "label": "Maamaas Wallet",
// //           "amount": paymentBreakdown.maamaasWallet,
// //           "percentage": totalPayments > 0
// //               ? ((paymentBreakdown.maamaasWallet / totalPayments) * 100)
// //               : 0,
// //           "color": Colors.orange,
// //         },
// //       ];
// //
// //       final filteredPayments = payments
// //           .where((p) => (p["amount"] as double) > 0)
// //           .toList();
// //
// //       if (filteredPayments.isEmpty) {
// //         return Card(
// //           elevation: 4,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Center(
// //               child: Column(
// //                 children: [
// //                   const Text("No payment distribution data available"),
// //                   Text(
// //                     "Period: ${_detailedStatistics!.period}",
// //                     style: const TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       }
// //
// //       return Card(
// //         elevation: 4,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             children: [
// //               const Text(
// //                 "Payment Distribution",
// //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 "Period: ${_detailedStatistics!.period}",
// //                 style: const TextStyle(fontSize: 12, color: Colors.grey),
// //               ),
// //               const SizedBox(height: 12),
// //               AspectRatio(
// //                 aspectRatio: 1.3,
// //                 child: PieChart(
// //                   PieChartData(
// //                     sectionsSpace: 3,
// //                     centerSpaceRadius: 50,
// //                     centerSpaceColor: Colors.grey[50],
// //                     pieTouchData: PieTouchData(
// //                       touchCallback: (event, response) {
// //                         setState(() {
// //                           if (!event.isInterestedForInteractions ||
// //                               response == null ||
// //                               response.touchedSection == null) {
// //                             _selectedPie = null;
// //                             return;
// //                           }
// //                           _selectedPie =
// //                               response.touchedSection!.touchedSectionIndex;
// //                         });
// //                       },
// //                     ),
// //                     sections: filteredPayments.asMap().entries.map((entry) {
// //                       final index = entry.key;
// //                       final e = entry.value;
// //                       final bool isSelected = _selectedPie == index;
// //                       final double amount = e["amount"] as double;
// //                       final double percentage = e["percentage"] as double;
// //
// //                       return PieChartSectionData(
// //                         color: e["color"] as Color,
// //                         value: amount, // CORRECT: Using raw amount
// //                         title:
// //                             "${e["label"]}\n₹${amount.toStringAsFixed(2)}\n${percentage.toStringAsFixed(1)}%",
// //                         radius: isSelected ? 70 : 60,
// //                         titleStyle: const TextStyle(
// //                           fontSize: 11,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black,
// //                         ),
// //                         titlePositionPercentageOffset: 0.6,
// //                       );
// //                     }).toList(),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[50],
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Column(
// //                   children: [
// //                     Text(
// //                       "Total Payments: ₹${totalPayments.toStringAsFixed(2)}",
// //                       style: const TextStyle(fontWeight: FontWeight.bold),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     ...filteredPayments.map((payment) {
// //                       return Padding(
// //                         padding: const EdgeInsets.symmetric(vertical: 2),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Row(
// //                               children: [
// //                                 Container(
// //                                   width: 12,
// //                                   height: 12,
// //                                   decoration: BoxDecoration(
// //                                     color: payment["color"] as Color,
// //                                     shape: BoxShape.circle,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 8),
// //                                 Text(payment["label"] as String),
// //                               ],
// //                             ),
// //                             Text(
// //                               "₹${(payment["amount"] as double).toStringAsFixed(2)} "
// //                               "(${(payment["percentage"] as double).toStringAsFixed(1)}%)",
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     }).toList(),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     // If no detailed statistics, show simplified version
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             const Text(
// //               "Payment Distribution",
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 16),
// //             const Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey),
// //             const SizedBox(height: 12),
// //             const Text(
// //               "Payment data will appear here",
// //               style: TextStyle(color: Colors.grey),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               "Select a date range to view payment breakdown",
// //               style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
// //               textAlign: TextAlign.center,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Add method for vertical chips
// //   Widget _buildVerticalChips() {
// //     return SingleChildScrollView(
// //       scrollDirection: Axis.horizontal,
// //       physics: const BouncingScrollPhysics(),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: ReportVertical.values.map((vertical) {
// //           final isSelected = _selectedVertical == vertical;
// //
// //           return Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 8.0),
// //             child: GestureDetector(
// //               onTap: () {
// //                 setState(() => _selectedVertical = vertical);
// //                 _handleVerticalSelection(vertical);
// //               },
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Container(
// //                     width: 45,
// //                     height: 45,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: isSelected
// //                           ? _getVerticalColor(vertical)
// //                           : Colors.white,
// //                       boxShadow: [
// //                         if (isSelected)
// //                           BoxShadow(
// //                             color: _getVerticalColor(vertical).withOpacity(0.2),
// //                             blurRadius: 4,
// //                             offset: const Offset(0, 2),
// //                           ),
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.1),
// //                           blurRadius: 2,
// //                           offset: const Offset(0, 1),
// //                         ),
// //                       ],
// //                       border: Border.all(
// //                         color: isSelected
// //                             ? _getVerticalColor(vertical)
// //                             : Colors.grey.shade300,
// //                         width: isSelected ? 2 : 1,
// //                       ),
// //                     ),
// //                     child: Center(
// //                       child: Icon(
// //                         _verticalIcon(vertical),
// //                         size: 22,
// //                         color: isSelected
// //                             ? Colors.white
// //                             : _getVerticalColor(vertical),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     _getShortLabel(vertical),
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 11,
// //                       fontWeight: FontWeight.w500,
// //                       color: isSelected
// //                           ? _getVerticalColor(vertical)
// //                           : Colors.black87,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// //
// //   String _getShortLabel(ReportVertical v) {
// //     switch (v) {
// //       case ReportVertical.food:
// //         return "Food";
// //       case ReportVertical.catering:
// //         return "Catering";
// //     }
// //   }
// //
// //   IconData _verticalIcon(ReportVertical v) {
// //     switch (v) {
// //       case ReportVertical.food:
// //         return Icons.fastfood;
// //       case ReportVertical.catering:
// //         return Icons.restaurant;
// //     }
// //   }
// //
// //   Color _getVerticalColor(ReportVertical v) {
// //     switch (v) {
// //       case ReportVertical.food:
// //         return const Color(0xFFB15DC6);
// //       case ReportVertical.catering:
// //         return const Color(0xFF2196F3);
// //     }
// //   }
// //
// //   void _handleVerticalSelection(ReportVertical vertical) {
// //     if (vertical == ReportVertical.catering) {
// //       // Navigate to the catering report page
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => const ReportAndAnalysisPagecatering(),
// //         ),
// //       ).then((_) {
// //         // When coming back from catering page, ensure food is selected
// //         if (mounted) {
// //           setState(() {
// //             _selectedVertical = ReportVertical.food;
// //           });
// //         }
// //       });
// //     } else {
// //       // For food, just refresh the current data
// //       print('Selected vertical: Food');
// //       _fetchStatistics();
// //       _fetchCustomStatistics();
// //       _fetchDetailedStatistics();
// //     }
// //   }
// //
// //   void _navigateToHome() {
// //     Navigator.pushReplacement(
// //       context,
// //       MaterialPageRoute(builder: (context) => const HomeWrapper()),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: _navigateToHome, // Navigate directly to home
// //         ),
// //         title: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Text(
// //               "Report & Analysis",
// //               style: TextStyle(
// //                 color: Colors.black,
// //                 fontWeight: FontWeight.w600,
// //                 fontSize: 16,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             _buildVerticalChips(),
// //           ],
// //         ),
// //         centerTitle: true,
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //         automaticallyImplyLeading: false,
// //         iconTheme: const IconThemeData(color: Colors.black),
// //         toolbarHeight: 90, // Adjusted height to accommodate the chips
// //       ),
// //       body: Column(
// //         children: [
// //           // Only Custom Range Selector & Export Button at top (fixed)
// //           Container(
// //             color: Colors.white,
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //             child: _buildCustomRangeSelector(),
// //           ),
// //
// //           // SCROLLABLE CONTENT - Everything else scrolls including buttons
// //           Expanded(
// //             child: Stack(
// //               children: [
// //                 _isLoading
// //                     ? const Center(child: CircularProgressIndicator())
// //                     : _errorMessage.isNotEmpty
// //                     ? Center(
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Text(
// //                               'Error: $_errorMessage',
// //                               textAlign: TextAlign.center,
// //                             ),
// //                             const SizedBox(height: 16),
// //                             ElevatedButton(
// //                               onPressed: _fetchStatistics,
// //                               child: const Text('Retry'),
// //                             ),
// //                           ],
// //                         ),
// //                       )
// //                     : RefreshIndicator(
// //                         onRefresh: () async {
// //                           await _fetchStatistics();
// //                           await _fetchCustomStatistics();
// //                         },
// //                         child: SingleChildScrollView(
// //                           padding: const EdgeInsets.all(16),
// //                           physics: const AlwaysScrollableScrollPhysics(),
// //                           child: Column(
// //                             children: [
// //                               // 📊 Custom Range Summary Cards
// //                               _buildCustomRangeCards(),
// //                               const SizedBox(height: 16),
// //
// //                               // 📊 View Toggles (Financial/Revenue/Orders/Payments/Rating) - HORIZONTAL SCROLL
// //                               _buildViewToggles(),
// //                               const SizedBox(height: 16),
// //
// //                               // 📊 Financial Cards Section
// //                               _buildFinancialCardsSection(),
// //                               const SizedBox(height: 25),
// //
// //                               // 📊 Orders & Revenue Graph
// //                               _buildOrdersRevenueGraph(),
// //                               const SizedBox(height: 25),
// //
// //                               // 📊 Top Selling Items Chart
// //                               _buildTopSellingItemsChart(),
// //                               const SizedBox(height: 25),
// //
// //                               // 📊 Payment Distribution Pie Chart
// //                               _buildPaymentDistributionPieChart(),
// //                               const SizedBox(height: 50),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //
// //                 // Date Picker Modal
// //                 if (_showDatePicker) _buildDatePickerModal(),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _LegendDot extends StatelessWidget {
// //   final Color color;
// //   final String label;
// //
// //   const _LegendDot({required this.color, required this.label});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Container(
// //           width: 12,
// //           height: 12,
// //           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
// //         ),
// //         const SizedBox(width: 4),
// //         Text(
// //           label,
// //           style: const TextStyle(fontSize: 13),
// //           overflow: TextOverflow.ellipsis,
// //           maxLines: 1,
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:maamaaspartner/Api/food_authservice.dart';
// import 'package:intl/intl.dart';
// import '../Models/food&beverages/custom_model.dart';
// import '../Models/food&beverages/detailed_statisticsresponse_model.dart';
// import '../caterings/ReportAndAnalysisPage.dart';
// import '../widgets_helper/Home_screen_1.dart' hide DailyStat;
//
// enum ReportVertical { food, catering }
//
// // ─── Design Tokens ─────────────────────────────────────────────────────────────
// class _R {
//   static const bg = Color(0xFFF7F8FC);
//   static const white = Color(0xFFFFFFFF);
//   static const border = Color(0xFFEEEFF5);
//   static const accent = Color(0xFFE66D33);
//   static const accentDark = Color(0xFFE66D33);
//   static const accentLight = Color(0xFFF5E8FA);
//   static const green = Color(0xFF10B981);
//   static const greenLight = Color(0xFFD1FAE5);
//   static const blue = Color(0xFF3B82F6);
//   static const blueLight = Color(0xFFDBEAFE);
//   static const amber = Color(0xFFF59E0B);
//   static const amberLight = Color(0xFFFEF3C7);
//   static const red = Color(0xFFEF4444);
//   static const redLight = Color(0xFFFEE2E2);
//   static const purple = Color(0xFF8B5CF6);
//   static const purpleLight = Color(0xFFEDE9FE);
//   static const teal = Color(0xFF14B8A6);
//   static const tealLight = Color(0xFFCCFBF1);
//   static const text1 = Color(0xFF111827);
//   static const text2 = Color(0xFF6B7280);
//   static const text3 = Color(0xFFB0B3C1);
//   static const shadow = Color(0x0A000000);
//   static const shadowMd = Color(0x12000000);
// }
//
// class ReportAnalysisPage extends StatefulWidget {
//   const ReportAnalysisPage({Key? key}) : super(key: key);
//
//   @override
//   State<ReportAnalysisPage> createState() => _ReportAnalysisPageState();
// }
//
// class _ReportAnalysisPageState extends State<ReportAnalysisPage>
//     with SingleTickerProviderStateMixin {
//   // ── State ───────────────────────────────────────────────────────────────────
//   bool _showWeekDetails = false;
//   int? _selectedBarIndex;
//   int? _selectedPie;
//   StatisticsResponse? _statistics;
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isMobile = false;
//   DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
//   DateTime _endDate = DateTime.now();
//   String _activeView = 'financial';
//   bool _showDatePicker = false;
//   CustomStatisticsResponse? _customStatistics;
//   bool _isLoadingCustom = false;
//   DetailedStatisticsResponse? _detailedStatistics;
//   bool _isLoadingDetailed = false;
//   ReportVertical _selectedVertical = ReportVertical.food;
//
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         final views = ['financial', 'revenue', 'orders', 'rating'];
//         _handleViewToggle(views[_tabController.index]);
//       }
//     });
//     _fetchStatistics();
//     _fetchCustomStatistics();
//     _fetchDetailedStatistics();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkMobile());
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   void _checkMobile() {
//     if (!mounted) return;
//     setState(() => _isMobile = MediaQuery.of(context).size.width < 768);
//   }
//
//   Future<void> _fetchStatistics() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//     final stats = await food_authservice.fetchVendorStatistics();
//     setState(() {
//       _isLoading = false;
//       if (stats == null) _errorMessage = 'Failed to load statistics';
//     });
//   }
//
//   Future<void> _fetchCustomStatistics() async {
//     try {
//       final from = DateFormat('yyyy-MM-dd').format(_startDate);
//       final to = DateFormat('yyyy-MM-dd').format(_endDate);
//       final s = await food_authservice.fetchCustomStatistics(
//         fromDate: from,
//         toDate: to,
//       );
//       if (mounted) setState(() => _customStatistics = s);
//     } catch (e) {
//       debugPrint('Custom stats error: $e');
//     }
//   }
//
//   Future<void> _fetchDetailedStatistics() async {
//     setState(() => _isLoadingDetailed = true);
//     try {
//       final from = DateFormat('yyyy-MM-dd').format(_startDate);
//       final to = DateFormat('yyyy-MM-dd').format(_endDate);
//       final s = await food_authservice.fetchDetailedStatistics(
//         fromDate: from,
//         toDate: to,
//       );
//       if (mounted)
//         setState(() {
//           _detailedStatistics = s;
//           _isLoadingDetailed = false;
//         });
//     } catch (e) {
//       debugPrint('Detailed stats error: $e');
//       if (mounted) setState(() => _isLoadingDetailed = false);
//     }
//   }
//
//   int _getDaysDifference(DateTime s, DateTime e) => e.difference(s).inDays + 1;
//
//   String _fmt(double amt) {
//     final formatter = NumberFormat.currency(
//       symbol: '₹',
//       decimalDigits: 0,
//     );
//     return formatter.format(amt);
//   }
//   void _handleViewToggle(String view) async {
//     setState(() => _activeView = view);
//     if (['orders', 'revenue', 'rating'].contains(view)) {
//       await _fetchDetailedStatistics();
//     }
//   }
//
//   void _handleDateApply() {
//     _fetchCustomStatistics();
//     _fetchDetailedStatistics();
//     setState(() => _showDatePicker = false);
//   }
//
//   // ─── Data helpers ─────────────────────────────────────────────────────────
//   double get _totalRevenue =>
//       _detailedStatistics?.totalRevenue ?? _customStatistics?.totalRevenue ?? 0;
//   int get _totalOrders =>
//       _detailedStatistics?.totalOrders ?? _customStatistics?.totalOrders ?? 0;
//   String get _avgRating =>
//       _detailedStatistics?.averageRating ??
//       _customStatistics?.averageRating ??
//       '0.00';
//   double get _netRevenue => _detailedStatistics?.netRevenue ?? 0;
//   String get _profitMargin => _detailedStatistics?.profitMargin ?? '0%';
//
//   // ─── BUILD ────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData.light(),
//       child: Scaffold(
//         backgroundColor: _R.bg,
//         body: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(),
//               // _buildVerticalSwitcher(),
//               _buildDateRangeBar(),
//               _buildTabBar(),
//               Expanded(
//                 child: _isLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           color: _R.accent,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : _errorMessage.isNotEmpty
//                     ? _buildError()
//                     : Stack(
//                         children: [
//                           RefreshIndicator(
//                             color: _R.accent,
//                             onRefresh: () async {
//                               await _fetchStatistics();
//                               await _fetchCustomStatistics();
//                               await _fetchDetailedStatistics();
//                             },
//                             child: SingleChildScrollView(
//                               physics: const AlwaysScrollableScrollPhysics(),
//                               padding: const EdgeInsets.fromLTRB(
//                                 16,
//                                 16,
//                                 16,
//                                 32,
//                               ),
//                               child: Column(
//                                 children: [
//                                   _buildKpiRow(),
//                                   const SizedBox(height: 16),
//                                   _buildViewCards(),
//                                   const SizedBox(height: 16),
//                                   _buildOrdersRevenueGraph(),
//                                   const SizedBox(height: 16),
//                                   _buildTopSellingChart(),
//                                   const SizedBox(height: 16),
//                                   _buildPaymentPieChart(),
//                                   const SizedBox(height: 16),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           if (_showDatePicker) _buildDatePickerOverlay(),
//                         ],
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Header ──────────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       decoration: const BoxDecoration(
//         color: _R.white,
//         border: Border(bottom: BorderSide(color: _R.border)),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeWrapper()),
//             ),
//             child: Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: _R.bg,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: _R.border),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: _R.text1,
//                 size: 15,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Report Management',
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w800,
//                     color: _R.text1,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 Text(
//                   '${DateFormat('MMM d').format(_startDate)} – ${DateFormat('MMM d, yyyy').format(_endDate)}',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: _R.text2,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Export button
//           GestureDetector(
//             onTap: () {},
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [_R.accent, _R.accentDark],
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _R.accent.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Icon(Icons.download_rounded, color: Colors.white, size: 15),
//                   SizedBox(width: 5),
//                   Text(
//                     'Export',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
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
//
//   // ── Vertical Switcher ────────────────────────────────────────────────────────
//   // Widget _buildVerticalSwitcher() {
//   //   return Container(
//   //     color: _R.white,
//   //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
//   //     child: Container(
//   //       padding: const EdgeInsets.all(4),
//   //       decoration: BoxDecoration(
//   //         color: _R.bg,
//   //         borderRadius: BorderRadius.circular(12),
//   //         border: Border.all(color: _R.border),
//   //       ),
//   //       child: Row(
//   //         children: ReportVertical.values.map((v) {
//   //           final isSelected = _selectedVertical == v;
//   //           final color = v == ReportVertical.food ? _R.accent : _R.blue;
//   //           return Expanded(
//   //             child: GestureDetector(
//   //               onTap: () {
//   //                 setState(() => _selectedVertical = v);
//   //                 if (v == ReportVertical.catering) {
//   //                   Navigator.push(
//   //                     context,
//   //                     MaterialPageRoute(
//   //                       builder: (_) => const ReportAndAnalysisPagecatering(),
//   //                     ),
//   //                   ).then((_) {
//   //                     if (mounted)
//   //                       setState(() => _selectedVertical = ReportVertical.food);
//   //                   });
//   //                 } else {
//   //                   _fetchStatistics();
//   //                   _fetchCustomStatistics();
//   //                   _fetchDetailedStatistics();
//   //                 }
//   //               },
//   //               child: AnimatedContainer(
//   //                 duration: const Duration(milliseconds: 200),
//   //                 padding: const EdgeInsets.symmetric(vertical: 9),
//   //                 decoration: BoxDecoration(
//   //                   color: isSelected ? _R.white : Colors.transparent,
//   //                   borderRadius: BorderRadius.circular(8),
//   //                   boxShadow: isSelected
//   //                       ? [
//   //                           BoxShadow(
//   //                             color: _R.shadowMd,
//   //                             blurRadius: 6,
//   //                             offset: const Offset(0, 2),
//   //                           ),
//   //                         ]
//   //                       : null,
//   //                 ),
//   //                 child: Row(
//   //                   mainAxisAlignment: MainAxisAlignment.center,
//   //                   children: [
//   //                     Icon(
//   //                       v == ReportVertical.food
//   //                           ? Icons.fastfood_rounded
//   //                           : Icons.restaurant_rounded,
//   //                       color: isSelected ? color : _R.text3,
//   //                       size: 15,
//   //                     ),
//   //                     const SizedBox(width: 6),
//   //                     Text(
//   //                       v == ReportVertical.food ? 'Food' : 'Catering',
//   //                       style: TextStyle(
//   //                         color: isSelected ? color : _R.text2,
//   //                         fontWeight: isSelected
//   //                             ? FontWeight.w700
//   //                             : FontWeight.w500,
//   //                         fontSize: 13,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           );
//   //         }).toList(),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   // ── Date Range Bar ───────────────────────────────────────────────────────────
//   Widget _buildDateRangeBar() {
//     return Container(
//       color: _R.white,
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       child: GestureDetector(
//         onTap: () => setState(() => _showDatePicker = !_showDatePicker),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: _R.bg,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: _R.border),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: _R.accentLight,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.calendar_today_rounded,
//                   color: _R.accent,
//                   size: 15,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Date Range',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: _R.text2,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       '${DateFormat('MMM d, yyyy').format(_startDate)}  →  ${DateFormat('MMM d, yyyy').format(_endDate)}',
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: _R.text1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: _R.accentLight,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   '${_getDaysDifference(_startDate, _endDate)}d',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: _R.accent,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Icon(
//                 _showDatePicker
//                     ? Icons.keyboard_arrow_up_rounded
//                     : Icons.keyboard_arrow_down_rounded,
//                 color: _R.text3,
//                 size: 20,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Tab Bar ──────────────────────────────────────────────────────────────────
//   Widget _buildTabBar() {
//     final tabs = [
//       {'label': 'Financial', 'icon': Icons.account_balance_wallet_outlined},
//       {'label': 'Revenue', 'icon': Icons.trending_up_rounded},
//       {'label': 'Orders', 'icon': Icons.receipt_long_rounded},
//       {'label': 'Rating', 'icon': Icons.star_outline_rounded},
//     ];
//     return Container(
//       color: _R.white,
//       child: Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             isScrollable: true,
//             tabAlignment: TabAlignment.start,
//             indicatorColor: _R.accent,
//             indicatorWeight: 2.5,
//             indicatorSize: TabBarIndicatorSize.label,
//             labelColor: _R.accent,
//             unselectedLabelColor: _R.text2,
//             labelStyle: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             tabs: tabs
//                 .map(
//                   (t) => Tab(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(t['icon'] as IconData, size: 14),
//                         const SizedBox(width: 5),
//                         Text(t['label'] as String),
//                       ],
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//           Divider(color: _R.border, height: 1),
//         ],
//       ),
//     );
//   }
//
//   // ── KPI Row ──────────────────────────────────────────────────────────────────
//   Widget _buildKpiRow() {
//     if (_isLoadingDetailed &&
//         _detailedStatistics == null &&
//         _customStatistics == null) {
//       return _buildShimmerRow();
//     }
//
//     final dailyAvg = _getDaysDifference(_startDate, _endDate) > 0
//         ? _totalRevenue / _getDaysDifference(_startDate, _endDate)
//         : 0.0;
//
//     final kpis = [
//       {
//         'label': 'Revenue',
//         'value': _fmt(_totalRevenue),
//         'color': _R.green,
//         'icon': Icons.currency_rupee_rounded,
//         'bg': _R.greenLight,
//       },
//       {
//         'label': 'Orders',
//         'value': _totalOrders.toString(),
//         'color': _R.blue,
//         'icon': Icons.shopping_bag_rounded,
//         'bg': _R.blueLight,
//       },
//       {
//         'label': 'Avg Rating',
//         'value': _avgRating,
//         'color': _R.amber,
//         'icon': Icons.star_rounded,
//         'bg': _R.amberLight,
//       },
//       {
//         'label': 'Daily Avg',
//         'value': _fmt(dailyAvg),
//         'color': _R.purple,
//         'icon': Icons.timeline_rounded,
//         'bg': _R.purpleLight,
//       },
//     ];
//
//     return Container(
//       decoration: BoxDecoration(
//         color: _R.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _R.border),
//         boxShadow: [
//           BoxShadow(
//             color: _R.shadow,
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//         child: Row(
//           children: kpis.asMap().entries.map((e) {
//             final kpi = e.value;
//             final isLast = e.key == kpis.length - 1;
//             return Expanded(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _kpiCell(
//                       kpi['label'] as String,
//                       kpi['value'] as String,
//                       kpi['color'] as Color,
//                       kpi['icon'] as IconData,
//                       kpi['bg'] as Color,
//                     ),
//                   ),
//                   if (!isLast)
//                     Container(width: 1, height: 44, color: _R.border),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   Widget _kpiCell(
//     String label,
//     String value,
//     Color color,
//     IconData icon,
//     Color bg,
//   ) {
//     return Column(
//       children: [
//         Container(
//           width: 38,
//           height: 38,
//           decoration: BoxDecoration(
//             color: bg,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, size: 18, color: color),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w800,
//             color: _R.text1,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.center,
//         ),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 10, color: _R.text2),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildShimmerRow() {
//     return Container(
//       height: 100,
//       decoration: BoxDecoration(
//         color: _R.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _R.border),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(
//           4,
//           (_) => Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: _R.border,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Container(
//                 width: 40,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: _R.border,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 width: 30,
//                 height: 10,
//                 decoration: BoxDecoration(
//                   color: _R.border,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── View Cards ───────────────────────────────────────────────────────────────
//   Widget _buildViewCards() {
//     if (_isLoadingDetailed && _detailedStatistics == null)
//       return _buildShimmerRow();
//
//     List<Map<String, dynamic>> cards = [];
//
//     switch (_activeView) {
//       case 'financial':
//         cards = [
//           {
//             'title': 'Total Revenue',
//             'value': _fmt(_totalRevenue),
//             'color': _R.green,
//             'bg': _R.greenLight,
//             'icon': Icons.attach_money_rounded,
//           },
//           {
//             'title': 'Net Profit',
//             'value': _fmt(_netRevenue),
//             'color': _R.blue,
//             'bg': _R.blueLight,
//             'icon': Icons.account_balance_wallet_rounded,
//           },
//           {
//             'title': 'Profit Margin',
//             'value': _profitMargin,
//             'color': _R.purple,
//             'bg': _R.purpleLight,
//             'icon': Icons.trending_up_rounded,
//           },
//         ];
//         break;
//       case 'revenue':
//         final disc = (_detailedStatistics?.grossRevenue ?? 0) > _totalRevenue
//             ? (_detailedStatistics!.grossRevenue - _totalRevenue)
//             : 0.0;
//         cards = [
//           {
//             'title': 'Total Revenue',
//             'value': _fmt(_totalRevenue),
//             'color': _R.green,
//             'bg': _R.greenLight,
//             'icon': Icons.attach_money_rounded,
//           },
//           {
//             'title': 'Total Orders',
//             'value': _totalOrders.toString(),
//             'color': _R.blue,
//             'bg': _R.blueLight,
//             'icon': Icons.shopping_bag_rounded,
//           },
//           {
//             'title': 'Discounts',
//             'value': _fmt(disc),
//             'color': _R.red,
//             'bg': _R.redLight,
//             'icon': Icons.discount_rounded,
//           },
//         ];
//         break;
//       case 'orders':
//         final dineIn =
//             _detailedStatistics?.orderTypeRevenueStats.dineIn.count ?? 0;
//         final takeaway =
//             _detailedStatistics?.orderTypeRevenueStats.takeaway.count ?? 0;
//         final delivery =
//             _detailedStatistics?.orderTypeRevenueStats.delivery.count ?? 0;
//         cards = [
//           {
//             'title': 'Total Orders',
//             'value': _totalOrders.toString(),
//             'color': _R.blue,
//             'bg': _R.blueLight,
//             'icon': Icons.shopping_bag_rounded,
//           },
//           {
//             'title': 'Dine-In',
//             'value': dineIn.toString(),
//             'color': _R.green,
//             'bg': _R.greenLight,
//             'icon': Icons.restaurant_rounded,
//           },
//           {
//             'title': 'Takeaway',
//             'value': takeaway.toString(),
//             'color': _R.amber,
//             'bg': _R.amberLight,
//             'icon': Icons.takeout_dining_rounded,
//           },
//           {
//             'title': 'Delivery',
//             'value': delivery.toString(),
//             'color': _R.purple,
//             'bg': _R.purpleLight,
//             'icon': Icons.delivery_dining_rounded,
//           },
//         ];
//         break;
//       case 'rating':
//         final reviews = _detailedStatistics?.totalRatings ?? 0;
//         cards = [
//           {
//             'title': 'Overall Rating',
//             'value': _avgRating,
//             'color': _R.amber,
//             'bg': _R.amberLight,
//             'icon': Icons.star_rounded,
//           },
//           {
//             'title': 'Total Reviews',
//             'value': reviews.toString(),
//             'color': _R.blue,
//             'bg': _R.blueLight,
//             'icon': Icons.reviews_rounded,
//           },
//           {
//             'title': 'Response Rate',
//             'value': '95%',
//             'color': _R.green,
//             'bg': _R.greenLight,
//             'icon': Icons.speed_rounded,
//           },
//           {
//             'title': 'Avg Response',
//             'value': '2 min',
//             'color': _R.purple,
//             'bg': _R.purpleLight,
//             'icon': Icons.access_time_rounded,
//           },
//         ];
//         break;
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         color: _R.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _R.border),
//         boxShadow: [
//           BoxShadow(
//             color: _R.shadow,
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: _R.accentLight,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.analytics_rounded,
//                     color: _R.accent,
//                     size: 14,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _activeView == 'financial'
//                       ? 'Financial Overview'
//                       : _activeView == 'revenue'
//                       ? 'Revenue Analysis'
//                       : _activeView == 'orders'
//                       ? 'Orders Breakdown'
//                       : 'Rating Overview',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: _R.text1,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '${DateFormat('MMM d').format(_startDate)} – ${DateFormat('MMM d').format(_endDate)}',
//                   style: const TextStyle(fontSize: 11, color: _R.text2),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             Row(
//               children: cards
//                   .map(
//                     (c) => Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: _viewCard(c),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _viewCard(Map<String, dynamic> c) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//       decoration: BoxDecoration(
//         color: (c['bg'] as Color),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: (c['color'] as Color).withOpacity(0.15)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(c['icon'] as IconData, color: c['color'] as Color, size: 20),
//           const SizedBox(height: 6),
//           Text(
//             c['value'] as String,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: c['color'] as Color,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 3),
//           Text(
//             c['title'] as String,
//             style: const TextStyle(
//               fontSize: 9,
//               color: _R.text2,
//               fontWeight: FontWeight.w500,
//             ),
//             maxLines: 2,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Orders & Revenue Chart ────────────────────────────────────────────────────
//   Widget _buildOrdersRevenueGraph() {
//     List<FlSpot> orderSpots = [];
//     List<FlSpot> revenueSpots = [];
//     List<DailyStat> dailyStats = [];
//     bool isDailyStats = false;
//
//     if (_detailedStatistics != null &&
//         _detailedStatistics!.dailyStats.isNotEmpty) {
//       dailyStats = List.from(_detailedStatistics!.dailyStats)
//         ..sort((a, b) => a.date.compareTo(b.date));
//       orderSpots = dailyStats
//           .asMap()
//           .entries
//           .map((e) => FlSpot(e.key.toDouble(), e.value.orders.toDouble()))
//           .toList();
//       revenueSpots = dailyStats
//           .asMap()
//           .entries
//           .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
//           .toList();
//       isDailyStats = true;
//     } else if (_statistics != null) {
//       orderSpots = List.generate(
//         7,
//         (i) => FlSpot(
//           i.toDouble(),
//           (_statistics!.weeklyOrders / 7 * (i + 1)).toDouble(),
//         ),
//       );
//       revenueSpots = List.generate(
//         7,
//         (i) => FlSpot(
//           i.toDouble(),
//           (_statistics!.weeklyRevenue / 7 * (i + 1)).toDouble(),
//         ),
//       );
//     }
//
//     if (orderSpots.isEmpty) return const SizedBox.shrink();
//
//     final maxO = orderSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
//     final maxR = revenueSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
//
//     return _chartCard(
//       title: isDailyStats ? 'Daily Trends' : 'Weekly Overview',
//       subtitle: isDailyStats
//           ? 'Orders & Revenue by day'
//           : 'Orders & Revenue (7 days)',
//       child: Column(
//         children: [
//           AspectRatio(
//             aspectRatio: 1.8,
//             child: LineChart(
//               LineChartData(
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: false,
//                   getDrawingHorizontalLine: (_) =>
//                       FlLine(color: _R.border, strokeWidth: 1),
//                 ),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 36,
//                       interval: maxO > 0 ? maxO / 4 : 1,
//                       getTitlesWidget: (v, _) => Text(
//                         '${v.toInt()}',
//                         style: const TextStyle(fontSize: 9, color: _R.text2),
//                       ),
//                     ),
//                   ),
//                   rightTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 46,
//                       interval: maxR > 0 ? maxR / 4 : 1,
//                       getTitlesWidget: (v, _) => Text(
//                         _fmt(v),
//                         style: const TextStyle(fontSize: 9, color: _R.text2),
//                       ),
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 28,
//                       getTitlesWidget: (v, _) {
//                         if (isDailyStats && v.toInt() < dailyStats.length) {
//                           final d = DateTime.tryParse(
//                             dailyStats[v.toInt()].date,
//                           );
//                           return d != null
//                               ? Text(
//                                   DateFormat('d\nMMM').format(d),
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     fontSize: 8,
//                                     color: _R.text2,
//                                   ),
//                                 )
//                               : const Text('');
//                         }
//                         const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
//                         final i = v.toInt();
//                         return i < days.length
//                             ? Text(
//                                 days[i],
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: _R.text2,
//                                 ),
//                               )
//                             : const Text('');
//                       },
//                     ),
//                   ),
//                   topTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                 ),
//                 borderData: FlBorderData(
//                   show: true,
//                   border: Border.all(color: _R.border),
//                 ),
//                 lineBarsData: [
//                   _lineBar(orderSpots, _R.blue),
//                   _lineBar(revenueSpots, _R.amber),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               _LegendDot(color: _R.blue, label: 'Orders'),
//               SizedBox(width: 16),
//               _LegendDot(color: _R.amber, label: 'Revenue (₹)'),
//             ],
//           ),
//           if (_showWeekDetails && _detailedStatistics != null) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _R.bg,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: _R.border),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Period: ${_detailedStatistics!.period}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12,
//                       color: _R.text1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Total Orders: ${_detailedStatistics!.totalOrders}',
//                     style: const TextStyle(fontSize: 12, color: _R.text2),
//                   ),
//                   Text(
//                     'Total Revenue: ${_fmt(_detailedStatistics!.totalRevenue)}',
//                     style: const TextStyle(fontSize: 12, color: _R.text2),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           const SizedBox(height: 6),
//           GestureDetector(
//             onTap: () => setState(() => _showWeekDetails = !_showWeekDetails),
//             child: Text(
//               _showWeekDetails ? 'Hide details ↑' : 'Show details ↓',
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: _R.accent,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   LineChartBarData _lineBar(List<FlSpot> spots, Color color) =>
//       LineChartBarData(
//         spots: spots,
//         isCurved: true,
//         color: color,
//         barWidth: 2.5,
//         dotData: FlDotData(
//           show: true,
//           getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
//             radius: 3,
//             color: color,
//             strokeWidth: 2,
//             strokeColor: _R.white,
//           ),
//         ),
//         belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
//       );
//
//   // ── Top Selling Chart ─────────────────────────────────────────────────────────
//   Widget _buildTopSellingChart() {
//     List<Map<String, dynamic>> items = [];
//     final colors = [
//       _R.green,
//       _R.amber,
//       _R.blue,
//       _R.purple,
//       _R.red,
//       _R.teal,
//       const Color(0xFFEC4899),
//       const Color(0xFF6366F1),
//     ];
//
//     if (_detailedStatistics != null &&
//         _detailedStatistics!.topSellingByCategory.isNotEmpty) {
//       items = _detailedStatistics!.topSellingByCategory
//           .asMap()
//           .entries
//           .map(
//             (e) => {
//               'label': e.value.item,
//               'orders': e.value.quantity,
//               'category': e.value.category,
//               'color': colors[e.key % colors.length],
//             },
//           )
//           .toList();
//     } else if (_statistics != null && _statistics!.topSellingItems.isNotEmpty) {
//       items = _statistics!.topSellingItems
//           .asMap()
//           .entries
//           .map(
//             (e) => {
//               'label': e.value.name,
//               'orders': e.value.count,
//               'category': '',
//               'color': colors[e.key % colors.length],
//             },
//           )
//           .toList();
//     }
//
//     if (items.isEmpty)
//       return _chartCard(
//         title: 'Top Selling Items',
//         subtitle: 'No data available',
//         child: const SizedBox(
//           height: 80,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.bar_chart_rounded, size: 40, color: _R.text3),
//                 SizedBox(height: 8),
//                 Text(
//                   'No top selling data',
//                   style: TextStyle(color: _R.text2, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//
//     return _chartCard(
//       title: 'Top Selling Items',
//       subtitle: _detailedStatistics?.period ?? 'by category',
//       child: Column(
//         children: [
//           AspectRatio(
//             aspectRatio: 1.7,
//             child: BarChart(
//               BarChartData(
//                 borderData: FlBorderData(show: false),
//                 gridData: FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 28,
//                       getTitlesWidget: (v, _) => Text(
//                         '${v.toInt()}',
//                         style: const TextStyle(fontSize: 9, color: _R.text2),
//                       ),
//                     ),
//                   ),
//                   rightTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   topTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 28,
//                       getTitlesWidget: (v, _) {
//                         final i = v.toInt();
//                         if (i < 0 || i >= items.length) return const Text('');
//                         final l = items[i]['label'] as String;
//                         return Text(
//                           l.length > 7 ? '${l.substring(0, 7)}…' : l,
//                           style: const TextStyle(fontSize: 8, color: _R.text2),
//                           textAlign: TextAlign.center,
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 barGroups: items.asMap().entries.map((e) {
//                   final c = e.value['color'] as Color;
//                   return BarChartGroupData(
//                     x: e.key,
//                     barRods: [
//                       BarChartRodData(
//                         toY: (e.value['orders'] as num).toDouble(),
//                         gradient: LinearGradient(
//                           colors: [c, c.withOpacity(0.6)],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                         width: 20,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                     ],
//                     showingTooltipIndicators: _selectedBarIndex == e.key
//                         ? [0]
//                         : [],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             alignment: WrapAlignment.center,
//             spacing: 10,
//             runSpacing: 6,
//             children: items
//                 .map(
//                   (e) => _LegendDot(
//                     color: e['color'] as Color,
//                     label: e['label'] as String,
//                   ),
//                 )
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Payment Pie Chart ─────────────────────────────────────────────────────────
//   Widget _buildPaymentPieChart() {
//     if (_detailedStatistics == null) {
//       return _chartCard(
//         title: 'Payment Distribution',
//         subtitle: 'Select a date range to view',
//         child: const SizedBox(
//           height: 80,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.pie_chart_outline_rounded,
//                   size: 40,
//                   color: _R.text3,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'No payment data',
//                   style: TextStyle(color: _R.text2, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     final pb = _detailedStatistics!.paymentBreakdown;
//     final total = pb.onlinePayment + pb.cash + pb.maamaasWallet;
//
//     final raw = [
//       {'label': 'Online', 'amount': pb.onlinePayment, 'color': _R.green},
//       {'label': 'Cash', 'amount': pb.cash, 'color': _R.blue},
//       {'label': 'Wallet', 'amount': pb.maamaasWallet, 'color': _R.amber},
//     ];
//     final payments = raw.where((p) => (p['amount'] as double) > 0).toList();
//
//     if (payments.isEmpty)
//       return _chartCard(
//         title: 'Payment Distribution',
//         subtitle: 'No payments recorded',
//         child: const SizedBox(
//           height: 60,
//           child: Center(
//             child: Text('No payment data', style: TextStyle(color: _R.text2)),
//           ),
//         ),
//       );
//
//     return _chartCard(
//       title: 'Payment Distribution',
//       subtitle: _detailedStatistics!.period,
//       child: Column(
//         children: [
//           AspectRatio(
//             aspectRatio: 1.4,
//             child: PieChart(
//               PieChartData(
//                 sectionsSpace: 3,
//                 centerSpaceRadius: 50,
//                 centerSpaceColor: _R.bg,
//                 pieTouchData: PieTouchData(
//                   touchCallback: (_, res) {
//                     setState(() {
//                       _selectedPie = (res?.touchedSection?.touchedSectionIndex);
//                     });
//                   },
//                 ),
//                 sections: payments.asMap().entries.map((e) {
//                   final p = e.value;
//                   final isSelected = _selectedPie == e.key;
//                   final amt = p['amount'] as double;
//                   final pct = total > 0 ? (amt / total * 100) : 0.0;
//                   return PieChartSectionData(
//                     color: p['color'] as Color,
//                     value: amt,
//                     title: '${pct.toStringAsFixed(0)}%',
//                     radius: isSelected ? 72 : 60,
//                     titleStyle: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: _R.bg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _R.border),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Total Payments',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 13,
//                         color: _R.text1,
//                       ),
//                     ),
//                     Text(
//                       _fmt(total),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 13,
//                         color: _R.accent,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 ...payments.map(
//                   (p) => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 3),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 10,
//                           height: 10,
//                           decoration: BoxDecoration(
//                             color: p['color'] as Color,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             p['label'] as String,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: _R.text2,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '${_fmt(p['amount'] as double)}  ${total > 0 ? (((p['amount'] as double) / total) * 100).toStringAsFixed(1) : 0}%',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: _R.text1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Date Picker Overlay ───────────────────────────────────────────────────────
//   Widget _buildDatePickerOverlay() {
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         margin: const EdgeInsets.all(12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: _R.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: _R.border),
//           boxShadow: [
//             BoxShadow(
//               color: _R.shadowMd,
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 const Icon(
//                   Icons.calendar_month_rounded,
//                   color: _R.accent,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Select Date Range',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14,
//                     color: _R.text1,
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () => setState(() => _showDatePicker = false),
//                   child: const Icon(
//                     Icons.close_rounded,
//                     color: _R.text2,
//                     size: 18,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             Row(
//               children: [
//                 Expanded(
//                   child: _dateField('From', _startDate, () async {
//                     final d = await showDatePicker(
//                       context: context,
//                       initialDate: _startDate,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime.now(),
//                       builder: (ctx, child) => Theme(
//                         data: ThemeData.light().copyWith(
//                           colorScheme: const ColorScheme.light(
//                             primary: _R.accent,
//                           ),
//                         ),
//                         child: child!,
//                       ),
//                     );
//                     if (d != null) setState(() => _startDate = d);
//                   }),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     '→',
//                     style: TextStyle(color: _R.text3, fontSize: 16),
//                   ),
//                 ),
//                 Expanded(
//                   child: _dateField('To', _endDate, () async {
//                     final d = await showDatePicker(
//                       context: context,
//                       initialDate: _endDate,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime.now(),
//                       builder: (ctx, child) => Theme(
//                         data: ThemeData.light().copyWith(
//                           colorScheme: const ColorScheme.light(
//                             primary: _R.accent,
//                           ),
//                         ),
//                         child: child!,
//                       ),
//                     );
//                     if (d != null) setState(() => _endDate = d);
//                   }),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => _showDatePicker = false),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 11),
//                       decoration: BoxDecoration(
//                         color: _R.bg,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: _R.border),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: _R.text2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       _handleDateApply();
//                       final views = [
//                         'financial',
//                         'revenue',
//                         'orders',
//                         'rating',
//                       ];
//                       _tabController.index = views
//                           .indexOf(_activeView)
//                           .clamp(0, 3);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 11),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [_R.accent, _R.accentDark],
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: _isLoadingCustom
//                           ? const Center(
//                               child: SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             )
//                           : const Center(
//                               child: Text(
//                                 'Apply',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _dateField(String label, DateTime date, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: _R.bg,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: _R.border),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 9,
//                 color: _R.text2,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               DateFormat('MMM d, yyyy').format(date),
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: _R.text1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Error State ───────────────────────────────────────────────────────────────
//   Widget _buildError() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: _R.redLight,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               color: _R.red,
//               size: 30,
//             ),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             _errorMessage,
//             style: const TextStyle(color: _R.text2, fontSize: 14),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           GestureDetector(
//             onTap: _fetchStatistics,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [_R.accent, _R.accentDark],
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Text(
//                 'Retry',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Chart Card Wrapper ────────────────────────────────────────────────────────
//   Widget _chartCard({
//     required String title,
//     required String subtitle,
//     required Widget child,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _R.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _R.border),
//         boxShadow: [
//           BoxShadow(
//             color: _R.shadow,
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: _R.accentLight,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.bar_chart_rounded,
//                     color: _R.accent,
//                     size: 14,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           color: _R.text1,
//                         ),
//                       ),
//                       Text(
//                         subtitle,
//                         style: const TextStyle(fontSize: 10, color: _R.text2),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Legend Dot ───────────────────────────────────────────────────────────────
// class _LegendDot extends StatelessWidget {
//   final Color color;
//   final String label;
//
//   const _LegendDot({required this.color, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 11,
//             color: _R.text2,
//             fontWeight: FontWeight.w500,
//           ),
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//         ),
//       ],
//     );
//   }
// }
