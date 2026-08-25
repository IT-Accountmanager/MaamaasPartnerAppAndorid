// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:maamaaspartner/widgets_helper/food/footer.dart';
// // import '../API/Authservice.dart';
// // import '../Models/food&beverages/SubscriptionData.dart';
// // import '../Models/food&beverages/vendor_model.dart';
// // import 'Registration.dart';
// // import 'bannerscreen.dart';
// //
// // class Company extends StatefulWidget {
// //   const Company({super.key});
// //
// //   @override
// //   State<Company> createState() => _CompanyState();
// // }
// //
// // class _CompanyState extends State<Company> with TickerProviderStateMixin {
// //   bool isDrawerOpen = false;
// //   late TabController _tabController;
// //   late List<Widget> _tabs;
// //   String ownerName = '';
// //   String companyName = '';
// //   String selectedVertical = 'Food';
// //   String selectedPlan = 'Standard';
// //   List<TextEditingController> _controllers = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabs = [
// //       Banner_screen(),
// //       Registration(),
// //       // Banner_screen(),
// //       Termsandconditions(onNext: _goToNextTab),
// //       CancelTab(onNext: _goToNextTab),
// //       summaryTab(),
// //     ];
// //     _tabController = TabController(length: _tabs.length, vsync: this);
// //     loadVendorData();
// //   }
// //
// //   void _goToNextTab() {
// //     if (_tabController.index < _tabs.length - 1) {
// //       _tabController.animateTo(_tabController.index + 1);
// //     }
// //   }
// //
// //   int currentIndex = 0;
// //
// //   void toggleDrawer() {
// //     setState(() {
// //       isDrawerOpen = !isDrawerOpen;
// //     });
// //   }
// //
// //   void handleItemSelected(int index) {
// //     setState(() {
// //       currentIndex = index;
// //       isDrawerOpen = false;
// //     });
// //   }
// //
// //   void loadVendorData() async {
// //     final data = await Authservice().fetchVendorData();
// //     setState(() {});
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     for (var controller in _controllers) {
// //       controller.dispose();
// //     }
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         return Scaffold(
// //           backgroundColor: Colors.grey[50],
// //           appBar: AppBar(
// //             title: Text(
// //               "Business Profile",
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w600,
// //                 color: Colors.black,
// //               ),
// //             ),
// //             backgroundColor: Colors.white,
// //             elevation: 0,
// //             centerTitle: true,
// //             iconTheme: IconThemeData(color: Colors.black),
// //           ),
// //           body: Column(
// //             children: [
// //               // Enhanced TabBar
// //               Container(
// //                 child: TabBar(
// //                   controller: _tabController,
// //                   isScrollable: true,
// //                   labelColor: Colors.black,
// //                   unselectedLabelColor: Colors.black54,
// //                   indicatorColor: Colors.amber,
// //                   indicatorWeight: 3.0,
// //                   indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
// //                   labelStyle: TextStyle(
// //                     fontSize: 14.sp,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.black,
// //                   ),
// //                   unselectedLabelStyle: TextStyle(
// //                     fontSize: 13.sp,
// //                     fontWeight: FontWeight.w500,
// //                     color: Colors.black,
// //                   ),
// //                   tabs: const [
// //                     Tab(text: "Banners"),
// //                     Tab(text: "Registration"),
// //                     Tab(text: "📋 Terms & Conditions"),
// //                     Tab(text: "🔄 Cancel & Refund"),
// //                     Tab(text: "📊 Summary"),
// //                   ],
// //                 ),
// //               ),
// //
// //               // Tab Content
// //               Expanded(
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       begin: Alignment.topCenter,
// //                       end: Alignment.bottomCenter,
// //                       colors: [Colors.grey[50]!, Colors.grey[100]!],
// //                     ),
// //                   ),
// //                   child: TabBarView(
// //                     controller: _tabController,
// //                     children: _tabs.map((tab) {
// //                       return AnimatedContainer(
// //                         duration: Duration(milliseconds: 300),
// //                         curve: Curves.easeInOut,
// //                         child: tab,
// //                       );
// //                     }).toList(),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           // bottomNavigationBar: Footer(),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // Widget cardItem(
// //   String title1,
// //   String title2,
// //   String title3,
// //   List<String> features, [
// //   Widget? actionButton,
// // ]) {
// //   return Center(
// //     child: Container(
// //       width: 230.w,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(20.r),
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black12,
// //             blurRadius: 15.r,
// //             offset: Offset(0, 4),
// //           ),
// //         ],
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [Colors.white, Colors.grey[50]!],
// //         ),
// //         border: Border.all(
// //           color: Colors.blue.shade100.withOpacity(0.5),
// //           width: 1.5.w,
// //         ),
// //       ),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SizedBox(height: 20.h),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.star, color: Colors.amber, size: 18.sp),
// //               SizedBox(width: 5.w),
// //               Text(
// //                 title1,
// //                 style: TextStyle(
// //                   fontSize: 20.sp,
// //                   fontWeight: FontWeight.w800,
// //                   color: Colors.blue[900],
// //                   letterSpacing: 0.5,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 12.h),
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
// //             decoration: BoxDecoration(
// //               color: Colors.blue[50],
// //               borderRadius: BorderRadius.circular(8.r),
// //               border: Border.all(color: Colors.blue[100]!),
// //             ),
// //             child: Text(
// //               title2,
// //               style: TextStyle(
// //                 fontSize: 14.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: Colors.blue[800],
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 8.h),
// //           Text(
// //             title3,
// //             style: TextStyle(
// //               fontSize: 13.sp,
// //               fontWeight: FontWeight.w600,
// //               color: Colors.grey[700],
// //             ),
// //           ),
// //           SizedBox(height: 15.h),
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 15.w),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: features.map((feature) {
// //                 bool isChecked = feature.endsWith('✔️');
// //                 return Padding(
// //                   padding: EdgeInsets.only(bottom: 8.h),
// //                   child: Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Icon(
// //                         isChecked ? Icons.check_circle : Icons.cancel,
// //                         color: isChecked ? Colors.green : Colors.red,
// //                         size: 16.sp,
// //                       ),
// //                       SizedBox(width: 8.w),
// //                       Expanded(
// //                         child: Text(
// //                           feature.replaceAll('✔️', '').replaceAll('❌', ''),
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             fontWeight: FontWeight.w600,
// //                             color: isChecked
// //                                 ? Colors.green[700]
// //                                 : Colors.red[700],
// //                             height: 1.3,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ),
// //           SizedBox(height: 15.h),
// //           if (actionButton != null)
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 15.w),
// //               child: actionButton,
// //             ),
// //           SizedBox(height: 20.h),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// //
// // bool isChecked = false;
// //
// // class Termsandconditions extends StatefulWidget {
// //   final VoidCallback onNext;
// //
// //   const Termsandconditions({super.key, required this.onNext});
// //
// //   @override
// //   State<Termsandconditions> createState() => _TermsandconditionsState();
// // }
// //
// // class _TermsandconditionsState extends State<Termsandconditions> {
// //   bool isChecked = false;
// //
// //   void toggleCheckbox() {
// //     setState(() {
// //       isChecked = !isChecked;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.transparent,
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: EdgeInsets.all(20.w),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Reservation Policy Section
// //               _buildPolicyCard(
// //                 title: '1. Reservation Policy',
// //                 icon: Icons.calendar_today,
// //                 points: [
// //                   'Customers are encouraged to make reservations in advance.',
// //                   'Reservations are held for 15 minutes beyond the scheduled time.',
// //                 ],
// //               ),
// //               SizedBox(height: 20.h),
// //
// //               // Cancellation Policy Section
// //               _buildPolicyCard(
// //                 title: '2. Cancellation Policy',
// //                 icon: Icons.cancel,
// //                 points: [
// //                   'Please cancel or modify your reservation at least 2 hours before your scheduled time.',
// //                   'Late cancellations may incur a fee.',
// //                 ],
// //               ),
// //               SizedBox(height: 20.h),
// //
// //               // Payment Terms Section
// //               _buildPolicyCard(
// //                 title: '3. Payment Terms',
// //                 icon: Icons.payment,
// //                 points: [
// //                   'We accept cash, major credit/debit cards, and online payments.',
// //                   'All prices are inclusive of applicable taxes unless mentioned otherwise.',
// //                 ],
// //               ),
// //               SizedBox(height: 25.h),
// //
// //               // Agreement Section
// //               Container(
// //                 padding: EdgeInsets.all(16.w),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12.r),
// //                   border: Border.all(color: Colors.blue.shade200),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black12,
// //                       blurRadius: 8,
// //                       offset: Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     InkWell(
// //                       onTap: toggleCheckbox,
// //                       borderRadius: BorderRadius.circular(8.r),
// //                       child: Container(
// //                         width: 28.w,
// //                         height: 28.h,
// //                         decoration: BoxDecoration(
// //                           color: isChecked ? Colors.blue[800] : Colors.white,
// //                           borderRadius: BorderRadius.circular(8.r),
// //                           border: Border.all(
// //                             color: isChecked ? Colors.blue[800]! : Colors.grey,
// //                             width: 2.w,
// //                           ),
// //                         ),
// //                         child: isChecked
// //                             ? Icon(
// //                                 Icons.check,
// //                                 color: Colors.white,
// //                                 size: 18.sp,
// //                               )
// //                             : null,
// //                       ),
// //                     ),
// //                     SizedBox(width: 12.w),
// //                     Expanded(
// //                       child: Text(
// //                         'I agree to the Terms and Conditions',
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.w600,
// //                           fontSize: 16.sp,
// //                           color: Colors.grey[800],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 20.h),
// //
// //               if (isChecked)
// //                 Center(
// //                   child: Container(
// //                     width: 200.w,
// //                     height: 50.h,
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [Colors.green[600]!, Colors.green[400]!],
// //                         begin: Alignment.centerLeft,
// //                         end: Alignment.centerRight,
// //                       ),
// //                       borderRadius: BorderRadius.circular(25.r),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.green.withOpacity(0.3),
// //                           blurRadius: 10,
// //                           offset: Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: ElevatedButton(
// //                       onPressed: widget.onNext,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.transparent,
// //                         shadowColor: Colors.transparent,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(25.r),
// //                         ),
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Text(
// //                             'Next',
// //                             style: TextStyle(
// //                               fontSize: 16.sp,
// //                               fontWeight: FontWeight.w600,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                           SizedBox(width: 8.w),
// //                           Icon(
// //                             Icons.arrow_forward,
// //                             color: Colors.white,
// //                             size: 18.sp,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               SizedBox(height: 20.h),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPolicyCard({
// //     required String title,
// //     required IconData icon,
// //     required List<String> points,
// //   }) {
// //     return Container(
// //       padding: EdgeInsets.all(16.w),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(15.r),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
// //         ],
// //         border: Border.all(color: Colors.grey[200]!),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, color: Colors.blue[700], size: 20.sp),
// //               SizedBox(width: 8.w),
// //               Text(
// //                 title,
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w700,
// //                   fontSize: 16.sp,
// //                   color: Colors.blue[800],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 12.h),
// //           Column(
// //             children: points.map((point) => _buildBulletText(point)).toList(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // Widget _buildBulletText(String text) {
// //   return Padding(
// //     padding: EdgeInsets.only(left: 8.w, bottom: 6.h),
// //     child: Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Icon(Icons.circle, size: 6.sp, color: Colors.blue[700]),
// //         SizedBox(width: 12.w),
// //         Expanded(
// //           child: Text(
// //             text,
// //             style: TextStyle(
// //               fontSize: 14.sp,
// //               color: Colors.grey[700],
// //               height: 1.4,
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // class CancelTab extends StatefulWidget {
// //   final VoidCallback onNext;
// //
// //   const CancelTab({super.key, required this.onNext});
// //
// //   @override
// //   State<CancelTab> createState() => _CancelTabState();
// // }
// //
// // class _CancelTabState extends State<CancelTab> {
// //   bool isChecked = false;
// //
// //   void toggleCheckbox() {
// //     setState(() {
// //       isChecked = !isChecked;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.transparent,
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: EdgeInsets.all(20.w),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Policy Content
// //               Container(
// //                 padding: EdgeInsets.all(20.w),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(15.r),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black12,
// //                       blurRadius: 8,
// //                       offset: Offset(0, 3),
// //                     ),
// //                   ],
// //                   border: Border.all(color: Colors.orange[100]!),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'Reservation & Cancellation Policy',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.w700,
// //                         fontSize: 18.sp,
// //                         color: Colors.orange[800],
// //                       ),
// //                     ),
// //                     SizedBox(height: 15.h),
// //                     _buildBulletText1(
// //                       'Please cancel or modify your reservation at least 2 hours before your scheduled time',
// //                     ),
// //                     _buildBulletText1('Late cancellations may incur a fee.'),
// //                     _buildBulletText1(
// //                       'No-shows without prior notice may result in a temporary or permanent booking restriction.',
// //                     ),
// //                     _buildBulletText1(
// //                       'For group reservations (6+ people), cancellations should be made at least 24 hours in advance.',
// //                     ),
// //                     _buildBulletText1(
// //                       'If a prepaid booking is canceled late, no refund will be issued.',
// //                     ),
// //                     _buildBulletText1(
// //                       "We reserve the right to release your table if you're more than 15 minutes late without notifying us.",
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 25.h),
// //
// //               // Agreement Section
// //               Container(
// //                 padding: EdgeInsets.all(16.w),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12.r),
// //                   border: Border.all(color: Colors.orange.shade200),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black12,
// //                       blurRadius: 8,
// //                       offset: Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     InkWell(
// //                       onTap: toggleCheckbox,
// //                       borderRadius: BorderRadius.circular(8.r),
// //                       child: Container(
// //                         width: 28.w,
// //                         height: 28.h,
// //                         decoration: BoxDecoration(
// //                           color: isChecked ? Colors.orange[800] : Colors.white,
// //                           borderRadius: BorderRadius.circular(8.r),
// //                           border: Border.all(
// //                             color: isChecked
// //                                 ? Colors.orange[800]!
// //                                 : Colors.grey,
// //                             width: 2.w,
// //                           ),
// //                         ),
// //                         child: isChecked
// //                             ? Icon(
// //                                 Icons.check,
// //                                 color: Colors.white,
// //                                 size: 18.sp,
// //                               )
// //                             : null,
// //                       ),
// //                     ),
// //                     SizedBox(width: 12.w),
// //                     Expanded(
// //                       child: Text(
// //                         'I agree to the Cancellation Policy',
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.w600,
// //                           fontSize: 16.sp,
// //                           color: Colors.grey[800],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 20.h),
// //
// //               if (isChecked)
// //                 Center(
// //                   child: Container(
// //                     width: 200.w,
// //                     height: 50.h,
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [Colors.orange[600]!, Colors.orange[400]!],
// //                         begin: Alignment.centerLeft,
// //                         end: Alignment.centerRight,
// //                       ),
// //                       borderRadius: BorderRadius.circular(25.r),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.orange.withOpacity(0.3),
// //                           blurRadius: 10,
// //                           offset: Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         print("Submit clicked");
// //                         widget.onNext();
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.transparent,
// //                         shadowColor: Colors.transparent,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(25.r),
// //                         ),
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Icon(Icons.send, color: Colors.white, size: 18.sp),
// //                           SizedBox(width: 8.w),
// //                           Text(
// //                             'Submit',
// //                             style: TextStyle(
// //                               fontSize: 16.sp,
// //                               fontWeight: FontWeight.w600,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               SizedBox(height: 20.h),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // Widget _buildBulletText1(String text) {
// //   return Padding(
// //     padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
// //     child: Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Icon(
// //           Icons.warning_amber_rounded,
// //           size: 16.sp,
// //           color: Colors.orange[700],
// //         ),
// //         SizedBox(width: 12.w),
// //         Expanded(
// //           child: Text(
// //             text,
// //             style: TextStyle(
// //               fontSize: 14.sp,
// //               color: Colors.grey[700],
// //               height: 1.4,
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // Widget summaryTab() {
// //   return FutureBuilder<SubscriptionData?>(
// //     future: Authservice.fetchSubscriptionData(),
// //     builder: (context, snapshot) {
// //       if (snapshot.connectionState == ConnectionState.waiting) {
// //         return Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               CircularProgressIndicator(
// //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
// //                 strokeWidth: 3,
// //               ),
// //               SizedBox(height: 16.h),
// //               Text(
// //                 'Loading Subscription Data...',
// //                 style: TextStyle(
// //                   fontSize: 16.sp,
// //                   color: Colors.grey[600],
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       } else if (snapshot.hasError) {
// //         return Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.error_outline, color: Colors.red, size: 50.sp),
// //               SizedBox(height: 16.h),
// //               Text(
// //                 "Error: ${snapshot.error}",
// //                 style: TextStyle(
// //                   fontSize: 16.sp,
// //                   color: Colors.red[700],
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ),
// //         );
// //       } else if (!snapshot.hasData || snapshot.data == null) {
// //         return Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 50.sp),
// //               SizedBox(height: 16.h),
// //               Text(
// //                 "No subscription data found",
// //                 style: TextStyle(
// //                   fontSize: 16.sp,
// //                   color: Colors.grey[600],
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       }
// //
// //       final data = snapshot.data!;
// //       final vendor = data.vendorEnquiry;
// //
// //       final fieldMap = {
// //         'Vendor Id': vendor.vendorId.toString(),
// //         'Account': data.status,
// //         'Business Vertical': vendor.businessVerticals.join(', '),
// //         'Plan': data.subscriptionPlan.planType,
// //         'Price': data.subscriptionPlan.price.toString(),
// //         'Start Date':
// //             "${data.startDate.day}-${data.startDate.month}-${data.startDate.year}",
// //         'End Date':
// //             "${data.endDate.day}-${data.endDate.month}-${data.endDate.year}",
// //         'Remaining Days': data.remainingDays.toString(),
// //         'Company Name': vendor.companyName ?? '-',
// //         'Owner Name': vendor.name,
// //         'Email': vendor.email,
// //         'Phone': vendor.mobileNumber,
// //         'Payment Status': data.payment.status,
// //       };
// //
// //       return Padding(
// //         padding: EdgeInsets.all(20.w),
// //         child: Column(
// //           children: [
// //             // Summary Table - No header, just the table
// //             Expanded(
// //               child: SingleChildScrollView(child: fieldValueTable(fieldMap)),
// //             ),
// //           ],
// //         ),
// //       );
// //     },
// //   );
// // }
// //
// // Widget fieldValueTable(Map<String, String> data) {
// //   return Container(
// //     decoration: BoxDecoration(
// //       borderRadius: BorderRadius.circular(12.r),
// //       boxShadow: [
// //         BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
// //       ],
// //     ),
// //     child: Table(
// //       columnWidths: const {0: FixedColumnWidth(150), 1: FlexColumnWidth(150)},
// //       border: TableBorder.all(
// //         color: Colors.grey.shade300,
// //         borderRadius: BorderRadius.circular(12.r),
// //         width: 1.5,
// //       ),
// //       children: data.entries.map((entry) {
// //         final key = entry.key;
// //         final value = entry.value;
// //
// //         Widget valueWidget;
// //
// //         if (key == 'Account') {
// //           String buttonText = value.toLowerCase() == 'active'
// //               ? 'Upgrade'
// //               : 'Renewal';
// //
// //           valueWidget = Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
// //                 decoration: BoxDecoration(
// //                   color: value.toLowerCase() == 'active'
// //                       ? Colors.green[50]
// //                       : Colors.orange[50],
// //                   borderRadius: BorderRadius.circular(8.r),
// //                   border: Border.all(
// //                     color: value.toLowerCase() == 'active'
// //                         ? Colors.green[100]!
// //                         : Colors.orange[100]!,
// //                   ),
// //                 ),
// //                 child: Text(
// //                   value,
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.w600,
// //                     color: value.toLowerCase() == 'active'
// //                         ? Colors.green[800]
// //                         : Colors.orange[800],
// //                   ),
// //                 ),
// //               ),
// //               ElevatedButton(
// //                 onPressed: () {
// //                   print('$buttonText clicked');
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.orange,
// //                   foregroundColor: Colors.white,
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: 12.w,
// //                     vertical: 6.h,
// //                   ),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(8.r),
// //                   ),
// //                   elevation: 2,
// //                 ),
// //                 child: Text(
// //                   buttonText,
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.w600,
// //                     fontSize: 12.sp,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         } else if (key == 'Payment Status') {
// //           valueWidget = Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //             decoration: BoxDecoration(
// //               color: value.toLowerCase() == 'paid'
// //                   ? Colors.green[50]
// //                   : Colors.red[50],
// //               borderRadius: BorderRadius.circular(8.r),
// //               border: Border.all(
// //                 color: value.toLowerCase() == 'paid'
// //                     ? Colors.green[100]!
// //                     : Colors.red[100]!,
// //               ),
// //             ),
// //             child: Text(
// //               value,
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w600,
// //                 color: value.toLowerCase() == 'paid'
// //                     ? Colors.green[800]
// //                     : Colors.red[800],
// //               ),
// //             ),
// //           );
// //         } else {
// //           valueWidget = Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 14.sp,
// //               color: Colors.grey[800],
// //               fontWeight: FontWeight.w500,
// //             ),
// //           );
// //         }
// //
// //         return TableRow(
// //           decoration: BoxDecoration(color: Colors.white),
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(12.w),
// //               decoration: BoxDecoration(
// //                 color: Colors.blue[50],
// //                 borderRadius: key == data.entries.first.key
// //                     ? BorderRadius.only(topLeft: Radius.circular(11.r))
// //                     : null,
// //               ),
// //               child: Text(
// //                 key,
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   fontWeight: FontWeight.w700,
// //                   color: Colors.blue[900],
// //                 ),
// //               ),
// //             ),
// //             Padding(padding: EdgeInsets.all(12.w), child: valueWidget),
// //           ],
// //         );
// //       }).toList(),
// //     ),
// //   );
// // }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaaspartner/widgets_helper/food/footer.dart';
import '../API/Authservice.dart';
import '../BannerScreen/screens/food_profile_screen.dart';
import '../Models/food&beverages/SubscriptionData.dart';
import '../Models/food&beverages/vendor_model.dart';
import '../Registration01/screens/food_registration_screen.dart';
import '../RegistrationScreen/screens/food_registration_screen.dart';
import 'Registration.dart';
import 'bannerscreen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _cPrimary = Color(0xFFE66D33);
const _cPrimaryLt = Color(0xFFFFF0E8);
const _cSurface = Color(0xFFFFFFFF);
const _cBg = Color(0xFFF6F7FA);
const _cBorder = Color(0xFFECEDF2);
const _cText = Color(0xFF111827);
const _cSub = Color(0xFF6B7280);
const _cMuted = Color(0xFFB0B3C1);
const _cSuccess = Color(0xFF10B981);
const _cSuccessLt = Color(0xFFD1FAE5);
const _cDanger = Color(0xFFEF4444);
const _cDangerLt = Color(0xFFFEE2E2);
const _cInfo = Color(0xFF3B82F6);
const _cInfoLt = Color(0xFFDBEAFE);

