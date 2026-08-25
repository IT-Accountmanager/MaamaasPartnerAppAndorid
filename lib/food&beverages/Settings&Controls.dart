// import 'dart:convert';
//
// import 'package:dio/dio.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:maamaaspartner/Api/food_authservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Models/food&beverages/add_employee.dart';
// import '../Models/food&beverages/ticket_model.dart';
// import '../Models/food&beverages/timings_model.dart';
// import 'AddEmployee.dart';
//
// class SettingsAndControlsPage extends StatefulWidget {
//   const SettingsAndControlsPage({Key? key}) : super(key: key);
//
//   @override
//   _SettingsAndControlsPageState createState() =>
//       _SettingsAndControlsPageState();
// }
//
// class _SettingsAndControlsPageState extends State<SettingsAndControlsPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<dynamic> vendorTimings = [];
//   List<Ticket> tickets = [];
//   bool isLoadingTickets = false;
//   Map<String, dynamic>? billingSetup;
//   bool isLoadingBilling = false;
//
//   List<dynamic> employees = [];
//   bool isLoadingEmployees = false;
//
//   bool showRaiseTicket = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     fetchBillingSetup();
//     fetchTickets(); // ✅ Fetch tickets on load
//     fetchEmployees();
//   }
//
//   final ignoreFields = [
//     'vendorId',
//     'parentId',
//     'username',
//     'password',
//     'enabled',
//     'accountNonLocked',
//     'accountNonExpired',
//     'credentialsNonExpired',
//     'companyName',
//     'businessVerticals',
//     'registerTime',
//     'city',
//     'role',
//   ];
//
//   Future<void> fetchEmployees() async {
//     setState(() => isLoadingEmployees = true);
//
//     try {
//       final data = await food_authservice.fetchEmployees();
//
//       setState(() {
//         employees = data;
//       });
//     } catch (e) {
//       debugPrint("Error in fetchEmployees UI: $e");
//     } finally {
//       setState(() => isLoadingEmployees = false);
//     }
//   }
//
//   Future<void> fetchBillingSetup() async {
//     setState(() => isLoadingBilling = true);
//     final data = await food_authservice.fetchBillingSetup();
//     if (data != null) {
//       setState(() => billingSetup = data);
//     }
//     setState(() => isLoadingBilling = false);
//   }
//
//   Future<void> fetchTickets() async {
//     setState(() => isLoadingTickets = true);
//     tickets = await food_authservice.fetchTickets(); // call API from service
//     setState(() => isLoadingTickets = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Settings & Controls",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: Column(
//         children: [
//           // TabBar inside body
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               isScrollable: true,
//               // Enables horizontal scrolling
//               labelColor: Colors.blue,
//               // Active tab color
//               unselectedLabelColor: Colors.grey,
//               // Inactive tab color
//               indicatorColor: Colors.blue,
//               // Underline color
//               tabs: const [
//                 Tab(text: "Employee"),
//                 Tab(text: "Vendor Timings"),
//                 Tab(text: "Billing Setup"),
//                 Tab(text: "View Tickets"),
//               ],
//             ),
//           ),
//
//           // Expanded for TabBarView to fill remaining space
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _employeeSection(),
//                 VendorTimingsPage(),
//                 _buildingSetupSection(billingSetup, (updatedBillingSetup) {
//                   setState(() {
//                     billingSetup = updatedBillingSetup;
//                   });
//                 }),
//                 _viewTicketSection(),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: Footer(),
//     );
//   }
//
//   // ✅ EMPLOYEE SECTION
//   Widget _employeeSection() {
//     if (isLoadingEmployees) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Expanded(
//             child: employees.isEmpty
//                 ? const Center(
//                     child: Text(
//                       "No Employees Added Yet",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: employees.length,
//                     itemBuilder: (context, index) {
//                       final emp = employees[index] as Employee;
//
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         color: Colors.grey.shade200,
//                         child: ListTile(
//                           title: Text(
//                             emp.name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 4),
//                               _buildInfoRow("Email", emp.email),
//                               _buildInfoRow("Mobile", emp.mobileNumber),
//                               _buildInfoRow("Role", emp.employeRole.name),
//                               _buildInfoRow(
//                                 "Modules",
//                                 emp.businessModules
//                                     .map((m) => m.name)
//                                     .join(', '),
//                               ),
//                               _buildInfoRow(
//                                 "Verticals",
//                                 emp.businessVerticals
//                                     .map((v) => v.name)
//                                     .join(', '),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AddEmployeePage(),
//                   ),
//                 );
//                 // 👇 Refresh employee list if new one added
//                 if (result == true) food_authservice.fetchEmployees();
//               },
//               icon: const Icon(Icons.add),
//               label: const Text("Add Employee"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 2),
//       child: RichText(
//         text: TextSpan(
//           children: [
//             TextSpan(
//               text: "$label: ",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             TextSpan(
//               text: value,
//               style: const TextStyle(color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildingSetupSection() {
//   //   /// CONTROLLERS
//   //   final TextEditingController serviceChargesController =
//   //   TextEditingController(
//   //     text: billingSetup?['serviceCharges']?.toString() ?? '',
//   //   );
//   //
//   //   /// STATE VALUES (DEFAULTS)
//   //   bool isEditing = false;
//   //   bool isRestaurantOn = true;
//   //
//   //   String? serviceChargesType = billingSetup?['serviceChargesType'];
//   //   String? serviceChargesApply = billingSetup?['serviceChargesApply'];
//   //
//   //   /// ✅ DEFAULT VALUES
//   //   String orderDestination = "Chef";
//   //   String userOrderDestination = "Vendor";
//   //
//   //   return StatefulBuilder(
//   //     builder: (context, setState) {
//   //       /// 🔹 LOAD EXISTING VALUES ONLY ONCE
//   //       if (billingSetup != null) {
//   //         orderDestination =
//   //         billingSetup!['initialOrderStatus'] == "DELIVERED"
//   //             ? "Chef"
//   //             : "Delivery";
//   //
//   //         userOrderDestination =
//   //         billingSetup!['userInitialOrderStatus'] == "HOLD"
//   //             ? "Vendor"
//   //             : "Chef";
//   //       }
//   //
//   //       return Padding(
//   //         padding: const EdgeInsets.all(10),
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.end,
//   //           children: [
//   //             /// 🔘 RESTAURANT TOGGLE
//   //             Row(
//   //               mainAxisAlignment: MainAxisAlignment.end,
//   //               children: [
//   //                 const Text(
//   //                   "Restaurant",
//   //                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//   //                 ),
//   //                 const SizedBox(width: 8),
//   //                 Text(
//   //                   isRestaurantOn ? "ON" : "OFF",
//   //                   style: TextStyle(
//   //                     fontSize: 13,
//   //                     fontWeight: FontWeight.bold,
//   //                     color: isRestaurantOn ? Colors.green : Colors.red,
//   //                   ),
//   //                 ),
//   //                 const SizedBox(width: 6),
//   //                 Switch(
//   //                   value: isRestaurantOn,
//   //                   onChanged: (value) {
//   //                     setState(() => isRestaurantOn = value);
//   //                   },
//   //                 ),
//   //               ],
//   //             ),
//   //
//   //             const SizedBox(height: 6),
//   //
//   //             /// ⬇️ SERVICE CHARGES CARD
//   //             Card(
//   //               elevation: 2,
//   //               child: Padding(
//   //                 padding: const EdgeInsets.all(10),
//   //                 child: Column(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     /// HEADER
//   //                     Row(
//   //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                       children: [
//   //                         const Text(
//   //                           "Service Charges Setup",
//   //                           style: TextStyle(
//   //                               fontSize: 16, fontWeight: FontWeight.bold),
//   //                         ),
//   //                         if (billingSetup != null)
//   //                           IconButton(
//   //                             icon: Icon(
//   //                               isEditing ? Icons.cancel : Icons.edit,
//   //                               color: Colors.deepPurple,
//   //                             ),
//   //                             onPressed: () {
//   //                               setState(() {
//   //                                 isEditing = !isEditing;
//   //                               });
//   //                             },
//   //                           ),
//   //                       ],
//   //                     ),
//   //
//   //                     const SizedBox(height: 10),
//   //
//   //                     /// SERVICE CHARGES
//   //                     TextField(
//   //                       controller: serviceChargesController,
//   //                       enabled: isEditing || billingSetup == null,
//   //                       keyboardType: TextInputType.number,
//   //                       decoration: const InputDecoration(
//   //                         border: OutlineInputBorder(),
//   //                         labelText: "Service Charges (0-100)",
//   //                       ),
//   //                     ),
//   //
//   //                     const SizedBox(height: 10),
//   //
//   //                     /// SERVICE CHARGES APPLY
//   //                     DropdownButtonFormField<String>(
//   //                       value: serviceChargesApply,
//   //                       decoration: const InputDecoration(
//   //                         border: OutlineInputBorder(),
//   //                         labelText: "Service Charges Apply",
//   //                       ),
//   //                       items: const [
//   //                         DropdownMenuItem(
//   //                           value: "Applicable",
//   //                           child: Text("Applicable"),
//   //                         ),
//   //                         DropdownMenuItem(
//   //                           value: "Not_Applicable",
//   //                           child: Text("Not Applicable"),
//   //                         ),
//   //                       ],
//   //                       onChanged: (isEditing || billingSetup == null)
//   //                           ? (v) => setState(() => serviceChargesApply = v)
//   //                           : null,
//   //                     ),
//   //
//   //                     const SizedBox(height: 10),
//   //
//   //                     /// SERVICE CHARGES TYPE
//   //                     DropdownButtonFormField<String>(
//   //                       value: serviceChargesType,
//   //                       decoration: const InputDecoration(
//   //                         border: OutlineInputBorder(),
//   //                         labelText: "Service Charges Type",
//   //                       ),
//   //                       items: const [
//   //                         DropdownMenuItem(
//   //                           value: "CUSTOMER_PAYABLE",
//   //                           child: Text("Customer Payable"),
//   //                         ),
//   //                         DropdownMenuItem(
//   //                           value: "BUSINESS_BORNE",
//   //                           child: Text("Business Borne"),
//   //                         ),
//   //                       ],
//   //                       onChanged: (isEditing || billingSetup == null)
//   //                           ? (v) => setState(() => serviceChargesType = v)
//   //                           : null,
//   //                     ),
//   //
//   //                     const SizedBox(height: 10),
//   //
//   //                     /// ✅ SEND ORDER TO (DEFAULT: CHEF)
//   //                     DropdownButtonFormField<String>(
//   //                       value: orderDestination,
//   //                       decoration: const InputDecoration(
//   //                         border: OutlineInputBorder(),
//   //                         labelText: "Send Order To",
//   //                       ),
//   //                       items: const [
//   //                         DropdownMenuItem(
//   //                           value: "Chef",
//   //                           child: Text("Chef"),
//   //                         ),
//   //                         DropdownMenuItem(
//   //                           value: "Delivery",
//   //                           child: Text("Delivery"),
//   //                         ),
//   //                       ],
//   //                       onChanged: (isEditing || billingSetup == null)
//   //                           ? (v) =>
//   //                           setState(() => orderDestination = v!)
//   //                           : null,
//   //                     ),
//   //
//   //                     const SizedBox(height: 10),
//   //
//   //                     /// ✅ SEND USERS ORDERS TO (DEFAULT: VENDOR)
//   //                     DropdownButtonFormField<String>(
//   //                       value: userOrderDestination,
//   //                       decoration: const InputDecoration(
//   //                         border: OutlineInputBorder(),
//   //                         labelText: "Send Users Orders To",
//   //                       ),
//   //                       items: const [
//   //                         DropdownMenuItem(
//   //                           value: "Vendor",
//   //                           child: Text("Vendor"),
//   //                         ),
//   //                         DropdownMenuItem(
//   //                           value: "Chef",
//   //                           child: Text("Chef"),
//   //                         ),
//   //                       ],
//   //                       onChanged: (isEditing || billingSetup == null)
//   //                           ? (v) => setState(
//   //                               () => userOrderDestination = v!)
//   //                           : null,
//   //                     ),
//   //
//   //                     const SizedBox(height: 20),
//   //
//   //                     /// SUBMIT BUTTON
//   //                     Center(
//   //                       child: ElevatedButton(
//   //                         onPressed: () {
//   //                           // SAVE / UPDATE LOGIC
//   //                         },
//   //                         child:
//   //                         Text(billingSetup == null ? "Save" : "Update"),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//   Widget _buildingSetupSection(
//     Map<String, dynamic>? billingSetup,
//     void Function(Map<String, dynamic>) onUpdated,
//   ) {
//     final TextEditingController serviceChargesController =
//         TextEditingController(
//           text: billingSetup?['serviceCharges']?.toString() ?? '',
//         );
//
//     bool isEditing = false;
//     bool isRestaurantOn = true;
//
//     String? serviceChargesType = billingSetup?['serviceChargesType'];
//     String? serviceChargesApply = billingSetup?['serviceChargesApply'];
//
//     String orderDestination = "Chef";
//     String userOrderDestination = "Vendor";
//
//     return StatefulBuilder(
//       builder: (context, setState) {
//         // Load initial values only once
//         if (billingSetup != null) {
//           orderDestination = billingSetup!['initialOrderStatus'] == "DELIVERED"
//               ? "Chef"
//               : "Delivery";
//
//           userOrderDestination =
//               billingSetup!['userInitialOrderStatus'] == "HOLD"
//               ? "Vendor"
//               : "Chef";
//         }
//
//         return Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               // RESTAURANT TOGGLE
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text(
//                     "Restaurant",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     isRestaurantOn ? "ON" : "OFF",
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: isRestaurantOn ? Colors.green : Colors.red,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Switch(
//                     value: isRestaurantOn,
//                     onChanged: (value) {
//                       setState(() => isRestaurantOn = value);
//                     },
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 6),
//
//               // SERVICE CHARGES CARD
//               Card(
//                 elevation: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // HEADER
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Service Charges Setup",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (billingSetup != null)
//                             IconButton(
//                               icon: Icon(
//                                 isEditing ? Icons.cancel : Icons.edit,
//                                 color: Colors.deepPurple,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   isEditing = !isEditing;
//                                 });
//                               },
//                             ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // SERVICE CHARGES INPUT
//                       TextField(
//                         controller: serviceChargesController,
//                         enabled: isEditing || billingSetup == null,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: "Service Charges (0-100)",
//                         ),
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // SERVICE CHARGES APPLY
//                       DropdownButtonFormField<String>(
//                         value: serviceChargesApply,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: "Service Charges Apply",
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                             value: "Applicable",
//                             child: Text("Applicable"),
//                           ),
//                           DropdownMenuItem(
//                             value: "Not_Applicable",
//                             child: Text("Not Applicable"),
//                           ),
//                         ],
//                         onChanged: (isEditing || billingSetup == null)
//                             ? (v) => setState(() => serviceChargesApply = v)
//                             : null,
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // SERVICE CHARGES TYPE
//                       DropdownButtonFormField<String>(
//                         value: serviceChargesType,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: "Service Charges Type",
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                             value: "CUSTOMER_PAYABLE",
//                             child: Text("Customer Payable"),
//                           ),
//                           DropdownMenuItem(
//                             value: "BUSINESS_BORNE",
//                             child: Text("Business Borne"),
//                           ),
//                         ],
//                         onChanged: (isEditing || billingSetup == null)
//                             ? (v) => setState(() => serviceChargesType = v)
//                             : null,
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // SEND ORDER TO
//                       DropdownButtonFormField<String>(
//                         value: orderDestination,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: "Send Order To",
//                         ),
//                         items: const [
//                           DropdownMenuItem(value: "Chef", child: Text("Chef")),
//                           DropdownMenuItem(
//                             value: "Delivery",
//                             child: Text("Delivery"),
//                           ),
//                         ],
//                         onChanged: (isEditing || billingSetup == null)
//                             ? (v) => setState(() => orderDestination = v!)
//                             : null,
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // SEND USERS ORDERS TO
//                       DropdownButtonFormField<String>(
//                         value: userOrderDestination,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: "Send Users Orders To",
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                             value: "Vendor",
//                             child: Text("Vendor"),
//                           ),
//                           DropdownMenuItem(value: "Chef", child: Text("Chef")),
//                         ],
//                         onChanged: (isEditing || billingSetup == null)
//                             ? (v) => setState(() => userOrderDestination = v!)
//                             : null,
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // SUBMIT BUTTON
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final serviceCharges =
//                                 double.tryParse(
//                                   serviceChargesController.text,
//                                 ) ??
//                                 0;
//
//                             try {
//                               if (billingSetup == null) {
//                                 // ADD NEW SETUP
//                                 await food_authservice.addBillingSetup(
//                                   serviceCharges: serviceCharges,
//                                   serviceChargesType:
//                                       serviceChargesType ?? "CUSTOMER_PAYABLE",
//                                   serviceChargesApply:
//                                       serviceChargesApply ?? "Applicable",
//                                   platformChargeType: "FIXED",
//                                   initialOrderStatus: orderDestination,
//                                   userOrderDestination: userOrderDestination,
//                                 );
//
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                       "Billing setup saved successfully!",
//                                     ),
//                                   ),
//                                 );
//                               } else {
//                                 // UPDATE EXISTING SETUP
//                                 await food_authservice.updateBillingSetup(
//                                   id: billingSetup!['id'],
//                                   serviceCharges: serviceCharges,
//                                   serviceChargesType:
//                                       serviceChargesType ?? "CUSTOMER_PAYABLE",
//                                   serviceChargesApply:
//                                       serviceChargesApply ?? "Applicable",
//                                   platformChargeType: "FIXED",
//                                   vendorId: billingSetup!['vendorId'],
//                                   orderDestination: orderDestination,
//                                   userOrderDestination: userOrderDestination,
//                                 );
//
//                                 // Exit edit mode
//                                 setState(() {
//                                   isEditing = false;
//                                 });
//
//                                 // Update local billingSetup to reflect changes in UI
//                                 final updatedBillingSetup = {
//                                   ...billingSetup!,
//                                   "serviceCharges": serviceCharges,
//                                   "serviceChargesType": serviceChargesType,
//                                   "serviceChargesApply": serviceChargesApply,
//                                   "initialOrderStatus":
//                                       orderDestination == "Chef"
//                                       ? "DELIVERED"
//                                       : "CONFIRMED",
//                                   "userInitialOrderStatus":
//                                       userOrderDestination == "Vendor"
//                                       ? "HOLD"
//                                       : "CONFIRMED",
//                                 };
//
//                                 // Notify parent widget
//                                 onUpdated(updatedBillingSetup);
//
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                       "Billing setup updated successfully!",
//                                     ),
//                                   ),
//                                 );
//                               }
//                             } catch (e) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     "Update failed: ${e.toString()}",
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                           child: Text(billingSetup == null ? "Save" : "Update"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _viewTicketSection() {
//     return Scaffold(
//       body: Padding(padding: const EdgeInsets.all(16.0), child: _ticketList()),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton.icon(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     Raise_ticket(), // make sure this is a valid widget
//               ),
//             );
//           },
//           icon: const Icon(Icons.add),
//           label: Text(showRaiseTicket ? "Close Ticket Form" : "Raise Ticket"),
//         ),
//       ),
//     );
//   }
//
//   Widget _ticketList() {
//     if (isLoadingTickets) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (tickets.isEmpty) {
//       return const Center(child: Text("No tickets found"));
//     }
//     return Expanded(
//       child: ListView.builder(
//         itemCount: tickets.length,
//         itemBuilder: (context, index) {
//           final ticket = tickets[index];
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 6),
//             child: ListTile(
//               title: Text("Ticket Type:${ticket.ticketType}"),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(ticket.message ?? ""),
//                   Text("Status: ${ticket.status ?? "Unknown"}"),
//                   Text("Created At: ${ticket.createdAt ?? "-"}"),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class VendorTimingsPage extends StatefulWidget {
//   const VendorTimingsPage({super.key});
//
//   @override
//   State<VendorTimingsPage> createState() => _VendorTimingsPageState();
// }
//
// class _VendorTimingsPageState extends State<VendorTimingsPage> {
//   List<Timing> vendorTimings = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchVendorTimings();
//   }
//
//   Future<void> fetchVendorTimings() async {
//     final List<Timing> data = await food_authservice.fetchVendorTimings();
//     setState(() {
//       vendorTimings = data.map((t) {
//         return Timing(
//           id: t.id,
//           day: t.day,
//           startTime: t.startTime,
//           lastTime: t.lastTime.isEmpty || t.lastTime == "null"
//               ? "--:--"
//               : t.lastTime,
//         );
//       }).toList();
//     });
//   }
//
//   // ===== Add Timing Slot =====
//   Future<void> _addNewTimingSlot(String day) async {
//     final openTime = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 9, minute: 0),
//     );
//     if (openTime == null) return;
//
//     final closeTime = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 18, minute: 0),
//     );
//     if (closeTime == null) return;
//
//     final startTime =
//         "${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}:00";
//     final lastTime =
//         "${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}:00";
//
//     await food_authservice.addVendorTiming(
//       day: day,
//       startTime: startTime,
//       lastTime: lastTime,
//     );
//
//     // Refresh the list
//     await fetchVendorTimings();
//   }
//
//   // ===== Edit Open Time =====
//   Future<void> _selectOpenTime(Timing timing) async {
//     final initialTime = _parseTimeString(timing.startTime);
//     final selectedTime = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//     );
//
//     if (selectedTime != null) {
//       final updatedStartTime =
//           "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";
//
//       await food_authservice.editVendorTiming(
//         id: timing.id,
//         day: timing.day,
//         startTime: updatedStartTime,
//         lastTime: timing.lastTime == "--:--" ? "23:59:00" : timing.lastTime,
//       );
//
//       setState(() {
//         timing.startTime = updatedStartTime;
//       });
//
//       // Refresh to get updated data from backend
//       await fetchVendorTimings();
//     }
//   }
//
//   // ===== Edit Close Time =====
//   Future<void> _selectCloseTime(Timing timing) async {
//     final initialTime = timing.lastTime == "--:--"
//         ? const TimeOfDay(hour: 23, minute: 59)
//         : _parseTimeString(timing.lastTime);
//
//     final selectedTime = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//     );
//
//     if (selectedTime != null) {
//       final updatedLastTime =
//           "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";
//
//       await food_authservice.editVendorTiming(
//         id: timing.id,
//         day: timing.day,
//         startTime: timing.startTime,
//         lastTime: updatedLastTime,
//       );
//
//       setState(() {
//         timing.lastTime = updatedLastTime;
//       });
//
//       // Refresh to get updated data from backend
//       await fetchVendorTimings();
//     }
//   }
//
//   // ===== Delete Timing Slot =====
//   Future<void> _deleteTimingSlot(Timing timing) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.warning, color: Colors.orange),
//             SizedBox(width: 8),
//             Text("Delete Timing Slot"),
//           ],
//         ),
//         content: const Text(
//           "Are you sure you want to delete this timing slot?",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       await food_authservice.deleteVendorTiming(timing.id);
//       await fetchVendorTimings();
//     }
//   }
//
//   TimeOfDay _parseTimeString(String timeStr) {
//     try {
//       if (timeStr.isEmpty || timeStr == "--:--" || timeStr == "null") {
//         return const TimeOfDay(hour: 9, minute: 0);
//       }
//       final cleanTime = timeStr.replaceAll(RegExp(r'[^0-9:]'), '');
//       final parts = cleanTime.split(':');
//       if (parts.length >= 2) {
//         return TimeOfDay(
//           hour: int.parse(parts[0]),
//           minute: int.parse(parts[1]),
//         );
//       }
//       return const TimeOfDay(hour: 9, minute: 0);
//     } catch (_) {
//       return const TimeOfDay(hour: 9, minute: 0);
//     }
//   }
//
//   String _formatTime(String timeStr) {
//     if (timeStr.isEmpty ||
//         timeStr.toLowerCase() == 'null' ||
//         timeStr == "--:--") {
//       return "--:--";
//     }
//
//     try {
//       // Remove seconds if present
//       final parts = timeStr.split(':');
//       if (parts.length >= 2) {
//         final hour = int.parse(parts[0]);
//         final minute = int.parse(parts[1]);
//         return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
//       }
//       return timeStr;
//     } catch (_) {
//       return "--:--";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final daysOfWeek = [
//       "Monday",
//       "Tuesday",
//       "Wednesday",
//       "Thursday",
//       "Friday",
//       "Saturday",
//       "Sunday",
//     ];
//
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: fetchVendorTimings,
//                 child: ListView(
//                   children: [for (final day in daysOfWeek) _buildDayCard(day)],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDayCard(String day) {
//     final dayTimings = vendorTimings
//         .where((t) => t.day.toLowerCase() == day.toLowerCase())
//         .toList();
//
//     final hasSlot = dayTimings.isNotEmpty;
//
//     return Card(
//       color: Colors.grey.shade200,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   (day == "Saturday" || day == "Sunday")
//                       ? Icons.weekend
//                       : Icons.calendar_today,
//                   color: Colors.deepPurple,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (!hasSlot)
//               Column(
//                 children: const [
//                   Icon(Icons.access_time, size: 40, color: Colors.grey),
//                   SizedBox(height: 8),
//                   Text(
//                     "No timing set for this day",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   SizedBox(height: 16),
//                 ],
//               ),
//             if (hasSlot)
//               ...dayTimings
//                   .map(
//                     (timing) => Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade50,
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: const Text(
//                                   "Slot",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.blue,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               const Spacer(),
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.delete_outline,
//                                   size: 20,
//                                 ),
//                                 color: Colors.red,
//                                 onPressed: () => _deleteTimingSlot(timing),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: InkWell(
//                                   onTap: () => _selectOpenTime(timing),
//                                   child: _timeBox(
//                                     "Open Time",
//                                     _formatTime(timing.startTime),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: InkWell(
//                                   onTap: () => _selectCloseTime(timing),
//                                   child: _timeBox(
//                                     "Close Time",
//                                     _formatTime(timing.lastTime),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                   .toList(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: hasSlot ? null : () => _addNewTimingSlot(day),
//                 icon: const Icon(Icons.add, size: 20),
//                 label: const Text("Add Timing"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: hasSlot
//                       ? Colors.grey.shade300
//                       : Colors.white,
//                   foregroundColor: hasSlot
//                       ? Colors.grey.shade600
//                       : Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                       color: hasSlot
//                           ? Colors.grey.shade400
//                           : Colors.deepPurple.shade200,
//                     ),
//                   ),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _timeBox(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.white,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const Icon(Icons.access_time, size: 18, color: Colors.grey),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class Raise_ticket extends StatefulWidget {
//   const Raise_ticket({super.key});
//
//   @override
//   State<Raise_ticket> createState() => _Raise_ticketState();
// }
//
// class _Raise_ticketState extends State<Raise_ticket> {
//   TextEditingController message = TextEditingController();
//   String? ticketTypeLabel;
//
//   bool _isLoading = false;
//
//   final Map<String, String> ticketTypeMap = {
//     "Delivery Issue": "ORDER_COMPLAINT",
//     "Payment Problem": "PAYOUT_ISSUE",
//     "Wrong Order": "ORDER_COMPLAINT",
//     "Service Quality": "TECHNICAL_SUPPORT",
//     "Other": "OTHER",
//   };
//
//   Future<void> submitTicket() async {
//     if (message.text.isEmpty || ticketTypeLabel == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     bool success = await food_authservice.submitTicket(
//       ticketType: ticketTypeMap[ticketTypeLabel!]!, // map label → enum value
//       message: message.text,
//     );
//
//     setState(() {
//       _isLoading = false;
//     });
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Ticket submitted successfully")),
//       );
//
//       // Reset form (optional, since we're popping)
//       setState(() {
//         ticketTypeLabel = null;
//       });
//       message.clear();
//
//       // Close the screen
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Failed to submit ticket")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Raise a Ticket")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("Ticket Type"),
//               DropdownButton<String>(
//                 isExpanded: true,
//                 value: ticketTypeLabel,
//                 hint: const Text("Select Ticket Type"),
//                 items: ticketTypeMap.keys
//                     .map(
//                       (label) =>
//                           DropdownMenuItem(value: label, child: Text(label)),
//                     )
//                     .toList(),
//                 onChanged: (v) => setState(() => ticketTypeLabel = v),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: message,
//                 maxLines: 2,
//                 decoration: const InputDecoration(
//                   labelText: 'Message',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 80),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           onPressed: _isLoading ? null : submitTicket,
//           child: _isLoading
//               ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//               : const Text("Submit Ticket"),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maamaaspartner/Api/food_authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/food&beverages/add_employee.dart';
import '../Models/food&beverages/ticket_model.dart';
import '../Models/food&beverages/timings_model.dart';
import 'AddEmployee.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const blue = Color(0xFFE66D33);
  static const blueLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x14000000);
}

