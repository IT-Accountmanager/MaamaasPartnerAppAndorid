import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import '../../API/food_authservice.dart';
import 'package:pdf/widgets.dart' as pw;
import '../newscreens/foodmainscreen.dart';
import '../professional_user/Main_screen.dart';

class food_Invoice extends StatefulWidget {
  final int orderId;
  const food_Invoice({super.key, required this.orderId});
  @override
  _InvoiceState createState() => _InvoiceState();
}

class _InvoiceState extends State<food_Invoice> {
  late final int orderId;
  // String? transactionIdFromPrefs;
  String chargeLabel = "Service Charge";

  @override
  void initState() {
    super.initState();
    // _loadLocalData();
    orderId = widget.orderId;
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreenfood()),
        );
      }
    });
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

  Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final List items = (data['order'] is List) ? data['order'] : [];

    final imageBytes = await rootBundle.load('assets/MAAMAAS.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    String formatAmount(dynamic value) {
      if (value == null) return '0.00';
      return double.tryParse(value.toString())?.toStringAsFixed(2) ?? '0.00';
    }

    // pw.Widget keyValue(String key, String value, {bool bold = false}) {
    //   return pw.Padding(
    //     padding: const pw.EdgeInsets.symmetric(vertical: 2),
    //     child: pw.Row(
    //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //       children: [
    //         pw.Text(
    //           key,
    //           style: pw.TextStyle(
    //             fontSize: 10,
    //             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    //           ),
    //         ),
    //         pw.Text(
    //           value,
    //           style: pw.TextStyle(
    //             fontSize: 10,
    //             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

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
                    'MAAMAAS',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Divider(),

          // ================= ORDER INFO =================
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN — Order Details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue(
                        'Order ID',
                        data['orderId']?.toString() ?? 'N/A',
                      ),

                      // Customer (optional)
                      // keyValue('Customer', data['userName'] ?? 'N/A'),

                      // Order date & time from single field
                      if (data['orderDateAndTime'] != null &&
                          data['orderDateAndTime'].toString().isNotEmpty)
                        () {
                          final orderDateTime = DateTime.tryParse(
                            data['orderDateAndTime'],
                          );
                          if (orderDateTime != null) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                keyValue(
                                  'Date',
                                  "${orderDateTime.day}-${orderDateTime.month}-${orderDateTime.year}",
                                ),
                                keyValue(
                                  'Time',
                                  "${orderDateTime.hour.toString().padLeft(2, '0')}:${orderDateTime.minute.toString().padLeft(2, '0')}",
                                ),
                              ],
                            );
                          } else {
                            return pw.Container(); // fallback if parse fails
                          }
                        }(),

                      //
                      // // If separate 'date' and 'time' fields exist
                      // if (data['date'] != null &&
                      //     data['date'].toString().isNotEmpty)
                      //   keyValue('Scheduled Date', data['date']),
                      // if (data['time'] != null &&
                      //     data['time'].toString().isNotEmpty)
                      //   keyValue('Scheduled Time', data['time']),
                      keyValue(
                        'Order Type',
                        data['orderType']?.toString().replaceAll('_', ' ') ??
                            'N/A',
                      ),
                      keyValue(
                        'Payment',
                        data['paymentMethod']?.toString().replaceAll(
                              '_',
                              ' ',
                            ) ??
                            'N/A',
                      ),

                      if (data['transactionId'] != null)
                        keyValue('Transaction ID', data['transactionId']),

                      if (data["sheduled"] == true) ...[
                        pw.Text(
                          'Scheduled Details',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        if (data['date']?.toString().isNotEmpty ?? false)
                          keyValue('Scheduled Date', data['date']),

                        if (data['time']?.toString().isNotEmpty ?? false)
                          keyValue('Scheduled Time', data['time']),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(width: 20),

                // RIGHT COLUMN — Restaurant Details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue(
                        'Restaurant Name',
                        (data['vendorRegisteredName']?.toString().replaceAll(
                                  '_',
                                  ' ',
                                ) ??
                                'N/A')
                            .toUpperCase(),
                      ),
                      keyValue(
                        'FSSAI No',
                        data['vendorFssai']?.toString() ?? 'N/A',
                      ),
                      keyValue(
                        'GSTIN',
                        data['vendorGstIn']?.toString() ?? 'N/A',
                      ),
                      keyValue(
                        'Restaurant Address',
                        [
                                  data['vendorFullAddress'],
                                  data['vendorCity'],
                                  data['vendorState'],
                                ]
                                .where(
                                  (e) => e != null && e.toString().isNotEmpty,
                                )
                                .toList()
                                .isNotEmpty
                            ? [
                                    data['vendorFullAddress'],
                                    data['vendorCity'],
                                    data['vendorState'],
                                  ]
                                  .where(
                                    (e) => e != null && e.toString().isNotEmpty,
                                  )
                                  .join('\n') // 👈 use newline instead of comma
                            : 'N/A',
                      ),
                      if (data['orderType']?.toString() == "DELIVERY") ...[
                        keyValue(
                          "Customer Name:",
                          "${data['deliveryUserName'] ?? 'N/A'}",
                        ),
                        keyValue(
                          "Mobile Number:",
                          "${data['mobileNo'] ?? 'N/A'}",
                        ),
                        // keyValue(
                        //   "Delivery Address:",
                        //   (data['deliveryAddress'] as String?)?.replaceAll(
                        //         '_',
                        //         ' ',
                        //       ) ??
                        //       'N/A',
                        // ),
                        keyValue(
                          "Delivery Address",
                          (data['deliveryAddress'] as String?)
                                  ?.replaceAll('_', ' ')
                                  ?.replaceAll(',', '\n') ??
                              'N/A',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ================= ITEMS TABLE =================
          pw.Text(
            'Ordered Items',
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
                item['dishName'] ?? 'N/A',
                item['quantity'].toString(),
                "₹${formatAmount(item['price'])}",
                "₹${formatAmount(item['totalPrice'])}",
              ];
            }),
          ),

          pw.SizedBox(height: 20),

          // ================= BILLING SUMMARY =================
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

                  // Base amounts
                  keyValue('Sub Total', "₹${formatAmount(data['subTotal'])}"),
                  keyValue('SGST', "₹${formatAmount(data['sgst'])}"),
                  keyValue('CGST', "₹${formatAmount(data['cgst'])}"),
                  keyValue(
                    'Platform Charges',
                    "₹${formatAmount(data['platformCharges'])}",
                  ),

                  if ((data['discountAmount'] ?? 0) > 0)
                    keyValue(
                      'Discount',
                      "- ₹${formatAmount(data['discountAmount'])}",
                    ),

                  if (data['orderType']?.toString() == "DELIVERY" ||
                      data['orderType']?.toString() == "TAKEAWAY")
                    keyValue(
                      'Packing Charges',
                      "₹${formatAmount(data['packingCharges'])}",
                    ),

                  if (data['orderType']?.toString() == "DELIVERY")
                    keyValue(
                      'Delivery Charges',
                      "₹${formatAmount(data['deliveryCharges'])}",
                    ),

                  pw.Divider(height: 12),

                  keyValue(
                    'Grand Total',
                    "₹${formatAmount(data['grandTotal'])}",
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
              'Thank you for ordering with MAAMAAS',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
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
          MaterialPageRoute(builder: (context) => MainScreenfood()),
          // MaterialPageRoute(builder: (context) => Restaurents()),
          (route) => false,
        );
        return false; // prevent normal back
      },
      child: Scaffold(
        // backgroundColor: theme.colorScheme.surface, // Use theme background
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SafeArea(
            bottom: false,
            child: AppBar(title: Text("Invoice"), centerTitle: true),
          ),
        ),
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
                  return const Center(child: Text("No invoice details found."));
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
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final data = await food_Authservice.fetchOrderById(
                            widget.orderId,
                          );
                          if (data != null) {
                            final pdfBytes = await generateOrderPdf(data);
                            await downloadPdf(
                              pdfBytes,
                              "Invoice_${widget.orderId}.pdf",
                            );
                          }
                        },
                        icon: Icon(Icons.download),
                        label: Text(
                          "Download PDF",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white, // Text & icon color
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 4, // Shadow
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
        : Colors.white;
    final onCardColor = Colors.black;
    final dateTimeStr = data['orderDateAndTime'];
    DateTime? dateTime = dateTimeStr != null
        ? DateTime.tryParse(dateTimeStr)
        : null;
    bool parseBool(dynamic value) {
      return value == true ||
          value == 1 ||
          value == '1' ||
          value.toString().toLowerCase() == 'true';
    }

    final bool isScheduled = parseBool(data['sheduled']);

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
              dateTime != null
                  ? "${dateTime.year}-${dateTime.month}-${dateTime.day}"
                  : "N/A",
              onCardColor: onCardColor,
            ),

            _buildInfoRow(
              context,
              "Time:",
              dateTime != null
                  ? "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}"
                  : "N/A",
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
                data['transactionId'] ?? "N/A",
                onCardColor: onCardColor,
              ),
            // if (data['paymentMethod']?.toString().toLowerCase() ==
            //     "maamaas_wallet")
            //   _buildInfoRow(
            //     context,
            //     "walletType:",
            //     data['walletTypes'] ?? "N/A",
            //     onCardColor: onCardColor,
            //   ),
            if (data['orderType']?.toString() == "DELIVERY") ...[
              _buildInfoRow(
                context,
                "Customer Name:",
                "${data['deliveryUserName'] ?? 'N/A'}",
                onCardColor: onCardColor,
              ),
              _buildInfoRow(
                context,
                "Mobile Number:",
                "${data['mobileNo'] ?? 'N/A'}",
                onCardColor: onCardColor,
              ),
              _buildInfoRow(
                context,
                "Delivery Address:",
                (data['deliveryAddress'] as String?)?.replaceAll('_', ' ') ??
                    'N/A',
                onCardColor: onCardColor,
              ),
            ],
            if (isScheduled) ...[
              const SizedBox(height: 12),

              Text(
                "Scheduled Details",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onCardColor,
                ),
              ),

              const SizedBox(height: 8),

              if (data['date'] != null && data['date'].toString().isNotEmpty)
                _buildInfoRow(
                  context,
                  "Scheduled Date:",
                  data['date'],
                  onCardColor: onCardColor,
                ),

              if (data['time'] != null && data['time'].toString().isNotEmpty)
                _buildInfoRow(
                  context,
                  "Scheduled Time:",
                  data['time'],
                  onCardColor: onCardColor,
                ),
            ],

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
      color: Colors.grey,
      // color: onCardColor.withOpacity(0.9),
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
                  "₹${(item['price'] as num?)?.toStringAsFixed(1) ?? '0.00'}",
                  style: cellStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                  "₹${(item['totalPrice'] as num?)?.toStringAsFixed(1) ?? '0.00'}",
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
    // final num serviceCharges = data['serviceCharge'] ?? 0;
    final num deliveryCharges = data['deliveryCharges'] ?? 0;
    final num grandTotal = data['grandTotal'] ?? 0;

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
        _buildInfoRow(
          context,
          "Platform Charges:",
          "₹${platformCharges.toStringAsFixed(2)}",
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
        if (orderType == 'delivery' || orderType == 'takeaway')
          _buildInfoRow(
            context,
            "Packing Charges:",
            "₹${packingCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
        if (orderType == 'delivery')
          _buildInfoRow(
            context,
            "Delivery Charges:",
            "₹${deliveryCharges.toStringAsFixed(2)}",
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
}
