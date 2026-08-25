// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
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
//
//   LatLng _selectedLocation = const LatLng(17.3850, 78.4867);
//
//   String _selectedAddress = '';
//
//   bool _isLoading = true;
//
//   void _update(VendorFormData updated) {
//     widget.onChanged(updated);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//   }
//
//   Future<void> _initializeLocation() async {
//     if (widget.formData.latitude != null && widget.formData.longitude != null) {
//       _selectedLocation = LatLng(
//         widget.formData.latitude!,
//         widget.formData.longitude!,
//       );
//
//       await _getAddressFromLatLng(_selectedLocation);
//
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     } else {
//       await _getCurrentLocation();
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     if (mounted) {
//       setState(() => _isLoading = true);
//     }
//
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//       if (!serviceEnabled) {
//         _showSnack('Please enable location services');
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.denied) {
//         _showSnack('Location permission denied');
//         return;
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         _showSnack('Location permission permanently denied');
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       _selectedLocation = LatLng(position.latitude, position.longitude);
//
//       await _getAddressFromLatLng(_selectedLocation);
//
//       _update(
//         widget.formData.copyWith(
//           latitude: position.latitude,
//           longitude: position.longitude,
//         ),
//       );
//
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(_selectedLocation, 15),
//       );
//     } catch (e) {
//       debugPrint(e.toString());
//
//       _showSnack('Unable to get location');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _getAddressFromLatLng(LatLng position) async {
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//
//         final address = [
//           place.subThoroughfare,
//           place.thoroughfare,
//           place.locality,
//           place.administrativeArea,
//           place.postalCode,
//           place.country,
//         ].where((e) => e != null && e.isNotEmpty).join(', ');
//
//         if (mounted) {
//           setState(() {
//             _selectedAddress = address;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//
//       if (mounted) {
//         setState(() {
//           _selectedAddress = 'Address not found';
//         });
//       }
//     }
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//
//     controller.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 15));
//   }
//
//   void _onCameraMove(CameraPosition position) {
//     _selectedLocation = position.target;
//   }
//
//   Future<void> _onCameraIdle() async {
//     await _getAddressFromLatLng(_selectedLocation);
//
//     _update(
//       widget.formData.copyWith(
//         latitude: _selectedLocation.latitude,
//         longitude: _selectedLocation.longitude,
//       ),
//     );
//   }
//
//   void _showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   Widget _buildInput({
//     required String label,
//     required String hint,
//     String? value,
//     TextInputType? keyboardType,
//     required Function(String) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//
//         const SizedBox(height: 8),
//
//         Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFFF9FAFB),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFE5E7EB)),
//           ),
//           child: TextField(
//             controller: TextEditingController(text: value),
//             keyboardType: keyboardType,
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               hintText: hint,
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 14,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Address & Location',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF111827),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 _buildInput(
//                   label: 'Door No *',
//                   hint: 'Door Number',
//                   value: widget.formData.doorNumber,
//                   onChanged: (v) =>
//                       _update(widget.formData.copyWith(doorNumber: v)),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildInput(
//                   label: 'Street / Address *',
//                   hint: 'Street Address',
//                   value: widget.formData.addressLine,
//                   onChanged: (v) =>
//                       _update(widget.formData.copyWith(addressLine: v)),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildInput(
//                         label: 'City *',
//                         hint: 'City',
//                         value: widget.formData.city,
//                         onChanged: (v) =>
//                             _update(widget.formData.copyWith(city: v)),
//                       ),
//                     ),
//
//                     const SizedBox(width: 12),
//
//                     Expanded(
//                       child: _buildInput(
//                         label: 'State *',
//                         hint: 'State',
//                         value: widget.formData.state,
//                         onChanged: (v) =>
//                             _update(widget.formData.copyWith(state: v)),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildInput(
//                         label: 'Pincode *',
//                         hint: 'Pincode',
//                         keyboardType: TextInputType.number,
//                         value: widget.formData.pincode,
//                         onChanged: (v) =>
//                             _update(widget.formData.copyWith(pincode: v)),
//                       ),
//                     ),
//
//                     const SizedBox(width: 12),
//
//                     Expanded(
//                       child: _buildInput(
//                         label: 'Landmark',
//                         hint: 'Landmark',
//                         value: widget.formData.landMark,
//                         onChanged: (v) =>
//                             _update(widget.formData.copyWith(landMark: v)),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildInput(
//                         label: 'Latitude',
//                         hint: 'Latitude',
//                         keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true,
//                         ),
//                         value: widget.formData.latitude?.toString() ?? '',
//                         onChanged: (v) {
//                           final lat = double.tryParse(v);
//
//                           _update(widget.formData.copyWith(latitude: lat));
//
//                           if (lat != null &&
//                               widget.formData.longitude != null) {
//                             setState(() {
//                               _selectedLocation = LatLng(
//                                 lat,
//                                 widget.formData.longitude!,
//                               );
//                             });
//
//                             _mapController?.animateCamera(
//                               CameraUpdate.newLatLng(_selectedLocation),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//
//                     const SizedBox(width: 12),
//
//                     Expanded(
//                       child: _buildInput(
//                         label: 'Longitude',
//                         hint: 'Longitude',
//                         keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true,
//                         ),
//                         value: widget.formData.longitude?.toString() ?? '',
//                         onChanged: (v) {
//                           final lng = double.tryParse(v);
//
//                           _update(widget.formData.copyWith(longitude: lng));
//
//                           if (lng != null && widget.formData.latitude != null) {
//                             setState(() {
//                               _selectedLocation = LatLng(
//                                 widget.formData.latitude!,
//                                 lng,
//                               );
//                             });
//
//                             _mapController?.animateCamera(
//                               CameraUpdate.newLatLng(_selectedLocation),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//
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
//                         Icon(Icons.location_on, color: Color(0xFF2563EB)),
//                         SizedBox(width: 8),
//                         Text(
//                           'Use my location',
//                           style: TextStyle(
//                             color: Color(0xFF2563EB),
//                             fontWeight: FontWeight.w600,
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
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             height: 420,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             clipBehavior: Clip.antiAlias,
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
//
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
//
//                 if (_isLoading)
//                   Container(
//                     color: Colors.black.withOpacity(0.4),
//                     child: const Center(child: CircularProgressIndicator()),
//                   ),
//
//                 Positioned(
//                   bottom: 16,
//                   left: 16,
//                   right: 16,
//                   child: Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       _selectedAddress.isNotEmpty
//                           ? _selectedAddress
//                           : 'Move map to select location',
//                       style: const TextStyle(fontSize: 13),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
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
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: const Text('← Back'),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
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
//                       ),
//                       child: const Text(
//                         'Save & Next',
//                         style: TextStyle(color: Colors.white),
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
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/vendor_form_data.dart';

class LocationStep extends StatefulWidget {
  final VendorFormData formData;
  final ValueChanged<VendorFormData> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LocationStep({
    super.key,
    required this.formData,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(17.3850, 78.4867);
  String _selectedAddress = '';
  bool _isLoading = true;

  // Text Controllers
  late TextEditingController _doorNoController;
  late TextEditingController _addressLineController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _landmarkController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeLocation();
  }

  void _initializeControllers() {
    _doorNoController = TextEditingController(
      text: widget.formData.doorNumber ?? '',
    );
    _addressLineController = TextEditingController(
      text: widget.formData.addressLine ?? '',
    );
    _cityController = TextEditingController(text: widget.formData.city ?? '');
    _stateController = TextEditingController(text: widget.formData.state ?? '');
    _pincodeController = TextEditingController(
      text: widget.formData.pincode ?? '',
    );
    _landmarkController = TextEditingController(
      text: widget.formData.landMark ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.formData.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.formData.longitude?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(LocationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if formData changes externally
    if (oldWidget.formData.doorNumber != widget.formData.doorNumber) {
      _doorNoController.text = widget.formData.doorNumber ?? '';
    }
    if (oldWidget.formData.addressLine != widget.formData.addressLine) {
      _addressLineController.text = widget.formData.addressLine ?? '';
    }
    if (oldWidget.formData.city != widget.formData.city) {
      _cityController.text = widget.formData.city ?? '';
    }
    if (oldWidget.formData.state != widget.formData.state) {
      _stateController.text = widget.formData.state ?? '';
    }
    if (oldWidget.formData.pincode != widget.formData.pincode) {
      _pincodeController.text = widget.formData.pincode ?? '';
    }
    if (oldWidget.formData.landMark != widget.formData.landMark) {
      _landmarkController.text = widget.formData.landMark ?? '';
    }
  }

  @override
  void dispose() {
    _doorNoController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _update(VendorFormData updated) {
    widget.onChanged(updated);
  }

  Future<void> _initializeLocation() async {
    if (widget.formData.latitude != null && widget.formData.longitude != null) {
      _selectedLocation = LatLng(
        widget.formData.latitude!,
        widget.formData.longitude!,
      );
      await _getAddressFromLatLng(_selectedLocation);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Please enable location services');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showSnack('Location permission denied');
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _selectedLocation = LatLng(position.latitude, position.longitude);
      await _getAddressFromLatLng(_selectedLocation);

      _update(
        widget.formData.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      _updateLatLongControllers();

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation, 15),
      );
    } catch (e) {
      debugPrint(e.toString());
      _showSnack('Unable to get location');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateLatLongControllers() {
    _latitudeController.text = _selectedLocation.latitude.toString();
    _longitudeController.text = _selectedLocation.longitude.toString();
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.subThoroughfare,
          place.thoroughfare,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        if (mounted) {
          setState(() {
            _selectedAddress = address;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          _selectedAddress = 'Address not found';
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 15));
  }

  void _onCameraMove(CameraPosition position) {
    _selectedLocation = position.target;
  }

  Future<void> _onCameraIdle() async {
    await _getAddressFromLatLng(_selectedLocation);
    _updateLatLongControllers();
    _update(
      widget.formData.copyWith(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   'Address & Location',
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.w700,
                //     color: Color(0xFF111827),
                //   ),
                // ),
                // const SizedBox(height: 20),

                _buildInput(
                  label: 'Door No',
                  hint: 'Door Number',
                  controller: _doorNoController,
                  onChanged: (v) =>
                      _update(widget.formData.copyWith(doorNumber: v)),
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                _buildInput(
                  label: 'Street / Address',
                  hint: 'Street Address',
                  controller: _addressLineController,
                  onChanged: (v) =>
                      _update(widget.formData.copyWith(addressLine: v)),
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        label: 'City',
                        hint: 'City',
                        controller: _cityController,
                        onChanged: (v) =>
                            _update(widget.formData.copyWith(city: v)),
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInput(
                        label: 'State',
                        hint: 'State',
                        controller: _stateController,
                        onChanged: (v) =>
                            _update(widget.formData.copyWith(state: v)),
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        label: 'Pincode',
                        hint: 'Pincode',
                        keyboardType: TextInputType.number,
                        controller: _pincodeController,
                        onChanged: (v) =>
                            _update(widget.formData.copyWith(pincode: v)),
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInput(
                        label: 'Landmark',
                        hint: 'Landmark',
                        controller: _landmarkController,
                        onChanged: (v) =>
                            _update(widget.formData.copyWith(landMark: v)),
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        label: 'Latitude',
                        hint: 'Latitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: _latitudeController,
                        onChanged: (v) {
                          final lat = double.tryParse(v);
                          _update(widget.formData.copyWith(latitude: lat));
                          if (lat != null &&
                              widget.formData.longitude != null) {
                            setState(() {
                              _selectedLocation = LatLng(
                                lat,
                                widget.formData.longitude!,
                              );
                            });
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(_selectedLocation),
                            );
                          }
                        },
                        isRequired: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInput(
                        label: 'Longitude',
                        hint: 'Longitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: _longitudeController,
                        onChanged: (v) {
                          final lng = double.tryParse(v);
                          _update(widget.formData.copyWith(longitude: lng));
                          if (lng != null && widget.formData.latitude != null) {
                            setState(() {
                              _selectedLocation = LatLng(
                                widget.formData.latitude!,
                                lng,
                              );
                            });
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(_selectedLocation),
                            );
                          }
                        },
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                InkWell(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2563EB)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Text(
                          'Use my location',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 420,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 15,
                  ),
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _selectedAddress.isNotEmpty
                          ? _selectedAddress
                          : 'Move map to select location',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('← Back'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE66D33),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save & Next',
                        style: TextStyle(color: Colors.white),
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
  }
}