// ─── SettingsAndControlsPage ──────────────────────────────────────────────────
class SettingsAndControlsPage extends StatefulWidget {
  const SettingsAndControlsPage({Key? key}) : super(key: key);
  @override
  _SettingsAndControlsPageState createState() =>
      _SettingsAndControlsPageState();
}

class _SettingsAndControlsPageState extends State<SettingsAndControlsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Ticket> tickets = [];
  bool isLoadingTickets = false;
  Map<String, dynamic>? billingSetup;
  bool isLoadingBilling = false;
  List<dynamic> employees = [];
  bool isLoadingEmployees = false;
  bool showRaiseTicket = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchBillingSetup();
    fetchTickets();
    fetchEmployees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchEmployees() async {
    setState(() => isLoadingEmployees = true);
    try {
      final data = await food_authservice.fetchEmployees();
      setState(() => employees = data);
    } catch (e) {
      debugPrint('Error fetching employees: $e');
    } finally {
      setState(() => isLoadingEmployees = false);
    }
  }

  Future<void> fetchBillingSetup() async {
    setState(() => isLoadingBilling = true);
    final data = await food_authservice.fetchBillingSetup();
    if (data != null) setState(() => billingSetup = data);
    setState(() => isLoadingBilling = false);
  }

  Future<void> fetchTickets() async {
    setState(() => isLoadingTickets = true);
    tickets = await food_authservice.fetchTickets();
    setState(() => isLoadingTickets = false);
  }

  void _snack(String msg, Color color) {
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

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _employeeSection(),
                  const VendorTimingsPage(),
                  _buildingSetupSection(billingSetup, (updated) {
                    setState(() => billingSetup = updated);
                  }),
                  _viewTicketSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: _C.white,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _C.text1,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings & Controls',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _C.text1,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = [
      {'label': 'Employee', 'icon': Icons.people_rounded},
      {'label': 'Timings', 'icon': Icons.schedule_rounded},
      {'label': 'Billing', 'icon': Icons.receipt_long_rounded},
      {'label': 'Tickets', 'icon': Icons.support_agent_rounded},
    ];

    return Container(
      color: _C.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: _C.accent,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: _C.accent,
            unselectedLabelColor: _C.text2,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: tabs
                .map(
                  (t) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t['icon'] as IconData, size: 14),
                        const SizedBox(width: 5),
                        Text(t['label'] as String),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(color: _C.border, height: 1),
        ],
      ),
    );
  }

  // ── Employee Section ──────────────────────────────────────────────────────────
  Widget _employeeSection() {
    if (isLoadingEmployees) {
      return const Center(
        child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
      );
    }

    return Column(
      children: [
        Expanded(
          child: employees.isEmpty
              ? _emptyState(
                  Icons.people_outline_rounded,
                  'No Employees Yet',
                  'Add your first employee below',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  itemCount: employees.length,
                  itemBuilder: (_, i) {
                    final emp = employees[i] as Employee;
                    return _employeeCard(emp);
                  },
                ),
        ),
        _bottomActionBar(
          label: 'Add Employee',
          icon: Icons.person_add_rounded,
          color: _C.accent,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEmployeePage()),
            );
            if (result == true) fetchEmployees();
          },
        ),
      ],
    );
  }

  Widget _employeeCard(Employee emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
        boxShadow: [
          const BoxShadow(
            color: _C.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_C.accent, _C.accentDark],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.text1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emp.email,
                    style: const TextStyle(fontSize: 12, color: _C.text2),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _chip(emp.employeRole.name, _C.accent, _C.accentLight),
                      _chip(emp.mobileNumber, _C.blue, _C.blueLight),
                    ],
                  ),
                  if (emp.businessModules.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: emp.businessModules
                          .map((m) => _chip(m.name, _C.purple, _C.purpleLight))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Billing Setup Section ─────────────────────────────────────────────────────
  Widget _buildingSetupSection(
    Map<String, dynamic>? billingSetup,
    void Function(Map<String, dynamic>) onUpdated,
  ) {
    final serviceChargesController = TextEditingController(
      text: billingSetup?['serviceCharges']?.toString() ?? '',
    );
    bool isEditing = false;
    bool isRestaurantOn = true;
    String? serviceChargesType = billingSetup?['serviceChargesType'];
    String? serviceChargesApply = billingSetup?['serviceChargesApply'];
    String orderDestination = 'Chef';
    String userOrderDestination = 'Vendor';

    return StatefulBuilder(
      builder: (context, setS) {
        if (billingSetup != null) {
          orderDestination = billingSetup!['initialOrderStatus'] == 'DELIVERED'
              ? 'Chef'
              : 'Delivery';
          userOrderDestination =
              billingSetup!['userInitialOrderStatus'] == 'HOLD'
              ? 'Vendor'
              : 'Chef';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Restaurant toggle card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.border),
                  boxShadow: [
                    const BoxShadow(
                      color: _C.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isRestaurantOn ? _C.greenLight : _C.redLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: isRestaurantOn ? _C.green : _C.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Restaurant Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _C.text1,
                            ),
                          ),
                          Text(
                            'Toggle your restaurant availability',
                            style: TextStyle(fontSize: 11, color: _C.text2),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setS(() => isRestaurantOn = !isRestaurantOn),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isRestaurantOn ? _C.green : _C.border,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: isRestaurantOn
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 3,
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

              const SizedBox(height: 14),

              // Service charges card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.border),
                  boxShadow: [
                    const BoxShadow(
                      color: _C.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _C.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: _C.accent,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Service Charges Setup',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _C.text1,
                            ),
                          ),
                        ),
                        if (billingSetup != null)
                          GestureDetector(
                            onTap: () => setS(() => isEditing = !isEditing),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isEditing ? _C.redLight : _C.accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isEditing
                                    ? Icons.close_rounded
                                    : Icons.edit_rounded,
                                color: isEditing ? _C.red : _C.accent,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _formField(
                      label: 'Service Charges (0–100)',
                      child: TextField(
                        controller: serviceChargesController,
                        enabled: isEditing || billingSetup == null,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _C.text1,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _formField(
                      label: 'Service Charges Apply',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: serviceChargesApply,
                          isExpanded: true,
                          hint: const Text(
                            'Select...',
                            style: TextStyle(fontSize: 13, color: _C.text3),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: _C.text1,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (isEditing || billingSetup == null)
                              ? (v) => setS(() => serviceChargesApply = v)
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'Applicable',
                              child: Text('Applicable'),
                            ),
                            DropdownMenuItem(
                              value: 'Not_Applicable',
                              child: Text('Not Applicable'),
                            ),
                          ],
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _formField(
                      label: 'Service Charges Type',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: serviceChargesType,
                          isExpanded: true,
                          hint: const Text(
                            'Select...',
                            style: TextStyle(fontSize: 13, color: _C.text3),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: _C.text1,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (isEditing || billingSetup == null)
                              ? (v) => setS(() => serviceChargesType = v)
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'CUSTOMER_PAYABLE',
                              child: Text('Customer Payable'),
                            ),
                            DropdownMenuItem(
                              value: 'BUSINESS_BORNE',
                              child: Text('Business Borne'),
                            ),
                          ],
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _formField(
                      label: 'Send Order To',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: orderDestination,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _C.text1,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (isEditing || billingSetup == null)
                              ? (v) => setS(() => orderDestination = v!)
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'Chef',
                              child: Text('Chef'),
                            ),
                            DropdownMenuItem(
                              value: 'Delivery',
                              child: Text('Delivery'),
                            ),
                          ],
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _formField(
                      label: 'Send Users Orders To',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: userOrderDestination,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _C.text1,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (isEditing || billingSetup == null)
                              ? (v) => setS(() => userOrderDestination = v!)
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'Vendor',
                              child: Text('Vendor'),
                            ),
                            DropdownMenuItem(
                              value: 'Chef',
                              child: Text('Chef'),
                            ),
                          ],
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: () async {
                        final serviceCharges =
                            double.tryParse(serviceChargesController.text) ?? 0;
                        try {
                          if (billingSetup == null) {
                            await food_authservice.addBillingSetup(
                              serviceCharges: serviceCharges,
                              serviceChargesType:
                                  serviceChargesType ?? 'CUSTOMER_PAYABLE',
                              serviceChargesApply:
                                  serviceChargesApply ?? 'Applicable',
                              platformChargeType: 'FIXED',
                              initialOrderStatus: orderDestination,
                              userOrderDestination: userOrderDestination,
                            );
                            _snack('Billing setup saved!', _C.green);
                          } else {
                            await food_authservice.updateBillingSetup(
                              id: billingSetup!['id'],
                              serviceCharges: serviceCharges,
                              serviceChargesType:
                                  serviceChargesType ?? 'CUSTOMER_PAYABLE',
                              serviceChargesApply:
                                  serviceChargesApply ?? 'Applicable',
                              platformChargeType: 'FIXED',
                              vendorId: billingSetup!['vendorId'],
                              orderDestination: orderDestination,
                              userOrderDestination: userOrderDestination,
                            );
                            setS(() => isEditing = false);
                            final updated = {
                              ...billingSetup!,
                              'serviceCharges': serviceCharges,
                              'serviceChargesType': serviceChargesType,
                              'serviceChargesApply': serviceChargesApply,
                              'initialOrderStatus': orderDestination == 'Chef'
                                  ? 'DELIVERED'
                                  : 'CONFIRMED',
                              'userInitialOrderStatus':
                                  userOrderDestination == 'Vendor'
                                  ? 'HOLD'
                                  : 'CONFIRMED',
                            };
                            onUpdated(updated);
                            _snack('Billing setup updated!', _C.green);
                          }
                        } catch (e) {
                          _snack('Update failed: $e', _C.red);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_C.accent, _C.accentDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _C.accent.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            billingSetup == null
                                ? 'Save Setup'
                                : 'Update Setup',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
      },
    );
  }

  Widget _formField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.text2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: _C.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.border),
          ),
          child: child,
        ),
      ],
    );
  }

  // ── View Ticket Section ───────────────────────────────────────────────────────
  Widget _viewTicketSection() {
    return Column(
      children: [
        Expanded(child: _ticketList()),
        _bottomActionBar(
          label: 'Raise a Ticket',
          icon: Icons.add_circle_outline_rounded,
          color: _C.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Raise_ticket()),
          ),
        ),
      ],
    );
  }

  Widget _ticketList() {
    if (isLoadingTickets) {
      return const Center(
        child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2),
      );
    }
    if (tickets.isEmpty) {
      return _emptyState(
        Icons.support_agent_outlined,
        'No Tickets Yet',
        'Raise a ticket for support',
      );
    }

    final statusColor = {
      'OPEN': _C.amber,
      'CLOSED': _C.green,
      'PENDING': _C.blue,
    };
    final statusBg = {
      'OPEN': _C.amberLight,
      'CLOSED': _C.greenLight,
      'PENDING': _C.blueLight,
    };

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      itemCount: tickets.length,
      itemBuilder: (_, i) {
        final ticket = tickets[i];
        final status = ticket.status?.toUpperCase() ?? 'OPEN';
        final sColor = statusColor[status] ?? _C.text3;
        final sBg = statusBg[status] ?? _C.bg;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
            boxShadow: [
              const BoxShadow(
                color: _C.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _C.accentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.confirmation_number_rounded,
                        color: _C.accent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ticket.ticketType,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _C.text1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: sBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: sColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if ((ticket.message ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    ticket.message!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _C.text2,
                      height: 1.5,
                    ),
                  ),
                ],
                if (ticket.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: _C.text3,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.createdAt.toString(),
                        style: const TextStyle(fontSize: 10, color: _C.text3),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────
  Widget _bottomActionBar({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: _C.white,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.black, 0.15)!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
    ),
  );

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.bg,
              shape: BoxShape.circle,
              border: Border.all(color: _C.border),
            ),
            child: Icon(icon, size: 28, color: _C.text3),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.text1,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: _C.text2)),
        ],
      ),
    );
  }
}

