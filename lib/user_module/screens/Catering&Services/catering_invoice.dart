import 'dart:convert';
import 'dart:convert' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/catering_authservice.dart';
import '../../API/food_authservice.dart';
import 'package:pdf/widgets.dart' as pw;

import '../newscreens/restaurentsnew.dart';

class catering_invoice extends StatefulWidget {
  final int orderId;
  const catering_invoice({super.key, required this.orderId});
  @override
  _catering_invoiceState createState() => _catering_invoiceState();
}

class _catering_invoiceState extends State<catering_invoice> {
  late final int orderId;
  String? transactionIdFromPrefs;
  String chargeLabel = "Service Charge";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    orderId = widget.orderId;
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Restaurentsnew(scrollController: _scrollController)),
        );
      }
    });
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      transactionIdFromPrefs = prefs.getString('razorpay_transaction_id');
      chargeLabel = prefs.getString('chargeLabel') ?? "Service Charge";
    });
  }

  // Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
  //   final pdf = pw.Document();
  //   final List<dynamic> items = data['orderItems'] as List<dynamic>? ?? [];
  //   print("🧾 UI received ${items.length} items");
  //   final imageBytes = await rootBundle.load('assets/maamaaslogo.jpeg');
  //   final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
  //   final prefs = await SharedPreferences.getInstance();
  //   final transactionIdFromPrefs = prefs.getString('transactionId');
  //   final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  //   final ttf = pw.Font.ttf(fontData);
  //
  //
  //   final dateTime = DateTime.tryParse(data['dateTime'] ?? '');
  //   final formattedDate = dateTime != null
  //       ? '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}'
  //       : 'N/A';
  //   final formattedTime = dateTime != null
  //       ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
  //       : 'N/A';
  //
  //   pdf.addPage(
  //     pw.MultiPage(
  //       theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
  //       pageFormat: PdfPageFormat.a4,
  //       margin: const pw.EdgeInsets.all(32),
  //       build: (context) => [
  //         // Header
  //         pw.Header(
  //           level: 0,
  //           child: pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Container(width: 70, height: 70, child: pw.Image(image)),
  //               pw.Text(
  //                 'Invoice/Bill',
  //                 style: pw.TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: pw.FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         pw.SizedBox(height: 1 * PdfPageFormat.cm),
  //
  //         pw.Row(
  //           crossAxisAlignment: pw.CrossAxisAlignment.end,
  //           children: [
  //             pw.Spacer(),
  //             pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.end,
  //               children: [
  //                 pw.Text('Order ID: ${data['orderId'] ?? 'N/A'}'),
  //                 pw.Text('Date: $formattedDate'),
  //                 pw.Text('Time: $formattedTime'),
  //                 pw.Text(
  //                   'Payment Method: ${data['paymentMethod']?.toString().replaceAll('_', ' ') ?? 'N/A'}',
  //                 ),
  //                 pw.Text('cateringDate: ${data['cateringDate'] ?? 'N/A'}'),
  //                 pw.Text('cateringTime: ${data['cateringTime'] ?? 'N/A'}'),
  //                 if (data['paymentMethod']?.toString().toLowerCase() ==
  //                     "online_payment")
  //                   pw.Text(
  //                     'Transaction ID: ${data['transactionId'] ?? transactionIdFromPrefs ?? 'N/A'}',
  //                   ),
  //               ],
  //             ),
  //           ],
  //         ),
  //
  //         if ((data['location'] ?? '').toString().isNotEmpty)
  //           pw.Padding(
  //             padding: pw.EdgeInsets.only(top: 5),
  //             child: pw.Text('Location: ${data['location']}'),
  //           ),
  //
  //         pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
  //
  //         pw.Text(
  //           'Ordered Items:',
  //           style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  //         ),
  //         pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
  //         pw.TableHelper.fromTextArray(
  //           headerStyle: pw.TextStyle(
  //             fontWeight: pw.FontWeight.bold,
  //             fontSize: 10,
  //           ),
  //           cellStyle: const pw.TextStyle(fontSize: 9),
  //           headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
  //           cellAlignment: pw.Alignment.centerLeft,
  //           cellAlignments: {
  //             0: pw.Alignment.center,
  //             2: pw.Alignment.center,
  //             3: pw.Alignment.centerRight,
  //             4: pw.Alignment.centerRight,
  //           },
  //           columnWidths: {
  //             0: const pw.FixedColumnWidth(30),
  //             1: const pw.FlexColumnWidth(3),
  //             2: const pw.FixedColumnWidth(40),
  //             3: const pw.FlexColumnWidth(1.5),
  //             4: const pw.FlexColumnWidth(1.5),
  //           },
  //           headers: ['S.No', 'Item', 'Qty', 'Items', 'Price'],
  //           data: List.generate(items.length, (index) {
  //             final item = items[index];
  //             return [
  //               (index + 1).toString(),
  //               item['packageName'] ?? 'N/A',
  //               (item['quantity'] ?? 0).toString(),
  //               "₹${(item['packageItems'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
  //               "₹${(item['packagePrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
  //             ];
  //           }),
  //         ),
  //
  //         pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
  //
  //         // Billing Summary
  //         pw.Align(
  //           alignment: pw.Alignment.centerRight,
  //           child: pw.SizedBox(
  //             width: 200,
  //             child: pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 pw.Text(
  //                   'Billing Summary:',
  //                   style: pw.TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: pw.FontWeight.bold,
  //                   ),
  //                 ),
  //                 pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
  //                 _buildPdfPriceRow(
  //                   'Sub Total:',
  //                   "₹${(data['subtotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
  //                   style: pw.TextStyle(
  //                     fontWeight: pw.FontWeight.bold,
  //                     fontSize: 11,
  //                   ),
  //                 ),
  //                 if ((data['discountAmount'] as num?) != null &&
  //                     (data['discountAmount'] as num) > 0)
  //                   _buildPdfPriceRow(
  //                     'Discount:',
  //                     "- ₹${(data['discountAmount'] as num?)?.toStringAsFixed(2) ?? '0.0'}",
  //                   ),
  //                 _buildPdfPriceRow(
  //                   'SGST:',
  //                   "₹${(data['sgst'] as num?)?.toStringAsFixed(2) ?? '0.0'}",
  //                 ),
  //                 _buildPdfPriceRow(
  //                   'CGST:',
  //                   "₹${(data['cgst'] as num?)?.toStringAsFixed(2) ?? '0.0'}",
  //                 ),
  //
  //                 _buildPdfPriceRow(
  //                   'Platform Charges:',
  //                   "₹${(data['platformFeeAmount'] as num?)?.toStringAsFixed(2) ?? '0.0'}",
  //                 ),
  //                 pw.Divider(color: PdfColors.grey600, height: 10),
  //                 _buildPdfPriceRow(
  //                   'Grand Total:',
  //                   "₹${(data['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
  //                   style: pw.TextStyle(
  //                     fontWeight: pw.FontWeight.bold,
  //                     fontSize: 11,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //
  //         pw.SizedBox(height: 1.5 * PdfPageFormat.cm),
  //         pw.Center(
  //           child: pw.Text(
  //             'Thank you for your order! Visit Again!',
  //             style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   return pdf.save();
  // }

  // static pw.Widget _buildPdfPriceRow(
  //   String label,
  //   String value, {
  //   pw.TextStyle? style,
  // }) {
  //   return pw.Padding(
  //     padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
  //     child: pw.Row(
  //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //       children: [
  //         pw.Text(label, style: style ?? const pw.TextStyle(fontSize: 10)),
  //         pw.Text(value, style: style ?? const pw.TextStyle(fontSize: 10)),
  //       ],
  //     ),
  //   );
  // }

  Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final imageBytes = await rootBundle.load('assets/maamaaslogo.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
    final List<dynamic> items = data['orderItems'] as List<dynamic>? ?? [];

    final dateTimeString = data['orderDateTime'] ?? '';
    DateTime? parsedDateTime;
    try {
      parsedDateTime = DateTime.parse(dateTimeString);
    } catch (_) {}

    final formattedDate = parsedDateTime != null
        ? DateFormat('yyyy-MM-dd').format(parsedDateTime)
        : 'N/A';
    final formattedTime = parsedDateTime != null
        ? DateFormat('hh:mm a').format(parsedDateTime)
        : 'N/A';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(width: 70, height: 70, child: pw.Image(image)),
                pw.Text(
                  'Invoice / Bill',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),

          // ORDER INFO
          pw.Text("Order ID: ${data['orderId'] ?? 'N/A'}"),
          pw.Text("Date: $formattedDate"),
          pw.Text("Time: $formattedTime"),
          pw.Text("Payment Method: ${data['paymentMethod'] ?? 'N/A'}"),
          if (data['transactionId'] != null)
            pw.Text("Transaction ID: ${data['transactionId']}"),
          pw.SizedBox(height: 10),

          if (data['cateringDate'] != null)
            pw.Text("Catering Date: ${data['cateringDate']}"),
          if (data['cateringTime'] != null)
            pw.Text("Catering Time: ${data['cateringTime']}"),
          if (data['location'] != null)
            pw.Text("Location: ${data['location']}"),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),

          // ORDERED ITEMS
          pw.Text(
            "Ordered Items",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          // ITEMS TABLE
          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            border: null,
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
            cellStyle: pw.TextStyle(fontSize: 10),
            headers: ["S.No", "Package (Items)", "Qty", "Total"],
            data: List.generate(items.length, (index) {
              final item = items[index] as Map<String, dynamic>;
              final List<dynamic> packageItems =
                  (item['packageItems'] is String)
                  ? (pw.JsonDecoder().convert(item['packageItems']) as List)
                  : (item['packageItems'] ?? []);

              final itemNames = packageItems.isNotEmpty
                  ? packageItems
                        .map((e) => "• ${e['itemName'] ?? ''}")
                        .join('\n')
                  : '—';

              final double packagePrice =
                  (item['packagePrice'] as num?)?.toDouble() ?? 0.0;
              final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              final double total = packagePrice * quantity;

              return [
                "${index + 1}",
                "${item['packageName'] ?? 'N/A'}\n$itemNames",
                "$quantity",
                "₹${total.toStringAsFixed(2)}",
              ];
            }),
          ),

          pw.SizedBox(height: 15),
          pw.Divider(thickness: 1),

          // BILLING DETAILS
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _pdfInfoRow(
                  "Subtotal:",
                  "₹${(data['subtotal'] ?? 0).toStringAsFixed(2)}",
                ),
                if ((data['discountAmount'] ?? 0) > 0)
                  _pdfInfoRow(
                    "Discount:",
                    "- ₹${(data['discountAmount']).toStringAsFixed(2)}",
                  ),
                _pdfInfoRow(
                  "Platform Charges:",
                  "₹${(data['platformFeeAmount'] ?? 0).toStringAsFixed(2)}",
                ),
                _pdfInfoRow(
                  "SGST:",
                  "₹${(data['sgst'] ?? 0).toStringAsFixed(2)}",
                ),
                _pdfInfoRow(
                  "CGST:",
                  "₹${(data['cgst'] ?? 0).toStringAsFixed(2)}",
                ),
                pw.Divider(thickness: 0.8),
                _pdfInfoRow(
                  "Grand Total:",
                  "₹${(data['total'] ?? 0).toStringAsFixed(2)}",
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfInfoRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Navigate to home and clear previous stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Restaurentsnew(scrollController: _scrollController)),
          (route) => false,
        );
        return false; // prevent normal back
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface, // Use theme background
          appBar: AppBar(title: Center(child: Text("Invoice"))),
          body: Stack(
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: catering_authservice().fetchOrderById(widget.orderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error fetching invoice: ${snapshot.error}",
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                      child: Text("No invoice details found."),
                    );
                  }

                  final data = snapshot.data!;
                  final List<dynamic> items =
                      data['orderItems'] as List<dynamic>? ?? [];
                  print("🧾 UI received ${items.length} items");

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 16.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInvoiceContentCard(context, theme, data, items),
                        SizedBox(height: 24.h),
                        _buildActionButtons(context, theme, data),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          // bottomNavigationBar: food_foooter(
          //   onFilterTap: () => _openFilterBottomSheet(),
          // ),
        ),
      ),
    );
  }

  Widget _buildInvoiceContentCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
    List<dynamic> items,
  ) {
    final cardBackgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]
        // : Color(0xFF6A1B9A);
        : Color(0xFFB15DC6);
    final onCardColor = Colors.white;
    final dateTimeString = data['orderDateTime'] ?? '';
    DateTime? parsedDateTime;

    try {
      parsedDateTime = DateTime.parse(dateTimeString);
    } catch (e) {
      parsedDateTime = null;
    }

    final formattedDate = parsedDateTime != null
        ? "${parsedDateTime.year}-${parsedDateTime.month.toString().padLeft(2, '0')}-${parsedDateTime.day.toString().padLeft(2, '0')}"
        : 'N/A';

    final formattedTime = parsedDateTime != null
        ? "${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}"
        : 'N/A';

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: cardBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Order Summary",
                style: TextStyle(
                  color: onCardColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _buildInfoRow(
              context,
              "Order ID:",
              "${data['orderId'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Date:",
              formattedDate,
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Time:",
              formattedTime,
              onCardColor: onCardColor,
            ),

            _buildInfoRow(
              context,
              "Payment:",
              (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
              onCardColor: onCardColor,
            ),
            if (data['paymentMethod']?.toString() == "Online_Payment")
              _buildInfoRow(
                context,
                "Transaction ID:",
                data['transactionId'] ?? transactionIdFromPrefs ?? "N/A",
                onCardColor: onCardColor,
              ),
            _buildInfoRow(
              context,
              "Date:",
              "${data['cateringDate'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Time:",
              "${data['cateringTime'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            if (data['location'] != null &&
                (data['location'] as String).isNotEmpty)
              _buildInfoRow(
                context,
                "Location:",
                "${data['location']}",
                onCardColor: onCardColor,
              ),

            Divider(
              // ignore: deprecated_member_use
              color: onCardColor.withOpacity(0.4),
              thickness: 0.8,
              height: 25.h,
            ),
            Text(
              "Ordered Items",
              style: TextStyle(
                color: onCardColor,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            _buildItemsTable(context, items, onCardColor),

            SizedBox(height: 15.h),
            _buildPriceDetails(context, data, onCardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    required Color onCardColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                // ignore: deprecated_member_use
                color: onCardColor.withOpacity(0.85),
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: onCardColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(
    BuildContext context,
    List<dynamic> items,
    Color onCardColor,
  ) {
    final headerStyle = TextStyle(
      // ignore: deprecated_member_use
      color: onCardColor.withOpacity(0.95),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    final cellStyle = TextStyle(color: onCardColor, fontSize: 11);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
      ),
      child: Table(
        border: TableBorder.symmetric(
          // ignore: deprecated_member_use
          inside: BorderSide(color: onCardColor.withOpacity(0.1)),
        ),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(3),
          2: IntrinsicColumnWidth(),
          3: IntrinsicColumnWidth(),
        },
        children: [
          // 🏷️ Header Row
          TableRow(
            // ignore: deprecated_member_use
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15)),
            children: [
              _tableCell("S.No", headerStyle, align: TextAlign.center),
              _tableCell("Package (Items)", headerStyle),
              _tableCell("Qty", headerStyle, align: TextAlign.center),
              _tableCell("Total", headerStyle, align: TextAlign.right),
            ],
          ),

          // 📦 Data Rows
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value as Map<String, dynamic>;

            // Extract nested package items safely
            final List<dynamic> packageItems = (data['packageItems'] is String)
                ? (jsonDecode(data['packageItems']) as List)
                : (data['packageItems'] ?? []);

            // Build bullet points for item names
            final String itemNames = packageItems.isNotEmpty
                ? packageItems.map((e) => "• ${e['itemName'] ?? ''}").join('\n')
                : '—';

            // Calculate total for this package
            final double packagePrice =
                (data['packagePrice'] as num?)?.toDouble() ?? 0.0;
            final int quantity = (data['quantity'] as num?)?.toInt() ?? 0;
            final double total = packagePrice * quantity;

            return TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    // ignore: deprecated_member_use
                    color: onCardColor.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
              ),
              children: [
                _tableCell(
                  "${index + 1}",
                  cellStyle,
                  align: TextAlign.center,
                  padding: 8,
                ),
                _tableCell(
                  "${data['packageName'] ?? 'N/A'}\n$itemNames",
                  cellStyle.copyWith(height: 1.4),
                  padding: 8,
                ),
                _tableCell(
                  quantity.toString(),
                  cellStyle,
                  align: TextAlign.center,
                  padding: 8,
                ),
                _tableCell(
                  "₹${total.toStringAsFixed(2)}",
                  cellStyle,
                  align: TextAlign.right,
                  padding: 8,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableCell(
    String text,
    TextStyle style, {
    TextAlign align = TextAlign.left,
    double padding = 6,
  }) {
    return Padding(
      padding: EdgeInsets.all(padding.w),
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _buildPriceDetails(
    BuildContext context,
    Map<String, dynamic> data,
    Color onCardColor,
  ) {
    final num subTotal = data['subtotal'] ?? 0;
    final num discount = data['discountAmount'] ?? 0;
    final num sgst = data['sgst'] ?? 0;
    final num cgst = data['cgst'] ?? 0;
    final num platformCharges = data['platformFeeAmount'] ?? 0;
    final num grandTotal = data['total'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 5.h),
        _buildInfoRow(
          context,
          "Sub Total:",
          "₹${subTotal.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
        if (discount > 0)
          _buildInfoRow(
            context,
            "Discount:",
            "- ₹${discount.toStringAsFixed(2)}",
            onCardColor: Colors.greenAccent,
          ),

        _buildInfoRow(
          context,
          "Platform charges",
          "₹${platformCharges.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),

        _buildInfoRow(
          context,
          "SGST:",
          "₹${sgst.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
        _buildInfoRow(
          context,
          "CGST:",
          "₹${cgst.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
        Divider(
          // ignore: deprecated_member_use
          color: onCardColor.withOpacity(0.4),
          thickness: 0.8,
          height: 20.h,
        ),
        _buildInfoRow(
          context,
          "Grand Total:",
          "₹${grandTotal.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.print_outlined,
                size: 18.sp,
                color: theme.colorScheme.onPrimary,
              ),
              label: Text(
                "Print",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                final orderData = await food_Authservice.fetchOrderById(
                  widget.orderId,
                );
                if (orderData != null) {
                  final pdfFileBytes = await generateOrderPdf(orderData);
                  await Printing.layoutPdf(
                    onLayout: (format) => Future.value(pdfFileBytes),
                  );
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Could not fetch order details for printing.",
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.download_outlined,
                size: 18.sp,
                color: theme.colorScheme.onSecondaryContainer,
              ), // Example using secondary container
              label: Text(
                "Download",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                final orderData = await food_Authservice.fetchOrderById(
                  widget.orderId,
                );
                if (orderData != null) {
                  try {
                    final pdfData = await generateOrderPdf(orderData);
                    await Printing.sharePdf(
                      bytes: pdfData,
                      filename:
                          'Invoice_${orderData['orderId'] ?? 'details'}.pdf',
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error generating PDF: $e")),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Could not fetch order details for download.",
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme
                    .colorScheme
                    .secondaryContainer, // Example using secondary container
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