// ─── Gradient shorthand ───────────────────────────────────────────────────────
const _kGrad = LinearGradient(
  colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ══════════════════════════════════════════════════════════════════════════════
// COMPANY — root screen
// ══════════════════════════════════════════════════════════════════════════════
class Company extends StatefulWidget {
  const Company({super.key});
  @override
  State<Company> createState() => _CompanyState();
}

class _CompanyState extends State<Company> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Widget> _tabs;
  int _activeIndex = 0;


  @override
  void initState() {
    super.initState();
    _tabs = [const FoodProfileScreen0(), const FoodRegistrationScreen01()];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() => _activeIndex = _tabController.index);
    });
  }

  void _goToNextTab() {
    if (_tabController.index < _tabs.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _cBg,
      // ── SafeArea: single top-level wrap for the whole screen ───────────────
      body: SafeArea(
        child: Column(
          children: [
            // White sticky header with gradient tab chips
            _Header(
              tabController: _tabController,
              activeIndex: _activeIndex,
              onTabTap: (i) {
                _tabController.animateTo(i);
                setState(() => _activeIndex = i);
              },
            ),
            // Scrollable tab content
            Expanded(
              child: TabBarView(controller: _tabController, children: _tabs),
            ),
          ],
        ),
      ),
    );
  }
}