// ─── VendorTimingsPage ────────────────────────────────────────────────────────
class VendorTimingsPage extends StatefulWidget {
  const VendorTimingsPage({super.key});
  @override
  State<VendorTimingsPage> createState() => _VendorTimingsPageState();
}

class _VendorTimingsPageState extends State<VendorTimingsPage> {
  List<Timing> vendorTimings = [];

  @override
  void initState() {
    super.initState();
    fetchVendorTimings();
  }

  Future<void> fetchVendorTimings() async {
    final data = await food_authservice.fetchVendorTimings();
    setState(() {
      vendorTimings = data
          .map(
            (t) => Timing(
              id: t.id,
              day: t.day,
              startTime: t.startTime,
              lastTime: t.lastTime.isEmpty || t.lastTime == 'null'
                  ? '--:--'
                  : t.lastTime,
            ),
          )
          .toList();
    });
  }

  Future<void> _addNewTimingSlot(String day) async {
    final open = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _C.accent),
        ),
        child: child!,
      ),
    );
    if (open == null) return;
    final close = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _C.accent),
        ),
        child: child!,
      ),
    );
    if (close == null) return;
    await food_authservice.addVendorTiming(
      day: day,
      startTime:
          '${open.hour.toString().padLeft(2, '0')}:${open.minute.toString().padLeft(2, '0')}:00',
      lastTime:
          '${close.hour.toString().padLeft(2, '0')}:${close.minute.toString().padLeft(2, '0')}:00',
    );
    await fetchVendorTimings();
  }

  Future<void> _selectOpenTime(Timing timing) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _parse(timing.startTime),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _C.accent),
        ),
        child: child!,
      ),
    );
    if (t == null) return;
    final updated =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
    await food_authservice.editVendorTiming(
      id: timing.id,
      day: timing.day,
      startTime: updated,
      lastTime: timing.lastTime == '--:--' ? '23:59:00' : timing.lastTime,
    );
    setState(() => timing.startTime = updated);
    await fetchVendorTimings();
  }

  Future<void> _selectCloseTime(Timing timing) async {
    final t = await showTimePicker(
      context: context,
      initialTime: timing.lastTime == '--:--'
          ? const TimeOfDay(hour: 23, minute: 59)
          : _parse(timing.lastTime),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _C.accent),
        ),
        child: child!,
      ),
    );
    if (t == null) return;
    final updated =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
    await food_authservice.editVendorTiming(
      id: timing.id,
      day: timing.day,
      startTime: timing.startTime,
      lastTime: updated,
    );
    setState(() => timing.lastTime = updated);
    await fetchVendorTimings();
  }

  Future<void> _deleteTimingSlot(Timing timing) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: _C.amber),
            SizedBox(width: 8),
            Text(
              'Delete Slot',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: const Text(
          'Remove this timing slot?',
          style: TextStyle(color: _C.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _C.text2)),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _C.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await food_authservice.deleteVendorTiming(timing.id);
      await fetchVendorTimings();
    }
  }

  TimeOfDay _parse(String s) {
    try {
      if (s.isEmpty || s == '--:--' || s == 'null')
        return const TimeOfDay(hour: 9, minute: 0);
      final parts = s.replaceAll(RegExp(r'[^0-9:]'), '').split(':');
      if (parts.length >= 2)
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
    } catch (_) {}
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _fmtTime(String s) {
    if (s.isEmpty || s.toLowerCase() == 'null' || s == '--:--') return '--:--';
    try {
      final parts = s.split(':');
      if (parts.length >= 2)
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    } catch (_) {}
    return '--:--';
  }

  @override
  Widget build(BuildContext context) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return RefreshIndicator(
      color: _C.accent,
      onRefresh: fetchVendorTimings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: days.map((d) => _buildDayCard(d)).toList(),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final dayTimings = vendorTimings
        .where((t) => t.day.toLowerCase() == day.toLowerCase())
        .toList();
    final hasSlot = dayTimings.isNotEmpty;
    final isWeekend = day == 'Saturday' || day == 'Sunday';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasSlot ? _C.accent.withOpacity(0.2) : _C.border,
        ),
        boxShadow: [
          const BoxShadow(
            color: _C.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isWeekend ? _C.amberLight : _C.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isWeekend
                        ? Icons.weekend_rounded
                        : Icons.calendar_today_rounded,
                    color: isWeekend ? _C.amber : _C.accent,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _C.text1,
                        ),
                      ),
                      if (!hasSlot)
                        const Text(
                          'No timing set',
                          style: TextStyle(fontSize: 11, color: _C.text3),
                        ),
                    ],
                  ),
                ),
                if (hasSlot)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _C.greenLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.green,
                      ),
                    ),
                  ),
              ],
            ),

            // Timing slots
            if (hasSlot) ...[
              const SizedBox(height: 12),
              ...dayTimings.map(
                (timing) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectOpenTime(timing),
                          child: _timeCell('Open', _fmtTime(timing.startTime)),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: _C.border,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectCloseTime(timing),
                          child: _timeCell('Close', _fmtTime(timing.lastTime)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteTimingSlot(timing),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _C.redLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: _C.red,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Add button
            GestureDetector(
              onTap: hasSlot ? null : () => _addNewTimingSlot(day),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: hasSlot ? _C.bg : _C.accentLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasSlot ? _C.border : _C.accent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: hasSlot ? _C.text3 : _C.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Timing',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: hasSlot ? _C.text3 : _C.accent,
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

  Widget _timeCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: _C.text2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 14, color: _C.accent),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _C.text1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Raise Ticket ─────────────────────────────────────────────────────────────
class Raise_ticket extends StatefulWidget {
  const Raise_ticket({super.key});
  @override
  State<Raise_ticket> createState() => _Raise_ticketState();
}

class _Raise_ticketState extends State<Raise_ticket> {
  final _messageCtrl = TextEditingController();
  String? _selectedLabel;
  bool _isLoading = false;

  final Map<String, String> ticketTypeMap = {
    'Delivery Issue': 'ORDER_COMPLAINT',
    'Payment Problem': 'PAYOUT_ISSUE',
    'Wrong Order': 'ORDER_COMPLAINT',
    'Service Quality': 'TECHNICAL_SUPPORT',
    'Other': 'OTHER',
  };

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_messageCtrl.text.isEmpty || _selectedLabel == null) {
      _snack('Please fill all fields', _C.amber);
      return;
    }
    setState(() => _isLoading = true);
    final success = await food_authservice.submitTicket(
      ticketType: ticketTypeMap[_selectedLabel!]!,
      message: _messageCtrl.text,
    );
    setState(() => _isLoading = false);
    if (success) {
      _snack('Ticket submitted successfully ✅', _C.green);
      _messageCtrl.clear();
      setState(() => _selectedLabel = null);
      Navigator.pop(context);
    } else {
      _snack('Failed to submit ticket', _C.red);
    }
  }

  void _snack(String msg, Color color) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: _C.white,
                border: Border(bottom: BorderSide(color: _C.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _C.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _C.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: _C.text1,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Raise a Ticket',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _C.text1,
                          ),
                        ),
                        Text(
                          'Get help from our support team',
                          style: TextStyle(fontSize: 11, color: _C.text2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _C.blueLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: _C.blue,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Ticket type label
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Issue Type',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _C.text2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ticketTypeMap.keys.map((label) {
                            final isSelected = _selectedLabel == label;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedLabel = label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? _C.accent : _C.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? _C.accent : _C.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: _C.accent.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [
                                          const BoxShadow(
                                            color: _C.shadow,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : _C.text2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Message field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Describe the Issue',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _C.text2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: _C.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _C.border),
                            boxShadow: [
                              const BoxShadow(
                                color: _C.shadow,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _messageCtrl,
                            maxLines: 5,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _C.text1,
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Describe your issue in detail...',
                              hintStyle: TextStyle(
                                color: _C.text3,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Submit button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: _C.white,
                border: Border(top: BorderSide(color: _C.border)),
              ),
              child: GestureDetector(
                onTap: _isLoading ? null : _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _C.blue.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Submit Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
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
}
