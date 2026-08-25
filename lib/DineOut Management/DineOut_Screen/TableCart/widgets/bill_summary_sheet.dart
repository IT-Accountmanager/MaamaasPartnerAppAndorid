import 'package:flutter/material.dart';

class BillSummarySheet extends StatelessWidget {
  final double subtotal;
  final double gst;
  final double serviceCharge;
  final double packingCharges;
  final double platformFee;
  final double deliveryCharge;
  final double discountAmount;
  final bool isDiscountApplied;
  final TextEditingController discountCtrl;
  final double total;
  final double grandTotal;
  final VoidCallback onApplyDiscount;
  final VoidCallback onRemoveDiscount;

  const BillSummarySheet({
    Key? key,
    required this.subtotal,
    required this.gst,
    required this.serviceCharge,
    required this.packingCharges,
    required this.platformFee,
    required this.deliveryCharge,
    required this.discountAmount,
    required this.isDiscountApplied,
    required this.discountCtrl,
    required this.total,
    required this.grandTotal,
    required this.onApplyDiscount,
    required this.onRemoveDiscount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.summarize_outlined,
                    color: Color(0xFFe66d33), size: 18),
                SizedBox(width: 6),
                Text('Bill Summary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Divider(height: 20),
            _row('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
            // Discount row
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Discount (%): ',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: discountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      enabled: !isDiscountApplied,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter %',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: isDiscountApplied,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDiscountApplied
                          ? const Color(0xFFdc3545)
                          : const Color(0xFF28a745),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed:
                        isDiscountApplied ? onRemoveDiscount : onApplyDiscount,
                    child: Text(
                      isDiscountApplied ? 'Remove' : 'Apply',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            if (isDiscountApplied && discountAmount > 0) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFe8f5e9),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFFc8e6c9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount Applied',
                        style: TextStyle(
                            color: Color(0xFF2e7d32),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    Text('- ₹${discountAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Color(0xFF2e7d32),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (serviceCharge > 0)
              _row('Service Charge', '₹${serviceCharge.toStringAsFixed(2)}'),
            if (packingCharges > 0)
              _row('Packing Charges',
                  '₹${packingCharges.toStringAsFixed(2)}'),
            if (platformFee > 0)
              _row('Platform Fee', '₹${platformFee.toStringAsFixed(2)}'),
            if (deliveryCharge > 0)
              _row('Delivery Charge',
                  '₹${deliveryCharge.toStringAsFixed(2)}'),
            _row('GST', '₹${gst.toStringAsFixed(2)}'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFFe66d33)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: Color(0xFF555555))),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