class _Header extends StatefulWidget {
  final TabController tabController;
  final int activeIndex;
  final ValueChanged<int> onTabTap;

  const _Header({
    required this.tabController,
    required this.activeIndex,
    required this.onTabTap,
  });

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  static const _tabs = [
    _TabMeta('Banners', Icons.photo_library_rounded),
    // _TabMeta('Registration', Icons.assignment_rounded),
  ];

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(_Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_onTabChanged);
      widget.tabController.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cSurface,
        border: Border(bottom: BorderSide(color: _cBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          // ── Back button (fixed left) ────────────────────────────────────
          if (Navigator.of(context).canPop())
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: _cBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _cBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: _cText,
                ),
              ),
            ),

          // ── Scrollable tab chips (fills the middle) ─────────────────────
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isActive = widget.activeIndex == i;
                  final tab = _tabs[i];
                  return GestureDetector(
                    onTap: () => widget.onTabTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green
                            : const Color(0xFFE66D33),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tab.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabMeta {
  final String label;
  final IconData icon;
  const _TabMeta(this.label, this.icon);
}

Widget cardItem(
  String title1,
  String title2,
  String title3,
  List<String> features, [
  Widget? actionButton,
]) {
  return Center(
    child: Container(
      width: 240.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _cSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _cBorder),
      ),
      child: Column(
        children: [
          // ── Gradient header band ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: _kGrad,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title3,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // ── Feature list ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: features.map((f) {
                final checked = f.endsWith('✔️');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: checked ? _cSuccessLt : _cDangerLt,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          checked ? Icons.check_rounded : Icons.close_rounded,
                          size: 14,
                          color: checked ? _cSuccess : _cDanger,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f.replaceAll('✔️', '').replaceAll('❌', ''),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: checked ? _cText : _cSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (actionButton != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: actionButton,
            ),
        ],
      ),
    ),
  );
}

