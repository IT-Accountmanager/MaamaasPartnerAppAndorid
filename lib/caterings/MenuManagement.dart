// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../CateringModels/PackageItem.dart';
// import '../CateringModels/package_model.dart';
// import '../Catering_authservices/Auth_Services.dart';
// import 'AddPackage.dart';
// import 'UpdatePackagePage.dart';
//
// class MenuManagementPage extends StatefulWidget {
//   const MenuManagementPage({super.key});
//
//   @override
//   State<MenuManagementPage> createState() => _MenuManagementPageState();
// }
//
// class _MenuManagementPageState extends State<MenuManagementPage> {
//   final List<PackageModel> packages = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   int _selectedIndex = 0;
//
//   void _onBottomNavTap(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   Future<void> fetchPackages() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });
//
//     try {
//       final vendorId = await CateringService.getVendorId();
//       if (vendorId == null) {
//         throw Exception('Vendor not logged in');
//       }
//
//       final List<PackageModel> fetchedPackages =
//           await CateringService.getPackagesByVendor(vendorId);
//
//       setState(() {
//         packages.clear();
//         packages.addAll(fetchedPackages);
//         isLoading = false;
//       });
//
//       // Debug: Print package details
//       for (var pkg in packages) {
//         print("🖼 Package: ${pkg.packageName}");
//         print("🖼 Image URL: ${pkg.image}");
//         print("🖼 Items count: ${pkg.items.length}");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Failed to load packages: $e';
//       });
//       print('⚠️ Error fetching packages: $e');
//     }
//   }
//
//   Future<void> deletePackage(int packageId) async {
//     try {
//       final vendorId = await CateringService.getVendorId();
//       if (vendorId == null) {
//         throw Exception('Vendor not logged in');
//       }
//
//       final success = await CateringService.deletePackage(packageId);
//
//       if (success) {
//         // ✅ Success — remove from list
//         setState(() {
//           packages.removeWhere((pkg) => pkg.id == packageId);
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Package deleted successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to delete package'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error deleting package: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPackages(); // 🔹 Fetch data on page load
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Menu Management",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         actions: [],
//       ),
//
//       // 🔹 Main Body
//       body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
//
//       // 🔹 Floating Button
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: Colors.deepPurple,
//         label: const Text(
//           "+ Add Package",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddPackagePage(
//                 onPackageAdded: (pkg) {
//                   setState(() => packages.add(pkg));
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.deepPurple),
//       );
//     }
//
//     if (errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, size: 64, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(
//               errorMessage,
//               style: const TextStyle(color: Colors.red, fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: fetchPackages,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (packages.isEmpty) {
//       return const Center(
//         child: Text(
//           "No packages added yet",
//           style: TextStyle(color: Colors.grey, fontSize: 18),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       itemCount: packages.length,
//       itemBuilder: (context, index) {
//         final pkg = packages[index];
//         return Card(
//           elevation: 4,
//           margin: const EdgeInsets.only(bottom: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Image Display
//                     if (pkg.image != null && pkg.image!.isNotEmpty)
//                       _buildPackageImage(pkg.image!)
//                     else
//                       _buildNoImagePlaceholder(),
//
//                     const SizedBox(height: 10),
//                     _buildPackageName(pkg.packageName),
//                     const SizedBox(height: 6),
//                     _buildPackageType(pkg.packageType),
//                     const SizedBox(height: 10),
//                     _buildItemsList(pkg.items),
//                     const SizedBox(height: 10),
//                     _buildTotalPrice(pkg.totalPrice),
//                   ],
//                 ),
//               ),
//
//               // Action Buttons
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Row(
//                   children: [
//                     // Edit Button
//                     _buildActionButton(
//                       icon: Icons.edit,
//                       color: Colors.blue,
//                       onTap: () => _onEditPackage(pkg),
//                     ),
//                     const SizedBox(width: 8),
//                     // Delete Button
//                     _buildActionButton(
//                       icon: Icons.delete,
//                       color: Colors.red,
//                       onTap: () => _onDeletePackage(pkg),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildPackageImage(String imageUrl) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Image.network(
//         imageUrl,
//         height: 160,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         loadingBuilder: (context, child, progress) {
//           if (progress == null) return child;
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.deepPurple),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) =>
//             const Icon(Icons.broken_image, size: 60, color: Colors.grey),
//       ),
//     );
//   }
//
//   Widget _buildNoImagePlaceholder() {
//     return Container(
//       height: 160,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
//           SizedBox(height: 8),
//           Text('No Image Available', style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPackageName(String name) {
//     return Text(
//       name,
//       style: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Colors.deepPurple,
//       ),
//     );
//   }
//
//   Widget _buildPackageType(String type) {
//     final bool isVegetarian = type.toLowerCase().contains('veg');
//     return Text(
//       type,
//       style: TextStyle(
//         color: isVegetarian ? Colors.green : Colors.redAccent,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
//
//   Widget _buildItemsList(List<PackageItemModel> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Items:",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 4),
//         ...items.map(
//           (item) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 2),
//             child: Text(
//               "• ${item.itemName} - ₹${item.price.toStringAsFixed(2)}",
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTotalPrice(double totalPrice) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Text(
//         "Total: ₹${totalPrice.toStringAsFixed(2)}",
//         style: const TextStyle(
//           color: Colors.deepPurple,
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(6),
//           child: Icon(icon, color: color, size: 22),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _onEditPackage(PackageModel pkg) async {
//     final updatedPackage = await Navigator.push<PackageModel?>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => UpdatePackagePage(
//           packageData: {
//             "id": pkg.id,
//             "vendorId": pkg.vendorId,
//             "packageName": pkg.packageName,
//             "packageType": pkg.packageType,
//             "image": pkg.image ?? "",
//             "totalPrice": pkg.totalPrice,
//             "items": pkg.items
//                 .map(
//                   (i) => {"id": i.id, "itemName": i.itemName, "price": i.price},
//                 )
//                 .toList(),
//           },
//         ),
//       ),
//     );
//
//     if (updatedPackage != null) {
//       // Find and update the package in the list
//       final index = packages.indexWhere((element) => element.id == pkg.id);
//       if (index != -1) {
//         setState(() {
//           packages[index] = updatedPackage;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Package updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _onDeletePackage(PackageModel pkg) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: const Text('Are you sure you want to delete this package?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       await deletePackage(pkg.id!);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../CateringModels/PackageItem.dart';
import '../CateringModels/package_model.dart';
import '../Catering_authservices/Auth_Services.dart';
import 'AddPackage.dart';
import 'UpdatePackagePage.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const _cBg = Color(0xFFF7F8FC);
const _cWhite = Color(0xFFFFFFFF);
const _cBorder = Color(0xFFEEEFF5);
const _cAccent = Color(0xFFE66D33);
const _cAccentLt = Color(0xFFFFF0E8);
const _cText1 = Color(0xFF111827);
const _cText2 = Color(0xFF6B7280);
const _cText3 = Color(0xFFB0B3C1);
const _cGreen = Color(0xFF10B981);
const _cGreenLt = Color(0xFFD1FAE5);
const _cRed = Color(0xFFEF4444);
const _cRedLt = Color(0xFFFEE2E2);
const _cShadow = Color(0x0A000000);

const _kGrad = LinearGradient(
  colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});
  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  final List<PackageModel> packages = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final vendorId = await CateringService.getVendorId();
      if (vendorId == null) throw Exception('Vendor not logged in');
      final fetched = await CateringService.getPackagesByVendor(vendorId);
      setState(() {
        packages.clear();
        packages.addAll(fetched);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load packages: $e';
      });
    }
  }

  Future<void> deletePackage(int packageId) async {
    try {
      final vendorId = await CateringService.getVendorId();
      if (vendorId == null) throw Exception('Vendor not logged in');
      final success = await CateringService.deletePackage(packageId);
      if (success) {
        setState(() => packages.removeWhere((pkg) => pkg.id == packageId));
        _snack('Package deleted successfully!', _cGreen);
      } else {
        _snack('Failed to delete package', _cRed);
      }
    } catch (e) {
      _snack('Error deleting package: $e', _cRed);
    }
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

      appBar: _buildAppBar(),


      body: _buildBody(),

      floatingActionButton: _buildFab(),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _cWhite,
      elevation: 0,
      leading: Navigator.of(context).canPop()
          ? GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _cBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: _cText1,
                ),
              ),
            )
          : null,
      title: const Text(
        'Menu Management',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _cText1,
          letterSpacing: -0.3,
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _cBorder),
      ),
    );
  }

  // ── FAB — gradient "Add Package" ─────────────────────────────────────────────
  Widget _buildFab() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddPackagePage(
              onPackageAdded: (pkg) => setState(() => packages.add(pkg)),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: _kGrad,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _cAccent.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Add Package',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body states ───────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: _cRedLt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 34,
                  color: _cRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: _cText2,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: fetchPackages,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: _kGrad,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _cAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _cBg,
                shape: BoxShape.circle,
                border: Border.all(color: _cBorder),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 36,
                color: _cText3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Packages Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _cText1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap "+ Add Package" to create your first one',
              style: TextStyle(fontSize: 13, color: _cText2),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: packages.length,
      itemBuilder: (_, i) => _buildPackageCard(packages[i]),
    );
  }

  // ── Package card ──────────────────────────────────────────────────────────────
  Widget _buildPackageCard(PackageModel pkg) {
    final isVeg = pkg.packageType.toLowerCase().contains('veg');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: (pkg.image != null && pkg.image!.isNotEmpty)
                ? Image.network(
                    pkg.image!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 160,
                            color: _cBg,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: _cAccent,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),

          // ── Info ───────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + edit/delete row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pkg.packageName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _cText1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Edit button
                    GestureDetector(
                      onTap: () => _onEditPackage(pkg),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Color(0xFF3B82F6),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    GestureDetector(
                      onTap: () => _onDeletePackage(pkg),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _cRedLt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: _cRed,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Package type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isVeg ? _cGreenLt : _cRedLt,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (isVeg ? _cGreen : _cRed).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVeg ? Icons.eco_rounded : Icons.set_meal_rounded,
                        size: 13,
                        color: isVeg ? _cGreen : _cRed,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        pkg.packageType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isVeg ? _cGreen : _cRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Items
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _cText1,
                  ),
                ),
                const SizedBox(height: 6),
                ...pkg.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(right: 8, top: 1),
                          decoration: const BoxDecoration(
                            color: _cAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _cText2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _cText1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Divider + total
                const Divider(color: _cBorder, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 13,
                        color: _cText2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${pkg.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _cAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: _cBg,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded, size: 40, color: _cText3),
          SizedBox(height: 8),
          Text(
            'No Image Available',
            style: TextStyle(fontSize: 12, color: _cText3),
          ),
        ],
      ),
    );
  }

  Future<void> _onEditPackage(PackageModel pkg) async {
    final updated = await Navigator.push<PackageModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => UpdatePackagePage(
          packageData: {
            "id": pkg.id,
            "vendorId": pkg.vendorId,
            "packageName": pkg.packageName,
            "packageType": pkg.packageType,
            "image": pkg.image ?? "",
            "totalPrice": pkg.totalPrice,
            "items": pkg.items
                .map(
                  (i) => {"id": i.id, "itemName": i.itemName, "price": i.price},
                )
                .toList(),
          },
        ),
      ),
    );
    if (updated != null) {
      final idx = packages.indexWhere((e) => e.id == pkg.id);
      if (idx != -1) {
        setState(() => packages[idx] = updated);
        _snack('Package updated successfully!', _cGreen);
      }
    }
  }

  Future<void> _onDeletePackage(PackageModel pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Package?',
          style: TextStyle(fontWeight: FontWeight.w800, color: _cText1),
        ),
        content: Text(
          'Are you sure you want to delete "${pkg.packageName}"?',
          style: const TextStyle(color: _cText2, fontSize: 14),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: _cBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _cBorder),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600, color: _cText2),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: _cRedLt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _cRed.withOpacity(0.3)),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700, color: _cRed),
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await deletePackage(pkg.id!);
  }
}
