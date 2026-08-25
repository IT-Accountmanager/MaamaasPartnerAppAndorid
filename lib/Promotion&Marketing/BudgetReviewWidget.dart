import 'dart:io';

import 'package:flutter/material.dart';

import 'Models.dart';
import 'Services.dart';


class BudgetReviewWidget extends StatefulWidget {
  final CampaignData formData;
  final Function(String, dynamic) onInputChange;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool Function() isStepValid;
  final List<MenuItem> menuItems;
  final ApiService apiService;

  const BudgetReviewWidget({
    Key? key,
    required this.formData,
    required this.onInputChange,
    required this.onNext,
    required this.onBack,
    required this.isStepValid,
    required this.menuItems,
    required this.apiService,
  }) : super(key: key);

  @override
  State<BudgetReviewWidget> createState() => _BudgetReviewWidgetState();
}

class _BudgetReviewWidgetState extends State<BudgetReviewWidget> {
  bool _isProcessing = false;
  double _couponDiscount = 0;
  bool _couponApplied = false;
  Map<String, dynamic>? _billingData;

  @override
  void initState() {
    super.initState();
    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    try {
      final data = await widget.apiService.fetchBilling();
      setState(() {
        _billingData = data;
      });
    } catch (e) {
      debugPrint('Failed to load billing: $e');
    }
  }

  Future<void> _applyCoupon() async {
    if (widget.formData.couponCode == null ||
        widget.formData.couponCode!.isEmpty) {
      _showSnackBar('Please enter a coupon code');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final customerId = widget.apiService.getCustomerId();
      if (customerId == null) throw Exception('Customer ID missing');

      final investment =
          double.tryParse(widget.formData.investment ?? '0') ?? 0;

      final response = await widget.apiService.applyCoupon(
        customerId: customerId,
        couponCode: widget.formData.couponCode!,
        amount: investment,
      );

      final discount =
          (response['discountAmount'] ??
                  response['data']?['discountAmount'] ??
                  0)
              .toDouble();

      setState(() {
        _couponDiscount = discount;
        _couponApplied = true;
      });

      _showSnackBar('Coupon applied successfully');
    } catch (e) {
      _showSnackBar('Invalid coupon: $e');
      setState(() {
        _couponDiscount = 0;
        _couponApplied = false;
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  double _calculateTotal() {
    final investment = double.tryParse(widget.formData.investment ?? '0') ?? 0;
    final gst = investment * 0.18;
    final total = investment + gst;
    return _couponApplied ? total - _couponDiscount : total;
  }

  @override
  Widget build(BuildContext context) {
    final investment = double.tryParse(widget.formData.investment ?? '0') ?? 0;
    final gst = investment * 0.18;
    final total = investment + gst;
    final finalTotal = _couponApplied ? total - _couponDiscount : total;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget & Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Investment
            _buildTextField(
              'Investment (₹)',
              'investment',
              hint: 'Enter your budget',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Days or Reach
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Days',
                    'days',
                    hint: 'Number of days',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Reach',
                    'reach',
                    hint: 'Target reach',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Start and End Dates
            Row(
              children: [
                Expanded(child: _buildDateField('Start Date', 'startDate')),
                const SizedBox(width: 16),
                Expanded(child: _buildDateField('End Date', 'endDate')),
              ],
            ),

            const SizedBox(height: 24),

            // Coupon Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coupon Code',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) =>
                              widget.onInputChange('couponCode', value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _applyCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Budget',
                    '₹${investment.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('GST (18%)', '₹${gst.toStringAsFixed(2)}'),
                  if (_couponApplied) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Coupon Discount',
                      '-₹${_couponDiscount.toStringAsFixed(2)}',
                      valueColor: Colors.green,
                    ),
                  ],
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Grand Total',
                    '₹${finalTotal.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.isStepValid()) {
                        // Proceed to payment or create campaign
                        if (finalTotal <= 0) {
                          // Create campaign directly
                          _createCampaign(transactionId: 'FREE_CAMPAIGN');
                        } else {
                          // Show payment dialog
                          _showPaymentDialog(finalTotal);
                        }
                      } else {
                        _showSnackBar('Please fill all required fields');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185FA5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      finalTotal <= 0
                          ? 'Create Campaign'
                          : 'Pay ₹${finalTotal.toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String field, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          onChanged: (value) => widget.onInputChange(field, value),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              widget.onInputChange(
                field,
                date.toIso8601String().split('T').first,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.formData.startDate == field
                      ? (field == 'startDate'
                            ? widget.formData.startDate ?? 'Select date'
                            : widget.formData.endDate ?? 'Select date')
                      : 'Select date',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? (isTotal ? const Color(0xFF185FA5) : null),
          ),
        ),
      ],
    );
  }

  Future<void> _showPaymentDialog(double amount) async {
    // Implement payment dialog using Razorpay or other payment gateway
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment'),
        content: Text('Pay ₹${amount.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Proceed with payment processing
              _createCampaign(
                transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
              );
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCampaign({required String transactionId}) async {
    setState(() => _isProcessing = true);

    try {
      final payload = _buildCampaignPayload(transactionId);
      final mediaFile = _getMediaFile();

      final response = await widget.apiService.createCampaign(
        payload,
        mediaFile,
      );

      if (mounted) {
        _showSnackBar('Campaign created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Failed to create campaign: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Map<String, dynamic> _buildCampaignPayload(String transactionId) {
    final customerId = widget.apiService.getCustomerId();
    final vendorId = widget.apiService.getVendorId();

    final investment = double.tryParse(widget.formData.investment ?? '0') ?? 0;
    final gst = investment * 0.18;

    return {
      'campaignName': widget.formData.name ?? '',
      'goal': widget.formData.goal?.toUpperCase() ?? 'BRANDING',
      'subGoal': (widget.formData.subGoal ?? '').toUpperCase(),
      'medium': widget.formData.mediums.isNotEmpty
          ? widget.formData.mediums.first.toUpperCase()
          : 'APP',
      'mediaType': widget.formData.videoFile != null ? 'VIDEO' : 'IMAGE',
      'customerId': customerId,
      'totalBudget': investment + gst,
      'gst': gst,
      'startDate':
          widget.formData.startDate ?? DateTime.now().toIso8601String(),
      'endDate': widget.formData.endDate ?? DateTime.now().toIso8601String(),
      'transactionId': transactionId,
      'paymentMethod': 'Online_Payment',
      'totalDays': int.tryParse(widget.formData.days ?? '1') ?? 1,
      'targetAudience': widget.formData.audience,
      'callToAction': widget.formData.callToAction?.toUpperCase(),
      'vendorId': vendorId != null ? int.parse(vendorId) : null,
    };
  }

  File? _getMediaFile() {
    if (widget.formData.videoFile != null) {
      return File(widget.formData.videoFile!);
    } else if (widget.formData.images.isNotEmpty) {
      return File(widget.formData.images.first);
    }
    return null;
  }
}
