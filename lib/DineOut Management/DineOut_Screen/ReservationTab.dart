import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DineOut_Services/DineOutAuthService.dart';
import 'DineoutHelpers.dart';
import 'ReservationCard.dart';

class ReservationTab extends StatefulWidget {
  final List<Map<String, dynamic>> reservations;
  final Function(DateTime) onFilterDateChanged;
  final Function() onRefresh;

  const ReservationTab({
    super.key,
    required this.reservations,
    required this.onFilterDateChanged,
    required this.onRefresh,
  });

  @override
  State<ReservationTab> createState() => _ReservationTabState();
}

class _ReservationTabState extends State<ReservationTab>
    with AutomaticKeepAliveClientMixin {
  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _orange = Color(0xFFE87722);
  static const Color _orangeLight = Color(0xFFFFF4EC);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFEEECEA);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF888888);
  static const Color _success = Color(0xFF4CAF50);
  static const Color _error = Color(0xFFE53935);
  static const Color _pending = Color(0xFFFFA726);

  DateTime _selectedFilterDate = DateTime.now();
  List<Map<String, dynamic>> _tables = [];
  late ScrollController _scrollController;

  double _scrollOffset = 0.0;
  bool _isHeaderVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchTables();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final newScrollOffset = _scrollController.offset;
    // Hide header when scrolled down more than 50 pixels
    final isVisible = newScrollOffset <= 50;

    if (_isHeaderVisible != isVisible) {
      setState(() {
        _isHeaderVisible = isVisible;
        _scrollOffset = newScrollOffset;
      });
    }
  }

  Future<void> _fetchTables() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      int vendorId = prefs.getInt('vendorId') ?? 0;
      if (vendorId != 0) {
        List<Map<String, dynamic>> fetchedTables =
            await DineoutAuthService.fetchTables(vendorId);
        if (mounted) {
          setState(() {
            _tables = fetchedTables;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching tables: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // ── Collapsible Header: Action bar (Book Table + Filter) ─────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isHeaderVisible ? 68 : 0,
          child: _isHeaderVisible
              ? Container(
                  color: const Color(0xFFF7F6F3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_buildBookTableButton(), _buildFilterButton()],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Scrollable Content ─────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: _orange,
            onRefresh: () async {
              widget.onRefresh();
              await _fetchTables();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildReservationsList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Book Table button ──────────────────────────────────────────────────────
  Widget _buildBookTableButton() {
    return GestureDetector(
      onTap: () => _showBookTableDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: _orange,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _orange.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
            SizedBox(width: 6),
            Text(
              'Book Table',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter button ──────────────────────────────────────────────────────────
  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: _orangeLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _orange.withOpacity(0.3)),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        onSelected: (String value) async {
          switch (value) {
            case 'today':
              await _filterByDate(DateTime.now());
              break;
            case 'tomorrow':
              await _filterByDate(DateTime.now().add(const Duration(days: 1)));
              break;
            case 'custom':
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedFilterDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: _orange,
                        onPrimary: Colors.white,
                        onSurface: _textDark,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && mounted) await _filterByDate(picked);
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt_rounded, color: _orange, size: 15),
              const SizedBox(width: 6),
              Text(
                _getFilterLabel(),
                style: TextStyle(
                  color: _orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, color: _orange, size: 16),
            ],
          ),
        ),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'today',
            child: Row(
              children: [
                Icon(Icons.today, size: 18),
                SizedBox(width: 12),
                Text('Today'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'tomorrow',
            child: Row(
              children: [
                Icon(Icons.event, size: 18),
                SizedBox(width: 12),
                Text('Tomorrow'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'custom',
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18),
                SizedBox(width: 12),
                Text('Custom Date'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter logic ─────────────────────────────────────────────────
  Future<void> _filterByDate(DateTime date) async {
    if (!mounted) return;
    setState(() => _selectedFilterDate = date);
    widget.onFilterDateChanged(date);
  }

  String _getFilterLabel() {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));
    if (_selectedFilterDate.year == now.year &&
        _selectedFilterDate.month == now.month &&
        _selectedFilterDate.day == now.day) {
      return 'Today';
    } else if (_selectedFilterDate.year == tomorrow.year &&
        _selectedFilterDate.month == tomorrow.month &&
        _selectedFilterDate.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM yyyy').format(_selectedFilterDate);
    }
  }

  // ── Reservations list ──────────────────────────────────────────────────────
  Widget _buildReservationsList() {
    if (widget.reservations.isNotEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.reservations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final res = widget.reservations[index];
          return ReservationCard(
            reservation: res,
            index: index,
            onEdit: (booking, idx) => _showEditBookingDialog(booking, idx),
            onRefresh: widget.onRefresh,
          );
        },
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _orangeLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.table_restaurant_outlined,
                  size: 30,
                  color: _orange,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No bookings for ${DateFormat('dd MMM yyyy').format(_selectedFilterDate)}',
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap "Book Table" to create a reservation',
                style: TextStyle(
                  color: _textMuted.withOpacity(0.8),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  // ── Book Table Dialog ──────────────────────────────────────────────────────
  void _showBookTableDialog() {
    final customerNameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    final timeController = TextEditingController();

    String? selectedFloor;
    String? selectedGuests;
    int? autoAssignedSeatingId;
    String? autoAssignedTableCode;
    int? autoAssignedTableCapacity;
    String? autoAssignedTableName;
    String selectedDuration = '90';
    DateTime selectedDate = DateTime.now();

    final now = DateTime.now();
    timeController.text = DateFormat('h:mm a').format(now);

    List<String> availableFloors = _tables
        .where((table) => table['status'] == 'Available')
        .map((table) => table['name']?.toString() ?? 'Unknown Floor')
        .toSet()
        .toList();

    List<String> floorOrder = [
      'Ground Floor',
      'First Floor',
      'Second Floor',
      'Third Floor',
      'Fourth Floor',
      'Fifth Floor',
      'Roof Top',
      'Terrace',
      'Basement',
    ];
    availableFloors.sort((a, b) {
      int indexA = floorOrder.indexOf(a);
      int indexB = floorOrder.indexOf(b);
      if (indexA == -1) indexA = 999;
      if (indexB == -1) indexB = 999;
      return indexA.compareTo(indexB);
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) {
          List<Map<String, dynamic>> availableTablesByFloor = [];
          if (selectedFloor != null) {
            availableTablesByFloor = _tables
                .where(
                  (table) =>
                      table['status'] == 'Available' &&
                      (table['name']?.toString() ?? 'Unknown Floor') ==
                          selectedFloor,
                )
                .toList();
          }

          List<String> guestOptions = availableTablesByFloor
              .map(
                (table) =>
                    table['capacity']?.toString() ??
                    table['seats']?.toString() ??
                    '0',
              )
              .toSet()
              .toList();
          guestOptions.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

          if (selectedGuests != null &&
              selectedGuests!.isNotEmpty &&
              selectedFloor != null) {
            int guestCount = int.parse(selectedGuests!);
            autoAssignedSeatingId = null;
            autoAssignedTableCode = null;
            autoAssignedTableCapacity = null;
            autoAssignedTableName = null;

            for (var table in availableTablesByFloor) {
              int tableCapacity = table['capacity'] ?? table['seats'] ?? 0;
              if (tableCapacity == guestCount) {
                autoAssignedSeatingId = table['id'];
                autoAssignedTableCode = table['code'];
                autoAssignedTableCapacity = tableCapacity;
                autoAssignedTableName = table['name'];
                break;
              }
            }

            if (autoAssignedSeatingId == null) {
              Map<String, dynamic>? bestTable;
              for (var table in availableTablesByFloor) {
                int tableCapacity = table['capacity'] ?? table['seats'] ?? 0;
                if (tableCapacity >= guestCount) {
                  if (bestTable == null ||
                      tableCapacity <
                          (bestTable['capacity'] ?? bestTable['seats'] ?? 0)) {
                    bestTable = table;
                  }
                }
              }
              if (bestTable != null) {
                autoAssignedSeatingId = bestTable['id'];
                autoAssignedTableCode = bestTable['code'];
                autoAssignedTableCapacity =
                    bestTable['capacity'] ?? bestTable['seats'] ?? 0;
                autoAssignedTableName = bestTable['name'];
              }
            }
          }

          return Dialog(
            backgroundColor: _white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Dialog header ──────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _orangeLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: _orange,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Book Table',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    DineoutHelpers.fieldLabel('CUSTOMER NAME'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: customerNameController,
                      hint: 'Enter customer name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('PHONE NUMBER'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: phoneController,
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('SELECT FLOOR'),
                    const SizedBox(height: 6),
                    if (availableFloors.isEmpty)
                      _warningBox(
                        _error,
                        Icons.warning_amber_rounded,
                        'No available tables found',
                      )
                    else
                      _dropdownBox(
                        child: DropdownButton<String>(
                          hint: const Text('Select floor'),
                          value: selectedFloor,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _textMuted,
                          ),
                          items: availableFloors.map((floor) {
                            int tableCount = _tables
                                .where(
                                  (table) =>
                                      table['status'] == 'Available' &&
                                      (table['name']?.toString() ??
                                              'Unknown Floor') ==
                                          floor,
                                )
                                .length;
                            return DropdownMenuItem<String>(
                              value: floor,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.home_rounded,
                                    size: 16,
                                    color: _orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$floor ($tableCount tables)',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDlgState(() {
                              selectedFloor = value;
                              selectedGuests = null;
                              autoAssignedSeatingId = null;
                            });
                          },
                        ),
                      ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('NUMBER OF GUESTS'),
                    const SizedBox(height: 6),
                    if (selectedFloor == null)
                      _infoBox(
                        _orange,
                        Icons.info_outline,
                        'Please select a floor first',
                      )
                    else if (guestOptions.isEmpty)
                      _warningBox(
                        _error,
                        Icons.warning_amber_rounded,
                        'No tables available on this floor',
                      )
                    else
                      _dropdownBox(
                        child: DropdownButton<String>(
                          hint: const Text('Select number of guests'),
                          value: selectedGuests,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _textMuted,
                          ),
                          items: guestOptions.map((guests) {
                            int tableCount = availableTablesByFloor
                                .where(
                                  (table) =>
                                      (table['capacity'] ?? table['seats'] ?? 0)
                                          .toString() ==
                                      guests,
                                )
                                .length;
                            return DropdownMenuItem<String>(
                              value: guests,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    size: 14,
                                    color: _orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$guests guests ($tableCount tables)',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setDlgState(() => selectedGuests = value),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // ── Auto-assigned table info ───────────────────────────
                    if (selectedFloor != null &&
                        selectedGuests != null &&
                        autoAssignedSeatingId != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _success),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: _success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Table Auto-Assigned',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Table $autoAssignedTableCode – $autoAssignedTableCapacity seater on $selectedFloor',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('DATE'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null && mounted)
                          setDlgState(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: _white,
                          border: Border.all(color: _border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 17,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('TIME'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: timeController,
                      hint: 'Enter time (e.g., 7:30 PM)',
                      icon: Icons.access_time_rounded,
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('DURATION'),
                    const SizedBox(height: 6),
                    _dropdownBox(
                      child: DropdownButton<String>(
                        value: selectedDuration,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _textMuted,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '30',
                            child: Text('30 minutes'),
                          ),
                          DropdownMenuItem(value: '60', child: Text('1 hour')),
                          DropdownMenuItem(
                            value: '90',
                            child: Text('1.5 hours'),
                          ),
                          DropdownMenuItem(
                            value: '120',
                            child: Text('2 hours'),
                          ),
                          DropdownMenuItem(
                            value: '180',
                            child: Text('3 hours'),
                          ),
                        ],
                        onChanged: (v) =>
                            setDlgState(() => selectedDuration = v!),
                      ),
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('NOTES (OPTIONAL)'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: notesController,
                      hint: 'Any special requests or notes',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: DineoutHelpers.cancelButton(
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DineoutHelpers.primaryButton(
                            label: 'Book Table',
                            onTap: () async {
                              final name = customerNameController.text.trim();
                              final phone = phoneController.text.trim();
                              final time = timeController.text.trim();

                              if (name.isEmpty) {
                                if (mounted)
                                  _showSnack('Please enter customer name');
                                return;
                              }
                              if (phone.isEmpty) {
                                if (mounted)
                                  _showSnack('Please enter phone number');
                                return;
                              }
                              if (selectedFloor == null) {
                                if (mounted)
                                  _showSnack('Please select a floor');
                                return;
                              }
                              if (selectedGuests == null) {
                                if (mounted)
                                  _showSnack('Please select number of guests');
                                return;
                              }
                              if (autoAssignedSeatingId == null) {
                                if (mounted) {
                                  _showSnack(
                                    'No table available for $selectedGuests guests on $selectedFloor',
                                  );
                                }
                                return;
                              }
                              if (time.isEmpty) {
                                if (mounted) _showSnack('Please enter time');
                                return;
                              }

                              String formattedTime =
                                  DineoutHelpers.convertTo24HourFormat(time);
                              int durationMinutes = int.parse(selectedDuration);
                              String formattedDate = DateFormat(
                                'yyyy-MM-dd',
                              ).format(selectedDate);

                              final prefs =
                                  await SharedPreferences.getInstance();
                              int vendorId = prefs.getInt('vendorId') ?? 0;
                              if (vendorId == 0) {
                                if (mounted) _showSnack('Vendor ID not found');
                                return;
                              }

                              Map<String, dynamic> seatingObject = {
                                "id": autoAssignedSeatingId,
                                "name": selectedFloor,
                                "seatingStatus": "Reserved",
                                "code": autoAssignedTableCode,
                                "capacity": autoAssignedTableCapacity,
                                "description": null,
                                "remarks": null,
                                "cleanTime": "00:30:00",
                                "manuallyUpdated": true,
                              };

                              if (mounted) Navigator.pop(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Creating booking...'),
                                  ),
                                );
                              }

                              bool success =
                                  await DineoutAuthService.createReservation(
                                    vendorId: vendorId,
                                    guestName: name,
                                    phoneNumber: phone,
                                    capacity: int.parse(selectedGuests!),
                                    bookingDate: formattedDate,
                                    startTime: formattedTime,
                                    durationMinutes: durationMinutes,
                                    seatingId: autoAssignedSeatingId!,
                                    types: "BOOK_NOW",
                                    seating: seatingObject,
                                  );

                              if (success && mounted) {
                                _showSnack(
                                  '✅ Booking created successfully for $name on $selectedFloor',
                                );
                                widget.onRefresh();
                                _fetchTables();
                              } else if (mounted) {
                                _showSnack('❌ Failed to create booking');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Edit Booking Dialog ────────────────────────────────────────────────────
  void _showEditBookingDialog(Map<String, dynamic> booking, int index) {
    final nameController = TextEditingController(text: booking['name']);
    final phoneController = TextEditingController(text: booking['phone']);
    final guestsController = TextEditingController(
      text: booking['guests'].toString(),
    );
    final timeController = TextEditingController(text: booking['time']);

    DateTime selectedDate;
    try {
      selectedDate = DateTime.parse(booking['date']);
    } catch (e) {
      try {
        selectedDate = DateFormat('dd/MM/yyyy').parse(booking['date']);
      } catch (e) {
        selectedDate = DateTime.now();
      }
    }

    String selectedDuration = '90';
    String rawDuration = booking['duration'] ?? '90';
    if (rawDuration.contains('30') || rawDuration == '30 minutes')
      selectedDuration = '30';
    else if (rawDuration.contains('1 hour') || rawDuration == '60')
      selectedDuration = '60';
    else if (rawDuration.contains('1.5') ||
        rawDuration == '90' ||
        rawDuration == '1.5 hours')
      selectedDuration = '90';
    else if (rawDuration.contains('2') ||
        rawDuration == '120' ||
        rawDuration == '2 hours')
      selectedDuration = '120';
    else if (rawDuration.contains('3') ||
        rawDuration == '180' ||
        rawDuration == '3 hours')
      selectedDuration = '180';

    int bookingId = booking['id'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) {
          return Dialog(
            backgroundColor: _white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Dialog header ──────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _orangeLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: _orange,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Edit Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Currently assigned table info ──────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _success),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.table_restaurant_rounded,
                            color: _success,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Currently Assigned Table',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${booking['code'] ?? booking['table'] ?? 'N/A'} – ${booking['capacity'] ?? booking['guests'] ?? 0} seats',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    DineoutHelpers.fieldLabel('CUSTOMER NAME'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: nameController,
                      hint: 'Enter customer name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('PHONE NUMBER'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: phoneController,
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('NUMBER OF GUESTS'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: guestsController,
                      hint: 'Enter number of guests',
                      icon: Icons.group_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('DATE'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null && mounted)
                          setDlgState(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: _white,
                          border: Border.all(color: _border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 17,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('TIME'),
                    const SizedBox(height: 6),
                    DineoutHelpers.inputField(
                      controller: timeController,
                      hint: 'Enter time (e.g., 7:30 PM)',
                      icon: Icons.access_time_rounded,
                    ),
                    const SizedBox(height: 14),

                    DineoutHelpers.fieldLabel('DURATION'),
                    const SizedBox(height: 6),
                    _dropdownBox(
                      child: DropdownButton<String>(
                        value: selectedDuration,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _textMuted,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '30',
                            child: Text('30 minutes'),
                          ),
                          DropdownMenuItem(value: '60', child: Text('1 hour')),
                          DropdownMenuItem(
                            value: '90',
                            child: Text('1.5 hours'),
                          ),
                          DropdownMenuItem(
                            value: '120',
                            child: Text('2 hours'),
                          ),
                          DropdownMenuItem(
                            value: '180',
                            child: Text('3 hours'),
                          ),
                        ],
                        onChanged: (v) =>
                            setDlgState(() => selectedDuration = v!),
                      ),
                    ),
                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: DineoutHelpers.cancelButton(
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DineoutHelpers.primaryButton(
                            label: 'Update Booking',
                            onTap: () async {
                              final name = nameController.text.trim();
                              final phone = phoneController.text.trim();
                              final guestsStr = guestsController.text.trim();
                              final time = timeController.text.trim();

                              if (name.isEmpty) {
                                if (mounted)
                                  _showSnack('Please enter customer name');
                                return;
                              }
                              if (phone.isEmpty) {
                                if (mounted)
                                  _showSnack('Please enter phone number');
                                return;
                              }
                              if (guestsStr.isEmpty) {
                                if (mounted)
                                  _showSnack('Please enter number of guests');
                                return;
                              }
                              if (time.isEmpty) {
                                if (mounted) _showSnack('Please enter time');
                                return;
                              }

                              final guests = int.tryParse(guestsStr) ?? 0;
                              if (guests <= 0) {
                                if (mounted) {
                                  _showSnack(
                                    'Please enter valid number of guests',
                                  );
                                }
                                return;
                              }

                              String formattedTime =
                                  DineoutHelpers.convertTo24HourFormat(time);
                              int durationMinutes = int.parse(selectedDuration);
                              String formattedDate = DateFormat(
                                'yyyy-MM-dd',
                              ).format(selectedDate);

                              final prefs =
                                  await SharedPreferences.getInstance();
                              int vendorId = prefs.getInt('vendorId') ?? 0;
                              if (vendorId == 0) {
                                if (mounted) _showSnack('Vendor ID not found');
                                return;
                              }
                              if (bookingId == 0) {
                                if (mounted) _showSnack('Booking ID not found');
                                return;
                              }

                              if (mounted) Navigator.pop(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Updating booking...'),
                                  ),
                                );
                              }

                              bool success =
                                  await DineoutAuthService.updateReservation(
                                    vendorId: vendorId,
                                    bookingId: bookingId,
                                    guestName: name,
                                    phoneNumber: phone,
                                    capacity: guests,
                                    bookingDate: formattedDate,
                                    startTime: formattedTime,
                                    durationMinutes: durationMinutes,
                                  );

                              if (success && mounted) {
                                _showSnack('✅ Booking updated successfully');
                                widget.onRefresh();
                                _fetchTables();
                              } else if (mounted) {
                                _showSnack('❌ Failed to update booking');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Shared dialog helper widgets ───────────────────────────────────────────
  Widget _dropdownBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _warningBox(Color color, IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _infoBox(Color color, IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
