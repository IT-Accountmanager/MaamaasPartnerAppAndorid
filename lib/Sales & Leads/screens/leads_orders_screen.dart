import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/catering_models.dart';
import '../services/catering_service.dart';
import '../widgets/theme.dart';
import 'quotation_screen.dart';

// ─── Event type filters ───────────────────────────────────────────────────────
const _dailyTypes = ['CORPORATE', 'DAILY', 'WEEKLY', 'MONTHLY'];
const _eventTypes = [
  'WEDDING',
  'BIRTHDAY',
  'ENGAGEMENT',
  'ANNIVERSARY',
  'FESTIVAL',
  'OTHER',
];

class LeadsOrdersScreen extends StatefulWidget {
  const LeadsOrdersScreen({super.key});
  @override
  State<LeadsOrdersScreen> createState() => _LeadsOrdersScreenState();
}

class _LeadsOrdersScreenState extends State<LeadsOrdersScreen> {
  List<CateringLead> _all = [];
  List<CateringLead> _filtered = [];
  bool _loading = false;
  String? _filterType; // null = All, 'DAILY', 'EVENT'
  Set<int> _paymentDone = {}; // orderIds where payment succeeded

  late final Razorpay _razorpay;
  CateringLead? _payingLead;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
    _load();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ── Data Loading ─────────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() => _loading = true);
    final leads = await CateringService.fetchLeads();
    final quotations = await CateringService.fetchQuotations();

    // Map quotation status onto each lead
    final qMap = {
      for (final q in quotations) q.leadId: q.status ?? 'SUBMITTED',
    };
    for (final l in leads) l.quotationStatus = qMap[l.orderId];

    if (mounted)
      setState(() {
        _all = leads;
        _loading = false;
        _applyFilter();
      });
  }

  void _applyFilter() {
    List<CateringLead> result = _all;
    if (_filterType == 'DAILY') {
      result = _all
          .where((l) => _dailyTypes.contains(l.eventType.toUpperCase()))
          .toList();
    } else if (_filterType == 'EVENT') {
      result = _all
          .where((l) => _eventTypes.contains(l.eventType.toUpperCase()))
          .toList();
    }
    setState(() => _filtered = result);
  }

  // ── Lead Payment ──────────────────────────────────────────────────────────────
  Future<void> _startLeadPayment(CateringLead lead) async {
    _payingLead = lead;
    ctSnack(context, 'Creating payment order...', warning: true);

    final orderId = await CateringService.createLeadPaymentOrder(
      lead.leadPrice,
    );
    if (orderId == null) {
      ctSnack(context, '❌ Failed to create order', error: true);
      return;
    }

    _razorpay.open({
      'key': 'rzp_test_TJECsclCivENpY',
      'amount': (lead.leadPrice * 100).round(), // paise
      'currency': 'INR',
      'name': 'Catering Service',
      'description': 'Payment for Lead #${lead.orderId}',
      'order_id': orderId,
      'prefill': {
        'name': lead.name,
        'email': lead.email,
        'contact': lead.mobile,
      },
      'theme': {'color': '#E66D33'},
    });
  }

  void _onPaySuccess(PaymentSuccessResponse r) async {
    final lead = _payingLead;
    if (lead == null) return;

    // Step 1: Initiate in catering backend
    await CateringService.initiateLeadPayment(
      leadId: lead.orderId,
      amount: lead.leadPrice,
      orderId: lead.orderId,
    );

    // Step 2: Capture
    final captured = await CateringService.captureLeadPayment(
      paymentId: r.paymentId!,
      amount: lead.leadPrice,
    );

    if (mounted) {
      if (captured) {
        setState(() => _paymentDone.add(lead.orderId));
        ctSnack(context, '✅ Payment successful! Lead unlocked.');
        _load(); // refresh to get full details
      } else {
        ctSnack(
          context,
          '⚠️ Payment saved but capture failed. ID: ${r.paymentId}',
          warning: true,
        );
      }
    }
    _payingLead = null;
  }

  void _onPayError(PaymentFailureResponse r) {
    if (mounted)
      ctSnack(
        context,
        'Payment failed: ${r.message ?? 'Unknown error'}',
        error: true,
      );
    _payingLead = null;
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ctBg,
    appBar: AppBar(
      backgroundColor: ctCard,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ctBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ctBorder),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 15,
            color: ctText1,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),

      actions: [
        // Filter button
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _FilterDropdown(
            selected: _filterType,
            onSelect: (v) {
              setState(() => _filterType = v);
              _applyFilter();
            },
          ),
        ),
        // Create Lead button
        // Padding(
        //   padding: const EdgeInsets.only(right: 12),
        //   child: GestureDetector(
        //     onTap: () => ctSnack(
        //       context,
        //       'Create Lead — integrate with your CustomizeMenu screen',
        //     ),
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //       decoration: BoxDecoration(
        //         color: ctAccent,
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //       child: const Text(
        //         '+ Create',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontWeight: FontWeight.w700,
        //           fontSize: 12,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    ),
    body: _loading
        ? const Center(
            child: CircularProgressIndicator(color: ctAccent, strokeWidth: 2),
          )
        : _filtered.isEmpty
        ? _buildEmpty()
        : RefreshIndicator(
            color: ctAccent,
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _buildLeadCard(_filtered[i]),
            ),
          ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: ctAccentL,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.room_service_outlined,
            color: ctAccent,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _filterType != null
              ? 'No ${_filterType!.toLowerCase()} leads found'
              : 'No leads found',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ctText1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pull to refresh',
          style: TextStyle(color: ctText2, fontSize: 13),
        ),
      ],
    ),
  );

  // ─── Lead Card ────────────────────────────────────────────────────────────────
  Widget _buildLeadCard(CateringLead lead) {
    final bool paymentDone = _paymentDone.contains(lead.orderId);
    final bool canView = paymentDone || lead.hasFullAccess;
    final bool needsPay = lead.needsPayment && !paymentDone;

    return _LeadCard(
      lead: lead,
      canView: canView,
      needsPay: needsPay,
      onPay: () => _startLeadPayment(lead),
      onQuotation: () => _openQuotation(lead),
    );
  }

  void _openQuotation(CateringLead lead) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuotationScreen(lead: lead)),
    ).then((_) => _load()); // refresh after returning
  }
}

