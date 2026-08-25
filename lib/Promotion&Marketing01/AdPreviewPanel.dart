import 'package:flutter/material.dart';

import 'CampaignConstants.dart';
import 'PromotionalModel.dart';
import 'StepProgressBar.dart';


class AdPreviewPanel extends StatelessWidget {
  final CampaignFormData formData;

  const AdPreviewPanel({super.key, required this.formData});

  String get _displayName =>
      formData.name.isNotEmpty ? formData.name : 'Your Business';

  String _getGoalLabel() {
    return CampaignConstants.goals
        .firstWhere(
          (g) => g.value == formData.goal,
          orElse: () => const GoalOption(value: '', label: ''),
        )
        .label;
  }

  String _getSubGoalLabel() {
    final sgs = CampaignConstants.subGoals[formData.goal] ?? [];
    return sgs
            .where((s) => s.value == formData.subGoal)
            .map((s) => s.label)
            .firstOrNull ??
        '';
  }

  String _getCTALabel() {
    return CampaignConstants.callToActionOptions.firstWhere(
          (c) => c['value'] == formData.callToAction,
          orElse: () => {'label': ''},
        )['label'] ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: const Center(
            child: Text(
              'Ad Preview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // Campaign details summary
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (formData.goal.isNotEmpty)
                InfoRow(
                  label: 'Goal',
                  value: _getGoalLabel(),
                  valueColor: AppColors.primary,
                  valueBg: AppColors.primaryLight,
                ),
              if (formData.name.isNotEmpty)
                InfoRow(
                  label: 'Campaign',
                  value: _displayName,
                  valueColor: AppColors.primary,
                  valueBg: AppColors.primaryLight,
                ),
              if (formData.subGoal.isNotEmpty)
                InfoRow(
                  label: 'Sub Goal',
                  value: _getSubGoalLabel(),
                  valueColor: AppColors.green,
                  valueBg: AppColors.greenLight,
                ),
              if (formData.mediums.isNotEmpty)
                InfoRow(
                  label: 'Medium',
                  value: formData.mediums
                      .map((m) => m[0].toUpperCase() + m.substring(1))
                      .join(', '),
                  valueColor: AppColors.primary,
                  valueBg: AppColors.primaryLight,
                ),
              if (formData.mediaTypes.isNotEmpty)
                InfoRow(
                  label: 'Media Type',
                  value: formData.mediaTypes
                      .map((m) => m[0].toUpperCase() + m.substring(1))
                      .join(', '),
                  valueColor: AppColors.amber,
                  valueBg: AppColors.amberLight,
                ),
              if (formData.callToAction.isNotEmpty)
                InfoRow(
                  label: 'CTA',
                  value: _getCTALabel(),
                  valueColor: AppColors.purple,
                  valueBg: AppColors.purpleLight,
                ),
              if (formData.investment.isNotEmpty && formData.investment != '0')
                InfoRow(
                  label: 'Budget',
                  value: '₹ ${formData.investment}',
                  valueColor: AppColors.success,
                  valueBg: AppColors.greenBg,
                ),
              if (formData.goalConfig.discount.discountValue.isNotEmpty)
                InfoRow(
                  label: 'Discount',
                  value:
                      '🔥 ${formData.goalConfig.discount.discountValue}% OFF',
                  valueColor: const Color(0xFF065f46),
                  valueBg: const Color(0xFFECFDF5),
                ),
              if (formData.startDate.isNotEmpty && formData.endDate.isNotEmpty)
                InfoRow(
                  label: 'Dates',
                  value: '${formData.startDate} → ${formData.endDate}',
                  valueColor: const Color(0xFF1d4ed8),
                  valueBg: AppColors.primaryLight,
                ),
            ],
          ),
        ),

        // Social Ad Preview (Facebook style) — only when media is present
        if (formData.images.isNotEmpty || formData.videoFile != null)
          _SocialAdPreview(
            formData: formData,
            displayName: _displayName,
            ctaLabel: _getCTALabel(),
          ),

        // Empty state
        if (formData.goal.isEmpty &&
            formData.images.isEmpty &&
            formData.videoFile == null)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 24,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nothing selected yet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your selections will appear here',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SocialAdPreview extends StatefulWidget {
  final CampaignFormData formData;
  final String displayName;
  final String ctaLabel;

  const _SocialAdPreview({
    required this.formData,
    required this.displayName,
    required this.ctaLabel,
  });

  @override
  State<_SocialAdPreview> createState() => _SocialAdPreviewState();
}

class _SocialAdPreviewState extends State<_SocialAdPreview> {
  int _formatIndex = 0;
  final formats = ['Facebook', 'Instagram Feed', 'Instagram Story'];

  String get _initials {
    final name = widget.displayName;
    if (name == 'Your Business') return 'YB';
    return name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join('')
        .substring(0, name.split(' ').length > 1 ? 2 : 1)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Format tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: List.generate(
              formats.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _formatIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _formatIndex == i
                          ? AppColors.primary
                          : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formats[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _formatIndex == i
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Preview card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            decoration: BoxDecoration(
              color: _formatIndex == 2 ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Header (not story)
                if (_formatIndex != 2)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFE8523A),
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              'Sponsored · 🌐',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                // Media area
                Container(
                  height: _formatIndex == 2 ? 220 : 160,
                  color: AppColors.bgLight,
                  child: widget.formData.images.isNotEmpty
                      ? Image.network(
                          widget.formData.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.videocam_outlined,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),

                // CTA
                if (_formatIndex == 0 && widget.ctaLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.ctaLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Story CTA
                if (_formatIndex == 2 && widget.ctaLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          widget.ctaLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Engagement row (feed only)
                if (_formatIndex != 2)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _EngageBtn(
                          icon: Icons.thumb_up_outlined,
                          label: 'Like',
                        ),
                        _EngageBtn(
                          icon: Icons.chat_bubble_outline,
                          label: 'Comment',
                        ),
                        _EngageBtn(icon: Icons.share_outlined, label: 'Share'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _EngageBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EngageBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
