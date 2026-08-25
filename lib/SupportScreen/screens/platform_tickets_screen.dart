// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/support_models.dart';
// import '../models/faq_data.dart';
// import '../services/support_service.dart';
// import '../widgets/theme.dart';
//
// class PlatformTicketsScreen extends StatefulWidget {
//   const PlatformTicketsScreen({super.key});
//   @override
//   State<PlatformTicketsScreen> createState() => _PlatformTicketsScreenState();
// }
//
// class _PlatformTicketsScreenState extends State<PlatformTicketsScreen> {
//   List<PlatformTicket> _all = [];
//   bool _loading = false;
//
//   // Filters
//   final _searchCtrl = TextEditingController();
//   String _searchTerm = '';
//   String _filterPriority = '';
//   String _filterStatus = '';
//   String _filterType = '';
//   bool _filterOpen = false;
//
//   PlatformTicket? _selectedTicket;
//   bool _drawerOpen = false;
//
//   // Chat
//   final _chatCtrl = TextEditingController();
//   final List<Map<String, String>> _chatList = [];
//
//   // Create form
//   bool _createOpen = false;
//   final _subjectCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String _newPriority = '';
//   String _newType = '';
//   File? _attachment;
//   bool _submitting = false;
//
//   // Stats
//   List<Map<String, dynamic>> get _summaryCards => [
//     {'label': 'Total', 'count': _all.length, 'color': spBlue},
//     {
//       'label': 'Open',
//       'count': _all.where((t) => t.status == 'OPEN').length,
//       'color': spBlueL,
//     },
//     {
//       'label': 'In Progress',
//       'count': _all.where((t) => t.status == 'In Progress').length,
//       'color': spAmber,
//     },
//     {
//       'label': 'Escalated',
//       'count': _all.where((t) => t.status == 'Escalated').length,
//       'color': spRed,
//     },
//     {
//       'label': 'Resolved',
//       'count': _all.where((t) => t.status == 'Resolved').length,
//       'color': spGreen,
//     },
//     {
//       'label': 'Closed',
//       'count': _all.where((t) => t.status == 'Closed').length,
//       'color': spGray,
//     },
//   ];
//
//   List<PlatformTicket> get _filtered => _all.where((t) {
//     final q = _searchTerm.toLowerCase();
//     if (q.isNotEmpty &&
//         !t.ticketNumber.toLowerCase().contains(q) &&
//         !t.subject.toLowerCase().contains(q))
//       return false;
//     if (_filterPriority.isNotEmpty &&
//         t.priority.toLowerCase() != _filterPriority.toLowerCase())
//       return false;
//     if (_filterStatus.isNotEmpty &&
//         t.status.toLowerCase() != _filterStatus.toLowerCase())
//       return false;
//     if (_filterType.isNotEmpty &&
//         t.issueType.toLowerCase() != _filterType.toLowerCase())
//       return false;
//     return true;
//   }).toList();
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     _chatCtrl.dispose();
//     _subjectCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     setState(() => _loading = true);
//     final list = await SupportService.getPlatformTickets();
//     if (mounted)
//       setState(() {
//         _all = list;
//         _loading = false;
//       });
//   }
//
//   Future<void> _submit() async {
//     if (_subjectCtrl.text.trim().isEmpty ||
//         _newPriority.isEmpty ||
//         _newType.isEmpty) {
//       spSnack(context, 'Fill Subject, Priority and Type', warn: true);
//       return;
//     }
//     setState(() => _submitting = true);
//     final ticket = PlatformTicket(
//       subject: _subjectCtrl.text.trim(),
//       description: _descCtrl.text.trim(),
//       priority: _newPriority,
//       issueType: _newType,
//     );
//     final ok = await SupportService.createPlatformTicket(
//       ticket,
//       attachment: _attachment,
//     );
//     if (mounted) {
//       setState(() => _submitting = false);
//       if (ok) {
//         spSnack(context, '✅ Ticket created successfully!');
//         _subjectCtrl.clear();
//         _descCtrl.clear();
//         setState(() {
//           _newPriority = '';
//           _newType = '';
//           _attachment = null;
//           _createOpen = false;
//         });
//         _load();
//       } else {
//         spSnack(context, '❌ Failed to create ticket', error: true);
//       }
//     }
//   }
//
//   void _sendChat() {
//     final msg = _chatCtrl.text.trim();
//     if (msg.isEmpty) return;
//     setState(() {
//       _chatList.add({'text': msg, 'sender': 'user'});
//       _chatCtrl.clear();
//     });
//     Future.delayed(const Duration(milliseconds: 1200), () {
//       if (mounted)
//         setState(
//           () => _chatList.add({
//             'text':
//                 'Support: We received your message. Our team is checking this issue.',
//             'sender': 'support',
//           }),
//         );
//     });
//   }
//
//   String _fmtDate(String d) {
//     try {
//       return DateFormat('dd/MM/yyyy').format(DateTime.parse(d));
//     } catch (_) {
//       return d;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => Stack(
//     children: [
//       Column(
//         children: [
//           // Summary cards
//           SizedBox(
//             height: 90,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
//               itemCount: _summaryCards.length,
//               itemBuilder: (_, i) {
//                 final c = _summaryCards[i];
//                 return Container(
//                   width: 90,
//                   margin: const EdgeInsets.only(right: 10),
//                   decoration: spCardDeco(radius: 12),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         '${c['count']}',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w800,
//                           color: c['color'] as Color,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         c['label'] as String,
//                         style: const TextStyle(
//                           fontSize: 10,
//                           color: spText2,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Search + Filter + Create bar
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
//             child: Row(
//               children: [
//                 // Search
//                 Expanded(
//                   child: Container(
//                     height: 42,
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: spCard,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: spBorder),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.search_rounded,
//                           size: 16,
//                           color: spText3,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: TextField(
//                             controller: _searchCtrl,
//                             decoration: const InputDecoration(
//                               hintText: 'Search ticket...',
//                               hintStyle: TextStyle(
//                                 color: spText3,
//                                 fontSize: 12,
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.zero,
//                               isDense: true,
//                             ),
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: spText1,
//                             ),
//                             onChanged: (v) => setState(() => _searchTerm = v),
//                           ),
//                         ),
//                         if (_searchTerm.isNotEmpty)
//                           GestureDetector(
//                             onTap: () {
//                               _searchCtrl.clear();
//                               setState(() => _searchTerm = '');
//                             },
//                             child: const Icon(
//                               Icons.close_rounded,
//                               size: 14,
//                               color: spText3,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Filter
//                 GestureDetector(
//                   onTap: () => setState(() => _filterOpen = !_filterOpen),
//                   child: Container(
//                     height: 42,
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color:
//                           (_filterPriority.isNotEmpty ||
//                               _filterStatus.isNotEmpty ||
//                               _filterType.isNotEmpty)
//                           ? spAccent
//                           : spCard,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: spBorder),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.filter_list_rounded,
//                           size: 15,
//                           color:
//                               (_filterPriority.isNotEmpty ||
//                                   _filterStatus.isNotEmpty ||
//                                   _filterType.isNotEmpty)
//                               ? Colors.white
//                               : spText2,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Filter',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color:
//                                 (_filterPriority.isNotEmpty ||
//                                     _filterStatus.isNotEmpty ||
//                                     _filterType.isNotEmpty)
//                                 ? Colors.white
//                                 : spText2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Create
//                 GestureDetector(
//                   onTap: () => setState(() => _createOpen = true),
//                   child: Container(
//                     height: 42,
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: spAccent,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.add_rounded, size: 15, color: Colors.white),
//                         SizedBox(width: 4),
//                         Text(
//                           'Create',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
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
//           // Filter dropdown
//           if (_filterOpen)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
//               child: Container(
//                 decoration: spCardDeco(radius: 14),
//                 padding: const EdgeInsets.all(14),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Text(
//                           'Filter Tickets',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14,
//                             color: spText1,
//                           ),
//                         ),
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: () => setState(() {
//                             _filterPriority = '';
//                             _filterStatus = '';
//                             _filterType = '';
//                             _filterOpen = false;
//                           }),
//                           child: const Text(
//                             'Clear',
//                             style: TextStyle(
//                               color: spRed,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _dropdownFilter(
//                             'Priority',
//                             _filterPriority,
//                             ['', 'High', 'Medium', 'Critical'],
//                             (v) => setState(() => _filterPriority = v),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: _dropdownFilter(
//                             'Status',
//                             _filterStatus,
//                             [
//                               '',
//                               'New',
//                               'Assigned',
//                               'In Progress',
//                               'Escalated',
//                               'Resolved',
//                               'Closed',
//                             ],
//                             (v) => setState(() => _filterStatus = v),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // Ticket list
//           Expanded(
//             child: _loading
//                 ? const Center(
//                     child: CircularProgressIndicator(
//                       color: spAccent,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : _filtered.isEmpty
//                 ? _emptyState(
//                     'No tickets found',
//                     Icons.confirmation_number_outlined,
//                   )
//                 : RefreshIndicator(
//                     color: spAccent,
//                     onRefresh: _load,
//                     child: ListView.builder(
//                       padding: const EdgeInsets.fromLTRB(12, 10, 12, 32),
//                       itemCount: _filtered.length,
//                       itemBuilder: (_, i) => _ticketCard(_filtered[i], i + 1),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//
//       // Create modal
//       if (_createOpen) _buildCreateModal(),
//
//       // Ticket detail drawer
//       if (_drawerOpen && _selectedTicket != null) _buildDrawer(),
//     ],
//   );
//
//   Widget _ticketCard(PlatformTicket t, int idx) => GestureDetector(
//     onTap: () => setState(() {
//       _selectedTicket = t;
//       _chatList.clear();
//       _drawerOpen = true;
//     }),
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: spCardDeco(),
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: spAccentL,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '$idx',
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                       color: spAccent,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       t.subject,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: spText1,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       t.ticketNumber,
//                       style: const TextStyle(fontSize: 11, color: spText2),
//                     ),
//                   ],
//                 ),
//               ),
//               _statusBadge(t.status),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               _chip(t.issueType, spGrayL, spText2),
//               const SizedBox(width: 6),
//               _priorityBadge(t.priority),
//               const Spacer(),
//               Text(
//                 _fmtDate(t.createdAt),
//                 style: const TextStyle(fontSize: 10, color: spText3),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _buildCreateModal() => Positioned.fill(
//     child: GestureDetector(
//       onTap: () => setState(() => _createOpen = false),
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: GestureDetector(
//             onTap: () {},
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: spCard,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
//                     child: Row(
//                       children: [
//                         const Text(
//                           'Create Ticket',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w800,
//                             color: spText1,
//                           ),
//                         ),
//                         const Spacer(),
//                         IconButton(
//                           icon: const Icon(Icons.close_rounded, color: spText2),
//                           onPressed: () => setState(() => _createOpen = false),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(color: spBorder),
//                   // Body
//                   SingleChildScrollView(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       children: [
//                         _formField(_subjectCtrl, 'Subject *', maxLines: 1),
//                         const SizedBox(height: 12),
//                         _formField(_descCtrl, 'Description', maxLines: 3),
//                         const SizedBox(height: 12),
//                         _dropdownFormField(
//                           'Priority *',
//                           _newPriority,
//                           ['', 'High', 'Medium', 'Critical'],
//                           (v) => setState(() => _newPriority = v),
//                         ),
//                         const SizedBox(height: 12),
//                         _dropdownFormField(
//                           'Issue Type *',
//                           _newType,
//                           ['', ...ticketTypes.map((t) => t['value']!)],
//                           (v) => setState(() => _newType = v),
//                           labels: {
//                             '': 'Select Type',
//                             ...{
//                               for (final t in ticketTypes)
//                                 t['value']!: t['label']!,
//                             },
//                           },
//                         ),
//                         const SizedBox(height: 12),
//                         // Attachment
//                         GestureDetector(
//                           // onTap: () async {
//                           //   final result = await FilePicker.platform
//                           //       .pickFiles();
//                           //   if (result != null &&
//                           //       result.files.single.path != null) {
//                           //     setState(
//                           //       () => _attachment = File(
//                           //         result.files.single.path!,
//                           //       ),
//                           //     );
//                           //   }
//                           // },
//                           child: Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               color: spBg,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: spBorder,
//                                 style: BorderStyle.solid,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(
//                                   Icons.attach_file_rounded,
//                                   size: 18,
//                                   color: spText2,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _attachment != null
//                                         ? _attachment!.path.split('/').last
//                                         : 'Attach file (optional)',
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: _attachment != null
//                                           ? spText1
//                                           : spText3,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         GestureDetector(
//                           onTap: _submitting ? null : _submit,
//                           child: Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             decoration: BoxDecoration(
//                               color: spAccent,
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             child: _submitting
//                                 ? const Center(
//                                     child: SizedBox(
//                                       width: 18,
//                                       height: 18,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                   )
//                                 : const Center(
//                                     child: Text(
//                                       'Submit Ticket',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
//
//   Widget _buildDrawer() => Positioned.fill(
//     child: GestureDetector(
//       onTap: () => setState(() => _drawerOpen = false),
//       child: Container(
//         color: Colors.black38,
//         child: Align(
//           alignment: Alignment.centerRight,
//           child: GestureDetector(
//             onTap: () {},
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.88,
//               margin: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: spCard,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   // Drawer header
//                   Container(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
//                     decoration: const BoxDecoration(
//                       border: Border(bottom: BorderSide(color: spBorder)),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             _selectedTicket!.subject,
//                             style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w800,
//                               color: spText1,
//                             ),
//                             maxLines: 2,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.close_rounded,
//                             size: 20,
//                             color: spText2,
//                           ),
//                           onPressed: () => setState(() => _drawerOpen = false),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Ticket meta
//                   Padding(
//                     padding: const EdgeInsets.all(14),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: spBg,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: spBorder),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               _priorityBadge(_selectedTicket!.priority),
//                               const SizedBox(width: 8),
//                               _statusBadge(_selectedTicket!.status),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           _metaRow('ID', _selectedTicket!.ticketNumber),
//                           const SizedBox(height: 4),
//                           _metaRow('Type', _selectedTicket!.issueType),
//                           const SizedBox(height: 4),
//                           _metaRow(
//                             'Date',
//                             _fmtDate(_selectedTicket!.createdAt),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Chat
//                   const Padding(
//                     padding: EdgeInsets.fromLTRB(14, 0, 14, 8),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Live Chat',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                           color: spText1,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: spBg,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: spBorder),
//                       ),
//                       child: _chatList.isEmpty
//                           ? Center(
//                               child: Text(
//                                 'No messages yet.\nSend a message below.',
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   color: spText3,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               itemCount: _chatList.length,
//                               itemBuilder: (_, i) {
//                                 final msg = _chatList[i];
//                                 final isUser = msg['sender'] == 'user';
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 4,
//                                   ),
//                                   child: Align(
//                                     alignment: isUser
//                                         ? Alignment.centerRight
//                                         : Alignment.centerLeft,
//                                     child: Container(
//                                       constraints: BoxConstraints(
//                                         maxWidth:
//                                             MediaQuery.of(context).size.width *
//                                             0.6,
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 14,
//                                         vertical: 10,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isUser ? spBlue : Colors.white,
//                                         borderRadius: BorderRadius.circular(18),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: spShadow,
//                                             blurRadius: 4,
//                                           ),
//                                         ],
//                                       ),
//                                       child: Text(
//                                         msg['text']!,
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: isUser
//                                               ? Colors.white
//                                               : spText1,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//                   ),
//                   // Chat input
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             decoration: BoxDecoration(
//                               color: spBg,
//                               borderRadius: BorderRadius.circular(30),
//                               border: Border.all(color: spBorder),
//                             ),
//                             child: TextField(
//                               controller: _chatCtrl,
//                               decoration: const InputDecoration(
//                                 hintText: 'Type message...',
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   vertical: 12,
//                                 ),
//                                 hintStyle: TextStyle(
//                                   color: spText3,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: spText1,
//                               ),
//                               onSubmitted: (_) => _sendChat(),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         GestureDetector(
//                           onTap: _sendChat,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             decoration: BoxDecoration(
//                               color: spAccent,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: const Text(
//                               'Send',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
//
//   // Helpers
//   Widget _statusBadge(String s) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//     decoration: BoxDecoration(
//       color: spStatusColor(s).withOpacity(0.12),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: spStatusColor(s).withOpacity(0.4)),
//     ),
//     child: Text(
//       s,
//       style: TextStyle(
//         fontSize: 10,
//         fontWeight: FontWeight.w600,
//         color: spStatusColor(s),
//       ),
//     ),
//   );
//   Widget _priorityBadge(String p) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//     decoration: BoxDecoration(
//       color: spPriorityColor(p),
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Text(
//       p,
//       style: const TextStyle(
//         fontSize: 10,
//         fontWeight: FontWeight.w700,
//         color: Colors.white,
//       ),
//     ),
//   );
//   Widget _chip(String t, Color bg, Color fg) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//     decoration: BoxDecoration(
//       color: bg,
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Text(
//       t,
//       style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500),
//     ),
//   );
//   Widget _metaRow(String label, String val) => Row(
//     children: [
//       SizedBox(
//         width: 36,
//         child: Text(
//           label,
//           style: const TextStyle(fontSize: 12, color: spText2),
//         ),
//       ),
//       const Text(': ', style: TextStyle(color: spText2, fontSize: 12)),
//       Expanded(
//         child: Text(
//           val,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: spText1,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     ],
//   );
//   Widget _emptyState(String msg, IconData icon) => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(icon, size: 52, color: spText3),
//         const SizedBox(height: 12),
//         Text(msg, style: const TextStyle(color: spText2, fontSize: 14)),
//       ],
//     ),
//   );
//   Widget _formField(
//     TextEditingController ctrl,
//     String hint, {
//     int maxLines = 1,
//   }) => Container(
//     decoration: BoxDecoration(
//       color: spBg,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: spBorder),
//     ),
//     child: TextField(
//       controller: ctrl,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: spText3, fontSize: 13),
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.all(14),
//       ),
//       style: const TextStyle(fontSize: 13, color: spText1),
//     ),
//   );
//   Widget _dropdownFormField(
//     String hint,
//     String val,
//     List<String> opts,
//     ValueChanged<String> onChanged, {
//     Map<String, String>? labels,
//   }) => Container(
//     decoration: BoxDecoration(
//       color: spBg,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: spBorder),
//     ),
//     padding: const EdgeInsets.symmetric(horizontal: 14),
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton<String>(
//         value: val.isEmpty ? '' : val,
//         hint: Text(hint, style: const TextStyle(color: spText3, fontSize: 13)),
//         isExpanded: true,
//         style: const TextStyle(fontSize: 13, color: spText1),
//         items: opts
//             .map(
//               (o) => DropdownMenuItem(
//                 value: o,
//                 child: Text(labels?[o] ?? (o.isEmpty ? hint : o)),
//               ),
//             )
//             .toList(),
//         onChanged: (v) => v != null ? onChanged(v) : null,
//       ),
//     ),
//   );
//   Widget _dropdownFilter(
//     String hint,
//     String val,
//     List<String> opts,
//     ValueChanged<String> onChanged,
//   ) => Container(
//     height: 38,
//     padding: const EdgeInsets.symmetric(horizontal: 10),
//     decoration: BoxDecoration(
//       color: spBg,
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: spBorder),
//     ),
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton<String>(
//         value: val,
//         isExpanded: true,
//         style: const TextStyle(fontSize: 12, color: spText1),
//         hint: Text(hint, style: const TextStyle(fontSize: 12, color: spText3)),
//         items: opts
//             .map(
//               (o) => DropdownMenuItem(
//                 value: o,
//                 child: Text(
//                   o.isEmpty ? 'All $hint' : o,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             )
//             .toList(),
//         onChanged: (v) => v != null ? onChanged(v) : null,
//       ),
//     ),
//   );
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/support_models.dart';
import '../models/faq_data.dart';
import '../services/support_service.dart';
import '../widgets/theme.dart';

class PlatformTicketsScreen extends StatefulWidget {
  const PlatformTicketsScreen({super.key});
  @override
  State<PlatformTicketsScreen> createState() => _PlatformTicketsScreenState();
}

class _PlatformTicketsScreenState extends State<PlatformTicketsScreen> {
  List<PlatformTicket> _all = [];
  bool _loading = false;

  // Filters
  final _searchCtrl = TextEditingController();
  String _searchTerm = '';
  String _filterPriority = '';
  String _filterStatus = '';
  String _filterType = '';
  bool _filterOpen = false;

  PlatformTicket? _selectedTicket;
  bool _drawerOpen = false;

  // Chat
  final _chatCtrl = TextEditingController();
  final List<Map<String, String>> _chatList = [];

  // Create form
  bool _createOpen = false;
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _newPriority = '';
  String _newType = '';
  File? _attachment;
  bool _submitting = false;

  // Stats
  List<Map<String, dynamic>> get _summaryCards => [
    {'label': 'Total', 'count': _all.length, 'color': spBlue},
    {
      'label': 'Open',
      'count': _all.where((t) => t.status == 'OPEN').length,
      'color': spBlueL,
    },
    {
      'label': 'In Progress',
      'count': _all.where((t) => t.status == 'In Progress').length,
      'color': spAmber,
    },
    {
      'label': 'Escalated',
      'count': _all.where((t) => t.status == 'Escalated').length,
      'color': spRed,
    },
    {
      'label': 'Resolved',
      'count': _all.where((t) => t.status == 'Resolved').length,
      'color': spGreen,
    },
    {
      'label': 'Closed',
      'count': _all.where((t) => t.status == 'Closed').length,
      'color': spGray,
    },
  ];

  List<PlatformTicket> get _filtered => _all.where((t) {
    final q = _searchTerm.toLowerCase();
    if (q.isNotEmpty &&
        !t.ticketNumber.toLowerCase().contains(q) &&
        !t.subject.toLowerCase().contains(q))
      return false;
    if (_filterPriority.isNotEmpty &&
        t.priority.toLowerCase() != _filterPriority.toLowerCase())
      return false;
    if (_filterStatus.isNotEmpty &&
        t.status.toLowerCase() != _filterStatus.toLowerCase())
      return false;
    if (_filterType.isNotEmpty &&
        t.issueType.toLowerCase() != _filterType.toLowerCase())
      return false;
    return true;
  }).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _chatCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await SupportService.getPlatformTickets();
    if (mounted)
      setState(() {
        _all = list;
        _loading = false;
      });
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty ||
        _newPriority.isEmpty ||
        _newType.isEmpty) {
      spSnack(context, 'Fill Subject, Priority and Type', warn: true);
      return;
    }
    setState(() => _submitting = true);
    final ticket = PlatformTicket(
      subject: _subjectCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priority: _newPriority,
      issueType: _newType,
    );
    final ok = await SupportService.createPlatformTicket(
      ticket,
      attachment: _attachment,
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        spSnack(context, '✅ Ticket created successfully!');
        _subjectCtrl.clear();
        _descCtrl.clear();
        setState(() {
          _newPriority = '';
          _newType = '';
          _attachment = null;
          _createOpen = false;
        });
        _load();
      } else {
        spSnack(context, '❌ Failed to create ticket', error: true);
      }
    }
  }

  void _sendChat() {
    final msg = _chatCtrl.text.trim();
    if (msg.isEmpty) return;
    setState(() {
      _chatList.add({'text': msg, 'sender': 'user'});
      _chatCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted)
        setState(
          () => _chatList.add({
            'text':
                'Support: We received your message. Our team is checking this issue.',
            'sender': 'support',
          }),
        );
    });
  }

  String _fmtDate(String d) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        RefreshIndicator(
          color: spAccent,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              // Summary cards
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    itemCount: _summaryCards.length,
                    itemBuilder: (_, i) {
                      final c = _summaryCards[i];
                      return Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: spCardDeco(radius: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${c['count']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: c['color'] as Color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c['label'] as String,
                              style: const TextStyle(
                                fontSize: 10,
                                color: spText2,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Search + Filter + Create bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Row(
                    children: [
                      // Search
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: spCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: spBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                size: 16,
                                color: spText3,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Search ticket...',
                                    hintStyle: TextStyle(
                                      color: spText3,
                                      fontSize: 12,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: spText1,
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _searchTerm = v),
                                ),
                              ),
                              if (_searchTerm.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchTerm = '');
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: spText3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter
                      GestureDetector(
                        onTap: () => setState(() => _filterOpen = !_filterOpen),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color:
                                (_filterPriority.isNotEmpty ||
                                    _filterStatus.isNotEmpty ||
                                    _filterType.isNotEmpty)
                                ? spAccent
                                : spCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: spBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                size: 15,
                                color:
                                    (_filterPriority.isNotEmpty ||
                                        _filterStatus.isNotEmpty ||
                                        _filterType.isNotEmpty)
                                    ? Colors.white
                                    : spText2,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      (_filterPriority.isNotEmpty ||
                                          _filterStatus.isNotEmpty ||
                                          _filterType.isNotEmpty)
                                      ? Colors.white
                                      : spText2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Create
                      GestureDetector(
                        onTap: () => setState(() => _createOpen = true),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: spAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Create',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter dropdown
              if (_filterOpen)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Container(
                      decoration: spCardDeco(radius: 14),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Filter Tickets',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: spText1,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _filterPriority = '';
                                  _filterStatus = '';
                                  _filterType = '';
                                  _filterOpen = false;
                                }),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: spRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _dropdownFilter(
                                  'Priority',
                                  _filterPriority,
                                  ['', 'High', 'Medium', 'Critical'],
                                  (v) => setState(() => _filterPriority = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _dropdownFilter(
                                  'Status',
                                  _filterStatus,
                                  [
                                    '',
                                    'New',
                                    'Assigned',
                                    'In Progress',
                                    'Escalated',
                                    'Resolved',
                                    'Closed',
                                  ],
                                  (v) => setState(() => _filterStatus = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Ticket list
              if (_loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: spAccent,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (_filtered.isEmpty)
                SliverFillRemaining(
                  child: _emptyState(
                    'No tickets found',
                    Icons.confirmation_number_outlined,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _ticketCard(_filtered[index], index + 1),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Create modal
        if (_createOpen) _buildCreateModal(),

        // Ticket detail drawer
        if (_drawerOpen && _selectedTicket != null) _buildDrawer(),
      ],
    ),
  );

  Widget _ticketCard(PlatformTicket t, int idx) => GestureDetector(
    onTap: () => setState(() {
      _selectedTicket = t;
      _chatList.clear();
      _drawerOpen = true;
    }),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: spCardDeco(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: spAccentL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$idx',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: spAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.subject,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: spText1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      t.ticketNumber,
                      style: const TextStyle(fontSize: 11, color: spText2),
                    ),
                  ],
                ),
              ),
              _statusBadge(t.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip(t.issueType, spGrayL, spText2),
              const SizedBox(width: 6),
              _priorityBadge(t.priority),
              const Spacer(),
              Text(
                _fmtDate(t.createdAt),
                style: const TextStyle(fontSize: 10, color: spText3),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildCreateModal() => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _createOpen = false),
      child: Container(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: spCard,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Keep this
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                      child: Row(
                        children: [
                          const Text(
                            'Create Ticket',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: spText1,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: spText2,
                            ),
                            onPressed: () =>
                                setState(() => _createOpen = false),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: spBorder),

                    // Body - Use Flexible instead of Expanded
                    Flexible(
                      // ✅ Changed from Expanded to Flexible
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // ✅ Add this
                          children: [
                            _formField(_subjectCtrl, 'Subject *', maxLines: 1),
                            const SizedBox(height: 12),
                            _formField(_descCtrl, 'Description', maxLines: 3),
                            const SizedBox(height: 12),
                            _dropdownFormField(
                              'Priority *',
                              _newPriority,
                              ['', 'High', 'Medium', 'Critical'],
                              (v) => setState(() => _newPriority = v),
                            ),
                            const SizedBox(height: 12),
                            _dropdownFormField(
                              'Issue Type *',
                              _newType,
                              ['', ...ticketTypes.map((t) => t['value']!)],
                              (v) => setState(() => _newType = v),
                              labels: {
                                '': 'Select Type',
                                ...{
                                  for (final t in ticketTypes)
                                    t['value']!: t['label']!,
                                },
                              },
                            ),
                            const SizedBox(height: 12),

                            // Attachment
                            GestureDetector(
                              // onTap: _pickAttachment,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: spBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: spBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file_rounded,
                                      size: 18,
                                      color: spText2,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _attachment != null
                                            ? _attachment!.path.split('/').last
                                            : 'Attach file (optional)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _attachment != null
                                              ? spText1
                                              : spText3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_attachment != null) ...[
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () =>
                                            setState(() => _attachment = null),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: spRed,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Submit
                            GestureDetector(
                              onTap: _submitting ? null : _submit,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: spAccent,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: _submitting
                                    ? const Center(
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Text(
                                          'Submit Ticket',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            // ✅ Remove any extra SizedBox at the bottom
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildDrawer() => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _drawerOpen = false),
      child: Container(
        color: Colors.black38,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: spCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Drawer header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: spBorder)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedTicket!.subject,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: spText1,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: spText2,
                          ),
                          onPressed: () => setState(() => _drawerOpen = false),
                        ),
                      ],
                    ),
                  ),
                  // Ticket meta
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: spBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: spBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _priorityBadge(_selectedTicket!.priority),
                              const SizedBox(width: 8),
                              _statusBadge(_selectedTicket!.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _metaRow('ID', _selectedTicket!.ticketNumber),
                          const SizedBox(height: 4),
                          _metaRow('Type', _selectedTicket!.issueType),
                          const SizedBox(height: 4),
                          _metaRow(
                            'Date',
                            _fmtDate(_selectedTicket!.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chat
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Live Chat',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: spText1,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: spBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: spBorder),
                      ),
                      child: _chatList.isEmpty
                          ? Center(
                              child: Text(
                                'No messages yet.\nSend a message below.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: spText3,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _chatList.length,
                              itemBuilder: (_, i) {
                                final msg = _chatList[i];
                                final isUser = msg['sender'] == 'user';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Align(
                                    alignment: isUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.6,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUser ? spBlue : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: spShadow,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        msg['text']!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isUser
                                              ? Colors.white
                                              : spText1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  // Chat input
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: spBg,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: spBorder),
                            ),
                            child: TextField(
                              controller: _chatCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Type message...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                hintStyle: TextStyle(
                                  color: spText3,
                                  fontSize: 13,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: spText1,
                              ),
                              onSubmitted: (_) => _sendChat(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendChat,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: spAccent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Send',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  // Helpers
  Widget _statusBadge(String s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: spStatusColor(s).withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: spStatusColor(s).withOpacity(0.4)),
    ),
    child: Text(
      s,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: spStatusColor(s),
      ),
    ),
  );

  Widget _priorityBadge(String p) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: spPriorityColor(p),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      p,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );

  Widget _chip(String t, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      t,
      style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500),
    ),
  );

  Widget _metaRow(String label, String val) => Row(
    children: [
      SizedBox(
        width: 36,
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: spText2),
        ),
      ),
      const Text(': ', style: TextStyle(color: spText2, fontSize: 12)),
      Expanded(
        child: Text(
          val,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: spText1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _emptyState(String msg, IconData icon) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 52, color: spText3),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: spText2, fontSize: 14)),
      ],
    ),
  );

  Widget _formField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) => Container(
    decoration: BoxDecoration(
      color: spBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: spBorder),
    ),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: spText3, fontSize: 13),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(14),
      ),
      style: const TextStyle(fontSize: 13, color: spText1),
    ),
  );

  Widget _dropdownFormField(
    String hint,
    String val,
    List<String> opts,
    ValueChanged<String> onChanged, {
    Map<String, String>? labels,
  }) => Container(
    decoration: BoxDecoration(
      color: spBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: spBorder),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val.isNotEmpty
            ? val
            : null, // ✅ Change this line - use null instead of empty string
        hint: Text(hint, style: const TextStyle(color: spText3, fontSize: 13)),
        isExpanded: true,
        style: const TextStyle(fontSize: 13, color: spText1),
        items: opts
            .map(
              (o) => DropdownMenuItem(
                value: o.isEmpty ? null : o,
                child: Text(labels?[o] ?? (o.isEmpty ? hint : o)),
              ),
            )
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : onChanged(''),
      ),
    ),
  );

  Widget _dropdownFilter(
    String hint,
    String val,
    List<String> opts,
    ValueChanged<String> onChanged,
  ) => Container(
    height: 38,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: spBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: spBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        style: const TextStyle(fontSize: 12, color: spText1),
        hint: Text(hint, style: const TextStyle(fontSize: 12, color: spText3)),
        items: opts
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(
                  o.isEmpty ? 'All $hint' : o,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            )
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    ),
  );
}
