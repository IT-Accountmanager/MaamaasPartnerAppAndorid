// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:intl/intl.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // import '../Api/APIclient.dart';
// // import '../CateringModels/lead_model.dart';
// // import '../caterings/quotation.dart';
// //
// // // ─── Design Tokens ─────────────────────────────────────────────────────────────
// // class _C {
// //   static const bg = Color(0xFFF7F8FC);
// //   static const white = Color(0xFFFFFFFF);
// //   static const border = Color(0xFFEEEFF5);
// //   static const accent = Color(0xFFE66D33);
// //   static const accentLt = Color(0xFFFFF0E8);
// //   static const blue = Color(0xFFE66D33);
// //   static const blueLt = Color(0xFFDBEAFE);
// //   static const green = Color(0xFF10B981);
// //   static const greenLt = Color(0xFFF7F8FC);
// //   static const amber = Color(0xFFE66D33);
// //   static const amberLt = Color(0xFFF7F8FC);
// //   static const red = Color(0xFFEF4444);
// //   static const redLt = Color(0xFFFEE2E2);
// //   static const text1 = Color(0xFF111827);
// //   static const text2 = Color(0xFF6B7280);
// //   static const text3 = Color(0xFFB0B3C1);
// //   static const shadow = Color(0x0A000000);
// // }
// //
// // const _kGrad = LinearGradient(
// //   colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
// //   begin: Alignment.topLeft,
// //   end: Alignment.bottomRight,
// // );
// //
// // class LeadManagementPage extends StatefulWidget {
// //   const LeadManagementPage({super.key});
// //   @override
// //   State<LeadManagementPage> createState() => _LeadManagementPageState();
// // }
// //
// // class _LeadManagementPageState extends State<LeadManagementPage> {
// //   bool _isLoading = false;
// //   bool _isProcessingPayment = false;
// //   List<Map<String, dynamic>> _leadsOrders = [];
// //   List<Map<String, dynamic>> _filteredOrders = [];
// //   Map<int, String> _quotationStatuses = {};
// //   Map<String, bool> _expandedLeads = {};
// //   Set<int> _newOrderIds = {};
// //
// //   int _vendorId = 0;
// //   bool _isVendorLoading = true;
// //
// //   String _searchQuery = '';
// //   String _statusFilter = 'all';
// //
// //   late Razorpay _razorpay;
// //   double _currentPaymentAmount = 0;
// //   int _currentLeadId = 0;
// //   String? _currentOrderId;
// //
// //   int _currentPage = 1;
// //   static const int _pageSize = 10;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeRazorpay();
// //     _loadVendorId();
// //   }
// //
// //   Future<void> _loadVendorId() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       int vid = prefs.getInt('vendorId') ?? prefs.getInt('VendorId') ?? 0;
// //       setState(() {
// //         _vendorId = vid;
// //         _isVendorLoading = false;
// //       });
// //       if (_vendorId != 0) _fetchLeads();
// //     } catch (_) {
// //       setState(() {
// //         _vendorId = 0;
// //         _isVendorLoading = false;
// //       });
// //     }
// //   }
// //
// //   void _initializeRazorpay() {
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }
// //
// //   void _handlePaymentSuccess(PaymentSuccessResponse r) {
// //     _capturePayment(paymentId: r.paymentId!, orderId: r.orderId!);
// //   }
// //
// //   void _handlePaymentError(PaymentFailureResponse r) {
// //     setState(() => _isProcessingPayment = false);
// //     _snack('Payment failed: ${r.message ?? 'Unknown error'}', _C.red);
// //   }
// //
// //   void _handleExternalWallet(ExternalWalletResponse _) {
// //     setState(() => _isProcessingPayment = false);
// //   }
// //
// //   Future<void> _fetchLeads() async {
// //     if (_vendorId == 0) return;
// //     setState(() => _isLoading = true);
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = _getToken(prefs);
// //       if (token == null) {
// //         setState(() => _isLoading = false);
// //         return;
// //       }
// //       final resp = await http.get(
// //         Uri.parse(
// //           'http://staging.maamaas.com:8080/catering/api/vendor/$_vendorId',
// //         ),
// //         headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
// //       );
// //       if (resp.statusCode == 200) {
// //         final result = jsonDecode(resp.body) as Map<String, dynamic>;
// //         if (result['success'] == true) {
// //           final data = result['data'] as Map<String, dynamic>;
// //           final orders = <Map<String, dynamic>>[];
// //           final Set<int> paidIds = {};
// //           if (data['fullLeads'] is List) {
// //             for (final ld in data['fullLeads'] as List) {
// //               try {
// //                 final l = Lead.fromJson(ld as Map<String, dynamic>);
// //                 if (l.id != null) paidIds.add(l.id!);
// //                 orders.add(_buildOrder(l, isPaid: true));
// //                 _expandedLeads.putIfAbsent(l.id.toString(), () => false);
// //               } catch (_) {}
// //             }
// //           }
// //           if (data['maskedLeads'] is List) {
// //             for (final ld in data['maskedLeads'] as List) {
// //               try {
// //                 final l = Lead.fromJson(ld as Map<String, dynamic>);
// //                 final paid = paidIds.contains(l.id ?? 0);
// //                 orders.add(_buildOrder(l, isPaid: paid, masked: !paid));
// //                 _expandedLeads.putIfAbsent(l.id.toString(), () => false);
// //               } catch (_) {}
// //             }
// //           }
// //           _sortByDate(orders);
// //           final curr = orders.map((o) => o['orderId'] as int).toSet();
// //           final prev = _filteredOrders.map((o) => o['orderId'] as int).toSet();
// //           setState(() {
// //             _leadsOrders = orders;
// //             _applyFilters();
// //             _isLoading = false;
// //             _newOrderIds = curr.difference(prev);
// //           });
// //           await _fetchQuotations();
// //         } else {
// //           setState(() => _isLoading = false);
// //         }
// //       } else {
// //         setState(() => _isLoading = false);
// //       }
// //     } catch (_) {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   Map<String, dynamic> _buildOrder(
// //     Lead l, {
// //     required bool isPaid,
// //     bool masked = false,
// //   }) {
// //     final total =
// //         (l.vegPlates ?? 0) + (l.nonVegPlates ?? 0) + (l.mixedPlates ?? 0);
// //     var loc = [
// //       l.city,
// //       l.state,
// //     ].where((e) => e != null && e.isNotEmpty).join(', ');
// //     if (loc.isEmpty) loc = 'Location not specified';
// //     return {
// //       'orderId': l.id ?? 0,
// //       'name': isPaid ? (l.fullName ?? 'Not specified') : '*** *** ***',
// //       'mobile': isPaid ? (l.phoneNumber ?? 'Not specified') : '***-***-****',
// //       'email': isPaid ? (l.email ?? 'Not specified') : '***@***.com',
// //       'orderDateAndTime': l.createdAt ?? '',
// //       'eventDate': l.eventDate,
// //       'fromDate': l.fromDate,
// //       'toDate': l.toDate,
// //       'eventTime': l.eventTime,
// //       'eventType': l.eventType ?? 'Event',
// //       'eventName': _eventName(l.eventType ?? 'Event'),
// //       'numberOfPlates': total,
// //       'clientLocation': loc,
// //       'leadPrice': l.leadPrice ?? 0.0,
// //       'items': l.items ?? {},
// //       'addOns': (l.addOns ?? [])
// //           .map(
// //             (a) => {
// //               'addOnType': a.addOnType,
// //               'quantity': a.quantity,
// //               'selected': a.selected,
// //             },
// //           )
// //           .toList(),
// //       'vegPlates': l.vegPlates ?? 0,
// //       'nonVegPlates': l.nonVegPlates ?? 0,
// //       'mixedPlates': l.mixedPlates ?? 0,
// //       'additionalRequests': l.additionalRequests ?? '',
// //       'accessMessage': l.accessMessage ?? 'Payment required for full details',
// //       'masked': masked,
// //       'leadStatus': l.leadStatus,
// //       'actualName': l.fullName,
// //       'actualMobile': l.phoneNumber,
// //       'actualEmail': l.email,
// //       'actualCity': l.city,
// //       'actualState': l.state,
// //       'actualItems': l.items ?? {},
// //       'actualAddOns': l.addOns,
// //       'actualAdditionalRequests': l.additionalRequests,
// //       'isPaid': isPaid,
// //     };
// //   }
// //
// //   String _eventName(String t) =>
// //       const {
// //         'DAILY': 'Daily',
// //         'WEEKLY': 'Weekly',
// //         'MONTHLY': 'Monthly',
// //         'YEARLY': 'Yearly',
// //         'CORPORATE': 'Corporate',
// //         'WEDDING': 'Wedding',
// //         'BIRTHDAY': 'Birthday Party',
// //         'ENGAGEMENT': 'Engagement',
// //         'FESTIVAL': 'Festival Celebration',
// //       }[t] ??
// //       t;
// //   void _sortByDate(List<Map<String, dynamic>> orders) => orders.sort((a, b) {
// //     final ap = a['isPaid'] as bool? ?? false;
// //     final bp = b['isPaid'] as bool? ?? false;
// //     if (ap != bp) return ap ? 1 : -1;
// //     try {
// //       return DateTime.parse(
// //         b['orderDateAndTime'],
// //       ).compareTo(DateTime.parse(a['orderDateAndTime']));
// //     } catch (_) {
// //       return 0;
// //     }
// //   });
// //
// //   void _applyFilters() {
// //     setState(() {
// //       _filteredOrders = _leadsOrders.where((o) {
// //         if (_searchQuery.isNotEmpty) {
// //           final id = o['orderId'].toString();
// //           final name = o['actualName']?.toString().toLowerCase() ?? '';
// //           if (!id.contains(_searchQuery) &&
// //               !name.contains(_searchQuery.toLowerCase()))
// //             return false;
// //         }
// //         if (_statusFilter == 'paid' && !(o['isPaid'] as bool? ?? false))
// //           return false;
// //         if (_statusFilter == 'unpaid' && (o['isPaid'] as bool? ?? false))
// //           return false;
// //         return true;
// //       }).toList();
// //       _sortByDate(_filteredOrders);
// //     });
// //   }
// //
// //   Future<void> _fetchQuotations() async {
// //     if (_vendorId == 0) return;
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = _getToken(prefs);
// //       if (token == null) return;
// //       final resp = await http.get(
// //         Uri.parse(
// //           'http://staging.maamaas.com:8080/catering/api/vendor/quotations/$_vendorId',
// //         ),
// //         headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
// //       );
// //       if (resp.statusCode == 200) {
// //         final result = jsonDecode(resp.body) as Map<String, dynamic>;
// //         if (result['success'] == true) {
// //           final qs = result['data'] as List? ?? [];
// //           setState(() {
// //             _quotationStatuses.clear();
// //             for (final q in qs) {
// //               final lid = q['leadId'] as int?;
// //               final s = q['status'] as String?;
// //               if (lid != null && s != null) _quotationStatuses[lid] = s;
// //             }
// //           });
// //         }
// //       }
// //     } catch (_) {}
// //   }
// //
// //   Future<void> _handlePaymentForLead(Map<String, dynamic> order) async {
// //     final leadId = order['orderId'] as int;
// //     final amount = order['leadPrice'] as double? ?? 0.0;
// //     if (amount <= 0) {
// //       _snack('Invalid payment amount', _C.red);
// //       return;
// //     }
// //     setState(() {
// //       _isProcessingPayment = true;
// //       _currentLeadId = leadId;
// //       _currentPaymentAmount = amount;
// //     });
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = _getToken(prefs);
// //       if (token == null) {
// //         setState(() => _isProcessingPayment = false);
// //         _snack('Authentication token not found', _C.red);
// //         return;
// //       }
// //       final orderResp = await _createPaymentOrder(amount: amount);
// //       if (orderResp == null) {
// //         setState(() => _isProcessingPayment = false);
// //         _snack('Failed to create payment order', _C.red);
// //         return;
// //       }
// //       final orderId = orderResp['orderId'];
// //       if (orderId == null) {
// //         setState(() => _isProcessingPayment = false);
// //         throw Exception('Order ID not returned');
// //       }
// //       _currentOrderId = orderId;
// //       _razorpay.open({
// //         'key': 'rzp_live_TJDvykibQEsCuN',
// //         'amount': (amount * 100).toInt(),
// //         'currency': 'INR',
// //         'name': 'Maamaas Catering',
// //         'description': 'Lead #$leadId - View Full Details',
// //         'order_id': orderId,
// //         'prefill': {
// //           'contact': order['actualMobile'] ?? '',
// //           'email': order['actualEmail'] ?? '',
// //         },
// //         'notes': {
// //           'leadId': leadId.toString(),
// //           'vendorId': _vendorId.toString(),
// //         },
// //       });
// //     } catch (e) {
// //       setState(() => _isProcessingPayment = false);
// //       _snack('Payment initiation failed: $e', _C.red);
// //     }
// //   }
// //
// //   Future<Map<String, dynamic>?> _createPaymentOrder({
// //     required double amount,
// //   }) async {
// //     try {
// //       final resp = await ApiClient.post('api/user/create-order', {
// //         'amount': amount,
// //         'currency': 'INR',
// //         'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
// //         'notes': {
// //           'source': 'catering_leads',
// //           'leadId': _currentLeadId.toString(),
// //           'vendorId': _vendorId.toString(),
// //         },
// //       }, service: 'subscription');
// //       if (resp.statusCode == 200 || resp.statusCode == 201)
// //         return jsonDecode(resp.body);
// //     } catch (_) {}
// //     return null;
// //   }
// //
// //   Future<void> _capturePayment({
// //     required String paymentId,
// //     required String orderId,
// //   }) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = _getToken(prefs);
// //       if (token == null) {
// //         setState(() => _isProcessingPayment = false);
// //         _snack('Auth token not found', _C.red);
// //         return;
// //       }
// //       final capture = await _captureOnBackend(
// //         paymentId: paymentId,
// //         amount: _currentPaymentAmount,
// //       );
// //       if (capture != null) {
// //         await _initiatePayment(
// //           leadId: _currentLeadId,
// //           vendorId: _vendorId,
// //           amount: _currentPaymentAmount,
// //           orderId: orderId,
// //           token: token,
// //           paymentId: paymentId,
// //         );
// //       } else {
// //         setState(() => _isProcessingPayment = false);
// //         _snack('Failed to capture payment', _C.red);
// //       }
// //     } catch (_) {
// //       setState(() => _isProcessingPayment = false);
// //       _snack('Payment capture failed', _C.red);
// //     }
// //   }
// //
// //   Future<Map<String, dynamic>?> _captureOnBackend({
// //     required String paymentId,
// //     required double amount,
// //   }) async {
// //     try {
// //       final resp = await ApiClient.post('api/user/capture', {
// //         'paymentId': paymentId,
// //         'amount': amount,
// //         'currency': 'INR',
// //       }, service: 'subscription');
// //       if (resp.statusCode == 200 || resp.statusCode == 201)
// //         return jsonDecode(resp.body);
// //     } catch (_) {}
// //     return null;
// //   }
// //
// //   Future<void> _initiatePayment({
// //     required int leadId,
// //     required int vendorId,
// //     required double amount,
// //     required String orderId,
// //     required String token,
// //     required String paymentId,
// //   }) async {
// //     try {
// //       final resp = await http.post(
// //         Uri.parse(
// //           'http://staging.maamaas.com:8080/catering/api/vendor/payment/initiate?leadId=$leadId&vendorId=$vendorId&amount=$amount&orderid=$orderId',
// //         ),
// //         headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
// //       );
// //       if (resp.statusCode == 200 || resp.statusCode == 201) {
// //         await _handleSuccess(leadId);
// //       } else {
// //         setState(() => _isProcessingPayment = false);
// //         _snack('Failed to update payment status', _C.red);
// //       }
// //     } catch (_) {
// //       setState(() => _isProcessingPayment = false);
// //       _snack('Payment verification failed', _C.red);
// //     }
// //   }
// //
// //   Future<void> _handleSuccess(int leadId) async {
// //     setState(() {
// //       _isProcessingPayment = false;
// //       _updateAsPaid(leadId);
// //       _expandedLeads[leadId.toString()] = true;
// //       _sortByDate(_filteredOrders);
// //     });
// //     _snack('Payment successful! You can now view full lead details.', _C.green);
// //     await _fetchLeads();
// //   }
// //
// //   void _updateAsPaid(int leadId) {
// //     for (final list in [_filteredOrders, _leadsOrders]) {
// //       for (int i = 0; i < list.length; i++) {
// //         if (list[i]['orderId'] == leadId) {
// //           list[i]['isPaid'] = true;
// //           list[i]['masked'] = false;
// //           if (list[i]['actualName'] != null)
// //             list[i]['name'] = list[i]['actualName'];
// //           if (list[i]['actualMobile'] != null)
// //             list[i]['mobile'] = list[i]['actualMobile'];
// //           if (list[i]['actualEmail'] != null)
// //             list[i]['email'] = list[i]['actualEmail'];
// //           break;
// //         }
// //       }
// //     }
// //   }
// //
// //   String _quotBtnText(Map<String, dynamic> order) {
// //     final s = _quotationStatuses[order['orderId'] as int];
// //     if (s == null) return 'Create Quotation';
// //     switch (s) {
// //       case 'SELECTED':
// //         return 'Quotation Accepted';
// //       case 'SUBMITTED':
// //         return 'Quotation Submitted';
// //       case 'REJECTED':
// //         return 'Quotation Rejected';
// //       default:
// //         return 'Create Quotation';
// //     }
// //   }
// //
// //   Color _quotBtnColor(String text) {
// //     switch (text) {
// //       case 'Quotation Accepted':
// //         return _C.green;
// //       case 'Quotation Submitted':
// //         return _C.amber;
// //       case 'Quotation Rejected':
// //         return _C.red;
// //       default:
// //         return _C.accent;
// //     }
// //   }
// //
// //   void _goToQuotation(Map<String, dynamic> order) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => QuotationScreen(
// //           order: {
// //             'id': order['orderId'],
// //             'leadId': order['orderId'],
// //             'orderId': order['orderId'],
// //             'name': order['actualName'] ?? order['name'],
// //             'fullName': order['actualName'] ?? order['name'],
// //             'phoneNumber': order['actualMobile'] ?? order['mobile'],
// //             'email': order['actualEmail'] ?? order['email'],
// //             'eventType': order['eventType'],
// //             'eventDate': order['eventDate'],
// //             'eventTime': order['eventTime'],
// //             'fromDate': order['fromDate'],
// //             'toDate': order['toDate'],
// //             'vegPlates': order['vegPlates'],
// //             'nonVegPlates': order['nonVegPlates'],
// //             'mixedPlates': order['mixedPlates'],
// //             'totalPlates': order['numberOfPlates'],
// //             'items': order['actualItems'] ?? order['items'],
// //             'addOns': order['actualAddOns'] ?? order['addOns'] ?? [],
// //             'additionalRequests':
// //                 order['actualAdditionalRequests'] ??
// //                 order['additionalRequests'],
// //             'fullAddress': order['clientLocation'],
// //             'address': order['clientLocation'],
// //             'city': order['actualCity'],
// //             'state': order['actualState'],
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   String? _getToken(SharedPreferences prefs) {
// //     for (final k in [
// //       'authToken',
// //       'token',
// //       'accessToken',
// //       'jwtToken',
// //       'bearerToken',
// //       'userToken',
// //     ]) {
// //       final v = prefs.get(k);
// //       if (v != null) return v.toString();
// //     }
// //     return null;
// //   }
// //
// //   void _snack(String msg, Color color) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           msg,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         backgroundColor: color,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //       ),
// //     );
// //   }
// //
// //   List<Map<String, dynamic>> get _paginated {
// //     final s = (_currentPage - 1) * _pageSize;
// //     final e = s + _pageSize;
// //     if (s >= _filteredOrders.length) return [];
// //     return _filteredOrders.sublist(
// //       s,
// //       e > _filteredOrders.length ? _filteredOrders.length : e,
// //     );
// //   }
// //
// //   int get _totalPages =>
// //       _filteredOrders.isEmpty ? 1 : (_filteredOrders.length / _pageSize).ceil();
// //
// //   @override
// //   void dispose() {
// //     _razorpay.clear();
// //     super.dispose();
// //   }
// //
// //   // ─── BUILD ──────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     SystemChrome.setSystemUIOverlayStyle(
// //       const SystemUiOverlayStyle(
// //         statusBarColor: Colors.transparent,
// //         statusBarIconBrightness: Brightness.dark,
// //       ),
// //     );
// //
// //     if (_isVendorLoading)
// //       return Scaffold(
// //         backgroundColor: _C.bg,
// //         body: const Center(
// //           child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
// //         ),
// //       );
// //     if (_vendorId == 0)
// //       return Scaffold(
// //         backgroundColor: _C.bg,
// //         body: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(Icons.error_outline_rounded, size: 48, color: _C.red),
// //               const SizedBox(height: 14),
// //               const Text(
// //                 'Vendor ID not found',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w700,
// //                   color: _C.text1,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               const Text(
// //                 'Please login again',
// //                 style: TextStyle(fontSize: 13, color: _C.text2),
// //               ),
// //               const SizedBox(height: 20),
// //               GestureDetector(
// //                 onTap: _loadVendorId,
// //                 child: Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 24,
// //                     vertical: 11,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     gradient: _kGrad,
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: const Text(
// //                     'Retry',
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //
// //     if (_isProcessingPayment) return _buildPaymentOverlay();
// //
// //     return Scaffold(
// //       backgroundColor: _C.bg,
// //       // ── AppBar handles status bar — SafeArea on body NOT needed ────────────
// //       appBar: _buildAppBar(),
// //       body: Column(
// //         children: [
// //           _buildSearchBar(),
// //           _buildStatsBar(),
// //           Expanded(
// //             child: _isLoading
// //                 ? _buildLoading()
// //                 : _filteredOrders.isEmpty
// //                 ? _buildEmpty()
// //                 : RefreshIndicator(
// //                     color: _C.accent,
// //                     onRefresh: _fetchLeads,
// //                     child: ListView.builder(
// //                       padding: EdgeInsets.fromLTRB(
// //                         16.w,
// //                         10.h,
// //                         16.w,
// //                         24.h + MediaQuery.of(context).padding.bottom,
// //                       ),
// //                       itemCount: _paginated.length,
// //                       itemBuilder: (_, i) => _buildLeadCard(_paginated[i]),
// //                     ),
// //                   ),
// //           ),
// //           if (_totalPages > 1) _buildPagination(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── AppBar — white, matches app design ────────────────────────────────────────
// //   PreferredSizeWidget _buildAppBar() {
// //     return AppBar(
// //       backgroundColor: _C.white,
// //       elevation: 0,
// //       leading: GestureDetector(
// //         onTap: () => Navigator.pop(context),
// //         child: Container(
// //           margin: const EdgeInsets.all(8),
// //           decoration: BoxDecoration(
// //             color: _C.bg,
// //             borderRadius: BorderRadius.circular(10),
// //             border: Border.all(color: _C.border),
// //           ),
// //           child: const Icon(
// //             Icons.arrow_back_ios_new_rounded,
// //             size: 16,
// //             color: _C.text1,
// //           ),
// //         ),
// //       ),
// //       title: const Text(
// //         'Lead Management',
// //         style: TextStyle(
// //           fontSize: 17,
// //           fontWeight: FontWeight.w800,
// //           color: _C.text1,
// //           letterSpacing: -0.3,
// //         ),
// //       ),
// //
// //       bottom: PreferredSize(
// //         preferredSize: const Size.fromHeight(1),
// //         child: Container(height: 1, color: _C.border),
// //       ),
// //     );
// //   }
// //
// //   // ── Search + filter bar ───────────────────────────────────────────────────────
// //   Widget _buildSearchBar() {
// //     return Container(
// //       color: _C.white,
// //       padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: Container(
// //               height: 40.h,
// //               decoration: BoxDecoration(
// //                 color: _C.bg,
// //                 borderRadius: BorderRadius.circular(10.r),
// //                 border: Border.all(color: _C.border),
// //               ),
// //               child: TextField(
// //                 style: TextStyle(fontSize: 13.sp, color: _C.text1),
// //                 onChanged: (v) {
// //                   _searchQuery = v;
// //                   _applyFilters();
// //                   _currentPage = 1;
// //                 },
// //                 decoration: InputDecoration(
// //                   hintText: 'Search by ID or name...',
// //                   hintStyle: TextStyle(fontSize: 12.sp, color: _C.text3),
// //                   prefixIcon: Icon(
// //                     Icons.search_rounded,
// //                     size: 18.sp,
// //                     color: _C.text3,
// //                   ),
// //                   border: InputBorder.none,
// //                   contentPadding: EdgeInsets.symmetric(vertical: 10.h),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           SizedBox(width: 10.w),
// //           Container(
// //             height: 40.h,
// //             padding: EdgeInsets.symmetric(horizontal: 12.w),
// //             decoration: BoxDecoration(
// //               color: _C.accentLt,
// //               borderRadius: BorderRadius.circular(10.r),
// //               border: Border.all(color: _C.accent.withOpacity(0.3)),
// //             ),
// //             child: DropdownButton<String>(
// //               value: _statusFilter,
// //               underline: const SizedBox(),
// //               icon: Icon(
// //                 Icons.arrow_drop_down_rounded,
// //                 color: _C.accent,
// //                 size: 20.sp,
// //               ),
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 fontWeight: FontWeight.w600,
// //                 color: _C.accent,
// //               ),
// //               onChanged: (v) {
// //                 setState(() {
// //                   _statusFilter = v!;
// //                   _applyFilters();
// //                   _currentPage = 1;
// //                 });
// //               },
// //               items: const [
// //                 DropdownMenuItem(value: 'all', child: Text('All Leads')),
// //                 DropdownMenuItem(value: 'paid', child: Text('Paid')),
// //                 DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Stats bar ─────────────────────────────────────────────────────────────────
// //   Widget _buildStatsBar() {
// //     final paid = _filteredOrders.where((o) => o['isPaid'] == true).length;
// //     final unpaid = _filteredOrders.where((o) => o['isPaid'] != true).length;
// //     return Container(
// //       color: _C.white,
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
// //       child: Row(
// //         children: [
// //           _statChip('Total', _filteredOrders.length.toString(), _C.accent),
// //           SizedBox(width: 12.w),
// //           _statChip('Paid', paid.toString(), _C.green),
// //           SizedBox(width: 12.w),
// //           _statChip('Unpaid', unpaid.toString(), _C.amber),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _statChip(String label, String value, Color color) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(20.r),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Text(
// //             '$label: ',
// //             style: TextStyle(fontSize: 11.sp, color: _C.text2),
// //           ),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               fontWeight: FontWeight.w700,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Lead card ─────────────────────────────────────────────────────────────────
// //   Widget _buildLeadCard(Map<String, dynamic> order) {
// //     final orderId = order['orderId'].toString();
// //     final isPaid = order['isPaid'] as bool? ?? false;
// //     final isExpanded = _expandedLeads[orderId] ?? false;
// //     final isNew = _newOrderIds.contains(order['orderId'] as int);
// //     final quotText = _quotBtnText(order);
// //     final quotColor = _quotBtnColor(quotText);
// //     final canQuot = quotText == 'Create Quotation';
// //
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 12.h),
// //       decoration: BoxDecoration(
// //         color: _C.white,
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(
// //           color: isNew ? _C.accent.withOpacity(0.4) : _C.border,
// //           width: isNew ? 1.5 : 1,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: isNew ? _C.accent.withOpacity(0.08) : _C.shadow,
// //             blurRadius: 8,
// //             offset: const Offset(0, 3),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Header
// //           Container(
// //             padding: EdgeInsets.all(14.r),
// //             decoration: BoxDecoration(
// //               color: isPaid ? _C.greenLt : _C.amberLt,
// //               borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 8.r,
// //                   height: 8.r,
// //                   decoration: BoxDecoration(
// //                     color: isPaid ? _C.green : _C.amber,
// //                     shape: BoxShape.circle,
// //                   ),
// //                 ),
// //                 SizedBox(width: 8.w),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Lead #${order['orderId']}',
// //                         style: TextStyle(
// //                           fontSize: 14.sp,
// //                           fontWeight: FontWeight.w800,
// //                           color: _C.text1,
// //                         ),
// //                       ),
// //                       SizedBox(height: 2.h),
// //                       Text(
// //                         order['eventName'] as String? ?? 'Event',
// //                         style: TextStyle(
// //                           fontSize: 12.sp,
// //                           fontWeight: FontWeight.w600,
// //                           color: isPaid ? _C.green : _C.amber,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       _fmtDate(
// //                         (order['eventDate'] ?? order['fromDate']) as String?,
// //                       ),
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         fontWeight: FontWeight.w600,
// //                         color: _C.text1,
// //                       ),
// //                     ),
// //                     if (order['eventTime'] != null)
// //                       Text(
// //                         _fmtTime(order['eventTime'] as String?),
// //                         style: TextStyle(fontSize: 10.sp, color: _C.text2),
// //                       ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           // Plates + location
// //           Padding(
// //             padding: EdgeInsets.all(14.r),
// //             child: Row(
// //               children: [
// //                 _plateChip('Total', '${order['numberOfPlates']}', _C.accent),
// //                 SizedBox(width: 8.w),
// //                 _plateChip('Veg', '${order['vegPlates'] ?? 0}', _C.green),
// //                 SizedBox(width: 8.w),
// //                 _plateChip('Non-Veg', '${order['nonVegPlates'] ?? 0}', _C.red),
// //                 const Spacer(),
// //                 Expanded(
// //                   child: Row(
// //                     children: [
// //                       Icon(
// //                         Icons.location_on_rounded,
// //                         size: 12.sp,
// //                         color: _C.text3,
// //                       ),
// //                       SizedBox(width: 4.w),
// //                       Expanded(
// //                         child: Text(
// //                           order['clientLocation'] as String? ?? '',
// //                           style: TextStyle(fontSize: 10.sp, color: _C.text2),
// //                           maxLines: 2,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           Divider(color: _C.border, height: 1),
// //
// //           // Unpaid: pay button
// //           if (!isPaid)
// //             Padding(
// //               padding: EdgeInsets.all(14.r),
// //               child: GestureDetector(
// //                 onTap: _isProcessingPayment
// //                     ? null
// //                     : () => _handlePaymentForLead(order),
// //                 child: Container(
// //                   width: double.infinity,
// //                   padding: EdgeInsets.symmetric(vertical: 13.h),
// //                   decoration: BoxDecoration(
// //                     gradient: const LinearGradient(
// //                       colors: [_C.amber, Color(0xFFD97706)],
// //                     ),
// //                     borderRadius: BorderRadius.circular(12.r),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: _C.amber.withOpacity(0.35),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 4),
// //                       ),
// //                     ],
// //                   ),
// //                   child:
// //                       (_isProcessingPayment &&
// //                           _currentLeadId == order['orderId'])
// //                       ? Center(
// //                           child: SizedBox(
// //                             width: 18.r,
// //                             height: 18.r,
// //                             child: const CircularProgressIndicator(
// //                               color: Colors.white,
// //                               strokeWidth: 2,
// //                             ),
// //                           ),
// //                         )
// //                       : Row(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Icon(
// //                               Icons.lock_open_rounded,
// //                               color: Colors.white,
// //                               size: 16.sp,
// //                             ),
// //                             SizedBox(width: 8.w),
// //                             Text(
// //                               'Pay ₹${(order['leadPrice'] as double? ?? 0.0).toStringAsFixed(0)} to Unlock',
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 13.sp,
// //                                 fontWeight: FontWeight.w700,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                 ),
// //               ),
// //             )
// //           else ...[
// //             // Paid: contact info
// //             Padding(
// //               padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
// //               child: Container(
// //                 padding: EdgeInsets.all(12.r),
// //                 decoration: BoxDecoration(
// //                   color: _C.greenLt,
// //                   borderRadius: BorderRadius.circular(10.r),
// //                   border: Border.all(color: _C.green.withOpacity(0.2)),
// //                 ),
// //                 child: Column(
// //                   children: [
// //                     _infoRow(
// //                       Icons.person_rounded,
// //                       order['actualName'] as String? ?? 'Not specified',
// //                       _C.green,
// //                     ),
// //                     SizedBox(height: 6.h),
// //                     _infoRow(
// //                       Icons.phone_rounded,
// //                       order['actualMobile'] as String? ?? 'Not specified',
// //                       _C.green,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             // Expand toggle
// //             GestureDetector(
// //               onTap: () =>
// //                   setState(() => _expandedLeads[orderId] = !isExpanded),
// //               child: Padding(
// //                 padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Text(
// //                       isExpanded ? 'Hide Details' : 'View Full Details',
// //                       style: TextStyle(
// //                         color: _C.accent,
// //                         fontSize: 12.sp,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                     SizedBox(width: 4.w),
// //                     Icon(
// //                       isExpanded
// //                           ? Icons.keyboard_arrow_up_rounded
// //                           : Icons.keyboard_arrow_down_rounded,
// //                       color: _C.accent,
// //                       size: 18.sp,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             // Expanded details
// //             if (isExpanded)
// //               Padding(
// //                 padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Divider(color: _C.border, height: 1),
// //                     SizedBox(height: 12.h),
// //                     _sectionLabel('Contact Details'),
// //                     _detailsCard([
// //                       _detailRow(
// //                         'Name',
// //                         order['actualName'] as String? ?? 'Not specified',
// //                       ),
// //                       _detailRow(
// //                         'Phone',
// //                         order['actualMobile'] as String? ?? 'Not specified',
// //                       ),
// //                       _detailRow(
// //                         'Email',
// //                         order['actualEmail'] as String? ?? 'Not specified',
// //                       ),
// //                       _detailRow(
// //                         'Location',
// //                         order['clientLocation'] as String? ?? 'Not specified',
// //                       ),
// //                     ]),
// //                     SizedBox(height: 12.h),
// //                     if (order['addOns'] != null &&
// //                         (order['addOns'] as List).isNotEmpty) ...[
// //                       _sectionLabel('Add-Ons'),
// //                       _addOnsCard(order['addOns'] as List),
// //                       SizedBox(height: 12.h),
// //                     ],
// //                     if (order['items'] is Map &&
// //                         (order['items'] as Map).isNotEmpty) ...[
// //                       _sectionLabel('Menu Items'),
// //                       _menuItemsCard(order['items'] as Map<String, dynamic>),
// //                       SizedBox(height: 12.h),
// //                     ],
// //                     if ((order['additionalRequests'] as String?)?.isNotEmpty ==
// //                         true) ...[
// //                       _sectionLabel('Additional Requests'),
// //                       Container(
// //                         width: double.infinity,
// //                         padding: EdgeInsets.all(12.r),
// //                         decoration: BoxDecoration(
// //                           color: _C.bg,
// //                           borderRadius: BorderRadius.circular(10.r),
// //                           border: Border.all(color: _C.border),
// //                         ),
// //                         child: Text(
// //                           order['additionalRequests'].toString(),
// //                           style: TextStyle(fontSize: 13.sp, color: _C.text2),
// //                         ),
// //                       ),
// //                       SizedBox(height: 12.h),
// //                     ],
// //                     GestureDetector(
// //                       onTap: canQuot ? () => _goToQuotation(order) : null,
// //                       child: Container(
// //                         width: double.infinity,
// //                         padding: EdgeInsets.symmetric(vertical: 13.h),
// //                         decoration: BoxDecoration(
// //                           color: canQuot
// //                               ? quotColor
// //                               : quotColor.withOpacity(0.15),
// //                           borderRadius: BorderRadius.circular(12.r),
// //                           border: Border.all(color: quotColor.withOpacity(0.3)),
// //                         ),
// //                         child: Center(
// //                           child: Text(
// //                             quotText,
// //                             style: TextStyle(
// //                               fontSize: 13.sp,
// //                               fontWeight: FontWeight.w700,
// //                               color: canQuot ? Colors.white : quotColor,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _plateChip(String label, String value, Color color) => Container(
// //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
// //     decoration: BoxDecoration(
// //       color: color.withOpacity(0.1),
// //       borderRadius: BorderRadius.circular(8.r),
// //       border: Border.all(color: color.withOpacity(0.2)),
// //     ),
// //     child: Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 14.sp,
// //             fontWeight: FontWeight.w800,
// //             color: color,
// //           ),
// //         ),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 9.sp,
// //             color: color,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //   Widget _infoRow(IconData icon, String text, Color color) => Row(
// //     children: [
// //       Icon(icon, size: 14.sp, color: color),
// //       SizedBox(width: 8.w),
// //       Expanded(
// //         child: Text(
// //           text,
// //           style: TextStyle(
// //             fontSize: 13.sp,
// //             fontWeight: FontWeight.w600,
// //             color: _C.text1,
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// //   Widget _sectionLabel(String l) => Padding(
// //     padding: EdgeInsets.only(bottom: 8.h),
// //     child: Text(
// //       l,
// //       style: TextStyle(
// //         fontSize: 13.sp,
// //         fontWeight: FontWeight.w700,
// //         color: _C.text1,
// //       ),
// //     ),
// //   );
// //   Widget _detailsCard(List<Widget> rows) => Container(
// //     padding: EdgeInsets.all(12.r),
// //     decoration: BoxDecoration(
// //       color: _C.bg,
// //       borderRadius: BorderRadius.circular(10.r),
// //       border: Border.all(color: _C.border),
// //     ),
// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: rows.expand((w) => [w, SizedBox(height: 6.h)]).toList()
// //         ..removeLast(),
// //     ),
// //   );
// //   Widget _detailRow(String label, String value) => Row(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       SizedBox(
// //         width: 70.w,
// //         child: Text(
// //           '$label:',
// //           style: TextStyle(
// //             fontSize: 12.sp,
// //             color: _C.text2,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ),
// //       Expanded(
// //         child: Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 12.sp,
// //             color: _C.text1,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// //   Widget _addOnsCard(List addOns) {
// //     const names = {
// //       'SERVICE_BOYS': 'Service Boys',
// //       'PAPER_PLATES': 'Paper Plates',
// //       'WATER_BOTTLES': 'Water Bottles',
// //       'DISPOSABLE_CUPS': 'Disposable Cups',
// //       'TISSUE_PAPER': 'Tissue Paper',
// //     };
// //     final sel = addOns
// //         .where((a) => a is Map && (a['selected'] as bool? ?? false))
// //         .toList();
// //     if (sel.isEmpty) return const SizedBox.shrink();
// //     return Container(
// //       padding: EdgeInsets.all(12.r),
// //       decoration: BoxDecoration(
// //         color: _C.bg,
// //         borderRadius: BorderRadius.circular(10.r),
// //         border: Border.all(color: _C.border),
// //       ),
// //       child: Column(
// //         children: sel.map<Widget>((a) {
// //           final type = (a as Map)['addOnType'] as String? ?? '';
// //           final qty = a['quantity'] as int? ?? 0;
// //           return Padding(
// //             padding: EdgeInsets.symmetric(vertical: 3.h),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 5.r,
// //                   height: 5.r,
// //                   decoration: const BoxDecoration(
// //                     color: _C.accent,
// //                     shape: BoxShape.circle,
// //                   ),
// //                 ),
// //                 SizedBox(width: 8.w),
// //                 Text(
// //                   '${names[type] ?? type.replaceAll('_', ' ')} × $qty',
// //                   style: TextStyle(fontSize: 12.sp, color: _C.text2),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// //
// //   Widget _menuItemsCard(Map<String, dynamic> items) => Container(
// //     padding: EdgeInsets.all(12.r),
// //     decoration: BoxDecoration(
// //       color: _C.bg,
// //       borderRadius: BorderRadius.circular(10.r),
// //       border: Border.all(color: _C.border),
// //     ),
// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: items.entries.expand((e) {
// //         if (e.value is! List || (e.value as List).isEmpty) return <Widget>[];
// //         return [
// //           Text(
// //             e.key,
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               fontWeight: FontWeight.w700,
// //               color: _C.accent,
// //             ),
// //           ),
// //           SizedBox(height: 4.h),
// //           ...(e.value as List).map(
// //             (i) => Padding(
// //               padding: EdgeInsets.only(left: 8.w, bottom: 3.h),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 4.r,
// //                     height: 4.r,
// //                     decoration: const BoxDecoration(
// //                       color: _C.text3,
// //                       shape: BoxShape.circle,
// //                     ),
// //                   ),
// //                   SizedBox(width: 6.w),
// //                   Text(
// //                     i.toString(),
// //                     style: TextStyle(fontSize: 11.sp, color: _C.text2),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 8.h),
// //         ];
// //       }).toList(),
// //     ),
// //   );
// //
// //   String _fmtDate(String? s) {
// //     if (s == null || s.isEmpty) return 'Not specified';
// //     try {
// //       return DateFormat('dd-MMM-yyyy').format(DateTime.parse(s));
// //     } catch (_) {
// //       return s;
// //     }
// //   }
// //
// //   String _fmtTime(String? s) {
// //     if (s == null || s.isEmpty) return 'Not specified';
// //     try {
// //       return DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(s));
// //     } catch (_) {
// //       try {
// //         return DateFormat('h:mm a').format(DateFormat('HH:mm').parse(s));
// //       } catch (_) {
// //         return s;
// //       }
// //     }
// //   }
// //
// //   Widget _buildPaymentOverlay() {
// //     return Scaffold(
// //       backgroundColor: _C.bg,
// //       appBar: _buildAppBar(),
// //       body: Stack(
// //         children: [
// //           _buildLeadList(),
// //           Container(
// //             color: Colors.black.withOpacity(0.35),
// //             child: Center(
// //               child: Container(
// //                 padding: EdgeInsets.all(24.r),
// //                 decoration: BoxDecoration(
// //                   color: _C.white,
// //                   borderRadius: BorderRadius.circular(16.r),
// //                 ),
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const CircularProgressIndicator(
// //                       color: _C.accent,
// //                       strokeWidth: 2,
// //                     ),
// //                     SizedBox(height: 16.h),
// //                     Text(
// //                       'Processing Payment...',
// //                       style: TextStyle(
// //                         fontSize: 15.sp,
// //                         fontWeight: FontWeight.w600,
// //                         color: _C.text1,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLeadList() {
// //     if (_isLoading) return _buildLoading();
// //     if (_filteredOrders.isEmpty) return _buildEmpty();
// //     return RefreshIndicator(
// //       color: _C.accent,
// //       onRefresh: _fetchLeads,
// //       child: ListView.builder(
// //         padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
// //         itemCount: _paginated.length,
// //         itemBuilder: (_, i) => _buildLeadCard(_paginated[i]),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPagination() => Container(
// //     color: _C.white,
// //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         _pageBtn(
// //           '← Prev',
// //           _currentPage > 1,
// //           () => setState(() => _currentPage--),
// //         ),
// //         Padding(
// //           padding: EdgeInsets.symmetric(horizontal: 16.w),
// //           child: Text(
// //             '$_currentPage / $_totalPages',
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               color: _C.text2,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ),
// //         _pageBtn(
// //           'Next →',
// //           _currentPage < _totalPages,
// //           () => setState(() => _currentPage++),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   Widget _pageBtn(String label, bool enabled, VoidCallback onTap) =>
// //       GestureDetector(
// //         onTap: enabled ? onTap : null,
// //         child: Container(
// //           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
// //           decoration: BoxDecoration(
// //             color: enabled ? _C.accentLt : _C.bg,
// //             borderRadius: BorderRadius.circular(8.r),
// //             border: Border.all(color: enabled ? _C.accent : _C.border),
// //           ),
// //           child: Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 11.sp,
// //               fontWeight: FontWeight.w600,
// //               color: enabled ? _C.accent : _C.text3,
// //             ),
// //           ),
// //         ),
// //       );
// //   Widget _buildLoading() => const Center(
// //     child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
// //   );
// //   Widget _buildEmpty() => Center(
// //     child: Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Container(
// //           width: 72,
// //           height: 72,
// //           decoration: BoxDecoration(
// //             color: _C.bg,
// //             shape: BoxShape.circle,
// //             border: Border.all(color: _C.border),
// //           ),
// //           child: const Icon(
// //             Icons.leaderboard_outlined,
// //             size: 32,
// //             color: _C.text3,
// //           ),
// //         ),
// //         const SizedBox(height: 14),
// //         const Text(
// //           'No Leads Available',
// //           style: TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w700,
// //             color: _C.text1,
// //           ),
// //         ),
// //         const SizedBox(height: 4),
// //         const Text(
// //           'New leads will appear here',
// //           style: TextStyle(fontSize: 13, color: _C.text2),
// //         ),
// //       ],
// //     ),
// //   );
// // }
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../Api/APIclient.dart';
// import '../CateringModels/lead_model.dart';
// import '../caterings/quotation.dart';
//
// // ─── Design Tokens ─────────────────────────────────────────────────────────────
// class _C {
//   static const bg = Color(0xFFF7F8FC);
//   static const white = Color(0xFFFFFFFF);
//   static const border = Color(0xFFEEEFF5);
//   static const accent = Color(0xFFE66D33);
//   static const accentLt = Color(0xFFFFF0E8);
//   static const blue = Color(0xFFE66D33);
//   static const blueLt = Color(0xFFDBEAFE);
//   static const green = Color(0xFF10B981);
//   static const greenLt = Color(0xFFF7F8FC);
//   static const amber = Color(0xFFE66D33);
//   static const amberLt = Color(0xFFF7F8FC);
//   static const red = Color(0xFFEF4444);
//   static const redLt = Color(0xFFFEE2E2);
//   static const text1 = Color(0xFF111827);
//   static const text2 = Color(0xFF6B7280);
//   static const text3 = Color(0xFFB0B3C1);
//   static const shadow = Color(0x0A000000);
// }
//
// const _kGrad = LinearGradient(
//   colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// // ─── Base URL kept as a single constant so it can't drift out of sync again ────
// const String _kBaseUrl = 'http://staging.maamaas.com:8080/catering/api';
//
// class LeadManagementPage extends StatefulWidget {
//   const LeadManagementPage({super.key});
//   @override
//   State<LeadManagementPage> createState() => _LeadManagementPageState();
// }
//
// class _LeadManagementPageState extends State<LeadManagementPage> {
//   bool _isLoading = false;
//   bool _isProcessingPayment = false;
//   List<Map<String, dynamic>> _leadsOrders = [];
//   List<Map<String, dynamic>> _filteredOrders = [];
//   Map<int, String> _quotationStatuses = {};
//   Map<String, bool> _expandedLeads = {};
//   Set<int> _newOrderIds = {};
//
//   int _vendorId = 0;
//   bool _isVendorLoading = true;
//
//   String _searchQuery = '';
//   String _statusFilter = 'all';
//
//   late Razorpay _razorpay;
//   double _currentPaymentAmount = 0;
//   int _currentLeadId = 0;
//   String? _currentOrderId;
//
//   int _currentPage = 1;
//   static const int _pageSize = 10;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeRazorpay();
//     _loadVendorId();
//   }
//
//   Future<void> _loadVendorId() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       int vid = prefs.getInt('vendorId') ?? prefs.getInt('VendorId') ?? 0;
//       setState(() {
//         _vendorId = vid;
//         _isVendorLoading = false;
//       });
//       if (_vendorId != 0) _fetchLeads();
//     } catch (e) {
//       debugPrint('loadVendorId error: $e');
//       setState(() {
//         _vendorId = 0;
//         _isVendorLoading = false;
//       });
//     }
//   }
//
//   void _initializeRazorpay() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse r) {
//     // r.orderId is the SAME order id we generated in _createPaymentOrder()
//     // and handed to Razorpay.open() — Razorpay just echoes it back on success.
//     _capturePayment(paymentId: r.paymentId!, orderId: r.orderId!);
//   }
//
//   void _handlePaymentError(PaymentFailureResponse r) {
//     setState(() => _isProcessingPayment = false);
//     _snack('Payment failed: ${r.message ?? 'Unknown error'}', _C.red);
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse _) {
//     setState(() => _isProcessingPayment = false);
//   }
//
//   Future<void> _fetchLeads() async {
//     if (_vendorId == 0) return;
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = _getToken(prefs);
//       if (token == null) {
//         setState(() => _isLoading = false);
//         _snack('Authentication token not found', _C.red);
//         return;
//       }
//       final resp = await http.get(
//         Uri.parse('$_kBaseUrl/vendor/$_vendorId'),
//         headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
//       );
//       if (resp.statusCode == 200) {
//         final result = jsonDecode(resp.body) as Map<String, dynamic>;
//         if (result['success'] == true) {
//           final data = result['data'] as Map<String, dynamic>;
//           final orders = <Map<String, dynamic>>[];
//           final Set<int> paidIds = {};
//           if (data['fullLeads'] is List) {
//             for (final ld in data['fullLeads'] as List) {
//               try {
//                 final l = Lead.fromJson(ld as Map<String, dynamic>);
//                 if (l.id != null) paidIds.add(l.id!);
//                 orders.add(_buildOrder(l, isPaid: true));
//                 _expandedLeads.putIfAbsent(l.id.toString(), () => false);
//               } catch (e) {
//                 debugPrint('fullLeads parse error: $e');
//               }
//             }
//           }
//           if (data['maskedLeads'] is List) {
//             for (final ld in data['maskedLeads'] as List) {
//               try {
//                 final l = Lead.fromJson(ld as Map<String, dynamic>);
//                 final paid = paidIds.contains(l.id ?? 0);
//                 orders.add(_buildOrder(l, isPaid: paid, masked: !paid));
//                 _expandedLeads.putIfAbsent(l.id.toString(), () => false);
//               } catch (e) {
//                 debugPrint('maskedLeads parse error: $e');
//               }
//             }
//           }
//           _sortByDate(orders);
//           final curr = orders.map((o) => o['orderId'] as int).toSet();
//           final prev = _filteredOrders.map((o) => o['orderId'] as int).toSet();
//           setState(() {
//             _leadsOrders = orders;
//             _applyFilters();
//             _isLoading = false;
//             _newOrderIds = curr.difference(prev);
//           });
//           await _fetchQuotations();
//         } else {
//           setState(() => _isLoading = false);
//           _snack(
//             result['message']?.toString() ?? 'Failed to load leads',
//             _C.red,
//           );
//         }
//       } else {
//         setState(() => _isLoading = false);
//         _snack('Failed to load leads (${resp.statusCode})', _C.red);
//       }
//     } catch (e) {
//       debugPrint('fetchLeads error: $e');
//       setState(() => _isLoading = false);
//       _snack('Something went wrong while loading leads', _C.red);
//     }
//   }
//
//   Map<String, dynamic> _buildOrder(
//     Lead l, {
//     required bool isPaid,
//     bool masked = false,
//   }) {
//     final total =
//         (l.vegPlates ?? 0) + (l.nonVegPlates ?? 0) + (l.mixedPlates ?? 0);
//     var loc = [
//       l.city,
//       l.state,
//     ].where((e) => e != null && e.isNotEmpty).join(', ');
//     if (loc.isEmpty) loc = 'Location not specified';
//     return {
//       'orderId': l.id ?? 0,
//       'name': isPaid ? (l.fullName ?? 'Not specified') : '*** *** ***',
//       'mobile': isPaid ? (l.phoneNumber ?? 'Not specified') : '***-***-****',
//       'email': isPaid ? (l.email ?? 'Not specified') : '***@***.com',
//       'orderDateAndTime': l.createdAt ?? '',
//       'eventDate': l.eventDate,
//       'fromDate': l.fromDate,
//       'toDate': l.toDate,
//       'eventTime': l.eventTime,
//       'eventType': l.eventType ?? 'Event',
//       'eventName': _eventName(l.eventType ?? 'Event'),
//       'numberOfPlates': total,
//       'clientLocation': loc,
//       'leadPrice': l.leadPrice ?? 0.0,
//       'items': l.items ?? {},
//       'addOns': (l.addOns ?? [])
//           .map(
//             (a) => {
//               'addOnType': a.addOnType,
//               'quantity': a.quantity,
//               'selected': a.selected,
//             },
//           )
//           .toList(),
//       'vegPlates': l.vegPlates ?? 0,
//       'nonVegPlates': l.nonVegPlates ?? 0,
//       'mixedPlates': l.mixedPlates ?? 0,
//       'additionalRequests': l.additionalRequests ?? '',
//       'accessMessage': l.accessMessage ?? 'Payment required for full details',
//       'masked': masked,
//       'leadStatus': l.leadStatus,
//       'actualName': l.fullName,
//       'actualMobile': l.phoneNumber,
//       'actualEmail': l.email,
//       'actualCity': l.city,
//       'actualState': l.state,
//       'actualItems': l.items ?? {},
//       'actualAddOns': l.addOns,
//       'actualAdditionalRequests': l.additionalRequests,
//       'isPaid': isPaid,
//     };
//   }
//
//   String _eventName(String t) =>
//       const {
//         'DAILY': 'Daily',
//         'WEEKLY': 'Weekly',
//         'MONTHLY': 'Monthly',
//         'YEARLY': 'Yearly',
//         'CORPORATE': 'Corporate',
//         'WEDDING': 'Wedding',
//         'BIRTHDAY': 'Birthday Party',
//         'ENGAGEMENT': 'Engagement',
//         'FESTIVAL': 'Festival Celebration',
//       }[t] ??
//       t;
//   void _sortByDate(List<Map<String, dynamic>> orders) => orders.sort((a, b) {
//     final ap = a['isPaid'] as bool? ?? false;
//     final bp = b['isPaid'] as bool? ?? false;
//     if (ap != bp) return ap ? 1 : -1;
//     try {
//       return DateTime.parse(
//         b['orderDateAndTime'],
//       ).compareTo(DateTime.parse(a['orderDateAndTime']));
//     } catch (_) {
//       return 0;
//     }
//   });
//
//   void _applyFilters() {
//     setState(() {
//       _filteredOrders = _leadsOrders.where((o) {
//         if (_searchQuery.isNotEmpty) {
//           final id = o['orderId'].toString();
//           final name = o['actualName']?.toString().toLowerCase() ?? '';
//           if (!id.contains(_searchQuery) &&
//               !name.contains(_searchQuery.toLowerCase())) {
//             return false;
//           }
//         }
//         if (_statusFilter == 'paid' && !(o['isPaid'] as bool? ?? false)) {
//           return false;
//         }
//         if (_statusFilter == 'unpaid' && (o['isPaid'] as bool? ?? false)) {
//           return false;
//         }
//         return true;
//       }).toList();
//       _sortByDate(_filteredOrders);
//     });
//   }
//
//   Future<void> _fetchQuotations() async {
//     if (_vendorId == 0) return;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = _getToken(prefs);
//       if (token == null) return;
//       final resp = await http.get(
//         Uri.parse('$_kBaseUrl/vendor/quotations/$_vendorId'),
//         headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
//       );
//       if (resp.statusCode == 200) {
//         final result = jsonDecode(resp.body) as Map<String, dynamic>;
//         if (result['success'] == true) {
//           final qs = result['data'] as List? ?? [];
//           setState(() {
//             _quotationStatuses.clear();
//             for (final q in qs) {
//               final lid = q['leadId'] as int?;
//               final s = q['status'] as String?;
//               if (lid != null && s != null) _quotationStatuses[lid] = s;
//             }
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('fetchQuotations error: $e');
//     }
//   }
//
//   // ─── Payment flow ─────────────────────────────────────────────────────────
//   // 1. _handlePaymentForLead()  -> _createPaymentOrder() generates orderId,
//   //                                then Razorpay checkout opens with that orderId.
//   // 2. _handlePaymentSuccess()  -> Razorpay returns paymentId + the SAME orderId.
//   // 3. _capturePayment()        -> calls _captureOnBackend() (paymentId + orderId)
//   //                                then _initiatePayment() (paymentId + orderId).
//   // orderId is generated exactly once (in step 1) and threaded unchanged through
//   // to both /api/user/capture and /catering/api/vendor/payment/initiate.
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> _handlePaymentForLead(Map<String, dynamic> order) async {
//     final leadId = order['orderId'] as int;
//     final amount = order['leadPrice'] as double? ?? 0.0;
//     if (amount <= 0) {
//       _snack('Invalid payment amount', _C.red);
//       return;
//     }
//     setState(() {
//       _isProcessingPayment = true;
//       _currentLeadId = leadId;
//       _currentPaymentAmount = amount;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = _getToken(prefs);
//       if (token == null) {
//         setState(() => _isProcessingPayment = false);
//         _snack('Authentication token not found', _C.red);
//         return;
//       }
//       final orderResp = await _createPaymentOrder(amount: amount);
//       if (orderResp == null) {
//         setState(() => _isProcessingPayment = false);
//         _snack('Failed to create payment order', _C.red);
//         return;
//       }
//       final orderId = orderResp['orderId'];
//       if (orderId == null) {
//         setState(() => _isProcessingPayment = false);
//         throw Exception('Order ID not returned');
//       }
//       _currentOrderId = orderId;
//       _razorpay.open({
//         'key': 'rzp_live_TJDvykibQEsCuN',
//         'amount': (amount * 100).toInt(),
//         'currency': 'INR',
//         'name': 'Maamaas Catering',
//         'description': 'Lead #$leadId - View Full Details',
//         'order_id': orderId,
//         'prefill': {
//           'contact': order['actualMobile'] ?? '',
//           'email': order['actualEmail'] ?? '',
//         },
//         'notes': {
//           'leadId': leadId.toString(),
//           'vendorId': _vendorId.toString(),
//         },
//       });
//     } catch (e) {
//       setState(() => _isProcessingPayment = false);
//       _snack('Payment initiation failed: $e', _C.red);
//     }
//   }
//
//   /// Step 1: creates the Razorpay order and returns { orderId, ... }.
//   /// This is the ONLY place a fresh orderId is generated.
//   Future<Map<String, dynamic>?> _createPaymentOrder({
//     required double amount,
//   }) async {
//     try {
//       final resp = await ApiClient.post('api/user/create-order', {
//         'amount': amount,
//         'currency': 'INR',
//         'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
//         'notes': {
//           'source': 'catering_leads',
//           'leadId': _currentLeadId.toString(),
//           'vendorId': _vendorId.toString(),
//         },
//       }, service: 'subscription');
//       if (resp.statusCode == 200 || resp.statusCode == 201) {
//         return jsonDecode(resp.body);
//       }
//       debugPrint('createPaymentOrder failed: ${resp.statusCode} ${resp.body}');
//     } catch (e) {
//       debugPrint('createPaymentOrder error: $e');
//     }
//     return null;
//   }
//
//   Future<void> _capturePayment({
//     required String paymentId,
//     required String orderId,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = _getToken(prefs);
//       if (token == null) {
//         setState(() => _isProcessingPayment = false);
//         _snack('Auth token not found', _C.red);
//         return;
//       }
//       final capture = await _captureOnBackend(
//         paymentId: paymentId,
//         orderId: orderId,
//         amount: _currentPaymentAmount,
//       );
//       if (capture != null) {
//         await _initiatePayment(
//           leadId: _currentLeadId,
//           vendorId: _vendorId,
//           amount: _currentPaymentAmount,
//           orderId: orderId,
//           token: token,
//           paymentId: paymentId,
//         );
//       } else {
//         setState(() => _isProcessingPayment = false);
//         _snack('Failed to capture payment', _C.red);
//       }
//     } catch (e) {
//       debugPrint('capturePayment error: $e');
//       setState(() => _isProcessingPayment = false);
//       _snack('Payment capture failed', _C.red);
//     }
//   }
//
//   /// Step 2: confirms/captures the payment on our backend.
//   /// Now sends orderId too, so the backend can tie the payment back to the order.
//   Future<Map<String, dynamic>?> _captureOnBackend({
//     required String paymentId,
//     required String orderId,
//     required double amount,
//   }) async {
//     try {
//       final resp = await ApiClient.post('api/user/capture', {
//         'paymentId': paymentId,
//         'orderId': orderId,
//         'amount': amount,
//         'currency': 'INR',
//       }, service: 'subscription');
//       if (resp.statusCode == 200 || resp.statusCode == 201) {
//         return jsonDecode(resp.body);
//       }
//       debugPrint('captureOnBackend failed: ${resp.statusCode} ${resp.body}');
//     } catch (e) {
//       debugPrint('captureOnBackend error: $e');
//     }
//     return null;
//   }
//
//   /// Step 3: tells the catering backend to unlock the lead, passing the same
//   /// orderId through as the `orderid` query param.
//   Future<void> _initiatePayment({
//     required int leadId,
//     required int vendorId,
//     required double amount,
//     required String orderId,
//     required String token,
//     required String paymentId,
//   }) async {
//     try {
//       final resp = await http.post(
//         Uri.parse(
//           '$_kBaseUrl/vendor/payment/initiate'
//           '?leadId=$leadId&vendorId=$vendorId&amount=$amount&orderid=$orderId',
//         ),
//         headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
//       );
//       if (resp.statusCode == 200 || resp.statusCode == 201) {
//         await _handleSuccess(leadId);
//       } else {
//         setState(() => _isProcessingPayment = false);
//         _snack('Failed to update payment status', _C.red);
//       }
//     } catch (e) {
//       debugPrint('initiatePayment error: $e');
//       setState(() => _isProcessingPayment = false);
//       _snack('Payment verification failed', _C.red);
//     }
//   }
//
//   Future<void> _handleSuccess(int leadId) async {
//     setState(() {
//       _isProcessingPayment = false;
//       _updateAsPaid(leadId);
//       _expandedLeads[leadId.toString()] = true;
//       _sortByDate(_filteredOrders);
//     });
//     _snack('Payment successful! You can now view full lead details.', _C.green);
//     await _fetchLeads();
//   }
//
//   void _updateAsPaid(int leadId) {
//     for (final list in [_filteredOrders, _leadsOrders]) {
//       for (int i = 0; i < list.length; i++) {
//         if (list[i]['orderId'] == leadId) {
//           list[i]['isPaid'] = true;
//           list[i]['masked'] = false;
//           if (list[i]['actualName'] != null) {
//             list[i]['name'] = list[i]['actualName'];
//           }
//           if (list[i]['actualMobile'] != null) {
//             list[i]['mobile'] = list[i]['actualMobile'];
//           }
//           if (list[i]['actualEmail'] != null) {
//             list[i]['email'] = list[i]['actualEmail'];
//           }
//           break;
//         }
//       }
//     }
//   }
//
//   String _quotBtnText(Map<String, dynamic> order) {
//     final s = _quotationStatuses[order['orderId'] as int];
//     if (s == null) return 'Create Quotation';
//     switch (s) {
//       case 'SELECTED':
//         return 'Quotation Accepted';
//       case 'SUBMITTED':
//         return 'Quotation Submitted';
//       case 'REJECTED':
//         return 'Quotation Rejected';
//       default:
//         return 'Create Quotation';
//     }
//   }
//
//   Color _quotBtnColor(String text) {
//     switch (text) {
//       case 'Quotation Accepted':
//         return _C.green;
//       case 'Quotation Submitted':
//         return _C.amber;
//       case 'Quotation Rejected':
//         return _C.red;
//       default:
//         return _C.accent;
//     }
//   }
//
//   void _goToQuotation(Map<String, dynamic> order) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QuotationScreen(
//           order: {
//             'id': order['orderId'],
//             'leadId': order['orderId'],
//             'orderId': order['orderId'],
//             'name': order['actualName'] ?? order['name'],
//             'fullName': order['actualName'] ?? order['name'],
//             'phoneNumber': order['actualMobile'] ?? order['mobile'],
//             'email': order['actualEmail'] ?? order['email'],
//             'eventType': order['eventType'],
//             'eventDate': order['eventDate'],
//             'eventTime': order['eventTime'],
//             'fromDate': order['fromDate'],
//             'toDate': order['toDate'],
//             'vegPlates': order['vegPlates'],
//             'nonVegPlates': order['nonVegPlates'],
//             'mixedPlates': order['mixedPlates'],
//             'totalPlates': order['numberOfPlates'],
//             'items': order['actualItems'] ?? order['items'],
//             'addOns': order['actualAddOns'] ?? order['addOns'] ?? [],
//             'additionalRequests':
//                 order['actualAdditionalRequests'] ??
//                 order['additionalRequests'],
//             'fullAddress': order['clientLocation'],
//             'address': order['clientLocation'],
//             'city': order['actualCity'],
//             'state': order['actualState'],
//           },
//         ),
//       ),
//     );
//   }
//
//   String? _getToken(SharedPreferences prefs) {
//     for (final k in [
//       'authToken',
//       'token',
//       'accessToken',
//       'jwtToken',
//       'bearerToken',
//       'userToken',
//     ]) {
//       final v = prefs.get(k);
//       if (v != null) return v.toString();
//     }
//     return null;
//   }
//
//   void _snack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           msg,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   List<Map<String, dynamic>> get _paginated {
//     final s = (_currentPage - 1) * _pageSize;
//     final e = s + _pageSize;
//     if (s >= _filteredOrders.length) return [];
//     return _filteredOrders.sublist(
//       s,
//       e > _filteredOrders.length ? _filteredOrders.length : e,
//     );
//   }
//
//   int get _totalPages =>
//       _filteredOrders.isEmpty ? 1 : (_filteredOrders.length / _pageSize).ceil();
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   // ─── BUILD ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//     );
//
//     if (_isVendorLoading) {
//       return Scaffold(
//         backgroundColor: _C.bg,
//         body: const Center(
//           child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
//         ),
//       );
//     }
//     if (_vendorId == 0) {
//       return Scaffold(
//         backgroundColor: _C.bg,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline_rounded, size: 48, color: _C.red),
//               const SizedBox(height: 14),
//               const Text(
//                 'Vendor ID not found',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: _C.text1,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Please login again',
//                 style: TextStyle(fontSize: 13, color: _C.text2),
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: _loadVendorId,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 11,
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
//     if (_isProcessingPayment) return _buildPaymentOverlay();
//
//     return Scaffold(
//       backgroundColor: _C.bg,
//       // ── AppBar handles status bar — SafeArea on body NOT needed ────────────
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           _buildStatsBar(),
//           Expanded(
//             child: _isLoading
//                 ? _buildLoading()
//                 : _filteredOrders.isEmpty
//                 ? _buildEmpty()
//                 : RefreshIndicator(
//                     color: _C.accent,
//                     onRefresh: _fetchLeads,
//                     child: ListView.builder(
//                       padding: EdgeInsets.fromLTRB(
//                         16.w,
//                         10.h,
//                         16.w,
//                         24.h + MediaQuery.of(context).padding.bottom,
//                       ),
//                       itemCount: _paginated.length,
//                       itemBuilder: (_, i) => _buildLeadCard(_paginated[i]),
//                     ),
//                   ),
//           ),
//           if (_totalPages > 1) _buildPagination(),
//         ],
//       ),
//     );
//   }
//
//   // ── AppBar — white, matches app design ────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: _C.white,
//       elevation: 0,
//       leading: GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child: Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: _C.bg,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: _C.border),
//           ),
//           child: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             size: 16,
//             color: _C.text1,
//           ),
//         ),
//       ),
//       title: const Text(
//         'Lead Management',
//         style: TextStyle(
//           fontSize: 17,
//           fontWeight: FontWeight.w800,
//           color: _C.text1,
//           letterSpacing: -0.3,
//         ),
//       ),
//
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(height: 1, color: _C.border),
//       ),
//     );
//   }
//
//   // ── Search + filter bar ───────────────────────────────────────────────────────
//   Widget _buildSearchBar() {
//     return Container(
//       color: _C.white,
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 40.h,
//               decoration: BoxDecoration(
//                 color: _C.bg,
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(color: _C.border),
//               ),
//               child: TextField(
//                 style: TextStyle(fontSize: 13.sp, color: _C.text1),
//                 onChanged: (v) {
//                   _searchQuery = v;
//                   _applyFilters();
//                   _currentPage = 1;
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search by ID or name...',
//                   hintStyle: TextStyle(fontSize: 12.sp, color: _C.text3),
//                   prefixIcon: Icon(
//                     Icons.search_rounded,
//                     size: 18.sp,
//                     color: _C.text3,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(vertical: 10.h),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 10.w),
//           Container(
//             height: 40.h,
//             padding: EdgeInsets.symmetric(horizontal: 12.w),
//             decoration: BoxDecoration(
//               color: _C.accentLt,
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(color: _C.accent.withOpacity(0.3)),
//             ),
//             child: DropdownButton<String>(
//               value: _statusFilter,
//               underline: const SizedBox(),
//               icon: Icon(
//                 Icons.arrow_drop_down_rounded,
//                 color: _C.accent,
//                 size: 20.sp,
//               ),
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w600,
//                 color: _C.accent,
//               ),
//               onChanged: (v) {
//                 setState(() {
//                   _statusFilter = v!;
//                   _applyFilters();
//                   _currentPage = 1;
//                 });
//               },
//               items: const [
//                 DropdownMenuItem(value: 'all', child: Text('All Leads')),
//                 DropdownMenuItem(value: 'paid', child: Text('Paid')),
//                 DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Stats bar ─────────────────────────────────────────────────────────────────
//   Widget _buildStatsBar() {
//     final paid = _filteredOrders.where((o) => o['isPaid'] == true).length;
//     final unpaid = _filteredOrders.where((o) => o['isPaid'] != true).length;
//     return Container(
//       color: _C.white,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//       child: Row(
//         children: [
//           _statChip('Total', _filteredOrders.length.toString(), _C.accent),
//           SizedBox(width: 12.w),
//           _statChip('Paid', paid.toString(), _C.green),
//           SizedBox(width: 12.w),
//           _statChip('Unpaid', unpaid.toString(), _C.amber),
//         ],
//       ),
//     );
//   }
//
//   Widget _statChip(String label, String value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(fontSize: 11.sp, color: _C.text2),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Lead card ─────────────────────────────────────────────────────────────────
//   Widget _buildLeadCard(Map<String, dynamic> order) {
//     final orderId = order['orderId'].toString();
//     final isPaid = order['isPaid'] as bool? ?? false;
//     final isExpanded = _expandedLeads[orderId] ?? false;
//     final isNew = _newOrderIds.contains(order['orderId'] as int);
//     final quotText = _quotBtnText(order);
//     final quotColor = _quotBtnColor(quotText);
//     final canQuot = quotText == 'Create Quotation';
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: isNew ? _C.accent.withOpacity(0.4) : _C.border,
//           width: isNew ? 1.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isNew ? _C.accent.withOpacity(0.08) : _C.shadow,
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: EdgeInsets.all(14.r),
//             decoration: BoxDecoration(
//               color: isPaid ? _C.greenLt : _C.amberLt,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 8.r,
//                   height: 8.r,
//                   decoration: BoxDecoration(
//                     color: isPaid ? _C.green : _C.amber,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Lead #${order['orderId']}',
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w800,
//                           color: _C.text1,
//                         ),
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         order['eventName'] as String? ?? 'Event',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w600,
//                           color: isPaid ? _C.green : _C.amber,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       _fmtDate(
//                         (order['eventDate'] ?? order['fromDate']) as String?,
//                       ),
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         fontWeight: FontWeight.w600,
//                         color: _C.text1,
//                       ),
//                     ),
//                     if (order['eventTime'] != null)
//                       Text(
//                         _fmtTime(order['eventTime'] as String?),
//                         style: TextStyle(fontSize: 10.sp, color: _C.text2),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Plates + location
//           Padding(
//             padding: EdgeInsets.all(14.r),
//             child: Row(
//               children: [
//                 _plateChip('Total', '${order['numberOfPlates']}', _C.accent),
//                 SizedBox(width: 8.w),
//                 _plateChip('Veg', '${order['vegPlates'] ?? 0}', _C.green),
//                 SizedBox(width: 8.w),
//                 _plateChip('Non-Veg', '${order['nonVegPlates'] ?? 0}', _C.red),
//                 const Spacer(),
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_rounded,
//                         size: 12.sp,
//                         color: _C.text3,
//                       ),
//                       SizedBox(width: 4.w),
//                       Expanded(
//                         child: Text(
//                           order['clientLocation'] as String? ?? '',
//                           style: TextStyle(fontSize: 10.sp, color: _C.text2),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Divider(color: _C.border, height: 1),
//
//           // Unpaid: pay button
//           if (!isPaid)
//             Padding(
//               padding: EdgeInsets.all(14.r),
//               child: GestureDetector(
//                 onTap: _isProcessingPayment
//                     ? null
//                     : () => _handlePaymentForLead(order),
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(vertical: 13.h),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [_C.amber, Color(0xFFD97706)],
//                     ),
//                     borderRadius: BorderRadius.circular(12.r),
//                     boxShadow: [
//                       BoxShadow(
//                         color: _C.amber.withOpacity(0.35),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child:
//                       (_isProcessingPayment &&
//                           _currentLeadId == order['orderId'])
//                       ? Center(
//                           child: SizedBox(
//                             width: 18.r,
//                             height: 18.r,
//                             child: const CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           ),
//                         )
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.lock_open_rounded,
//                               color: Colors.white,
//                               size: 16.sp,
//                             ),
//                             SizedBox(width: 8.w),
//                             Text(
//                               'Pay ₹${(order['leadPrice'] as double? ?? 0.0).toStringAsFixed(0)} to Unlock',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//             )
//           else ...[
//             // Paid: contact info
//             Padding(
//               padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
//               child: Container(
//                 padding: EdgeInsets.all(12.r),
//                 decoration: BoxDecoration(
//                   color: _C.greenLt,
//                   borderRadius: BorderRadius.circular(10.r),
//                   border: Border.all(color: _C.green.withOpacity(0.2)),
//                 ),
//                 child: Column(
//                   children: [
//                     _infoRow(
//                       Icons.person_rounded,
//                       order['actualName'] as String? ?? 'Not specified',
//                       _C.green,
//                     ),
//                     SizedBox(height: 6.h),
//                     _infoRow(
//                       Icons.phone_rounded,
//                       order['actualMobile'] as String? ?? 'Not specified',
//                       _C.green,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // Expand toggle
//             GestureDetector(
//               onTap: () =>
//                   setState(() => _expandedLeads[orderId] = !isExpanded),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       isExpanded ? 'Hide Details' : 'View Full Details',
//                       style: TextStyle(
//                         color: _C.accent,
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(width: 4.w),
//                     Icon(
//                       isExpanded
//                           ? Icons.keyboard_arrow_up_rounded
//                           : Icons.keyboard_arrow_down_rounded,
//                       color: _C.accent,
//                       size: 18.sp,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // Expanded details
//             if (isExpanded)
//               Padding(
//                 padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Divider(color: _C.border, height: 1),
//                     SizedBox(height: 12.h),
//                     _sectionLabel('Contact Details'),
//                     _detailsCard([
//                       _detailRow(
//                         'Name',
//                         order['actualName'] as String? ?? 'Not specified',
//                       ),
//                       _detailRow(
//                         'Phone',
//                         order['actualMobile'] as String? ?? 'Not specified',
//                       ),
//                       _detailRow(
//                         'Email',
//                         order['actualEmail'] as String? ?? 'Not specified',
//                       ),
//                       _detailRow(
//                         'Location',
//                         order['clientLocation'] as String? ?? 'Not specified',
//                       ),
//                     ]),
//                     SizedBox(height: 12.h),
//                     if (order['addOns'] != null &&
//                         (order['addOns'] as List).isNotEmpty) ...[
//                       _sectionLabel('Add-Ons'),
//                       _addOnsCard(order['addOns'] as List),
//                       SizedBox(height: 12.h),
//                     ],
//                     if (order['items'] is Map &&
//                         (order['items'] as Map).isNotEmpty) ...[
//                       _sectionLabel('Menu Items'),
//                       _menuItemsCard(order['items'] as Map<String, dynamic>),
//                       SizedBox(height: 12.h),
//                     ],
//                     if ((order['additionalRequests'] as String?)?.isNotEmpty ==
//                         true) ...[
//                       _sectionLabel('Additional Requests'),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(12.r),
//                         decoration: BoxDecoration(
//                           color: _C.bg,
//                           borderRadius: BorderRadius.circular(10.r),
//                           border: Border.all(color: _C.border),
//                         ),
//                         child: Text(
//                           order['additionalRequests'].toString(),
//                           style: TextStyle(fontSize: 13.sp, color: _C.text2),
//                         ),
//                       ),
//                       SizedBox(height: 12.h),
//                     ],
//                     GestureDetector(
//                       onTap: canQuot ? () => _goToQuotation(order) : null,
//                       child: Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(vertical: 13.h),
//                         decoration: BoxDecoration(
//                           color: canQuot
//                               ? quotColor
//                               : quotColor.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(12.r),
//                           border: Border.all(color: quotColor.withOpacity(0.3)),
//                         ),
//                         child: Center(
//                           child: Text(
//                             quotText,
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w700,
//                               color: canQuot ? Colors.white : quotColor,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _plateChip(String label, String value, Color color) => Container(
//     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//     decoration: BoxDecoration(
//       color: color.withOpacity(0.1),
//       borderRadius: BorderRadius.circular(8.r),
//       border: Border.all(color: color.withOpacity(0.2)),
//     ),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w800,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 9.sp,
//             color: color,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
//   Widget _infoRow(IconData icon, String text, Color color) => Row(
//     children: [
//       Icon(icon, size: 14.sp, color: color),
//       SizedBox(width: 8.w),
//       Expanded(
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w600,
//             color: _C.text1,
//           ),
//         ),
//       ),
//     ],
//   );
//   Widget _sectionLabel(String l) => Padding(
//     padding: EdgeInsets.only(bottom: 8.h),
//     child: Text(
//       l,
//       style: TextStyle(
//         fontSize: 13.sp,
//         fontWeight: FontWeight.w700,
//         color: _C.text1,
//       ),
//     ),
//   );
//   Widget _detailsCard(List<Widget> rows) => Container(
//     padding: EdgeInsets.all(12.r),
//     decoration: BoxDecoration(
//       color: _C.bg,
//       borderRadius: BorderRadius.circular(10.r),
//       border: Border.all(color: _C.border),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: rows.expand((w) => [w, SizedBox(height: 6.h)]).toList()
//         ..removeLast(),
//     ),
//   );
//   Widget _detailRow(String label, String value) => Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       SizedBox(
//         width: 70.w,
//         child: Text(
//           '$label:',
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: _C.text2,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//       Expanded(
//         child: Text(
//           value,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: _C.text1,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     ],
//   );
//   Widget _addOnsCard(List addOns) {
//     const names = {
//       'SERVICE_BOYS': 'Service Boys',
//       'PAPER_PLATES': 'Paper Plates',
//       'WATER_BOTTLES': 'Water Bottles',
//       'DISPOSABLE_CUPS': 'Disposable Cups',
//       'TISSUE_PAPER': 'Tissue Paper',
//     };
//     final sel = addOns
//         .where((a) => a is Map && (a['selected'] as bool? ?? false))
//         .toList();
//     if (sel.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: EdgeInsets.all(12.r),
//       decoration: BoxDecoration(
//         color: _C.bg,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: _C.border),
//       ),
//       child: Column(
//         children: sel.map<Widget>((a) {
//           final type = (a as Map)['addOnType'] as String? ?? '';
//           final qty = a['quantity'] as int? ?? 0;
//           return Padding(
//             padding: EdgeInsets.symmetric(vertical: 3.h),
//             child: Row(
//               children: [
//                 Container(
//                   width: 5.r,
//                   height: 5.r,
//                   decoration: const BoxDecoration(
//                     color: _C.accent,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   '${names[type] ?? type.replaceAll('_', ' ')} × $qty',
//                   style: TextStyle(fontSize: 12.sp, color: _C.text2),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _menuItemsCard(Map<String, dynamic> items) => Container(
//     padding: EdgeInsets.all(12.r),
//     decoration: BoxDecoration(
//       color: _C.bg,
//       borderRadius: BorderRadius.circular(10.r),
//       border: Border.all(color: _C.border),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: items.entries.expand((e) {
//         if (e.value is! List || (e.value as List).isEmpty) return <Widget>[];
//         return [
//           Text(
//             e.key,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w700,
//               color: _C.accent,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           ...(e.value as List).map(
//             (i) => Padding(
//               padding: EdgeInsets.only(left: 8.w, bottom: 3.h),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 4.r,
//                     height: 4.r,
//                     decoration: const BoxDecoration(
//                       color: _C.text3,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   SizedBox(width: 6.w),
//                   Text(
//                     i.toString(),
//                     style: TextStyle(fontSize: 11.sp, color: _C.text2),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 8.h),
//         ];
//       }).toList(),
//     ),
//   );
//
//   String _fmtDate(String? s) {
//     if (s == null || s.isEmpty) return 'Not specified';
//     try {
//       return DateFormat('dd-MMM-yyyy').format(DateTime.parse(s));
//     } catch (_) {
//       return s;
//     }
//   }
//
//   String _fmtTime(String? s) {
//     if (s == null || s.isEmpty) return 'Not specified';
//     try {
//       return DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(s));
//     } catch (_) {
//       try {
//         return DateFormat('h:mm a').format(DateFormat('HH:mm').parse(s));
//       } catch (_) {
//         return s;
//       }
//     }
//   }
//
//   Widget _buildPaymentOverlay() {
//     return Scaffold(
//       backgroundColor: _C.bg,
//       appBar: _buildAppBar(),
//       body: Stack(
//         children: [
//           _buildLeadList(),
//           Container(
//             color: Colors.black.withOpacity(0.35),
//             child: Center(
//               child: Container(
//                 padding: EdgeInsets.all(24.r),
//                 decoration: BoxDecoration(
//                   color: _C.white,
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const CircularProgressIndicator(
//                       color: _C.accent,
//                       strokeWidth: 2,
//                     ),
//                     SizedBox(height: 16.h),
//                     Text(
//                       'Processing Payment...',
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w600,
//                         color: _C.text1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLeadList() {
//     if (_isLoading) return _buildLoading();
//     if (_filteredOrders.isEmpty) return _buildEmpty();
//     return RefreshIndicator(
//       color: _C.accent,
//       onRefresh: _fetchLeads,
//       child: ListView.builder(
//         padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
//         itemCount: _paginated.length,
//         itemBuilder: (_, i) => _buildLeadCard(_paginated[i]),
//       ),
//     );
//   }
//
//   Widget _buildPagination() => Container(
//     color: _C.white,
//     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _pageBtn(
//           '← Prev',
//           _currentPage > 1,
//           () => setState(() => _currentPage--),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: Text(
//             '$_currentPage / $_totalPages',
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: _C.text2,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         _pageBtn(
//           'Next →',
//           _currentPage < _totalPages,
//           () => setState(() => _currentPage++),
//         ),
//       ],
//     ),
//   );
//
//   Widget _pageBtn(String label, bool enabled, VoidCallback onTap) =>
//       GestureDetector(
//         onTap: enabled ? onTap : null,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//           decoration: BoxDecoration(
//             color: enabled ? _C.accentLt : _C.bg,
//             borderRadius: BorderRadius.circular(8.r),
//             border: Border.all(color: enabled ? _C.accent : _C.border),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 11.sp,
//               fontWeight: FontWeight.w600,
//               color: enabled ? _C.accent : _C.text3,
//             ),
//           ),
//         ),
//       );
//   Widget _buildLoading() => const Center(
//     child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
//   );
//   Widget _buildEmpty() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 72,
//           height: 72,
//           decoration: BoxDecoration(
//             color: _C.bg,
//             shape: BoxShape.circle,
//             border: Border.all(color: _C.border),
//           ),
//           child: const Icon(
//             Icons.leaderboard_outlined,
//             size: 32,
//             color: _C.text3,
//           ),
//         ),
//         const SizedBox(height: 14),
//         const Text(
//           'No Leads Available',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//             color: _C.text1,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'New leads will appear here',
//           style: TextStyle(fontSize: 13, color: _C.text2),
//         ),
//       ],
//     ),
//   );
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Api/APIclient.dart';
import '../CateringModels/lead_model.dart';
import '../caterings/quotation.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentLt = Color(0xFFFFF0E8);
  static const blue = Color(0xFFE66D33);
  static const blueLt = Color(0xFFDBEAFE);
  static const green = Color(0xFF10B981);
  static const greenLt = Color(0xFFF7F8FC);
  static const amber = Color(0xFFE66D33);
  static const amberLt = Color(0xFFF7F8FC);
  static const red = Color(0xFFEF4444);
  static const redLt = Color(0xFFFEE2E2);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
}

const _kGrad = LinearGradient(
  colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Base URL kept as a single constant so it can't drift out of sync again ────
const String _kBaseUrl = 'http://staging.maamaas.com:8080/catering/api';

class LeadManagementPage extends StatefulWidget {
  const LeadManagementPage({super.key});
  @override
  State<LeadManagementPage> createState() => _LeadManagementPageState();
}

class _LeadManagementPageState extends State<LeadManagementPage> {
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  List<Map<String, dynamic>> _leadsOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  Map<int, String> _quotationStatuses = {};
  Map<String, bool> _expandedLeads = {};
  Set<int> _newOrderIds = {};

  int _vendorId = 0;
  bool _isVendorLoading = true;

  String _searchQuery = '';
  String _statusFilter = 'all';

  late Razorpay _razorpay;
  double _currentPaymentAmount = 0;
  int _currentLeadId = 0;
  String? _currentOrderId;
  // ── NEW: track the receipt generated at order-creation time so it can be
  // reused, unchanged, when we call the capture API (the capture API expects
  // `receipt`, not `orderId`). ──────────────────────────────────────────────
  String? _currentReceipt;

  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _loadVendorId();
  }

  Future<void> _loadVendorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int vid = prefs.getInt('vendorId') ?? prefs.getInt('VendorId') ?? 0;
      setState(() {
        _vendorId = vid;
        _isVendorLoading = false;
      });
      if (_vendorId != 0) _fetchLeads();
    } catch (e) {
      debugPrint('loadVendorId error: $e');
      setState(() {
        _vendorId = 0;
        _isVendorLoading = false;
      });
    }
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse r) {
    // r.orderId is the SAME order id we generated in _createPaymentOrder()
    // and handed to Razorpay.open() — Razorpay just echoes it back on success.
    _capturePayment(paymentId: r.paymentId!, orderId: r.orderId!);
  }

  void _handlePaymentError(PaymentFailureResponse r) {
    setState(() => _isProcessingPayment = false);
    _snack('Payment failed: ${r.message ?? 'Unknown error'}', _C.red);
  }

  void _handleExternalWallet(ExternalWalletResponse _) {
    setState(() => _isProcessingPayment = false);
  }

  Future<void> _fetchLeads() async {
    if (_vendorId == 0) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = _getToken(prefs);
      if (token == null) {
        setState(() => _isLoading = false);
        _snack('Authentication token not found', _C.red);
        return;
      }
      final resp = await http.get(
        Uri.parse('$_kBaseUrl/vendor/$_vendorId'),
        headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final result = jsonDecode(resp.body) as Map<String, dynamic>;
        if (result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>;
          final orders = <Map<String, dynamic>>[];
          final Set<int> paidIds = {};
          if (data['fullLeads'] is List) {
            for (final ld in data['fullLeads'] as List) {
              try {
                final l = Lead.fromJson(ld as Map<String, dynamic>);
                if (l.id != null) paidIds.add(l.id!);
                orders.add(_buildOrder(l, isPaid: true));
                _expandedLeads.putIfAbsent(l.id.toString(), () => false);
              } catch (e) {
                debugPrint('fullLeads parse error: $e');
              }
            }
          }
          if (data['maskedLeads'] is List) {
            for (final ld in data['maskedLeads'] as List) {
              try {
                final l = Lead.fromJson(ld as Map<String, dynamic>);
                final paid = paidIds.contains(l.id ?? 0);
                orders.add(_buildOrder(l, isPaid: paid, masked: !paid));
                _expandedLeads.putIfAbsent(l.id.toString(), () => false);
              } catch (e) {
                debugPrint('maskedLeads parse error: $e');
              }
            }
          }
          _sortByDate(orders);
          final curr = orders.map((o) => o['orderId'] as int).toSet();
          final prev = _filteredOrders.map((o) => o['orderId'] as int).toSet();
          setState(() {
            _leadsOrders = orders;
            _applyFilters();
            _isLoading = false;
            _newOrderIds = curr.difference(prev);
          });
          await _fetchQuotations();
        } else {
          setState(() => _isLoading = false);
          _snack(
            result['message']?.toString() ?? 'Failed to load leads',
            _C.red,
          );
        }
      } else {
        setState(() => _isLoading = false);
        _snack('Failed to load leads (${resp.statusCode})', _C.red);
      }
    } catch (e) {
      debugPrint('fetchLeads error: $e');
      setState(() => _isLoading = false);
      _snack('Something went wrong while loading leads', _C.red);
    }
  }

  Map<String, dynamic> _buildOrder(
    Lead l, {
    required bool isPaid,
    bool masked = false,
  }) {
    final total =
        (l.vegPlates ?? 0) + (l.nonVegPlates ?? 0) + (l.mixedPlates ?? 0);
    var loc = [
      l.city,
      l.state,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    if (loc.isEmpty) loc = 'Location not specified';
    return {
      'orderId': l.id ?? 0,
      'name': isPaid ? (l.fullName ?? 'Not specified') : '*** *** ***',
      'mobile': isPaid ? (l.phoneNumber ?? 'Not specified') : '***-***-****',
      'email': isPaid ? (l.email ?? 'Not specified') : '***@***.com',
      'orderDateAndTime': l.createdAt ?? '',
      'eventDate': l.eventDate,
      'fromDate': l.fromDate,
      'toDate': l.toDate,
      'eventTime': l.eventTime,
      'eventType': l.eventType ?? 'Event',
      'eventName': _eventName(l.eventType ?? 'Event'),
      'numberOfPlates': total,
      'clientLocation': loc,
      'leadPrice': l.leadPrice ?? 0.0,
      'items': l.items ?? {},
      'addOns': (l.addOns ?? [])
          .map(
            (a) => {
              'addOnType': a.addOnType,
              'quantity': a.quantity,
              'selected': a.selected,
            },
          )
          .toList(),
      'vegPlates': l.vegPlates ?? 0,
      'nonVegPlates': l.nonVegPlates ?? 0,
      'mixedPlates': l.mixedPlates ?? 0,
      'additionalRequests': l.additionalRequests ?? '',
      'accessMessage': l.accessMessage ?? 'Payment required for full details',
      'masked': masked,
      'leadStatus': l.leadStatus,
      'actualName': l.fullName,
      'actualMobile': l.phoneNumber,
      'actualEmail': l.email,
      'actualCity': l.city,
      'actualState': l.state,
      'actualItems': l.items ?? {},
      'actualAddOns': l.addOns,
      'actualAdditionalRequests': l.additionalRequests,
      'isPaid': isPaid,
    };
  }

  String _eventName(String t) =>
      const {
        'DAILY': 'Daily',
        'WEEKLY': 'Weekly',
        'MONTHLY': 'Monthly',
        'YEARLY': 'Yearly',
        'CORPORATE': 'Corporate',
        'WEDDING': 'Wedding',
        'BIRTHDAY': 'Birthday Party',
        'ENGAGEMENT': 'Engagement',
        'FESTIVAL': 'Festival Celebration',
      }[t] ??
      t;
  void _sortByDate(List<Map<String, dynamic>> orders) => orders.sort((a, b) {
    final ap = a['isPaid'] as bool? ?? false;
    final bp = b['isPaid'] as bool? ?? false;
    if (ap != bp) return ap ? 1 : -1;
    try {
      return DateTime.parse(
        b['orderDateAndTime'],
      ).compareTo(DateTime.parse(a['orderDateAndTime']));
    } catch (_) {
      return 0;
    }
  });

  void _applyFilters() {
    setState(() {
      _filteredOrders = _leadsOrders.where((o) {
        if (_searchQuery.isNotEmpty) {
          final id = o['orderId'].toString();
          final name = o['actualName']?.toString().toLowerCase() ?? '';
          if (!id.contains(_searchQuery) &&
              !name.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }
        if (_statusFilter == 'paid' && !(o['isPaid'] as bool? ?? false)) {
          return false;
        }
        if (_statusFilter == 'unpaid' && (o['isPaid'] as bool? ?? false)) {
          return false;
        }
        return true;
      }).toList();
      _sortByDate(_filteredOrders);
    });
  }

  Future<void> _fetchQuotations() async {
    if (_vendorId == 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = _getToken(prefs);
      if (token == null) return;
      final resp = await http.get(
        Uri.parse('$_kBaseUrl/vendor/quotations/$_vendorId'),
        headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final result = jsonDecode(resp.body) as Map<String, dynamic>;
        if (result['success'] == true) {
          final qs = result['data'] as List? ?? [];
          setState(() {
            _quotationStatuses.clear();
            for (final q in qs) {
              final lid = q['leadId'] as int?;
              final s = q['status'] as String?;
              if (lid != null && s != null) _quotationStatuses[lid] = s;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('fetchQuotations error: $e');
    }
  }

  // ─── Payment flow ─────────────────────────────────────────────────────────
  // 1. _handlePaymentForLead()  -> _createPaymentOrder() generates orderId
  //                                AND a receipt string, then Razorpay
  //                                checkout opens with that orderId.
  // 2. _handlePaymentSuccess()  -> Razorpay returns paymentId + the SAME
  //                                orderId.
  // 3. _capturePayment()        -> calls _captureOnBackend() with
  //                                (paymentId + receipt + amount + currency)
  //                                — this matches the capture API's actual
  //                                contract — then _initiatePayment() with
  //                                (paymentId + orderId) for the catering
  //                                backend, which is a separate endpoint that
  //                                still expects `orderid`.
  // orderId is generated exactly once (in step 1) and threaded unchanged
  // through to /catering/api/vendor/payment/initiate.
  // receipt is generated exactly once (in step 1) and threaded unchanged
  // through to /subscription/api/user/capture.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handlePaymentForLead(Map<String, dynamic> order) async {
    final leadId = order['orderId'] as int;
    final amount = order['leadPrice'] as double? ?? 0.0;
    if (amount <= 0) {
      _snack('Invalid payment amount', _C.red);
      return;
    }
    setState(() {
      _isProcessingPayment = true;
      _currentLeadId = leadId;
      _currentPaymentAmount = amount;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = _getToken(prefs);
      if (token == null) {
        setState(() => _isProcessingPayment = false);
        _snack('Authentication token not found', _C.red);
        return;
      }
      final orderResp = await _createPaymentOrder(amount: amount);
      if (orderResp == null) {
        setState(() => _isProcessingPayment = false);
        _snack('Failed to create payment order', _C.red);
        return;
      }
      final orderId = orderResp['orderId'];
      if (orderId == null) {
        setState(() => _isProcessingPayment = false);
        throw Exception('Order ID not returned');
      }
      _currentOrderId = orderId;
      _razorpay.open({
        'key': 'rzp_live_TJDvykibQEsCuN',
        'amount': (amount * 100).toInt(),
        'currency': 'INR',
        'name': 'Maamaas Catering',
        'description': 'Lead #$leadId - View Full Details',
        'order_id': orderId,
        'prefill': {
          'contact': order['actualMobile'] ?? '',
          'email': order['actualEmail'] ?? '',
        },
        'notes': {
          'leadId': leadId.toString(),
          'vendorId': _vendorId.toString(),
        },
      });
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      _snack('Payment initiation failed: $e', _C.red);
    }
  }

  /// Step 1: creates the Razorpay order and returns { orderId, ... }.
  /// This is the ONLY place a fresh orderId AND receipt are generated.
  Future<Map<String, dynamic>?> _createPaymentOrder({
    required double amount,
  }) async {
    try {
      // Generate the receipt once here and hold onto it — the capture API
      // needs this exact same value later, it does NOT take orderId.
      final receipt = 'receipt_${DateTime.now().millisecondsSinceEpoch}';
      _currentReceipt = receipt;

      final resp = await ApiClient.post('api/user/create-order', {
        'amount': amount,
        'currency': 'INR',
        'receipt': receipt,
        'notes': {
          'source': 'catering_leads',
          'leadId': _currentLeadId.toString(),
          'vendorId': _vendorId.toString(),
        },
      }, service: 'subscription');
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return jsonDecode(resp.body);
      }
      debugPrint('createPaymentOrder failed: ${resp.statusCode} ${resp.body}');
    } catch (e) {
      debugPrint('createPaymentOrder error: $e');
    }
    return null;
  }

  Future<void> _capturePayment({
    required String paymentId,
    required String orderId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = _getToken(prefs);
      if (token == null) {
        setState(() => _isProcessingPayment = false);
        _snack('Auth token not found', _C.red);
        return;
      }
      final capture = await _captureOnBackend(
        paymentId: paymentId,
        amount: _currentPaymentAmount,
      );
      if (capture != null) {
        await _initiatePayment(
          leadId: _currentLeadId,
          vendorId: _vendorId,
          amount: _currentPaymentAmount,
          orderId: orderId,
          token: token,
          paymentId: paymentId,
        );
      } else {
        setState(() => _isProcessingPayment = false);
        _snack('Failed to capture payment', _C.red);
      }
    } catch (e) {
      debugPrint('capturePayment error: $e');
      setState(() => _isProcessingPayment = false);
      _snack('Payment capture failed', _C.red);
    }
  }

  Future<Map<String, dynamic>?> _captureOnBackend({
    required String paymentId,
    required double amount,
  }) async {
    try {
      final resp = await ApiClient.post('api/user/capture', {
        'paymentId': paymentId,
        'amount': amount,
        'currency': 'INR',
        'receipt': _currentReceipt ?? '',
      }, service: 'subscription');
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final decoded = jsonDecode(resp.body);
        // Some backends return 200 with a success:false payload rather than
        // a non-2xx status code — guard against silently treating that as OK.
        if (decoded is Map<String, dynamic> &&
            decoded.containsKey('success') &&
            decoded['success'] != true) {
          debugPrint('captureOnBackend rejected: ${resp.body}');
          return null;
        }
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      }
      debugPrint('captureOnBackend failed: ${resp.statusCode} ${resp.body}');
    } catch (e) {
      debugPrint('captureOnBackend error: $e');
    }
    return null;
  }

  /// Step 3: tells the catering backend to unlock the lead, passing the same
  /// orderId through as the `orderid` query param. This is a separate
  /// endpoint from capture and still uses orderId, not receipt.
  Future<void> _initiatePayment({
    required int leadId,
    required int vendorId,
    required double amount,
    required String orderId,
    required String token,
    required String paymentId,
  }) async {
    try {
      // Uri.replace() URL-encodes query params correctly (handles orderId's
      // underscores/special chars) instead of hand-built string interpolation.
      // Amount is sent with no trailing ".0" in case the backend expects an
      // integer-looking value (adjust here if the backend actually wants the
      // literal double string).
      final amountStr = amount == amount.roundToDouble()
          ? amount.toInt().toString()
          : amount.toString();
      final uri = Uri.parse('$_kBaseUrl/vendor/payment/initiate').replace(
        queryParameters: {
          'leadId': leadId.toString(),
          'vendorId': vendorId.toString(),
          'amount': amountStr,
          'orderid': orderId,
        },
      );
      final resp = await http.post(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );
      debugPrint('initiatePayment -> ${resp.statusCode}: ${resp.body}');
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await _handleSuccess(leadId);
      } else {
        setState(() => _isProcessingPayment = false);
        // Surface the backend's actual error message when available instead
        // of a generic string, so real failures (bad orderid, amount
        // mismatch, expired token, etc.) are visible instead of hidden.
        String detail = 'Failed to update payment status';
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map && decoded['message'] != null) {
            detail = decoded['message'].toString();
          }
        } catch (_) {
          // response wasn't JSON — fall back to the generic message
        }
        _snack(detail, _C.red);
      }
    } catch (e) {
      debugPrint('initiatePayment error: $e');
      setState(() => _isProcessingPayment = false);
      _snack('Payment verification failed', _C.red);
    }
  }

  Future<void> _handleSuccess(int leadId) async {
    setState(() {
      _isProcessingPayment = false;
      _updateAsPaid(leadId);
      _expandedLeads[leadId.toString()] = true;
      _sortByDate(_filteredOrders);
    });
    _snack('Payment successful! You can now view full lead details.', _C.green);
    await _fetchLeads();
  }

  void _updateAsPaid(int leadId) {
    for (final list in [_filteredOrders, _leadsOrders]) {
      for (int i = 0; i < list.length; i++) {
        if (list[i]['orderId'] == leadId) {
          list[i]['isPaid'] = true;
          list[i]['masked'] = false;
          if (list[i]['actualName'] != null) {
            list[i]['name'] = list[i]['actualName'];
          }
          if (list[i]['actualMobile'] != null) {
            list[i]['mobile'] = list[i]['actualMobile'];
          }
          if (list[i]['actualEmail'] != null) {
            list[i]['email'] = list[i]['actualEmail'];
          }
          break;
        }
      }
    }
  }

  String _quotBtnText(Map<String, dynamic> order) {
    final s = _quotationStatuses[order['orderId'] as int];
    if (s == null) return 'Create Quotation';
    switch (s) {
      case 'SELECTED':
        return 'Quotation Accepted';
      case 'SUBMITTED':
        return 'Quotation Submitted';
      case 'REJECTED':
        return 'Quotation Rejected';
      default:
        return 'Create Quotation';
    }
  }

  Color _quotBtnColor(String text) {
    switch (text) {
      case 'Quotation Accepted':
        return _C.green;
      case 'Quotation Submitted':
        return _C.amber;
      case 'Quotation Rejected':
        return _C.red;
      default:
        return _C.accent;
    }
  }

  void _goToQuotation(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationScreen(
          order: {
            'id': order['orderId'],
            'leadId': order['orderId'],
            'orderId': order['orderId'],
            'name': order['actualName'] ?? order['name'],
            'fullName': order['actualName'] ?? order['name'],
            'phoneNumber': order['actualMobile'] ?? order['mobile'],
            'email': order['actualEmail'] ?? order['email'],
            'eventType': order['eventType'],
            'eventDate': order['eventDate'],
            'eventTime': order['eventTime'],
            'fromDate': order['fromDate'],
            'toDate': order['toDate'],
            'vegPlates': order['vegPlates'],
            'nonVegPlates': order['nonVegPlates'],
            'mixedPlates': order['mixedPlates'],
            'totalPlates': order['numberOfPlates'],
            'items': order['actualItems'] ?? order['items'],
            'addOns': order['actualAddOns'] ?? order['addOns'] ?? [],
            'additionalRequests':
                order['actualAdditionalRequests'] ??
                order['additionalRequests'],
            'fullAddress': order['clientLocation'],
            'address': order['clientLocation'],
            'city': order['actualCity'],
            'state': order['actualState'],
          },
        ),
      ),
    );
  }

  String? _getToken(SharedPreferences prefs) {
    for (final k in [
      'authToken',
      'token',
      'accessToken',
      'jwtToken',
      'bearerToken',
      'userToken',
    ]) {
      final v = prefs.get(k);
      if (v != null) return v.toString();
    }
    return null;
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Map<String, dynamic>> get _paginated {
    final s = (_currentPage - 1) * _pageSize;
    final e = s + _pageSize;
    if (s >= _filteredOrders.length) return [];
    return _filteredOrders.sublist(
      s,
      e > _filteredOrders.length ? _filteredOrders.length : e,
    );
  }

  int get _totalPages =>
      _filteredOrders.isEmpty ? 1 : (_filteredOrders.length / _pageSize).ceil();

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    if (_isVendorLoading) {
      return Scaffold(
        backgroundColor: _C.bg,
        body: const Center(
          child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
        ),
      );
    }
    if (_vendorId == 0) {
      return Scaffold(
        backgroundColor: _C.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: _C.red),
              const SizedBox(height: 14),
              const Text(
                'Vendor ID not found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.text1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please login again',
                style: TextStyle(fontSize: 13, color: _C.text2),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _loadVendorId,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    gradient: _kGrad,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isProcessingPayment) return _buildPaymentOverlay();

    return Scaffold(
      backgroundColor: _C.bg,
      // ── AppBar handles status bar — SafeArea on body NOT needed ────────────
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsBar(),
          Expanded(
            child: _isLoading
                ? _buildLoading()
                : _filteredOrders.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: _C.accent,
                    onRefresh: _fetchLeads,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        10.h,
                        16.w,
                        24.h + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: _paginated.length,
                      itemBuilder: (_, i) => _buildLeadCard(_paginated[i]),
                    ),
                  ),
          ),
          if (_totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  // ── AppBar — white, matches app design ────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _C.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.border),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: _C.text1,
          ),
        ),
      ),
      title: const Text(
        'Lead Management',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _C.text1,
          letterSpacing: -0.3,
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.border),
      ),
    );
  }

  // ── Search + filter bar ───────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _C.white,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _C.border),
              ),
              child: TextField(
                style: TextStyle(fontSize: 13.sp, color: _C.text1),
                onChanged: (v) {
                  _searchQuery = v;
                  _applyFilters();
                  _currentPage = 1;
                },
                decoration: InputDecoration(
                  hintText: 'Search by ID or name...',
                  hintStyle: TextStyle(fontSize: 12.sp, color: _C.text3),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18.sp,
                    color: _C.text3,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: _C.accentLt,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _C.accent.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: _statusFilter,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: _C.accent,
                size: 20.sp,
              ),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _C.accent,
              ),
              onChanged: (v) {
                setState(() {
                  _statusFilter = v!;
                  _applyFilters();
                  _currentPage = 1;
                });
              },
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Leads')),
                DropdownMenuItem(value: 'paid', child: Text('Paid')),
                DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    final paid = _filteredOrders.where((o) => o['isPaid'] == true).length;
    final unpaid = _filteredOrders.where((o) => o['isPaid'] != true).length;
    return Container(
      color: _C.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _statChip('Total', _filteredOrders.length.toString(), _C.accent),
          SizedBox(width: 12.w),
          _statChip('Paid', paid.toString(), _C.green),
          SizedBox(width: 12.w),
          _statChip('Unpaid', unpaid.toString(), _C.amber),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11.sp, color: _C.text2),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Lead card ─────────────────────────────────────────────────────────────────
  Widget _buildLeadCard(Map<String, dynamic> order) {
    final orderId = order['orderId'].toString();
    final isPaid = order['isPaid'] as bool? ?? false;
    final isExpanded = _expandedLeads[orderId] ?? false;
    final isNew = _newOrderIds.contains(order['orderId'] as int);
    final quotText = _quotBtnText(order);
    final quotColor = _quotBtnColor(quotText);
    final canQuot = quotText == 'Create Quotation';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isNew ? _C.accent.withOpacity(0.4) : _C.border,
          width: isNew ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isNew ? _C.accent.withOpacity(0.08) : _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isPaid ? _C.greenLt : _C.amberLt,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: isPaid ? _C.green : _C.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lead #${order['orderId']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: _C.text1,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        order['eventName'] as String? ?? 'Event',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? _C.green : _C.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmtDate(
                        (order['eventDate'] ?? order['fromDate']) as String?,
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.text1,
                      ),
                    ),
                    if (order['eventTime'] != null)
                      Text(
                        _fmtTime(order['eventTime'] as String?),
                        style: TextStyle(fontSize: 10.sp, color: _C.text2),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Plates + location
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                _plateChip('Total', '${order['numberOfPlates']}', _C.accent),
                SizedBox(width: 8.w),
                _plateChip('Veg', '${order['vegPlates'] ?? 0}', _C.green),
                SizedBox(width: 8.w),
                _plateChip('Non-Veg', '${order['nonVegPlates'] ?? 0}', _C.red),
                const Spacer(),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 12.sp,
                        color: _C.text3,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          order['clientLocation'] as String? ?? '',
                          style: TextStyle(fontSize: 10.sp, color: _C.text2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(color: _C.border, height: 1),

          // Unpaid: pay button
          if (!isPaid)
            Padding(
              padding: EdgeInsets.all(14.r),
              child: GestureDetector(
                onTap: _isProcessingPayment
                    ? null
                    : () => _handlePaymentForLead(order),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.amber, Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: _C.amber.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      (_isProcessingPayment &&
                          _currentLeadId == order['orderId'])
                      ? Center(
                          child: SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_open_rounded,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Pay ₹${(order['leadPrice'] as double? ?? 0.0).toStringAsFixed(0)} to Unlock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            )
          else ...[
            // Paid: contact info
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: _C.greenLt,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _C.green.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      Icons.person_rounded,
                      order['actualName'] as String? ?? 'Not specified',
                      _C.green,
                    ),
                    SizedBox(height: 6.h),
                    _infoRow(
                      Icons.phone_rounded,
                      order['actualMobile'] as String? ?? 'Not specified',
                      _C.green,
                    ),
                  ],
                ),
              ),
            ),
            // Expand toggle
            GestureDetector(
              onTap: () =>
                  setState(() => _expandedLeads[orderId] = !isExpanded),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded ? 'Hide Details' : 'View Full Details',
                      style: TextStyle(
                        color: _C.accent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _C.accent,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ),
            // Expanded details
            if (isExpanded)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: _C.border, height: 1),
                    SizedBox(height: 12.h),
                    _sectionLabel('Contact Details'),
                    _detailsCard([
                      _detailRow(
                        'Name',
                        order['actualName'] as String? ?? 'Not specified',
                      ),
                      _detailRow(
                        'Phone',
                        order['actualMobile'] as String? ?? 'Not specified',
                      ),
                      _detailRow(
                        'Email',
                        order['actualEmail'] as String? ?? 'Not specified',
                      ),
                      _detailRow(
                        'Location',
                        order['clientLocation'] as String? ?? 'Not specified',
                      ),
                    ]),
                    SizedBox(height: 12.h),
                    if (order['addOns'] != null &&
                        (order['addOns'] as List).isNotEmpty) ...[
                      _sectionLabel('Add-Ons'),
                      _addOnsCard(order['addOns'] as List),
                      SizedBox(height: 12.h),
                    ],
                    if (order['items'] is Map &&
                        (order['items'] as Map).isNotEmpty) ...[
                      _sectionLabel('Menu Items'),
                      _menuItemsCard(order['items'] as Map<String, dynamic>),
                      SizedBox(height: 12.h),
                    ],
                    if ((order['additionalRequests'] as String?)?.isNotEmpty ==
                        true) ...[
                      _sectionLabel('Additional Requests'),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: _C.bg,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: _C.border),
                        ),
                        child: Text(
                          order['additionalRequests'].toString(),
                          style: TextStyle(fontSize: 13.sp, color: _C.text2),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    GestureDetector(
                      onTap: canQuot ? () => _goToQuotation(order) : null,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: canQuot
                              ? quotColor
                              : quotColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: quotColor.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            quotText,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: canQuot ? Colors.white : quotColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _plateChip(String label, String value, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
  Widget _infoRow(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 14.sp, color: color),
      SizedBox(width: 8.w),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _C.text1,
          ),
        ),
      ),
    ],
  );
  Widget _sectionLabel(String l) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(
      l,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: _C.text1,
      ),
    ),
  );
  Widget _detailsCard(List<Widget> rows) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: _C.bg,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: _C.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.expand((w) => [w, SizedBox(height: 6.h)]).toList()
        ..removeLast(),
    ),
  );
  Widget _detailRow(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 70.w,
        child: Text(
          '$label:',
          style: TextStyle(
            fontSize: 12.sp,
            color: _C.text2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: _C.text1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
  Widget _addOnsCard(List addOns) {
    const names = {
      'SERVICE_BOYS': 'Service Boys',
      'PAPER_PLATES': 'Paper Plates',
      'WATER_BOTTLES': 'Water Bottles',
      'DISPOSABLE_CUPS': 'Disposable Cups',
      'TISSUE_PAPER': 'Tissue Paper',
    };
    final sel = addOns
        .where((a) => a is Map && (a['selected'] as bool? ?? false))
        .toList();
    if (sel.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: sel.map<Widget>((a) {
          final type = (a as Map)['addOnType'] as String? ?? '';
          final qty = a['quantity'] as int? ?? 0;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 3.h),
            child: Row(
              children: [
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: const BoxDecoration(
                    color: _C.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${names[type] ?? type.replaceAll('_', ' ')} × $qty',
                  style: TextStyle(fontSize: 12.sp, color: _C.text2),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _menuItemsCard(Map<String, dynamic> items) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: _C.bg,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: _C.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.entries.expand((e) {
        if (e.value is! List || (e.value as List).isEmpty) return <Widget>[];
        return [
          Text(
            e.key,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: _C.accent,
            ),
          ),
          SizedBox(height: 4.h),
          ...(e.value as List).map(
            (i) => Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 3.h),
              child: Row(
                children: [
                  Container(
                    width: 4.r,
                    height: 4.r,
                    decoration: const BoxDecoration(
                      color: _C.text3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    i.toString(),
                    style: TextStyle(fontSize: 11.sp, color: _C.text2),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ];
      }).toList(),
    ),
  );

  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return 'Not specified';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtTime(String? s) {
    if (s == null || s.isEmpty) return 'Not specified';
    try {
      return DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(s));
    } catch (_) {
      try {
        return DateFormat('h:mm a').format(DateFormat('HH:mm').parse(s));
      } catch (_) {
        return s;
      }
    }
  }

  Widget _buildPaymentOverlay() {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildLeadList(),
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: _C.accent,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Processing Payment...',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.text1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadList() {
    if (_isLoading) return _buildLoading();
    if (_filteredOrders.isEmpty) return _buildEmpty();
    return RefreshIndicator(
      color: _C.accent,
      onRefresh: _fetchLeads,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
        itemCount: _paginated.length,
        itemBuilder: (_, i) => _buildLeadCard(_paginated[i]),
      ),
    );
  }

  Widget _buildPagination() => Container(
    color: _C.white,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageBtn(
          '← Prev',
          _currentPage > 1,
          () => setState(() => _currentPage--),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '$_currentPage / $_totalPages',
            style: TextStyle(
              fontSize: 12.sp,
              color: _C.text2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _pageBtn(
          'Next →',
          _currentPage < _totalPages,
          () => setState(() => _currentPage++),
        ),
      ],
    ),
  );

  Widget _pageBtn(String label, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: enabled ? _C.accentLt : _C.bg,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: enabled ? _C.accent : _C.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: enabled ? _C.accent : _C.text3,
            ),
          ),
        ),
      );
  Widget _buildLoading() => const Center(
    child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
  );
  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _C.bg,
            shape: BoxShape.circle,
            border: Border.all(color: _C.border),
          ),
          child: const Icon(
            Icons.leaderboard_outlined,
            size: 32,
            color: _C.text3,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'No Leads Available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.text1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'New leads will appear here',
          style: TextStyle(fontSize: 13, color: _C.text2),
        ),
      ],
    ),
  );
}
