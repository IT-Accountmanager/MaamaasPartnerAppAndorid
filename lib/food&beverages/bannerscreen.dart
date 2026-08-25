// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:maamaaspartner/Api/food_authservice.dart';
// // import '../Models/food&beverages/aboutus_model.dart';
// // import '../Models/food&beverages/bannermodel.dart';
// //
// // class Banner_screen extends StatefulWidget {
// //   const Banner_screen({super.key});
// //
// //   @override
// //   State<Banner_screen> createState() => _HomePageState();
// // }
// //
// // class _HomePageState extends State<Banner_screen> {
// //   static const Color primaryColor = Color(0xFF67B95F);
// //   bool _isOpen = true;
// //   bool _showDetails = false;
// //   BannerModel? _banner;
// //   AboutUsModel? _aboutUs;
// //   bool _isLoading = true;
// //   bool _isLoadingAboutUs = true;
// //   String _errorMessage = '';
// //
// //   final PageController _galleryController = PageController(
// //     viewportFraction: 0.85,
// //   );
// //
// //   List<String> _galleryImages = [
// //     'assets/fruits.png',
// //     'assets/Dry fruits.png',
// //     'assets/Bread.png',
// //     'assets/Drinks.png',
// //   ];
// //
// //   int _currentPage = 0;
// //   Timer? _timer;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _startAutoScroll();
// //     _loadAllData();
// //   }
// //
// //   Future<void> _loadAllData() async {
// //     await Future.wait([_loadBanner(), _loadAboutUs()]);
// //   }
// //
// //   Future<void> _loadBanner() async {
// //     print('🔄 Starting banner fetch...');
// //     try {
// //       final banner = await food_authservice.fetchVendorBanner();
// //       print(
// //         '📦 Banner fetch completed. Result: ${banner != null ? "SUCCESS" : "NULL"}',
// //       );
// //
// //       if (banner != null) {
// //         print('📊 Banner Data Received:');
// //         print('  - Company Name: ${banner.companyName}');
// //       }
// //
// //       setState(() {
// //         _banner = banner;
// //         _isLoading = false;
// //         if (banner == null) {
// //           _errorMessage = 'No banner data found for this vendor';
// //         }
// //       });
// //     } catch (e) {
// //       print('❌ ERROR in _loadBanner: $e');
// //       setState(() {
// //         _isLoading = false;
// //         _errorMessage = 'Error loading banner: $e';
// //       });
// //     }
// //   }
// //
// //   Future<void> _loadAboutUs() async {
// //     print('🔄 Starting about us fetch...');
// //     try {
// //       final aboutUs = await food_authservice.fetchVendorAboutUs();
// //
// //       if (aboutUs != null) {
// //         print('✅ AboutUs Data Received:');
// //         print('  - About Us Text: ${aboutUs.aboutUs}');
// //         print(
// //           '  - Main Image: ${aboutUs.image.isNotEmpty ? "Exists" : "Empty"}',
// //         );
// //         print('  - Gallery Images: ${aboutUs.getGalleryImages().length}');
// //         print('  - Mission: ${aboutUs.mission ?? "Not provided"}');
// //         print('  - Vision: ${aboutUs.vision ?? "Not provided"}');
// //
// //         final apiGalleryImages = aboutUs.getGalleryImages();
// //
// //         setState(() {
// //           _aboutUs = aboutUs;
// //           _isLoadingAboutUs = false;
// //
// //           if (apiGalleryImages.isNotEmpty) {
// //             _galleryImages = apiGalleryImages;
// //           }
// //         });
// //       } else {
// //         print('ℹ️ No about us data found');
// //         setState(() {
// //           _isLoadingAboutUs = false;
// //         });
// //       }
// //     } catch (e) {
// //       print('❌ ERROR in _loadAboutUs: $e');
// //       setState(() {
// //         _isLoadingAboutUs = false;
// //       });
// //     }
// //   }
// //
// //   void _startAutoScroll() {
// //     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
// //       if (_galleryImages.isNotEmpty &&
// //           _currentPage < _galleryImages.length - 1) {
// //         _currentPage++;
// //       } else {
// //         _currentPage = 0;
// //       }
// //       _galleryController.animateToPage(
// //         _currentPage,
// //         duration: const Duration(milliseconds: 600),
// //         curve: Curves.easeInOut,
// //       );
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     _galleryController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey.shade100,
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 10),
// //             _buildBanner(context),
// //             if (_errorMessage.isNotEmpty) _buildErrorMessage(),
// //             const SizedBox(height: 20),
// //             _buildToggleAndCollapse(),
// //             const SizedBox(height: 20),
// //             if (_showDetails) _buildAboutSection(),
// //             const SizedBox(height: 30),
// //             _buildGallerySection(),
// //             const SizedBox(height: 80),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildErrorMessage() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: Colors.orange[50],
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(color: Colors.orange),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(Icons.info, color: Colors.orange[800]),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 _errorMessage,
// //                 style: TextStyle(color: Colors.orange[800]),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBanner(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Column(
// //         children: [
// //           Container(
// //             height: 200,
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(20),
// //               image: DecorationImage(
// //                 image: _isLoading
// //                     ? const AssetImage('assets/Groceries.png') as ImageProvider
// //                     : (_banner?.companyBanner != null &&
// //                               _banner!.companyBanner.isNotEmpty
// //                           ? NetworkImage(_banner!.companyBanner)
// //                           : const AssetImage('assets/Groceries.png')
// //                                 as ImageProvider),
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //             child: Stack(
// //               children: [
// //                 Positioned(
// //                   top: 16,
// //                   left: 16,
// //                   child: CircleAvatar(
// //                     radius: 28,
// //                     backgroundColor: Colors.white,
// //                     backgroundImage: _getLogoImage(),
// //                   ),
// //                 ),
// //                 Positioned(
// //                   top: 16,
// //                   right: 16,
// //                   child: InkWell(
// //                     onTap: () {
// //                       showDialog(
// //                         context: context,
// //                         barrierDismissible: false,
// //                         builder: (context) => const UploadBannerPopup(),
// //                       );
// //                     },
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.green.withOpacity(0.85),
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.white, width: 2),
// //                       ),
// //                       child: const Text(
// //                         "Add +",
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 Center(
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Text(
// //                         _getCompanyName(),
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.bold,
// //                           letterSpacing: 1.2,
// //                         ),
// //                       ),
// //                       if (_banner?.establishedYear != null &&
// //                           _banner!.establishedYear.isNotEmpty)
// //                         Padding(
// //                           padding: const EdgeInsets.only(top: 4.0),
// //                           child: Text(
// //                             'Since ${_banner!.establishedYear}',
// //                             style: const TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 14,
// //                               fontStyle: FontStyle.italic,
// //                             ),
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //                 if (_isLoading)
// //                   const Center(
// //                     child: CircularProgressIndicator(color: Colors.white),
// //                   ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //           // _buildDebugInfo(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   ImageProvider _getLogoImage() {
// //     if (_isLoading) {
// //       return const AssetImage('assets/maamaslogo.png');
// //     }
// //     if (_banner?.companyLogo != null && _banner!.companyLogo.isNotEmpty) {
// //       return NetworkImage(_banner!.companyLogo);
// //     }
// //     return const AssetImage('assets/maamaslogo.png');
// //   }
// //
// //   String _getCompanyName() {
// //     if (_isLoading) return "Loading...";
// //     if (_banner?.companyName != null && _banner!.companyName.isNotEmpty) {
// //       return _banner!.companyName;
// //     }
// //     return "FRESH & GROCERIES";
// //   }
// //
// //
// //
// //   Widget _buildToggleAndCollapse() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.shade300,
// //               blurRadius: 6,
// //               offset: const Offset(0, 3),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 10,
// //                   height: 10,
// //                   decoration: BoxDecoration(
// //                     color: _isOpen ? Colors.green : Colors.red,
// //                     shape: BoxShape.circle,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   _isOpen ? "OPEN" : "CLOSED",
// //                   style: TextStyle(
// //                     color: _isOpen ? Colors.green : Colors.red,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 Switch(
// //                   value: _isOpen,
// //                   onChanged: (v) => setState(() => _isOpen = v),
// //                   activeColor: Colors.green,
// //                 ),
// //               ],
// //             ),
// //             ElevatedButton.icon(
// //               onPressed: () {
// //                 setState(() => _showDetails = !_showDetails);
// //               },
// //               icon: Icon(
// //                 _showDetails
// //                     ? Icons.keyboard_arrow_up
// //                     : Icons.keyboard_arrow_down,
// //               ),
// //               label: Text(_showDetails ? "Show Less" : "Know More"),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: primaryColor,
// //                 foregroundColor: Colors.white,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Function to handle Mission & Vision edit
// //   void _handleMissionVisionEdit() {
// //     TextEditingController missionController = TextEditingController(
// //       text: _aboutUs?.mission ?? '',
// //     );
// //     TextEditingController visionController = TextEditingController(
// //       text: _aboutUs?.vision ?? '',
// //     );
// //
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Edit Mission & Vision'),
// //         content: Container(
// //           width: double.maxFinite,
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 TextField(
// //                   controller: missionController,
// //                   maxLines: 3,
// //                   decoration: const InputDecoration(
// //                     labelText: 'Mission',
// //                     hintText: 'Enter your mission statement...',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 TextField(
// //                   controller: visionController,
// //                   maxLines: 3,
// //                   decoration: const InputDecoration(
// //                     labelText: 'Vision',
// //                     hintText: 'Enter your vision statement...',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () async {
// //               final newMission = missionController.text.trim();
// //               final newVision = visionController.text.trim();
// //
// //               if (newMission.isEmpty || newVision.isEmpty) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(
// //                     content: Text('Please fill both Mission and Vision'),
// //                   ),
// //                 );
// //                 return;
// //               }
// //
// //               // Show loading
// //               showDialog(
// //                 context: context,
// //                 barrierDismissible: false,
// //                 builder: (context) =>
// //                     const Center(child: CircularProgressIndicator()),
// //               );
// //
// //               // Call unified API
// //               final success = await food_authservice.updateAboutUsComplete(
// //                 aboutUs: _aboutUs?.aboutUs ?? '',
// //                 mission: newMission,
// //                 vision: newVision,
// //                 image: null, // Keep existing image
// //               );
// //
// //               Navigator.pop(context); // Close loading dialog
// //               Navigator.pop(context); // Close edit dialog
// //
// //               if (success) {
// //                 // Update local state
// //                 setState(() {
// //                   if (_aboutUs != null) {
// //                     _aboutUs = _aboutUs!.copyWith(
// //                       mission: newMission,
// //                       vision: newVision,
// //                     );
// //                   }
// //                 });
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(
// //                     content: Text('Mission & Vision updated successfully!'),
// //                   ),
// //                 );
// //               } else {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(
// //                     content: Text('Failed to update Mission & Vision'),
// //                   ),
// //                 );
// //               }
// //             },
// //             child: const Text('Save'),
// //             style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Function to handle About Us edit with Image
// //   void _handleAboutUsEdit() {
// //     TextEditingController aboutUsController = TextEditingController(
// //       text: _aboutUs?.aboutUs ?? '',
// //     );
// //
// //     showDialog(
// //       context: context,
// //       builder: (context) => EditAboutUsCompletePopup(
// //         aboutUs: _aboutUs,
// //         onSave: (newAboutUsText, newImage) async {
// //           // Show loading
// //           showDialog(
// //             context: context,
// //             barrierDismissible: false,
// //             builder: (_) => const Center(child: CircularProgressIndicator()),
// //           );
// //
// //           final success = await food_authservice.updateAboutUsComplete(
// //             aboutUs: newAboutUsText,
// //             mission: _aboutUs?.mission,
// //             vision: _aboutUs?.vision,
// //             image: newImage,
// //           );
// //
// //           Navigator.pop(context); // close loader
// //
// //           if (success) {
// //             setState(() {
// //               if (_aboutUs != null) {
// //                 _aboutUs = _aboutUs!.copyWith(
// //                   aboutUs: newAboutUsText,
// //                   image: newImage != null ? 'updated' : _aboutUs!.image,
// //                 );
// //               }
// //             });
// //
// //             await _loadAboutUs(); // Reload to get updated image URL
// //
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               const SnackBar(content: Text("About Us updated successfully")),
// //             );
// //           } else {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               const SnackBar(content: Text("Failed to update About Us")),
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }
// //
// //   // Function to handle Add About Us section (when all are empty)
// //   void _handleAddAboutUsSection() {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AddAboutUsSectionPopup(
// //         aboutUs: _aboutUs,
// //         onSave: (newAboutUsText, newImage, newMission, newVision) async {
// //           // Show loading
// //           showDialog(
// //             context: context,
// //             barrierDismissible: false,
// //             builder: (context) =>
// //                 const Center(child: CircularProgressIndicator()),
// //           );
// //
// //           try {
// //             // Call unified API to update all data
// //             final success = await food_authservice.updateAboutUsComplete(
// //               aboutUs: newAboutUsText,
// //               mission: newMission,
// //               vision: newVision,
// //               image: newImage,
// //             );
// //
// //             Navigator.pop(context); // Close loading dialog
// //             Navigator.pop(context); // Close add dialog
// //
// //             if (success) {
// //               // Refetch data to get updated values
// //               await _loadAboutUs();
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(
// //                   content: Text('About Us section added successfully!'),
// //                 ),
// //               );
// //             } else {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Failed to add About Us section')),
// //               );
// //             }
// //           } catch (e) {
// //             Navigator.pop(context); // Close loading dialog
// //             ScaffoldMessenger.of(
// //               context,
// //             ).showSnackBar(SnackBar(content: Text('Error: $e')));
// //           }
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildAboutSection() {
// //     final bool hasAboutUsImage =
// //         _aboutUs?.image != null && _aboutUs!.image.isNotEmpty;
// //     final bool hasMission =
// //         _aboutUs?.mission != null && _aboutUs!.mission!.isNotEmpty;
// //     final bool hasVision =
// //         _aboutUs?.vision != null && _aboutUs!.vision!.isNotEmpty;
// //     final bool hasAboutUsText =
// //         _aboutUs?.aboutUs != null && _aboutUs!.aboutUs.isNotEmpty;
// //
// //     // Show ADD button only if ALL four are missing
// //     final bool showAddButton =
// //         !hasAboutUsText && !hasAboutUsImage && !hasMission && !hasVision;
// //
// //     return Padding(
// //       padding: const EdgeInsets.all(16.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           // About Us Title with Edit Button (always shows if exists, otherwise shows +)
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 hasAboutUsText ? _aboutUs!.aboutUs.toUpperCase() : "ABOUT US",
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(
// //                   color: primaryColor,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(width: 10),
// //               if (hasAboutUsText)
// //                 IconButton(
// //                   onPressed: _handleAboutUsEdit,
// //                   icon: const Icon(Icons.edit, color: primaryColor, size: 24),
// //                   tooltip: 'Edit About Us',
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(height: 10),
// //
// //           // About Us Image Section
// //           Stack(
// //             children: [
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(12),
// //                 child: Container(
// //                   height: 180,
// //                   width: double.infinity,
// //                   color: Colors.grey.shade200,
// //                   child: _isLoadingAboutUs
// //                       ? const Center(child: CircularProgressIndicator())
// //                       : hasAboutUsImage
// //                       ? Image.network(
// //                           _aboutUs!.image,
// //                           fit: BoxFit.cover,
// //                           loadingBuilder: (context, child, loadingProgress) {
// //                             if (loadingProgress == null) return child;
// //                             return Center(
// //                               child: CircularProgressIndicator(
// //                                 value:
// //                                     loadingProgress.expectedTotalBytes != null
// //                                     ? loadingProgress.cumulativeBytesLoaded /
// //                                           loadingProgress.expectedTotalBytes!
// //                                     : null,
// //                               ),
// //                             );
// //                           },
// //                           errorBuilder: (context, error, stackTrace) {
// //                             print('❌ Error loading about us image: $error');
// //                             return Image.asset(
// //                               'assets/Groceries.png',
// //                               fit: BoxFit.cover,
// //                             );
// //                           },
// //                         )
// //                       : Image.asset('assets/Groceries.png', fit: BoxFit.cover),
// //                 ),
// //               ),
// //               // Add button for About Us Image only
// //               if (!hasAboutUsImage)
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: GestureDetector(
// //                     onTap: _handleAboutUsEdit,
// //                     child: Container(
// //                       padding: const EdgeInsets.all(8),
// //                       decoration: BoxDecoration(
// //                         color: primaryColor,
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: const Icon(
// //                         Icons.add_a_photo,
// //                         color: Colors.white,
// //                         size: 20,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(height: 10),
// //
// //           // About Us Text with Add button if empty
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Expanded(
// //                 child: Text(
// //                   hasAboutUsText
// //                       ? _aboutUs!.aboutUs
// //                       : "No about us description added yet.",
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     height: 1.5,
// //                     color: hasAboutUsText ? Colors.black87 : Colors.grey,
// //                     fontStyle: hasAboutUsText
// //                         ? FontStyle.normal
// //                         : FontStyle.italic,
// //                   ),
// //                 ),
// //               ),
// //               if (!hasAboutUsText)
// //                 IconButton(
// //                   onPressed: _handleAboutUsEdit,
// //                   icon: const Icon(Icons.add, color: primaryColor, size: 24),
// //                   tooltip: 'Add About Us Text',
// //                 ),
// //             ],
// //           ),
// //
// //           // Mission & Vision Section
// //           const SizedBox(height: 20),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 "MISSION & VISION",
// //                 style: TextStyle(
// //                   color: primaryColor,
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(width: 10),
// //               // Show edit button if either mission or vision exists
// //               if (hasMission || hasVision)
// //                 IconButton(
// //                   onPressed: _handleMissionVisionEdit,
// //                   icon: const Icon(Icons.edit, color: primaryColor, size: 24),
// //                   tooltip: 'Edit Mission & Vision',
// //                 ),
// //             ],
// //           ),
// //
// //           // Mission Section
// //           const SizedBox(height: 8),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 "Mission: ",
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               if (!hasMission)
// //                 IconButton(
// //                   onPressed: _handleMissionVisionEdit,
// //                   icon: const Icon(Icons.add, color: primaryColor, size: 20),
// //                   tooltip: 'Add Mission',
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             hasMission ? _aboutUs!.mission! : "No mission statement added yet.",
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontSize: 14,
// //               color: hasMission ? Colors.black87 : Colors.grey,
// //               fontStyle: hasMission ? FontStyle.normal : FontStyle.italic,
// //             ),
// //           ),
// //
// //           // Vision Section
// //           const SizedBox(height: 12),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 "Vision: ",
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               if (!hasVision)
// //                 IconButton(
// //                   onPressed: _handleMissionVisionEdit,
// //                   icon: const Icon(Icons.add, color: primaryColor, size: 20),
// //                   tooltip: 'Add Vision',
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             hasVision ? _aboutUs!.vision! : "No vision statement added yet.",
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontSize: 14,
// //               color: hasVision ? Colors.black87 : Colors.grey,
// //               fontStyle: hasVision ? FontStyle.normal : FontStyle.italic,
// //             ),
// //           ),
// //
// //           // Main Add Button for Entire Section (only shows when all are empty)
// //           if (showAddButton) ...[
// //             const SizedBox(height: 30),
// //             ElevatedButton.icon(
// //               onPressed: _handleAddAboutUsSection,
// //               icon: const Icon(Icons.add_circle_outline),
// //               label: const Text('Add About Us Section'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: primaryColor,
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 30,
// //                   vertical: 15,
// //                 ),
// //               ),
// //             ),
// //           ],
// //
// //           // Show leadership cards only if About Us image, mission, and vision are all empty
// //           if (!hasAboutUsImage &&
// //               !hasMission &&
// //               !hasVision &&
// //               !hasAboutUsText) ...[
// //             const SizedBox(height: 20),
// //             const Text(
// //               "MEET OUR LEADERSHIP",
// //               style: TextStyle(
// //                 color: primaryColor,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 _buildLeaderCard("AAA", "Founder & CEO"),
// //                 _buildLeaderCard("BBB", "Co-Founder & Director"),
// //               ],
// //             ),
// //             const SizedBox(height: 25),
// //             const Text(
// //               "OUR COMMITMENTS",
// //               style: TextStyle(
// //                 color: primaryColor,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 10),
// //             const Text(
// //               "We are committed to quality, trust, and freshness in every order.",
// //               textAlign: TextAlign.center,
// //               style: TextStyle(fontSize: 14),
// //             ),
// //             const SizedBox(height: 20),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 _buildInfoBox(
// //                   "OUR MISSION",
// //                   "Deliver fresh groceries with quality and care.",
// //                 ),
// //                 _buildInfoBox(
// //                   "OUR VISION",
// //                   "Be the most trusted grocery partner for every home.",
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLeaderCard(String name, String role) {
// //     return Container(
// //       width: 140,
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.shade300,
// //             blurRadius: 6,
// //             offset: const Offset(0, 3),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           const CircleAvatar(
// //             radius: 30,
// //             backgroundImage: AssetImage('assets/profile.png'),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             name,
// //             style: const TextStyle(
// //               fontWeight: FontWeight.bold,
// //               fontSize: 16,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             role,
// //             textAlign: TextAlign.center,
// //             style: const TextStyle(fontSize: 13, color: Colors.grey),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoBox(String title, String description) {
// //     return Container(
// //       width: 150,
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.shade300,
// //             blurRadius: 6,
// //             offset: const Offset(0, 3),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           Text(
// //             title,
// //             textAlign: TextAlign.center,
// //             style: const TextStyle(
// //               color: primaryColor,
// //               fontWeight: FontWeight.bold,
// //               fontSize: 15,
// //             ),
// //           ),
// //           const SizedBox(height: 6),
// //           Text(
// //             description,
// //             textAlign: TextAlign.center,
// //             style: const TextStyle(fontSize: 13, color: Colors.black87),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildGallerySection() {
// //     return Column(
// //       children: [
// //         const Text(
// //           "GALLERY",
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.bold,
// //             color: primaryColor,
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         SizedBox(
// //           height: 200,
// //           child: _galleryImages.isNotEmpty
// //               ? PageView.builder(
// //                   controller: _galleryController,
// //                   itemCount: _galleryImages.length,
// //                   itemBuilder: (context, index) {
// //                     final imageUrl = _galleryImages[index];
// //                     final bool isAsset = imageUrl.startsWith('assets/');
// //
// //                     return Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
// //                       child: ClipRRect(
// //                         borderRadius: BorderRadius.circular(15),
// //                         child: isAsset
// //                             ? Image.asset(imageUrl, fit: BoxFit.cover)
// //                             : Image.network(
// //                                 imageUrl,
// //                                 fit: BoxFit.cover,
// //                                 loadingBuilder:
// //                                     (context, child, loadingProgress) {
// //                                       if (loadingProgress == null) return child;
// //                                       return Center(
// //                                         child: CircularProgressIndicator(
// //                                           value:
// //                                               loadingProgress
// //                                                       .expectedTotalBytes !=
// //                                                   null
// //                                               ? loadingProgress
// //                                                         .cumulativeBytesLoaded /
// //                                                     loadingProgress
// //                                                         .expectedTotalBytes!
// //                                               : null,
// //                                         ),
// //                                       );
// //                                     },
// //                                 errorBuilder: (context, error, stackTrace) {
// //                                   print(
// //                                     '❌ Error loading gallery image: $error',
// //                                   );
// //                                   return Container(
// //                                     color: Colors.grey.shade300,
// //                                     child: const Center(
// //                                       child: Icon(
// //                                         Icons.broken_image,
// //                                         size: 50,
// //                                         color: Colors.grey,
// //                                       ),
// //                                     ),
// //                                   );
// //                                 },
// //                               ),
// //                       ),
// //                     );
// //                   },
// //                 )
// //               : const Center(
// //                   child: Text(
// //                     'No gallery images available',
// //                     style: TextStyle(color: Colors.grey),
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // // Popup for Editing About Us Complete (text + image)
// // class EditAboutUsCompletePopup extends StatefulWidget {
// //   final AboutUsModel? aboutUs;
// //   final Function(String, File?) onSave;
// //
// //   const EditAboutUsCompletePopup({
// //     super.key,
// //     this.aboutUs,
// //     required this.onSave,
// //   });
// //
// //   @override
// //   State<EditAboutUsCompletePopup> createState() =>
// //       _EditAboutUsCompletePopupState();
// // }
// //
// // class _EditAboutUsCompletePopupState extends State<EditAboutUsCompletePopup> {
// //   static const Color primaryColor = Color(0xFF67B95F);
// //   final ImagePicker _picker = ImagePicker();
// //   File? _aboutUsImage;
// //   final TextEditingController _textController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize with existing data
// //     if (widget.aboutUs?.aboutUs != null) {
// //       _textController.text = widget.aboutUs!.aboutUs;
// //     }
// //   }
// //
// //   Future<void> _pickImage() async {
// //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _aboutUsImage = File(pickedFile.path);
// //       });
// //     }
// //   }
// //
// //   void _removeImage() {
// //     setState(() {
// //       _aboutUsImage = null;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double width = MediaQuery.of(context).size.width * 0.9;
// //
// //     return Dialog(
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       backgroundColor: Colors.white,
// //       insetPadding: const EdgeInsets.all(16),
// //       child: Container(
// //         width: width,
// //         padding: const EdgeInsets.all(16),
// //         constraints: const BoxConstraints(maxHeight: 500),
// //         child: Stack(
// //           children: [
// //             Positioned(
// //               top: 0,
// //               right: 0,
// //               child: IconButton(
// //                 icon: const Icon(Icons.close, color: Colors.black),
// //                 onPressed: () => Navigator.pop(context),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.only(top: 40),
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   children: [
// //                     const Text(
// //                       "Edit About Us",
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                         color: primaryColor,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 20),
// //
// //                     // About Us Image Upload Section
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           "About Us Image",
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         InkWell(
// //                           onTap: _pickImage,
// //                           child: Container(
// //                             height: 150,
// //                             width: double.infinity,
// //                             decoration: BoxDecoration(
// //                               color: Colors.grey.shade200,
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(color: Colors.grey.shade400),
// //                             ),
// //                             child: _buildImagePreview(),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         if (_aboutUsImage != null ||
// //                             (widget.aboutUs?.image != null &&
// //                                 widget.aboutUs!.image.isNotEmpty))
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.end,
// //                             children: [
// //                               ElevatedButton.icon(
// //                                 onPressed: _pickImage,
// //                                 icon: const Icon(Icons.edit, size: 16),
// //                                 label: const Text("Change Image"),
// //                                 style: ElevatedButton.styleFrom(
// //                                   backgroundColor: primaryColor,
// //                                   foregroundColor: Colors.white,
// //                                   padding: const EdgeInsets.symmetric(
// //                                     horizontal: 12,
// //                                     vertical: 6,
// //                                   ),
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 8),
// //                               OutlinedButton.icon(
// //                                 onPressed: _removeImage,
// //                                 icon: const Icon(
// //                                   Icons.delete,
// //                                   size: 16,
// //                                   color: Colors.red,
// //                                 ),
// //                                 label: const Text(
// //                                   "Remove",
// //                                   style: TextStyle(color: Colors.red),
// //                                 ),
// //                                 style: OutlinedButton.styleFrom(
// //                                   padding: const EdgeInsets.symmetric(
// //                                     horizontal: 12,
// //                                     vertical: 6,
// //                                   ),
// //                                   side: const BorderSide(color: Colors.red),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 20),
// //
// //                     // About Us Text Section
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           "About Us Text",
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         TextField(
// //                           controller: _textController,
// //                           maxLines: 5,
// //                           decoration: InputDecoration(
// //                             hintText: 'Write about your company...',
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                             contentPadding: const EdgeInsets.all(12),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 30),
// //
// //                     // Action Buttons
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                       children: [
// //                         Expanded(
// //                           child: OutlinedButton.icon(
// //                             onPressed: () => Navigator.pop(context),
// //                             icon: const Icon(Icons.cancel_outlined),
// //                             label: const Text("Cancel"),
// //                             style: OutlinedButton.styleFrom(
// //                               padding: const EdgeInsets.symmetric(vertical: 12),
// //                               side: BorderSide(color: Colors.grey.shade400),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 16),
// //                         Expanded(
// //                           child: ElevatedButton.icon(
// //                             onPressed: () {
// //                               if (_textController.text.trim().isEmpty) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(
// //                                     content: Text('Please enter About Us text'),
// //                                   ),
// //                                 );
// //                                 return;
// //                               }
// //                               widget.onSave(
// //                                 _textController.text,
// //                                 _aboutUsImage,
// //                               );
// //                             },
// //                             icon: const Icon(Icons.save),
// //                             label: const Text("Save Changes"),
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: primaryColor,
// //                               foregroundColor: Colors.white,
// //                               padding: const EdgeInsets.symmetric(vertical: 12),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildImagePreview() {
// //     if (_aboutUsImage != null) {
// //       return ClipRRect(
// //         borderRadius: BorderRadius.circular(12),
// //         child: Image.file(_aboutUsImage!, fit: BoxFit.cover),
// //       );
// //     } else if (widget.aboutUs?.image != null &&
// //         widget.aboutUs!.image.isNotEmpty) {
// //       return ClipRRect(
// //         borderRadius: BorderRadius.circular(12),
// //         child: Image.network(
// //           widget.aboutUs!.image,
// //           fit: BoxFit.cover,
// //           loadingBuilder: (context, child, loadingProgress) {
// //             if (loadingProgress == null) return child;
// //             return Center(
// //               child: CircularProgressIndicator(
// //                 value: loadingProgress.expectedTotalBytes != null
// //                     ? loadingProgress.cumulativeBytesLoaded /
// //                           loadingProgress.expectedTotalBytes!
// //                     : null,
// //               ),
// //             );
// //           },
// //           errorBuilder: (context, error, stackTrace) {
// //             return const Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Icon(Icons.broken_image, size: 50, color: Colors.grey),
// //                   SizedBox(height: 8),
// //                   Text(
// //                     'Cannot load image',
// //                     style: TextStyle(color: Colors.grey),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         ),
// //       );
// //     } else {
// //       return const Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
// //             SizedBox(height: 8),
// //             Text('Tap to add image', style: TextStyle(color: Colors.grey)),
// //           ],
// //         ),
// //       );
// //     }
// //   }
// // }
// //
// // // Popup for Adding Complete About Us Section
// // class AddAboutUsSectionPopup extends StatefulWidget {
// //   final AboutUsModel? aboutUs;
// //   final Function(String, File?, String, String) onSave;
// //
// //   const AddAboutUsSectionPopup({super.key, this.aboutUs, required this.onSave});
// //
// //   @override
// //   State<AddAboutUsSectionPopup> createState() => _AddAboutUsSectionPopupState();
// // }
// //
// // class _AddAboutUsSectionPopupState extends State<AddAboutUsSectionPopup> {
// //   static const Color primaryColor = Color(0xFF67B95F);
// //   final ImagePicker _picker = ImagePicker();
// //   File? _aboutUsImage;
// //   final TextEditingController _aboutUsController = TextEditingController();
// //   final TextEditingController _missionController = TextEditingController();
// //   final TextEditingController _visionController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize with existing data if available
// //     if (widget.aboutUs?.aboutUs != null) {
// //       _aboutUsController.text = widget.aboutUs!.aboutUs;
// //     }
// //     if (widget.aboutUs?.mission != null) {
// //       _missionController.text = widget.aboutUs!.mission!;
// //     }
// //     if (widget.aboutUs?.vision != null) {
// //       _visionController.text = widget.aboutUs!.vision!;
// //     }
// //   }
// //
// //   Future<void> _pickImage() async {
// //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _aboutUsImage = File(pickedFile.path);
// //       });
// //     }
// //   }
// //
// //   void _removeImage() {
// //     setState(() {
// //       _aboutUsImage = null;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double width = MediaQuery.of(context).size.width * 0.9;
// //
// //     return Dialog(
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       backgroundColor: Colors.white,
// //       insetPadding: const EdgeInsets.all(16),
// //       child: Container(
// //         width: width,
// //         padding: const EdgeInsets.all(16),
// //         constraints: const BoxConstraints(maxHeight: 600),
// //         child: Stack(
// //           children: [
// //             Positioned(
// //               top: 0,
// //               right: 0,
// //               child: IconButton(
// //                 icon: const Icon(Icons.close, color: Colors.black),
// //                 onPressed: () => Navigator.pop(context),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.only(top: 40),
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   children: [
// //                     const Text(
// //                       "Add About Us Section",
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                         color: primaryColor,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 20),
// //
// //                     // About Us Image Upload Section
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           "About Us Image (Optional)",
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         InkWell(
// //                           onTap: _pickImage,
// //                           child: Container(
// //                             height: 150,
// //                             width: double.infinity,
// //                             decoration: BoxDecoration(
// //                               color: Colors.grey.shade200,
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(color: Colors.grey.shade400),
// //                             ),
// //                             child: _aboutUsImage != null
// //                                 ? ClipRRect(
// //                                     borderRadius: BorderRadius.circular(12),
// //                                     child: Image.file(
// //                                       _aboutUsImage!,
// //                                       fit: BoxFit.cover,
// //                                     ),
// //                                   )
// //                                 : const Center(
// //                                     child: Column(
// //                                       mainAxisAlignment:
// //                                           MainAxisAlignment.center,
// //                                       children: [
// //                                         Icon(
// //                                           Icons.add_photo_alternate,
// //                                           size: 50,
// //                                           color: Colors.grey,
// //                                         ),
// //                                         SizedBox(height: 8),
// //                                         Text(
// //                                           'Tap to add image (Optional)',
// //                                           style: TextStyle(color: Colors.grey),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         if (_aboutUsImage != null)
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.end,
// //                             children: [
// //                               ElevatedButton.icon(
// //                                 onPressed: _pickImage,
// //                                 icon: const Icon(Icons.edit, size: 16),
// //                                 label: const Text("Change"),
// //                                 style: ElevatedButton.styleFrom(
// //                                   backgroundColor: primaryColor,
// //                                   foregroundColor: Colors.white,
// //                                   padding: const EdgeInsets.symmetric(
// //                                     horizontal: 12,
// //                                     vertical: 6,
// //                                   ),
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 8),
// //                               OutlinedButton.icon(
// //                                 onPressed: _removeImage,
// //                                 icon: const Icon(
// //                                   Icons.delete,
// //                                   size: 16,
// //                                   color: Colors.red,
// //                                 ),
// //                                 label: const Text(
// //                                   "Remove",
// //                                   style: TextStyle(color: Colors.red),
// //                                 ),
// //                                 style: OutlinedButton.styleFrom(
// //                                   padding: const EdgeInsets.symmetric(
// //                                     horizontal: 12,
// //                                     vertical: 6,
// //                                   ),
// //                                   side: const BorderSide(color: Colors.red),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 20),
// //
// //                     // About Us Text Section
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           "About Us Text",
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         TextField(
// //                           controller: _aboutUsController,
// //                           maxLines: 3,
// //                           decoration: InputDecoration(
// //                             hintText: 'Write about your company...',
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                             contentPadding: const EdgeInsets.all(12),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 20),
// //
// //                     // Mission Section
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           "Mission *",
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         TextField(
// //                           controller: _missionController,
// //                           maxLines: 3,
// //                           decoration: InputDecoration(
// //                             hintText: 'Enter your mission statement...',
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                             contentPadding: const EdgeInsets.all(12),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 20),
// //
// //                     // Vision Section
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           "Vision *",
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         TextField(
// //                           controller: _visionController,
// //                           maxLines: 3,
// //                           decoration: InputDecoration(
// //                             hintText: 'Enter your vision statement...',
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                             contentPadding: const EdgeInsets.all(12),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 30),
// //
// //                     // Action Buttons
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                       children: [
// //                         Expanded(
// //                           child: OutlinedButton.icon(
// //                             onPressed: () => Navigator.pop(context),
// //                             icon: const Icon(Icons.cancel_outlined),
// //                             label: const Text("Cancel"),
// //                             style: OutlinedButton.styleFrom(
// //                               padding: const EdgeInsets.symmetric(vertical: 12),
// //                               side: BorderSide(color: Colors.grey.shade400),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 16),
// //                         Expanded(
// //                           child: ElevatedButton.icon(
// //                             onPressed: () {
// //                               final mission = _missionController.text.trim();
// //                               final vision = _visionController.text.trim();
// //
// //                               if (mission.isEmpty || vision.isEmpty) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(
// //                                     content: Text(
// //                                       'Please fill both Mission and Vision',
// //                                     ),
// //                                   ),
// //                                 );
// //                                 return;
// //                               }
// //
// //                               widget.onSave(
// //                                 _aboutUsController.text.trim(),
// //                                 _aboutUsImage,
// //                                 mission,
// //                                 vision,
// //                               );
// //                             },
// //                             icon: const Icon(Icons.add),
// //                             label: const Text("Add All"),
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: primaryColor,
// //                               foregroundColor: Colors.white,
// //                               padding: const EdgeInsets.symmetric(vertical: 12),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Keep existing UploadBannerPopup class (unchanged)
// // class UploadBannerPopup extends StatefulWidget {
// //   const UploadBannerPopup({super.key});
// //
// //   @override
// //   State<UploadBannerPopup> createState() => _UploadBannerPopupState();
// // }
// //
// // class _UploadBannerPopupState extends State<UploadBannerPopup> {
// //   static const Color primaryColor = Color(0xFF67B95F);
// //   final ImagePicker _picker = ImagePicker();
// //   File? _bannerImage;
// //   File? _logoImage;
// //
// //   Future<void> _pickImage(bool isBanner) async {
// //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         if (isBanner) {
// //           _bannerImage = File(pickedFile.path);
// //         } else {
// //           _logoImage = File(pickedFile.path);
// //         }
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double width = MediaQuery.of(context).size.width * 0.9;
// //
// //     return Dialog(
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       backgroundColor: Colors.white,
// //       insetPadding: const EdgeInsets.all(16),
// //       child: Container(
// //         width: width,
// //         padding: const EdgeInsets.all(16),
// //         constraints: const BoxConstraints(maxHeight: 600),
// //         child: Stack(
// //           children: [
// //             Positioned(
// //               top: 0,
// //               right: 0,
// //               child: IconButton(
// //                 icon: const Icon(Icons.close, color: Colors.black),
// //                 onPressed: () => Navigator.pop(context),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.only(top: 40),
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   children: [
// //                     const Text(
// //                       "Upload Banner Details",
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                         color: primaryColor,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 20),
// //                     _buildTextField("Name"),
// //                     _buildTextField("Established Year"),
// //                     _buildUploadBox("Banner Image", _bannerImage, true),
// //                     _buildUploadBox("Logo Image", _logoImage, false),
// //                     _buildTextFieldWithIcon("Website Link", Icons.language),
// //                     _buildTextFieldWithIcon(
// //                       "Facebook Link",
// //                       FontAwesomeIcons.facebook,
// //                     ),
// //                     _buildTextFieldWithIcon(
// //                       "Twitter Link",
// //                       FontAwesomeIcons.twitter,
// //                     ),
// //                     _buildTextFieldWithIcon(
// //                       "Instagram Link",
// //                       FontAwesomeIcons.instagram,
// //                     ),
// //                     _buildTextFieldWithIcon(
// //                       "WhatsApp Link",
// //                       FontAwesomeIcons.whatsapp,
// //                     ),
// //                     _buildTextFieldWithIcon(
// //                       "LinkedIn Link",
// //                       FontAwesomeIcons.linkedin,
// //                     ),
// //                     _buildTextFieldWithIcon(
// //                       "YouTube Link",
// //                       FontAwesomeIcons.youtube,
// //                     ),
// //                     const SizedBox(height: 20),
// //                     ElevatedButton.icon(
// //                       onPressed: () => Navigator.pop(context),
// //                       icon: const Icon(Icons.check_circle_outline),
// //                       label: const Text("Submit"),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: primaryColor,
// //                         foregroundColor: Colors.white,
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 40,
// //                           vertical: 12,
// //                         ),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildUploadBox(String label, File? imageFile, bool isBanner) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             label,
// //             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(height: 6),
// //           InkWell(
// //             onTap: () => _pickImage(isBanner),
// //             child: Container(
// //               height: 120,
// //               decoration: BoxDecoration(
// //                 color: Colors.grey.shade200,
// //                 borderRadius: BorderRadius.circular(10),
// //                 border: Border.all(color: Colors.grey.shade400),
// //               ),
// //               child: imageFile != null
// //                   ? ClipRRect(
// //                       borderRadius: BorderRadius.circular(10),
// //                       child: Image.file(
// //                         imageFile,
// //                         width: double.infinity,
// //                         fit: BoxFit.cover,
// //                       ),
// //                     )
// //                   : const Center(
// //                       child: Icon(
// //                         Icons.camera_alt,
// //                         size: 40,
// //                         color: Colors.grey,
// //                       ),
// //                     ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTextField(String label) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: TextField(
// //         decoration: InputDecoration(
// //           labelText: label,
// //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTextFieldWithIcon(String label, IconData icon) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: TextField(
// //         decoration: InputDecoration(
// //           prefixIcon: Icon(icon, color: primaryColor),
// //           labelText: label,
// //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:maamaaspartner/Api/food_authservice.dart';
// import '../Models/food&beverages/aboutus_model.dart';
// import '../Models/food&beverages/bannermodel.dart';
//
// // ─── Design tokens ─────────────────────────────────────────────────────────────
// const _cPrimary = Color(0xFF67B95F);
// const _cPrimaryLt = Color(0xFFEDF9EC);
// const _cSurface = Color(0xFFFFFFFF);
// const _cBg = Color(0xFFF6F7FA);
// const _cBorder = Color(0xFFECEDF2);
// const _cText = Color(0xFF111827);
// const _cSub = Color(0xFF6B7280);
// const _cMuted = Color(0xFFB0B3C1);
//
// class Banner_screen extends StatefulWidget {
//   const Banner_screen({super.key});
//   @override
//   State<Banner_screen> createState() => _BannerScreenState();
// }
//
// class _BannerScreenState extends State<Banner_screen> {
//   bool _isOpen = true;
//   bool _showDetails = false;
//   BannerModel? _banner;
//   AboutUsModel? _aboutUs;
//   bool _isLoading = true;
//   bool _isLoadingAboutUs = true;
//   String _errorMessage = '';
//
//   final PageController _galleryCtrl = PageController(viewportFraction: 0.88);
//   List<String> _galleryImages = [
//     'assets/fruits.png',
//     'assets/Dry fruits.png',
//     'assets/Bread.png',
//     'assets/Drinks.png',
//   ];
//   int _currentPage = 0;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//     _loadAllData();
//   }
//
//   Future<void> _loadAllData() async {
//     await Future.wait([_loadBanner(), _loadAboutUs()]);
//   }
//
//   Future<void> _loadBanner() async {
//     try {
//       final banner = await food_authservice.fetchVendorBanner();
//       setState(() {
//         _banner = banner;
//         _isLoading = false;
//         if (banner == null) _errorMessage = 'No banner data found';
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Error: $e';
//       });
//     }
//   }
//
//   Future<void> _loadAboutUs() async {
//     try {
//       final aboutUs = await food_authservice.fetchVendorAboutUs();
//       if (aboutUs != null) {
//         final apiImages = aboutUs.getGalleryImages();
//         setState(() {
//           _aboutUs = aboutUs;
//           _isLoadingAboutUs = false;
//           if (apiImages.isNotEmpty) _galleryImages = apiImages;
//         });
//       } else {
//         setState(() => _isLoadingAboutUs = false);
//       }
//     } catch (e) {
//       setState(() => _isLoadingAboutUs = false);
//     }
//   }
//
//   void _startAutoScroll() {
//     _timer = Timer.periodic(const Duration(seconds: 3), (_) {
//       if (_galleryImages.isEmpty) return;
//       _currentPage = (_currentPage + 1) % _galleryImages.length;
//       _galleryCtrl.animateToPage(
//         _currentPage,
//         duration: const Duration(milliseconds: 600),
//         curve: Curves.easeInOut,
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _galleryCtrl.dispose();
//     super.dispose();
//   }
//
//   // ── Edit handlers ─────────────────────────────────────────────────────────
//   void _handleMissionVisionEdit() {
//     final mc = TextEditingController(text: _aboutUs?.mission ?? '');
//     final vc = TextEditingController(text: _aboutUs?.vision ?? '');
//     showDialog(
//       context: context,
//       builder: (_) => _EditDialog(
//         title: 'Mission & Vision',
//         icon: Icons.lightbulb_rounded,
//         children: [
//           _DialogField(ctrl: mc, label: 'Mission', lines: 3),
//           const SizedBox(height: 12),
//           _DialogField(ctrl: vc, label: 'Vision', lines: 3),
//         ],
//         onSave: () async {
//           if (mc.text.trim().isEmpty || vc.text.trim().isEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Fill both Mission & Vision')),
//             );
//             return;
//           }
//           _showLoader();
//           final ok = await food_authservice.updateAboutUsComplete(
//             aboutUs: _aboutUs?.aboutUs ?? '',
//             mission: mc.text.trim(),
//             vision: vc.text.trim(),
//             image: null,
//           );
//           _hideLoader();
//           Navigator.pop(context);
//           if (ok) {
//             setState(() {
//               _aboutUs = _aboutUs?.copyWith(
//                 mission: mc.text.trim(),
//                 vision: vc.text.trim(),
//               );
//             });
//             _snack('Updated!', success: true);
//           } else {
//             _snack('Update failed');
//           }
//         },
//       ),
//     );
//   }
//
//   void _handleAboutUsEdit() {
//     showDialog(
//       context: context,
//       builder: (_) => EditAboutUsCompletePopup(
//         aboutUs: _aboutUs,
//         onSave: (text, file) async {
//           _showLoader();
//           final ok = await food_authservice.updateAboutUsComplete(
//             aboutUs: text,
//             mission: _aboutUs?.mission,
//             vision: _aboutUs?.vision,
//             image: file,
//           );
//           _hideLoader();
//           if (ok) {
//             setState(() {
//               _aboutUs = _aboutUs?.copyWith(aboutUs: text);
//             });
//             await _loadAboutUs();
//             _snack('About Us updated!', success: true);
//           } else {
//             _snack('Update failed');
//           }
//         },
//       ),
//     );
//   }
//
//   void _handleAddAboutUsSection() {
//     showDialog(
//       context: context,
//       builder: (_) => AddAboutUsSectionPopup(
//         aboutUs: _aboutUs,
//         onSave: (text, file, mission, vision) async {
//           _showLoader();
//           final ok = await food_authservice.updateAboutUsComplete(
//             aboutUs: text,
//             mission: mission,
//             vision: vision,
//             image: file,
//           );
//           _hideLoader();
//           Navigator.pop(context);
//           if (ok) {
//             await _loadAboutUs();
//             _snack('Added successfully!', success: true);
//           } else {
//             _snack('Failed to add');
//           }
//         },
//       ),
//     );
//   }
//
//   void _showLoader() => showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) =>
//         const Center(child: CircularProgressIndicator(color: _cPrimary)),
//   );
//
//   void _hideLoader() {
//     if (mounted && Navigator.canPop(context)) Navigator.pop(context);
//   }
//
//   void _snack(String msg, {bool success = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: success ? _cPrimary : Colors.red,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _cBg,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 12),
//             _buildBanner(),
//             if (_errorMessage.isNotEmpty) _buildError(),
//             const SizedBox(height: 16),
//             _buildStatusToggle(),
//             const SizedBox(height: 16),
//             if (_showDetails) ...[
//               _buildAboutSection(),
//               const SizedBox(height: 16),
//             ],
//             // _buildGallery(),
//             // const SizedBox(height: 80),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Banner ────────────────────────────────────────────────────────────────
//   Widget _buildBanner() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Container(
//               height: 200,
//               width: double.infinity,
//               child: _isLoading
//                   ? Container(
//                       color: Colors.grey.shade200,
//                       child: const Center(
//                         child: CircularProgressIndicator(color: _cPrimary),
//                       ),
//                     )
//                   : (_banner?.companyBanner.isNotEmpty == true
//                         ? Image.network(
//                             _banner!.companyBanner,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Image.asset(
//                               'assets/Groceries.png',
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : Image.asset(
//                             'assets/Groceries.png',
//                             fit: BoxFit.cover,
//                           )),
//             ),
//           ),
//           // Dark gradient overlay
//           ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
//                 ),
//               ),
//             ),
//           ),
//           // Logo top-left
//           // Positioned(
//           //   top: 14,
//           //   left: 14,
//           //   child: Container(
//           //     padding: const EdgeInsets.all(2),
//           //     decoration: BoxDecoration(
//           //       color: Colors.white,
//           //       shape: BoxShape.circle,
//           //       boxShadow: [
//           //         BoxShadow(
//           //           color: Colors.black26,
//           //           blurRadius: 6,
//           //           offset: const Offset(0, 2),
//           //         ),
//           //       ],
//           //     ),
//           //     child: CircleAvatar(
//           //       radius: 26,
//           //       backgroundColor: Colors.grey.shade100,
//           //       backgroundImage: _getLogoImage(),
//           //     ),
//           //   ),
//           // ),
//           // Add+ top-right
//           Positioned(
//             top: 14,
//             right: 14,
//             child: GestureDetector(
//               onTap: () => showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) => const UploadBannerPopup(),
//               ),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 7,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _cPrimary.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(9),
//                   border: Border.all(color: Colors.white, width: 1.5),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.add_rounded, color: Colors.white, size: 15),
//                     SizedBox(width: 4),
//                     Text(
//                       'Edit Banner',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Company name bottom
//           Positioned(
//             bottom: 14,
//             left: 14,
//             right: 14,
//             child: Column(
//               children: [
//                 Text(
//                   _isLoading
//                       ? 'Loading...'
//                       : (_banner?.companyName.isNotEmpty == true
//                             ? _banner!.companyName
//                             : 'FRESH & GROCERIES'),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.5,
//                     shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 if (_banner?.establishedYear.isNotEmpty == true) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     'Est. ${_banner!.establishedYear}',
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   ImageProvider _getLogoImage() {
//     if (_isLoading) return const AssetImage('assets/maamaslogo.png');
//     if (_banner?.companyLogo.isNotEmpty == true)
//       return NetworkImage(_banner!.companyLogo);
//     return const AssetImage('assets/maamaslogo.png');
//   }
//
//   Widget _buildError() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.orange.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.orange.shade200),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.info_outline_rounded,
//               color: Colors.orange.shade700,
//               size: 18,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 _errorMessage,
//                 style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Status toggle ─────────────────────────────────────────────────────────
//   Widget _buildStatusToggle() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: _cSurface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: _cBorder),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Open/Closed pill
//             GestureDetector(
//               onTap: () => setState(() => _isOpen = !_isOpen),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 220),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _isOpen
//                       ? const Color(0xFFD1FAE5)
//                       : const Color(0xFFFEE2E2),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: _isOpen
//                         ? const Color(0xFF10B981).withOpacity(0.3)
//                         : const Color(0xFFEF4444).withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: _isOpen
//                             ? const Color(0xFF10B981)
//                             : const Color(0xFFEF4444),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 7),
//                     Text(
//                       _isOpen ? 'OPEN' : 'CLOSED',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 12,
//                         color: _isOpen
//                             ? const Color(0xFF059669)
//                             : const Color(0xFFEF4444),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const Spacer(),
//             // Know more
//             GestureDetector(
//               onTap: () => setState(() => _showDetails = !_showDetails),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _cPrimaryLt,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: _cPrimary.withOpacity(0.25)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       _showDetails ? 'Show Less' : 'Know More',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: _cPrimary,
//                       ),
//                     ),
//                     const SizedBox(width: 5),
//                     AnimatedRotation(
//                       turns: _showDetails ? 0.5 : 0,
//                       duration: const Duration(milliseconds: 200),
//                       child: const Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         color: _cPrimary,
//                         size: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── About section ─────────────────────────────────────────────────────────
//   Widget _buildAboutSection() {
//     final hasImage = _aboutUs?.image.isNotEmpty == true;
//     final hasMission = _aboutUs?.mission?.isNotEmpty == true;
//     final hasVision = _aboutUs?.vision?.isNotEmpty == true;
//     final hasText = _aboutUs?.aboutUs.isNotEmpty == true;
//     final showAdd = !hasText && !hasImage && !hasMission && !hasVision;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           // About Us card
//           _InfoCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       hasText ? _aboutUs!.aboutUs.toUpperCase() : 'ABOUT US',
//                       style: const TextStyle(
//                         color: _cPrimary,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(width: 6),
//                     _EditIconBtn(
//                       onTap: _handleAboutUsEdit,
//                       icon: hasText ? Icons.edit_rounded : Icons.add_rounded,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 // Image
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         height: 170,
//                         width: double.infinity,
//                         color: Colors.grey.shade100,
//                         child: _isLoadingAboutUs
//                             ? const Center(
//                                 child: CircularProgressIndicator(
//                                   color: _cPrimary,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : hasImage
//                             ? Image.network(
//                                 _aboutUs!.image,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, __, ___) => Image.asset(
//                                   'assets/Groceries.png',
//                                   fit: BoxFit.cover,
//                                 ),
//                               )
//                             : Image.asset(
//                                 'assets/Groceries.png',
//                                 fit: BoxFit.cover,
//                               ),
//                       ),
//                     ),
//                     if (!hasImage)
//                       Positioned(
//                         top: 8,
//                         right: 8,
//                         child: GestureDetector(
//                           onTap: _handleAboutUsEdit,
//                           child: Container(
//                             padding: const EdgeInsets.all(7),
//                             decoration: BoxDecoration(
//                               color: _cPrimary,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.add_a_photo_rounded,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   hasText ? _aboutUs!.aboutUs : 'No description added yet.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13,
//                     height: 1.5,
//                     color: hasText ? _cText : _cMuted,
//                     fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           // Mission & Vision card
//           _InfoCard(
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'MISSION & VISION',
//                       style: TextStyle(
//                         color: _cPrimary,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     _EditIconBtn(
//                       onTap: _handleMissionVisionEdit,
//                       icon: (hasMission || hasVision)
//                           ? Icons.edit_rounded
//                           : Icons.add_rounded,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _MVBox(
//                         icon: Icons.flag_rounded,
//                         label: 'Mission',
//                         text: hasMission ? _aboutUs!.mission! : 'Not added yet',
//                         hasContent: hasMission,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _MVBox(
//                         icon: Icons.visibility_rounded,
//                         label: 'Vision',
//                         text: hasVision ? _aboutUs!.vision! : 'Not added yet',
//                         hasContent: hasVision,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           if (showAdd) ...[
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: _handleAddAboutUsSection,
//               child: Container(
//                 height: 50,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: _cPrimaryLt,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: _cPrimary.withOpacity(0.3)),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add_circle_outline_rounded,
//                       color: _cPrimary,
//                       size: 18,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Add About Us Section',
//                       style: TextStyle(
//                         color: _cPrimary,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ── Gallery ───────────────────────────────────────────────────────────────
//   // Widget _buildGallery() {
//   //   return Column(
//   //     children: [
//   //       Padding(
//   //         padding: const EdgeInsets.symmetric(horizontal: 16),
//   //         child: Row(
//   //           children: [
//   //             Container(
//   //               width: 4,
//   //               height: 20,
//   //               decoration: BoxDecoration(
//   //                 color: _cPrimary,
//   //                 borderRadius: BorderRadius.circular(2),
//   //               ),
//   //             ),
//   //             const SizedBox(width: 10),
//   //             const Text(
//   //               'GALLERY',
//   //               style: TextStyle(
//   //                 fontSize: 16,
//   //                 fontWeight: FontWeight.w800,
//   //                 color: _cText,
//   //                 letterSpacing: 1,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //       const SizedBox(height: 12),
//   //       SizedBox(
//   //         height: 180,
//   //         child: _galleryImages.isNotEmpty
//   //             ? PageView.builder(
//   //                 controller: _galleryCtrl,
//   //                 itemCount: _galleryImages.length,
//   //                 itemBuilder: (_, i) {
//   //                   final url = _galleryImages[i];
//   //                   final isAsset = url.startsWith('assets/');
//   //                   return Padding(
//   //                     padding: const EdgeInsets.symmetric(horizontal: 6),
//   //                     child: ClipRRect(
//   //                       borderRadius: BorderRadius.circular(14),
//   //                       child: isAsset
//   //                           ? Image.asset(url, fit: BoxFit.cover)
//   //                           : Image.network(
//   //                               url,
//   //                               fit: BoxFit.cover,
//   //                               loadingBuilder: (_, child, prog) {
//   //                                 if (prog == null) return child;
//   //                                 return Container(
//   //                                   color: Colors.grey.shade200,
//   //                                   child: const Center(
//   //                                     child: CircularProgressIndicator(
//   //                                       color: _cPrimary,
//   //                                       strokeWidth: 2,
//   //                                     ),
//   //                                   ),
//   //                                 );
//   //                               },
//   //                               errorBuilder: (_, __, ___) => Container(
//   //                                 color: Colors.grey.shade200,
//   //                                 child: const Center(
//   //                                   child: Icon(
//   //                                     Icons.broken_image_rounded,
//   //                                     color: Colors.grey,
//   //                                     size: 40,
//   //                                   ),
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                     ),
//   //                   );
//   //                 },
//   //               )
//   //             : const Center(
//   //                 child: Text(
//   //                   'No gallery images',
//   //                   style: TextStyle(color: _cMuted),
//   //                 ),
//   //               ),
//   //       ),
//   //     ],
//   //   );
//   // }
// }
//
// // ── Helper widgets ────────────────────────────────────────────────────────────
// class _InfoCard extends StatelessWidget {
//   final Widget child;
//   const _InfoCard({required this.child});
//   @override
//   Widget build(BuildContext context) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: _cSurface,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: _cBorder),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.04),
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: child,
//   );
// }
//
// class _EditIconBtn extends StatelessWidget {
//   final VoidCallback onTap;
//   final IconData icon;
//   const _EditIconBtn({required this.onTap, required this.icon});
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       width: 28,
//       height: 28,
//       decoration: BoxDecoration(
//         color: _cPrimaryLt,
//         borderRadius: BorderRadius.circular(7),
//       ),
//       child: Icon(icon, color: _cPrimary, size: 15),
//     ),
//   );
// }
//
// class _MVBox extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String text;
//   final bool hasContent;
//   const _MVBox({
//     required this.icon,
//     required this.label,
//     required this.text,
//     required this.hasContent,
//   });
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: hasContent ? _cPrimaryLt : _cBg,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(
//         color: hasContent ? _cPrimary.withOpacity(0.2) : _cBorder,
//       ),
//     ),
//     child: Column(
//       children: [
//         Icon(icon, color: hasContent ? _cPrimary : _cMuted, size: 20),
//         const SizedBox(height: 6),
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w700,
//             fontSize: 12,
//             color: _cText,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           text,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 11,
//             height: 1.4,
//             color: hasContent ? _cSub : _cMuted,
//             fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
//           ),
//           maxLines: 3,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     ),
//   );
// }
//
// class _DialogField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String label;
//   final int lines;
//   const _DialogField({required this.ctrl, required this.label, this.lines = 1});
//   @override
//   Widget build(BuildContext context) => TextField(
//     controller: ctrl,
//     maxLines: lines,
//     decoration: InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       contentPadding: const EdgeInsets.all(12),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _cPrimary, width: 2),
//       ),
//     ),
//   );
// }
//
// class _EditDialog extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final List<Widget> children;
//   final VoidCallback onSave;
//   const _EditDialog({
//     required this.title,
//     required this.icon,
//     required this.children,
//     required this.onSave,
//   });
//   @override
//   Widget build(BuildContext context) => Dialog(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     backgroundColor: _cSurface,
//     insetPadding: const EdgeInsets.all(20),
//     child: Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 34,
//                 height: 34,
//                 decoration: BoxDecoration(
//                   color: _cPrimaryLt,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: Icon(icon, color: _cPrimary, size: 17),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 15,
//                   color: _cText,
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.close_rounded, color: _cSub, size: 20),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...children,
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: _cBorder),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: _cSub, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: onSave,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _cPrimary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Save',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // UPLOAD BANNER POPUP
// // ══════════════════════════════════════════════════════════════════════════════
// class UploadBannerPopup extends StatefulWidget {
//   const UploadBannerPopup({super.key});
//   @override
//   State<UploadBannerPopup> createState() => _UploadBannerPopupState();
// }
//
// class _UploadBannerPopupState extends State<UploadBannerPopup> {
//   final ImagePicker _picker = ImagePicker();
//   File? _bannerImage;
//   File? _logoImage;
//
//   Future<void> _pickImage(bool isBanner) async {
//     final f = await _picker.pickImage(source: ImageSource.gallery);
//     if (f != null)
//       setState(() {
//         if (isBanner)
//           _bannerImage = File(f.path);
//         else
//           _logoImage = File(f.path);
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       backgroundColor: _cSurface,
//       insetPadding: const EdgeInsets.all(16),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//         constraints: const BoxConstraints(maxHeight: 620),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 34,
//                   height: 34,
//                   decoration: BoxDecoration(
//                     color: _cPrimaryLt,
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                   child: const Icon(
//                     Icons.photo_library_rounded,
//                     color: _cPrimary,
//                     size: 17,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'Upload Banner Details',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 15,
//                     color: _cText,
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(
//                     Icons.close_rounded,
//                     color: _cSub,
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             const Divider(color: _cBorder),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     _textField('Company Name'),
//                     _textField('Established Year', type: TextInputType.number),
//                     _uploadBox('Banner Image', _bannerImage, true),
//                     _uploadBox('Logo Image', _logoImage, false),
//                     _iconField('Website', Icons.language_rounded),
//                     _iconField('Facebook', FontAwesomeIcons.facebook),
//                     _iconField('Twitter', FontAwesomeIcons.twitter),
//                     _iconField('Instagram', FontAwesomeIcons.instagram),
//                     _iconField('WhatsApp', FontAwesomeIcons.whatsapp),
//                     _iconField('LinkedIn', FontAwesomeIcons.linkedin),
//                     _iconField('YouTube', FontAwesomeIcons.youtube),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () => Navigator.pop(context),
//                         icon: const Icon(
//                           Icons.check_circle_outline_rounded,
//                           size: 18,
//                         ),
//                         label: const Text(
//                           'Submit',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _cPrimary,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _textField(String label, {TextInputType type = TextInputType.text}) =>
//       Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: TextField(
//           keyboardType: type,
//           decoration: InputDecoration(
//             labelText: label,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 12,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: _cPrimary, width: 2),
//             ),
//           ),
//         ),
//       );
//
//   Widget _iconField(String label, IconData icon) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: TextField(
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: _cPrimary, size: 18),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 12,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _cPrimary, width: 2),
//         ),
//       ),
//     ),
//   );
//
//   Widget _uploadBox(String label, File? file, bool isBanner) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//             color: _cText,
//           ),
//         ),
//         const SizedBox(height: 6),
//         InkWell(
//           onTap: () => _pickImage(isBanner),
//           borderRadius: BorderRadius.circular(10),
//           child: Container(
//             height: 110,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: _cBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(
//                 color: file != null ? _cPrimary : _cBorder,
//                 width: file != null ? 1.5 : 1,
//               ),
//             ),
//             child: file != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.file(file, fit: BoxFit.cover),
//                   )
//                 : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: const [
//                       Icon(
//                         Icons.cloud_upload_rounded,
//                         size: 36,
//                         color: _cMuted,
//                       ),
//                       SizedBox(height: 6),
//                       Text(
//                         'Tap to upload',
//                         style: TextStyle(color: _cMuted, fontSize: 12),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // EDIT ABOUT US POPUP
// // ══════════════════════════════════════════════════════════════════════════════
// class EditAboutUsCompletePopup extends StatefulWidget {
//   final AboutUsModel? aboutUs;
//   final Function(String, File?) onSave;
//   const EditAboutUsCompletePopup({
//     super.key,
//     this.aboutUs,
//     required this.onSave,
//   });
//   @override
//   State<EditAboutUsCompletePopup> createState() =>
//       _EditAboutUsCompletePopupState();
// }
//
// class _EditAboutUsCompletePopupState extends State<EditAboutUsCompletePopup> {
//   final _picker = ImagePicker();
//   File? _image;
//   late TextEditingController _ctrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = TextEditingController(text: widget.aboutUs?.aboutUs ?? '');
//   }
//
//   Future<void> _pick() async {
//     final f = await _picker.pickImage(source: ImageSource.gallery);
//     if (f != null) setState(() => _image = File(f.path));
//   }
//
//   @override
//   Widget build(BuildContext context) => Dialog(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//     backgroundColor: _cSurface,
//     insetPadding: const EdgeInsets.all(16),
//     child: Container(
//       padding: const EdgeInsets.all(20),
//       constraints: const BoxConstraints(maxHeight: 540),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 34,
//                 height: 34,
//                 decoration: BoxDecoration(
//                   color: _cPrimaryLt,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: const Icon(
//                   Icons.edit_rounded,
//                   color: _cPrimary,
//                   size: 17,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Edit About Us',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 15,
//                   color: _cText,
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.close_rounded, color: _cSub, size: 20),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           const Divider(color: _cBorder),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Image',
//                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//                   ),
//                   const SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: _pick,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         height: 140,
//                         width: double.infinity,
//                         color: _cBg,
//                         child: _buildImagePreview(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   const Text(
//                     'About Us Text',
//                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _ctrl,
//                     maxLines: 4,
//                     decoration: InputDecoration(
//                       hintText: 'Write about your company...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       contentPadding: const EdgeInsets.all(12),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                           color: _cPrimary,
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: _cBorder),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: _cSub, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_ctrl.text.trim().isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Enter About Us text')),
//                       );
//                       return;
//                     }
//                     widget.onSave(_ctrl.text, _image);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _cPrimary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Save',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _buildImagePreview() {
//     if (_image != null) return Image.file(_image!, fit: BoxFit.cover);
//     if (widget.aboutUs?.image.isNotEmpty == true)
//       return Image.network(
//         widget.aboutUs!.image,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => _uploadPlaceholder(),
//       );
//     return _uploadPlaceholder();
//   }
//
//   Widget _uploadPlaceholder() => Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: const [
//       Icon(Icons.add_photo_alternate_rounded, size: 40, color: _cMuted),
//       SizedBox(height: 8),
//       Text('Tap to add image', style: TextStyle(color: _cMuted, fontSize: 12)),
//     ],
//   );
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // ADD ABOUT US SECTION POPUP
// // ══════════════════════════════════════════════════════════════════════════════
// class AddAboutUsSectionPopup extends StatefulWidget {
//   final AboutUsModel? aboutUs;
//   final Function(String, File?, String, String) onSave;
//   const AddAboutUsSectionPopup({super.key, this.aboutUs, required this.onSave});
//   @override
//   State<AddAboutUsSectionPopup> createState() => _AddAboutUsSectionPopupState();
// }
//
// class _AddAboutUsSectionPopupState extends State<AddAboutUsSectionPopup> {
//   final _picker = ImagePicker();
//   File? _image;
//   late TextEditingController _aboutCtrl, _missionCtrl, _visionCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _aboutCtrl = TextEditingController(text: widget.aboutUs?.aboutUs ?? '');
//     _missionCtrl = TextEditingController(text: widget.aboutUs?.mission ?? '');
//     _visionCtrl = TextEditingController(text: widget.aboutUs?.vision ?? '');
//   }
//
//   Future<void> _pick() async {
//     final f = await _picker.pickImage(source: ImageSource.gallery);
//     if (f != null) setState(() => _image = File(f.path));
//   }
//
//   @override
//   Widget build(BuildContext context) => Dialog(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//     backgroundColor: _cSurface,
//     insetPadding: const EdgeInsets.all(16),
//     child: Container(
//       padding: const EdgeInsets.all(20),
//       constraints: const BoxConstraints(maxHeight: 620),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 34,
//                 height: 34,
//                 decoration: BoxDecoration(
//                   color: _cPrimaryLt,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: const Icon(
//                   Icons.add_rounded,
//                   color: _cPrimary,
//                   size: 17,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Add About Us Section',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 15,
//                   color: _cText,
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.close_rounded, color: _cSub, size: 20),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           const Divider(color: _cBorder),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Image (Optional)',
//                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//                   ),
//                   const SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: _pick,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         height: 120,
//                         width: double.infinity,
//                         color: _cBg,
//                         child: _image != null
//                             ? Image.file(_image!, fit: BoxFit.cover)
//                             : Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: const [
//                                   Icon(
//                                     Icons.add_photo_alternate_rounded,
//                                     size: 36,
//                                     color: _cMuted,
//                                   ),
//                                   SizedBox(height: 6),
//                                   Text(
//                                     'Tap to add (optional)',
//                                     style: TextStyle(
//                                       color: _cMuted,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   _sectionField(_aboutCtrl, 'About Us Text', 3),
//                   const SizedBox(height: 10),
//                   _sectionField(_missionCtrl, 'Mission *', 3),
//                   const SizedBox(height: 10),
//                   _sectionField(_visionCtrl, 'Vision *', 3),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: _cBorder),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: _cSub, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_missionCtrl.text.trim().isEmpty ||
//                         _visionCtrl.text.trim().isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Fill Mission & Vision')),
//                       );
//                       return;
//                     }
//                     widget.onSave(
//                       _aboutCtrl.text.trim(),
//                       _image,
//                       _missionCtrl.text.trim(),
//                       _visionCtrl.text.trim(),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _cPrimary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Add All',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _sectionField(TextEditingController ctrl, String label, int lines) =>
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//           ),
//           const SizedBox(height: 6),
//           TextField(
//             controller: ctrl,
//             maxLines: lines,
//             decoration: InputDecoration(
//               hintText: 'Enter $label...',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               contentPadding: const EdgeInsets.all(12),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: _cPrimary, width: 2),
//               ),
//             ),
//           ),
//         ],
//       );
// }
