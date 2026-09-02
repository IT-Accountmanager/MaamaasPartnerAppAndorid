import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'status_chip.dart';

/// Mobile-friendly replacement for the desktop `<table>` rows used in
/// every leads screen. Each screen passes in whatever trailing widget
/// (action buttons / status chip) it needs.
class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback? onTap;
  final Widget? trailing;
  final List<Widget>? actions;
  final bool showPlates;
  final bool showPrice;

  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.trailing,
    this.actions,
    this.showPlates = true,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${lead.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lead.masked ? 'Masked lead' : lead.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusChip.solid(label: lead.eventType, color: eventTypeColor(lead.eventType)),
                ],
              ),
              const SizedBox(height: 6),
              if (!lead.masked)
                Text(
                  lead.mobile,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.event, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(lead.eventDate ?? lead.fromDate),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSubtle),
                  ),
                  if (showPlates) ...[
                    const SizedBox(width: 14),
                    const Icon(Icons.restaurant, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${lead.totalPlates} plates',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSubtle),
                    ),
                  ],
                ],
              ),
              if (showPrice) ...[
                const SizedBox(height: 8),
                Text(
                  formatInr(lead.leadPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(height: 8),
                trailing!,
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((a) => Padding(padding: const EdgeInsets.only(left: 8), child: a))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
