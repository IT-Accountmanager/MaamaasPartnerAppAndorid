// import 'package:flutter/material.dart';
// import 'package:maamaaspartner/RegistrationScreen/steps/MapPickerScree.dart';
// import '../models/vendor_form_data.dart';
// import '../widgets/common_widgets.dart';
//
// class CompanyProfileStep extends StatefulWidget {
//   final VendorFormData formData;
//   final ValueChanged<VendorFormData> onChanged;
//   final VoidCallback onNext;
//
//   const CompanyProfileStep({
//     super.key,
//     required this.formData,
//     required this.onChanged,
//     required this.onNext,
//   });
//
//   @override
//   State<CompanyProfileStep> createState() => _CompanyProfileStepState();
// }
//
// class _CompanyProfileStepState extends State<CompanyProfileStep> {
//   final _businessTypes = [
//     {'value': 'HOTEL', 'label': 'Hotel'},
//     {'value': 'RESTAURANT', 'label': 'Restaurant'},
//     {'value': 'CAFE', 'label': 'Cafe'},
//     {'value': 'CLOUD_KITCHEN', 'label': 'Cloud Kitchen'},
//     {'value': 'FOOD_COURT', 'label': 'Food Court'},
//     {'value': 'STREET_FOOD', 'label': 'Street Food'},
//     {'value': 'BAKERY', 'label': 'Bakery'},
//   ];
//
//   void _update(VendorFormData updated) => widget.onChanged(updated);
//
//   String _getValidDropdownValue(String? apiValue) {
//     if (apiValue == null || apiValue.isEmpty) return '';
//     final upperValue = apiValue.toUpperCase();
//     final exists = _businessTypes.any((type) => type['value'] == upperValue);
//     if (exists) return upperValue;
//
//     final mappedValue = _mapBusinessType(apiValue);
//     if (mappedValue != null) return mappedValue;
//     return '';
//   }
//
//   String? _mapBusinessType(String apiValue) {
//     final lowerValue = apiValue.toLowerCase();
//     switch (lowerValue) {
//       case 'restaurant':
//         return 'RESTAURANT';
//       case 'hotel':
//         return 'HOTEL';
//       case 'cafe':
//         return 'CAFE';
//       case 'cloud kitchen':
//       case 'cloud_kitchen':
//         return 'CLOUD_KITCHEN';
//       case 'food court':
//       case 'food_court':
//         return 'FOOD_COURT';
//       case 'street food':
//       case 'street_food':
//         return 'STREET_FOOD';
//       case 'bakery':
//         return 'BAKERY';
//       default:
//         return null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final f = widget.formData;
//     final validVerticalType = _getValidDropdownValue(f.verticalType);
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SectionTitle('Company Details'),
//
//           LabeledInput(
//             label: 'Company Name *',
//             placeholder: 'Enter company name',
//             value: f.companyName,
//             onChanged: (v) => _update(f.copyWith(companyName: v)),
//           ),
//           const SizedBox(height: 14),
//
//           LabeledInput(
//             label: 'Business Vertical *',
//             placeholder: '',
//             value: 'Food & Beverages',
//             onChanged: (_) {},
//             readOnly: true,
//           ),
//           const SizedBox(height: 14),
//
//           LabeledInput(
//             label: 'Position *',
//             placeholder: 'Enter position',
//             value: f.position,
//             onChanged: (v) => _update(f.copyWith(position: v)),
//           ),
//           const SizedBox(height: 14),
//
//           LabeledDropdown(
//             label: 'Business Type *',
//             value: validVerticalType,
//             items: _businessTypes,
//             onChanged: (v) => _update(f.copyWith(verticalType: v ?? '')),
//           ),
//           const SizedBox(height: 20),
//
//           const SectionTitle('Address Details'),
//
//           Row(
//             children: [
//               Expanded(
//                 child: LabeledInput(
//                   label: 'Door No',
//                   placeholder: 'Door number',
//                   value: f.doorNumber,
//                   onChanged: (v) => _update(f.copyWith(doorNumber: v)),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: LabeledInput(
//                   label: 'Street / Address',
//                   placeholder: 'Street',
//                   value: f.addressLine,
//                   onChanged: (v) => _update(f.copyWith(addressLine: v)),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//
//           Row(
//             children: [
//               Expanded(
//                 child: LabeledInput(
//                   label: 'City',
//                   placeholder: 'City',
//                   value: f.city,
//                   onChanged: (v) => _update(f.copyWith(city: v)),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: LabeledInput(
//                   label: 'State',
//                   placeholder: 'State',
//                   value: f.state,
//                   onChanged: (v) => _update(f.copyWith(state: v)),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//
//           Row(
//             children: [
//               Expanded(
//                 child: LabeledInput(
//                   label: 'Pincode',
//                   placeholder: 'Pincode',
//                   value: f.pincode,
//                   keyboardType: TextInputType.number,
//                   onChanged: (v) => _update(f.copyWith(pincode: v)),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: LabeledInput(
//                   label: 'Landmark',
//                   placeholder: 'Landmark',
//                   value: f.landMark,
//                   onChanged: (v) => _update(f.copyWith(landMark: v)),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//
//           Row(
//             children: [
//               Expanded(
//                 child: LabeledInput(
//                   label: 'Latitude',
//                   placeholder: 'Latitude',
//                   value: f.latitude?.toString() ?? '',
//                   keyboardType: TextInputType.number,
//                   onChanged: (v) =>
//                       _update(f.copyWith(latitude: double.tryParse(v))),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: LabeledInput(
//                   label: 'Longitude',
//                   placeholder: 'Longitude',
//                   value: f.longitude?.toString() ?? '',
//                   keyboardType: TextInputType.number,
//                   onChanged: (v) =>
//                       _update(f.copyWith(longitude: double.tryParse(v))),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Location *',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: kTextMid,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: double.infinity,
//                 height: 46,
//                 child: OutlinedButton.icon(
//                   onPressed: () async {
//                     final result = await Navigator.push<Map<String, dynamic>>(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MapPickerScreen(
//                           initialLatitude: f.latitude,
//                           initialLongitude: f.longitude,
//                           onLocationSelected: (lat, lng, address) {
//                             Navigator.pop(context, {
//                               'latitude': lat,
//                               'longitude': lng,
//                               'address': address,
//                             });
//                           },
//                         ),
//                       ),
//                     );
//                     if (result != null && mounted) {
//                       _update(
//                         f.copyWith(
//                           latitude: result['latitude'] as double,
//                           longitude: result['longitude'] as double,
//                           address: result['address'] as String,
//                         ),
//                       );
//                     }
//                   },
//                   icon: const Icon(
//                     Icons.location_on,
//                     color: Color(0xFF2563EB),
//                     size: 18,
//                   ),
//                   label: const Text(
//                     'Add Location',
//                     style: TextStyle(
//                       color: Color(0xFF2563EB),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Color(0xFF2563EB)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 28),
//           NextButton(label: 'Next →', onPressed: widget.onNext),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
