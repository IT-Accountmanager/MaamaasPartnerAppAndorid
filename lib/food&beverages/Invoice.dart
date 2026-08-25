// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../API/food_authservice.dart';
// // import 'package:pdf/widgets.dart' as pw;
// //
// // import '../printservice/printservice.dart';
// //
// // class food_Invoice extends StatefulWidget {
// //   final int orderId;
// //
// //   const food_Invoice({super.key, required this.orderId});
// //
// //   @override
// //   _InvoiceState createState() => _InvoiceState();
// // }
// //
// // class _InvoiceState extends State<food_Invoice> {
// //   late final int orderId;
// //   String? transactionIdFromPrefs;
// //   String chargeLabel = "Service Charge";
// //
// //   List<BluetoothInfo> pairedDevices = [];
// //   List<BluetoothInfo> scannedDevices = [];
// //   String? connectedPrinterMac;
// //   bool isScanning = false;
// //   bool isConnected = false;
// //
// //   static const String kDefaultPrinterKey = 'default_printer_mac';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadLocalData();
// //     orderId = widget.orderId;
// //   }
// //
// //   Future<void> saveDefaultPrinter(String mac) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString(kDefaultPrinterKey, mac);
// //   }
// //
// //   Future<String?> getDefaultPrinter() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return prefs.getString(kDefaultPrinterKey);
// //   }
// //
// //   Future<void> printBillToBluetooth(Map<String, dynamic> data) async {
// //     print("🔹 Print button clicked - showing printer selector");
// //
// //     // Show bottom sheet with printers
// //     await showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //       ),
// //       builder: (context) => DraggableScrollableSheet(
// //         initialChildSize: 0.9,
// //         minChildSize: 0.5,
// //         maxChildSize: 0.95,
// //         builder: (context, scrollController) => PrinterBottomSheet(
// //           controller: scrollController,
// //           onPrint: (printerMac) => printInvoiceToPrinter(data, printerMac),
// //           onConnected: (mac) {
// //             connectedPrinterMac = mac;
// //             isConnected = true;
// //           },
// //           onSetDefault: saveDefaultPrinter,
// //           parentEnsureBluetoothPermissions: ensureBluetoothPermissions,
// //           parentShowBluetoothPermissionDialog: _showBluetoothPermissionDialog,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> printcustomercopyToPrinter(
// //     Map<String, dynamic> data,
// //     String printerMac,
// //   ) async {
// //     try {
// //       await _printThermalkot(data); // Your existing thermal receipt function
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("✅ Customer Copy  printed successfully!"),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("❌ Print failed: $e"),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     } finally {
// //       await PrintBluetoothThermal.disconnect;
// //     }
// //   }
// //
// //   String formatPaymentMethod(String? method) {
// //     switch (method) {
// //       case 'Online_Payment':
// //         return 'Online Payment';
// //       case 'Cash':
// //         return 'Cash';
// //       case 'Maamaas_Wallet':
// //         return 'Maamaas Wallet';
// //       case 'UPI':
// //         return 'UPI';
// //       default:
// //         return method?.replaceAll('_', ' ') ?? '';
// //     }
// //   }
// //
// //   String formatOrderType(String? type) {
// //     switch (type) {
// //       case 'TAKEAWAY':
// //         return 'Take Away';
// //       case 'DINE_IN':
// //         return 'Dine In';
// //       case 'DELIVERY':
// //         return 'Delivery';
// //       default:
// //         return type?.replaceAll('_', ' ') ?? '';
// //     }
// //   }
// //
// //   Future<void> _printThermalkot(Map<String, dynamic> data) async {
// //     final items = data['order'] as List<dynamic>? ?? [];
// //
// //     // ---------------- HEADER TITLE (BIG + BOLD + CENTER) ----------------
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
// //
// //     // BOLD ON
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "${data['vendorRegisteredName']?.toString().toUpperCase()}\n",
// //       ),
// //     );
// //
// //     // Reset to normal
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     // Center divider
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
// //
// //     String left1 = "Order ID : ${data['orderId']}";
// //     String right1 = "Date : ${data['date'] ?? ''}";
// //
// //     String left2 = "Type     : ${formatOrderType(data['orderType'])}";
// //     String right2 = "Time : ${data['time'] ?? ''}";
// //
// //     String makeRow(String left, String right) {
// //       int maxWidth = 48;
// //       int spaces = maxWidth - left.length - right.length;
// //       if (spaces < 1) spaces = 1;
// //       return left + (" " * spaces) + right;
// //     }
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: makeRow(left1, right1) + "\n"),
// //     );
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: makeRow(left2, right2) + "\n"),
// //     );
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     // ---------------- ITEMS ----------------
// //
// //     // Bold ON
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "ITEM                       QTY\n",
// //       ),
// //     );
// //
// //     // Bold OFF
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     for (var item in items) {
// //       String name = (item['dishName'] ?? 'N/A').toString();
// //       if (name.length > 26) name = name.substring(0, 26);
// //
// //       final qty = item['quantity']?.toString() ?? '0';
// //       // final price = (item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00';
// //
// //       final line = name.padRight(28) + qty.padRight(10);
// //
// //       await PrintBluetoothThermal.writeString(
// //         printText: PrintTextSize(size: 2, text: "$line\n"),
// //       );
// //     }
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     // ---------------- CUT PAPER ----------------
// //     await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
// //     await cutPaper();
// //   }
// //
// //   Future<void> printInvoiceToPrinter(
// //     Map<String, dynamic> data,
// //     String printerMac,
// //   ) async {
// //     try {
// //       await _printThermalReceipt(
// //         data,
// //       ); // Your existing thermal receipt function
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("✅ Customer Copy  printed successfully!"),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("❌ Print failed: $e"),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     } finally {
// //       await PrintBluetoothThermal.disconnect;
// //     }
// //   }
// //
// //   Future<void> _printThermalReceipt(Map<String, dynamic> data) async {
// //     final items = data['order'] as List<dynamic>? ?? [];
// //
// //     // ---------------- HEADER TITLE (BIG + BOLD + CENTER) ----------------
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
// //
// //     // BOLD ON
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "${data['vendorRegisteredName']?.toString().toUpperCase()}\n",
// //       ),
// //     );
// //
// //     // Reset to normal
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     // Center divider
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     // ---------------- ORDER DETAILS (BOLD TEXT) ----------------
// //
// //     // Bold ON (ESC ! 8)
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
// //
// //     String left1 = "Order ID : ${data['orderId']}";
// //     String right1 = "Date : ${data['date'] ?? ''}";
// //
// //     String left2 = "Type     : ${formatOrderType(data['orderType'])}";
// //     String right2 = "Time : ${data['time'] ?? ''}";
// //
// //     String left3 = "Payment  : ${formatPaymentMethod(data['paymentMethod'])}";
// //     String right3 = "";
// //
// //     String makeRow(String left, String right, {int totalWidth = 48}) {
// //       left = left.trimRight();
// //       right = right.trimLeft();
// //
// //       int spaceCount = totalWidth - left.length - right.length;
// //       if (spaceCount < 1) spaceCount = 1;
// //
// //       return left + (' ' * spaceCount) + right;
// //     }
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: makeRow(left1, right1) + "\n"),
// //     );
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: makeRow(left2, right2) + "\n"),
// //     );
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: makeRow(left3, right3) + "\n"),
// //     );
// //
// //     // Bold OFF
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     // ---------------- ITEMS ----------------
// //
// //     // Bold ON
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "ITEM                       QTY       TOTAL\n",
// //       ),
// //     );
// //
// //     // Bold OFF
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     for (var item in items) {
// //       String name = (item['dishName'] ?? 'N/A').toString();
// //       if (name.length > 26) name = name.substring(0, 26);
// //
// //       final qty = item['quantity']?.toString() ?? '0';
// //       final price = (item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00';
// //
// //       final line = name.padRight(28) + qty.padRight(10) + "Rs.$price";
// //
// //       await PrintBluetoothThermal.writeString(
// //         printText: PrintTextSize(size: 2, text: "$line\n"),
// //       );
// //     }
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     // ---------------- SUMMARY ----------------
// //
// //     double subTotal = (data['subTotal'] ?? 0).toDouble();
// //     double cgst = (data['cgst'] ?? 0).toDouble();
// //     double sgst = (data['sgst'] ?? 0).toDouble();
// //     double grandTotal = (data['grandTotal'] ?? 0).toDouble();
// //     double servicecharges = (data['serviceCharge'] ?? 0);
// //     double platformCharges = (data['platformCharges'] ?? 0);
// //     double packingCharges = (data['packingCharges'] ?? 0);
// //
// //     await PrintBluetoothThermal.writeBytes(
// //       Uint8List.fromList([27, 33, 8]),
// //     ); // Bold
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text:
// //             "Sub Total:                            Rs.${subTotal.toStringAsFixed(2)}\n",
// //       ),
// //     );
// //     if (data["orderType"] == "DINE_IN")
// //       await PrintBluetoothThermal.writeString(
// //         printText: PrintTextSize(
// //           size: 2,
// //           text:
// //               "Service Charges:                      Rs.${servicecharges.toStringAsFixed(2)}\n",
// //         ),
// //       );
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text:
// //             "Platform Charges:                     Rs.${platformCharges.toStringAsFixed(2)}\n",
// //       ),
// //     );
// //     if (data["orderType"] == "TAKEAWAY")
// //       await PrintBluetoothThermal.writeString(
// //         printText: PrintTextSize(
// //           size: 2,
// //           text:
// //               "Packing Charges:                       Rs.${packingCharges.toStringAsFixed(2)}\n",
// //         ),
// //       );
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text:
// //             "SGST:                                 Rs.${sgst.toStringAsFixed(2)}\n",
// //       ),
// //     );
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text:
// //             "CGST:                                 Rs.${cgst.toStringAsFixed(2)}\n",
// //       ),
// //     );
// //
// //     // Bold OFF
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     // ---------------- GRAND TOTAL (BOLD + DOUBLE SIZE + CENTER) ----------------
// //
// //     await PrintBluetoothThermal.writeBytes(
// //       Uint8List.fromList([27, 97, 1]),
// //     ); // center
// //     await PrintBluetoothThermal.writeBytes(
// //       Uint8List.fromList([27, 33, 48]),
// //     ); // double size + bold
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text:
// //             "TOTAL:                                Rs.${grandTotal.toStringAsFixed(2)}\n",
// //       ),
// //     );
// //
// //     // Reset formatting
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     // FSSAI + GST
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "FSSAI: ${data['vendorFssai']}\n",
// //       ),
// //     );
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "GSTIN: ${data['vendorGstIn']}\n\n",
// //       ),
// //     );
// //
// //     // ---------------- FOOTER (CENTER + BOLD) ----------------
// //     await PrintBluetoothThermal.writeBytes(
// //       Uint8List.fromList([27, 97, 1]),
// //     ); // center
// //     await PrintBluetoothThermal.writeBytes(
// //       Uint8List.fromList([27, 33, 8]),
// //     ); // bold
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: "Thank You for Visiting!\n"),
// //     );
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: "Have a nice day!\n\n"),
// //     );
// //
// //     // Reset
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     // ---------------- CUT PAPER ----------------
// //     await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
// //     await cutPaper();
// //   }
// //
// //   Future<void> cutPaper() async {
// //     // Feed lines
// //     await PrintBluetoothThermal.writeBytes([27, 100, 2]);
// //
// //     // Try different cut cmds
// //     // await PrintBluetoothThermal.writeBytes([29, 86, 0]); // GS V 0
// //     // await PrintBluetoothThermal.writeBytes([29, 86, 1]); // GS V 1
// //     // await PrintBluetoothThermal.writeBytes([29, 86, 66, 0]); // GS V B 0
// //     // await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]); // GS V A 0
// //   }
// //
// //   Future<bool> ensureBluetoothPermissions() async {
// //     try {
// //       // Check Bluetooth is enabled
// //       final bool isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
// //       if (!isBluetoothOn) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Nearby/Bluetooth permission is required to print.'),
// //             duration: Duration(seconds: 3),
// //           ),
// //         );
// //         _showBluetoothPermissionDialog(); // opens your dialog with Open Settings
// //         return false;
// //       }
// //
// //       // Request standard Bluetooth permissions only
// //       Map<Permission, PermissionStatus> statuses = await [
// //         Permission.bluetoothScan,
// //         Permission.bluetoothConnect,
// //         Permission.bluetoothAdvertise,
// //         Permission.locationWhenInUse, // Often needed for classic Bluetooth
// //       ].request();
// //
// //       // Check if any critical permission denied
// //       if (statuses[Permission.bluetoothScan]?.isGranted != true ||
// //           statuses[Permission.bluetoothConnect]?.isGranted != true) {
// //         _showBluetoothPermissionDialog();
// //         return false;
// //       }
// //       return true;
// //     } catch (e) {
// //       print('Permission check error: $e');
// //       return false;
// //     }
// //   }
// //
// //   void _showBluetoothPermissionDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('Bluetooth Permission Needed'),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('Nearby Devices permission is OFF'),
// //             SizedBox(height: 12.h),
// //             Text('Go to Settings > Apps > Your App > Permissions'),
// //             Text('Enable "Nearby devices" & "Bluetooth Scan"'),
// //             SizedBox(height: 12.h),
// //             Text(
// //               'Or tap below to open Settings directly',
// //               style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text('Cancel'),
// //           ),
// //           ElevatedButton.icon(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               openAppSettings();
// //             },
// //             icon: Icon(Icons.settings),
// //             label: Text('Open Settings'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> _loadLocalData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       transactionIdFromPrefs = prefs.getString('razorpay_transaction_id');
// //       chargeLabel = prefs.getString('chargeLabel') ?? "Service Charge";
// //     });
// //   }
// //
// //   Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
// //     final pdf = pw.Document();
// //     final List<dynamic> items = data['order'] as List<dynamic>? ?? [];
// //
// //     final imageBytes = await rootBundle.load('assets/MAAMAAS.jpeg');
// //     final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
// //     final prefs = await SharedPreferences.getInstance();
// //     final transactionIdFromPrefs = prefs.getString('transactionId');
// //
// //     final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
// //     final ttf = pw.Font.ttf(fontData);
// //     final orderType = (data['orderType']?.toString().toLowerCase() ?? '');
// //
// //     pdf.addPage(
// //       pw.MultiPage(
// //         theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
// //         pageFormat: PdfPageFormat.a4,
// //         margin: const pw.EdgeInsets.all(32),
// //         build: (context) => [
// //           // Header
// //           pw.Header(
// //             level: 0,
// //             child: pw.Row(
// //               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //               children: [
// //                 pw.Container(width: 70, height: 70, child: pw.Image(image)),
// //                 pw.Text(
// //                   'Invoice / Bill',
// //                   style: pw.TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: pw.FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           pw.SizedBox(height: 1 * PdfPageFormat.cm),
// //
// //           // Order Info
// //           pw.Row(
// //             crossAxisAlignment: pw.CrossAxisAlignment.end,
// //             children: [
// //               pw.Spacer(),
// //               pw.Column(
// //                 crossAxisAlignment: pw.CrossAxisAlignment.end,
// //                 children: [
// //                   pw.Text('Order ID: ${data['orderId'] ?? 'N/A'}'),
// //                   pw.Text('User Name: ${data['userName'] ?? 'N/A'}'),
// //                   pw.Text('Date: ${data['date'] ?? 'N/A'}'),
// //                   pw.Text('Time: ${data['time'] ?? 'N/A'}'),
// //                   pw.Text(
// //                     'Order Type: ${data['orderType']?.toString().replaceAll('_', ' ') ?? 'N/A'}',
// //                   ),
// //                   pw.Text(
// //                     'Payment Method: ${data['paymentMethod']?.toString().replaceAll('_', ' ') ?? 'N/A'}',
// //                   ),
// //                   if (data['paymentMethod']?.toString().toLowerCase() ==
// //                       "online_payment")
// //                     pw.Text(
// //                       'Transaction ID: ${data['transactionId'] ?? transactionIdFromPrefs ?? 'N/A'}',
// //                     ),
// //                   if (data['paymentMethod']?.toString().toLowerCase() ==
// //                       "maamaas_wallet")
// //                     pw.Text('walletType: ${data['walletTypes'] ?? 'N/A'}'),
// //                 ],
// //               ),
// //             ],
// //           ),
// //
// //           if ((data['location'] ?? '').toString().isNotEmpty)
// //             pw.Padding(
// //               padding: const pw.EdgeInsets.only(top: 5),
// //               child: pw.Text('Location: ${data['location']}'),
// //             ),
// //
// //           pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
// //
// //           // Ordered Items Table
// //           pw.Text(
// //             'Ordered Items:',
// //             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
// //           ),
// //           pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
// //           pw.TableHelper.fromTextArray(
// //             headerStyle: pw.TextStyle(
// //               fontWeight: pw.FontWeight.bold,
// //               fontSize: 10,
// //             ),
// //             cellStyle: const pw.TextStyle(fontSize: 9),
// //             headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
// //             cellAlignment: pw.Alignment.centerLeft,
// //             cellAlignments: {
// //               0: pw.Alignment.center,
// //               2: pw.Alignment.center,
// //               3: pw.Alignment.centerRight,
// //               4: pw.Alignment.centerRight,
// //             },
// //             columnWidths: {
// //               0: const pw.FixedColumnWidth(30),
// //               1: const pw.FlexColumnWidth(3),
// //               2: const pw.FixedColumnWidth(40),
// //               3: const pw.FlexColumnWidth(1.5),
// //               4: const pw.FlexColumnWidth(1.5),
// //             },
// //             headers: ['S.No', 'Item', 'Qty', 'Price', 'Total'],
// //             data: List.generate(items.length, (index) {
// //               final item = items[index];
// //               return [
// //                 (index + 1).toString(),
// //                 item['dishName'] ?? 'N/A',
// //                 (item['quantity'] ?? 0).toString(),
// //                 "₹${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                 "₹${(item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //               ];
// //             }),
// //           ),
// //
// //           pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
// //
// //           // Billing Summary Section
// //           pw.Align(
// //             alignment: pw.Alignment.centerRight,
// //             child: pw.SizedBox(
// //               width: 200,
// //               child: pw.Column(
// //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                 children: [
// //                   pw.Text(
// //                     'Billing Summary:',
// //                     style: pw.TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: pw.FontWeight.bold,
// //                     ),
// //                   ),
// //                   pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
// //
// //                   _buildPdfPriceRow(
// //                     'Sub Total:',
// //                     "₹${(data['subTotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     isBold: true,
// //                   ),
// //                   _buildPdfPriceRow(
// //                     'SGST:',
// //                     "₹${(data['sgst'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                   ),
// //                   _buildPdfPriceRow(
// //                     'CGST:',
// //                     "₹${(data['cgst'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                   ),
// //
// //                   if ((data['discountAmount'] as num?) != null &&
// //                       (data['discountAmount'] as num) > 0)
// //                     _buildPdfPriceRow(
// //                       'Discount:',
// //                       "- ₹${(data['discountAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     ),
// //                   _buildPdfPriceRow(
// //                     'Service Charge:',
// //                     "₹${(data['serviceCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                   ),
// //                   // 👇 Conditional charges based on order type
// //                   if (orderType == 'dine-in' || orderType == 'dinein')
// //                     _buildPdfPriceRow(
// //                       'Service Charge:',
// //                       "₹${(data['serviceCharge'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     )
// //                   else if (orderType == 'takeaway' ||
// //                       orderType == 'take away' ||
// //                       orderType == 'pickup') ...[
// //                     _buildPdfPriceRow(
// //                       'Packing Charges:',
// //                       "₹${(data['packingCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     ),
// //                     _buildPdfPriceRow(
// //                       'Platform Charges:',
// //                       "₹${(data['platformCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     ),
// //                   ] else if (orderType == 'delivery') ...[
// //                     _buildPdfPriceRow(
// //                       'Packing Charges:',
// //                       "₹${(data['packingCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     ),
// //                     _buildPdfPriceRow(
// //                       'Platform Charges:',
// //                       "₹${(data['platformCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     ),
// //                     _buildPdfPriceRow(
// //                       'Delivery Charge:',
// //                       "₹${(data['deliveryCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     ),
// //                   ],
// //
// //                   pw.Divider(color: PdfColors.grey600, height: 10),
// //
// //                   _buildPdfPriceRow(
// //                     'Grand Total:',
// //                     "₹${(data['grandTotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                     isBold: true,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //
// //           pw.SizedBox(height: 1.5 * PdfPageFormat.cm),
// //           pw.Center(
// //             child: pw.Text(
// //               'Thank you for your order! Visit Again!',
// //               style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
// //             ),
// //           ),
// //           pw.Center(
// //             child: pw.Text(
// //               'Visit Again!',
// //               style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //
// //     return pdf.save();
// //   }
// //
// //   pw.Widget _buildPdfPriceRow(
// //     String label,
// //     String value, {
// //     bool isBold = false,
// //   }) {
// //     return pw.Row(
// //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //       children: [
// //         pw.Text(
// //           label,
// //           style: pw.TextStyle(
// //             fontSize: 10,
// //             fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
// //           ),
// //         ),
// //         pw.Text(
// //           value,
// //           style: pw.TextStyle(
// //             fontSize: 10,
// //             fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //
// //     return Scaffold(
// //       backgroundColor: theme.colorScheme.surface,
// //       appBar: AppBar(
// //         // Remove the leading property entirely
// //         // leading: IconButton(...), // Remove this line
// //         title: Text(
// //           "Invoice",
// //           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
// //         ),
// //         centerTitle: true,
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //         iconTheme: IconThemeData(color: Colors.black),
// //       ),
// //       body: Stack(
// //         children: [
// //           FutureBuilder<Map<String, dynamic>?>(
// //             future: food_authservice.fetchOrderById(widget.orderId),
// //             builder: (context, snapshot) {
// //               if (snapshot.connectionState == ConnectionState.waiting) {
// //                 return const Center(child: CircularProgressIndicator());
// //               } else if (snapshot.hasError) {
// //                 return Center(
// //                   child: Text(
// //                     "Error fetching invoice: ${snapshot.error}",
// //                     style: TextStyle(color: theme.colorScheme.error),
// //                   ),
// //                 );
// //               } else if (!snapshot.hasData || snapshot.data == null) {
// //                 return const Center(child: Text("No invoice details found."));
// //               }
// //
// //               final data = snapshot.data!;
// //               final List<dynamic> items = data['order'] as List<dynamic>? ?? [];
// //
// //               return SingleChildScrollView(
// //                 padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     _buildInvoiceContentCard(context, theme, data, items),
// //                     // SizedBox(height: 24.h),
// //                     // _buildActionButtons(context, theme, data),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInvoiceContentCard(
// //     BuildContext context,
// //     ThemeData theme,
// //     Map<String, dynamic> data,
// //     List<dynamic> items,
// //   ) {
// //     final cardBackgroundColor = theme.brightness == Brightness.dark
// //         ? Colors.grey[800]
// //         : Color(0xFFF97316);
// //     final onCardColor = Colors.white;
// //
// //     return Card(
// //       elevation: 3,
// //       margin: EdgeInsets.zero,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
// //       color: cardBackgroundColor,
// //       child: Padding(
// //         padding: EdgeInsets.all(16.w),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Center(
// //               child: Text(
// //                 "Order Summary",
// //                 style: TextStyle(
// //                   color: onCardColor,
// //                   fontSize: 18.sp,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: 20.h),
// //             _buildInfoRow(
// //               context,
// //               "Order ID:",
// //               "${data['orderId'] ?? 'N/A'}",
// //               onCardColor: onCardColor,
// //             ),
// //             _buildInfoRow(
// //               context,
// //               "Date:",
// //               "${data['date'] ?? 'N/A'}",
// //               onCardColor: onCardColor,
// //             ),
// //             _buildInfoRow(
// //               context,
// //               "Time:",
// //               "${data['time'] ?? 'N/A'}",
// //               onCardColor: onCardColor,
// //             ),
// //             _buildInfoRow(
// //               context,
// //               "Order Type:",
// //               (data['orderType'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
// //               onCardColor: onCardColor,
// //             ),
// //             _buildInfoRow(
// //               context,
// //               "Payment:",
// //               (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
// //               onCardColor: onCardColor,
// //             ),
// //             if (data['paymentMethod']?.toString() == "Online_Payment")
// //               _buildInfoRow(
// //                 context,
// //                 "Transaction ID:",
// //                 data['transactionId'] ?? transactionIdFromPrefs ?? "N/A",
// //                 onCardColor: onCardColor,
// //               ),
// //             if (data['paymentMethod']?.toString().toLowerCase() ==
// //                 "maamaas_wallet")
// //               _buildInfoRow(
// //                 context,
// //                 "walletType:",
// //                 data['walletTypes'] ?? "N/A",
// //                 onCardColor: onCardColor,
// //               ),
// //
// //             Divider(
// //               color: onCardColor.withOpacity(0.4),
// //               thickness: 0.8,
// //               height: 25.h,
// //             ),
// //             Text(
// //               "Ordered Items",
// //               style: TextStyle(
// //                 color: onCardColor,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 15.sp,
// //               ),
// //             ),
// //             SizedBox(height: 10.h),
// //             _buildItemsTable(context, items, onCardColor),
// //
// //             SizedBox(height: 15.h),
// //             _buildPriceDetails(context, data, onCardColor),
// //
// //             // =============== CONDITION FOR PRINT BUTTONS ===============
// //             if ((data['orderType']?.toString() ?? '').toUpperCase() ==
// //                 'DINE_IN')
// //               Column(
// //                 children: [
// //                   SizedBox(height: 20),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [
// //                       _buildPrintButton(
// //                         context: context,
// //                         data: data,
// //                         buttonText: 'KOT',
// //                         onPressed: () async {
// //                           final bool bluetoothOk =
// //                               await ensureBluetoothPermissions();
// //                           if (!bluetoothOk) return;
// //
// //                           final data = await food_authservice.fetchOrderById(
// //                             widget.orderId,
// //                           );
// //                           if (data == null) return;
// //
// //                           final defaultMac = await getDefaultPrinter();
// //
// //                           if (defaultMac != null && defaultMac.isNotEmpty) {
// //                             try {
// //                               final connected =
// //                                   await PrintBluetoothThermal.connect(
// //                                     macPrinterAddress: defaultMac,
// //                                   );
// //                               if (connected) {
// //                                 await printcustomercopyToPrinter(
// //                                   data,
// //                                   defaultMac,
// //                                 );
// //                                 return;
// //                               } else {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(
// //                                     content: Text(
// //                                       'Default printer not reachable. Select printer.',
// //                                     ),
// //                                   ),
// //                                 );
// //                               }
// //                             } catch (e) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(content: Text('Print failed: $e')),
// //                               );
// //                             }
// //                           }
// //
// //                           printBillToBluetooth(data);
// //                         },
// //                       ),
// //
// //                       _buildPrintButton(
// //                         context: context,
// //                         data: data,
// //                         buttonText: 'Customer Copy',
// //                         onPressed: () async {
// //                           final bool bluetoothOk =
// //                               await ensureBluetoothPermissions();
// //                           if (!bluetoothOk) return;
// //
// //                           final data = await food_authservice.fetchOrderById(
// //                             widget.orderId,
// //                           );
// //                           if (data == null) return;
// //
// //                           final defaultMac = await getDefaultPrinter();
// //
// //                           if (defaultMac != null && defaultMac.isNotEmpty) {
// //                             try {
// //                               final connected =
// //                                   await PrintBluetoothThermal.connect(
// //                                     macPrinterAddress: defaultMac,
// //                                   );
// //                               if (connected) {
// //                                 await printInvoiceToPrinter(data, defaultMac);
// //                                 return;
// //                               } else {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(
// //                                     content: Text(
// //                                       'Default printer not reachable. Select printer.',
// //                                     ),
// //                                   ),
// //                                 );
// //                               }
// //                             } catch (e) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(content: Text('Print failed: $e')),
// //                               );
// //                             }
// //                           }
// //
// //                           printBillToBluetooth(data);
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               )
// //             else
// //               // Show only KOT button for non-DINE_IN orders
// //               Column(
// //                 children: [
// //                   SizedBox(height: 20),
// //                   Center(
// //                     child: _buildPrintButton(
// //                       context: context,
// //                       data: data,
// //                       buttonText: 'KOT',
// //                       onPressed: () async {
// //                         final bool bluetoothOk =
// //                             await ensureBluetoothPermissions();
// //                         if (!bluetoothOk) return;
// //
// //                         final data = await food_authservice.fetchOrderById(
// //                           widget.orderId,
// //                         );
// //                         if (data == null) return;
// //
// //                         final defaultMac = await getDefaultPrinter();
// //
// //                         if (defaultMac != null && defaultMac.isNotEmpty) {
// //                           try {
// //                             final connected =
// //                                 await PrintBluetoothThermal.connect(
// //                                   macPrinterAddress: defaultMac,
// //                                 );
// //                             if (connected) {
// //                               await printcustomercopyToPrinter(
// //                                 data,
// //                                 defaultMac,
// //                               );
// //                               return;
// //                             } else {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 const SnackBar(
// //                                   content: Text(
// //                                     'Default printer not reachable. Select printer.',
// //                                   ),
// //                                 ),
// //                               );
// //                             }
// //                           } catch (e) {
// //                             ScaffoldMessenger.of(context).showSnackBar(
// //                               SnackBar(content: Text('Print failed: $e')),
// //                             );
// //                           }
// //                         }
// //
// //                         printBillToBluetooth(data);
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             // =============== END OF CONDITION ===============
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPrintButton({
// //     required BuildContext context,
// //     required Map<String, dynamic> data,
// //     required String buttonText,
// //     required VoidCallback onPressed,
// //   }) {
// //     return ElevatedButton.icon(
// //       onPressed: onPressed,
// //       icon: Icon(Icons.print),
// //       label: Text(buttonText),
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: Colors.green,
// //         foregroundColor: Colors.white,
// //         elevation: 3,
// //         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoRow(
// //     BuildContext context,
// //     String label,
// //     String value, {
// //     required Color onCardColor,
// //   }) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(vertical: 3.h),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Expanded(
// //             flex: 2,
// //             child: Text(
// //               label,
// //               style: TextStyle(
// //                 color: onCardColor.withOpacity(0.85),
// //                 fontSize: 13.sp,
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             flex: 3,
// //             child: Text(
// //               value,
// //               style: TextStyle(
// //                 color: onCardColor,
// //                 fontSize: 13.sp,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //               textAlign: TextAlign.end,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildItemsTable(
// //     BuildContext context,
// //     List<dynamic> items,
// //     Color onCardColor,
// //   ) {
// //     final headerStyle = TextStyle(
// //       color: onCardColor.withOpacity(0.9),
// //       fontSize: 11.sp,
// //       fontWeight: FontWeight.bold,
// //     );
// //     final cellStyle = TextStyle(color: onCardColor, fontSize: 11.sp);
// //
// //     return Table(
// //       columnWidths: {
// //         0: IntrinsicColumnWidth(flex: 0.5), // S.No
// //         1: FlexColumnWidth(3), // Item Name
// //         2: IntrinsicColumnWidth(flex: 1), // Qty
// //         3: FlexColumnWidth(1.5), // Price
// //         4: FlexColumnWidth(1.5), // Total
// //       },
// //       children: [
// //         TableRow(
// //           decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
// //           children: [
// //             Padding(
// //               padding: EdgeInsets.all(8.w),
// //               child: Text(
// //                 "S.No",
// //                 style: headerStyle,
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //             Padding(
// //               padding: EdgeInsets.all(8.w),
// //               child: Text("Item", style: headerStyle),
// //             ),
// //             Padding(
// //               padding: EdgeInsets.all(8.w),
// //               child: Text(
// //                 "Qty",
// //                 style: headerStyle,
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //             Padding(
// //               padding: EdgeInsets.all(8.w),
// //               child: Text(
// //                 "Price",
// //                 style: headerStyle,
// //                 textAlign: TextAlign.right,
// //               ),
// //             ),
// //             Padding(
// //               padding: EdgeInsets.all(8.w),
// //               child: Text(
// //                 "Total",
// //                 style: headerStyle,
// //                 textAlign: TextAlign.right,
// //               ),
// //             ),
// //           ],
// //         ),
// //         ...items.asMap().entries.map((entry) {
// //           final index = entry.key;
// //           final item = entry.value as Map<String, dynamic>;
// //           return TableRow(
// //             decoration: BoxDecoration(
// //               border: Border(
// //                 bottom: BorderSide(
// //                   color: onCardColor.withOpacity(0.2),
// //                   width: 0.5,
// //                 ),
// //               ),
// //             ),
// //             children: [
// //               Padding(
// //                 padding: EdgeInsets.all(8.w),
// //                 child: Text(
// //                   "${index + 1}",
// //                   style: cellStyle,
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //               Padding(
// //                 padding: EdgeInsets.all(8.w),
// //                 child: Text(
// //                   item['dishName']?.toString() ?? 'N/A',
// //                   style: cellStyle,
// //                 ),
// //               ),
// //               Padding(
// //                 padding: EdgeInsets.all(8.w),
// //                 child: Text(
// //                   (item['quantity'] ?? 0).toString(),
// //                   style: cellStyle,
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //               Padding(
// //                 padding: EdgeInsets.all(8.w),
// //                 child: Text(
// //                   "₹${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                   style: cellStyle,
// //                   textAlign: TextAlign.right,
// //                 ),
// //               ),
// //               Padding(
// //                 padding: EdgeInsets.all(8.w),
// //                 child: Text(
// //                   "₹${(item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
// //                   style: cellStyle,
// //                   textAlign: TextAlign.right,
// //                 ),
// //               ),
// //             ],
// //           );
// //         }),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildPriceDetails(
// //     BuildContext context,
// //     Map<String, dynamic> data,
// //     Color onCardColor,
// //   ) {
// //     final orderType = data['orderType']?.toString().toLowerCase() ?? '';
// //     final num subTotal = data['subTotal'] ?? 0;
// //     final num discount = data['discountAmount'] ?? 0;
// //     final num sgst = data['sgst'] ?? 0;
// //     final num cgst = data['cgst'] ?? 0;
// //     final num platformCharges = data['platformCharges'] ?? 0;
// //     final num packingCharges = data['packingCharges'] ?? 0;
// //     final num serviceCharges = data['serviceCharge'] ?? 0;
// //     final num deliveryCharges = data['deliveryCharges'] ?? 0;
// //     final num grandTotal = data['totalAmount'] ?? 0;
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.end,
// //       children: [
// //         SizedBox(height: 5.h),
// //
// //         _buildInfoRow(
// //           context,
// //           "Sub Total:",
// //           "₹${subTotal.toStringAsFixed(2)}",
// //           onCardColor: onCardColor,
// //         ),
// //
// //         // _buildInfoRow(
// //         //   context,
// //         //   "SGST:",
// //         //   "₹${sgst.toStringAsFixed(2)}",
// //         //   onCardColor: onCardColor,
// //         // ),
// //         // _buildInfoRow(
// //         //   context,
// //         //   "CGST:",
// //         //   "₹${cgst.toStringAsFixed(2)}",
// //         //   onCardColor: onCardColor,
// //         // ),
// //         if (sgst > 0)
// //           _buildInfoRow(
// //             context,
// //             "SGST:",
// //             "₹${sgst.toStringAsFixed(2)}",
// //             onCardColor: onCardColor,
// //           ),
// //
// //         if (cgst > 0)
// //           _buildInfoRow(
// //             context,
// //             "CGST:",
// //             "₹${cgst.toStringAsFixed(2)}",
// //             onCardColor: onCardColor,
// //           ),
// //
// //         if (discount > 0)
// //           _buildInfoRow(
// //             context,
// //             "Discount:",
// //             "-₹${discount.toStringAsFixed(2)}",
// //             onCardColor: onCardColor,
// //           ),
// //
// //         // 👇 Conditional Charges based on orderType
// //         // if (orderType == 'dine_in') ...[
// //         //   _buildInfoRow(
// //         //     context,
// //         //     "Service Charges:",
// //         //     "₹${serviceCharges.toStringAsFixed(2)}",
// //         //     onCardColor: onCardColor,
// //         //   ),
// //         // ] else if (orderType == 'takeaway' ||
// //         //     orderType == 'take_away' ||
// //         //     orderType == 'pickup') ...[
// //         //   _buildInfoRow(
// //         //     context,
// //         //     "Packing Charges:",
// //         //     "₹${packingCharges.toStringAsFixed(2)}",
// //         //     onCardColor: onCardColor,
// //         //   ),
// //         //   _buildInfoRow(
// //         //     context,
// //         //     "Platform Charges:",
// //         //     "₹${platformCharges.toStringAsFixed(2)}",
// //         //     onCardColor: onCardColor,
// //         //   ),
// //         // ] else if (orderType == 'delivery') ...[
// //         //   _buildInfoRow(
// //         //     context,
// //         //     "Packing Charges:",
// //         //     "₹${packingCharges.toStringAsFixed(2)}",
// //         //     onCardColor: onCardColor,
// //         //   ),
// //         //   _buildInfoRow(
// //         //     context,
// //         //     "Platform Charges:",
// //         //     "₹${platformCharges.toStringAsFixed(2)}",
// //         //     onCardColor: onCardColor,
// //         //   ),
// //         //   _buildInfoRow(
// //         //     context,
// //         //     "Delivery Charges:",
// //         //     "₹${deliveryCharges.toStringAsFixed(2)}",
// //         //     onCardColor: onCardColor,
// //         //   ),
// //         // ],
// //         if (orderType == 'dine_in' && serviceCharges > 0) ...[
// //           _buildInfoRow(
// //             context,
// //             "Service Charges:",
// //             "₹${serviceCharges.toStringAsFixed(2)}",
// //             onCardColor: onCardColor,
// //           ),
// //         ] else if (orderType == 'takeaway' ||
// //             orderType == 'take_away' ||
// //             orderType == 'pickup') ...[
// //           if (packingCharges > 0)
// //             _buildInfoRow(
// //               context,
// //               "Packing Charges:",
// //               "₹${packingCharges.toStringAsFixed(2)}",
// //               onCardColor: onCardColor,
// //             ),
// //           if (platformCharges > 0)
// //             _buildInfoRow(
// //               context,
// //               "Platform Charges:",
// //               "₹${platformCharges.toStringAsFixed(2)}",
// //               onCardColor: onCardColor,
// //             ),
// //         ] else if (orderType == 'delivery') ...[
// //           if (packingCharges > 0)
// //             _buildInfoRow(
// //               context,
// //               "Packing Charges:",
// //               "₹${packingCharges.toStringAsFixed(2)}",
// //               onCardColor: onCardColor,
// //             ),
// //           if (platformCharges > 0)
// //             _buildInfoRow(
// //               context,
// //               "Platform Charges:",
// //               "₹${platformCharges.toStringAsFixed(2)}",
// //               onCardColor: onCardColor,
// //             ),
// //           if (deliveryCharges > 0)
// //             _buildInfoRow(
// //               context,
// //               "Delivery Charges:",
// //               "₹${deliveryCharges.toStringAsFixed(2)}",
// //               onCardColor: onCardColor,
// //             ),
// //         ],
// //         Divider(
// //           color: onCardColor.withOpacity(0.4),
// //           thickness: 0.8,
// //           height: 20.h,
// //         ),
// //
// //         _buildInfoRow(
// //           context,
// //           "Grand Total:",
// //           "₹${grandTotal.toStringAsFixed(2)}",
// //           onCardColor: onCardColor,
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/food_authservice.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// import '../printservice/printservice.dart';
//
// class food_Invoice extends StatefulWidget {
//   final int orderId;
//
//   const food_Invoice({super.key, required this.orderId});
//
//   @override
//   _InvoiceState createState() => _InvoiceState();
// }
//
// class _InvoiceState extends State<food_Invoice> {
//   late final int orderId;
//   String? transactionIdFromPrefs;
//   String chargeLabel = "Service Charge";
//
//   List<BluetoothInfo> pairedDevices = [];
//   List<BluetoothInfo> scannedDevices = [];
//   String? connectedPrinterMac;
//   bool isScanning = false;
//   bool isConnected = false;
//
//   static const String kDefaultPrinterKey = 'default_printer_mac';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLocalData();
//     orderId = widget.orderId;
//   }
//
//   Future<void> saveDefaultPrinter(String mac) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(kDefaultPrinterKey, mac);
//   }
//
//   Future<String?> getDefaultPrinter() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(kDefaultPrinterKey);
//   }
//
//   Future<void> printBillToBluetooth(Map<String, dynamic> data) async {
//     print("🔹 Print button clicked - showing printer selector");
//
//     // Show bottom sheet with printers
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (context, scrollController) => PrinterBottomSheet(
//           controller: scrollController,
//           onPrint: (printerMac) => printInvoiceToPrinter(data, printerMac),
//           onConnected: (mac) {
//             connectedPrinterMac = mac;
//             isConnected = true;
//           },
//           onSetDefault: saveDefaultPrinter,
//           parentEnsureBluetoothPermissions: ensureBluetoothPermissions,
//           parentShowBluetoothPermissionDialog: _showBluetoothPermissionDialog,
//         ),
//       ),
//     );
//   }
//
//   Future<void> printcustomercopyToPrinter(
//     Map<String, dynamic> data,
//     String printerMac,
//   ) async {
//     print("🔹 Starting customer copy print to: $printerMac");
//
//     try {
//       // Try to connect to printer
//       print("🔄 Attempting to connect to printer: $printerMac");
//       bool connected = await PrintBluetoothThermal.connect(
//         macPrinterAddress: printerMac,
//       );
//       if (!connected) {
//         throw Exception("Failed to connect to printer");
//       }
//       print("✅ Connected successfully!");
//
//       await _printThermalkot(data);
//
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("✅ Customer Copy printed successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ Print failed: $e");
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("❌ Print failed: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       rethrow;
//     } finally {
//       try {
//         await PrintBluetoothThermal.disconnect;
//         print("🔌 Disconnected from printer");
//       } catch (e) {
//         print("⚠️ Error during disconnect: $e");
//       }
//     }
//   }
//
//   String formatPaymentMethod(String? method) {
//     switch (method) {
//       case 'Online_Payment':
//         return 'Online Payment';
//       case 'Cash':
//         return 'Cash';
//       case 'Maamaas_Wallet':
//         return 'Maamaas Wallet';
//       case 'UPI':
//         return 'UPI';
//       default:
//         return method?.replaceAll('_', ' ') ?? '';
//     }
//   }
//
//   String formatOrderType(String? type) {
//     switch (type) {
//       case 'TAKEAWAY':
//         return 'Take Away';
//       case 'DINE_IN':
//         return 'Dine In';
//       case 'DELIVERY':
//         return 'Delivery';
//       default:
//         return type?.replaceAll('_', ' ') ?? '';
//     }
//   }
//
//   Future<void> _printThermalkot(Map<String, dynamic> data) async {
//     try {
//       print("📱 Starting KOT print...");
//       print("📊 Data received: ${data.keys}");
//
//       // Check if order data exists
//       final items = data['order'] as List<dynamic>? ?? [];
//       if (items.isEmpty) {
//         print("❌ No items found in order");
//         throw Exception("No items found in order");
//       }
//
//       print("✅ Items found: ${items.length}");
//
//       // ---------------- HEADER TITLE (BIG + BOLD + CENTER) ----------------
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
//
//       // BOLD ON
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
//
//       final vendorName =
//           data['vendorRegisteredName']?.toString().toUpperCase() ?? 'VENDOR';
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: "$vendorName\n"),
//       );
//
//       // Reset to normal
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       // Center divider
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
//
//       String left1 = "Order ID : ${data['orderId'] ?? 'N/A'}";
//       String right1 = "Date : ${data['date'] ?? ''}";
//
//       String left2 = "Type     : ${formatOrderType(data['orderType'])}";
//       String right2 = "Time : ${data['time'] ?? ''}";
//
//       String makeRow(String left, String right) {
//         int maxWidth = 48;
//         int spaces = maxWidth - left.length - right.length;
//         if (spaces < 1) spaces = 1;
//         return left + (" " * spaces) + right;
//       }
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: makeRow(left1, right1) + "\n"),
//       );
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: makeRow(left2, right2) + "\n"),
//       );
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       // ---------------- ITEMS ----------------
//
//       // Bold ON
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "ITEM                       QTY\n",
//         ),
//       );
//
//       // Bold OFF
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       for (var item in items) {
//         String name = (item['dishName'] ?? 'N/A').toString();
//         if (name.length > 26) name = name.substring(0, 26);
//
//         final qty = item['quantity']?.toString() ?? '0';
//
//         final line = name.padRight(28) + qty.padRight(10);
//
//         await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(size: 2, text: "$line\n"),
//         );
//       }
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       // ---------------- CUT PAPER ----------------
//       await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
//       await cutPaper();
//
//       print("✅ KOT print completed successfully!");
//     } catch (e) {
//       print("❌ Error in _printThermalkot: $e");
//       rethrow;
//     }
//   }
//
//   Future<void> printInvoiceToPrinter(
//     Map<String, dynamic> data,
//     String printerMac,
//   ) async {
//     print("🔹 Starting invoice print to: $printerMac");
//
//     try {
//       print("🔄 Attempting to connect to printer: $printerMac");
//       bool connected = await PrintBluetoothThermal.connect(
//         macPrinterAddress: printerMac,
//       );
//       if (!connected) {
//         throw Exception("Failed to connect to printer");
//       }
//       print("✅ Connected successfully!");
//
//       await _printThermalReceipt(data);
//
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("✅ Customer Copy printed successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ Print failed: $e");
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("❌ Print failed: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       rethrow;
//     } finally {
//       try {
//         await PrintBluetoothThermal.disconnect;
//         print("🔌 Disconnected from printer");
//       } catch (e) {
//         print("⚠️ Error during disconnect: $e");
//       }
//     }
//   }
//
//   Future<void> _printThermalReceipt(Map<String, dynamic> data) async {
//     try {
//       final items = data['order'] as List<dynamic>? ?? [];
//       if (items.isEmpty) {
//         print("❌ No items found in order");
//         throw Exception("No items found in order");
//       }
//
//       // ---------------- HEADER TITLE (BIG + BOLD + CENTER) ----------------
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
//
//       // BOLD ON
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
//
//       final vendorName =
//           data['vendorRegisteredName']?.toString().toUpperCase() ?? 'VENDOR';
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: "$vendorName\n"),
//       );
//
//       // Reset to normal
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       // Center divider
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       // ---------------- ORDER DETAILS (BOLD TEXT) ----------------
//
//       // Bold ON (ESC ! 8)
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
//
//       String left1 = "Order ID : ${data['orderId'] ?? 'N/A'}";
//       String right1 = "Date : ${data['date'] ?? ''}";
//
//       String left2 = "Type     : ${formatOrderType(data['orderType'])}";
//       String right2 = "Time : ${data['time'] ?? ''}";
//
//       String left3 = "Payment  : ${formatPaymentMethod(data['paymentMethod'])}";
//       String right3 = "";
//
//       String makeRow(String left, String right, {int totalWidth = 48}) {
//         left = left.trimRight();
//         right = right.trimLeft();
//
//         int spaceCount = totalWidth - left.length - right.length;
//         if (spaceCount < 1) spaceCount = 1;
//
//         return left + (' ' * spaceCount) + right;
//       }
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: makeRow(left1, right1) + "\n"),
//       );
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: makeRow(left2, right2) + "\n"),
//       );
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: makeRow(left3, right3) + "\n"),
//       );
//
//       // Bold OFF
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       // ---------------- ITEMS ----------------
//
//       // Bold ON
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "ITEM                       QTY       TOTAL\n",
//         ),
//       );
//
//       // Bold OFF
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       for (var item in items) {
//         String name = (item['dishName'] ?? 'N/A').toString();
//         if (name.length > 26) name = name.substring(0, 26);
//
//         final qty = item['quantity']?.toString() ?? '0';
//         final price =
//             (item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00';
//
//         final line = name.padRight(28) + qty.padRight(10) + "Rs.$price";
//
//         await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(size: 2, text: "$line\n"),
//         );
//       }
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       // ---------------- SUMMARY ----------------
//
//       double subTotal = (data['subTotal'] ?? 0).toDouble();
//       double cgst = (data['cgst'] ?? 0).toDouble();
//       double sgst = (data['sgst'] ?? 0).toDouble();
//       double grandTotal = (data['grandTotal'] ?? 0).toDouble();
//       double servicecharges = (data['serviceCharge'] ?? 0);
//       double platformCharges = (data['platformCharges'] ?? 0);
//       double packingCharges = (data['packingCharges'] ?? 0);
//
//       await PrintBluetoothThermal.writeBytes(
//         Uint8List.fromList([27, 33, 8]),
//       ); // Bold
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text:
//               "Sub Total:                            Rs.${subTotal.toStringAsFixed(2)}\n",
//         ),
//       );
//       if (data["orderType"] == "DINE_IN")
//         await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(
//             size: 2,
//             text:
//                 "Service Charges:                      Rs.${servicecharges.toStringAsFixed(2)}\n",
//           ),
//         );
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text:
//               "Platform Charges:                     Rs.${platformCharges.toStringAsFixed(2)}\n",
//         ),
//       );
//       if (data["orderType"] == "TAKEAWAY")
//         await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(
//             size: 2,
//             text:
//                 "Packing Charges:                       Rs.${packingCharges.toStringAsFixed(2)}\n",
//           ),
//         );
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text:
//               "SGST:                                 Rs.${sgst.toStringAsFixed(2)}\n",
//         ),
//       );
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text:
//               "CGST:                                 Rs.${cgst.toStringAsFixed(2)}\n",
//         ),
//       );
//
//       // Bold OFF
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       // ---------------- GRAND TOTAL (BOLD + DOUBLE SIZE + CENTER) ----------------
//
//       await PrintBluetoothThermal.writeBytes(
//         Uint8List.fromList([27, 97, 1]),
//       ); // center
//       await PrintBluetoothThermal.writeBytes(
//         Uint8List.fromList([27, 33, 48]),
//       ); // double size + bold
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text:
//               "TOTAL:                                Rs.${grandTotal.toStringAsFixed(2)}\n",
//         ),
//       );
//
//       // Reset formatting
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "------------------------------------------------\n",
//         ),
//       );
//
//       // FSSAI + GST
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "FSSAI: ${data['vendorFssai'] ?? 'N/A'}\n",
//         ),
//       );
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text: "GSTIN: ${data['vendorGstIn'] ?? 'N/A'}\n\n",
//         ),
//       );
//
//       // ---------------- FOOTER (CENTER + BOLD) ----------------
//       await PrintBluetoothThermal.writeBytes(
//         Uint8List.fromList([27, 97, 1]),
//       ); // center
//       await PrintBluetoothThermal.writeBytes(
//         Uint8List.fromList([27, 33, 8]),
//       ); // bold
//
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: "Thank You for Visiting!\n"),
//       );
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(size: 2, text: "Have a nice day!\n\n"),
//       );
//
//       // Reset
//       await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
//
//       // ---------------- CUT PAPER ----------------
//       await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
//       await cutPaper();
//
//       print("✅ Thermal receipt printed successfully!");
//     } catch (e) {
//       print("❌ Error in _printThermalReceipt: $e");
//       rethrow;
//     }
//   }
//
//   Future<void> cutPaper() async {
//     // Feed lines
//     await PrintBluetoothThermal.writeBytes([27, 100, 2]);
//   }
//
//   Future<bool> ensureBluetoothPermissions() async {
//     try {
//       // Check Bluetooth is enabled
//       final bool isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
//       if (!isBluetoothOn) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Bluetooth is not enabled. Please enable Bluetooth to print.',
//             ),
//             duration: Duration(seconds: 3),
//           ),
//         );
//         _showBluetoothPermissionDialog(); // opens your dialog with Open Settings
//         return false;
//       }
//
//       // Request standard Bluetooth permissions only
//       Map<Permission, PermissionStatus> statuses = await [
//         Permission.bluetoothScan,
//         Permission.bluetoothConnect,
//         Permission.bluetoothAdvertise,
//         Permission.locationWhenInUse, // Often needed for classic Bluetooth
//       ].request();
//
//       // Check if any critical permission denied
//       if (statuses[Permission.bluetoothScan]?.isGranted != true ||
//           statuses[Permission.bluetoothConnect]?.isGranted != true) {
//         _showBluetoothPermissionDialog();
//         return false;
//       }
//       return true;
//     } catch (e) {
//       print('Permission check error: $e');
//       return false;
//     }
//   }
//
//   void _showBluetoothPermissionDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Bluetooth Permission Needed'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Nearby Devices permission is OFF'),
//             SizedBox(height: 12.h),
//             Text('Go to Settings > Apps > Your App > Permissions'),
//             Text('Enable "Nearby devices" & "Bluetooth Scan"'),
//             SizedBox(height: 12.h),
//             Text(
//               'Or tap below to open Settings directly',
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//             icon: Icon(Icons.settings),
//             label: Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _loadLocalData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       transactionIdFromPrefs = prefs.getString('razorpay_transaction_id');
//       chargeLabel = prefs.getString('chargeLabel') ?? "Service Charge";
//     });
//   }
//
//   Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
//     final pdf = pw.Document();
//     final List<dynamic> items = data['order'] as List<dynamic>? ?? [];
//
//     final imageBytes = await rootBundle.load('assets/MAAMAAS.jpeg');
//     final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
//     final prefs = await SharedPreferences.getInstance();
//     final transactionIdFromPrefs = prefs.getString('transactionId');
//
//     final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
//     final ttf = pw.Font.ttf(fontData);
//     final orderType = (data['orderType']?.toString().toLowerCase() ?? '');
//
//     pdf.addPage(
//       pw.MultiPage(
//         theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (context) => [
//           // Header
//           pw.Header(
//             level: 0,
//             child: pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Container(width: 70, height: 70, child: pw.Image(image)),
//                 pw.Text(
//                   'Invoice / Bill',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 1 * PdfPageFormat.cm),
//
//           // Order Info
//           pw.Row(
//             crossAxisAlignment: pw.CrossAxisAlignment.end,
//             children: [
//               pw.Spacer(),
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.end,
//                 children: [
//                   pw.Text('Order ID: ${data['orderId'] ?? 'N/A'}'),
//                   pw.Text('User Name: ${data['userName'] ?? 'N/A'}'),
//                   pw.Text('Date: ${data['date'] ?? 'N/A'}'),
//                   pw.Text('Time: ${data['time'] ?? 'N/A'}'),
//                   pw.Text(
//                     'Order Type: ${data['orderType']?.toString().replaceAll('_', ' ') ?? 'N/A'}',
//                   ),
//                   pw.Text(
//                     'Payment Method: ${data['paymentMethod']?.toString().replaceAll('_', ' ') ?? 'N/A'}',
//                   ),
//                   if (data['paymentMethod']?.toString().toLowerCase() ==
//                       "online_payment")
//                     pw.Text(
//                       'Transaction ID: ${data['transactionId'] ?? transactionIdFromPrefs ?? 'N/A'}',
//                     ),
//                   if (data['paymentMethod']?.toString().toLowerCase() ==
//                       "maamaas_wallet")
//                     pw.Text('walletType: ${data['walletTypes'] ?? 'N/A'}'),
//                 ],
//               ),
//             ],
//           ),
//
//           if ((data['location'] ?? '').toString().isNotEmpty)
//             pw.Padding(
//               padding: const pw.EdgeInsets.only(top: 5),
//               child: pw.Text('Location: ${data['location']}'),
//             ),
//
//           pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
//
//           // Ordered Items Table
//           pw.Text(
//             'Ordered Items:',
//             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
//           ),
//           pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
//           pw.TableHelper.fromTextArray(
//             headerStyle: pw.TextStyle(
//               fontWeight: pw.FontWeight.bold,
//               fontSize: 10,
//             ),
//             cellStyle: const pw.TextStyle(fontSize: 9),
//             headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
//             cellAlignment: pw.Alignment.centerLeft,
//             cellAlignments: {
//               0: pw.Alignment.center,
//               2: pw.Alignment.center,
//               3: pw.Alignment.centerRight,
//               4: pw.Alignment.centerRight,
//             },
//             columnWidths: {
//               0: const pw.FixedColumnWidth(30),
//               1: const pw.FlexColumnWidth(3),
//               2: const pw.FixedColumnWidth(40),
//               3: const pw.FlexColumnWidth(1.5),
//               4: const pw.FlexColumnWidth(1.5),
//             },
//             headers: ['S.No', 'Item', 'Qty', 'Price', 'Total'],
//             data: List.generate(items.length, (index) {
//               final item = items[index];
//               return [
//                 (index + 1).toString(),
//                 item['dishName'] ?? 'N/A',
//                 (item['quantity'] ?? 0).toString(),
//                 "₹${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                 "₹${(item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//               ];
//             }),
//           ),
//
//           pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
//
//           // Billing Summary Section
//           pw.Align(
//             alignment: pw.Alignment.centerRight,
//             child: pw.SizedBox(
//               width: 200,
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Billing Summary:',
//                     style: pw.TextStyle(
//                       fontSize: 16,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
//
//                   _buildPdfPriceRow(
//                     'Sub Total:',
//                     "₹${(data['subTotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     isBold: true,
//                   ),
//                   _buildPdfPriceRow(
//                     'SGST:',
//                     "₹${(data['sgst'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                   ),
//                   _buildPdfPriceRow(
//                     'CGST:',
//                     "₹${(data['cgst'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                   ),
//
//                   if ((data['discountAmount'] as num?) != null &&
//                       (data['discountAmount'] as num) > 0)
//                     _buildPdfPriceRow(
//                       'Discount:',
//                       "- ₹${(data['discountAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     ),
//                   _buildPdfPriceRow(
//                     'Service Charge:',
//                     "₹${(data['serviceCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                   ),
//                   // 👇 Conditional charges based on order type
//                   if (orderType == 'dine-in' || orderType == 'dinein')
//                     _buildPdfPriceRow(
//                       'Service Charge:',
//                       "₹${(data['serviceCharge'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     )
//                   else if (orderType == 'takeaway' ||
//                       orderType == 'take away' ||
//                       orderType == 'pickup') ...[
//                     _buildPdfPriceRow(
//                       'Packing Charges:',
//                       "₹${(data['packingCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     ),
//                     _buildPdfPriceRow(
//                       'Platform Charges:',
//                       "₹${(data['platformCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     ),
//                   ] else if (orderType == 'delivery') ...[
//                     _buildPdfPriceRow(
//                       'Packing Charges:',
//                       "₹${(data['packingCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     ),
//                     _buildPdfPriceRow(
//                       'Platform Charges:',
//                       "₹${(data['platformCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     ),
//                     _buildPdfPriceRow(
//                       'Delivery Charge:',
//                       "₹${(data['deliveryCharges'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     ),
//                   ],
//
//                   pw.Divider(color: PdfColors.grey600, height: 10),
//
//                   _buildPdfPriceRow(
//                     'Grand Total:',
//                     "₹${(data['grandTotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                     isBold: true,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           pw.SizedBox(height: 1.5 * PdfPageFormat.cm),
//           pw.Center(
//             child: pw.Text(
//               'Thank you for your order! Visit Again!',
//               style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
//             ),
//           ),
//           pw.Center(
//             child: pw.Text(
//               'Visit Again!',
//               style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   pw.Widget _buildPdfPriceRow(
//     String label,
//     String value, {
//     bool isBold = false,
//   }) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: 10,
//             fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: 10,
//             fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       appBar: AppBar(
//         title: Text(
//           "Invoice",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: Stack(
//         children: [
//           FutureBuilder<Map<String, dynamic>?>(
//             future: food_authservice.fetchOrderById(widget.orderId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(
//                   child: Text(
//                     "Error fetching invoice: ${snapshot.error}",
//                     style: TextStyle(color: theme.colorScheme.error),
//                   ),
//                 );
//               } else if (!snapshot.hasData || snapshot.data == null) {
//                 return const Center(child: Text("No invoice details found."));
//               }
//
//               final data = snapshot.data!;
//               final List<dynamic> items = data['order'] as List<dynamic>? ?? [];
//
//               return SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _buildInvoiceContentCard(context, theme, data, items),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInvoiceContentCard(
//     BuildContext context,
//     ThemeData theme,
//     Map<String, dynamic> data,
//     List<dynamic> items,
//   ) {
//     final cardBackgroundColor = theme.brightness == Brightness.dark
//         ? Colors.grey[800]
//         : Color(0xFFF97316);
//     final onCardColor = Colors.white;
//
//     return Card(
//       elevation: 3,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       color: cardBackgroundColor,
//       child: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Text(
//                 "Order Summary",
//                 style: TextStyle(
//                   color: onCardColor,
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             _buildInfoRow(
//               context,
//               "Order ID:",
//               "${data['orderId'] ?? 'N/A'}",
//               onCardColor: onCardColor,
//             ),
//             _buildInfoRow(
//               context,
//               "Date:",
//               "${data['date'] ?? 'N/A'}",
//               onCardColor: onCardColor,
//             ),
//             _buildInfoRow(
//               context,
//               "Time:",
//               "${data['time'] ?? 'N/A'}",
//               onCardColor: onCardColor,
//             ),
//             _buildInfoRow(
//               context,
//               "Order Type:",
//               (data['orderType'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
//               onCardColor: onCardColor,
//             ),
//             _buildInfoRow(
//               context,
//               "Payment:",
//               (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
//               onCardColor: onCardColor,
//             ),
//             if (data['paymentMethod']?.toString() == "Online_Payment")
//               _buildInfoRow(
//                 context,
//                 "Transaction ID:",
//                 data['transactionId'] ?? transactionIdFromPrefs ?? "N/A",
//                 onCardColor: onCardColor,
//               ),
//             if (data['paymentMethod']?.toString().toLowerCase() ==
//                 "maamaas_wallet")
//               _buildInfoRow(
//                 context,
//                 "walletType:",
//                 data['walletTypes'] ?? "N/A",
//                 onCardColor: onCardColor,
//               ),
//
//             Divider(
//               color: onCardColor.withOpacity(0.4),
//               thickness: 0.8,
//               height: 25.h,
//             ),
//             Text(
//               "Ordered Items",
//               style: TextStyle(
//                 color: onCardColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15.sp,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             _buildItemsTable(context, items, onCardColor),
//
//             SizedBox(height: 15.h),
//             _buildPriceDetails(context, data, onCardColor),
//
//             // =============== CONDITION FOR PRINT BUTTONS ===============
//             SizedBox(height: 20.h),
//             if ((data['orderType']?.toString() ?? '').toUpperCase() ==
//                 'DINE_IN')
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildPrintButton(
//                     context: context,
//                     data: data,
//                     buttonText: 'KOT',
//                     isKOT: true,
//                   ),
//                   _buildPrintButton(
//                     context: context,
//                     data: data,
//                     buttonText: 'Customer Copy',
//                     isKOT: false,
//                   ),
//                 ],
//               )
//             else
//               Center(
//                 child: _buildPrintButton(
//                   context: context,
//                   data: data,
//                   buttonText: 'KOT',
//                   isKOT: true,
//                 ),
//               ),
//             // =============== END OF CONDITION ===============
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPrintButton({
//     required BuildContext context,
//     required Map<String, dynamic> data,
//     required String buttonText,
//     required bool isKOT,
//   }) {
//     return ElevatedButton.icon(
//       onPressed: () async {
//         print("🔹 $buttonText button pressed");
//         print("📊 Order ID: ${widget.orderId}");
//
//         final bool bluetoothOk = await ensureBluetoothPermissions();
//         if (!bluetoothOk) {
//           print("❌ Bluetooth permissions not granted");
//           return;
//         }
//
//         print("✅ Bluetooth permissions granted");
//
//         final data = await food_authservice.fetchOrderById(widget.orderId);
//         if (data == null) {
//           print("❌ Failed to fetch order data");
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Failed to fetch order data'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//           return;
//         }
//
//         print("✅ Order data fetched: ${data.keys}");
//
//         final defaultMac = await getDefaultPrinter();
//         print("📱 Default printer MAC: $defaultMac");
//
//         if (defaultMac != null && defaultMac.isNotEmpty) {
//           try {
//             // Try to connect to default printer
//             print("🔄 Attempting to connect to default printer: $defaultMac");
//             bool connected = await PrintBluetoothThermal.connect(
//               macPrinterAddress: defaultMac,
//             );
//
//             if (connected) {
//               print("✅ Connected to default printer");
//               if (isKOT) {
//                 await printcustomercopyToPrinter(data, defaultMac);
//               } else {
//                 await printInvoiceToPrinter(data, defaultMac);
//               }
//               return;
//             } else {
//               print("❌ Failed to connect to default printer");
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Default printer not reachable. Select printer.',
//                     ),
//                     backgroundColor: Colors.orange,
//                   ),
//                 );
//               }
//             }
//           } catch (e) {
//             print("❌ Print error: $e");
//             if (context.mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Print failed: ${e.toString()}')),
//               );
//             }
//           }
//         }
//
//         // Fallback to printer selection
//         if (context.mounted) {
//           printBillToBluetooth(data);
//         }
//       },
//       icon: Icon(Icons.print),
//       label: Text(buttonText),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 3,
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(
//     BuildContext context,
//     String label,
//     String value, {
//     required Color onCardColor,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 3.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: onCardColor.withOpacity(0.85),
//                 fontSize: 13.sp,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: onCardColor,
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemsTable(
//     BuildContext context,
//     List<dynamic> items,
//     Color onCardColor,
//   ) {
//     final headerStyle = TextStyle(
//       color: onCardColor.withOpacity(0.9),
//       fontSize: 11.sp,
//       fontWeight: FontWeight.bold,
//     );
//     final cellStyle = TextStyle(color: onCardColor, fontSize: 11.sp);
//
//     return Table(
//       columnWidths: {
//         0: IntrinsicColumnWidth(flex: 0.5), // S.No
//         1: FlexColumnWidth(3), // Item Name
//         2: IntrinsicColumnWidth(flex: 1), // Qty
//         3: FlexColumnWidth(1.5), // Price
//         4: FlexColumnWidth(1.5), // Total
//       },
//       children: [
//         TableRow(
//           decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
//           children: [
//             Padding(
//               padding: EdgeInsets.all(8.w),
//               child: Text(
//                 "S.No",
//                 style: headerStyle,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.w),
//               child: Text("Item", style: headerStyle),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.w),
//               child: Text(
//                 "Qty",
//                 style: headerStyle,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.w),
//               child: Text(
//                 "Price",
//                 style: headerStyle,
//                 textAlign: TextAlign.right,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.w),
//               child: Text(
//                 "Total",
//                 style: headerStyle,
//                 textAlign: TextAlign.right,
//               ),
//             ),
//           ],
//         ),
//         ...items.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value as Map<String, dynamic>;
//           return TableRow(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: onCardColor.withOpacity(0.2),
//                   width: 0.5,
//                 ),
//               ),
//             ),
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: Text(
//                   "${index + 1}",
//                   style: cellStyle,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: Text(
//                   item['dishName']?.toString() ?? 'N/A',
//                   style: cellStyle,
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: Text(
//                   (item['quantity'] ?? 0).toString(),
//                   style: cellStyle,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: Text(
//                   "₹${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                   style: cellStyle,
//                   textAlign: TextAlign.right,
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: Text(
//                   "₹${(item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
//                   style: cellStyle,
//                   textAlign: TextAlign.right,
//                 ),
//               ),
//             ],
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildPriceDetails(
//     BuildContext context,
//     Map<String, dynamic> data,
//     Color onCardColor,
//   ) {
//     final orderType = data['orderType']?.toString().toLowerCase() ?? '';
//     final num subTotal = data['subTotal'] ?? 0;
//     final num discount = data['discountAmount'] ?? 0;
//     final num sgst = data['sgst'] ?? 0;
//     final num cgst = data['cgst'] ?? 0;
//     final num platformCharges = data['platformCharges'] ?? 0;
//     final num packingCharges = data['packingCharges'] ?? 0;
//     final num serviceCharges = data['serviceCharge'] ?? 0;
//     final num deliveryCharges = data['deliveryCharges'] ?? 0;
//     final num grandTotal = data['totalAmount'] ?? 0;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         SizedBox(height: 5.h),
//
//         _buildInfoRow(
//           context,
//           "Sub Total:",
//           "₹${subTotal.toStringAsFixed(2)}",
//           onCardColor: onCardColor,
//         ),
//
//         if (sgst > 0)
//           _buildInfoRow(
//             context,
//             "SGST:",
//             "₹${sgst.toStringAsFixed(2)}",
//             onCardColor: onCardColor,
//           ),
//
//         if (cgst > 0)
//           _buildInfoRow(
//             context,
//             "CGST:",
//             "₹${cgst.toStringAsFixed(2)}",
//             onCardColor: onCardColor,
//           ),
//
//         if (discount > 0)
//           _buildInfoRow(
//             context,
//             "Discount:",
//             "-₹${discount.toStringAsFixed(2)}",
//             onCardColor: onCardColor,
//           ),
//
//         if (orderType == 'dine_in' && serviceCharges > 0) ...[
//           _buildInfoRow(
//             context,
//             "Service Charges:",
//             "₹${serviceCharges.toStringAsFixed(2)}",
//             onCardColor: onCardColor,
//           ),
//         ] else if (orderType == 'takeaway' ||
//             orderType == 'take_away' ||
//             orderType == 'pickup') ...[
//           if (packingCharges > 0)
//             _buildInfoRow(
//               context,
//               "Packing Charges:",
//               "₹${packingCharges.toStringAsFixed(2)}",
//               onCardColor: onCardColor,
//             ),
//           if (platformCharges > 0)
//             _buildInfoRow(
//               context,
//               "Platform Charges:",
//               "₹${platformCharges.toStringAsFixed(2)}",
//               onCardColor: onCardColor,
//             ),
//         ] else if (orderType == 'delivery') ...[
//           if (packingCharges > 0)
//             _buildInfoRow(
//               context,
//               "Packing Charges:",
//               "₹${packingCharges.toStringAsFixed(2)}",
//               onCardColor: onCardColor,
//             ),
//           if (platformCharges > 0)
//             _buildInfoRow(
//               context,
//               "Platform Charges:",
//               "₹${platformCharges.toStringAsFixed(2)}",
//               onCardColor: onCardColor,
//             ),
//           if (deliveryCharges > 0)
//             _buildInfoRow(
//               context,
//               "Delivery Charges:",
//               "₹${deliveryCharges.toStringAsFixed(2)}",
//               onCardColor: onCardColor,
//             ),
//         ],
//         Divider(
//           color: onCardColor.withOpacity(0.4),
//           thickness: 0.8,
//           height: 20.h,
//         ),
//
//         _buildInfoRow(
//           context,
//           "Grand Total:",
//           "₹${grandTotal.toStringAsFixed(2)}",
//           onCardColor: onCardColor,
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/food_authservice.dart';
import 'package:pdf/widgets.dart' as pw;

import '../printservice/printservice.dart';

class food_Invoice extends StatefulWidget {
  final int orderId;

  const food_Invoice({super.key, required this.orderId});

  @override
  _InvoiceState createState() => _InvoiceState();
}

class _InvoiceState extends State<food_Invoice> {
  late final int orderId;
  String? transactionIdFromPrefs;
  String chargeLabel = "Service Charge";

  List<BluetoothInfo> pairedDevices = [];
  List<BluetoothInfo> scannedDevices = [];
  String? connectedPrinterMac;
  bool isScanning = false;
  bool isConnected = false;

  static const String kDefaultPrinterKey = 'default_printer_mac';

  // Date formatting function
  String _fmtDate(String raw) {
    try {
      final utc = DateTime.parse(raw);
      final ist = utc.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd MMM yyyy, hh:mm a').format(ist);
    } catch (_) {
      return raw;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    orderId = widget.orderId;
  }

  Future<void> saveDefaultPrinter(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kDefaultPrinterKey, mac);
  }

  Future<String?> getDefaultPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kDefaultPrinterKey);
  }

  Future<void> printBillToBluetooth(Map<String, dynamic> data) async {
    print("🔹 Print button clicked - showing printer selector");

    // Show bottom sheet with printers
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => PrinterBottomSheet(
          controller: scrollController,
          onPrint: (printerMac) => printInvoiceToPrinter(data, printerMac),
          onConnected: (mac) {
            connectedPrinterMac = mac;
            isConnected = true;
          },
          onSetDefault: saveDefaultPrinter,
          parentEnsureBluetoothPermissions: ensureBluetoothPermissions,
          parentShowBluetoothPermissionDialog: _showBluetoothPermissionDialog,
        ),
      ),
    );
  }

  Future<void> printcustomercopyToPrinter(
    Map<String, dynamic> data,
    String printerMac,
  ) async {
    print("🔹 Starting customer copy print to: $printerMac");

    try {
      // Try to connect to printer
      print("🔄 Attempting to connect to printer: $printerMac");
      bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: printerMac,
      );
      if (!connected) {
        throw Exception("Failed to connect to printer");
      }
      print("✅ Connected successfully!");

      await _printThermalkot(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Customer Copy printed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ Print failed: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Print failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    } finally {
      try {
        await PrintBluetoothThermal.disconnect;
        print("🔌 Disconnected from printer");
      } catch (e) {
        print("⚠️ Error during disconnect: $e");
      }
    }
  }

  String formatPaymentMethod(String? method) {
    switch (method) {
      case 'Online_Payment':
        return 'Online Payment';
      case 'Cash':
        return 'Cash';
      case 'Maamaas_Wallet':
        return 'Maamaas Wallet';
      case 'UPI':
        return 'UPI';
      default:
        return method?.replaceAll('_', ' ') ?? '';
    }
  }

  String formatOrderType(String? type) {
    switch (type) {
      case 'TAKEAWAY':
        return 'Take Away';
      case 'DINE_IN':
        return 'Dine In';
      case 'DELIVERY':
        return 'Delivery';
      default:
        return type?.replaceAll('_', ' ') ?? '';
    }
  }

  Future<void> _printThermalkot(Map<String, dynamic> data) async {
    try {
      print("📱 Starting KOT print...");
      print("📊 Data received: ${data.keys}");

      // Check if order data exists
      final items = data['order'] as List<dynamic>? ?? [];
      if (items.isEmpty) {
        print("❌ No items found in order");
        throw Exception("No items found in order");
      }

      print("✅ Items found: ${items.length}");

      // ---------------- HEADER TITLE (BIG + BOLD + CENTER) ----------------
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));

      // BOLD ON
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));

      final vendorName =
          data['vendorRegisteredName']?.toString().toUpperCase() ?? 'VENDOR';
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: "$vendorName\n"),
      );

      // Reset to normal
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      // Center divider
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));

      // Format date and time using _fmtDate
      String formattedDate = _fmtDate(data['date'] ?? '');
      String formattedTime = _fmtDate(data['time'] ?? '');

      String left1 = "Order ID : ${data['orderId'] ?? 'N/A'}";
      String right1 = "Date : $formattedDate";

      String left2 = "Type     : ${formatOrderType(data['orderType'])}";
      String right2 = "Time : $formattedTime";

      String makeRow(String left, String right) {
        int maxWidth = 48;
        int spaces = maxWidth - left.length - right.length;
        if (spaces < 1) spaces = 1;
        return left + (" " * spaces) + right;
      }

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: makeRow(left1, right1) + "\n"),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: makeRow(left2, right2) + "\n"),
      );
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      // ---------------- ITEMS ----------------

      // Bold ON
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "ITEM                       QTY\n",
        ),
      );

      // Bold OFF
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      for (var item in items) {
        String name = (item['dishName'] ?? 'N/A').toString();
        if (name.length > 26) name = name.substring(0, 26);

        final qty = item['quantity']?.toString() ?? '0';

        final line = name.padRight(28) + qty.padRight(10);

        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 2, text: "$line\n"),
        );
      }

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      // ---------------- CUT PAPER ----------------
      await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
      await cutPaper();

      print("✅ KOT print completed successfully!");
    } catch (e) {
      print("❌ Error in _printThermalkot: $e");
      rethrow;
    }
  }

  Future<void> printInvoiceToPrinter(
    Map<String, dynamic> data,
    String printerMac,
  ) async {
    print("🔹 Starting invoice print to: $printerMac");

    try {
      print("🔄 Attempting to connect to printer: $printerMac");
      bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: printerMac,
      );
      if (!connected) {
        throw Exception("Failed to connect to printer");
      }
      print("✅ Connected successfully!");

      await _printThermalReceipt(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Customer Copy printed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ Print failed: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Print failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    } finally {
      try {
        await PrintBluetoothThermal.disconnect;
        print("🔌 Disconnected from printer");
      } catch (e) {
        print("⚠️ Error during disconnect: $e");
      }
    }
  }

  Future<void> _printThermalReceipt(Map<String, dynamic> data) async {
    try {
      final items = data['order'] as List<dynamic>? ?? [];
      if (items.isEmpty) {
        print("❌ No items found in order");
        throw Exception("No items found in order");
      }

      // ---------------- HEADER TITLE (BIG + BOLD + CENTER) ----------------
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));

      // BOLD ON
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));

      final vendorName =
          data['vendorRegisteredName']?.toString().toUpperCase() ?? 'VENDOR';
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: "$vendorName\n"),
      );

      // Reset to normal
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      // Center divider
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      // ---------------- ORDER DETAILS (BOLD TEXT) ----------------

      // Bold ON (ESC ! 8)
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));

      // Format date and time using _fmtDate
      String formattedDate = _fmtDate(data['date'] ?? '');
      String formattedTime = _fmtDate(data['time'] ?? '');

      String left1 = "Order ID : ${data['orderId'] ?? 'N/A'}";
      String right1 = "Date : $formattedDate";

      String left2 = "Type     : ${formatOrderType(data['orderType'])}";
      String right2 = "Time : $formattedTime";

      String left3 = "Payment  : ${formatPaymentMethod(data['paymentMethod'])}";
      String right3 = "";

      String makeRow(String left, String right, {int totalWidth = 48}) {
        left = left.trimRight();
        right = right.trimLeft();

        int spaceCount = totalWidth - left.length - right.length;
        if (spaceCount < 1) spaceCount = 1;

        return left + (' ' * spaceCount) + right;
      }

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: makeRow(left1, right1) + "\n"),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: makeRow(left2, right2) + "\n"),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: makeRow(left3, right3) + "\n"),
      );

      // Bold OFF
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      // ---------------- ITEMS ----------------

      // Bold ON
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "ITEM                       QTY       TOTAL\n",
        ),
      );

      // Bold OFF
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      for (var item in items) {
        String name = (item['dishName'] ?? 'N/A').toString();
        if (name.length > 26) name = name.substring(0, 26);

        final qty = item['quantity']?.toString() ?? '0';
        final price =
            (item['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00';

        final line = name.padRight(28) + qty.padRight(10) + "Rs.$price";

        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 2, text: "$line\n"),
        );
      }

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      // ---------------- SUMMARY ----------------

      double subTotal = (data['subTotal'] ?? 0).toDouble();
      double cgst = (data['cgst'] ?? 0).toDouble();
      double sgst = (data['sgst'] ?? 0).toDouble();
      double grandTotal = (data['grandTotal'] ?? 0).toDouble();
      double servicecharges = (data['serviceCharge'] ?? 0);
      double platformCharges = (data['platformCharges'] ?? 0);
      double packingCharges = (data['packingCharges'] ?? 0);

      await PrintBluetoothThermal.writeBytes(
        Uint8List.fromList([27, 33, 8]),
      ); // Bold

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              "Sub Total:                            Rs.${subTotal.toStringAsFixed(2)}\n",
        ),
      );
      if (data["orderType"] == "DINE_IN")
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(
            size: 2,
            text:
                "Service Charges:                      Rs.${servicecharges.toStringAsFixed(2)}\n",
          ),
        );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              "Platform Charges:                     Rs.${platformCharges.toStringAsFixed(2)}\n",
        ),
      );
      if (data["orderType"] == "TAKEAWAY")
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(
            size: 2,
            text:
                "Packing Charges:                       Rs.${packingCharges.toStringAsFixed(2)}\n",
          ),
        );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              "SGST:                                 Rs.${sgst.toStringAsFixed(2)}\n",
        ),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              "CGST:                                 Rs.${cgst.toStringAsFixed(2)}\n",
        ),
      );

      // Bold OFF
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      // ---------------- GRAND TOTAL (BOLD + DOUBLE SIZE + CENTER) ----------------

      await PrintBluetoothThermal.writeBytes(
        Uint8List.fromList([27, 97, 1]),
      ); // center
      await PrintBluetoothThermal.writeBytes(
        Uint8List.fromList([27, 33, 48]),
      ); // double size + bold

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              "TOTAL:                                Rs.${grandTotal.toStringAsFixed(2)}\n",
        ),
      );

      // Reset formatting
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "------------------------------------------------\n",
        ),
      );

      // FSSAI + GST
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "FSSAI: ${data['vendorFssai'] ?? 'N/A'}\n",
        ),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: "GSTIN: ${data['vendorGstIn'] ?? 'N/A'}\n\n",
        ),
      );

      // ---------------- FOOTER (CENTER + BOLD) ----------------
      await PrintBluetoothThermal.writeBytes(
        Uint8List.fromList([27, 97, 1]),
      ); // center
      await PrintBluetoothThermal.writeBytes(
        Uint8List.fromList([27, 33, 8]),
      ); // bold

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: "Thank You for Visiting!\n"),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: "Have a nice day!\n\n"),
      );

      // Reset
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));

      // ---------------- CUT PAPER ----------------
      await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
      await cutPaper();

      print("✅ Thermal receipt printed successfully!");
    } catch (e) {
      print("❌ Error in _printThermalReceipt: $e");
      rethrow;
    }
  }

  Future<void> cutPaper() async {
    // Feed lines
    await PrintBluetoothThermal.writeBytes([27, 100, 2]);
  }

  Future<bool> ensureBluetoothPermissions() async {
    try {
      // Check Bluetooth is enabled
      final bool isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bluetooth is not enabled. Please enable Bluetooth to print.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        _showBluetoothPermissionDialog(); // opens your dialog with Open Settings
        return false;
      }

      // Request standard Bluetooth permissions only
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse, // Often needed for classic Bluetooth
      ].request();

      // Check if any critical permission denied
      if (statuses[Permission.bluetoothScan]?.isGranted != true ||
          statuses[Permission.bluetoothConnect]?.isGranted != true) {
        _showBluetoothPermissionDialog();
        return false;
      }
      return true;
    } catch (e) {
      print('Permission check error: $e');
      return false;
    }
  }

  void _showBluetoothPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bluetooth Permission Needed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nearby Devices permission is OFF'),
            SizedBox(height: 12.h),
            Text('Go to Settings > Apps > Your App > Permissions'),
            Text('Enable "Nearby devices" & "Bluetooth Scan"'),
            SizedBox(height: 12.h),
            Text(
              'Or tap below to open Settings directly',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            icon: Icon(Icons.settings),
            label: Text('Open Settings'),
          ),
        ],
      ),
    );
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

    final imageBytes = await rootBundle.load('assets/MAAMAAS.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
    final prefs = await SharedPreferences.getInstance();
    final transactionIdFromPrefs = prefs.getString('transactionId');

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final orderType = (data['orderType']?.toString().toLowerCase() ?? '');

    // Format date and time for PDF
    String formattedDate = _fmtDate(data['date'] ?? '');
    String formattedTime = _fmtDate(data['time'] ?? '');

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
                  pw.Text('Date: $formattedDate'),
                  pw.Text('Time: $formattedTime'),
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Invoice",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: food_authservice.fetchOrderById(widget.orderId),
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
              final List<dynamic> items = data['order'] as List<dynamic>? ?? [];

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInvoiceContentCard(context, theme, data, items),
                  ],
                ),
              );
            },
          ),
        ],
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
        : Color(0xFFF97316);
    final onCardColor = Colors.white;

    // Format date and time for display
    String formattedDate = _fmtDate(data['date'] ?? '');
    String formattedTime = _fmtDate(data['time'] ?? '');

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

            // =============== CONDITION FOR PRINT BUTTONS ===============
            SizedBox(height: 20.h),
            if ((data['orderType']?.toString() ?? '').toUpperCase() ==
                'DINE_IN')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPrintButton(
                    context: context,
                    data: data,
                    buttonText: 'KOT',
                    isKOT: true,
                  ),
                  _buildPrintButton(
                    context: context,
                    data: data,
                    buttonText: 'Customer Copy',
                    isKOT: false,
                  ),
                ],
              )
            else
              Center(
                child: _buildPrintButton(
                  context: context,
                  data: data,
                  buttonText: 'KOT',
                  isKOT: true,
                ),
              ),
            // =============== END OF CONDITION ===============
          ],
        ),
      ),
    );
  }

  Widget _buildPrintButton({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String buttonText,
    required bool isKOT,
  }) {
    return ElevatedButton.icon(
      onPressed: () async {
        print("🔹 $buttonText button pressed");
        print("📊 Order ID: ${widget.orderId}");

        final bool bluetoothOk = await ensureBluetoothPermissions();
        if (!bluetoothOk) {
          print("❌ Bluetooth permissions not granted");
          return;
        }

        print("✅ Bluetooth permissions granted");

        final data = await food_authservice.fetchOrderById(widget.orderId);
        if (data == null) {
          print("❌ Failed to fetch order data");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to fetch order data'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        print("✅ Order data fetched: ${data.keys}");

        final defaultMac = await getDefaultPrinter();
        print("📱 Default printer MAC: $defaultMac");

        if (defaultMac != null && defaultMac.isNotEmpty) {
          try {
            // Try to connect to default printer
            print("🔄 Attempting to connect to default printer: $defaultMac");
            bool connected = await PrintBluetoothThermal.connect(
              macPrinterAddress: defaultMac,
            );

            if (connected) {
              print("✅ Connected to default printer");
              if (isKOT) {
                await printcustomercopyToPrinter(data, defaultMac);
              } else {
                await printInvoiceToPrinter(data, defaultMac);
              }
              return;
            } else {
              print("❌ Failed to connect to default printer");
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Default printer not reachable. Select printer.',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } catch (e) {
            print("❌ Print error: $e");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Print failed: ${e.toString()}')),
              );
            }
          }
        }

        // Fallback to printer selection
        if (context.mounted) {
          printBillToBluetooth(data);
        }
      },
      icon: Icon(Icons.print),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  color: onCardColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
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

        if (sgst > 0)
          _buildInfoRow(
            context,
            "SGST:",
            "₹${sgst.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),

        if (cgst > 0)
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

        if (orderType == 'dine_in' && serviceCharges > 0) ...[
          _buildInfoRow(
            context,
            "Service Charges:",
            "₹${serviceCharges.toStringAsFixed(2)}",
            onCardColor: onCardColor,
          ),
        ] else if (orderType == 'takeaway' ||
            orderType == 'take_away' ||
            orderType == 'pickup') ...[
          if (packingCharges > 0)
            _buildInfoRow(
              context,
              "Packing Charges:",
              "₹${packingCharges.toStringAsFixed(2)}",
              onCardColor: onCardColor,
            ),
          if (platformCharges > 0)
            _buildInfoRow(
              context,
              "Platform Charges:",
              "₹${platformCharges.toStringAsFixed(2)}",
              onCardColor: onCardColor,
            ),
        ] else if (orderType == 'delivery') ...[
          if (packingCharges > 0)
            _buildInfoRow(
              context,
              "Packing Charges:",
              "₹${packingCharges.toStringAsFixed(2)}",
              onCardColor: onCardColor,
            ),
          if (platformCharges > 0)
            _buildInfoRow(
              context,
              "Platform Charges:",
              "₹${platformCharges.toStringAsFixed(2)}",
              onCardColor: onCardColor,
            ),
          if (deliveryCharges > 0)
            _buildInfoRow(
              context,
              "Delivery Charges:",
              "₹${deliveryCharges.toStringAsFixed(2)}",
              onCardColor: onCardColor,
            ),
        ],
        Divider(
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
