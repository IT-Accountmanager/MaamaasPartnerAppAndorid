// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import 'package:maamaas_app/API/Auth_service.dart';
// import 'package:maamaas_app/API/catering_authservice.dart';
// import 'package:maamaas_app/Models/address_model.dart';
// import 'package:table_calendar/table_calendar.dart';
// import '../../Models/caterings/dish.dart';
// import '../saved_address.dart';
//
// class CustomisedMenu extends StatefulWidget {
//   const CustomisedMenu({super.key});
//
//   @override
//   State<CustomisedMenu> createState() => _CustomisedMenuState();
// }
//
// class _CustomisedMenuState extends State<CustomisedMenu> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _contactController = TextEditingController();
//   final _specialrequestsController = TextEditingController();
//   final _dateController = TextEditingController();
//   final _timeController = TextEditingController();
//   final _peopleController = TextEditingController();
//   final _budgetController = TextEditingController();
//   final _fulladdressController = TextEditingController();
//   final _countryController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _vegController = TextEditingController();
//   final _nonvegController = TextEditingController();
//   final _mixedController = TextEditingController();
//   bool _isVeg = true;
//   String? _selectedEventType;
//   Map<String, List<Dish>> categoryItems = {};
//   List<String> customizedCategories = [];
//   List<int> selectedItems = [];
//   bool _isSubmitting = false;
//   String? selectedAddress;
//   int? selectedAddressId;
//
//   void initState() {
//     super.initState();
//     loadCategories();
//   }
//
//   Future<void> loadCategories() async {
//     List<Dish> dishes = await catering_authservice.fetchDishes();
//     List<Dish> categories = dishes.where((d) => d.parentId == 0).toList();
//
//     categoryItems.clear();
//     customizedCategories.clear();
//
//     for (var category in categories) {
//       List<Dish> items = dishes
//           .where((d) => d.parentId == category.dishId)
//           .toList();
//
//       customizedCategories.add(category.dishName);
//       categoryItems[category.dishName] = items;
//     }
//
//     setState(() {});
//   }
//
//   void _showSummarySheet(BuildContext context) {
//     showModalBottomSheet(
//       backgroundColor: Colors.white,
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 16,
//           ),
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * 0.9,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Enquiry Summary",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const Divider(),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildDetailRow("Name", _nameController.text),
//                         _buildDetailRow("Email", _emailController.text),
//                         _buildDetailRow("Contact", _contactController.text),
//                         _buildDetailRow("Event Type", _selectedEventType ?? ""),
//                         _buildDetailRow("Date", _dateController.text),
//                         _buildDetailRow("Time", _timeController.text),
//                         _buildDetailRow("People", _peopleController.text),
//                         _buildDetailRow(
//                           "full address",
//                           selectedAddress == null
//                               ? 'Not selected'
//                               : selectedAddress.toString(),
//                         ),
//                         _buildDetailRow("Country", _countryController.text),
//                         _buildDetailRow("State", _stateController.text),
//                         _buildDetailRow("City", _cityController.text),
//                         _buildDetailRow("Veg Plates", _vegController.text),
//                         _buildDetailRow(
//                           "Non-Veg Plates",
//                           _nonvegController.text,
//                         ),
//                         _buildDetailRow("Mixed Plates", _mixedController.text),
//                         _buildDetailRow(
//                           "Special Requests",
//                           _specialrequestsController.text,
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           "Selected Items",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//
//                         ...categoryItems.entries.map((entry) {
//                           final category = entry.key;
//                           final items = entry.value
//                               .where(
//                                 (dish) => selectedItems.contains(dish.dishId),
//                           )
//                               .toList();
//                           if (items.isEmpty) return const SizedBox.shrink();
//
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 category,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.deepPurple,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               ...items.map((dish) {
//                                 return Card(
//                                   color: Colors.white,
//                                   child: ListTile(
//                                     title: Text(
//                                       dish.dishName,
//                                     ), // ✅ display name
//                                     trailing: IconButton(
//                                       icon: const Icon(
//                                         Icons.delete,
//                                         color: Colors.red,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           selectedItems.remove(
//                                             dish.dishId,
//                                           ); // ✅ remove by ID
//                                         });
//                                         Navigator.pop(context);
//                                         _showSummarySheet(
//                                           context,
//                                         ); // refresh bottom sheet
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               }),
//                               const SizedBox(height: 8),
//                             ],
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple,
//                       foregroundColor: Colors.white,
//                     ),
//                     onPressed: _isSubmitting
//                         ? null // disable button while loading
//                         : () async {
//                       setState(() => _isSubmitting = true);
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Submitting enquiry..."),
//                           backgroundColor: Colors.blue,
//                         ),
//                       );
//                       final success = await catering_authservice
//                           .createEnquiry(
//                         fullName: _nameController.text,
//                         email: _emailController.text,
//                         phoneNumber: _contactController.text,
//                         eventType: _selectedEventType ?? "",
//                         eventDate: _dateController.text,
//                         eventTime: _timeController.text,
//                         people: _peopleController.text,
//                         budget: _budgetController.text,
//                         fullAddress: _fulladdressController.text,
//                         country: _countryController.text,
//                         state: _stateController.text,
//                         city: _cityController.text,
//                         vegPlates: _vegController.text,
//                         nonVegPlates: _nonvegController.text,
//                         mixedPlates: _mixedController.text,
//                         specialRequests:
//                         _specialrequestsController.text,
//                         selectedItems: selectedItems.toList(),
//                         addressId: selectedAddressId,
//                       );
//                       if (success) {
//                         Navigator.pop(context);
//                         setState(() {
//                           _nameController.clear();
//                           _emailController.clear();
//                           _contactController.clear();
//                           _selectedEventType = null;
//                           _dateController.clear();
//                           _timeController.clear();
//                           _peopleController.clear();
//                           _budgetController.clear();
//                           _fulladdressController.clear();
//                           _countryController.clear();
//                           _stateController.clear();
//                           _cityController.clear();
//                           _vegController.clear();
//                           _nonvegController.clear();
//                           _mixedController.clear();
//                           _specialrequestsController.clear();
//                           selectedItems.clear();
//                           selectedAddressId = null;
//                         });
//
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               "Enquiry Submitted Successfully!",
//                             ),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Failed to submit enquiry!"),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     },
//
//                     child: const Text("Submit Enquiry"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return value.isNotEmpty
//         ? Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(
//             "$label: ",
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     )
//         : const SizedBox.shrink();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildForm(),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Select your Menu",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple,
//                     ),
//                   ),
//
//                   // Veg / Non-Veg Toggle
//                   FlutterSwitch(
//                     width: 85,
//                     height: 40,
//                     toggleSize: 30,
//                     borderRadius: 20,
//                     value: _isVeg,
//                     showOnOff: true,
//                     activeColor: Colors.green,
//                     inactiveColor: Colors.red,
//                     activeToggleColor: Colors.white,
//                     inactiveToggleColor: Colors.white,
//                     activeText: "Veg",
//                     inactiveText: "Non_Veg",
//                     valueFontSize: 10,
//                     toggleColor: Colors.white70,
//                     onToggle: (val) {
//                       setState(() => _isVeg = val);
//                     },
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//               _buildCategoryItems(),
//               // const SizedBox(height: 16),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _specialrequestsController,
//                 decoration: const InputDecoration(
//                   labelText: "Special Requests (optional)",
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: () {
//                     _showSummarySheet(context);
//                   },
//                   child: const Text("Submit"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildForm() {
//     DateTime today = DateTime.now();
//     DateTime firstAllowedDate = today.add(
//       Duration(days: 2),
//     ); // Only after 3 days
//     DateTime lastAllowedDate = today.add(Duration(days: 365));
//
//     DateTime _focusedDay = firstAllowedDate;
//     DateTime? _selectedDay;
//
//     void _showCupertinoDatePicker(BuildContext context) {
//       showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (_) {
//           return SizedBox(
//             height: 300,
//             child: CupertinoDatePicker(
//               mode: CupertinoDatePickerMode.date,
//               minimumDate: firstAllowedDate,
//               maximumDate: lastAllowedDate,
//               initialDateTime: firstAllowedDate,
//               onDateTimeChanged: (DateTime date) {
//                 _dateController.text =
//                 "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//               },
//             ),
//           );
//         },
//       );
//     }
//
//     void _showCalendarBottomSheet(BuildContext context) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (_) {
//           return SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       "Select Event Date",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     TableCalendar(
//                       firstDay: firstAllowedDate,
//                       lastDay: lastAllowedDate,
//
//                       focusedDay: _focusedDay,
//
//                       selectedDayPredicate: (day) =>
//                           isSameDay(_selectedDay, day),
//
//                       calendarStyle: const CalendarStyle(
//                         todayDecoration: BoxDecoration(
//                           color: Colors.deepPurple,
//                           shape: BoxShape.circle,
//                         ),
//                         selectedDecoration: BoxDecoration(
//                           color: Colors.deepPurpleAccent,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//
//                       onDaySelected: (selectedDay, focusedDay) {
//                         setState(() {
//                           _selectedDay = selectedDay;
//                           _focusedDay = focusedDay;
//                         });
//
//                         _dateController.text =
//                         "${selectedDay.day.toString().padLeft(2, '0')}-"
//                             "${selectedDay.month.toString().padLeft(2, '0')}-"
//                             "${selectedDay.year}";
//
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }
//
//     void _showCupertinoTimePicker(BuildContext context) {
//       showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (_) {
//           return SizedBox(
//             height: 250,
//             child: CupertinoDatePicker(
//               mode: CupertinoDatePickerMode.time,
//               use24hFormat: false,
//               onDateTimeChanged: (DateTime time) {
//                 final formatted = TimeOfDay.fromDateTime(time).format(context);
//                 _timeController.text = formatted;
//               },
//             ),
//           );
//         },
//       );
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // const Text(
//         //   "Enter Event Details",
//         //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         // ),
//         // const SizedBox(height: 16),
//         // TextField(
//         //   controller: _nameController,
//         //   decoration: const InputDecoration(
//         //     labelText: "Name",
//         //     border: OutlineInputBorder(),
//         //   ),
//         // ),
//         // const SizedBox(height: 12),
//
//         // const SizedBox(height: 12),
//         // TextField(
//         //   controller: _contactController,
//         //   decoration: const InputDecoration(
//         //     labelText: "Contact Number",
//         //     border: OutlineInputBorder(),
//         //   ),
//         //   keyboardType: TextInputType.phone,
//         // ),
//         const SizedBox(height: 12),
//         DropdownButtonFormField<String>(
//           initialValue: _selectedEventType,
//           decoration: const InputDecoration(
//             labelText: "Event Type",
//             border: OutlineInputBorder(),
//           ),
//           dropdownColor: Colors.white,
//           items:
//           [
//             "WEDDING",
//             "BIRTHDAY",
//             // "CORPORATE",
//             "ENGAGEMENT",
//             "ANNIVERSARY",
//             "OTHER",
//           ]
//               .map(
//                 (type) => DropdownMenuItem(value: type, child: Text(type)),
//           )
//               .toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedEventType = value;
//             });
//           },
//         ),
//
//         const SizedBox(height: 12),
//
//         // TextField(
//         //   controller: _dateController,
//         //   decoration: const InputDecoration(
//         //     labelText: "Event Date",
//         //     hintText: "Select date",
//         //     border: OutlineInputBorder(),
//         //     suffixIcon: Icon(Icons.calendar_today),
//         //   ),
//         //   readOnly: true,
//         //   // onTap: () => _showCupertinoDatePicker(context),
//         //   onTap: () => _showCalendarBottomSheet(context),
//         //
//         //   //
//         // ),
//         TextField(
//           controller: _dateController,
//           decoration: const InputDecoration(
//             labelText: "Event Date",
//             hintText: "Select date",
//             border: OutlineInputBorder(),
//             suffixIcon: Icon(Icons.calendar_today),
//           ),
//           readOnly: true,
//           onTap: () async {
//             DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: firstAllowedDate, // Start picker from allowed date
//               firstDate: firstAllowedDate, // Disable all before this
//               lastDate: lastAllowedDate, // Allow only next 3 days
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: ColorScheme.light(
//                       primary: Colors.deepPurple, // header background color
//                       onPrimary: Colors.white, // header text color
//                       onSurface: Colors.black, // body text color
//                     ),
//                     textButtonTheme: TextButtonThemeData(
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.black, // buttons color
//                       ),
//                     ),
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//             if (pickedDate != null) {
//               // Format as yyyy-MM-dd for backend
//               _dateController.text =
//               "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
//             }
//           },
//         ),
//         const SizedBox(height: 12),
//
//         // TextField(
//         //   controller: _timeController,
//         //   decoration: const InputDecoration(
//         //     labelText: "Event Time",
//         //     hintText: "Select Time",
//         //     border: OutlineInputBorder(),
//         //     suffixIcon: Icon(Icons.timer, color: Colors.deepPurple),
//         //   ),
//         //   readOnly: true,
//         //   onTap: () => _showCupertinoTimePicker(context),
//         // ),
//         TextField(
//           controller: _timeController,
//           decoration: const InputDecoration(
//             labelText: "Event Time",
//             hintText: "Select Time",
//             border: OutlineInputBorder(),
//             suffixIcon: Icon(Icons.timer, color: Colors.deepPurple),
//           ),
//           readOnly: true,
//           onTap: () async {
//             TimeOfDay? pickedTime = await showTimePicker(
//               context: context,
//               initialTime: TimeOfDay.now(),
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: const ColorScheme.light(
//                       primary: Colors.deepPurple,
//                       onPrimary: Colors.white,
//                       onSurface: Colors.black,
//                     ),
//                     textButtonTheme: TextButtonThemeData(
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.black,
//                       ),
//                     ),
//                   ),
//                   child: MediaQuery(
//                     data: MediaQuery.of(context).copyWith(
//                       alwaysUse24HourFormat: false, // 👈 Force 12-hour format
//                     ),
//                     child: child!,
//                   ),
//                 );
//               },
//             );
//
//             if (pickedTime != null) {
//               final formattedTime = pickedTime.format(
//                 context,
//               ); // 12-hour with AM/PM
//               _timeController.text = formattedTime; // Example: 02:30 PM
//             }
//           },
//         ),
//         const SizedBox(height: 12),
//
//         TextField(
//           controller: _emailController,
//           decoration: const InputDecoration(
//             labelText: "Email",
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.emailAddress,
//         ),
//
//         const SizedBox(height: 12),
//         _buildDeliveryAddress(),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _peopleController,
//           decoration: const InputDecoration(
//             labelText: "No of People",
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//
//         const SizedBox(height: 12),
//         TextField(
//           controller: _vegController,
//           decoration: const InputDecoration(
//             labelText: "No of Veg plates",
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _nonvegController,
//           decoration: const InputDecoration(
//             labelText: "No of Non-Veg plates",
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _mixedController,
//           decoration: const InputDecoration(
//             labelText: "No of Mixed plates",
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _budgetController,
//           decoration: const InputDecoration(
//             labelText: "Estmated Budget",
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDeliveryAddress() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => _showAddressBottomSheet(context),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.location_on, color: Color(0xFFB15DC6)),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     selectedAddress ?? "select address",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: selectedAddress == null
//                           ? Colors.grey[500]
//                           : Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
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
//   Future<void> _showAddressBottomSheet(BuildContext context) async {
//     List<Address> savedAddresses = [];
//     bool isLoading = true;
//     String? errorMessage;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       backgroundColor: Colors.white,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             Future<void> _fetchAddresses() async {
//               try {
//                 final data =
//                 await AuthService.fetchAddresses(); // ✅ working API
//                 setModalState(() {
//                   savedAddresses = data;
//                   isLoading = false;
//                 });
//               } catch (e) {
//                 setModalState(() {
//                   isLoading = false;
//                   errorMessage = "Error: $e";
//                 });
//               }
//             }
//
//             // Trigger initial load once
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (isLoading) _fetchAddresses();
//             });
//
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.7,
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Select Delivery Address",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     if (isLoading)
//                       const Expanded(
//                         child: Center(child: CircularProgressIndicator()),
//                       )
//                     else if (errorMessage != null)
//                       Expanded(child: Center(child: Text(errorMessage!)))
//                     else if (savedAddresses.isEmpty)
//                         const Expanded(
//                           child: Center(child: Text("No saved addresses found")),
//                         )
//                       else
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: savedAddresses.length,
//                             itemBuilder: (context, index) {
//                               final address = savedAddresses[index];
//                               final displayText =
//                                   "${address.doorNumber}, ${address.addressLine}, ${address.city} - ${address.pincode}";
//
//                               return GestureDetector(
//                                 onTap: () {
//                                   Navigator.pop(context, {
//                                     "id": address.id,
//                                     "display": displayText,
//                                   });
//                                 },
//                                 child: Container(
//                                   margin: const EdgeInsets.only(bottom: 12),
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.grey.shade300,
//                                     ),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       // const Icon(
//                                       //   Icons.location_on,
//                                       //   color: Color(0xFFB15DC6),
//                                       // ),
//                                       // const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Icon(
//                                                   getCategoryIcon(
//                                                     address.category,
//                                                   ),
//                                                   size: 16.sp,
//                                                   color: Colors.blueAccent,
//                                                 ),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   displayText ?? '',
//                                                   style: const TextStyle(
//                                                     fontSize: 14,
//                                                   ),
//                                                   maxLines: 2,
//                                                   overflow: TextOverflow.ellipsis,
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(
//                         onPressed: () async {
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AddressFormScreen(),
//                             ),
//                           );
//                           // if (result != null && result is String) {
//                           //   setModalState(() {
//                           //     savedAddresses.add({
//                           //       "doorNumber": "",
//                           //       "addressLine": result,
//                           //       "city": "",
//                           //       "pincode": "",
//                           //       "category": "",
//                           //       "name": "",
//                           //       "phoneNumber": "",
//                           //     });
//                           //   });
//                           // }
//                         },
//                         icon: const Icon(
//                           Icons.add_location_alt,
//                           color: Color(0xFFB15DC6),
//                         ),
//                         label: const Text(
//                           "Add new Address",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(color: Color(0xFFB15DC6)),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           backgroundColor: Color(0xFFB15DC6),
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     ).then((selected) {
//       if (selected != null && selected is Map<String, dynamic>) {
//         setState(() {
//           selectedAddressId = selected["id"];
//           selectedAddress = selected["display"];
//         });
//         debugPrint("✅ Selected Address ID: $selectedAddressId");
//         debugPrint("✅ Selected Address: $selectedAddress");
//       }
//     });
//   }
//
//   Widget _buildCategoryItems() {
//     if (customizedCategories.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return ListView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: customizedCategories.length,
//       itemBuilder: (context, index) {
//         String category = customizedCategories[index];
//         List<Dish> allItems = (categoryItems[category] ?? []).cast<Dish>();
//
//         // Filter based on _isVeg toggle
//         List<Dish> items = allItems.where((dish) {
//           if (_isVeg) {
//             return dish.dishType.toLowerCase() == "veg";
//           } else {
//             return dish.dishType.toLowerCase() == "non-veg";
//           }
//         }).toList();
//
//         return Card(
//           color: Colors.white,
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ExpansionTile(
//             title: Text(
//               category,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             trailing: const Icon(Icons.arrow_drop_down, size: 28),
//             children: items.isNotEmpty
//                 ? items.map((dish) {
//               bool isSelected = selectedItems.contains(dish.dishId);
//               return CheckboxListTile(
//                 value: isSelected,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     if (value == true) {
//                       selectedItems.add(dish.dishId);
//                     } else {
//                       selectedItems.remove(dish.dishId);
//                     }
//                   });
//                 },
//                 title: Row(
//                   children: [
//                     VegNonVegIcon(type: dish.dishType),
//                     SizedBox(width: 10),
//                     Expanded(child: Text(dish.dishName)),
//                   ],
//                 ),
//               );
//             }).toList()
//                 : [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   _isVeg
//                       ? "No Veg items available"
//                       : "No Non-Veg items available",
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class VegNonVegIcon extends StatelessWidget {
//   final String type; // "Veg" or "Non_veg"
//   final double size;
//
//   const VegNonVegIcon({super.key, required this.type, this.size = 15});
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isVeg = type.toLowerCase() == "veg";
//
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 2),
//         shape: BoxShape.rectangle,
//       ),
//       child: Center(
//         child: Container(
//           width: size / 2,
//           height: size / 2,
//           decoration: BoxDecoration(
//             color: isVeg ? Colors.green : Colors.red,
//             shape: BoxShape.circle,
//           ),
//         ),
//       ),
//     );
//   }
// }
