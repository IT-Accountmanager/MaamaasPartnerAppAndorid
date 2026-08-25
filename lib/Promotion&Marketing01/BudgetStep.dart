import 'package:flutter/material.dart';

import 'PromotionalModel.dart';
import 'StepProgressBar.dart';


class BudgetStep extends StatefulWidget {
  final CampaignFormData formData;
  final ValueChanged<String> onInvestmentChange;
  final ValueChanged<String> onDaysChange;
  final ValueChanged<String> onCouponChange;
  final VoidCallback onApplyCoupon;
  final VoidCallback onPayNow;
  final VoidCallback onBack;
  final bool couponApplied;
  final double couponDiscount;

  const BudgetStep({
    super.key,
    required this.formData,
    required this.onInvestmentChange,
    required this.onDaysChange,
    required this.onCouponChange,
    required this.onApplyCoupon,
    required this.onPayNow,
    required this.onBack,
    this.couponApplied = false,
    this.couponDiscount = 0,
  });

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  final _investmentCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  double get investment => double.tryParse(widget.formData.investment) ?? 0;
  double get gst => investment * 0.18;
  double get totalBeforeDiscount => investment + gst;
  double get finalAmount => widget.couponApplied
      ? totalBeforeDiscount - widget.couponDiscount
      : totalBeforeDiscount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Investment
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Campaign Budget (₹)'),
              TextField(
                controller: _investmentCtrl,
                keyboardType: TextInputType.number,
                onChanged: widget.onInvestmentChange,
                decoration: InputDecoration(
                  hintText: 'Enter budget amount',
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const FormLabel('Campaign Duration (Days)'),
              TextField(
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                onChanged: widget.onDaysChange,
                decoration: InputDecoration(
                  hintText: 'e.g. 7',
                  suffixText: 'days',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Coupon Code
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Coupon Code'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponCtrl,
                      onChanged: widget.onCouponChange,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: const Color(0xFFF97316),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: const Color(0xFFF97316),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: const Color(0xFFEA580C),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: widget.onApplyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.couponApplied) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Coupon applied! Saved ₹${widget.couponDiscount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bill Summary
        if (investment > 0)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '💳 Payment Summary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _BillRow(
                  label: 'Budget',
                  value: '₹ ${investment.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _BillRow(
                  label: 'GST (18%)',
                  value: '₹ ${gst.toStringAsFixed(2)}',
                ),
                if (widget.couponApplied) ...[
                  const SizedBox(height: 8),
                  _BillRow(
                    label: 'Coupon Discount',
                    value: '- ₹ ${widget.couponDiscount.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                    labelColor: AppColors.success,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  color: Color(0xFF93C5FD),
                  thickness: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Text(
                      '₹ ${finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: finalAmount > 0 ? widget.onPayNow : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      finalAmount <= 0
                          ? 'Create Campaign'
                          : 'Pay Now ₹ ${finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        NavButtonRow(
          onBack: widget.onBack,
          nextLabel: 'Pay Now',
          nextEnabled: investment > 0,
          onNext: widget.onPayNow,
          isLastStep: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Color? labelColor;

  const _BillRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: labelColor ?? AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1E40AF),
          ),
        ),
      ],
    );
  }
}