// TERMS & CONDITIONS TAB

class Termsandconditions extends StatefulWidget {
  final VoidCallback onNext;
  const Termsandconditions({super.key, required this.onNext});
  @override
  State<Termsandconditions> createState() => _TermsandconditionsState();
}

class _TermsandconditionsState extends State<Termsandconditions> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    // Bottom padding = fixed content gap + home indicator inset
    final bottomPad = 32 + MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
      child: Column(
        children: [
          _SectionHeader(
            icon: Icons.gavel_rounded,
            title: 'Terms & Conditions',
            subtitle: 'Please read carefully before proceeding',
          ),
          const SizedBox(height: 16),
          _policyCard(
            icon: Icons.event_available_rounded,
            iconColor: _cInfo,
            iconBg: _cInfoLt,
            title: '1. Reservation Policy',
            points: [
              'Customers are encouraged to make reservations in advance.',
              'Reservations are held for 15 minutes beyond the scheduled time.',
            ],
          ),
          const SizedBox(height: 12),
          _policyCard(
            icon: Icons.cancel_schedule_send_rounded,
            iconColor: _cDanger,
            iconBg: _cDangerLt,
            title: '2. Cancellation Policy',
            points: [
              'Please cancel or modify reservations at least 2 hours in advance.',
              'Late cancellations may incur a fee.',
            ],
          ),
          const SizedBox(height: 12),
          _policyCard(
            icon: Icons.payment_rounded,
            iconColor: _cSuccess,
            iconBg: _cSuccessLt,
            title: '3. Payment Terms',
            points: [
              'We accept cash, major credit/debit cards, and online payments.',
              'All prices are inclusive of applicable taxes unless stated otherwise.',
            ],
          ),
          const SizedBox(height: 20),
          // ── Animated agreement card ──────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => isChecked = !isChecked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isChecked ? _cSuccessLt : _cSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isChecked ? _cSuccess : _cBorder,
                  width: isChecked ? 1.5 : 1,
                ),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isChecked ? _cSuccess : _cSurface,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isChecked ? _cSuccess : _cMuted,
                        width: 2,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _cText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isChecked) ...[
            const SizedBox(height: 20),
            _PrimaryButton(
              label: 'Next Step',
              icon: Icons.arrow_forward_rounded,
              onTap: widget.onNext,
            ),
          ],
        ],
      ),
    );
  }

  Widget _policyCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _cText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5, right: 10),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _cSub,
                        height: 1.5,
                      ),
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
}

