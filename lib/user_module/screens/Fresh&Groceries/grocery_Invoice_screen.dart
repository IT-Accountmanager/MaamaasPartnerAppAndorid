import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/food_authservice.dart';
import 'package:pdf/widgets.dart' as pw;

import '../professional_user/Main_screen.dart';

class grocery_Invoice extends StatefulWidget {
  final int orderId;
  const grocery_Invoice({super.key, required this.orderId});
  @override
  _grocery_InvoiceState createState() => _grocery_InvoiceState();
}

class _grocery_InvoiceState extends State<grocery_Invoice> {
  late final int orderId;
  String? transactionIdFromPrefs;
  String chargeLabel = "Service Charge";

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    orderId = widget.orderId;
    // Future.delayed(const Duration(seconds: 10), () {
    //   if (mounted) {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => Restaurents()),
    //     );
    //   }
    // });
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      transactionIdFromPrefs = prefs.getString('razorpay_transaction_id');
      chargeLabel = prefs.getString('chargeLabel') ?? "Service Charge";
    });
  }

  Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final List<dynamic> items = data['order'] as List<dynamic>? ?? [];

    final imageBytes = await rootBundle.load('assets/maamaaslogo.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
    final prefs = await SharedPreferences.getInstance();
    final transactionIdFromPrefs = prefs.getString('transactionId');

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final orderType = (data['orderType']?.toString().toLowerCase() ?? '');

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
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
          pw.SizedBox(height: 1 * PdfPageFormat.cm),

          // Order Info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Order ID: ${data['orderId'] ?? 'N/A'}'),
                  pw.Text('User Name: ${data['userName'] ?? 'N/A'}'),
                  pw.Text('Date: ${data['date'] ?? 'N/A'}'),
                  pw.Text('Time: ${data['time'] ?? 'N/A'}'),
                  pw.Text(
                    'Order Type: ${data['orderType']?.toString().replaceAll('_', ' ') ?? 'N/A'}',
                  ),
                  pw.Text(
                    'Payment Method: ${data['paymentMethod']?.toString().replaceAll('_', ' ') ?? 'N/A'}',
                  ),
                  if (data['paymentMethod']?.toString().toLowerCase() ==
                      "online_payment")
                    pw.Text(
                      'Transaction ID: ${data['transactionId'] ?? transactionIdFromPrefs ?? 'N/A'}',
                    ),
                  if (data['paymentMethod']?.toString().toLowerCase() ==
                      "maamaas_wallet")
                    pw.Text('walletType: ${data['walletTypes'] ?? 'N/A'}'),
                ],
              ),
            ],
          ),

          if ((data['location'] ?? '').toString().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Text('Location: ${data['location']}'),
            ),

          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),

          // Ordered Items Table
          pw.Text(
            'Ordered Items:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FixedColumnWidth(40),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            headers: ['S.No', 'Item', 'Qty', 'Price', 'Total'],
            data: List.generate(items.length, (index) {
              final item = items[index];
              return [
                (index + 1).toString(),
                item['dishName'] ?? 'N/A',
                (item['quantity'] ?? 0).toString(),
                "₹${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                "₹${(item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
              ];
            }),
          ),

          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),

          // Billing Summary Section
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Billing Summary:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 0.3 * PdfPageFormat.cm),

                  _buildPdfPriceRow(
                    'Sub Total:',
                    "₹${(data['subTotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    isBold: true,
                  ),
                  _buildPdfPriceRow(
                    'SGST:',
                    "₹${(data['sgst'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                  ),
                  _buildPdfPriceRow(
                    'CGST:',
                    "₹${(data['cgst'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                  ),

                  if ((data['discountAmount'] as num?) != null &&
                      (data['discountAmount'] as num) > 0)
                    _buildPdfPriceRow(
                      'Discount:',
                      "- ₹${(data['discountAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                  _buildPdfPriceRow(
                    'Service Charge:',
                    "₹${(data['serviceCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                  ),
                  // 👇 Conditional charges based on order type
                  if (orderType == 'dine-in' || orderType == 'dinein')
                    _buildPdfPriceRow(
                      'Service Charge:',
                      "₹${(data['serviceCharge'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    )
                  else if (orderType == 'takeaway' ||
                      orderType == 'take away' ||
                      orderType == 'pickup') ...[
                    _buildPdfPriceRow(
                      'Packing Charges:',
                      "₹${(data['packingCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                    _buildPdfPriceRow(
                      'Platform Charges:',
                      "₹${(data['platformCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                  ] else if (orderType == 'delivery') ...[
                    _buildPdfPriceRow(
                      'Packing Charges:',
                      "₹${(data['packingCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                    _buildPdfPriceRow(
                      'Platform Charges:',
                      "₹${(data['platformCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                    _buildPdfPriceRow(
                      'Delivery Charge:',
                      "₹${(data['deliveryCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                  ],

                  pw.Divider(color: PdfColors.grey600, height: 10),

                  _buildPdfPriceRow(
                    'Grand Total:',
                    "₹${(data['grandTotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 1.5 * PdfPageFormat.cm),
          pw.Center(
            child: pw.Text(
              'Thank you for your order! Visit Again!',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'Visit Again!',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfPriceRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
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
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
        return false; // prevent normal back
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface, // Use theme background
          // appBar: customappBar(
          //   searchController: _searchController,
          //   onCameraTap: _openCamera,
          //   onMicTap: _startRecording,
          //   // onProfileTap: () => ProfileDrawer.open(context), // ✅ reusable
          // ),
          body: Stack(
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: food_Authservice.fetchOrderById(widget.orderId),
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
                      data['order'] as List<dynamic>? ?? [];

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
              "${data['date'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Time:",
              "${data['time'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Order Type:",
              (data['orderType'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
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
            if (data['paymentMethod']?.toString().toLowerCase() ==
                "maamaas_wallet")
              _buildInfoRow(
                context,
                "walletType:",
                data['walletTypes'] ?? "N/A",
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
      color: onCardColor.withOpacity(0.9),
      fontSize: 11.sp,
      fontWeight: FontWeight.bold,
    );
    final cellStyle = TextStyle(color: onCardColor, fontSize: 11.sp);

    return Table(
      columnWidths: {
        0: IntrinsicColumnWidth(flex: 0.5), // S.No
        1: FlexColumnWidth(3), // Item Name
        2: IntrinsicColumnWidth(flex: 1), // Qty
        3: FlexColumnWidth(1.5), // Price
        4: FlexColumnWidth(1.5), // Total
      },
      children: [
        TableRow(
          // ignore: deprecated_member_use
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                "S.No",
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text("Item", style: headerStyle),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                "Qty",
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                "Price",
                style: headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                "Total",
                style: headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          return TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  // ignore: deprecated_member_use
                  color: onCardColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ), // Horizontal lines
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                  "${index + 1}",
                  style: cellStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                  item['dishName']?.toString() ?? 'N/A',
                  style: cellStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                  (item['quantity'] ?? 0).toString(),
                  style: cellStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                  "₹${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                  style: cellStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                  "₹${(item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                  style: cellStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPriceDetails(
    BuildContext context,
    Map<String, dynamic> data,
    Color onCardColor,
  ) {
    final orderType = data['orderType']?.toString().toLowerCase() ?? '';
    final num subTotal = data['subTotal'] ?? 0;
    final num discount = data['discountAmount'] ?? 0;
    final num sgst = data['sgst'] ?? 0;
    final num cgst = data['cgst'] ?? 0;
    final num platformCharges = data['platformCharges'] ?? 0;
    final num packingCharges = data['packingCharges'] ?? 0;
    final num serviceCharges = data['serviceCharge'] ?? 0;
    final num deliveryCharges = data['deliveryCharges'] ?? 0;
    final num grandTotal = data['totalAmount'] ?? 0;

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

        if (discount > 0)
          _buildInfoRow(
            context,
            "Discount:",
            "-₹${discount.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),

        // 👇 Conditional Charges based on orderType
        if (orderType == 'dine_in') ...[
          _buildInfoRow(
            context,
            "Service Charges:",
            "₹${serviceCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
        ] else if (orderType == 'takeaway' ||
            orderType == 'take_away' ||
            orderType == 'pickup') ...[
          _buildInfoRow(
            context,
            "Packing Charges:",
            "₹${packingCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
          _buildInfoRow(
            context,
            "Platform Charges:",
            "₹${platformCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
        ] else if (orderType == 'delivery') ...[
          _buildInfoRow(
            context,
            "Packing Charges:",
            "₹${packingCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
          _buildInfoRow(
            context,
            "Platform Charges:",
            "₹${platformCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
          _buildInfoRow(
            context,
            "Delivery Charges:",
            "₹${deliveryCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
        ],

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


class FeedbackSectionWidget extends StatefulWidget {
  final String orderId;
  final Function(String feedback, int rating)? onSubmit;

  const FeedbackSectionWidget({Key? key, this.onSubmit, required this.orderId})
    : super(key: key);

  @override
  State<FeedbackSectionWidget> createState() => _FeedbackSectionWidgetState();
}

class _FeedbackSectionWidgetState extends State<FeedbackSectionWidget> {
  int rating = 0;
  late String orderId;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2, // Subtle elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: theme.cardColor, // Use theme card color
      // margin: EdgeInsets.symmetric(horizontal: 4.w), // Let parent column handle horizontal padding
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Rate Your Experience",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber, // Consistent star color
                    size: 32.sp, // Slightly larger stars
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Share your Feedback...",
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    // ignore: deprecated_member_use
                    .withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none, // Cleaner look with filled color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                if (rating == 0 && _feedbackController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please provide a rating or feedback."),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                  return;
                }
                if (widget.onSubmit != null) {
                  widget.onSubmit!(_feedbackController.text.trim(), rating);
                }
              },
              child: const Text("Submit Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}
