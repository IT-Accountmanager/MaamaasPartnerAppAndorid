// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// import 'package:google_api_headers/google_api_headers.dart';
//
// import '../../Api/Apiclient.dart';
//
// const String GOOGLE_API_KEY = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
//
// class SavedAddress extends ConsumerStatefulWidget {
//   final void Function(
//     String city,
//     String pincode,
//     String state,
//     double latitude,
//     double longitude,
//     int addressId,
//     String apiResponseBody,
//   )?
//   onAddressSelected;
//
//   const SavedAddress({Key? key, this.onAddressSelected}) : super(key: key);
//
//   @override
//   ConsumerState<SavedAddress> createState() => _SavedAddressState();
// }
//
// class _SavedAddressState extends ConsumerState<SavedAddress> {
//   bool _isUpdating = false;
//   bool _isGettingLocation = false;
//   bool _isLoading = true;
//   bool _showManualAddressForm = false;
//
//   String? _customerId;
//   String? _authToken;
//   String? _userRole;
//   String? _vendorId;
//   String? _username;
//
//   String? _currentAddress;
//   String? _selectedCity;
//   Map<String, dynamic>? _currentLocation;
//
//   List<Map<String, dynamic>> _savedAddresses = [];
//
//   final _formKey = GlobalKey<FormState>();
//   final ScrollController _scrollController = ScrollController();
//
//   final TextEditingController _doorNumberController = TextEditingController();
//   final TextEditingController _addressLineController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//
//   String _selectedCategory = 'Home';
//   final List<String> _categories = ['Home', 'Office', 'Other'];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }
//
//   @override
//   void dispose() {
//     _doorNumberController.dispose();
//     _addressLineController.dispose();
//     _landmarkController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pincodeController.dispose();
//     _nameController.dispose();
//     _phoneNumberController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                               INITIAL LOAD                                 */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _loadInitialData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Get stored data from SharedPreferences
//     _authToken = prefs.getString('token');
//     _userRole = prefs.getString('role');
//     _vendorId = prefs.getString('vendorId');
//     _username = prefs.getString('username');
//     _customerId = prefs.getString("customerId");
//
//     // For vendors, use vendorId as customerId for location APIs
//     if ((_userRole == 'ROLE_VENDOR' || _userRole == 'VENDOR') &&
//         (_vendorId != null && _vendorId!.isNotEmpty)) {
//       print("👤 Vendor detected, using vendorId as customerId: $_vendorId");
//     }
//
//     _selectedCity = prefs.getString('selected_city');
//     _currentAddress = prefs.getString('selected_address');
//
//     print("📊 Final loaded data:");
//     print("   Customer ID: '$_customerId'");
//     print("   Vendor ID: '$_vendorId'");
//     print("   User Role: $_userRole");
//     print("   Username: $_username");
//     print("   Selected City: $_selectedCity");
//
//     // Fetch current location and saved addresses
//     if (_customerId != null && _customerId!.isNotEmpty) {
//       await _fetchCurrentLocation();
//       await _fetchSavedAddresses();
//     } else {
//       print("⚠️ No customerId available - loading saved location from cache");
//       await _loadSavedLocation();
//     }
//
//     _isLoading = false;
//     setState(() {});
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                         GET CURRENT LOCATION API                           */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _fetchCurrentLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final customerId = prefs.getString('customerId');
//     final endpoint = "api/customer/get/current/location?customerId=$customerId";
//
//     try {
//       print("📍 Fetching current location for customerId: $_customerId");
//
//       final response = await ApiClient.get(endpoint, service: "subscription");
//
//       print("📍 Current Location API Status: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         _currentLocation = Map<String, dynamic>.from(decoded);
//         print("📍 Current location loaded: ${_currentLocation?['address']}");
//
//         // Update UI state
//         if (_currentLocation?['city'] != null) {
//           _selectedCity = _currentLocation!['city'];
//         }
//
//         // Update local customerId from response if available
//         if (_currentLocation?['customerId'] != null &&
//             _currentLocation!['customerId'].toString().isNotEmpty) {
//           _customerId = _currentLocation!['customerId'].toString();
//           print("✅ Updated customerId from location response: $_customerId");
//         }
//       } else if (response.statusCode == 404) {
//         print("📭 No current location saved for customerId: $_customerId");
//         _currentLocation = null;
//       } else {
//         print("⚠️ Failed to fetch current location: ${response.statusCode}");
//         _currentLocation = null;
//       }
//     } catch (e) {
//       print("❌ Error fetching current location: $e");
//       _currentLocation = null;
//     }
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                         GET SAVED ADDRESSES API                            */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _fetchSavedAddresses() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final customerId = prefs.getString('customerId');
//     final endpoint = "api/customer/get/current/location?customerId=$customerId";
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await ApiClient.get(endpoint, service: "subscription");
//
//       print("📋 Addresses API Status: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         if (decoded is List) {
//           _savedAddresses = decoded
//               .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
//               .toList();
//           print("📋 Received ${_savedAddresses.length} addresses");
//
//           // Mark current location if found
//           if (_currentLocation != null && _currentLocation!['id'] != null) {
//             final currentLocationId = _currentLocation!['id'];
//             for (var address in _savedAddresses) {
//               if (address['id'] == currentLocationId) {
//                 address['isCurrentLocation'] = true;
//                 break;
//               }
//             }
//           }
//         } else {
//           _savedAddresses = [];
//           print("📭 No addresses found or unexpected format");
//         }
//       } else if (response.statusCode == 404) {
//         _savedAddresses = [];
//         print("📭 No addresses found (404) for customerId: $_customerId");
//       } else {
//         _savedAddresses = [];
//         print("⚠️ Failed to fetch addresses: ${response.statusCode}");
//       }
//     } catch (e) {
//       _savedAddresses = [];
//       print("❌ Error fetching addresses: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                     ADD NEW ADDRESS API (POST)                             */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _addNewAddress(Map<String, dynamic> addressData) async {
//     setState(() => _isUpdating = true);
//     final endpoint = "api/user/location/add";
//
//     try {
//       final response = await ApiClient.post(
//         endpoint,
//         addressData, // ✅ pass the map directly
//         service: "subscription",
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//
//         final newAddress = Map<String, dynamic>.from(responseData);
//         _savedAddresses.add(newAddress);
//
//         // If this is set as current location, update it
//         if (addressData['setAsCurrent'] == true) {
//           // Prepare data for updating current location
//           final updateData = {
//             "customerId": addressData['customerId'],
//             "latitude": addressData['latitude'],
//             "longitude": addressData['longitude'],
//             "address": addressData['address'],
//             "city": addressData['city'],
//             "state": addressData['state'],
//             "pincode": addressData['pincode'],
//           };
//           await _updateCurrentLocation(updateData);
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Address added successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//
//         setState(() {
//           _showManualAddressForm = false;
//         });
//
//         // Reset form
//         _formKey.currentState?.reset();
//         _selectedCategory = 'Home';
//       } else {
//         String errorMsg =
//             'Failed to add address. Status: ${response.statusCode}';
//         try {
//           final errorData = jsonDecode(response.body);
//           if (errorData['error'] != null) {
//             errorMsg = errorData['error'];
//           } else if (errorData['message'] != null) {
//             errorMsg = errorData['message'];
//           }
//         } catch (e) {
//           errorMsg = response.body;
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMsg),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ Error adding address: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to add address: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isUpdating = false);
//     }
//   }
//
//   Future<void> _updateCurrentLocation(Map<String, dynamic> locationData) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerId = prefs.getString('customerId');
//     final endpoint = "api/customer/get/current/location?customerId=$customerId";
//
//     try {
//       // ALWAYS include customerId in the request body
//       final requestBody = {
//         "customerId": customerId, // This is critical
//         "latitude": locationData['latitude'] ?? 0.0,
//         "longitude": locationData['longitude'] ?? 0.0,
//         "address": locationData['address'] ?? "",
//       };
//
//       // Add optional fields if they exist
//       if (locationData['city'] != null) {
//         requestBody['city'] = locationData['city'];
//       }
//       if (locationData['state'] != null) {
//         requestBody['state'] = locationData['state'];
//       }
//       if (locationData['pincode'] != null) {
//         requestBody['pincode'] = locationData['pincode'];
//       }
//
//       print("📦 Update Request Body: ${jsonEncode(requestBody)}");
//
//       final response = await ApiClient.post(
//         endpoint,
//         requestBody, // ✅ pass the map directly
//         service: "subscription",
//       );
//
//       print("🔄 Update Location API Status: ${response.statusCode}");
//       print("🔄 Update Location Response: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         _currentLocation = Map<String, dynamic>.from(responseData);
//
//         // Save to SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         if (locationData['city'] != null) {
//           prefs.setString('selected_city', locationData['city']);
//           _selectedCity = locationData['city'];
//         } else if (responseData['city'] != null) {
//           prefs.setString('selected_city', responseData['city']);
//           _selectedCity = responseData['city'];
//         }
//
//         if (locationData['address'] != null) {
//           prefs.setString('selected_address', locationData['address']);
//           _currentAddress = locationData['address'];
//           print("💾 Saved address from API: ${locationData['address']}");
//         } else if (responseData['address'] != null) {
//           prefs.setString('selected_address', responseData['address']);
//           _currentAddress = responseData['address'];
//           print("💾 Saved address from API: ${responseData['address']}");
//         }
//
//         if (locationData['latitude'] != null) {
//           prefs.setDouble('selected_latitude', locationData['latitude']);
//         }
//         if (locationData['longitude'] != null) {
//           prefs.setDouble('selected_longitude', locationData['longitude']);
//         }
//         if (locationData['state'] != null) {
//           prefs.setString('selected_state', locationData['state']);
//         }
//         if (locationData['pincode'] != null) {
//           prefs.setString(
//             'selected_pincode',
//             locationData['pincode'].toString(),
//           );
//         }
//
//         if (responseData['id'] != null) {
//           prefs.setInt('selected_address_id', responseData['id']);
//         }
//         prefs.setString('location_api_response', response.body);
//
//         // Update the customerId if it's in the response (even if null, we keep our local one)
//         if (responseData['customerId'] != null &&
//             responseData['customerId'].toString().isNotEmpty) {
//         } else {
//           print("⚠️ Response customerId is null, keeping local: $_customerId");
//         }
//
//         // Call the callback if provided
//         widget.onAddressSelected?.call(
//           locationData['city'] ?? responseData['city'] ?? "",
//           locationData['pincode']?.toString() ??
//               responseData['pincode']?.toString() ??
//               "",
//           locationData['state'] ?? responseData['state'] ?? "",
//           locationData['latitude'] ??
//               responseData['latitude']?.toDouble() ??
//               0.0,
//           locationData['longitude'] ??
//               responseData['longitude']?.toDouble() ??
//               0.0,
//           responseData['id'] ?? 0,
//           response.body,
//         );
//
//         // Refresh data - IMPORTANT: Use the same customerId
//         if (_customerId != null && _customerId!.isNotEmpty) {
//           await _fetchCurrentLocation();
//           await _fetchSavedAddresses();
//         } else {
//           print("❌ Cannot refresh data: customerId is null after update");
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Location updated successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         String errorMsg =
//             'Failed to update location. Status: ${response.statusCode}';
//         try {
//           final errorData = jsonDecode(response.body);
//           if (errorData['error'] != null) {
//             errorMsg = errorData['error'];
//           } else if (errorData['message'] != null) {
//             errorMsg = errorData['message'];
//           }
//         } catch (e) {
//           errorMsg = response.body;
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMsg),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ Error updating location: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update location: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                          CURRENT GPS LOCATION                              */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _getCurrentLocation() async {
//     setState(() => _isGettingLocation = true);
//
//     try {
//       // Check permissions
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Location services are disabled. Please enable them.',
//             ),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Location permissions are denied.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Location permissions are permanently denied. Please enable from app settings.',
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//
//       // Get current position
//       final pos = await Geolocator.getCurrentPosition();
//       final placemarks = await placemarkFromCoordinates(
//         pos.latitude,
//         pos.longitude,
//       );
//
//       if (placemarks.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Could not retrieve address from coordinates.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//
//       final p = placemarks.first;
//       final address =
//           "${p.subThoroughfare ?? ''} ${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''} - ${p.postalCode ?? ''}";
//
//       print("📍 Got current location: ${p.locality}");
//
//       // Prepare location data for current location update
//       final locationData = {
//         "customerId": _customerId, // This is the key fix - sending customerId
//         "latitude": pos.latitude,
//         "longitude": pos.longitude,
//         "address": address,
//         "city": p.locality ?? "Current Location",
//         "state": p.administrativeArea ?? "",
//         "pincode": p.postalCode ?? "0",
//       };
//
//       // Update current location
//       await _updateCurrentLocation(locationData);
//     } catch (e) {
//       print("❌ Location error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to get location: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isGettingLocation = false);
//     }
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                        SEARCH PLACES (Google Places)                       */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _searchPlaces() async {
//     try {
//       Prediction? p = await PlacesAutocomplete.show(
//         context: context,
//         apiKey: GOOGLE_API_KEY,
//         mode: Mode.overlay,
//         language: "en",
//         components: [Component(Component.country, "in")],
//         logo: SizedBox.shrink(),
//       );
//
//       if (p != null) {
//         // Get place details
//         GoogleMapsPlaces places = GoogleMapsPlaces(
//           apiKey: GOOGLE_API_KEY,
//           apiHeaders: await GoogleApiHeaders().getHeaders(),
//         );
//
//         PlacesDetailsResponse detail = await places.getDetailsByPlaceId(
//           p.placeId!,
//         );
//         final location = detail.result.geometry!.location;
//         final address = detail.result.formattedAddress ?? p.description!;
//
//         // Get city, state, pincode from address
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//           location.lat,
//           location.lng,
//         );
//
//         String city = "";
//         String state = "";
//         String pincode = "";
//         String doorNumber = "";
//         String street = "";
//
//         if (placemarks.isNotEmpty) {
//           Placemark place = placemarks.first;
//           city = place.locality ?? place.subAdministrativeArea ?? '';
//           state = place.administrativeArea ?? '';
//           pincode = place.postalCode ?? '';
//           doorNumber = place.subThoroughfare ?? '';
//           street = place.street ?? '';
//         }
//
//         // Prepare location data for current location update
//         final locationData = {
//           "customerId": _customerId, // This is the key fix - sending customerId
//           "latitude": location.lat,
//           "longitude": location.lng,
//           "address": address,
//           "city": city.isNotEmpty ? city : "Selected Location",
//           "state": state,
//           "pincode": pincode.isNotEmpty ? pincode : "0",
//         };
//
//         // Update current location
//         await _updateCurrentLocation(locationData);
//       }
//     } catch (e) {
//       print("❌ Places search error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Search failed: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                         LOAD SAVED LOCATION (FALLBACK)                     */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _loadSavedLocation() async {
//     print("🔍 Loading saved location from SharedPreferences...");
//
//     final prefs = await SharedPreferences.getInstance();
//     final savedCity = prefs.getString('selected_city');
//     final savedState = prefs.getString('selected_state');
//     final savedPincode = prefs.getString('selected_pincode');
//     final savedLat = prefs.getDouble('selected_latitude');
//     final savedLng = prefs.getDouble('selected_longitude');
//     final savedAddressId = prefs.getInt('selected_address_id');
//     final savedAddress = prefs.getString('location_api_response');
//
//     if (savedCity != null && savedCity.isNotEmpty) {
//       print("📍 Found saved location: $savedCity");
//
//       Map<String, dynamic> addressData = {};
//       if (savedAddress != null && savedAddress.isNotEmpty) {
//         try {
//           addressData = jsonDecode(savedAddress);
//         } catch (e) {
//           print("⚠️ Could not parse saved address: $e");
//         }
//       }
//
//       final savedAddressEntry = {
//         'id': savedAddressId ?? addressData['id'] ?? 0,
//         'doorNumber': addressData['doorNumber'] ?? '',
//         'addressLine': addressData['addressLine'] ?? '',
//         'landMark': addressData['landMark'] ?? '',
//         'city': savedCity,
//         'state': savedState ?? addressData['state'] ?? '',
//         'pincode': savedPincode ?? addressData['pincode']?.toString() ?? '',
//         'name': addressData['name'] ?? 'Saved Location',
//         'phoneNumber': addressData['phoneNumber'] ?? '',
//         'latitude': savedLat ?? addressData['latitude']?.toDouble() ?? 0.0,
//         'longitude': savedLng ?? addressData['longitude']?.toDouble() ?? 0.0,
//         'address':
//             addressData['address'] ??
//             "${savedCity}, ${savedState ?? ''} - ${savedPincode ?? ''}",
//         'category': addressData['category'] ?? 'Home',
//         'customerId': addressData['customerId'] ?? _customerId,
//         'isCurrentLocation': true,
//       };
//
//       setState(() {
//         _savedAddresses = [savedAddressEntry];
//         _currentLocation = savedAddressEntry;
//       });
//     } else {
//       print("📭 No saved location found");
//     }
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                      MANUAL ADDRESS FORM SUBMIT                           */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _submitManualAddress() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     // Prepare address data
//     final addressData = {
//       "customerId": _customerId,
//       "doorNumber": _doorNumberController.text.trim(),
//       "addressLine": _addressLineController.text.trim(),
//       "landMark": _landmarkController.text.trim(),
//       "city": _cityController.text.trim(),
//       "state": _stateController.text.trim(),
//       "pincode": int.tryParse(_pincodeController.text.trim()) ?? 0,
//       "name": _nameController.text.trim().isNotEmpty
//           ? _nameController.text.trim()
//           : "My Address",
//       "phoneNumber": _phoneNumberController.text.trim(),
//       "latitude": 0.0, // Default value
//       "longitude": 0.0, // Default value
//       "address":
//           "${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pincodeController.text.trim()}",
//       "category": _selectedCategory, // This should be Home, Office, or Other
//       "setAsCurrent": true,
//     };
//
//     await _addNewAddress(addressData);
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                          ADDRESS CARD TAP HANDLER                          */
//   /* -------------------------------------------------------------------------- */
//
//   Future<void> _onAddressCardTap(Map<String, dynamic> address) async {
//     // Prepare location data for update
//     final locationData = {
//       "customerId": address['customerId'] ?? _customerId,
//       "latitude": address['latitude']?.toDouble() ?? 0.0,
//       "longitude": address['longitude']?.toDouble() ?? 0.0,
//       "address":
//           address['address'] ??
//           "${address['city']}, ${address['state']} - ${address['pincode']}",
//       "city": address['city'] ?? "Unknown City",
//       "state": address['state'] ?? "",
//       "pincode": address['pincode']?.toString() ?? "",
//     };
//
//     await _updateCurrentLocation(locationData);
//   }
//
//   /* -------------------------------------------------------------------------- */
//   /*                                UI WIDGETS                                 */
//   /* -------------------------------------------------------------------------- */
//
//   Widget _buildAddressCard(Map<String, dynamic> address) {
//     final String addressText = address['address'] ?? 'No address';
//     final bool isCurrentLocation = address['isCurrentLocation'] == true;
//
//     // Extract city, state, pincode
//     String city = address['city'] ?? "Unknown City";
//     String state = address['state'] ?? "";
//     String pincode = address['pincode']?.toString() ?? "";
//     String category = address['category'] ?? "Home";
//
//     final bool isSelected = _selectedCity == city;
//
//     return Card(
//       color: Colors.white,
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: isSelected ? Color(0xFFB15DC6) : Colors.grey.shade300,
//           width: isSelected ? 2 : 1,
//         ),
//       ),
//       child: InkWell(
//         onTap: () => _onAddressCardTap(address),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? Color(0xFFB15DC6).withOpacity(0.1)
//                       : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   _getCategoryIcon(category),
//                   color: isSelected ? Color(0xFFB15DC6) : Colors.grey,
//                 ),
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             address['name']?.isNotEmpty == true
//                                 ? address['name']
//                                 : city,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: isSelected
//                                   ? Color(0xFFB15DC6)
//                                   : Colors.black,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         if (isCurrentLocation)
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               borderRadius: BorderRadius.circular(4),
//                               border: Border.all(color: Colors.blue.shade100),
//                             ),
//                             child: Text(
//                               'CURRENT',
//                               style: TextStyle(
//                                 color: Colors.blue.shade700,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         SizedBox(width: 4),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _getCategoryColor(category).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(
//                               color: _getCategoryColor(
//                                 category,
//                               ).withOpacity(0.3),
//                             ),
//                           ),
//                           child: Text(
//                             category.toUpperCase(),
//                             style: TextStyle(
//                               color: _getCategoryColor(category),
//                               fontSize: 9,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 4),
//                     if (address['addressLine'] != null &&
//                         address['addressLine'].toString().isNotEmpty)
//                       Text(
//                         address['addressLine'].toString(),
//                         style: TextStyle(
//                           color: Colors.grey.shade800,
//                           fontSize: 14,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     Text(
//                       addressText,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 13,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 4),
//                     Row(
//                       children: [
//                         if (pincode.isNotEmpty)
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               'PIN: $pincode',
//                               style: TextStyle(
//                                 color: Colors.grey.shade700,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         SizedBox(width: 8),
//                         if (state.isNotEmpty)
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade50,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               state,
//                               style: TextStyle(
//                                 color: Colors.green.shade700,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 isSelected ? Icons.check_circle : Icons.chevron_right,
//                 color: isSelected ? Color(0xFFB15DC6) : Colors.grey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   IconData _getCategoryIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'home':
//         return Icons.home;
//       case 'office':
//         return Icons.work;
//       case 'other':
//         return Icons.location_on;
//       default:
//         return Icons.location_on;
//     }
//   }
//
//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'home':
//         return Colors.green;
//       case 'office':
//         return Colors.blue;
//       case 'other':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Widget _buildAddAddressButton() {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Color(0xFF34C759).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(Icons.add_location_alt, color: Color(0xFF34C759)),
//         ),
//         title: Text(
//           'Add New Address',
//           style: TextStyle(fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text(
//           'Enter address manually',
//           style: TextStyle(fontSize: 12),
//         ),
//         trailing: Icon(Icons.chevron_right, color: Colors.grey),
//         onTap: () {
//           setState(() {
//             _showManualAddressForm = true;
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _buildManualAddressForm() {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Add New Address',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close, color: Colors.grey),
//                     onPressed: () {
//                       setState(() {
//                         _showManualAddressForm = false;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Category Selection - FIXED to use exact backend enum values
//                     DropdownButtonFormField<String>(
//                       value: _selectedCategory,
//                       decoration: InputDecoration(
//                         labelText: 'Address Type',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(Icons.category, color: Colors.grey),
//                       ),
//                       items: _categories.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Row(
//                             children: [
//                               Icon(_getCategoryIcon(value), size: 20),
//                               SizedBox(width: 10),
//                               Text(value),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedCategory = newValue!;
//                         });
//                       },
//                     ),
//                     SizedBox(height: 12),
//
//                     // Name (Optional)
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         labelText: 'Name (Optional)',
//                         hintText: 'e.g., Home, Office, John\'s House',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(Icons.person, color: Colors.grey),
//                       ),
//                     ),
//                     SizedBox(height: 12),
//
//                     // Door Number (Optional)
//                     TextFormField(
//                       controller: _doorNumberController,
//                       decoration: InputDecoration(
//                         labelText: 'House/Door No. (Optional)',
//                         hintText: 'e.g., 123, A-101',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(Icons.house, color: Colors.grey),
//                       ),
//                     ),
//                     SizedBox(height: 12),
//
//                     // Address Line
//                     TextFormField(
//                       controller: _addressLineController,
//                       decoration: InputDecoration(
//                         labelText: 'Street, Building, Area',
//                         hintText: 'e.g., Main Street, Apartment 4B',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(Icons.streetview, color: Colors.grey),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter street/building/area';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 12),
//
//                     // Landmark (Optional)
//                     TextFormField(
//                       controller: _landmarkController,
//                       decoration: InputDecoration(
//                         labelText: 'Landmark (Optional)',
//                         hintText: 'e.g., Near Central Park, Opposite Bank',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(Icons.place, color: Colors.grey),
//                       ),
//                     ),
//                     SizedBox(height: 12),
//
//                     // City
//                     TextFormField(
//                       controller: _cityController,
//                       decoration: InputDecoration(
//                         labelText: 'City',
//                         hintText: 'e.g., Mumbai',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(
//                           Icons.location_city,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter city';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 12),
//
//                     // State
//                     TextFormField(
//                       controller: _stateController,
//                       decoration: InputDecoration(
//                         labelText: 'State',
//                         hintText: 'e.g., Maharashtra',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(Icons.map, color: Colors.grey),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter state';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 12),
//
//                     // Pincode
//                     TextFormField(
//                       controller: _pincodeController,
//                       decoration: InputDecoration(
//                         labelText: 'Pincode',
//                         hintText: 'e.g., 400001',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(
//                           Icons.local_post_office,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter pincode';
//                         }
//                         if (value.trim().length != 6) {
//                           return 'Pincode must be 6 digits';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 12),
//
//                     // Phone Number (Optional)
//                     TextFormField(
//                       controller: _phoneNumberController,
//                       decoration: InputDecoration(
//                         labelText: 'Phone Number (Optional)',
//                         hintText: 'e.g., 9876543210',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: Icon(Icons.phone, color: Colors.grey),
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),
//                     SizedBox(height: 24),
//
//                     // Submit Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isUpdating ? null : _submitManualAddress,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF34C759),
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: _isUpdating
//                             ? SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.save, size: 20),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Save Address',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_off, size: 80, color: Colors.grey.shade300),
//             SizedBox(height: 20),
//             Text(
//               'No saved addresses found',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Add your first address by searching\nor using current location',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//             SizedBox(height: 10),
//             if (_customerId != null && _customerId!.isNotEmpty)
//               Column(
//                 children: [
//                   Text(
//                     'Customer ID:',
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                   ),
//                   SelectableText(
//                     _customerId!,
//                     style: TextStyle(
//                       color: Colors.blue.shade600,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             if (_userRole != null)
//               Text(
//                 'Role: $_userRole',
//                 style: TextStyle(color: Colors.purple.shade600, fontSize: 12),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB15DC6)),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Loading locations...',
//             style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//           ),
//           SizedBox(height: 10),
//           if (_customerId != null && _customerId!.isNotEmpty)
//             Column(
//               children: [
//                 Text(
//                   'Customer ID:',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//                 ),
//                 SelectableText(
//                   _customerId!,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.blue.shade600,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             )
//           else
//             Text(
//               'No customer ID found',
//               style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
//             ),
//           if (_userRole != null)
//             Text(
//               'Role: $_userRole',
//               style: TextStyle(fontSize: 12, color: Colors.purple.shade600),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Container(
//       margin: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: _searchPlaces,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           child: Row(
//             children: [
//               Icon(Icons.search, color: Color(0xFFB15DC6)),
//               SizedBox(width: 12),
//               Text(
//                 'Search for area, street name...',
//                 style: TextStyle(color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCurrentLocationButton() {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Color(0xFFB15DC6).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(Icons.my_location, color: Color(0xFFB15DC6)),
//         ),
//         title: Text(
//           'Use Current Location',
//           style: TextStyle(fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text(
//           _currentLocation?['address'] ??
//               _currentAddress ??
//               'Tap to detect your location',
//           style: TextStyle(fontSize: 12),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         trailing: _isGettingLocation
//             ? SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB15DC6)),
//                 ),
//               )
//             : Icon(Icons.chevron_right, color: Colors.grey),
//         onTap: _getCurrentLocation,
//       ),
//     );
//   }
//
//   Widget _buildSavedAddressesList() {
//     return _isLoading
//         ? _buildLoadingState()
//         : _savedAddresses.isEmpty
//         ? _buildEmptyState()
//         : RefreshIndicator(
//             onRefresh: () async {
//               if (_customerId != null && _customerId!.isNotEmpty) {
//                 await _fetchSavedAddresses();
//                 await _fetchCurrentLocation();
//               }
//             },
//             color: Color(0xFFB15DC6),
//             child: ListView.builder(
//               padding: EdgeInsets.only(bottom: 16),
//               itemCount: _savedAddresses.length,
//               itemBuilder: (context, index) {
//                 final address = _savedAddresses[index];
//                 return _buildAddressCard(address);
//               },
//             ),
//           );
//   }
//
//   Widget _buildMainContent() {
//     if (_showManualAddressForm) {
//       return _buildManualAddressForm();
//     } else {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Search bar
//           _buildSearchBar(),
//
//           // Current location button
//           _buildCurrentLocationButton(),
//
//           // Add Address button (shown when manual form is hidden)
//           _buildAddAddressButton(),
//
//           Divider(height: 1),
//
//           if (_savedAddresses.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(left: 20, top: 8, bottom: 8),
//               child: Text(
//                 'SAVED ADDRESSES',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade600,
//                   fontSize: 14,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//
//           // Saved addresses list
//           Expanded(child: _buildSavedAddressesList()),
//         ],
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Text('Select Location'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadInitialData,
//             tooltip: 'Refresh all data',
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           _buildMainContent(),
//
//           // Loading overlay
//           if (_isUpdating || _isGettingLocation)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Color(0xFFB15DC6),
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         _isGettingLocation
//                             ? 'Getting location...'
//                             : 'Updating location...',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 16,
//                         ),
//                       ),
//                       if (_customerId != null) SizedBox(height: 8),
//                       Text(
//                         'Customer ID: $_customerId',
//                         style: TextStyle(fontSize: 12, color: Colors.blue),
//                       ),
//                       if (_userRole != null) SizedBox(height: 4),
//                       Text(
//                         'Role: $_userRole',
//                         style: TextStyle(fontSize: 12, color: Colors.purple),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