// ══════════════════════════════════════════════════════════════════════════════
// CANCEL & REFUND TAB
// SafeArea: NOT needed — inside Company's SafeArea.
// Bottom padding respects home indicator via MediaQuery.
// ══════════════════════════════════════════════════════════════════════════════
class CancelTab extends StatefulWidget {
  final VoidCallback onNext;
  const CancelTab({super.key, required this.onNext});
  @override
  State<CancelTab> createState() => _CancelTabState();
}

class _CancelTabState extends State<CancelTab> {
  bool isChecked = false;

  static const _points = [
    'Cancel or modify reservations at least 2 hours before scheduled time.',
    'Late cancellations may incur a fee.',
    'No-shows without prior notice may result in booking restrictions.',
    'Group reservations (6+ people) need 24 hours advance cancellation.',
    'Prepaid bookings canceled late will not receive a refund.',
    'Tables will be released if you\'re more than 15 minutes late without notice.',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = 32 + MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
      child: Column(
        children: [
          _SectionHeader(
            icon: Icons.replay_rounded,
            title: 'Cancel & Refund Policy',
            subtitle: 'Understand our cancellation terms',
          ),
          const SizedBox(height: 16),
          // ── Numbered policy points ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFE0CC)),
              boxShadow: [
                BoxShadow(
                  color: _cPrimary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: _points.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _cPrimaryLt,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _cPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _cSub,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // ── Animated agreement card ──────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => isChecked = !isChecked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isChecked ? _cPrimaryLt : _cSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isChecked ? _cPrimary : _cBorder,
                  width: isChecked ? 1.5 : 1,
                ),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isChecked ? _cPrimary : _cSurface,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isChecked ? _cPrimary : _cMuted,
                        width: 2,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I agree to the Cancellation Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _cText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isChecked) ...[
            const SizedBox(height: 20),
            _PrimaryButton(
              label: 'Submit & Continue',
              icon: Icons.send_rounded,
              onTap: widget.onNext,
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SUMMARY TAB
// SafeArea: NOT needed — inside Company's SafeArea.
// Bottom padding respects home indicator via MediaQuery.
// ══════════════════════════════════════════════════════════════════════════════
Widget summaryTab() {
  return FutureBuilder<SubscriptionData?>(
    future: Authservice.fetchSubscriptionData(),
    builder: (context, snapshot) {
      // ── Loading ─────────────────────────────────────────────────────────────
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _cPrimary, strokeWidth: 2.5),
              SizedBox(height: 16),
              Text(
                'Loading subscription data...',
                style: TextStyle(
                  fontSize: 14,
                  color: _cSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      // ── Error ────────────────────────────────────────────────────────────────
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: _cDangerLt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: _cDanger,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${snapshot.error}',
                style: const TextStyle(fontSize: 13, color: _cSub),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      // ── Empty ────────────────────────────────────────────────────────────────
      if (!snapshot.hasData || snapshot.data == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: _kGrad,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _cPrimary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No subscription data found',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _cText,
                ),
              ),
            ],
          ),
        );
      }

      final data = snapshot.data!;
      final vendor = data.vendorEnquiry;
      final bottomPad = 40 + MediaQuery.of(context).padding.bottom;

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
        child: Column(
          children: [
            // ── Status banner ────────────────────────────────────────────────────
            _StatusBanner(
              isActive: data.status.toLowerCase() == 'active',
              status: data.status,
              remainingDays: data.remainingDays,
            ),
            const SizedBox(height: 16),
            // ── Vendor info group ────────────────────────────────────────────────
            _SummaryGroup(
              icon: Icons.person_rounded,
              iconColor: _cInfo,
              iconBg: _cInfoLt,
              title: 'Vendor Info',
              rows: [
                _Row('Vendor ID', vendor.vendorId.toString()),
                _Row('Owner', vendor.name),
                _Row('Email', vendor.email),
                _Row('Phone', vendor.mobileNumber),
                _Row('Company', vendor.companyName ?? '—'),
              ],
            ),
            const SizedBox(height: 12),
            // ── Subscription group ───────────────────────────────────────────────
            _SummaryGroup(
              icon: Icons.workspace_premium_rounded,
              iconColor: _cPrimary,
              iconBg: _cPrimaryLt,
              title: 'Subscription',
              rows: [
                _Row('Plan', data.subscriptionPlan.planType),
                _Row('Price', '₹${data.subscriptionPlan.price}'),
                _Row('Business Vertical', vendor.businessVerticals.join(', ')),
                _Row(
                  'Start Date',
                  '${data.startDate.day}-${data.startDate.month}-${data.startDate.year}',
                ),
                _Row(
                  'End Date',
                  '${data.endDate.day}-${data.endDate.month}-${data.endDate.year}',
                ),
                _Row('Remaining Days', '${data.remainingDays} days'),
              ],
            ),
            const SizedBox(height: 12),
            // ── Payment group ────────────────────────────────────────────────────
            _SummaryGroup(
              icon: Icons.payment_rounded,
              iconColor: _cSuccess,
              iconBg: _cSuccessLt,
              title: 'Payment',
              rows: [_Row('Status', data.payment.status, isStatus: true)],
            ),
          ],
        ),
      );
    },
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// STATUS BANNER
// ──────────────────────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final bool isActive;
  final String status;
  final int remainingDays;

  const _StatusBanner({
    required this.isActive,
    required this.status,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    final Color bannerColor = isActive ? _cSuccess : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bannerColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.verified_rounded : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account $status',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isActive
                      ? '$remainingDays days remaining'
                      : 'Please renew your subscription',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Upgrade' : 'Renew',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: bannerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SUMMARY GROUP
// ──────────────────────────────────────────────────────────────────────────────
class _Row {
  final String key, value;
  final bool isStatus;
  const _Row(this.key, this.value, {this.isStatus = false});
}

class _SummaryGroup extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title;
  final List<_Row> rows;

  const _SummaryGroup({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Group header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _cText,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cBorder),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          e.value.key,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _cSub,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: e.value.isStatus
                            ? _StatusChip(status: e.value.value)
                            : Text(
                                e.value.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _cText,
                                ),
                                textAlign: TextAlign.end,
                              ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, color: _cBorder, indent: 14),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status.toLowerCase() == 'paid';
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isPaid ? _cSuccessLt : _cDangerLt,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isPaid
                ? _cSuccess.withOpacity(0.3)
                : _cDanger.withOpacity(0.3),
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isPaid ? _cSuccess : _cDanger,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// Gradient section header banner
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _kGrad,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _cPrimary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Gradient primary action button
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: _kGrad,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _cPrimary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
