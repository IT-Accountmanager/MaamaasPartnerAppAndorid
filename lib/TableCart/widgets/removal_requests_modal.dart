import 'package:flutter/material.dart';
import '../models/cart_models.dart';
import '../services/cart_service.dart';

class RemovalRequestsModal extends StatelessWidget {
  final List<RemovalRequest> requests;
  final Future<void> Function(int id, String status) onUpdateStatus;

  const RemovalRequestsModal({
    Key? key,
    required this.requests,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pending = requests.where((r) => r.status == 'PENDING').length;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (ctx, scroll) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.assignment_outlined, color: Color(0xFFe66d33)),
                const SizedBox(width: 8),
                const Text(
                  'Item Requests',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (pending > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe66d33),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: requests.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 50,
                          color: Colors.green,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No pending requests',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _RequestCard(
                      request: requests[i],
                      onUpdate: onUpdateStatus,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final RemovalRequest request;
  final Future<void> Function(int id, String status) onUpdate;

  const _RequestCard({Key? key, required this.request, required this.onUpdate})
    : super(key: key);

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final isPending = req.status == 'PENDING';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  req.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              _statusBadge(req.status),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow('Quantity', '${req.quantity}'),
          _infoRow('Request Type', req.requestType),
          if (req.removalQuantity != null)
            _infoRow('Remove Qty', '${req.removalQuantity}'),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28a745),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _updating
                        ? null
                        : () async {
                            setState(() => _updating = true);
                            await widget.onUpdate(req.id, 'ACCEPT');
                            if (mounted) setState(() => _updating = false);
                          },
                    icon: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFdc3545),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _updating
                        ? null
                        : () async {
                            setState(() => _updating = true);
                            await widget.onUpdate(req.id, 'DECLINE');
                            if (mounted) setState(() => _updating = false);
                          },
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Decline',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
        color = const Color(0xFFff9800);
        break;
      case 'ACCEPT':
        color = const Color(0xFF28a745);
        break;
      default:
        color = const Color(0xFFdc3545);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── ChangeTableModal ────────────────────────────────────────────────────────
class ChangeTableModal extends StatefulWidget {
  final int vendorId;
  final CartData? cartData;
  final String authToken;
  final String currentTableCode;
  final VoidCallback onSuccess;

  const ChangeTableModal({
    Key? key,
    required this.vendorId,
    required this.cartData,
    required this.authToken,
    required this.currentTableCode,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<ChangeTableModal> createState() => _ChangeTableModalState();
}

class _ChangeTableModalState extends State<ChangeTableModal> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<TableInfo> _tables = [];
  TableInfo? _selectedTable;
  int? _newSeatingId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    final raw = await CartService.fetchAvailableTables(widget.vendorId);
    setState(() {
      _tables = raw
          .map((t) => TableInfo.fromJson(t as Map<String, dynamic>))
          .toList();
      _loading = false;
    });
  }

  Future<void> _onSelectTable(TableInfo table) async {
    setState(() => _selectedTable = table);
    try {
      final id = await CartService.createBooking(
        vendorId: widget.vendorId,
        seatingId: table.id,
        tableCode: table.code,
        capacity: table.capacity,
        tableName: table.name,
        guestName: _nameCtrl.text,
        phoneNumber: _phoneCtrl.text,
      );
      setState(() => _newSeatingId = id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedTable == null || _newSeatingId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a table')));
      return;
    }
    final cartId = widget.cartData?.cartId ?? widget.cartData?.cartId;
    if (cartId == null) return;

    setState(() => _saving = true);
    try {
      await CartService.updateCartDetails(
        cartId: cartId,
        newSeatingId: _newSeatingId!,
        customerName: _nameCtrl.text,
        phoneNumber: _phoneCtrl.text,
      );
      final oldSeating = widget.cartData?.seatingDetailsId;
      if (oldSeating != null) {
        await CartService.deleteSeatingDetail(oldSeating);
      }
      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change Table',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFfff4ee),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFf3c5a9)),
                  ),
                  child: Text(
                    'Current: ${widget.currentTableCode}',
                    style: const TextStyle(
                      color: Color(0xFFe66d33),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  const Text(
                    'Customer Name',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter customer name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Phone Number',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Table',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_tables.isEmpty)
                    const Text(
                      'No available tables',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: _tables.length,
                      itemBuilder: (ctx, i) {
                        final t = _tables[i];
                        final isSelected = _selectedTable?.id == t.id;
                        return GestureDetector(
                          onTap: () => _onSelectTable(t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFe66d33)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFe66d33)
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  t.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 12,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${t.capacity}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(
                                            0xFF28a745,
                                          ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Available',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF28a745),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedTable != null
                                ? const Color(0xFFe66d33)
                                : Colors.grey,
                            elevation: 0,
                          ),
                          onPressed: _selectedTable == null || _saving
                              ? null
                              : _submit,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Change Table',
                                  style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
