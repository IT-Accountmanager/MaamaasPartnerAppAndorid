import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'status_chip.dart';

/// Ports the "Lead Details" modal that appears (in slightly different
/// flavours) in AssignedLeads.jsx, PaidLeads.jsx, LeadsHistory.jsx and
/// Quotations.jsx — a bottom sheet is the natural mobile equivalent of a
/// centered desktop modal overlay.
Future<void> showLeadDetailSheet(
  BuildContext context, {
  required LeadModel lead,
  List<Widget>? footerActions,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lead Details #${lead.id}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (lead.quotationStatus != null)
                      StatusChip.status(quotationStatusBadge(lead.quotationStatus)),
                  ],
                ),
                const Divider(height: 24),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _Section(
                        title: '👤 Customer Details',
                        rows: [
                          _row('Name', lead.name),
                          _row('Phone', lead.mobile),
                          _row('Email', lead.email),
                          _row('Location', '${lead.city}, ${lead.state}'),
                        ],
                      ),
                      _Section(
                        title: '📅 Event Details',
                        rows: [
                          _row('Event Type', lead.eventType),
                          _row('Date', formatDate(lead.eventDate ?? lead.fromDate)),
                          if (lead.eventTime != null) _row('Time', formatTime(lead.eventTime)),
                          if (lead.toDate != null) _row('To Date', formatDate(lead.toDate)),
                        ],
                      ),
                      _Section(
                        title: '🍽️ Plate Details',
                        rows: [
                          _row('Veg Plates', '${lead.vegPlates}'),
                          _row('Non-Veg Plates', '${lead.nonVegPlates}'),
                          _row('Mixed Plates', '${lead.mixedPlates}'),
                          _row('Total Plates', '${lead.totalPlates}', bold: true),
                        ],
                      ),
                      if (!lead.masked)
                        _Section(
                          title: '📍 Address',
                          rows: [_row('Full Address', lead.fullAddress.isEmpty ? 'N/A' : lead.fullAddress)],
                        ),
                      if (lead.quotationData != null)
                        _Section(
                          title: '📄 Quotation Details',
                          rows: [
                            _row('Veg Plate Price', formatInr(lead.quotationData!.vegPerPlatePrice)),
                            _row('Non-Veg Plate Price', formatInr(lead.quotationData!.nonVegPerPlatePrice)),
                            if (lead.quotationData!.mixedPerPlatePrice > 0)
                              _row('Mixed Plate Price', formatInr(lead.quotationData!.mixedPerPlatePrice)),
                            if (lead.quotationData!.quotationDetails.isNotEmpty)
                              _row('Details', lead.quotationData!.quotationDetails),
                          ],
                        ),
                      if (lead.addOns.isNotEmpty)
                        _Section(
                          title: '📦 Add-Ons',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: lead.addOns
                                .map((a) => Chip(
                                      label: Text('${a.displayType} × ${a.quantity}'),
                                      backgroundColor: const Color(0xFFFEF3E8),
                                      side: const BorderSide(color: AppColors.primary),
                                      labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                if (footerActions != null && footerActions.isNotEmpty) ...[
                  const Divider(height: 24),
                  Row(
                    children: footerActions
                        .map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: w)))
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _row(String label, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget>? rows;
  final Widget? child;

  const _Section({required this.title, this.rows, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          if (rows != null) ...rows!,
          if (child != null) child!,
        ],
      ),
    );
  }
}
