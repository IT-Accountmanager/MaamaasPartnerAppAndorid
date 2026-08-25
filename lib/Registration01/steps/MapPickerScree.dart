// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MapPickerScreen extends StatefulWidget {
//   final double? initialLatitude;
//   final double? initialLongitude;
//   final Function(double lat, double lng, String address) onLocationSelected;
//
//   const MapPickerScreen({
//     super.key,
//     this.initialLatitude,
//     this.initialLongitude,
//     required this.onLocationSelected,
//   });
//
//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }
//
// class _MapPickerScreenState extends State<MapPickerScreen> {
//   GoogleMapController? _mapController;
//
//   // Default: Hyderabad (change to your preferred default city)
//   LatLng _selectedLocation = const LatLng(17.3850, 78.4867);
//   String _selectedAddress = '';
//
//   // Start as true so spinner shows immediately while we fetch location
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//   }
//
//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _initializeLocation() async {
//     // If a previous location was passed in, use it directly
//     if (widget.initialLatitude != null && widget.initialLongitude != null) {
//       _selectedLocation = LatLng(
//         widget.initialLatitude!,
//         widget.initialLongitude!,
//       );
//       await _getAddressFromLatLng(_selectedLocation);
//       if (mounted) setState(() => _isLoading = false);
//     } else {
//       // Otherwise try to get the device's current location
//       await _getCurrentLocation();
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     if (mounted) setState(() => _isLoading = true);
//
//     try {
//       // Check if location services are enabled at all
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
//       final position =
//           await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high,
//           ).timeout(
//             const Duration(seconds: 15),
//             onTimeout: () => throw Exception('Location request timed out'),
//           );
//
//       _selectedLocation = LatLng(position.latitude, position.longitude);
//       await _getAddressFromLatLng(_selectedLocation);
//
//       // Move the camera to the fetched location once the map is ready
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(_selectedLocation, 15),
//       );
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       _showSnack('Could not get current location. Map centred on default.');
//       // Fall through — map will show the default LatLng already set
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
//       ).timeout(const Duration(seconds: 10));
//
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
//
//         if (mounted) setState(() => _selectedAddress = address);
//       }
//     } catch (e) {
//       debugPrint('Error getting address: $e');
//       if (mounted) {
//         setState(() => _selectedAddress = 'Address not found');
//       }
//     }
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     // Always move to the resolved location once the map surface is ready
//     controller.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 15));
//   }
//
//   void _onCameraMove(CameraPosition position) {
//     _selectedLocation = position.target;
//   }
//
//   Future<void> _onCameraIdle() async {
//     await _getAddressFromLatLng(_selectedLocation);
//   }
//
//   void _confirmLocation() {
//     // Call the callback and pop — do NOT call Navigator.pop inside the
//     // callback as well (that caused a double-pop black screen).
//     widget.onLocationSelected(
//       _selectedLocation.latitude,
//       _selectedLocation.longitude,
//       _selectedAddress,
//     );
//     // onLocationSelected already calls Navigator.pop from company_profile_step,
//     // so we don't pop here again.
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
//       appBar: AppBar(
//         title: const Text('Select Location'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.my_location),
//             onPressed: _getCurrentLocation,
//             tooltip: 'My Location',
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // ── Google Map ─────────────────────────────────────────────────
//             GoogleMap(
//               onMapCreated: _onMapCreated,
//               initialCameraPosition: CameraPosition(
//                 target: _selectedLocation,
//                 zoom: 15,
//               ),
//               onCameraMove: _onCameraMove,
//               onCameraIdle: _onCameraIdle,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//               zoomControlsEnabled: true,
//               mapToolbarEnabled: false, // avoids "open in maps" toolbar overlap
//             ),
//
//             // ── Static centre-pin (visual guide for drag-to-select) ────────
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.only(bottom: 40),
//                 child: Icon(Icons.location_pin, color: Colors.red, size: 48),
//               ),
//             ),
//
//             // ── Full-screen loading overlay ────────────────────────────────
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.4),
//                 child: const Center(child: CircularProgressIndicator()),
//               ),
//
//             // ── Bottom sheet with address + confirm button ─────────────────
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, -2),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Drag handle
//                     Center(
//                       child: Container(
//                         width: 40,
//                         height: 4,
//                         margin: const EdgeInsets.only(bottom: 14),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                     ),
//                     const Text(
//                       'Selected Location',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       _selectedAddress.isNotEmpty
//                           ? _selectedAddress
//                           : 'Move the map to select a location',
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: const Text('Cancel'),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _confirmLocation,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF2563EB),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: const Text(
//                               'Confirm Location',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
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
// }
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double lat, double lng, String address) onLocationSelected;

  const MapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;

  LatLng? _selectedLocation;
  String _selectedAddress = '';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // If a previous location was passed in, use it directly.
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      final loc = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      if (mounted) {
        setState(() {
          _selectedLocation = loc;
          _isLoading = false;
        });
      }
      await _getAddressFromLatLng(loc);
    } else {
      // Otherwise fetch the device's current location — no fallback coords.
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError('Location services are disabled. Please enable GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError(
          'Location permission permanently denied. Enable it in Settings.',
        );
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Location request timed out'),
          );

      final loc = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _selectedLocation = loc;
          _isLoading = false;
        });
      }

      await _getAddressFromLatLng(loc);

      // Move the camera once the map surface exists.
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(loc, 15));
    } catch (e) {
      debugPrint('Error getting location: $e');
      _setError(
        'Could not get current location. Check GPS/network and try again.',
      );
    }
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
    _showSnack(msg);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.subThoroughfare,
          place.thoroughfare,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        if (mounted) setState(() => _selectedAddress = address);
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      if (mounted) {
        setState(() => _selectedAddress = 'Address not found');
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    _selectedLocation = position.target;
  }

  Future<void> _onCameraIdle() async {
    if (_selectedLocation != null) {
      await _getAddressFromLatLng(_selectedLocation!);
    }
  }

  void _confirmLocation() {
    if (_selectedLocation == null) return;
    // Call the callback and pop — do NOT call Navigator.pop inside the
    // callback as well (that caused a double-pop black screen).
    widget.onLocationSelected(
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
      _selectedAddress,
    );
    // onLocationSelected already calls Navigator.pop from the caller,
    // so we don't pop here again.
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
      body: SafeArea(
        child: _selectedLocation == null
            ? _buildUnresolvedState()
            : _buildMapState(_selectedLocation!),
      ),
    );
  }

  // Shown while we have no coordinates at all yet — either loading,
  // or location resolution failed and there's nothing to render a map with.
  Widget _buildUnresolvedState() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unable to determine a location.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapState(LatLng location) {
    return Stack(
      children: [
        // ── Google Map ───────────────────────────────────────────────
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: location, zoom: 15),
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false, // avoids "open in maps" toolbar overlap
        ),

        // ── Static centre-pin (visual guide for drag-to-select) ────────
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.location_pin, color: Colors.red, size: 48),
          ),
        ),

        // ── Loading overlay (e.g. while re-fetching via the AppBar button)
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),

        // ── Bottom sheet with address + confirm button ─────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Selected Location',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedAddress.isNotEmpty
                      ? _selectedAddress
                      : 'Move the map to select a location',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      ],
    );
  }
}