// ─── Filter Dropdown ──────────────────────────────────────────────────────────
class _FilterDropdown extends StatefulWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;
  const _FilterDropdown({required this.selected, required this.onSelect});
  @override
  State<_FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<_FilterDropdown> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.selected == 'DAILY'
        ? 'Daily'
        : widget.selected == 'EVENT'
        ? 'Event'
        : 'Filter';

    return PopupMenuButton<String?>(
      initialValue: widget.selected,
      onSelected: (v) => widget.onSelect(v),
      itemBuilder: (_) => [
        _item(null, 'Show All', widget.selected == null),
        _item('DAILY', 'Daily', widget.selected == 'DAILY'),
        _item('EVENT', 'Event', widget.selected == 'EVENT'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.selected != null ? ctAccent : ctBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.selected != null ? ctAccent : ctBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 14,
              color: widget.selected != null ? Colors.white : ctText2,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.selected != null ? Colors.white : ctText2,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: widget.selected != null ? Colors.white : ctText2,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String?> _item(String? v, String label, bool active) =>
      PopupMenuItem<String?>(
        value: v,
        child: Row(
          children: [
            Icon(
              Icons.check_rounded,
              size: 14,
              color: active ? ctAccent : Colors.transparent,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? ctAccent : ctText1,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

// ─── Individual Lead Card ─────────────────────────────────────────────────────
class _LeadCard extends StatefulWidget {
  final CateringLead lead;
  final bool canView;
  final bool needsPay;
  final VoidCallback onPay;
  final VoidCallback onQuotation;
  const _LeadCard({
    required this.lead,
    required this.canView,
    required this.needsPay,
    required this.onPay,
    required this.onQuotation,
  });
  @override
  State<_LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<_LeadCard> {
  bool _expanded = false;

  CateringLead get l => widget.lead;
  String _fmtDate(String? d) {
    if (d == null || d.isEmpty) return 'Not specified';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return 'Not specified';
    try {
      final dt = DateTime.parse('1970-01-01T$t');
      return DateFormat('hh:mm a').format(dt).toLowerCase();
    } catch (_) {
      return t;
    }
  }

  Color get _quotationColor {
    switch (l.quotationStatus?.toUpperCase()) {
      case 'SUBMITTED':
        return ctAmber;
      case 'SELECTED':
        return ctGreen;
      case 'REJECTED':
        return ctRed;
      default:
        return ctAccent;
    }
  }

  String get _quotationLabel {
    switch (l.quotationStatus?.toUpperCase()) {
      case 'SUBMITTED':
        return 'SUBMITTED';
      case 'SELECTED':
        return 'ACCEPTED';
      case 'REJECTED':
        return 'REJECTED';
      default:
        return 'Quotation';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [ctAccent, Color(0xFFD45A2A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: ctAccent.withOpacity(0.25),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lead #${l.orderId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _eventTypeBadge(l.eventType),
                  ],
                ),
              ),
              Text(
                '₹${l.leadPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              // Pay Now button
              if (widget.needsPay)
                GestureDetector(
                  onTap: widget.onPay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: ctGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Expand toggle
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),

        // ── Access blocked banner ─────────────────────────────────────────────────
        if (l.masked || (!widget.canView && l.accessMessage != null))
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.accessMessage ?? 'Pay to unlock full details',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Full details (only if accessible) ─────────────────────────────────────
        if (widget.canView)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(
                        l.isDailyType ? 'From Date' : 'Date',
                        l.isDailyType
                            ? _fmtDate(l.fromDate)
                            : _fmtDate(l.eventDate),
                      ),
                      const SizedBox(height: 4),
                      _detailRow(
                        l.isDailyType ? 'To Date' : 'Time',
                        l.isDailyType
                            ? _fmtDate(l.toDate)
                            : _fmtTime(l.eventTime),
                      ),
                      const SizedBox(height: 4),
                      _detailRow('Plates', '${l.totalPlates}'),
                      const SizedBox(height: 4),
                      _detailRow(
                        'Event',
                        l.eventType.isEmpty ? 'Booking' : l.eventType,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Name', l.name.isNotEmpty ? l.name : '—'),
                      const SizedBox(height: 4),
                      _detailRow(
                        'Mobile',
                        l.mobile.isNotEmpty ? l.mobile : '—',
                      ),
                      const SizedBox(height: 4),
                      _detailRow('Email', l.email.isNotEmpty ? l.email : '—'),
                      const SizedBox(height: 4),
                      _detailRow('Location', l.clientLocation),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ── Expandable section ────────────────────────────────────────────────────
        if (_expanded) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Plates table
                _platesTable(),
                // Menu items
                if (l.items.isNotEmpty) _itemsSection(),
                // AddOns
                if (l.addOns.isNotEmpty) _addonsSection(),
              ],
            ),
          ),
        ],

        // ── Action buttons (Download PDF + Quotation) ─────────────────────────────
        if (widget.canView)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Row(
              children: [
                // Download PDF
                Expanded(
                  child: GestureDetector(
                    onTap: () => ctSnack(
                      context,
                      'PDF download — implement with pdf package',
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: ctGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Download PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Quotation button
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onQuotation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _quotationColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _quotationLabel,
                          style: TextStyle(
                            color:
                                l.quotationStatus?.toUpperCase() == 'SUBMITTED'
                                ? ctText1
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
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

  Widget _detailRow(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 70,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const Text(': ', style: TextStyle(color: Colors.white70, fontSize: 11)),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _eventTypeBadge(String type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      type.isEmpty ? 'Booking' : type,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _platesTable() {
    final isDailyType = l.isDailyType;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plate Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _plateCell('Veg', l.vegPlates, const Color(0xFF22863A)),
              _plateCell('Non-Veg', l.nonVegPlates, const Color(0xFFD73A49)),
              if (!isDailyType)
                _plateCell('Mixed', l.mixedPlates, const Color(0xFF005CC5)),
              _plateCell('Total', l.totalPlates, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _plateCell(String label, int count, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: ctText2,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _itemsSection() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white70,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Menu Items (${l.items.length})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: l.items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFC107)),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  Widget _addonsSection() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.add_box_outlined, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              'Add-Ons (${l.addOns.length})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: l.addOns
              .map(
                (a) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F5FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF4DABF7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        a.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1864AB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        ' × ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF363636),
                        ),
                      ),
                      Text(
                        '${a.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF363636),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}
