// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// // import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_api_headers/google_api_headers.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../API/Auth_service.dart';
// // import '../Models/address_model.dart';
// // import 'addressmodel_provider.dart';
// //
// // class SavedAddress extends ConsumerStatefulWidget {
// //   final bool hideExtraWidgets;
// //
// //   final void Function(
// //     String city,
// //     String pincode,
// //     String state,
// //     double latitude,
// //     double longitude,
// //     int addressId,
// //   )?
// //   onAddressSelected;
// //
// //   const SavedAddress({
// //     super.key,
// //     this.onAddressSelected,
// //     this.hideExtraWidgets = false,
// //   });
// //
// //   @override
// //   ConsumerState<SavedAddress> createState() => _SavedAddressState();
// // }
// //
// // class _SavedAddressState extends ConsumerState<SavedAddress> {
// //   GoogleMapController? mapController;
// //   bool isDrawerOpen = false;
// //   bool isLoading = false;
// //   List<Address> addressList = [];
// //   Future<List<Address>>? _futureAddresses;
// //
// //   final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
// //   String _city = "", _pincode = "", _state = "", _landmark = "";
// //   bool _isLoading = false;
// //   Position? _currentPosition;
// //   String? _currentAddress;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadAddresses();
// //     _futureAddresses = AuthService.fetchAddresses();
// //     _loadLocationFromAPI();
// //     _getCurrentLocation();
// //   }
// //
// //   void _refreshTable() {
// //     setState(() {
// //       _futureAddresses = AuthService.fetchAddresses();
// //     });
// //   }
// //
// //   void _loadLocationFromAPI() async {
// //     final location = await AuthService.fetchCurrentLocation();
// //
// //     setState(() {
// //       if (location != null) {
// //         // assign full model ✔
// //       } else {
// //         // no location available
// //       }
// //     });
// //   }
// //
// //   Future<void> _loadAddresses() async {
// //     setState(() => isLoading = true);
// //
// //     try {
// //       final addresses = await AuthService.fetchAddresses();
// //       setState(() {
// //         addressList = addresses;
// //         _futureAddresses = Future.value(addressList);
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => isLoading = false);
// //       // debugPrint("❌ Error loading addresses: $e");
// //     }
// //   }
// //
// //   Future<void> _deleteAddress(int addressId) async {
// //     final confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Confirm Delete'),
// //         content: const Text('Are you sure you want to delete this address?'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: const Text('Cancel'),
// //           ),
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             child: const Text('Delete'),
// //           ),
// //         ],
// //       ),
// //     );
// //
// //     if (confirm != true) return;
// //
// //     try {
// //       final success = await AuthService.deleteAddress(addressId);
// //
// //       if (success) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Address deleted successfully')),
// //         );
// //         _refreshTable();
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
// //     }
// //   }
// //
// //   Future<void> _updateLocation(LatLng latLng) async {
// //     setState(() {
// //       isLoading = true;
// //     });
// //
// //     try {
// //       final placemarks = await placemarkFromCoordinates(
// //         latLng.latitude,
// //         latLng.longitude,
// //       );
// //       if (placemarks.isNotEmpty) {
// //         final place = placemarks.first;
// //         _landmark = place.subLocality ?? "";
// //         _city =
// //             place.locality ??
// //                 place.subAdministrativeArea ??
// //                 place.subLocality ??
// //                 "";
// //         _pincode = place.postalCode ?? "";
// //         _state = place.administrativeArea ?? "";
// //
// //         // Update Riverpod state
// //         await ref
// //             .read(addressProvider.notifier)
// //             .updateLocalAddress(
// //               city: _city,
// //               stateName: _state,
// //               pincode: _pincode,
// //               latitude: latLng.latitude,
// //               longitude: latLng.longitude,
// //               fullAddress: "${place.street}, $_city, $_state, $_pincode",
// //             );
// //
// //         // Post to backend
// //         await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
// //
// //         widget.onAddressSelected?.call(
// //           _city,
// //           _pincode,
// //           _state,
// //           latLng.latitude,
// //           latLng.longitude,
// //           0,
// //         );
// //       }
// //     } catch (e) {
// //       // debugPrint("Reverse geocoding failed: $e");
// //     }
// //
// //     setState(() => isLoading = false);
// //   }
// //
// //   Future<void> _handleSearch() async {
// //     Prediction? p = await PlacesAutocomplete.show(
// //       context: context,
// //       apiKey: _googleApiKey,
// //       mode: Mode.overlay,
// //       language: "en",
// //       components: [Component(Component.country, "in")],
// //       logo: const SizedBox.shrink(),
// //     );
// //
// //     if (p != null) {
// //       final places = GoogleMapsPlaces(
// //         apiKey: _googleApiKey,
// //         apiHeaders: await const GoogleApiHeaders().getHeaders(),
// //       );
// //       final detail = await places.getDetailsByPlaceId(p.placeId!);
// //       final location = detail.result.geometry!.location;
// //       _updateLocation(LatLng(location.lat, location.lng));
// //       Navigator.pop(context);
// //       mapController?.animateCamera(
// //         CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
// //       );
// //     }
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     setState(() => _isLoading = true);
// //
// //     try {
// //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //       if (!serviceEnabled) {
// //         await Geolocator.openLocationSettings();
// //         return;
// //       }
// //
// //       LocationPermission permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         permission = await Geolocator.requestPermission();
// //         if (permission == LocationPermission.denied) return;
// //       }
// //       if (permission == LocationPermission.deniedForever) {
// //         await Geolocator.openAppSettings();
// //         return;
// //       }
// //
// //       final pos = await Geolocator.getCurrentPosition(
// //         // ignore: deprecated_member_use
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //
// //       // Get human-readable address
// //       List<Placemark> placemarks = await placemarkFromCoordinates(
// //         pos.latitude,
// //         pos.longitude,
// //       );
// //
// //       final place = placemarks.first;
// //       final address =
// //           "${place.name}, ${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
// //
// //       setState(() {
// //         _currentPosition = pos;
// //         _currentAddress = address;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       if (mounted) {
// //         // print("Error fetching current location: $e");
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }
// //
// //   IconData getCategoryIcon(String category) {
// //     switch (category) {
// //       case 'Home':
// //         return Icons.home_rounded;
// //       case 'Office':
// //         return Icons.business_rounded;
// //       case 'Other':
// //         return Icons.location_on_rounded;
// //       default:
// //         return Icons.place;
// //     }
// //   }
// //
// //   Widget _buildAddressItem(Address address) {
// //     final Color accentColor = Color(0xFFB15DC6);
// //     return InkWell(
// //       onTap: () async {
// //         await ref
// //             .read(addressProvider.notifier)
// //             .updateLocalAddress(
// //               city: address.city,
// //               stateName: address.state,
// //               pincode: address.pincode.toString(),
// //               latitude: address.latitude,
// //               longitude: address.longitude,
// //               fullAddress:
// //                   "${address.doorNumber}, ${address.addressLine}, ${address.city}",
// //             );
// //
// //         await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
// //
// //         widget.onAddressSelected?.call(
// //           address.city,
// //           address.pincode.toString(),
// //           address.state,
// //           address.latitude,
// //           address.longitude,
// //           address.id,
// //         );
// //         Navigator.pop(context);
// //       },
// //       child: Container(
// //         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.grey.shade300),
// //           borderRadius: BorderRadius.circular(8.r),
// //         ),
// //         child: Padding(
// //           padding: EdgeInsets.all(16.w),
// //           child: Row(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Flexible text column to prevent overflow
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Icon(
// //                           getCategoryIcon(address.category),
// //                           size: 20.sp,
// //                           color: Colors.blueAccent,
// //                         ),
// //                         SizedBox(width: 6.w),
// //
// //                         Expanded(
// //                           child: Text(
// //                             address.name,
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16.sp,
// //                             ),
// //                             maxLines: 2,
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                     SizedBox(height: 4.h),
// //                     Text(
// //                       '${address.doorNumber}, ${address.addressLine}',
// //                       style: TextStyle(fontSize: 14.sp),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     Text(
// //                       '${address.city}, ${address.pincode}',
// //                       style: TextStyle(fontSize: 14.sp),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     Text(
// //                       '+91 ${address.phoneNumber}',
// //                       style: TextStyle(fontSize: 14.sp),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(width: 8.w),
// //               // Action buttons
// //               Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   _buildCircleIcon(
// //                     icon: Icons.edit_outlined,
// //                     color: accentColor,
// //                     onPressed: () async {
// //                       final result = await Navigator.push<bool>(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (context) => AddressFormScreen(
// //                             addressId: address.id,
// //                             existingAddress: address,
// //                           ),
// //                         ),
// //                       );
// //                       if (result == true) _refreshTable();
// //                     },
// //                   ),
// //                   SizedBox(width: 12.w),
// //                   _buildCircleIcon(
// //                     icon: Icons.delete_outline,
// //                     color: Colors.red,
// //                     onPressed: () => _deleteAddress(address.id),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCircleIcon({
// //     required IconData icon,
// //     required Color color,
// //     required VoidCallback onPressed,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle,
// //         // ignore: deprecated_member_use
// //         color: color.withOpacity(0.1),
// //       ),
// //       child: IconButton(
// //         icon: Icon(icon, size: 18.sp, color: color),
// //         onPressed: onPressed,
// //         padding: EdgeInsets.zero,
// //         constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
// //         splashRadius: 20.sp,
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSearchSection() {
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //       decoration: BoxDecoration(
// //         border: Border.all(color: Colors.grey.shade300),
// //         borderRadius: BorderRadius.circular(8.r),
// //       ),
// //       child: InkWell(
// //         onTap: _handleSearch,
// //
// //         child: Container(
// //           height: 50,
// //           padding: const EdgeInsets.symmetric(horizontal: 12),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Row(
// //             children: const [
// //               Icon(Icons.search, color: Colors.grey),
// //               SizedBox(width: 8),
// //               Text("Search location...", style: TextStyle(color: Colors.grey)),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCurrentLocationSection() {
// //     if (_isLoading) {
// //       return const Center(child: CircularProgressIndicator());
// //     }
// //
// //     if (_currentPosition == null || _currentAddress == null) {
// //       return const Padding(
// //         padding: EdgeInsets.all(16),
// //         child: Text("Unable to fetch current location"),
// //       );
// //     }
// //
// //     return InkWell(
// //       onTap: () {
// //         _updateLocation(
// //           LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
// //         );
// //         Navigator.pop(context);
// //       },
// //       child: Container(
// //         width: double.infinity,
// //         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.grey.shade300),
// //           borderRadius: BorderRadius.circular(8.r),
// //         ),
// //         child: Padding(
// //           padding: EdgeInsets.all(16.w),
// //           child: Row(
// //             children: [
// //               const Icon(Icons.my_location, color: Color(0xFFB15DC6)),
// //               SizedBox(width: 12.w),
// //               Expanded(
// //                 child: Text(
// //                   _currentAddress!,
// //                   style: TextStyle(fontSize: 14.sp),
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildAddAddressSection() {
// //     return InkWell(
// //       onTap: () {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => AddressFormScreen()),
// //         );
// //       },
// //       child: Container(
// //         width: double.infinity,
// //         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.grey.shade300),
// //           borderRadius: BorderRadius.circular(8.r),
// //         ),
// //         child: Padding(
// //           padding: EdgeInsets.all(16.w),
// //           child: Row(
// //             children: const [
// //               Icon(Icons.add, color: Color(0xFFB15DC6)),
// //               SizedBox(width: 12),
// //               Text("Add Address"),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSavedAddressesSection() {
// //     return FutureBuilder<List<Address>>(
// //       future: _futureAddresses,
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Padding(
// //             padding: EdgeInsets.all(16),
// //             child: Center(child: CircularProgressIndicator()),
// //           );
// //         }
// //
// //         if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //           return const Padding(
// //             padding: EdgeInsets.all(16),
// //             child: Center(child: Text("No saved addresses")),
// //           );
// //         }
// //
// //         return ListView.builder(
// //           shrinkWrap: true, // ✅ IMPORTANT
// //           physics: const NeverScrollableScrollPhysics(),
// //           padding: const EdgeInsets.only(bottom: 16),
// //           itemCount: snapshot.data!.length,
// //           itemBuilder: (context, index) {
// //             debugPrint("📦 Snapshot State → ${snapshot.connectionState}");
// //             debugPrint("📦 Has Data → ${snapshot.hasData}");
// //             debugPrint("📦 Data Length → ${snapshot.data?.length}");
// //             return _buildAddressItem(snapshot.data![index]);
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         title: const Text("Select a location"),
// //         backgroundColor: Colors.white,
// //         foregroundColor: Colors.black,
// //         elevation: 0,
// //       ),
// //       body: SafeArea(
// //         child: RefreshIndicator(
// //           color: Colors.white,
// //           backgroundColor: Colors.blueAccent,
// //           displacement: 40,
// //           strokeWidth: 3,
// //           onRefresh: () async {
// //             _refreshTable();
// //           },
// //           child: ListView(
// //             physics: const AlwaysScrollableScrollPhysics(), // 🔥 important
// //             padding: EdgeInsets.zero,
// //             children: [
// //               // 🔥 Hide ONLY when redirected
// //               if (!widget.hideExtraWidgets) ...[
// //                 _buildSearchSection(),
// //                 _buildCurrentLocationSection(),
// //               ],
// //               _buildAddAddressSection(),
// //               _buildSavedAddressesSection(),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class AddressFormScreen extends StatefulWidget {
// //   final Address? existingAddress;
// //   final int? addressId;
// //
// //   const AddressFormScreen({super.key, this.addressId, this.existingAddress});
// //
// //   @override
// //   State<AddressFormScreen> createState() => _AddressFormScreenState();
// // }
// //
// // class _AddressFormScreenState extends State<AddressFormScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   late TextEditingController categoryController;
// //   late TextEditingController doorNumberController;
// //   late TextEditingController addressLineController;
// //   late TextEditingController landMarkController;
// //   late TextEditingController cityController;
// //   late TextEditingController pincodeController;
// //   late TextEditingController stateController;
// //   late TextEditingController nameController;
// //   late TextEditingController phoneNumberController;
// //   double? _latitude;
// //   double? _longitude;
// //
// //   // Colors
// //   final Color _primaryColor = const Color(0xFF6C63FF);
// //   final Color _backgroundColor = const Color(0xFFF8F9FA);
// //   final Color _cardColor = Colors.white;
// //   final Color _textColor = const Color(0xFF2D3748);
// //   final Color _successColor = const Color(0xFF4CAF50);
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     categoryController = TextEditingController(
// //       text: widget.existingAddress?.category ?? '',
// //     );
// //     doorNumberController = TextEditingController(
// //       text: widget.existingAddress?.doorNumber ?? '',
// //     );
// //     addressLineController = TextEditingController(
// //       text: widget.existingAddress?.addressLine ?? '',
// //     );
// //     landMarkController = TextEditingController(
// //       text: widget.existingAddress?.landMark ?? '',
// //     );
// //     cityController = TextEditingController(
// //       text: widget.existingAddress?.city ?? '',
// //     );
// //     pincodeController = TextEditingController(
// //       text: widget.existingAddress?.pincode.toString() ?? '',
// //     );
// //     stateController = TextEditingController(
// //       text: widget.existingAddress?.state ?? '',
// //     );
// //     nameController = TextEditingController(
// //       text: widget.existingAddress?.name ?? '',
// //     );
// //     phoneNumberController = TextEditingController(
// //       text: widget.existingAddress?.phoneNumber ?? '',
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     categoryController.dispose();
// //     doorNumberController.dispose();
// //     addressLineController.dispose();
// //     landMarkController.dispose();
// //     cityController.dispose();
// //     pincodeController.dispose();
// //     stateController.dispose();
// //     nameController.dispose();
// //     phoneNumberController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _saveAddress() async {
// //     if (!_formKey.currentState!.validate()) return;
// //
// //     final prefs = await SharedPreferences.getInstance();
// //     final customerId = prefs.getString('customerId');
// //     if (customerId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("User not logged in"),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }
// //     final address =
// //         [
// //               doorNumberController.text,
// //               addressLineController.text,
// //               landMarkController.text,
// //               cityController.text,
// //               stateController.text,
// //               pincodeController.text,
// //             ]
// //             .where((e) => e.trim().isNotEmpty) // avoid empty values
// //             .join(', ');
// //
// //     final body = {
// //       // "userId": userId,
// //       "customerId": customerId,
// //       "addressId": widget.addressId ?? 0,
// //       "doorNumber": doorNumberController.text,
// //       "addressLine": addressLineController.text,
// //       "landMark": landMarkController.text,
// //       "city": cityController.text,
// //       "state": stateController.text,
// //       "name": nameController.text,
// //       "phoneNumber": phoneNumberController.text,
// //       "pincode": int.tryParse(pincodeController.text) ?? 0,
// //       "category": categoryController.text,
// //       "address": address,
// //       "latitude": _latitude,
// //       "longitude": _longitude,
// //       "updatedAt": DateTime.now().toIso8601String(),
// //     };
// //
// //     try {
// //       final success = widget.addressId == null
// //           ? await AuthService.addAddress(body)
// //           : await AuthService.updateAddress(widget.addressId!, body);
// //
// //       if (success) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(
// //               widget.addressId == null
// //                   ? "Address added successfully!"
// //                   : "Address updated successfully!",
// //             ),
// //             backgroundColor: _successColor,
// //           ),
// //         );
// //         Navigator.pop(context, true);
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text("Failed to save address"),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: _backgroundColor,
// //       appBar: AppBar(
// //         title: Text(
// //           widget.addressId == null ? "Add New Address" : "Edit Address",
// //           style: TextStyle(
// //             fontSize: 18.sp,
// //             fontWeight: FontWeight.w600,
// //             color: _textColor,
// //           ),
// //         ),
// //         backgroundColor: _cardColor,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back, color: _textColor),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         // actions: [
// //         //   IconButton(
// //         //     icon: Icon(Icons.save, color: _primaryColor),
// //         //     onPressed: _saveAddress,
// //         //   ),
// //         // ],
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: EdgeInsets.all(16.w),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               children: [
// //                 // Map Section
// //                 _buildMapSection(),
// //                 SizedBox(height: 24.h),
// //
// //                 // Form Card
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: _cardColor,
// //                     borderRadius: BorderRadius.circular(16.r),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         // ignore: deprecated_member_use
// //                         color: Colors.black.withOpacity(0.1),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 4),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Padding(
// //                     padding: EdgeInsets.all(20.w),
// //                     child: Column(
// //                       children: [
// //                         // Address Type
// //                         _buildAddressTypeField(),
// //                         SizedBox(height: 16.h),
// //
// //                         // House/Flat No
// //                         _buildTextField(
// //                           controller: doorNumberController,
// //                           label: "House/Flat Number",
// //                           hintText: "Enter house/flat number",
// //                           icon: Icons.home_outlined,
// //                           validator: (value) => value?.isEmpty ?? true
// //                               ? 'Please enter house/flat number'
// //                               : null,
// //                         ),
// //                         SizedBox(height: 16.h),
// //
// //                         // Street Address
// //                         _buildTextField(
// //                           controller: addressLineController,
// //                           label: "Street Address",
// //                           hintText: "Enter street address",
// //                           icon: Icons.place_outlined,
// //                           validator: (value) => value?.isEmpty ?? true
// //                               ? 'Please enter street address'
// //                               : null,
// //                         ),
// //                         SizedBox(height: 16.h),
// //
// //                         // Landmark
// //                         _buildTextField(
// //                           controller: landMarkController,
// //                           label: "Landmark (Optional)",
// //                           hintText: "Enter nearby landmark",
// //                           icon: Icons.flag_outlined,
// //                         ),
// //                         SizedBox(height: 16.h),
// //
// //                         // City & Pincode Row
// //                         _buildTextField(
// //                           controller: cityController,
// //                           label: "City",
// //                           hintText: "Enter city",
// //                           icon: Icons.location_city_outlined,
// //                           validator: (value) => value?.isEmpty ?? true
// //                               ? 'Please enter city'
// //                               : null,
// //                         ),
// //
// //                         SizedBox(width: 12.w),
// //                         _buildTextField(
// //                           controller: pincodeController,
// //                           label: "Pincode",
// //                           hintText: "Pincode",
// //                           icon: Icons.markunread_mailbox_outlined,
// //                           keyboardType: TextInputType.number,
// //                           validator: (value) {
// //                             if (value?.isEmpty ?? true)
// //                               return 'Please enter pincode';
// //                             if (int.tryParse(value!) == null)
// //                               return 'Invalid pincode';
// //                             return null;
// //                           },
// //                         ),
// //
// //                         SizedBox(height: 16.h),
// //
// //                         // State
// //                         _buildTextField(
// //                           controller: stateController,
// //                           label: "State",
// //                           hintText: "State",
// //                           icon: Icons.map_outlined,
// //                           readOnly: true,
// //                         ),
// //                         SizedBox(height: 16.h),
// //
// //                         // Name
// //                         _buildTextField(
// //                           controller: nameController,
// //                           label: "Full Name",
// //                           hintText: "Enter your full name",
// //                           icon: Icons.person_outline,
// //                           validator: (value) => value?.isEmpty ?? true
// //                               ? 'Please enter name'
// //                               : null,
// //                         ),
// //                         SizedBox(height: 16.h),
// //
// //                         // Phone Number
// //                         _buildPhoneField(),
// //                         SizedBox(height: 24.h),
// //
// //                         // Save Button
// //                         _buildSaveButton(),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(height: 20.h),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildMapSection() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(16.r),
// //         boxShadow: [
// //           BoxShadow(
// //             // ignore: deprecated_member_use
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(16.r),
// //         child: GoogleMapsPage(
// //           onAddressSelected: (city, pincode, state, lat, lng) {
// //             setState(() {
// //               cityController.text = city;
// //               pincodeController.text = pincode;
// //               stateController.text = state;
// //               _latitude = lat;
// //               _longitude = lng;
// //             });
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildAddressTypeField() {
// //     final List<Map<String, dynamic>> addressTypes = [
// //       {
// //         'type': 'Home',
// //         'icon': Icons.home_rounded,
// //         'color': Color(0xFF4CAF50), // Green for home
// //       },
// //       {
// //         'type': 'Office',
// //         'icon': Icons.work_rounded,
// //         'color': Color(0xFF2196F3), // Blue for office
// //       },
// //       {
// //         'type': 'Other',
// //         'icon': Icons.location_on_rounded,
// //         'color': Color(0xFF9C27B0), // Purple for other
// //       },
// //     ];
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           "Address Type *",
// //           style: TextStyle(
// //             fontSize: 14.sp,
// //             fontWeight: FontWeight.w500,
// //             color: _textColor,
// //           ),
// //         ),
// //         SizedBox(height: 8.h),
// //         Container(
// //           width: double.infinity,
// //           padding: EdgeInsets.all(16.w),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(12.r),
// //             border: Border.all(color: Colors.grey[300]!),
// //             color: _cardColor,
// //           ),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: addressTypes.map((addressData) {
// //               final String type = addressData['type'];
// //               final IconData icon = addressData['icon'];
// //               final Color color = addressData['color'];
// //               final bool isSelected = categoryController.text == type;
// //
// //               return Expanded(
// //                 child: Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 4.w),
// //                   child: Material(
// //                     borderRadius: BorderRadius.circular(10.r),
// //                     color: isSelected
// //                         // ignore: deprecated_member_use
// //                         ? color.withOpacity(0.1)
// //                         : Colors.transparent,
// //                     child: InkWell(
// //                       borderRadius: BorderRadius.circular(10.r),
// //                       onTap: () {
// //                         setState(() {
// //                           categoryController.text = type;
// //                         });
// //                       },
// //                       child: Container(
// //                         padding: EdgeInsets.symmetric(
// //                           horizontal: 12.w,
// //                           vertical: 12.h,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(10.r),
// //                           border: Border.all(
// //                             color: isSelected ? color : Colors.grey[300]!,
// //                             width: isSelected ? 2 : 1,
// //                           ),
// //                         ),
// //                         child: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Icon(
// //                               icon,
// //                               size: 20.sp,
// //                               color: isSelected ? color : Colors.grey[600],
// //                             ),
// //                             SizedBox(height: 4.h),
// //                             Text(
// //                               type,
// //                               style: TextStyle(
// //                                 fontSize: 12.sp,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: isSelected ? color : _textColor,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             }).toList(),
// //           ),
// //         ),
// //         // Validation error message
// //         if (_formKey.currentState?.validate() == false &&
// //             categoryController.text.isEmpty)
// //           Padding(
// //             padding: EdgeInsets.only(top: 4.h),
// //             child: Row(
// //               children: [
// //                 Icon(Icons.error_outline, size: 14.sp, color: Colors.red),
// //                 SizedBox(width: 4.w),
// //                 Text(
// //                   'Please select address type',
// //                   style: TextStyle(fontSize: 12.sp, color: Colors.red),
// //                 ),
// //               ],
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildTextField({
// //     required TextEditingController controller,
// //     required String label,
// //     required String hintText,
// //     required IconData icon,
// //     bool readOnly = false,
// //     TextInputType keyboardType = TextInputType.text,
// //     String? Function(String?)? validator,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 14.sp,
// //             fontWeight: FontWeight.w500,
// //             color: _textColor,
// //           ),
// //         ),
// //         SizedBox(height: 6.h),
// //         Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(12.r),
// //             border: Border.all(color: Colors.grey[300]!),
// //           ),
// //           child: TextFormField(
// //             controller: controller,
// //             readOnly: readOnly,
// //             keyboardType: keyboardType,
// //             style: TextStyle(fontSize: 14.sp, color: _textColor),
// //             decoration: InputDecoration(
// //               hintText: hintText,
// //               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
// //               border: InputBorder.none,
// //               prefixIcon: Icon(icon, color: _primaryColor, size: 20.sp),
// //               contentPadding: EdgeInsets.symmetric(
// //                 horizontal: 16.w,
// //                 vertical: 14.h,
// //               ),
// //             ),
// //             validator: validator,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildPhoneField() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           "Phone Number",
// //           style: TextStyle(
// //             fontSize: 14.sp,
// //             fontWeight: FontWeight.w500,
// //             color: _textColor,
// //           ),
// //         ),
// //         SizedBox(height: 6.h),
// //         Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(12.r),
// //             border: Border.all(color: Colors.grey[300]!),
// //           ),
// //           child: TextFormField(
// //             controller: phoneNumberController,
// //             keyboardType: TextInputType.phone,
// //             style: TextStyle(fontSize: 14.sp, color: _textColor),
// //             decoration: InputDecoration(
// //               hintText: "Enter phone number",
// //               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
// //               border: InputBorder.none,
// //               prefixIcon: Icon(
// //                 Icons.phone_android_outlined,
// //                 color: _primaryColor,
// //                 size: 20.sp,
// //               ),
// //               prefixText: "+91 ",
// //               contentPadding: EdgeInsets.symmetric(
// //                 horizontal: 16.w,
// //                 vertical: 14.h,
// //               ),
// //             ),
// //             maxLength: 10,
// //             validator: (value) {
// //               if (value == null || value.isEmpty) {
// //                 return "Please enter phone number";
// //               } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
// //                 return "Enter valid 10 digit number";
// //               }
// //               return null;
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildSaveButton() {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: _saveAddress,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: _primaryColor,
// //           foregroundColor: Colors.white,
// //           elevation: 4,
// //           // ignore: deprecated_member_use
// //           shadowColor: _primaryColor.withOpacity(0.3),
// //           padding: EdgeInsets.symmetric(vertical: 16.h),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //           ),
// //         ),
// //         child: Text(
// //           widget.addressId == null ? "SAVE ADDRESS" : "UPDATE ADDRESS",
// //           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class GoogleMapsPage extends StatefulWidget {
// //   final Function(
// //     String city,
// //     String pincode,
// //     String state,
// //     double latitude,
// //     double longitude,
// //   )?
// //   onAddressSelected;
// //
// //   const GoogleMapsPage({super.key, this.onAddressSelected});
// //
// //   @override
// //   State<GoogleMapsPage> createState() => _GoogleMapsPageState();
// // }
// //
// // class _GoogleMapsPageState extends State<GoogleMapsPage> {
// //   GoogleMapController? mapController;
// //   Color _textColor = Colors.black87;
// //
// //   static const LatLng _initialPosition = LatLng(17.385044, 78.486671);
// //   static const CameraPosition _initialCameraPosition = CameraPosition(
// //     target: _initialPosition,
// //     zoom: 14,
// //   );
// //
// //   final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
// //   LatLng _currentLatLng = _initialPosition;
// //   String _city = "", _pincode = "", _state = "";
// //
// //   bool _isLoading = false;
// //   bool _hasPermission = true;
// //
// //   final Color _primaryColor = const Color(0xFF6C63FF);
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _getCurrentLocation();
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     try {
// //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //       if (!serviceEnabled) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text("Location services are disabled."),
// //             backgroundColor: Colors.orange,
// //           ),
// //         );
// //         return;
// //       }
// //
// //       LocationPermission permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         permission = await Geolocator.requestPermission();
// //       }
// //
// //       if (permission == LocationPermission.denied) {
// //         setState(() => _hasPermission = false);
// //         return;
// //       }
// //
// //       if (permission == LocationPermission.deniedForever) {
// //         setState(() => _hasPermission = false);
// //         return;
// //       }
// //
// //       setState(() => _hasPermission = true);
// //
// //       final position = await Geolocator.getCurrentPosition(
// //         // ignore: deprecated_member_use
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //
// //       _updateLocation(LatLng(position.latitude, position.longitude));
// //       mapController?.animateCamera(
// //         CameraUpdate.newLatLngZoom(
// //           LatLng(position.latitude, position.longitude),
// //           16,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
// //       );
// //     }
// //   }
// //
// //   Future<void> _updateLocation(LatLng latLng) async {
// //     setState(() {
// //       _currentLatLng = latLng;
// //       _isLoading = true;
// //     });
// //
// //     try {
// //       final placemarks = await placemarkFromCoordinates(
// //         latLng.latitude,
// //         latLng.longitude,
// //       );
// //
// //       if (placemarks.isNotEmpty) {
// //         final place = placemarks.first;
// //         _city =
// //             place.locality ??
// //                 place.subAdministrativeArea ??
// //                 place.subLocality ??
// //                 "";
// //         _pincode = place.postalCode ?? "";
// //         _state = place.administrativeArea ?? "";
// //
// //         widget.onAddressSelected?.call(
// //           _city,
// //           _pincode,
// //           _state,
// //           latLng.latitude,
// //           latLng.longitude,
// //         );
// //       }
// //     } catch (e) {
// //       // debugPrint("Reverse geocoding failed: $e");
// //     }
// //
// //     setState(() => _isLoading = false);
// //   }
// //
// //   Future<void> _handleSearch() async {
// //     Prediction? p = await PlacesAutocomplete.show(
// //       context: context,
// //       apiKey: _googleApiKey,
// //       mode: Mode.overlay,
// //       language: "en",
// //       components: [Component(Component.country, "in")],
// //       logo: const SizedBox.shrink(),
// //     );
// //
// //     if (p != null) {
// //       final places = GoogleMapsPlaces(
// //         apiKey: _googleApiKey,
// //         apiHeaders: await const GoogleApiHeaders().getHeaders(),
// //       );
// //
// //       final detail = await places.getDetailsByPlaceId(p.placeId!);
// //       final location = detail.result.geometry!.location;
// //
// //       _updateLocation(LatLng(location.lat, location.lng));
// //       mapController?.animateCamera(
// //         CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 300.h,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(color: Colors.grey.shade300),
// //       ),
// //       child: Stack(
// //         alignment: Alignment.center,
// //         children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(16.r),
// //             child: GoogleMap(
// //               initialCameraPosition: _initialCameraPosition,
// //               onMapCreated: (controller) => mapController = controller,
// //               myLocationEnabled: true,
// //               myLocationButtonEnabled: false,
// //               zoomControlsEnabled: false,
// //               onCameraMove: (pos) {
// //                 _currentLatLng = pos.target;
// //               },
// //               onCameraIdle: () {
// //                 _updateLocation(_currentLatLng);
// //               },
// //               gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
// //                 Factory<OneSequenceGestureRecognizer>(
// //                   () => EagerGestureRecognizer(),
// //                 ),
// //               },
// //             ),
// //           ),
// //
// //           // Location Pin
// //           const Icon(Icons.location_pin, size: 50, color: Colors.red),
// //
// //           // Search Bar
// //           Positioned(
// //             top: 16.h,
// //             left: 16.w,
// //             right: 16.w,
// //             child: InkWell(
// //               onTap: _handleSearch,
// //               child: Container(
// //                 height: 50.h,
// //                 padding: EdgeInsets.symmetric(horizontal: 16.w),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12.r),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black26,
// //                       blurRadius: 8,
// //                       offset: const Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(Icons.search, color: _primaryColor, size: 20.sp),
// //                     SizedBox(width: 12.w),
// //                     Text(
// //                       "Search location...",
// //                       style: TextStyle(
// //                         color: Colors.grey[600],
// //                         fontSize: 14.sp,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           // Current Location Button
// //           Positioned(
// //             bottom: 80.h,
// //             right: 16.w,
// //             child: FloatingActionButton(
// //               mini: true,
// //               backgroundColor: _primaryColor,
// //               onPressed: _getCurrentLocation,
// //               child: Icon(Icons.my_location, color: Colors.white, size: 20.sp),
// //             ),
// //           ),
// //
// //           // Loading Indicator
// //           if (_isLoading)
// //             Positioned(
// //               bottom: 20.h,
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(20.r),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black26,
// //                       blurRadius: 4,
// //                       offset: const Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     SizedBox(
// //                       width: 16.w,
// //                       height: 16.w,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         valueColor: AlwaysStoppedAnimation<Color>(
// //                           _primaryColor,
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 8.w),
// //                     Text(
// //                       "Getting address...",
// //                       style: TextStyle(fontSize: 12.sp, color: _textColor),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //           // Permission Denied Overlay
// //           if (!_hasPermission)
// //             Positioned.fill(
// //               child: Container(
// //                 // ignore: deprecated_member_use
// //                 color: Colors.white.withOpacity(0.95),
// //                 child: Center(
// //                   child: Padding(
// //                     padding: EdgeInsets.all(24.w),
// //                     child: Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         Icon(
// //                           Icons.location_off_rounded,
// //                           size: 60.sp,
// //                           color: Colors.orange,
// //                         ),
// //                         SizedBox(height: 16.h),
// //                         Text(
// //                           "Location Access Required",
// //                           style: TextStyle(
// //                             fontSize: 18.sp,
// //                             fontWeight: FontWeight.bold,
// //                             color: _textColor,
// //                           ),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                         SizedBox(height: 8.h),
// //                         Text(
// //                           "Please enable location permissions to set your address accurately on the map.",
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             color: Colors.grey[600],
// //                           ),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                         SizedBox(height: 20.h),
// //                         Row(
// //                           children: [
// //                             Expanded(
// //                               child: OutlinedButton(
// //                                 onPressed: () => Navigator.pop(context),
// //                                 style: OutlinedButton.styleFrom(
// //                                   padding: EdgeInsets.symmetric(vertical: 12.h),
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(8.r),
// //                                   ),
// //                                 ),
// //                                 child: Text(
// //                                   "Skip",
// //                                   style: TextStyle(color: _textColor),
// //                                 ),
// //                               ),
// //                             ),
// //                             SizedBox(width: 12.w),
// //                             Expanded(
// //                               child: ElevatedButton(
// //                                 onPressed: () async {
// //                                   await Geolocator.openAppSettings();
// //                                 },
// //                                 style: ElevatedButton.styleFrom(
// //                                   backgroundColor: _primaryColor,
// //                                   padding: EdgeInsets.symmetric(vertical: 12.h),
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(8.r),
// //                                   ),
// //                                 ),
// //                                 child: Text(
// //                                   "Enable Location",
// //                                   style: TextStyle(color: Colors.white),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../API/Auth_service.dart';
// import '../Models/address_model.dart';
// import 'addressmodel_provider.dart';
//
// class SavedAddress extends ConsumerStatefulWidget {
//   final bool hideExtraWidgets;
//
//   final void Function(
//       String city,
//       String pincode,
//       String state,
//       double latitude,
//       double longitude,
//       int addressId,
//       )?
//   onAddressSelected;
//
//   const SavedAddress({
//     super.key,
//     this.onAddressSelected,
//     this.hideExtraWidgets = false,
//   });
//
//   @override
//   ConsumerState<SavedAddress> createState() => _SavedAddressState();
// }
//
// class _SavedAddressState extends ConsumerState<SavedAddress> {
//   GoogleMapController? mapController;
//   bool isDrawerOpen = false;
//   bool isLoading = false;
//   List<Address> addressList = [];
//   Future<List<Address>>? _futureAddresses;
//
//   final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
//   String _city = "", _pincode = "", _state = "", _landmark = "";
//   bool _isLoading = false;
//   Position? _currentPosition;
//   String? _currentAddress;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAddresses();
//     _futureAddresses = AuthService.fetchAddresses();
//     _loadLocationFromAPI();
//     _getCurrentLocation();
//   }
//
//   void _refreshTable() {
//     setState(() {
//       _futureAddresses = AuthService.fetchAddresses();
//     });
//   }
//
//   void _loadLocationFromAPI() async {
//     final location = await AuthService.fetchCurrentLocation();
//
//     setState(() {
//       if (location != null) {
//         // assign full model ✔
//       } else {
//         // no location available
//       }
//     });
//   }
//
//   Future<void> _loadAddresses() async {
//     setState(() => isLoading = true);
//
//     try {
//       final addresses = await AuthService.fetchAddresses();
//       setState(() {
//         addressList = addresses;
//         _futureAddresses = Future.value(addressList);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       // debugPrint("❌ Error loading addresses: $e");
//     }
//   }
//
//   Future<void> _deleteAddress(int addressId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: const Text('Are you sure you want to delete this address?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     try {
//       final success = await AuthService.deleteAddress(addressId);
//
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Address deleted successfully')),
//         );
//         _refreshTable();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
//     }
//   }
//
//   // UPDATED: Fixed city extraction with fallback values
//   Future<void> _updateLocation(LatLng latLng) async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//         _landmark = place.subLocality ?? "";
//
//         // FIXED: Added fallback values for city
//         _city = place.locality ??
//             place.subAdministrativeArea ??
//             place.subLocality ??
//             place.administrativeArea ??
//             "";
//
//         _pincode = place.postalCode ?? "";
//         _state = place.administrativeArea ?? "";
//
//         // Update Riverpod state
//         await ref
//             .read(addressProvider.notifier)
//             .updateLocalAddress(
//           city: _city,
//           stateName: _state,
//           pincode: _pincode,
//           latitude: latLng.latitude,
//           longitude: latLng.longitude,
//           fullAddress: "${place.street}, $_city, $_state, $_pincode",
//         );
//
//         // Post to backend
//         await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
//
//         widget.onAddressSelected?.call(
//           _city,
//           _pincode,
//           _state,
//           latLng.latitude,
//           latLng.longitude,
//           0,
//         );
//       }
//     } catch (e) {
//       // debugPrint("Reverse geocoding failed: $e");
//     }
//
//     setState(() => isLoading = false);
//   }
//
//   Future<void> _handleSearch() async {
//     Prediction? p = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: _googleApiKey,
//       mode: Mode.overlay,
//       language: "en",
//       components: [Component(Component.country, "in")],
//       logo: const SizedBox.shrink(),
//     );
//
//     if (p != null) {
//       final places = GoogleMapsPlaces(
//         apiKey: _googleApiKey,
//         apiHeaders: await const GoogleApiHeaders().getHeaders(),
//       );
//       final detail = await places.getDetailsByPlaceId(p.placeId!);
//       final location = detail.result.geometry!.location;
//       _updateLocation(LatLng(location.lat, location.lng));
//       Navigator.pop(context);
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
//       );
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     setState(() => _isLoading = true);
//
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await Geolocator.openLocationSettings();
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) return;
//       }
//       if (permission == LocationPermission.deniedForever) {
//         await Geolocator.openAppSettings();
//         return;
//       }
//
//       final pos = await Geolocator.getCurrentPosition(
//         // ignore: deprecated_member_use
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       // Get human-readable address
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         pos.latitude,
//         pos.longitude,
//       );
//
//       final place = placemarks.first;
//       final address =
//           "${place.name}, ${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
//
//       setState(() {
//         _currentPosition = pos;
//         _currentAddress = address;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (mounted) {
//         // print("Error fetching current location: $e");
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   IconData getCategoryIcon(String category) {
//     switch (category) {
//       case 'Home':
//         return Icons.home_rounded;
//       case 'Office':
//         return Icons.business_rounded;
//       case 'Other':
//         return Icons.location_on_rounded;
//       default:
//         return Icons.place;
//     }
//   }
//
//   Widget _buildAddressItem(Address address) {
//     final Color accentColor = Color(0xFFB15DC6);
//     return InkWell(
//       onTap: () async {
//         await ref
//             .read(addressProvider.notifier)
//             .updateLocalAddress(
//           city: address.city,
//           stateName: address.state,
//           pincode: address.pincode.toString(),
//           latitude: address.latitude,
//           longitude: address.longitude,
//           fullAddress:
//           "${address.doorNumber}, ${address.addressLine}, ${address.city}",
//         );
//
//         await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
//
//         widget.onAddressSelected?.call(
//           address.city,
//           address.pincode.toString(),
//           address.state,
//           address.latitude,
//           address.longitude,
//           address.id,
//         );
//         Navigator.pop(context);
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Flexible text column to prevent overflow
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(
//                           getCategoryIcon(address.category),
//                           size: 20.sp,
//                           color: Colors.blueAccent,
//                         ),
//                         SizedBox(width: 6.w),
//
//                         Expanded(
//                           child: Text(
//                             address.name,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16.sp,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 4.h),
//                     Text(
//                       '${address.doorNumber}, ${address.addressLine}',
//                       style: TextStyle(fontSize: 14.sp),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       '${address.city}, ${address.pincode}',
//                       style: TextStyle(fontSize: 14.sp),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       '+91 ${address.phoneNumber}',
//                       style: TextStyle(fontSize: 14.sp),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               // Action buttons
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildCircleIcon(
//                     icon: Icons.edit_outlined,
//                     color: accentColor,
//                     onPressed: () async {
//                       final result = await Navigator.push<bool>(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddressFormScreen(
//                             addressId: address.id,
//                             existingAddress: address,
//                           ),
//                         ),
//                       );
//                       if (result == true) _refreshTable();
//                     },
//                   ),
//                   SizedBox(width: 12.w),
//                   _buildCircleIcon(
//                     icon: Icons.delete_outline,
//                     color: Colors.red,
//                     onPressed: () => _deleteAddress(address.id),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCircleIcon({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         // ignore: deprecated_member_use
//         color: color.withOpacity(0.1),
//       ),
//       child: IconButton(
//         icon: Icon(icon, size: 18.sp, color: color),
//         onPressed: onPressed,
//         padding: EdgeInsets.zero,
//         constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
//         splashRadius: 20.sp,
//       ),
//     );
//   }
//
//   Widget _buildSearchSection() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: InkWell(
//         onTap: _handleSearch,
//
//         child: Container(
//           height: 50,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             children: const [
//               Icon(Icons.search, color: Colors.grey),
//               SizedBox(width: 8),
//               Text("Search location...", style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCurrentLocationSection() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (_currentPosition == null || _currentAddress == null) {
//       return const Padding(
//         padding: EdgeInsets.all(16),
//         child: Text("Unable to fetch current location"),
//       );
//     }
//
//     return InkWell(
//       onTap: () {
//         _updateLocation(
//           LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//         );
//         Navigator.pop(context);
//       },
//       child: Container(
//         width: double.infinity,
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             children: [
//               const Icon(Icons.my_location, color: Color(0xFFB15DC6)),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Text(
//                   _currentAddress!,
//                   style: TextStyle(fontSize: 14.sp),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddAddressSection() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AddressFormScreen()),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             children: const [
//               Icon(Icons.add, color: Color(0xFFB15DC6)),
//               SizedBox(width: 12),
//               Text("Add Address"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSavedAddressesSection() {
//     return FutureBuilder<List<Address>>(
//       future: _futureAddresses,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(child: Text("No saved addresses")),
//           );
//         }
//
//         return ListView.builder(
//           shrinkWrap: true, // ✅ IMPORTANT
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.only(bottom: 16),
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             debugPrint("📦 Snapshot State → ${snapshot.connectionState}");
//             debugPrint("📦 Has Data → ${snapshot.hasData}");
//             debugPrint("📦 Data Length → ${snapshot.data?.length}");
//             return _buildAddressItem(snapshot.data![index]);
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Select a location"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: Colors.white,
//           backgroundColor: Colors.blueAccent,
//           displacement: 40,
//           strokeWidth: 3,
//           onRefresh: () async {
//             _refreshTable();
//           },
//           child: ListView(
//             physics: const AlwaysScrollableScrollPhysics(), // 🔥 important
//             padding: EdgeInsets.zero,
//             children: [
//               // 🔥 Hide ONLY when redirected
//               if (!widget.hideExtraWidgets) ...[
//                 _buildSearchSection(),
//                 _buildCurrentLocationSection(),
//               ],
//               _buildAddAddressSection(),
//               _buildSavedAddressesSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class AddressFormScreen extends StatefulWidget {
//   final Address? existingAddress;
//   final int? addressId;
//
//   const AddressFormScreen({super.key, this.addressId, this.existingAddress});
//
//   @override
//   State<AddressFormScreen> createState() => _AddressFormScreenState();
// }
//
// class _AddressFormScreenState extends State<AddressFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController categoryController;
//   late TextEditingController doorNumberController;
//   late TextEditingController addressLineController;
//   late TextEditingController landMarkController;
//   late TextEditingController cityController;
//   late TextEditingController pincodeController;
//   late TextEditingController stateController;
//   late TextEditingController nameController;
//   late TextEditingController phoneNumberController;
//   double? _latitude;
//   double? _longitude;
//
//   // Colors
//   final Color _primaryColor = const Color(0xFF6C63FF);
//   final Color _backgroundColor = const Color(0xFFF8F9FA);
//   final Color _cardColor = Colors.white;
//   final Color _textColor = const Color(0xFF2D3748);
//   final Color _successColor = const Color(0xFF4CAF50);
//
//   @override
//   void initState() {
//     super.initState();
//     categoryController = TextEditingController(
//       text: widget.existingAddress?.category ?? '',
//     );
//     doorNumberController = TextEditingController(
//       text: widget.existingAddress?.doorNumber ?? '',
//     );
//     addressLineController = TextEditingController(
//       text: widget.existingAddress?.addressLine ?? '',
//     );
//     landMarkController = TextEditingController(
//       text: widget.existingAddress?.landMark ?? '',
//     );
//     cityController = TextEditingController(
//       text: widget.existingAddress?.city ?? '',
//     );
//     pincodeController = TextEditingController(
//       text: widget.existingAddress?.pincode.toString() ?? '',
//     );
//     stateController = TextEditingController(
//       text: widget.existingAddress?.state ?? '',
//     );
//     nameController = TextEditingController(
//       text: widget.existingAddress?.name ?? '',
//     );
//     phoneNumberController = TextEditingController(
//       text: widget.existingAddress?.phoneNumber ?? '',
//     );
//   }
//
//   @override
//   void dispose() {
//     categoryController.dispose();
//     doorNumberController.dispose();
//     addressLineController.dispose();
//     landMarkController.dispose();
//     cityController.dispose();
//     pincodeController.dispose();
//     stateController.dispose();
//     nameController.dispose();
//     phoneNumberController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveAddress() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final prefs = await SharedPreferences.getInstance();
//     final customerId = prefs.getString('customerId');
//     if (customerId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("User not logged in"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     final address =
//     [
//       doorNumberController.text,
//       addressLineController.text,
//       landMarkController.text,
//       cityController.text,
//       stateController.text,
//       pincodeController.text,
//     ]
//         .where((e) => e.trim().isNotEmpty) // avoid empty values
//         .join(', ');
//
//     final body = {
//       // "userId": userId,
//       "customerId": customerId,
//       "addressId": widget.addressId ?? 0,
//       "doorNumber": doorNumberController.text,
//       "addressLine": addressLineController.text,
//       "landMark": landMarkController.text,
//       "city": cityController.text,
//       "state": stateController.text,
//       "name": nameController.text,
//       "phoneNumber": phoneNumberController.text,
//       "pincode": int.tryParse(pincodeController.text) ?? 0,
//       "category": categoryController.text,
//       "address": address,
//       "latitude": _latitude,
//       "longitude": _longitude,
//       "updatedAt": DateTime.now().toIso8601String(),
//     };
//
//     try {
//       final success = widget.addressId == null
//           ? await AuthService.addAddress(body)
//           : await AuthService.updateAddress(widget.addressId!, body);
//
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               widget.addressId == null
//                   ? "Address added successfully!"
//                   : "Address updated successfully!",
//             ),
//             backgroundColor: _successColor,
//           ),
//         );
//         Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to save address"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           widget.addressId == null ? "Add New Address" : "Edit Address",
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w600,
//             color: _textColor,
//           ),
//         ),
//         backgroundColor: _cardColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: _textColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         // actions: [
//         //   IconButton(
//         //     icon: Icon(Icons.save, color: _primaryColor),
//         //     onPressed: _saveAddress,
//         //   ),
//         // ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16.w),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 // Map Section
//                 _buildMapSection(),
//                 SizedBox(height: 24.h),
//
//                 // Form Card
//                 Container(
//                   decoration: BoxDecoration(
//                     color: _cardColor,
//                     borderRadius: BorderRadius.circular(16.r),
//                     boxShadow: [
//                       BoxShadow(
//                         // ignore: deprecated_member_use
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(20.w),
//                     child: Column(
//                       children: [
//                         // Address Type
//                         _buildAddressTypeField(),
//                         SizedBox(height: 16.h),
//
//                         // House/Flat No
//                         _buildTextField(
//                           controller: doorNumberController,
//                           label: "House/Flat Number",
//                           hintText: "Enter house/flat number",
//                           icon: Icons.home_outlined,
//                           validator: (value) => value?.isEmpty ?? true
//                               ? 'Please enter house/flat number'
//                               : null,
//                         ),
//                         SizedBox(height: 16.h),
//
//                         // Street Address
//                         _buildTextField(
//                           controller: addressLineController,
//                           label: "Street Address",
//                           hintText: "Enter street address",
//                           icon: Icons.place_outlined,
//                           validator: (value) => value?.isEmpty ?? true
//                               ? 'Please enter street address'
//                               : null,
//                         ),
//                         SizedBox(height: 16.h),
//
//                         // Landmark
//                         _buildTextField(
//                           controller: landMarkController,
//                           label: "Landmark (Optional)",
//                           hintText: "Enter nearby landmark",
//                           icon: Icons.flag_outlined,
//                         ),
//                         SizedBox(height: 16.h),
//
//                         // City & Pincode Row
//                         _buildTextField(
//                           controller: cityController,
//                           label: "City",
//                           hintText: "Enter city",
//                           icon: Icons.location_city_outlined,
//                           validator: (value) => value?.isEmpty ?? true
//                               ? 'Please enter city'
//                               : null,
//                         ),
//
//                         SizedBox(width: 12.w),
//                         _buildTextField(
//                           controller: pincodeController,
//                           label: "Pincode",
//                           hintText: "Pincode",
//                           icon: Icons.markunread_mailbox_outlined,
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value?.isEmpty ?? true)
//                               return 'Please enter pincode';
//                             if (int.tryParse(value!) == null)
//                               return 'Invalid pincode';
//                             return null;
//                           },
//                         ),
//
//                         SizedBox(height: 16.h),
//
//                         // State
//                         _buildTextField(
//                           controller: stateController,
//                           label: "State",
//                           hintText: "State",
//                           icon: Icons.map_outlined,
//                           readOnly: true,
//                         ),
//                         SizedBox(height: 16.h),
//
//                         // Name
//                         _buildTextField(
//                           controller: nameController,
//                           label: "Full Name",
//                           hintText: "Enter your full name",
//                           icon: Icons.person_outline,
//                           validator: (value) => value?.isEmpty ?? true
//                               ? 'Please enter name'
//                               : null,
//                         ),
//                         SizedBox(height: 16.h),
//
//                         // Phone Number
//                         _buildPhoneField(),
//                         SizedBox(height: 24.h),
//
//                         // Save Button
//                         _buildSaveButton(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMapSection() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16.r),
//         child: GoogleMapsPage(
//           onAddressSelected: (city, pincode, state, lat, lng) {
//             setState(() {
//               cityController.text = city;
//               pincodeController.text = pincode;
//               stateController.text = state;
//               _latitude = lat;
//               _longitude = lng;
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressTypeField() {
//     final List<Map<String, dynamic>> addressTypes = [
//       {
//         'type': 'Home',
//         'icon': Icons.home_rounded,
//         'color': Color(0xFF4CAF50), // Green for home
//       },
//       {
//         'type': 'Office',
//         'icon': Icons.work_rounded,
//         'color': Color(0xFF2196F3), // Blue for office
//       },
//       {
//         'type': 'Other',
//         'icon': Icons.location_on_rounded,
//         'color': Color(0xFF9C27B0), // Purple for other
//       },
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Address Type *",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: _textColor,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: Colors.grey[300]!),
//             color: _cardColor,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: addressTypes.map((addressData) {
//               final String type = addressData['type'];
//               final IconData icon = addressData['icon'];
//               final Color color = addressData['color'];
//               final bool isSelected = categoryController.text == type;
//
//               return Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                   child: Material(
//                     borderRadius: BorderRadius.circular(10.r),
//                     color: isSelected
//                     // ignore: deprecated_member_use
//                         ? color.withOpacity(0.1)
//                         : Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(10.r),
//                       onTap: () {
//                         setState(() {
//                           categoryController.text = type;
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12.w,
//                           vertical: 12.h,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10.r),
//                           border: Border.all(
//                             color: isSelected ? color : Colors.grey[300]!,
//                             width: isSelected ? 2 : 1,
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               icon,
//                               size: 20.sp,
//                               color: isSelected ? color : Colors.grey[600],
//                             ),
//                             SizedBox(height: 4.h),
//                             Text(
//                               type,
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: isSelected ? color : _textColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         // Validation error message
//         if (_formKey.currentState?.validate() == false &&
//             categoryController.text.isEmpty)
//           Padding(
//             padding: EdgeInsets.only(top: 4.h),
//             child: Row(
//               children: [
//                 Icon(Icons.error_outline, size: 14.sp, color: Colors.red),
//                 SizedBox(width: 4.w),
//                 Text(
//                   'Please select address type',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.red),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hintText,
//     required IconData icon,
//     bool readOnly = false,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: _textColor,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: TextFormField(
//             controller: controller,
//             readOnly: readOnly,
//             keyboardType: keyboardType,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: hintText,
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(icon, color: _primaryColor, size: 20.sp),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPhoneField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Phone Number",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: _textColor,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: TextFormField(
//             controller: phoneNumberController,
//             keyboardType: TextInputType.phone,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: "Enter phone number",
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(
//                 Icons.phone_android_outlined,
//                 color: _primaryColor,
//                 size: 20.sp,
//               ),
//               prefixText: "+91 ",
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//             maxLength: 10,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please enter phone number";
//               } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//                 return "Enter valid 10 digit number";
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _saveAddress,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 4,
//           // ignore: deprecated_member_use
//           shadowColor: _primaryColor.withOpacity(0.3),
//           padding: EdgeInsets.symmetric(vertical: 16.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: Text(
//           widget.addressId == null ? "SAVE ADDRESS" : "UPDATE ADDRESS",
//           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }
//
// class GoogleMapsPage extends StatefulWidget {
//   final Function(
//       String city,
//       String pincode,
//       String state,
//       double latitude,
//       double longitude,
//       )?
//   onAddressSelected;
//
//   const GoogleMapsPage({super.key, this.onAddressSelected});
//
//   @override
//   State<GoogleMapsPage> createState() => _GoogleMapsPageState();
// }
//
// class _GoogleMapsPageState extends State<GoogleMapsPage> {
//   GoogleMapController? mapController;
//   Color _textColor = Colors.black87;
//
//   static const LatLng _initialPosition = LatLng(17.385044, 78.486671);
//   static const CameraPosition _initialCameraPosition = CameraPosition(
//     target: _initialPosition,
//     zoom: 14,
//   );
//
//   final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
//   LatLng _currentLatLng = _initialPosition;
//   String _city = "", _pincode = "", _state = "";
//
//   bool _isLoading = false;
//   bool _hasPermission = true;
//
//   final Color _primaryColor = const Color(0xFF6C63FF);
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Location services are disabled."),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.denied) {
//         setState(() => _hasPermission = false);
//         return;
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         setState(() => _hasPermission = false);
//         return;
//       }
//
//       setState(() => _hasPermission = true);
//
//       final position = await Geolocator.getCurrentPosition(
//         // ignore: deprecated_member_use
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       _updateLocation(LatLng(position.latitude, position.longitude));
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(
//           LatLng(position.latitude, position.longitude),
//           16,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   // UPDATED: Fixed city extraction with fallback values
//   Future<void> _updateLocation(LatLng latLng) async {
//     setState(() {
//       _currentLatLng = latLng;
//       _isLoading = true;
//     });
//
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//
//         // FIXED: Added fallback values for city
//         _city = place.locality ??
//             place.subAdministrativeArea ??
//             place.subLocality ??
//             place.administrativeArea ??
//             "";
//
//         _pincode = place.postalCode ?? "";
//         _state = place.administrativeArea ?? "";
//
//         widget.onAddressSelected?.call(
//           _city,
//           _pincode,
//           _state,
//           latLng.latitude,
//           latLng.longitude,
//         );
//       }
//     } catch (e) {
//       // debugPrint("Reverse geocoding failed: $e");
//     }
//
//     setState(() => _isLoading = false);
//   }
//
//   Future<void> _handleSearch() async {
//     Prediction? p = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: _googleApiKey,
//       mode: Mode.overlay,
//       language: "en",
//       components: [Component(Component.country, "in")],
//       logo: const SizedBox.shrink(),
//     );
//
//     if (p != null) {
//       final places = GoogleMapsPlaces(
//         apiKey: _googleApiKey,
//         apiHeaders: await const GoogleApiHeaders().getHeaders(),
//       );
//
//       final detail = await places.getDetailsByPlaceId(p.placeId!);
//       final location = detail.result.geometry!.location;
//
//       _updateLocation(LatLng(location.lat, location.lng));
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 300.h,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16.r),
//             child: GoogleMap(
//               initialCameraPosition: _initialCameraPosition,
//               onMapCreated: (controller) => mapController = controller,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//               zoomControlsEnabled: false,
//               onCameraMove: (pos) {
//                 _currentLatLng = pos.target;
//               },
//               onCameraIdle: () {
//                 _updateLocation(_currentLatLng);
//               },
//               gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                 Factory<OneSequenceGestureRecognizer>(
//                       () => EagerGestureRecognizer(),
//                 ),
//               },
//             ),
//           ),
//
//           // Location Pin
//           const Icon(Icons.location_pin, size: 50, color: Colors.red),
//
//           // Search Bar
//           Positioned(
//             top: 16.h,
//             left: 16.w,
//             right: 16.w,
//             child: InkWell(
//               onTap: _handleSearch,
//               child: Container(
//                 height: 50.h,
//                 padding: EdgeInsets.symmetric(horizontal: 16.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.search, color: _primaryColor, size: 20.sp),
//                     SizedBox(width: 12.w),
//                     Text(
//                       "Search location...",
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Current Location Button
//           Positioned(
//             bottom: 80.h,
//             right: 16.w,
//             child: FloatingActionButton(
//               mini: true,
//               backgroundColor: _primaryColor,
//               onPressed: _getCurrentLocation,
//               child: Icon(Icons.my_location, color: Colors.white, size: 20.sp),
//             ),
//           ),
//
//           // Loading Indicator
//           if (_isLoading)
//             Positioned(
//               bottom: 20.h,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 16.w,
//                       height: 16.w,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           _primaryColor,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       "Getting address...",
//                       style: TextStyle(fontSize: 12.sp, color: _textColor),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // Permission Denied Overlay
//           if (!_hasPermission)
//             Positioned.fill(
//               child: Container(
//                 // ignore: deprecated_member_use
//                 color: Colors.white.withOpacity(0.95),
//                 child: Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(24.w),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.location_off_rounded,
//                           size: 60.sp,
//                           color: Colors.orange,
//                         ),
//                         SizedBox(height: 16.h),
//                         Text(
//                           "Location Access Required",
//                           style: TextStyle(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.bold,
//                             color: _textColor,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 8.h),
//                         Text(
//                           "Please enable location permissions to set your address accurately on the map.",
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             color: Colors.grey[600],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 20.h),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: EdgeInsets.symmetric(vertical: 12.h),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   "Skip",
//                                   style: TextStyle(color: _textColor),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 12.w),
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   await Geolocator.openAppSettings();
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: _primaryColor,
//                                   padding: EdgeInsets.symmetric(vertical: 12.h),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   "Enable Location",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../API/Auth_service.dart';
// import '../Models/address_model.dart';
// import 'addressmodel_provider.dart';
//
// // ─── Design Tokens ─────────────────────────────────────────────────────────────
// class _S {
//   static const bg = Color(0xFFF7F8FC);
//   static const white = Color(0xFFFFFFFF);
//   static const border = Color(0xFFEEEFF5);
//   static const accent = Color(0xFFB15DC6);
//   static const accentDark = Color(0xFF8B3FA0);
//   static const accentLight = Color(0xFFF5E8FA);
//   static const green = Color(0xFF10B981);
//   static const greenLight = Color(0xFFD1FAE5);
//   static const red = Color(0xFFEF4444);
//   static const redLight = Color(0xFFFEE2E2);
//   static const blue = Color(0xFF3B82F6);
//   static const blueLight = Color(0xFFDBEAFE);
//   static const amber = Color(0xFFF59E0B);
//   static const amberLight = Color(0xFFFEF3C7);
//   static const text1 = Color(0xFF111827);
//   static const text2 = Color(0xFF6B7280);
//   static const text3 = Color(0xFFB0B3C1);
//   static const shadow = Color(0x0A000000);
//   static const shadowMd = Color(0x14000000);
//
//   static LinearGradient get gradient => const LinearGradient(
//     colors: [accent, accentDark],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }
//
// // ─── SavedAddress ─────────────────────────────────────────────────────────────
// class SavedAddress extends ConsumerStatefulWidget {
//   final bool hideExtraWidgets;
//   final void Function(
//     String city,
//     String pincode,
//     String state,
//     double latitude,
//     double longitude,
//     int addressId,
//   )?
//   onAddressSelected;
//
//   const SavedAddress({
//     super.key,
//     this.onAddressSelected,
//     this.hideExtraWidgets = false,
//   });
//
//   @override
//   ConsumerState<SavedAddress> createState() => _SavedAddressState();
// }
//
// class _SavedAddressState extends ConsumerState<SavedAddress> {
//   GoogleMapController? mapController;
//   bool isLoading = false;
//   List<Address> addressList = [];
//   Future<List<Address>>? _futureAddresses;
//
//   final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
//   String _city = "", _pincode = "", _state = "", _landmark = "";
//   bool _isLoading = false;
//   Position? _currentPosition;
//   String? _currentAddress;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAddresses();
//     _futureAddresses = AuthService.fetchAddresses();
//     _loadLocationFromAPI();
//     _getCurrentLocation();
//   }
//
//   void _refreshTable() =>
//       setState(() => _futureAddresses = AuthService.fetchAddresses());
//
//   void _loadLocationFromAPI() async {
//     await AuthService.fetchCurrentLocation();
//   }
//
//   Future<void> _loadAddresses() async {
//     setState(() => isLoading = true);
//     try {
//       final addresses = await AuthService.fetchAddresses();
//       setState(() {
//         addressList = addresses;
//         _futureAddresses = Future.value(addressList);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> _deleteAddress(int addressId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: const BoxDecoration(
//                 color: _S.redLight,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.delete_outline_rounded,
//                 color: _S.red,
//                 size: 16,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Delete Address',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: _S.text1,
//               ),
//             ),
//           ],
//         ),
//         content: const Text(
//           'Are you sure you want to delete this address?',
//           style: TextStyle(fontSize: 13, color: _S.text2),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel', style: TextStyle(color: _S.text2)),
//           ),
//           GestureDetector(
//             onTap: () => Navigator.pop(context, true),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: _S.red,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 'Delete',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//     if (confirm != true) return;
//     try {
//       final success = await AuthService.deleteAddress(addressId);
//       if (success) {
//         _snack('Address deleted successfully', _S.green);
//         _refreshTable();
//       }
//     } catch (e) {
//       _snack('$e', _S.red);
//     }
//   }
//
//   Future<void> _updateLocation(LatLng latLng) async {
//     setState(() => isLoading = true);
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//         _landmark = place.subLocality ?? "";
//         _city =
//             place.locality ??
//             place.subAdministrativeArea ??
//             place.subLocality ??
//             place.administrativeArea ??
//             "";
//         _pincode = place.postalCode ?? "";
//         _state = place.administrativeArea ?? "";
//         await ref
//             .read(addressProvider.notifier)
//             .updateLocalAddress(
//               city: _city,
//               stateName: _state,
//               pincode: _pincode,
//               latitude: latLng.latitude,
//               longitude: latLng.longitude,
//               fullAddress: "${place.street}, $_city, $_state, $_pincode",
//             );
//         await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
//         widget.onAddressSelected?.call(
//           _city,
//           _pincode,
//           _state,
//           latLng.latitude,
//           latLng.longitude,
//           0,
//         );
//       }
//     } catch (_) {}
//     setState(() => isLoading = false);
//   }
//
//   Future<void> _handleSearch() async {
//     Prediction? p = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: _googleApiKey,
//       mode: Mode.overlay,
//       language: "en",
//       components: [Component(Component.country, "in")],
//       logo: const SizedBox.shrink(),
//     );
//     if (p != null) {
//       final places = GoogleMapsPlaces(
//         apiKey: _googleApiKey,
//         apiHeaders: await const GoogleApiHeaders().getHeaders(),
//       );
//       final detail = await places.getDetailsByPlaceId(p.placeId!);
//       final location = detail.result.geometry!.location;
//       _updateLocation(LatLng(location.lat, location.lng));
//       Navigator.pop(context);
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
//       );
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     setState(() => _isLoading = true);
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await Geolocator.openLocationSettings();
//         return;
//       }
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) return;
//       }
//       if (permission == LocationPermission.deniedForever) {
//         await Geolocator.openAppSettings();
//         return;
//       }
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       final placemarks = await placemarkFromCoordinates(
//         pos.latitude,
//         pos.longitude,
//       );
//       final place = placemarks.first;
//       setState(() {
//         _currentPosition = pos;
//         _currentAddress =
//             "${place.name}, ${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   IconData _categoryIcon(String category) {
//     switch (category) {
//       case 'Home':
//         return Icons.home_rounded;
//       case 'Office':
//         return Icons.business_rounded;
//       default:
//         return Icons.location_on_rounded;
//     }
//   }
//
//   Color _categoryColor(String category) {
//     switch (category) {
//       case 'Home':
//         return _S.green;
//       case 'Office':
//         return _S.blue;
//       default:
//         return _S.accent;
//     }
//   }
//
//   void _snack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           msg,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   // ── BUILD ─────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _S.bg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: RefreshIndicator(
//                 color: _S.accent,
//                 onRefresh: () async => _refreshTable(),
//                 child: ListView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: EdgeInsets.only(bottom: 24.h),
//                   children: [
//                     if (!widget.hideExtraWidgets) ...[
//                       _buildSearchSection(),
//                       _buildCurrentLocationSection(),
//                     ],
//                     _buildAddAddressButton(),
//                     _buildSavedAddressesSection(),
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
//   // ── Header ────────────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
//       decoration: BoxDecoration(
//         gradient: _S.gradient,
//         boxShadow: [
//           BoxShadow(
//             color: _S.accent.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 36.r,
//               height: 36.r,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: Colors.white,
//                 size: 16.sp,
//               ),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Select Location',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 18.sp,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 Text(
//                   'Choose or add your delivery address',
//                   style: TextStyle(color: Colors.white70, fontSize: 11.sp),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8.r),
//               border: Border.all(color: Colors.white30),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.location_on_rounded,
//                   color: Colors.white,
//                   size: 14.sp,
//                 ),
//                 SizedBox(width: 5.w),
//                 Text(
//                   'Addresses',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 11.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Search Section ────────────────────────────────────────────────────────────
//   Widget _buildSearchSection() {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
//       child: GestureDetector(
//         onTap: _handleSearch,
//         child: Container(
//           height: 50.h,
//           decoration: BoxDecoration(
//             color: _S.white,
//             borderRadius: BorderRadius.circular(14.r),
//             border: Border.all(color: _S.border),
//             boxShadow: [
//               const BoxShadow(
//                 color: _S.shadow,
//                 blurRadius: 8,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               SizedBox(width: 14.w),
//               Container(
//                 width: 28.r,
//                 height: 28.r,
//                 decoration: BoxDecoration(
//                   gradient: _S.gradient,
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Icon(
//                   Icons.search_rounded,
//                   color: Colors.white,
//                   size: 15.sp,
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Text(
//                 'Search for area, street name...',
//                 style: TextStyle(color: _S.text3, fontSize: 13.sp),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Current Location Section ──────────────────────────────────────────────────
//   Widget _buildCurrentLocationSection() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//       child: _isLoading
//           ? Container(
//               height: 60.h,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: _S.white,
//                 borderRadius: BorderRadius.circular(14.r),
//                 border: Border.all(color: _S.border),
//               ),
//               child: const CircularProgressIndicator(
//                 color: _S.accent,
//                 strokeWidth: 2,
//               ),
//             )
//           : _currentPosition == null
//           ? const SizedBox.shrink()
//           : GestureDetector(
//               onTap: () {
//                 _updateLocation(
//                   LatLng(
//                     _currentPosition!.latitude,
//                     _currentPosition!.longitude,
//                   ),
//                 );
//                 Navigator.pop(context);
//               },
//               child: Container(
//                 padding: EdgeInsets.all(14.r),
//                 decoration: BoxDecoration(
//                   color: _S.accentLight.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(14.r),
//                   border: Border.all(color: _S.accent.withOpacity(0.2)),
//                   boxShadow: [
//                     const BoxShadow(
//                       color: _S.shadow,
//                       blurRadius: 6,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 36.r,
//                       height: 36.r,
//                       decoration: BoxDecoration(
//                         gradient: _S.gradient,
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Icon(
//                         Icons.my_location_rounded,
//                         color: Colors.white,
//                         size: 18.sp,
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Use Current Location',
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w700,
//                               color: _S.accent,
//                             ),
//                           ),
//                           SizedBox(height: 2.h),
//                           Text(
//                             _currentAddress ?? '',
//                             style: TextStyle(fontSize: 11.sp, color: _S.text2),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       Icons.chevron_right_rounded,
//                       color: _S.accent,
//                       size: 18.sp,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
//
//   // ── Add Address Button ────────────────────────────────────────────────────────
//   Widget _buildAddAddressButton() {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
//       child: GestureDetector(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const AddressFormScreen()),
//         ).then((_) => _refreshTable()),
//         child: Container(
//           padding: EdgeInsets.all(14.r),
//           decoration: BoxDecoration(
//             color: _S.white,
//             borderRadius: BorderRadius.circular(14.r),
//             border: Border.all(
//               color: _S.accent.withOpacity(0.3),
//               style: BorderStyle.solid,
//             ),
//             boxShadow: [
//               const BoxShadow(
//                 color: _S.shadow,
//                 blurRadius: 6,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 36.r,
//                 height: 36.r,
//                 decoration: BoxDecoration(
//                   color: _S.accentLight,
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 child: Icon(
//                   Icons.add_location_alt_rounded,
//                   color: _S.accent,
//                   size: 18.sp,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Text(
//                 'Add New Address',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: _S.accent,
//                 ),
//               ),
//               const Spacer(),
//               Icon(Icons.chevron_right_rounded, color: _S.accent, size: 18.sp),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Section header ────────────────────────────────────────────────────────────
//   Widget _buildSectionHeader(String title) => Padding(
//     padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
//     child: Row(
//       children: [
//         Container(
//           width: 3,
//           height: 16,
//           decoration: BoxDecoration(
//             gradient: _S.gradient,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         SizedBox(width: 8.w),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w800,
//             color: _S.text1,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   // ── Saved Addresses ───────────────────────────────────────────────────────────
//   Widget _buildSavedAddressesSection() {
//     return FutureBuilder<List<Address>>(
//       future: _futureAddresses,
//       builder: (_, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return Padding(
//             padding: EdgeInsets.all(32.r),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 color: _S.accent,
//                 strokeWidth: 2,
//               ),
//             ),
//           );
//         }
//         if (!snap.hasData || snap.data!.isEmpty) {
//           return Padding(
//             padding: EdgeInsets.all(32.r),
//             child: Center(
//               child: Column(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: _S.accentLight,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.location_off_rounded,
//                       color: _S.accent,
//                       size: 28.sp,
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//                   Text(
//                     'No saved addresses',
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _S.text1,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     'Add an address to get started',
//                     style: TextStyle(fontSize: 12.sp, color: _S.text2),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionHeader('Saved Addresses (${snap.data!.length})'),
//             ...snap.data!.map((addr) => _buildAddressCard(addr)),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildAddressCard(Address address) {
//     final color = _categoryColor(address.category);
//     final icon = _categoryIcon(address.category);
//
//     return GestureDetector(
//       onTap: () async {
//         await ref
//             .read(addressProvider.notifier)
//             .updateLocalAddress(
//               city: address.city,
//               stateName: address.state,
//               pincode: address.pincode.toString(),
//               latitude: address.latitude,
//               longitude: address.longitude,
//               fullAddress:
//                   "${address.doorNumber}, ${address.addressLine}, ${address.city}",
//             );
//         await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
//         widget.onAddressSelected?.call(
//           address.city,
//           address.pincode.toString(),
//           address.state,
//           address.latitude,
//           address.longitude,
//           address.id,
//         );
//         Navigator.pop(context);
//       },
//       child: Container(
//         margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
//         decoration: BoxDecoration(
//           color: _S.white,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: _S.border),
//           boxShadow: [
//             const BoxShadow(
//               color: _S.shadow,
//               blurRadius: 8,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(14.r),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Category icon
//               Container(
//                 width: 42.r,
//                 height: 42.r,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12.r),
//                   border: Border.all(color: color.withOpacity(0.2)),
//                 ),
//                 child: Icon(icon, color: color, size: 20.sp),
//               ),
//               SizedBox(width: 12.w),
//               // Address details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           address.name,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14.sp,
//                             color: _S.text1,
//                           ),
//                         ),
//                         SizedBox(width: 6.w),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 6.w,
//                             vertical: 2.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: color.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(5.r),
//                           ),
//                           child: Text(
//                             address.category,
//                             style: TextStyle(
//                               fontSize: 9.sp,
//                               fontWeight: FontWeight.w700,
//                               color: color,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       '${address.doorNumber}, ${address.addressLine}',
//                       style: TextStyle(fontSize: 12.sp, color: _S.text2),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 2.h),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_city_rounded,
//                           size: 11.sp,
//                           color: _S.text3,
//                         ),
//                         SizedBox(width: 3.w),
//                         Text(
//                           '${address.city}, ${address.pincode}',
//                           style: TextStyle(fontSize: 11.sp, color: _S.text2),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 2.h),
//                     Row(
//                       children: [
//                         Icon(Icons.phone_rounded, size: 11.sp, color: _S.text3),
//                         SizedBox(width: 3.w),
//                         Text(
//                           '+91 ${address.phoneNumber}',
//                           style: TextStyle(fontSize: 11.sp, color: _S.text2),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               // Action buttons
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _iconAction(Icons.edit_rounded, _S.accent, () async {
//                     final result = await Navigator.push<bool>(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AddressFormScreen(
//                           addressId: address.id,
//                           existingAddress: address,
//                         ),
//                       ),
//                     );
//                     if (result == true) _refreshTable();
//                   }),
//                   SizedBox(height: 6.h),
//                   _iconAction(
//                     Icons.delete_outline_rounded,
//                     _S.red,
//                     () => _deleteAddress(address.id),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _iconAction(IconData icon, Color color, VoidCallback onTap) =>
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 32.r,
//           height: 32.r,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(9.r),
//             border: Border.all(color: color.withOpacity(0.2)),
//           ),
//           child: Icon(icon, color: color, size: 15.sp),
//         ),
//       );
// }
//
// // ─── AddressFormScreen ────────────────────────────────────────────────────────
// class AddressFormScreen extends StatefulWidget {
//   final Address? existingAddress;
//   final int? addressId;
//   const AddressFormScreen({super.key, this.addressId, this.existingAddress});
//   @override
//   State<AddressFormScreen> createState() => _AddressFormScreenState();
// }
//
// class _AddressFormScreenState extends State<AddressFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController categoryController;
//   late TextEditingController doorNumberController;
//   late TextEditingController addressLineController;
//   late TextEditingController landMarkController;
//   late TextEditingController cityController;
//   late TextEditingController pincodeController;
//   late TextEditingController stateController;
//   late TextEditingController nameController;
//   late TextEditingController phoneNumberController;
//   double? _latitude;
//   double? _longitude;
//   bool _isSaving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     categoryController = TextEditingController(
//       text: widget.existingAddress?.category ?? '',
//     );
//     doorNumberController = TextEditingController(
//       text: widget.existingAddress?.doorNumber ?? '',
//     );
//     addressLineController = TextEditingController(
//       text: widget.existingAddress?.addressLine ?? '',
//     );
//     landMarkController = TextEditingController(
//       text: widget.existingAddress?.landMark ?? '',
//     );
//     cityController = TextEditingController(
//       text: widget.existingAddress?.city ?? '',
//     );
//     pincodeController = TextEditingController(
//       text: widget.existingAddress?.pincode.toString() ?? '',
//     );
//     stateController = TextEditingController(
//       text: widget.existingAddress?.state ?? '',
//     );
//     nameController = TextEditingController(
//       text: widget.existingAddress?.name ?? '',
//     );
//     phoneNumberController = TextEditingController(
//       text: widget.existingAddress?.phoneNumber ?? '',
//     );
//   }
//
//   @override
//   void dispose() {
//     for (final c in [
//       categoryController,
//       doorNumberController,
//       addressLineController,
//       landMarkController,
//       cityController,
//       pincodeController,
//       stateController,
//       nameController,
//       phoneNumberController,
//     ])
//       c.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveAddress() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSaving = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final customerId = prefs.getString('customerId');
//       if (customerId == null) {
//         _snack('User not logged in', _S.red);
//         return;
//       }
//       final address = [
//         doorNumberController.text,
//         addressLineController.text,
//         landMarkController.text,
//         cityController.text,
//         stateController.text,
//         pincodeController.text,
//       ].where((e) => e.trim().isNotEmpty).join(', ');
//       final body = {
//         "customerId": customerId,
//         "addressId": widget.addressId ?? 0,
//         "doorNumber": doorNumberController.text,
//         "addressLine": addressLineController.text,
//         "landMark": landMarkController.text,
//         "city": cityController.text,
//         "state": stateController.text,
//         "name": nameController.text,
//         "phoneNumber": phoneNumberController.text,
//         "pincode": int.tryParse(pincodeController.text) ?? 0,
//         "category": categoryController.text,
//         "address": address,
//         "latitude": _latitude,
//         "longitude": _longitude,
//         "updatedAt": DateTime.now().toIso8601String(),
//       };
//       final success = widget.addressId == null
//           ? await AuthService.addAddress(body)
//           : await AuthService.updateAddress(widget.addressId!, body);
//       if (success) {
//         _snack(
//           widget.addressId == null ? 'Address added!' : 'Address updated!',
//           _S.green,
//         );
//         Navigator.pop(context, true);
//       } else {
//         _snack('Failed to save address', _S.red);
//       }
//     } catch (e) {
//       _snack('Error: $e', _S.red);
//     } finally {
//       setState(() => _isSaving = false);
//     }
//   }
//
//   void _snack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           msg,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.addressId != null;
//     return Scaffold(
//       backgroundColor: _S.bg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
//               decoration: BoxDecoration(
//                 gradient: _S.gradient,
//                 boxShadow: [
//                   BoxShadow(
//                     color: _S.accent.withOpacity(0.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       width: 36.r,
//                       height: 36.r,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Icon(
//                         Icons.arrow_back_ios_rounded,
//                         color: Colors.white,
//                         size: 16.sp,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           isEdit ? 'Edit Address' : 'Add New Address',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w900,
//                             fontSize: 18.sp,
//                           ),
//                         ),
//                         Text(
//                           isEdit
//                               ? 'Update your address details'
//                               : 'Fill in your delivery address',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 11.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(16.w),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       // Map Section
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(16.r),
//                         child: GoogleMapsPage(
//                           onAddressSelected: (city, pincode, state, lat, lng) {
//                             setState(() {
//                               cityController.text = city;
//                               pincodeController.text = pincode;
//                               stateController.text = state;
//                               _latitude = lat;
//                               _longitude = lng;
//                             });
//                           },
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//
//                       // Form card
//                       Container(
//                         padding: EdgeInsets.all(20.w),
//                         decoration: BoxDecoration(
//                           color: _S.white,
//                           borderRadius: BorderRadius.circular(16.r),
//                           border: Border.all(color: _S.border),
//                           boxShadow: [
//                             const BoxShadow(
//                               color: _S.shadow,
//                               blurRadius: 8,
//                               offset: Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             _buildAddressTypeSelector(),
//                             SizedBox(height: 16.h),
//                             _buildField(
//                               doorNumberController,
//                               'House / Flat Number',
//                               'e.g. 12B, Flat 4',
//                               Icons.home_outlined,
//                               validator: (v) =>
//                                   (v?.isEmpty ?? true) ? 'Required' : null,
//                             ),
//                             SizedBox(height: 14.h),
//                             _buildField(
//                               addressLineController,
//                               'Street Address',
//                               'Enter street / area name',
//                               Icons.place_outlined,
//                               validator: (v) =>
//                                   (v?.isEmpty ?? true) ? 'Required' : null,
//                             ),
//                             SizedBox(height: 14.h),
//                             _buildField(
//                               landMarkController,
//                               'Landmark (Optional)',
//                               'Nearby landmark',
//                               Icons.flag_outlined,
//                             ),
//                             SizedBox(height: 14.h),
//                             _buildField(
//                               cityController,
//                               'City',
//                               'Enter city',
//                               Icons.location_city_outlined,
//                               validator: (v) =>
//                                   (v?.isEmpty ?? true) ? 'Required' : null,
//                             ),
//                             SizedBox(height: 14.h),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildField(
//                                     pincodeController,
//                                     'Pincode',
//                                     'e.g. 500001',
//                                     Icons.markunread_mailbox_outlined,
//                                     type: TextInputType.number,
//                                     validator: (v) {
//                                       if (v?.isEmpty ?? true) return 'Required';
//                                       if (int.tryParse(v!) == null)
//                                         return 'Invalid';
//                                       return null;
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(width: 12.w),
//                                 Expanded(
//                                   child: _buildField(
//                                     stateController,
//                                     'State',
//                                     'State',
//                                     Icons.map_outlined,
//                                     readOnly: true,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 14.h),
//                             _buildField(
//                               nameController,
//                               'Full Name',
//                               'Your full name',
//                               Icons.person_outline,
//                               validator: (v) =>
//                                   (v?.isEmpty ?? true) ? 'Required' : null,
//                             ),
//                             SizedBox(height: 14.h),
//                             _buildPhoneField(),
//                             SizedBox(height: 20.h),
//                             _buildSaveButton(isEdit),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20.h),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressTypeSelector() {
//     final types = [
//       {'type': 'Home', 'icon': Icons.home_rounded, 'color': _S.green},
//       {'type': 'Office', 'icon': Icons.work_rounded, 'color': _S.blue},
//       {'type': 'Other', 'icon': Icons.location_on_rounded, 'color': _S.accent},
//     ];
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Address Type *',
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w700,
//             color: _S.text1,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Row(
//           children: types.map((t) {
//             final isSelected = categoryController.text == t['type'];
//             final color = t['color'] as Color;
//             return Expanded(
//               child: GestureDetector(
//                 onTap: () => setState(
//                   () => categoryController.text = t['type'] as String,
//                 ),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: EdgeInsets.symmetric(horizontal: 4.w),
//                   padding: EdgeInsets.symmetric(vertical: 12.h),
//                   decoration: BoxDecoration(
//                     color: isSelected ? color.withOpacity(0.1) : _S.bg,
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(
//                       color: isSelected ? color : _S.border,
//                       width: isSelected ? 1.5 : 1,
//                     ),
//                     boxShadow: isSelected
//                         ? [
//                             BoxShadow(
//                               color: color.withOpacity(0.2),
//                               blurRadius: 6,
//                               offset: const Offset(0, 2),
//                             ),
//                           ]
//                         : null,
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(
//                         t['icon'] as IconData,
//                         color: isSelected ? color : _S.text3,
//                         size: 20.sp,
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         t['type'] as String,
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           fontWeight: FontWeight.w700,
//                           color: isSelected ? color : _S.text2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildField(
//     TextEditingController ctrl,
//     String label,
//     String hint,
//     IconData icon, {
//     bool readOnly = false,
//     TextInputType type = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w600,
//             color: _S.text2,
//           ),
//         ),
//         SizedBox(height: 5.h),
//         Container(
//           decoration: BoxDecoration(
//             color: _S.bg,
//             borderRadius: BorderRadius.circular(10.r),
//             border: Border.all(color: _S.border),
//           ),
//           child: TextFormField(
//             controller: ctrl,
//             readOnly: readOnly,
//             keyboardType: type,
//             style: TextStyle(fontSize: 13.sp, color: _S.text1),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(color: _S.text3, fontSize: 13.sp),
//               prefixIcon: Icon(icon, color: _S.accent, size: 18.sp),
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.fromLTRB(0, 12.h, 12.w, 12.h),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10.r),
//                 borderSide: const BorderSide(color: _S.accent, width: 1.5),
//               ),
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPhoneField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Phone Number',
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w600,
//             color: _S.text2,
//           ),
//         ),
//         SizedBox(height: 5.h),
//         Container(
//           decoration: BoxDecoration(
//             color: _S.bg,
//             borderRadius: BorderRadius.circular(10.r),
//             border: Border.all(color: _S.border),
//           ),
//           child: TextFormField(
//             controller: phoneNumberController,
//             keyboardType: TextInputType.phone,
//             maxLength: 10,
//             style: TextStyle(fontSize: 13.sp, color: _S.text1),
//             decoration: InputDecoration(
//               hintText: 'Enter 10-digit number',
//               hintStyle: TextStyle(color: _S.text3, fontSize: 13.sp),
//               prefixIcon: Icon(
//                 Icons.phone_android_rounded,
//                 color: _S.accent,
//                 size: 18.sp,
//               ),
//               prefixText: '+91 ',
//               border: InputBorder.none,
//               counterText: '',
//               contentPadding: EdgeInsets.fromLTRB(0, 12.h, 12.w, 12.h),
//             ),
//             validator: (v) {
//               if (v == null || v.isEmpty) return 'Please enter phone number';
//               if (!RegExp(r'^[0-9]{10}$').hasMatch(v))
//                 return 'Enter valid 10 digit number';
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSaveButton(bool isEdit) => GestureDetector(
//     onTap: _isSaving ? null : _saveAddress,
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       width: double.infinity,
//       height: 50.h,
//       decoration: BoxDecoration(
//         gradient: _isSaving ? null : _S.gradient,
//         color: _isSaving ? _S.border : null,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: _isSaving
//             ? null
//             : [
//                 BoxShadow(
//                   color: _S.accent.withOpacity(0.4),
//                   blurRadius: 14,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//       ),
//       child: Center(
//         child: _isSaving
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: _S.text2,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Text(
//                 isEdit ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15.sp,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//       ),
//     ),
//   );
// }
//
// // ─── GoogleMapsPage ───────────────────────────────────────────────────────────
// class GoogleMapsPage extends StatefulWidget {
//   final Function(
//     String city,
//     String pincode,
//     String state,
//     double lat,
//     double lng,
//   )?
//   onAddressSelected;
//   const GoogleMapsPage({super.key, this.onAddressSelected});
//   @override
//   State<GoogleMapsPage> createState() => _GoogleMapsPageState();
// }
//
// class _GoogleMapsPageState extends State<GoogleMapsPage> {
//   GoogleMapController? mapController;
//   static const LatLng _initialPosition = LatLng(17.385044, 78.486671);
//   static const CameraPosition _initialCamera = CameraPosition(
//     target: _initialPosition,
//     zoom: 14,
//   );
//   final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
//   LatLng _currentLatLng = _initialPosition;
//   String _city = "", _pincode = "", _state = "";
//   bool _isLoading = false, _hasPermission = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _snack('Location services disabled', _S.amber);
//         return;
//       }
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied)
//         permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         setState(() => _hasPermission = false);
//         return;
//       }
//       setState(() => _hasPermission = true);
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _updateLocation(LatLng(pos.latitude, pos.longitude));
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
//       );
//     } catch (e) {
//       _snack('Error: $e', _S.red);
//     }
//   }
//
//   Future<void> _updateLocation(LatLng latLng) async {
//     setState(() {
//       _currentLatLng = latLng;
//       _isLoading = true;
//     });
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//         _city =
//             place.locality ??
//             place.subAdministrativeArea ??
//             place.subLocality ??
//             place.administrativeArea ??
//             "";
//         _pincode = place.postalCode ?? "";
//         _state = place.administrativeArea ?? "";
//         widget.onAddressSelected?.call(
//           _city,
//           _pincode,
//           _state,
//           latLng.latitude,
//           latLng.longitude,
//         );
//       }
//     } catch (_) {}
//     setState(() => _isLoading = false);
//   }
//
//   Future<void> _handleSearch() async {
//     Prediction? p = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: _googleApiKey,
//       mode: Mode.overlay,
//       language: "en",
//       components: [Component(Component.country, "in")],
//       logo: const SizedBox.shrink(),
//     );
//     if (p != null) {
//       final places = GoogleMapsPlaces(
//         apiKey: _googleApiKey,
//         apiHeaders: await const GoogleApiHeaders().getHeaders(),
//       );
//       final detail = await places.getDetailsByPlaceId(p.placeId!);
//       final location = detail.result.geometry!.location;
//       _updateLocation(LatLng(location.lat, location.lng));
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
//       );
//     }
//   }
//
//   void _snack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 280.h,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: _S.border),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16.r),
//             child: GoogleMap(
//               initialCameraPosition: _initialCamera,
//               onMapCreated: (c) => mapController = c,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//               zoomControlsEnabled: false,
//               onCameraMove: (pos) => _currentLatLng = pos.target,
//               onCameraIdle: () => _updateLocation(_currentLatLng),
//               gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                 Factory<OneSequenceGestureRecognizer>(
//                   () => EagerGestureRecognizer(),
//                 ),
//               },
//             ),
//           ),
//
//           // Pin
//           Icon(Icons.location_pin, size: 44.sp, color: _S.accent),
//
//           // Search bar overlay
//           Positioned(
//             top: 12.h,
//             left: 12.w,
//             right: 12.w,
//             child: GestureDetector(
//               onTap: _handleSearch,
//               child: Container(
//                 height: 44.h,
//                 padding: EdgeInsets.symmetric(horizontal: 14.w),
//                 decoration: BoxDecoration(
//                   color: _S.white,
//                   borderRadius: BorderRadius.circular(12.r),
//                   boxShadow: [
//                     const BoxShadow(
//                       color: _S.shadowMd,
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.search_rounded, color: _S.accent, size: 18.sp),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'Search location...',
//                       style: TextStyle(color: _S.text3, fontSize: 13.sp),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Current location FAB
//           Positioned(
//             bottom: 60.h,
//             right: 12.w,
//             child: GestureDetector(
//               onTap: _getCurrentLocation,
//               child: Container(
//                 width: 36.r,
//                 height: 36.r,
//                 decoration: BoxDecoration(
//                   gradient: _S.gradient,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: _S.accent.withOpacity(0.4),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   Icons.my_location_rounded,
//                   color: Colors.white,
//                   size: 18.sp,
//                 ),
//               ),
//             ),
//           ),
//
//           // Loading pill
//           if (_isLoading)
//             Positioned(
//               bottom: 14.h,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
//                 decoration: BoxDecoration(
//                   color: _S.white,
//                   borderRadius: BorderRadius.circular(20.r),
//                   boxShadow: [
//                     const BoxShadow(
//                       color: _S.shadowMd,
//                       blurRadius: 6,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       width: 14.w,
//                       height: 14.w,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: _S.accent,
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'Getting address...',
//                       style: TextStyle(fontSize: 11.sp, color: _S.text2),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // Location info pill
//           if (!_isLoading && _city.isNotEmpty)
//             Positioned(
//               bottom: 14.h,
//               child: Container(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width - 60.w,
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: _S.white,
//                   borderRadius: BorderRadius.circular(20.r),
//                   border: Border.all(color: _S.accent.withOpacity(0.3)),
//                   boxShadow: [
//                     const BoxShadow(
//                       color: _S.shadowMd,
//                       blurRadius: 6,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.location_on_rounded,
//                       color: _S.accent,
//                       size: 13.sp,
//                     ),
//                     SizedBox(width: 5.w),
//                     Text(
//                       '$_city${_pincode.isNotEmpty ? ', $_pincode' : ''}',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         fontWeight: FontWeight.w600,
//                         color: _S.text1,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // Permission denied overlay
//           if (!_hasPermission)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.white.withOpacity(0.96),
//                 child: Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20.r),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 56.r,
//                           height: 56.r,
//                           decoration: BoxDecoration(
//                             color: _S.amberLight,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.location_off_rounded,
//                             color: _S.amber,
//                             size: 28.sp,
//                           ),
//                         ),
//                         SizedBox(height: 12.h),
//                         Text(
//                           'Location Access Required',
//                           style: TextStyle(
//                             fontSize: 15.sp,
//                             fontWeight: FontWeight.w800,
//                             color: _S.text1,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 6.h),
//                         Text(
//                           'Enable location to set your address on the map',
//                           style: TextStyle(fontSize: 12.sp, color: _S.text2),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 16.h),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () => Navigator.pop(context),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 10.h),
//                                   decoration: BoxDecoration(
//                                     color: _S.bg,
//                                     borderRadius: BorderRadius.circular(10.r),
//                                     border: Border.all(color: _S.border),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       'Skip',
//                                       style: TextStyle(
//                                         fontSize: 13.sp,
//                                         fontWeight: FontWeight.w700,
//                                         color: _S.text2,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 10.w),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () async =>
//                                     await Geolocator.openAppSettings(),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 10.h),
//                                   decoration: BoxDecoration(
//                                     gradient: _S.gradient,
//                                     borderRadius: BorderRadius.circular(10.r),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: _S.accent.withOpacity(0.3),
//                                         blurRadius: 8,
//                                         offset: const Offset(0, 3),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       'Enable Location',
//                                       style: TextStyle(
//                                         fontSize: 13.sp,
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/Auth_service.dart';
import '../Models/address_model.dart';
import 'addressmodel_provider.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _S {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x14000000);

  static LinearGradient get gradient => const LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── SavedAddress ─────────────────────────────────────────────────────────────
class SavedAddress extends ConsumerStatefulWidget {
  final bool hideExtraWidgets;
  final void Function(
    String city,
    String pincode,
    String state,
    double latitude,
    double longitude,
    int addressId,
  )?
  onAddressSelected;

  const SavedAddress({
    super.key,
    this.onAddressSelected,
    this.hideExtraWidgets = false,
  });

  @override
  ConsumerState<SavedAddress> createState() => _SavedAddressState();
}

class _SavedAddressState extends ConsumerState<SavedAddress> {
  GoogleMapController? mapController;
  bool isLoading = false;
  List<Address> addressList = [];
  Future<List<Address>>? _futureAddresses;

  final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
  String _city = "", _pincode = "", _state = "", _landmark = "";
  bool _isLoading = false;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _futureAddresses = AuthService.fetchAddresses();
    _loadLocationFromAPI();
    _getCurrentLocation();
  }

  void _refreshTable() =>
      setState(() => _futureAddresses = AuthService.fetchAddresses());

  void _loadLocationFromAPI() async {
    await AuthService.fetchCurrentLocation();
  }

  Future<void> _loadAddresses() async {
    setState(() => isLoading = true);
    try {
      final addresses = await AuthService.fetchAddresses();
      setState(() {
        addressList = addresses;
        _futureAddresses = Future.value(addressList);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _S.redLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: _S.red,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Delete Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _S.text1,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(fontSize: 13, color: _S.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _S.text2)),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _S.red,
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
    if (confirm != true) return;
    try {
      final success = await AuthService.deleteAddress(addressId);
      if (success) {
        _snack('Address deleted successfully', _S.green);
        _refreshTable();
      }
    } catch (e) {
      _snack('$e', _S.red);
    }
  }

  Future<void> _updateLocation(LatLng latLng) async {
    setState(() => isLoading = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _landmark = place.subLocality ?? "";
        _city =
            place.locality ??
            place.subAdministrativeArea ??
            place.subLocality ??
            place.administrativeArea ??
            "";
        _pincode = place.postalCode ?? "";
        _state = place.administrativeArea ?? "";
        await ref
            .read(addressProvider.notifier)
            .updateLocalAddress(
              city: _city,
              stateName: _state,
              pincode: _pincode,
              latitude: latLng.latitude,
              longitude: latLng.longitude,
              fullAddress: "${place.street}, $_city, $_state, $_pincode",
            );
        await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
        widget.onAddressSelected?.call(
          _city,
          _pincode,
          _state,
          latLng.latitude,
          latLng.longitude,
          0,
        );
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _handleSearch() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: _googleApiKey,
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "in")],
      logo: const SizedBox.shrink(),
    );
    if (p != null) {
      final places = GoogleMapsPlaces(
        apiKey: _googleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      final detail = await places.getDetailsByPlaceId(p.placeId!);
      final location = detail.result.geometry!.location;
      _updateLocation(LatLng(location.lat, location.lng));
      Navigator.pop(context);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final place = placemarks.first;
      setState(() {
        _currentPosition = pos;
        _currentAddress =
            "${place.name}, ${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Home':
        return Icons.home_rounded;
      case 'Office':
        return Icons.business_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Home':
        return _S.green;
      case 'Office':
        return _S.blue;
      default:
        return _S.accent;
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

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _S.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: _S.accent,
                onRefresh: () async => _refreshTable(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 24.h),
                  children: [
                    if (!widget.hideExtraWidgets) ...[
                      _buildSearchSection(),
                      _buildCurrentLocationSection(),
                    ],
                    _buildAddAddressButton(),
                    _buildSavedAddressesSection(),
                  ],
                ),
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
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: _S.white,
        border: Border(bottom: BorderSide(color: _S.border, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: _S.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _S.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: _S.text1,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Location',
                  style: TextStyle(
                    color: _S.text1,
                    fontWeight: FontWeight.w800,
                    fontSize: 17.sp,
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

  // ── Search Section ────────────────────────────────────────────────────────────
  Widget _buildSearchSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: GestureDetector(
        onTap: _handleSearch,
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: _S.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: _S.border),
            boxShadow: [
              const BoxShadow(
                color: _S.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 14.w),
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  gradient: _S.gradient,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 15.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Search for area, street name...',
                style: TextStyle(color: _S.text3, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Current Location Section ──────────────────────────────────────────────────
  Widget _buildCurrentLocationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: _isLoading
          ? Container(
              height: 60.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _S.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _S.border),
              ),
              child: const CircularProgressIndicator(
                color: _S.accent,
                strokeWidth: 2,
              ),
            )
          : _currentPosition == null
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () {
                _updateLocation(
                  LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                );
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: _S.accentLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: _S.accent.withOpacity(0.2)),
                  boxShadow: [
                    const BoxShadow(
                      color: _S.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        gradient: _S.gradient,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use Current Location',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: _S.accent,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _currentAddress ?? '',
                            style: TextStyle(fontSize: 11.sp, color: _S.text2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _S.accent,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Add Address Button ────────────────────────────────────────────────────────
  Widget _buildAddAddressButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddressFormScreen()),
        ).then((_) => _refreshTable()),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: _S.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: _S.accent.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
            boxShadow: [
              const BoxShadow(
                color: _S.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: _S.accentLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.add_location_alt_rounded,
                  color: _S.accent,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _S.accent,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: _S.accent, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: _S.gradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: _S.text1,
          ),
        ),
      ],
    ),
  );

  // ── Saved Addresses ───────────────────────────────────────────────────────────
  Widget _buildSavedAddressesSection() {
    return FutureBuilder<List<Address>>(
      future: _futureAddresses,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(32.r),
            child: const Center(
              child: CircularProgressIndicator(
                color: _S.accent,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(32.r),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _S.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_off_rounded,
                      color: _S.accent,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No saved addresses',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _S.text1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Add an address to get started',
                    style: TextStyle(fontSize: 12.sp, color: _S.text2),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Saved Addresses (${snap.data!.length})'),
            ...snap.data!.map((addr) => _buildAddressCard(addr)),
          ],
        );
      },
    );
  }

  Widget _buildAddressCard(Address address) {
    final color = _categoryColor(address.category);
    final icon = _categoryIcon(address.category);

    return GestureDetector(
      onTap: () async {
        await ref
            .read(addressProvider.notifier)
            .updateLocalAddress(
              city: address.city,
              stateName: address.state,
              pincode: address.pincode.toString(),
              latitude: address.latitude,
              longitude: address.longitude,
              fullAddress:
                  "${address.doorNumber}, ${address.addressLine}, ${address.city}",
            );
        await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
        widget.onAddressSelected?.call(
          address.city,
          address.pincode.toString(),
          address.state,
          address.latitude,
          address.longitude,
          address.id,
        );
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        decoration: BoxDecoration(
          color: _S.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _S.border),
          boxShadow: [
            const BoxShadow(
              color: _S.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              // Address details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.sp,
                            color: _S.text1,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            address.category,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${address.doorNumber}, ${address.addressLine}',
                      style: TextStyle(fontSize: 12.sp, color: _S.text2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_city_rounded,
                          size: 11.sp,
                          color: _S.text3,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '${address.city}, ${address.pincode}',
                          style: TextStyle(fontSize: 11.sp, color: _S.text2),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.phone_rounded, size: 11.sp, color: _S.text3),
                        SizedBox(width: 3.w),
                        Text(
                          '+91 ${address.phoneNumber}',
                          style: TextStyle(fontSize: 11.sp, color: _S.text2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconAction(Icons.edit_rounded, _S.accent, () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddressFormScreen(
                          addressId: address.id,
                          existingAddress: address,
                        ),
                      ),
                    );
                    if (result == true) _refreshTable();
                  }),
                  SizedBox(height: 6.h),
                  _iconAction(
                    Icons.delete_outline_rounded,
                    _S.red,
                    () => _deleteAddress(address.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 15.sp),
        ),
      );
}

// ─── AddressFormScreen ────────────────────────────────────────────────────────
class AddressFormScreen extends StatefulWidget {
  final Address? existingAddress;
  final int? addressId;
  const AddressFormScreen({super.key, this.addressId, this.existingAddress});
  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController categoryController;
  late TextEditingController doorNumberController;
  late TextEditingController addressLineController;
  late TextEditingController landMarkController;
  late TextEditingController cityController;
  late TextEditingController pincodeController;
  late TextEditingController stateController;
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  double? _latitude;
  double? _longitude;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController(
      text: widget.existingAddress?.category ?? '',
    );
    doorNumberController = TextEditingController(
      text: widget.existingAddress?.doorNumber ?? '',
    );
    addressLineController = TextEditingController(
      text: widget.existingAddress?.addressLine ?? '',
    );
    landMarkController = TextEditingController(
      text: widget.existingAddress?.landMark ?? '',
    );
    cityController = TextEditingController(
      text: widget.existingAddress?.city ?? '',
    );
    pincodeController = TextEditingController(
      text: widget.existingAddress?.pincode.toString() ?? '',
    );
    stateController = TextEditingController(
      text: widget.existingAddress?.state ?? '',
    );
    nameController = TextEditingController(
      text: widget.existingAddress?.name ?? '',
    );
    phoneNumberController = TextEditingController(
      text: widget.existingAddress?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    for (final c in [
      categoryController,
      doorNumberController,
      addressLineController,
      landMarkController,
      cityController,
      pincodeController,
      stateController,
      nameController,
      phoneNumberController,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');
      if (customerId == null) {
        _snack('User not logged in', _S.red);
        return;
      }
      final address = [
        doorNumberController.text,
        addressLineController.text,
        landMarkController.text,
        cityController.text,
        stateController.text,
        pincodeController.text,
      ].where((e) => e.trim().isNotEmpty).join(', ');
      final body = {
        "customerId": customerId,
        "addressId": widget.addressId ?? 0,
        "doorNumber": doorNumberController.text,
        "addressLine": addressLineController.text,
        "landMark": landMarkController.text,
        "city": cityController.text,
        "state": stateController.text,
        "name": nameController.text,
        "phoneNumber": phoneNumberController.text,
        "pincode": int.tryParse(pincodeController.text) ?? 0,
        "category": categoryController.text,
        "address": address,
        "latitude": _latitude,
        "longitude": _longitude,
        "updatedAt": DateTime.now().toIso8601String(),
      };
      final success = widget.addressId == null
          ? await AuthService.addAddress(body)
          : await AuthService.updateAddress(widget.addressId!, body);
      if (success) {
        _snack(
          widget.addressId == null ? 'Address added!' : 'Address updated!',
          _S.green,
        );
        Navigator.pop(context, true);
      } else {
        _snack('Failed to save address', _S.red);
      }
    } catch (e) {
      _snack('Error: $e', _S.red);
    } finally {
      setState(() => _isSaving = false);
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
    final isEdit = widget.addressId != null;
    return Scaffold(
      backgroundColor: _S.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              decoration: const BoxDecoration(
                color: _S.white,
                border: Border(bottom: BorderSide(color: _S.border, width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: _S.bg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: _S.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: _S.text1,
                        size: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Address' : 'Add New Address',
                          style: TextStyle(
                            color: _S.text1,
                            fontWeight: FontWeight.w800,
                            fontSize: 17.sp,
                          ),
                        ),
                        Text(
                          isEdit
                              ? 'Update your address details'
                              : 'Fill in your delivery address',
                          style: TextStyle(color: _S.text2, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Map Section
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: GoogleMapsPage(
                          onAddressSelected: (city, pincode, state, lat, lng) {
                            setState(() {
                              cityController.text = city;
                              pincodeController.text = pincode;
                              stateController.text = state;
                              _latitude = lat;
                              _longitude = lng;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Form card
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: _S.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: _S.border),
                          boxShadow: [
                            const BoxShadow(
                              color: _S.shadow,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildAddressTypeSelector(),
                            SizedBox(height: 16.h),
                            _buildField(
                              doorNumberController,
                              'House / Flat Number',
                              'e.g. 12B, Flat 4',
                              Icons.home_outlined,
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Required' : null,
                            ),
                            SizedBox(height: 14.h),
                            _buildField(
                              addressLineController,
                              'Street Address',
                              'Enter street / area name',
                              Icons.place_outlined,
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Required' : null,
                            ),
                            SizedBox(height: 14.h),
                            _buildField(
                              landMarkController,
                              'Landmark (Optional)',
                              'Nearby landmark',
                              Icons.flag_outlined,
                            ),
                            SizedBox(height: 14.h),
                            _buildField(
                              cityController,
                              'City',
                              'Enter city',
                              Icons.location_city_outlined,
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Required' : null,
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    pincodeController,
                                    'Pincode',
                                    'e.g. 500001',
                                    Icons.markunread_mailbox_outlined,
                                    type: TextInputType.number,
                                    validator: (v) {
                                      if (v?.isEmpty ?? true) return 'Required';
                                      if (int.tryParse(v!) == null)
                                        return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildField(
                                    stateController,
                                    'State',
                                    'State',
                                    Icons.map_outlined,
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            _buildField(
                              nameController,
                              'Full Name',
                              'Your full name',
                              Icons.person_outline,
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Required' : null,
                            ),
                            SizedBox(height: 14.h),
                            _buildPhoneField(),
                            SizedBox(height: 20.h),
                            _buildSaveButton(isEdit),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    final types = [
      {'type': 'Home', 'icon': Icons.home_rounded, 'color': _S.green},
      {'type': 'Office', 'icon': Icons.work_rounded, 'color': _S.blue},
      {'type': 'Other', 'icon': Icons.location_on_rounded, 'color': _S.accent},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address Type *',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: _S.text1,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: types.map((t) {
            final isSelected = categoryController.text == t['type'];
            final color = t['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(
                  () => categoryController.text = t['type'] as String,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.1) : _S.bg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? color : _S.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        t['icon'] as IconData,
                        color: isSelected ? color : _S.text3,
                        size: 20.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        t['type'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : _S.text2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    bool readOnly = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _S.text2,
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          decoration: BoxDecoration(
            color: _S.bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _S.border),
          ),
          child: TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            keyboardType: type,
            style: TextStyle(fontSize: 13.sp, color: _S.text1),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: _S.text3, fontSize: 13.sp),
              prefixIcon: Icon(icon, color: _S.accent, size: 18.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(0, 12.h, 12.w, 12.h),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: _S.accent, width: 1.5),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _S.text2,
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          decoration: BoxDecoration(
            color: _S.bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _S.border),
          ),
          child: TextFormField(
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: TextStyle(fontSize: 13.sp, color: _S.text1),
            decoration: InputDecoration(
              hintText: 'Enter 10-digit number',
              hintStyle: TextStyle(color: _S.text3, fontSize: 13.sp),
              prefixIcon: Icon(
                Icons.phone_android_rounded,
                color: _S.accent,
                size: 18.sp,
              ),
              prefixText: '+91 ',
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.fromLTRB(0, 12.h, 12.w, 12.h),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter phone number';
              if (!RegExp(r'^[0-9]{10}$').hasMatch(v))
                return 'Enter valid 10 digit number';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEdit) => GestureDetector(
    onTap: _isSaving ? null : _saveAddress,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        gradient: _isSaving ? null : _S.gradient,
        color: _isSaving ? _S.border : null,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _isSaving
            ? null
            : [
                BoxShadow(
                  color: _S.accent.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Center(
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: _S.text2,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEdit ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    ),
  );
}

// ─── GoogleMapsPage ───────────────────────────────────────────────────────────
class GoogleMapsPage extends StatefulWidget {
  final Function(
    String city,
    String pincode,
    String state,
    double lat,
    double lng,
  )?
  onAddressSelected;
  const GoogleMapsPage({super.key, this.onAddressSelected});
  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  GoogleMapController? mapController;
  static const LatLng _initialPosition = LatLng(17.385044, 78.486671);
  static const CameraPosition _initialCamera = CameraPosition(
    target: _initialPosition,
    zoom: 14,
  );
  final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
  LatLng _currentLatLng = _initialPosition;
  String _city = "", _pincode = "", _state = "";
  bool _isLoading = false, _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack('Location services disabled', _S.amber);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _hasPermission = false);
        return;
      }
      setState(() => _hasPermission = true);
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(LatLng(pos.latitude, pos.longitude));
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
      );
    } catch (e) {
      _snack('Error: $e', _S.red);
    }
  }

  Future<void> _updateLocation(LatLng latLng) async {
    setState(() {
      _currentLatLng = latLng;
      _isLoading = true;
    });
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _city =
            place.locality ??
            place.subAdministrativeArea ??
            place.subLocality ??
            place.administrativeArea ??
            "";
        _pincode = place.postalCode ?? "";
        _state = place.administrativeArea ?? "";
        widget.onAddressSelected?.call(
          _city,
          _pincode,
          _state,
          latLng.latitude,
          latLng.longitude,
        );
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _handleSearch() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: _googleApiKey,
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "in")],
      logo: const SizedBox.shrink(),
    );
    if (p != null) {
      final places = GoogleMapsPlaces(
        apiKey: _googleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      final detail = await places.getDetailsByPlaceId(p.placeId!);
      final location = detail.result.geometry!.location;
      _updateLocation(LatLng(location.lat, location.lng));
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
      );
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _S.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              onMapCreated: (c) => mapController = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onCameraMove: (pos) => _currentLatLng = pos.target,
              onCameraIdle: () => _updateLocation(_currentLatLng),
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
          ),

          // Pin
          Icon(Icons.location_pin, size: 44.sp, color: _S.accent),

          // Search bar overlay
          Positioned(
            top: 12.h,
            left: 12.w,
            right: 12.w,
            child: GestureDetector(
              onTap: _handleSearch,
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: _S.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    const BoxShadow(
                      color: _S.shadowMd,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: _S.accent, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Search location...',
                      style: TextStyle(color: _S.text3, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Current location FAB
          Positioned(
            bottom: 60.h,
            right: 12.w,
            child: GestureDetector(
              onTap: _getCurrentLocation,
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  gradient: _S.gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _S.accent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),

          // Loading pill
          if (_isLoading)
            Positioned(
              bottom: 14.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: _S.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    const BoxShadow(
                      color: _S.shadowMd,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _S.accent,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Getting address...',
                      style: TextStyle(fontSize: 11.sp, color: _S.text2),
                    ),
                  ],
                ),
              ),
            ),

          // Location info pill
          if (!_isLoading && _city.isNotEmpty)
            Positioned(
              bottom: 14.h,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 60.w,
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _S.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: _S.accent.withOpacity(0.3)),
                  boxShadow: [
                    const BoxShadow(
                      color: _S.shadowMd,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: _S.accent,
                      size: 13.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '$_city${_pincode.isNotEmpty ? ', $_pincode' : ''}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _S.text1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

          // Permission denied overlay
          if (!_hasPermission)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.96),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            color: _S.amberLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_off_rounded,
                            color: _S.amber,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Location Access Required',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: _S.text1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Enable location to set your address on the map',
                          style: TextStyle(fontSize: 12.sp, color: _S.text2),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: _S.bg,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(color: _S.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: _S.text2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async =>
                                    await Geolocator.openAppSettings(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    gradient: _S.gradient,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _S.accent.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Enable Location',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
