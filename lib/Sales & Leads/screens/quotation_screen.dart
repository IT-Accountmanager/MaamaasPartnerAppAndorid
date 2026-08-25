import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/catering_models.dart';
import '../services/catering_service.dart';
import '../widgets/theme.dart';

class QuotationScreen extends StatefulWidget {
  final CateringLead lead;
  const QuotationScreen({super.key, required this.lead});
  @override State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  CateringLead get l => widget.lead;

  // Form state
  final _vegCtrl    = TextEditingController();
  final _nonVegCtrl = TextEditingController();
  final _mixedCtrl  = TextEditingController();
  final _notesCtrl  = TextEditingController();
  final Map<int, TextEditingController> _addonCtrls = {};

  bool _loading    = true;
  bool _sending    = false;
  bool _hasExisting = false;
  bool _showConfirmDialog = false;

  @override
  void initState() {
    super.initState();
    // Init addon controllers
    for (final a in l.addOns) _addonCtrls[a.id] = TextEditingController();
    _fetchExisting();
  }

  @override
  void dispose() {
    _vegCtrl.dispose(); _nonVegCtrl.dispose(); _mixedCtrl.dispose(); _notesCtrl.dispose();
    for (final c in _addonCtrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _fetchExisting() async {
    final quotations = await CateringService.fetchQuotations();
    final existing = quotations.where((q) => q.leadId == l.orderId).firstOrNull;
    if (existing != null && mounted) {
      _vegCtrl.text    = existing.vegPerPlatePrice > 0 ? existing.vegPerPlatePrice.toStringAsFixed(0) : '';
      _nonVegCtrl.text = existing.nonVegPerPlatePrice > 0 ? existing.nonVegPerPlatePrice.toStringAsFixed(0) : '';
      _mixedCtrl.text  = existing.mixedPerPlatePrice > 0 ? existing.mixedPerPlatePrice.toStringAsFixed(0) : '';
      _notesCtrl.text  = existing.quotationDetails;
      for (final ap in existing.addOnPrices) {
        _addonCtrls[ap.addOnId]?.text = ap.price > 0 ? ap.price.toStringAsFixed(0) : '';
      }
      setState(() { _hasExisting = true; _loading = false; });
    } else {
      setState(() => _loading = false);
    }
  }

  double get _vegPrice => double.tryParse(_vegCtrl.text) ?? 0;
  double get _nonVegPrice => double.tryParse(_nonVegCtrl.text) ?? 0;
  double get _mixedPrice => double.tryParse(_mixedCtrl.text) ?? 0;

  bool get _canSend {
    if (_hasExisting) return false;
    if (l.isDailyType) return _vegPrice > 0 && _nonVegPrice > 0;
    return _vegPrice > 0 && _nonVegPrice > 0 && _mixedPrice > 0;
  }
  Future<void> _send() async {
    setState(() { _sending = true; _showConfirmDialog = false; });
    final addonPrices = l.addOns.map((a) {
      final price = double.tryParse(_addonCtrls[a.id]?.text ?? '') ?? 0;
      return AddOnPrice(addOnId: a.id, price: price);
    }).where((ap) => ap.price > 0).toList();

    final quotation = Quotation(
      leadId:              l.orderId,
      vegPerPlatePrice:    _vegPrice,
      nonVegPerPlatePrice: _nonVegPrice,
      mixedPerPlatePrice:  l.isDailyType ? 0 : _mixedPrice,
      quotationDetails:    _notesCtrl.text,
      addOnPrices:         addonPrices,
    );

    final ok = await CateringService.sendQuotation(leadId: l.orderId, quotation: quotation);
    if (mounted) {
      setState(() => _sending = false);
      if (ok) {
        ctSnack(context, '✅ Quotation sent successfully!');
        setState(() => _hasExisting = true);
        Future.delayed(const Duration(milliseconds: 500), () => Navigator.pop(context));
      } else {
        ctSnack(context, '❌ Failed to send quotation', error: true);
      }
    }
  }

  String _fmtDate(String? d) {
    if (d == null || d.isEmpty) return 'Not specified';
    try { return DateFormat('dd/MM/yyyy').format(DateTime.parse(d)); } catch (_) { return d; }
  }
  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return 'Not specified';
    try { return DateFormat('hh:mm a').format(DateTime.parse('1970-01-01T$t')).toLowerCase(); } catch (_) { return t; }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ctBg,
    appBar: AppBar(
      backgroundColor: ctCard,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: ctBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: ctBorder)),
          child: const Icon(Icons.arrow_back_ios_rounded, size: 15, color: ctText1),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Quotation — Lead #${l.orderId}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ctText1)),
        Text(_hasExisting ? 'Already sent' : 'Create new quotation', style: TextStyle(fontSize: 11, color: _hasExisting ? ctGreen : ctText2)),
      ]),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: ctAccent))
        : Stack(children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Already sent banner ─────────────────────────────────────────
                if (_hasExisting)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: ctGreenL, borderRadius: BorderRadius.circular(10), border: Border.all(color: ctGreen.withOpacity(0.4))),
                    child: const Row(children: [
                      Icon(Icons.check_circle_outline_rounded, color: ctGreen, size: 18),
                      SizedBox(width: 10),
                      Expanded(child: Text('Quotation already sent. You cannot modify it.', style: TextStyle(color: ctGreen, fontWeight: FontWeight.w600, fontSize: 13))),
                    ]),
                  ),

                // ── Customer summary ────────────────────────────────────────────
                _sectionHeader('Customer Details'),
                Container(
                  decoration: ctCardDeco(),
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    Row(children: [
                      Expanded(child: _infoCell('Customer', l.name.isNotEmpty ? l.name : '—')),
                      Expanded(child: _infoCell('Phone', l.mobile.isNotEmpty ? l.mobile : '—')),
                    ]),
                    const Divider(color: ctBorder, height: 20),
                    if (l.isDailyType)
                      Row(children: [
                        Expanded(child: _infoCell('From Date', _fmtDate(l.fromDate))),
                        Expanded(child: _infoCell('To Date',   _fmtDate(l.toDate))),
                      ])
                    else
                      Row(children: [
                        Expanded(child: _infoCell('Event Date', _fmtDate(l.eventDate))),
                        if (l.eventTime != null)
                          Expanded(child: _infoCell('Event Time', _fmtTime(l.eventTime))),
                      ]),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Plate pricing ───────────────────────────────────────────────
                _sectionHeader('Plate Pricing'),
                Container(
                  decoration: ctCardDeco(),
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    _priceField(_vegCtrl,    '🌿 Veg Plate Price / plate',       l.vegPlates,    ctGreen),
                    const SizedBox(height: 12),
                    _priceField(_nonVegCtrl, '🍗 Non-Veg Plate Price / plate',   l.nonVegPlates, ctRed),
                    if (!l.isDailyType) ...[
                      const SizedBox(height: 12),
                      _priceField(_mixedCtrl, '🥗 Mixed Plate Price / plate',   l.mixedPlates,  ctBlue),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Addon pricing ───────────────────────────────────────────────
                if (l.addOns.isNotEmpty) ...[
                  _sectionHeader('Add-On TableServices Pricing'),
                  Container(
                    decoration: ctCardDeco(),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: l.addOns.asMap().entries.map((e) {
                        final i = e.key; final a = e.value;
                        return Column(children: [
                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(a.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: ctText1)),
                              Text('Qty: ${a.quantity}', style: const TextStyle(fontSize: 11, color: ctText2)),
                            ])),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 130,
                              child: _addonPriceField(_addonCtrls[a.id]!),
                            ),
                          ]),
                          if (i < l.addOns.length - 1) const Divider(color: ctBorder, height: 20),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Notes ───────────────────────────────────────────────────────
                _sectionHeader('Quotation Notes (Optional)'),
                Container(
                  decoration: ctCardDeco(),
                  child: TextField(
                    controller: _notesCtrl,
                    enabled: !_hasExisting,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add terms, special notes, or any details...',
                      hintStyle: const TextStyle(color: ctText3, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      filled: _hasExisting,
                      fillColor: _hasExisting ? ctBg : null,
                    ),
                    style: const TextStyle(fontSize: 13, color: ctText1),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Validation checklist ────────────────────────────────────────
                if (!_hasExisting)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: ctAmberL, borderRadius: BorderRadius.circular(10), border: Border.all(color: ctAmber.withOpacity(0.4))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Required before sending:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF856404))),
                      const SizedBox(height: 8),
                      _checkRow('Veg Plate Price',     _vegPrice > 0),
                      _checkRow('Non-Veg Plate Price', _nonVegPrice > 0),
                      if (!l.isDailyType) _checkRow('Mixed Plate Price', _mixedPrice > 0),
                    ]),
                  ),
              ]),
            ),

            // ── Sticky bottom button ────────────────────────────────────────────
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                decoration: const BoxDecoration(
                  color: ctCard,
                  border: Border(top: BorderSide(color: ctBorder)),
                ),
                child: GestureDetector(
                  onTap: _canSend && !_sending ? () => setState(() => _showConfirmDialog = true) : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _hasExisting ? ctPurple : _canSend ? ctBlue : ctBorder,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _sending
                        ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                        : Center(child: Text(
                            _hasExisting ? 'Quotation Already Sent' : _canSend ? 'Send Quotation' : 'Fill required prices',
                            style: TextStyle(color: _canSend && !_hasExisting ? Colors.white : const Color(0xFF6B7280), fontWeight: FontWeight.w800, fontSize: 15),
                          )),
                  ),
                ),
              ),
            ),

            // ── Confirm dialog overlay ──────────────────────────────────────────
            if (_showConfirmDialog) _buildConfirmOverlay(),
          ]),
  );

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: ctAccent, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ctText1)),
    ]),
  );

  Widget _infoCell(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, color: ctText2)),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ctText1), maxLines: 1, overflow: TextOverflow.ellipsis),
  ]);

  Widget _priceField(TextEditingController ctrl, String label, int plates, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ctText1)),
    const SizedBox(height: 4),
    Text('$plates plates', style: const TextStyle(fontSize: 11, color: ctText2)),
    const SizedBox(height: 6),
    Container(
      decoration: BoxDecoration(
        color: _hasExisting ? ctBg : ctCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _hasExisting ? ctBorder : color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 46,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: const BorderRadius.only(topLeft: Radius.circular(9), bottomLeft: Radius.circular(9))),
          child: Center(child: Text('₹', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color))),
        ),
        Expanded(child: TextField(
          controller: ctrl,
          enabled: !_hasExisting,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Price per plate',
            hintStyle: TextStyle(color: ctText3, fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          ),
          style: const TextStyle(fontSize: 14, color: ctText1, fontWeight: FontWeight.w600),
          onChanged: (_) => setState(() {}),
        )),
      ]),
    ),
  ]);

  Widget _addonPriceField(TextEditingController ctrl) => Container(
    decoration: BoxDecoration(
      color: _hasExisting ? ctBg : ctCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: ctBorder),
    ),
    child: Row(children: [
      Container(
        width: 32, height: 40,
        decoration: const BoxDecoration(color: ctAmberL, borderRadius: BorderRadius.only(topLeft: Radius.circular(9), bottomLeft: Radius.circular(9))),
        child: const Center(child: Text('₹', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ctAmber))),
      ),
      Expanded(child: TextField(
        controller: ctrl,
        enabled: !_hasExisting,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'Price/unit', hintStyle: TextStyle(color: ctText3, fontSize: 12), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
        style: const TextStyle(fontSize: 13, color: ctText1),
      )),
    ]),
  );

  Widget _checkRow(String label, bool done) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Container(
        width: 18, height: 18,
        decoration: BoxDecoration(
          color: done ? ctGreen : ctRed,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(child: Text(done ? '✓' : '!', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF856404))),
    ]),
  );

  Widget _buildConfirmOverlay() => Positioned.fill(
    child: Container(
      color: Colors.black54,
      child: Center(child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: ctCard, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 52, height: 52, decoration: const BoxDecoration(color: ctAmberL, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: ctAmber, size: 26)),
          const SizedBox(height: 14),
          const Text('Confirm Quotation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ctText1)),
          const SizedBox(height: 8),
          const Text('Once sent, you cannot change the quoted prices.', style: TextStyle(color: ctText2, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _showConfirmDialog = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: ctBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: ctBorder)),
                child: const Center(child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: ctText2))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: _send,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: ctGreen, borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('Send', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
              ),
            )),
          ]),
        ]),
      )),
    ),
  );
}
