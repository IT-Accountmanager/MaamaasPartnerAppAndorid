import 'package:flutter/material.dart';

class TipSection extends StatelessWidget {
  final double tipAmount;
  final double? selectedTip;
  final TextEditingController customTipCtrl;
  final bool isAddingTip;
  final ValueChanged<double?> onSelectTip;
  final VoidCallback onAddTip;
  final VoidCallback onRemoveTip;

  const TipSection({
    Key? key,
    required this.tipAmount,
    required this.selectedTip,
    required this.customTipCtrl,
    required this.isAddingTip,
    required this.onSelectTip,
    required this.onAddTip,
    required this.onRemoveTip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasTip = tipAmount > 0;
    return Card(
      elevation: 0,
      color: hasTip ? const Color(0xFFe8f5e9) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasTip ? const Color(0xFFc8e6c9) : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  color: hasTip
                      ? const Color(0xFF2e7d32)
                      : const Color(0xFFe66d33),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  hasTip ? 'Tip Added' : 'Add Tip',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasTip) ...[
              Row(
                children: [10.0, 20.0, 50.0].map((amount) {
                  final isSelected = selectedTip == amount;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        onSelectTip(isSelected ? null : amount);
                        customTipCtrl.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFe66d33)
                              : const Color(0xFFf5f5f5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFe66d33)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '₹${amount.toInt()}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: customTipCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => onSelectTip(null),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Custom amount',
                          prefixText: '₹',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe66d33),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: isAddingTip ? null : onAddTip,
                      child: isAddingTip
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2e7d32),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tip of ₹${tipAmount.toStringAsFixed(0)} added',
                        style: const TextStyle(
                          color: Color(0xFF2e7d32),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: isAddingTip ? null : onRemoveTip,
                    icon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFFdc3545),
                    ),
                    label: const Text(
                      'Remove',
                      style: TextStyle(color: Color(0xFFdc3545), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
