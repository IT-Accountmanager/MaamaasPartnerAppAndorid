// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:maamaaspartner/LoginScreen1/LoginScreen.dart';
//
// import 'TableServices.dart';
//
//
// class LandingPage extends StatefulWidget {
//   const LandingPage({super.key});
//
//   @override
//   State<LandingPage> createState() => _LandingPageState();
// }
//
// class _LandingPageState extends State<LandingPage> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isScrolled = false;
//   List<dynamic> _banners = [];
//   bool _isLoadingBanners = true;
//   int _currentSlide = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _fetchBanners();
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_scrollController.offset > 50 && !_isScrolled) {
//       setState(() => _isScrolled = true);
//     } else if (_scrollController.offset <= 50 && _isScrolled) {
//       setState(() => _isScrolled = false);
//     }
//   }
//
//   Future<void> _fetchBanners() async {
//     setState(() => _isLoadingBanners = true);
//
//     final result = await ApiService.getBanners();
//
//     if (result['success'] && mounted) {
//       final data = result['data'];
//
//       List<dynamic> bannerList = [];
//
//       if (data is List) {
//         bannerList = data;
//       } else if (data is Map) {
//         if (data['data'] is List) {
//           bannerList = data['data'];
//         } else {
//           bannerList = [data];
//         }
//       }
//
//       setState(() {
//         _banners = bannerList;
//         _isLoadingBanners = false;
//       });
//     } else {
//       if (mounted) {
//         setState(() => _isLoadingBanners = false);
//       }
//       debugPrint('Failed to load banners: ${result['message']}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // REMOVED Consumer<LoaderProvider> - no loader needed
//     return Scaffold(
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           // App Bar
//           SliverAppBar(
//             expandedHeight: 0,
//             pinned: true,
//             backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
//             elevation: _isScrolled ? 4 : 0,
//             centerTitle: true,
//             title: Text(
//               'MAAMAAS',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: _isScrolled ? Colors.black : Colors.white,
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   );
//                 },
//                 child: Text(
//                   'Sign In',
//                   style: TextStyle(
//                     color: _isScrolled ? Colors.black87 : Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE66D33),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: const Text('Get Started'),
//               ),
//               const SizedBox(width: 16),
//             ],
//           ),
//
//           // Hero Section
//           SliverToBoxAdapter(
//             child: _buildHeroSection(),
//           ),
//
//           // Add other sections as needed
//           const SliverToBoxAdapter(
//             child: SizedBox(height: 50),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeroSection() {
//     if (_isLoadingBanners) {
//       return Container(
//         height: 500,
//         color: Colors.grey[900],
//         child: const Center(
//           child: CircularProgressIndicator(color: Color(0xFFE66D33)),
//         ),
//       );
//     }
//
//     if (_banners.isEmpty) {
//       return _buildDefaultHero();
//     }
//
//     // Build slides from banners
//     List<Map<String, dynamic>> slides = [];
//     for (var banner in _banners) {
//       final images = [
//         banner['banner'],
//         banner['image1'],
//         banner['image2'],
//         banner['image3'],
//         banner['image4'],
//       ].where((img) => img != null && img.toString().isNotEmpty).toList();
//
//       for (var img in images) {
//         slides.add({
//           'image': img.toString(),
//           'companyName': banner['companyName']?.toString() ?? 'Maamaas',
//           'description': banner['description']?.toString() ?? 'Smart POS & Billing Solution',
//         });
//       }
//     }
//
//     if (slides.isEmpty) {
//       return _buildDefaultHero();
//     }
//
//     return Column(
//       children: [
//         CarouselSlider(
//           options: CarouselOptions(
//             height: 500,
//             autoPlay: true,
//             autoPlayInterval: const Duration(seconds: 3),
//             enlargeCenterPage: false,
//             viewportFraction: 1,
//             onPageChanged: (index, _) {
//               setState(() => _currentSlide = index);
//             },
//           ),
//           items: slides.map((slide) {
//             return Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(slide['image']),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.5),
//                       Colors.black.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//                 child: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           slide['companyName'],
//                           style: const TextStyle(
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           slide['description'],
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white.withOpacity(0.9),
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//         if (slides.length > 1)
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 slides.length,
//                     (index) => Container(
//                   width: 8,
//                   height: 8,
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _currentSlide == index
//                         ? const Color(0xFFE66D33)
//                         : Colors.grey.withOpacity(0.5),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildDefaultHero() {
//     return Container(
//       height: 500,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [const Color(0xFFE66D33), const Color(0xFFE66D33).withOpacity(0.8)],
//         ),
//       ),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Smart POS & Billing',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Management Software',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white70,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Manage your restaurant, cafe, or retail store with our powerful POS billing system.',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.9),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: const Color(0xFFE66D33),
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text('Get Started →'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }