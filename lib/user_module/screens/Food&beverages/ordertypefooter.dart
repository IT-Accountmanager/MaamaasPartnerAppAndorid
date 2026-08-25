import 'package:flutter/material.dart';
import '../../API/food_authservice.dart';
import '../../widgets/food/currentcart_notifier.dart';
import 'food_cartscreen.dart';

enum OrderType {
  delivery,
  takeaway, dinein }

class OrderCartFooter extends StatefulWidget {
  final double? savedAmount;

  const OrderCartFooter({super.key, this.savedAmount});

  @override
  State<OrderCartFooter> createState() => _OrderCartFooterState();
}

class _OrderCartFooterState extends State<OrderCartFooter> {
  OrderType selectedType = OrderType.dinein;

  @override
  void initState() {
    super.initState();
    loadCartData();
  }

  Future<void> loadCartData() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      final cart = await food_Authservice.fetchCart();
      CartNotifier.count.value = count;

      setState(() {
        selectedType = _mapOrderType(cart?.orderType);
      });
    } catch (e) {
      // print("Error loading cart data: $e");
    }
  }

  Future<void> updateOrderTypeOnServer(OrderType type) async {
    try {
      // Convert enum to uppercase with underscore for backend
      String typeString;
      switch (type) {
        case OrderType.delivery:
          typeString = "DELIVERY";
          break;
        case OrderType.takeaway:
          typeString = "TAKEAWAY";
          break;
        case OrderType.dinein:
          typeString = "DINE_IN"; // <-- this is important
          break;
      }

      await food_Authservice.updateOrderType(typeString);
    } catch (e) {
      // print("Failed to update order type: $e");
    }
  }

  OrderType _mapOrderType(String? type) {
    switch (type?.toLowerCase()) {
      case "delivery":
        return OrderType.delivery;
      case "takeaway":
        return OrderType.takeaway;
      case "dine-in":
        return OrderType.dinein;
      default:
        return OrderType.dinein;
    }
  }

  Color _getSegmentColor(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return Colors.blue;
      case OrderType.takeaway:
        return Colors.orange;
      case OrderType.dinein:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isSmallScreen) ...[
              Expanded(flex: 2, child: _buildOrderTypeSelector()),
              const SizedBox(width: 16),
            ],

            Expanded(
              flex: isSmallScreen ? 2 : 1,
              child: ValueListenableBuilder<int>(
                valueListenable: CartNotifier.count,
                builder: (context, count, _) {
                  return _buildCartSummary(count, isSmallScreen: isSmallScreen);
                },
              ),
            ),

            if (isSmallScreen) ...[
              const SizedBox(width: 12),
              _buildOrderTypeDropdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          _buildOrderTypeSegment(
            label: 'Delivery',
            type: OrderType.delivery,
            icon: Icons.delivery_dining_rounded,
          ),
          _buildDivider(),
          _buildOrderTypeSegment(
            label: 'Takeaway',
            type: OrderType.takeaway,
            icon: Icons.takeout_dining_rounded,
          ),
          _buildDivider(),
          _buildOrderTypeSegment(
            label: 'Dine-in',
            type: OrderType.dinein,
            icon: Icons.restaurant_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeDropdown() {
    return PopupMenuButton<OrderType>(
      onSelected: (type) async {
        setState(() => selectedType = type);
        await updateOrderTypeOnServer(type);
      },
      itemBuilder: (BuildContext context) => [
        _buildPopupMenuItem(
          OrderType.delivery,
          'Delivery',
          Icons.delivery_dining_rounded,
        ),
        _buildPopupMenuItem(
          OrderType.takeaway,
          'Takeaway',
          Icons.takeout_dining_rounded,
        ),
        _buildPopupMenuItem(
          OrderType.dinein,
          'Dine-in',
          Icons.restaurant_rounded,
        ),
      ],
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: _getSegmentColor(selectedType),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getOrderTypeIcon(selectedType),
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  PopupMenuItem<OrderType> _buildPopupMenuItem(
    OrderType type,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<OrderType>(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: _getSegmentColor(type), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return Icons.delivery_dining_rounded;
      case OrderType.takeaway:
        return Icons.takeout_dining_rounded;
      case OrderType.dinein:
        return Icons.restaurant_rounded;
    }
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 20, color: Colors.grey.shade300);
  }

  Widget _buildOrderTypeSegment({
    required String label,
    required OrderType type,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;
    final color = _getSegmentColor(type);

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => selectedType = type);
          await updateOrderTypeOnServer(type); // send to server immediately
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(int count, {required bool isSmallScreen}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => food_cartScreen(
              savedAmount: widget.savedAmount ?? 0.0,
              showSavedPopup: true,
            ),
          ),
        );
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D5BFF), Color(0xFF8C6BFF)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Cart icon with badge only
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white, size: 22),

                // BADGE ONLY
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 18,
                        minWidth: 18,
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            // Arrow icon
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
