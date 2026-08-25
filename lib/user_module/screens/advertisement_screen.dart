// import 'package:flutter/material.dart';
//
// import 'eventsPage.dart';
//
// class Advertisements_Page extends StatelessWidget {
//   const Advertisements_Page({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFF),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               color: Colors.black87,
//               size: 20,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         title: const Text(
//           "Advertisements",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               // child: IconButton(
//               //   icon: const Icon(Icons.help_outline_rounded,
//               //       color: Colors.deepPurple, size: 22),
//               //   onPressed: () {},
//               // ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Header with unique design
//             Container(
//               margin: const EdgeInsets.only(bottom: 30),
//               child: Column(
//                 children: [
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       // Container(
//                       //   height: 4,
//                       //   width: 80,
//                       //   decoration: BoxDecoration(
//                       //     gradient: LinearGradient(
//                       //       colors: [
//                       //         Colors.orange.shade400,
//                       //         Colors.deepPurple.shade400,
//                       //       ],
//                       //     ),
//                       //     borderRadius: BorderRadius.circular(2),
//                       //   ),
//                       // ),
//                       // Container(
//                       //   padding: const EdgeInsets.symmetric(
//                       //       horizontal: 20, vertical: 12),
//                       //   decoration: BoxDecoration(
//                       //     color: Colors.white,
//                       //     borderRadius: BorderRadius.circular(12),
//                       //     boxShadow: [
//                       //       BoxShadow(
//                       //         color: Colors.deepPurple.withOpacity(0.1),
//                       //         blurRadius: 15,
//                       //         offset: const Offset(0, 4),
//                       //       ),
//                       //     ],
//                       //     border: Border.all(
//                       //       color: Colors.deepPurple.shade100,
//                       //     ),
//                       //   ),
//                       //   // child: const Text(
//                       //   //   "Setup Ad Campaigns",
//                       //   //   style: TextStyle(
//                       //   //     fontSize: 20,
//                       //   //     fontWeight: FontWeight.w800,
//                       //   //     letterSpacing: -0.5,
//                       //   //     color: Colors.black87,
//                       //   //   ),
//                       //   // ),
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // /// Quick Ad Setup - Enhanced
//             // _adCard(
//             //   icon: Icons.bolt_rounded,
//             //   title: "Quick Ad Setup",
//             //   subtitle: "Instantly increase your visibility in just 1 tap",
//             //   gradient: LinearGradient(
//             //     colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
//             //   ),
//             //   iconBackground: LinearGradient(
//             //     colors: [Colors.deepPurple.shade400, Colors.purple.shade400],
//             //   ),
//             //   iconColor: Colors.white,
//             //   onTap: () {
//             //     // Navigate to Story Screen
//             //     // Navigator.push(
//             //     //   context,
//             //     //   MaterialPageRoute(
//             //     //     builder: (context) => (),
//             //     //   ),
//             //     // );
//             //   },
//             // ),
//
//             const SizedBox(height: 16),
//
//             /// Build your own Ad - Enhanced
//             _adCard(
//               icon: Icons.create_rounded,
//               title: "Build your own Ad",
//               subtitle:
//                   "Reach more customers by customizing your ad targeting and slots.",
//               showNew: true,
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.orange.shade50],
//               ),
//               iconBackground: LinearGradient(
//                 colors: [Colors.orange.shade400, Colors.red.shade400],
//               ),
//               iconColor: Colors.white,
//               onTap: () {
//                 // Navigate to Story Screen
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //     builder: (context) => const Story_Screen(),
//                 //   ),
//                 // );
//               },
//             ),
//
//             const SizedBox(height: 32),
//             _adCard(
//               icon: Icons.event_available_rounded, // better for events
//               title: "Events",
//               subtitle: "Create events and attract more customers instantly",
//               gradient: LinearGradient(
//                 colors: [Colors.indigo.shade50, Colors.blue.shade50],
//               ),
//               iconBackground: LinearGradient(
//                 colors: [Colors.indigo, Colors.blueAccent],
//               ),
//               iconColor: Colors.white,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => EventHomePage()),
//                 );
//               },
//             ),
//
//             const SizedBox(height: 32),
//
//             /// What is listing Ad - Enhanced (with tap to show image slider)
//             // GestureDetector(
//             //   onTap: () {
//             //     _showAdExamplesSlider(context);
//             //   },
//             //   child: Container(
//             //     padding: const EdgeInsets.all(24),
//             //     decoration: BoxDecoration(
//             //       gradient: LinearGradient(
//             //         begin: Alignment.topLeft,
//             //         end: Alignment.bottomRight,
//             //         colors: [Colors.white, Colors.deepPurple.shade50],
//             //       ),
//             //       borderRadius: BorderRadius.circular(20),
//             //       boxShadow: [
//             //         BoxShadow(
//             //           color: Colors.deepPurple.withOpacity(0.1),
//             //           blurRadius: 20,
//             //           offset: const Offset(0, 8),
//             //         ),
//             //       ],
//             //       border: Border.all(
//             //         color: Colors.deepPurple.shade100,
//             //         width: 1,
//             //       ),
//             //     ),
//             //     child: Stack(
//             //       children: [
//             //         Row(
//             //           children: [
//             //             Expanded(
//             //               child: Column(
//             //                 crossAxisAlignment: CrossAxisAlignment.start,
//             //                 children: [
//             //                   Row(
//             //                     children: [
//             //                       Container(
//             //                         padding: const EdgeInsets.symmetric(
//             //                           horizontal: 12,
//             //                           vertical: 6,
//             //                         ),
//             //                         decoration: BoxDecoration(
//             //                           color: Colors.deepPurple.shade100,
//             //                           borderRadius: BorderRadius.circular(8),
//             //                         ),
//             //                         child: const Text(
//             //                           "FEATURED",
//             //                           style: TextStyle(
//             //                             color: Colors.deepPurple,
//             //                             fontSize: 10,
//             //                             fontWeight: FontWeight.w800,
//             //                             letterSpacing: 0.5,
//             //                           ),
//             //                         ),
//             //                       ),
//             //                     ],
//             //                   ),
//             //                   const SizedBox(height: 12),
//             //                   const Text(
//             //                     "What is listing Ad?",
//             //                     style: TextStyle(
//             //                       fontSize: 18,
//             //                       fontWeight: FontWeight.w800,
//             //                       color: Colors.black87,
//             //                       letterSpacing: -0.5,
//             //                     ),
//             //                   ),
//             //                   const SizedBox(height: 10),
//             //                   Text(
//             //                     "Promote food, businesses, jobs, and more. Create ads easily and reach the right customers.",
//             //                     style: TextStyle(
//             //                       fontSize: 14,
//             //                       color: Colors.grey.shade700,
//             //                       height: 1.5,
//             //                     ),
//             //                   ),
//             //                   const SizedBox(height: 16),
//             //                   Container(
//             //                     padding: const EdgeInsets.symmetric(
//             //                       horizontal: 16,
//             //                       vertical: 10,
//             //                     ),
//             //                     decoration: BoxDecoration(
//             //                       gradient: LinearGradient(
//             //                         colors: [
//             //                           Colors.deepPurple.shade400,
//             //                           Colors.purple.shade400,
//             //                         ],
//             //                       ),
//             //                       borderRadius: BorderRadius.circular(12),
//             //                       boxShadow: [
//             //                         BoxShadow(
//             //                           color: Colors.deepPurple.withOpacity(0.3),
//             //                           blurRadius: 10,
//             //                           offset: const Offset(0, 4),
//             //                         ),
//             //                       ],
//             //                     ),
//             //                     child: Row(
//             //                       mainAxisSize: MainAxisSize.min,
//             //                       children: const [
//             //                         Text(
//             //                           "VIEW AD EXAMPLES",
//             //                           style: TextStyle(
//             //                             color: Colors.white,
//             //                             fontWeight: FontWeight.w600,
//             //                             fontSize: 13,
//             //                           ),
//             //                         ),
//             //                         SizedBox(width: 8),
//             //                         Icon(
//             //                           Icons.arrow_forward_rounded,
//             //                           color: Colors.white,
//             //                           size: 18,
//             //                         ),
//             //                       ],
//             //                     ),
//             //                   ),
//             //                 ],
//             //               ),
//             //             ),
//             //             const SizedBox(width: 20),
//             //             Container(
//             //               padding: const EdgeInsets.all(16),
//             //               decoration: BoxDecoration(
//             //                 gradient: LinearGradient(
//             //                   colors: [
//             //                     Colors.deepPurple.shade100,
//             //                     Colors.purple.shade100,
//             //                   ],
//             //                   begin: Alignment.topCenter,
//             //                   end: Alignment.bottomCenter,
//             //                 ),
//             //                 shape: BoxShape.circle,
//             //               ),
//             //               child: const Icon(
//             //                 Icons.photo_library_rounded,
//             //                 size: 50,
//             //                 color: Colors.deepPurple,
//             //               ),
//             //             ),
//             //           ],
//             //         ),
//             //         Positioned(
//             //           top: 0,
//             //           right: 0,
//             //           child: Container(
//             //             width: 60,
//             //             height: 60,
//             //             decoration: BoxDecoration(
//             //               color: Colors.deepPurple.withOpacity(0.05),
//             //               borderRadius: const BorderRadius.only(
//             //                 topRight: Radius.circular(20),
//             //                 bottomLeft: Radius.circular(30),
//             //               ),
//             //             ),
//             //           ),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//
//             const SizedBox(height: 32),
//
//             /// Track advertisements - Enhanced
//             // Container(
//             //   padding: const EdgeInsets.all(20),
//             //   decoration: BoxDecoration(
//             //     gradient: LinearGradient(
//             //       colors: [Colors.white, Colors.green.shade50],
//             //     ),
//             //     borderRadius: BorderRadius.circular(20),
//             //     boxShadow: [
//             //       BoxShadow(
//             //         color: Colors.green.withOpacity(0.1),
//             //         blurRadius: 15,
//             //         offset: const Offset(0, 6),
//             //       ),
//             //     ],
//             //     border: Border.all(color: Colors.green.shade100, width: 1),
//             //   ),
//             //   child: Row(
//             //     children: [
//             //       Container(
//             //         padding: const EdgeInsets.all(14),
//             //         decoration: BoxDecoration(
//             //           gradient: LinearGradient(
//             //             colors: [Colors.green.shade400, Colors.teal.shade400],
//             //           ),
//             //           shape: BoxShape.circle,
//             //           boxShadow: [
//             //             BoxShadow(
//             //               color: Colors.green.withOpacity(0.3),
//             //               blurRadius: 8,
//             //               offset: const Offset(0, 4),
//             //             ),
//             //           ],
//             //         ),
//             //         child: const Icon(
//             //           Icons.help_outline_rounded,
//             //           color: Colors.white,
//             //           size: 18,
//             //         ),
//             //       ),
//             //
//             //       const SizedBox(width: 16),
//             //       Expanded(
//             //         child: Column(
//             //           crossAxisAlignment: CrossAxisAlignment.start,
//             //           children: [
//             //             const Text(
//             //               "FAQs about ads",
//             //               style: TextStyle(
//             //                 fontSize: 18,
//             //                 fontWeight: FontWeight.w800,
//             //                 color: Colors.black87,
//             //               ),
//             //             ),
//             //             // const SizedBox(height: 4),
//             //             // Text(
//             //             //   "",
//             //             //   style: TextStyle(
//             //             //     fontSize: 13,
//             //             //     color: Colors.grey.shade600,
//             //             //   ),
//             //             // ),
//             //           ],
//             //         ),
//             //       ),
//             //       Container(
//             //         padding: const EdgeInsets.all(10),
//             //         decoration: BoxDecoration(
//             //           color: Colors.green.shade100,
//             //           borderRadius: BorderRadius.circular(12),
//             //         ),
//             //         child: const Icon(
//             //           Icons.arrow_forward_ios_rounded,
//             //           color: Colors.green,
//             //           size: 18,
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//
//             // /// Decorative elements at bottom
//             // const SizedBox(height: 40),
//             // Center(
//             //   child: Wrap(
//             //     spacing: 8,
//             //     children: List.generate(
//             //       3,
//             //       (index) => Container(
//             //         width: 8,
//             //         height: 8,
//             //         decoration: BoxDecoration(
//             //           color: index == 0
//             //               ? Colors.deepPurple
//             //               : Colors.grey.shade300,
//             //           shape: BoxShape.circle,
//             //         ),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Function to show ad examples image slider
//   void _showAdExamplesSlider(BuildContext context) {
//     final List<AdExample> adExamples = [
//       AdExample(
//         title: "Food Delivery Ad",
//         description: "Promote restaurant deals and food delivery services",
//         category: "FOOD",
//         imageUrl:
//             "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&auto=format&fit=crop",
//         gradient: LinearGradient(
//           colors: [Colors.orange.shade400, Colors.red.shade400],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       AdExample(
//         title: "Job Opening",
//         description: "Recruit talent with eye-catching job advertisements",
//         category: "JOBS",
//         imageUrl:
//             "https://images.unsplash.com/photo-1551836026-d5c2c5af78e4?w-800&auto=format&fit=crop",
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade400, Colors.purple.shade400],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       AdExample(
//         title: "Real Estate",
//         description: "Showcase properties with beautiful visual ads",
//         category: "PROPERTY",
//         imageUrl:
//             "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w-800&auto=format&fit=crop",
//         gradient: LinearGradient(
//           colors: [Colors.green.shade400, Colors.teal.shade400],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       AdExample(
//         title: "Online Courses",
//         description: "Promote educational content and skill development",
//         category: "EDUCATION",
//         imageUrl:
//             "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w-800&auto=format&fit=crop",
//         gradient: LinearGradient(
//           colors: [Colors.purple.shade400, Colors.pink.shade400],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       AdExample(
//         title: "Local Business",
//         description: "Boost local store visibility with targeted ads",
//         category: "BUSINESS",
//         imageUrl:
//             "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w-800&auto=format&fit=crop",
//         gradient: LinearGradient(
//           colors: [Colors.indigo.shade400, Colors.cyan.shade400],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       AdExample(
//         title: "Electronics Sale",
//         description: "Promote tech products with discount offers",
//         category: "SHOPPING",
//         imageUrl:
//             "https://images.unsplash.com/photo-1498049794561-7780e7231661?w-800&auto=format&fit=crop",
//         gradient: LinearGradient(
//           colors: [Colors.red.shade400, Colors.orange.shade400],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     ];
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AdExamplesDialog(adExamples: adExamples);
//       },
//     );
//   }
//
//   /// Enhanced Ad Card Widget
//   static Widget _adCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Gradient gradient,
//     required Gradient iconBackground,
//     required Color iconColor,
//     bool showNew = false,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: gradient,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 15,
//               offset: const Offset(0, 6),
//             ),
//           ],
//           border: Border.all(color: Colors.grey.shade200, width: 1),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 gradient: iconBackground,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Icon(icon, color: iconColor, size: 26),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.black87,
//                           letterSpacing: -0.3,
//                         ),
//                       ),
//                       if (showNew) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.red.shade400,
//                                 Colors.orange.shade400,
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(6),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.red.withOpacity(0.2),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             "NEW",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 color: Colors.deepPurple,
//                 size: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Model class for Ad Examples
// class AdExample {
//   final String title;
//   final String description;
//   final String category;
//   final String imageUrl;
//   final Gradient gradient;
//
//   AdExample({
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.imageUrl,
//     required this.gradient,
//   });
// }
//
// /// Ad Examples Dialog with Image Slider
// class AdExamplesDialog extends StatefulWidget {
//   final List<AdExample> adExamples;
//
//   const AdExamplesDialog({super.key, required this.adExamples});
//
//   @override
//   State<AdExamplesDialog> createState() => _AdExamplesDialogState();
// }
//
// class _AdExamplesDialogState extends State<AdExamplesDialog> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(20),
//       child: Container(
//         height: MediaQuery.of(context).size.height * 0.8,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Ad Examples Gallery",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         "See how your ads could look",
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.close_rounded, size: 20),
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Image Slider with Page View
//             Expanded(
//               child: Stack(
//                 children: [
//                   // Page View for Images
//                   PageView.builder(
//                     controller: _pageController,
//                     itemCount: widget.adExamples.length,
//                     onPageChanged: (index) {
//                       setState(() {
//                         _currentPage = index;
//                       });
//                     },
//                     itemBuilder: (context, index) {
//                       final ad = widget.adExamples[index];
//                       return _buildAdImageCard(ad);
//                     },
//                   ),
//
//                   // Gradient Overlay at bottom of image
//                   Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       height: 100,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                           colors: [
//                             Colors.black.withOpacity(0.7),
//                             Colors.transparent,
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Page Indicator
//                   Positioned(
//                     bottom: 20,
//                     left: 0,
//                     right: 0,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         widget.adExamples.length,
//                         (index) => Container(
//                           width: 8,
//                           height: 8,
//                           margin: const EdgeInsets.symmetric(horizontal: 4),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _currentPage == index
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.5),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Navigation Arrows
//                   Positioned(
//                     left: 10,
//                     top: 0,
//                     bottom: 0,
//                     child: Center(
//                       child: IconButton(
//                         icon: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.3),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.chevron_left_rounded,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                         onPressed: () {
//                           if (_currentPage > 0) {
//                             _pageController.previousPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     right: 10,
//                     top: 0,
//                     bottom: 0,
//                     child: Center(
//                       child: IconButton(
//                         icon: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.3),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.chevron_right_rounded,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                         onPressed: () {
//                           if (_currentPage < widget.adExamples.length - 1) {
//                             _pageController.nextPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Ad Info Section
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(24),
//                   bottomRight: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Category Badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: widget.adExamples[_currentPage].gradient,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       widget.adExamples[_currentPage].category,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//                   // Title
//                   Text(
//                     widget.adExamples[_currentPage].title,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.black87,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Description
//                   Text(
//                     widget.adExamples[_currentPage].description,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                       height: 1.4,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Create Similar Button
//                   // SizedBox(
//                   //   width: double.infinity,
//                   //   height: 50,
//                   //   child: ElevatedButton(
//                   //     onPressed: () {
//                   //       Navigator.pop(context);
//                   //       // Navigate to ad creation
//                   //     },
//                   //     style: ElevatedButton.styleFrom(
//                   //       backgroundColor: Colors.deepPurple,
//                   //       shape: RoundedRectangleBorder(
//                   //         borderRadius: BorderRadius.circular(12),
//                   //       ),
//                   //       elevation: 0,
//                   //     ),
//                   //     child: const Row(
//                   //       mainAxisAlignment: MainAxisAlignment.center,
//                   //       children: [
//                   //         Icon(Icons.add_rounded, size: 20),
//                   //         SizedBox(width: 8),
//                   //         Text(
//                   //           "CREATE SIMILAR AD",
//                   //           style: TextStyle(
//                   //             fontSize: 15,
//                   //             fontWeight: FontWeight.w600,
//                   //           ),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAdImageCard(AdExample ad) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           children: [
//             // Background Image
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(ad.imageUrl),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             // Gradient Overlay
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [Colors.black.withOpacity(0.6), Colors.transparent],
//                 ),
//               ),
//             ),
//
//             // Ad Badge
//             Positioned(
//               top: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.verified_rounded, color: Colors.white, size: 14),
//                     SizedBox(width: 4),
//                     Text(
//                       "SAMPLE AD",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Ad Mockup Elements
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Mock Business Name
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Text(
//                       "Business Name",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Mock Ad Text
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Special Offer!",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.deepPurple,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           "Get 50% off on your first order",
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Add this StoryScreen class at the end of the same file or import it
// class StoryScreen extends StatefulWidget {
//   const StoryScreen({super.key});
//
//   @override
//   State<StoryScreen> createState() => _StoryScreenState();
// }
//
// class _StoryScreenState extends State<StoryScreen> {
//   final List<String> categories = [
//     'JOBS',
//     'FOOD',
//     'EDUCATION',
//     'OFFERS',
//     'REAL_ESTATE',
//     'ONLINE_COURSES',
//     'BAKERY',
//   ];
//
//   String selectedCategory = 'JOBS';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Stories',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Categories Row (like Instagram stories at top)
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final category = categories[index];
//                 final isSelected = selectedCategory == category;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedCategory = category;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.all(8),
//                     child: Column(
//                       children: [
//                         // Category Circle
//                         Container(
//                           width: 70,
//                           height: 70,
//                           decoration: BoxDecoration(
//                             gradient: isSelected
//                                 ? const LinearGradient(
//                                     colors: [Colors.purple, Colors.orange],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   )
//                                 : LinearGradient(
//                                     colors: [
//                                       Colors.grey.shade800,
//                                       Colors.grey.shade600,
//                                     ],
//                                   ),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: isSelected
//                                   ? Colors.white
//                                   : Colors.grey.shade700,
//                               width: 3,
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               category.substring(0, 1),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: isSelected
//                                     ? FontWeight.bold
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         // Category Name
//                         Text(
//                           category,
//                           style: TextStyle(
//                             color: isSelected
//                                 ? Colors.white
//                                 : Colors.grey.shade400,
//                             fontSize: 12,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Divider
//           Container(height: 1, color: Colors.grey.shade800),
//
//           // Content Area
//           Expanded(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.star, size: 100, color: Colors.white),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Selected Category:',
//                     style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     selectedCategory,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Content for $selectedCategory will appear here',
//                     style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
