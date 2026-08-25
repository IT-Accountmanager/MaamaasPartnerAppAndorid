import 'package:flutter/material.dart';
import '../models/cart_models.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final VoidCallback onNote;
  final bool isSaved;

  const CartItemTile({
    Key? key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onNote,
    required this.isSaved,
  }) : super(key: key);

  String _shortStatus(String s) {
    switch (s) {
      case 'ORDER_IS_READY':
        return 'Ready';
      case 'WAITING_FOR_PICKUP':
        return 'Pickup';
      case 'ON_THE_WAY':
        return 'On Way';
      default:
        return s[0].toUpperCase() + s.substring(1).toLowerCase();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF17a2b8);
      case 'DELIVERED':
        return const Color(0xFF28a745);
      case 'PENDING':
        return const Color(0xFFffc107);
      case 'ORDER_IS_READY':
        return const Color(0xFF9b59b6);
      case 'ON_THE_WAY':
        return const Color(0xFF3498db);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Remove button ──────────────────────────────────────────────
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFdc3545).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Color(0xFFdc3545),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ── Name + badges ──────────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: onNote,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dish name — always ellipsized, never overflows
                    Text(
                      item.dishName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                    ),

                    // Optional note line
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),

                    // ── Badges — use Wrap so they never overflow ───────────
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        // Saved / Pending badge
                        _Badge(
                          label: isSaved ? 'Saved' : 'Pending',
                          color: isSaved
                              ? const Color(0xFF28a745)
                              : const Color(0xFFe66d33),
                        ),

                        if (item.orderStatus != null &&
                            item.orderStatus!.isNotEmpty)
                          _Badge(
                            label: _shortStatus(item.orderStatus!),
                            color: _statusColor(item.orderStatus!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // ── Qty controls ───────────────────────────────────────────────
            _QtyControl(
              quantity: item.quantity,
              onDecrease: onDecrease,
              onIncrease: onIncrease,
            ),

            const SizedBox(width: 6),

            SizedBox(
              width: 62,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small reusable badge ──────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Quantity control row ──────────────────────────────────────────────────────
class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  const _QtyControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFe66d33),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(icon: Icons.remove_rounded, onTap: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          _QtyBtn(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
