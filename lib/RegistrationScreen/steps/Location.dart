// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import '../models/vendor_form_data.dart';
//
// class LocationStep extends StatefulWidget {
//   final VendorFormData formData;
//   final ValueChanged<VendorFormData> onChanged;
//   final VoidCallback onNext;
//   final VoidCallback onBack;
//
//   const LocationStep({
//     super.key,
//     required this.formData,
//     required this.onChanged,
//     required this.onNext,
//     required this.onBack,
//   });
//
//   @override
//   State<LocationStep> createState() => _LocationStepState();
// }
//
// class _LocationStepState extends State<LocationStep> {
//   GoogleMapController? _mapController;
//   LatLng _selectedLocation = const LatLng(17.3850, 78.4867);
//   String _selectedAddress = '';
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//   }
//
//   void _update(VendorFormData updated) => widget.onChanged(updated);
//
//   Future<void> _initializeLocation() async {
//     if (widget.formData.latitude != null && widget.formData.longitude != null) {
//       _selectedLocation = LatLng(
//         widget.formData.latitude!,
//         widget.formData.longitude!,
//       );
//       await _getAddressFromLatLng(_selectedLocation);
//       if (mounted) setState(() => _isLoading = false);
//     } else {
//       await _getCurrentLocation();
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     if (mounted) setState(() => _isLoading = true);
//
//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showSnack('Location services are disabled. Please enable GPS.');
//         if (mounted) setState(() => _isLoading = false);
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showSnack('Location permission denied');
//           if (mounted) setState(() => _isLoading = false);
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         _showSnack(
//           'Location permission permanently denied. Enable it in Settings.',
//         );
//         if (mounted) setState(() => _isLoading = false);
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _selectedLocation = LatLng(position.latitude, position.longitude);
//       await _getAddressFromLatLng(_selectedLocation);
//       _update(
//         widget.formData.copyWith(
//           latitude: _selectedLocation.latitude,
//           longitude: _selectedLocation.longitude,
//         ),
//       );
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(_selectedLocation, 15),
//       );
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       _showSnack('Could not get current location');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _getAddressFromLatLng(LatLng position) async {
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//         final address = [
//           place.subThoroughfare,
//           place.thoroughfare,
//           place.locality,
//           place.administrativeArea,
//           place.postalCode,
//           place.country,
//         ].where((part) => part != null && part.isNotEmpty).join(', ');
//         if (mounted) setState(() => _selectedAddress = address);
//       }
//     } catch (e) {
//       debugPrint('Error getting address: $e');
//       if (mounted) setState(() => _selectedAddress = 'Address not found');
//     }
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     controller.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 15));
//   }
//
//   void _onCameraMove(CameraPosition position) {
//     _selectedLocation = position.target;
//   }
//
//   Future<void> _onCameraIdle() async {
//     await _getAddressFromLatLng(_selectedLocation);
//     _update(
//       widget.formData.copyWith(
//         latitude: _selectedLocation.latitude,
//         longitude: _selectedLocation.longitude,
//       ),
//     );
//   }
//
//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // Address & Location Header - matches re5.png
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Address & Location',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Address Fields
//                 const Text(
//                   'Door No *',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9FAFB),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFE5E7EB)),
//                   ),
//                   child: TextField(
//                     controller: TextEditingController(
//                       text: widget.formData.doorNumber,
//                     ),
//                     onChanged: (v) =>
//                         _update(widget.formData.copyWith(doorNumber: v)),
//                     decoration: const InputDecoration(
//                       hintText: 'Door number',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 const Text(
//                   'Street / Address *',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9FAFB),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFE5E7EB)),
//                   ),
//                   child: TextField(
//                     controller: TextEditingController(
//                       text: widget.formData.addressLine,
//                     ),
//                     onChanged: (v) =>
//                         _update(widget.formData.copyWith(addressLine: v)),
//                     decoration: const InputDecoration(
//                       hintText: 'Street address',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'City *',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Color(0xFF374151),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF9FAFB),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: const Color(0xFFE5E7EB),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: TextEditingController(
//                                 text: widget.formData.city,
//                               ),
//                               onChanged: (v) =>
//                                   _update(widget.formData.copyWith(city: v)),
//                               decoration: const InputDecoration(
//                                 hintText: 'City',
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'State *',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Color(0xFF374151),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF9FAFB),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: const Color(0xFFE5E7EB),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: TextEditingController(
//                                 text: widget.formData.state,
//                               ),
//                               onChanged: (v) =>
//                                   _update(widget.formData.copyWith(state: v)),
//                               decoration: const InputDecoration(
//                                 hintText: 'State',
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Pincode *',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Color(0xFF374151),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF9FAFB),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: const Color(0xFFE5E7EB),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: TextEditingController(
//                                 text: widget.formData.pincode,
//                               ),
//                               keyboardType: TextInputType.number,
//                               onChanged: (v) =>
//                                   _update(widget.formData.copyWith(pincode: v)),
//                               decoration: const InputDecoration(
//                                 hintText: 'Pincode',
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Landmark',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Color(0xFF374151),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF9FAFB),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: const Color(0xFFE5E7EB),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: TextEditingController(
//                                 text: widget.formData.landMark,
//                               ),
//                               onChanged: (v) => _update(
//                                 widget.formData.copyWith(landMark: v),
//                               ),
//                               decoration: const InputDecoration(
//                                 hintText: 'Landmark',
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Pin your location on map - matches re5.png
//                 const Text(
//                   'Pin your location on the map *',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 InkWell(
//                   onTap: _getCurrentLocation,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFEFF6FF),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFF2563EB)),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.location_on,
//                           color: Color(0xFF2563EB),
//                           size: 18,
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           'Use my location',
//                           style: TextStyle(
//                             color: Color(0xFF2563EB),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Map - matches re5.png/re6.png
//           Expanded(
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   onMapCreated: _onMapCreated,
//                   initialCameraPosition: CameraPosition(
//                     target: _selectedLocation,
//                     zoom: 15,
//                   ),
//                   onCameraMove: _onCameraMove,
//                   onCameraIdle: _onCameraIdle,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: false,
//                   zoomControlsEnabled: true,
//                 ),
//                 const Center(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: 40),
//                     child: Icon(
//                       Icons.location_pin,
//                       color: Colors.red,
//                       size: 48,
//                     ),
//                   ),
//                 ),
//                 if (_isLoading)
//                   Container(
//                     color: Colors.black.withOpacity(0.4),
//                     child: const Center(child: CircularProgressIndicator()),
//                   ),
//                 Positioned(
//                   bottom: 20,
//                   left: 20,
//                   right: 20,
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 10,
//                           offset: const Offset(0, -2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Selected Location',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           _selectedAddress.isNotEmpty
//                               ? _selectedAddress
//                               : 'Move the map to select a location',
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Back & Next Buttons
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: SizedBox(
//                     height: 52,
//                     child: OutlinedButton(
//                       onPressed: widget.onBack,
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Color(0xFFE5E7EB)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: const Text(
//                         '← Back',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: SizedBox(
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: widget.onNext,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE66D33),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Save & Next',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
