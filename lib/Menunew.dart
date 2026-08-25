import 'package:flutter/material.dart';

// ─── COLORS ──────────────────────────────────────────────────
class AppColors {
  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFF7ED);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFF0FDF4);
  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFFEF2F2);
  static const yellow = Color(0xFFF59E0B);
  static const blue = Color(0xFF2563EB);
  static const greyLight = Color(0xFFF9FAFB);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const white = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF3F4F6);
}

// ─── MODELS ──────────────────────────────────────────────────
class MenuCategory {
  final String name, description, created;
  final int items;
  final bool isActive;
  const MenuCategory({
    required this.name,
    required this.description,
    required this.items,
    required this.isActive,
    required this.created,
  });
}

class MenuItem {
  final String name, description, category, stock;
  final double basePrice, gst, delivery, pkg, finalPrice, costPrice;
  final bool isActive, isOos;
  final int popularity;
  const MenuItem({
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.gst,
    required this.delivery,
    required this.pkg,
    required this.finalPrice,
    required this.costPrice,
    required this.stock,
    required this.isActive,
    this.isOos = false,
    required this.popularity,
  });
}

class PricingCharge {
  final String type, method, value, appliedTo;
  final bool isActive;
  const PricingCharge({
    required this.type,
    required this.method,
    required this.value,
    required this.appliedTo,
    required this.isActive,
  });
}

class StockItem {
  final String name, category, totalStock, lowAlert, unit;
  final bool inStock;
  bool availableToday;
  final String? quickUpdate;
  StockItem({
    required this.name,
    required this.category,
    required this.totalStock,
    required this.lowAlert,
    required this.unit,
    required this.inStock,
    required this.availableToday,
    this.quickUpdate,
  });
}

class ImageLibraryItem {
  final String itemName, source, uploaded;
  const ImageLibraryItem({
    required this.itemName,
    required this.source,
    required this.uploaded,
  });
}

// ─── SAMPLE DATA ─────────────────────────────────────────────
final categories = [
  const MenuCategory(
    name: 'Biryani',
    description: 'Authentic Hyderabadi style biryanis',
    items: 8,
    isActive: true,
    created: '2025-12-01',
  ),
  const MenuCategory(
    name: 'Starters',
    description: 'Crispy appetizers and kebabs',
    items: 12,
    isActive: true,
    created: '2025-12-01',
  ),
  const MenuCategory(
    name: 'Main Course',
    description: 'Rich curries and gravies',
    items: 15,
    isActive: true,
    created: '2025-12-05',
  ),
  const MenuCategory(
    name: 'Rice & Breads',
    description: 'Naan, roti, and flavored rice',
    items: 6,
    isActive: true,
    created: '2025-12-05',
  ),
  const MenuCategory(
    name: 'Beverages',
    description: 'Fresh juices, lassi, and drinks',
    items: 10,
    isActive: true,
    created: '2025-12-10',
  ),
  const MenuCategory(
    name: 'Desserts',
    description: 'Traditional Indian sweets',
    items: 4,
    isActive: false,
    created: '2025-12-15',
  ),
];

final menuItems = [
  const MenuItem(
    name: 'Chicken Biryani',
    description: 'Aromatic basmati rice with tender chicken',
    category: 'Biryani',
    basePrice: 249,
    gst: 12,
    delivery: 25,
    pkg: 15,
    finalPrice: 301,
    costPrice: 120,
    stock: '50/plate',
    isActive: true,
    popularity: 95,
  ),
  const MenuItem(
    name: 'Mutton Biryani',
    description: 'Premium mutton pieces with saffron rice',
    category: 'Biryani',
    basePrice: 349,
    gst: 17,
    delivery: 35,
    pkg: 15,
    finalPrice: 416,
    costPrice: 180,
    stock: '30/plate',
    isActive: true,
    popularity: 88,
  ),
  const MenuItem(
    name: 'Paneer Tikka',
    description: 'Grilled cottage cheese with spices',
    category: 'Starters',
    basePrice: 199,
    gst: 10,
    delivery: 20,
    pkg: 10,
    finalPrice: 239,
    costPrice: 80,
    stock: '∞',
    isActive: true,
    popularity: 76,
  ),
  const MenuItem(
    name: 'Butter Chicken',
    description: 'Creamy tomato-based chicken curry',
    category: 'Main Course',
    basePrice: 279,
    gst: 14,
    delivery: 28,
    pkg: 12,
    finalPrice: 333,
    costPrice: 100,
    stock: '40/plate',
    isActive: true,
    popularity: 92,
  ),
  const MenuItem(
    name: 'Mango Lassi',
    description: 'Fresh mango yogurt smoothie',
    category: 'Beverages',
    basePrice: 89,
    gst: 4,
    delivery: 0,
    pkg: 5,
    finalPrice: 98,
    costPrice: 30,
    stock: '∞',
    isActive: false,
    isOos: true,
    popularity: 65,
  ),
];

final charges = [
  const PricingCharge(
    type: 'GST',
    method: 'Percentage',
    value: '5%',
    appliedTo: 'All Items',
    isActive: true,
  ),
  const PricingCharge(
    type: 'Delivery Charges',
    method: 'Percentage',
    value: '10%',
    appliedTo: 'All Items',
    isActive: true,
  ),
  const PricingCharge(
    type: 'Packaging Charges',
    method: 'Fixed',
    value: '₹15',
    appliedTo: 'All Items',
    isActive: true,
  ),
  const PricingCharge(
    type: 'Service Fee',
    method: 'Percentage',
    value: '2%',
    appliedTo: 'Dine-in Only',
    isActive: false,
  ),
  const PricingCharge(
    type: 'Platform Fee',
    method: 'Fixed',
    value: '₹3',
    appliedTo: 'Online Orders',
    isActive: true,
  ),
];

List<StockItem> stockItems = [
  StockItem(
    name: 'Chicken Biryani',
    category: 'Biryani',
    totalStock: '50',
    lowAlert: '10',
    unit: 'Plate',
    inStock: true,
    availableToday: true,
    quickUpdate: '50',
  ),
  StockItem(
    name: 'Mutton Biryani',
    category: 'Biryani',
    totalStock: '30',
    lowAlert: '5',
    unit: 'Plate',
    inStock: true,
    availableToday: true,
    quickUpdate: '30',
  ),
  StockItem(
    name: 'Paneer Tikka',
    category: 'Starters',
    totalStock: '∞',
    lowAlert: '—',
    unit: 'Plate',
    inStock: true,
    availableToday: true,
  ),
  StockItem(
    name: 'Butter Chicken',
    category: 'Main Course',
    totalStock: '40',
    lowAlert: '8',
    unit: 'Plate',
    inStock: true,
    availableToday: true,
    quickUpdate: '40',
  ),
  StockItem(
    name: 'Mango Lassi',
    category: 'Beverages',
    totalStock: '∞',
    lowAlert: '—',
    unit: 'Plate',
    inStock: false,
    availableToday: false,
  ),
];

final imageLibrary = [
  const ImageLibraryItem(
    itemName: 'Chicken Biryani',
    source: 'Upload',
    uploaded: '2025-12-01',
  ),
  const ImageLibraryItem(
    itemName: 'Paneer Tikka',
    source: 'AI Generated',
    uploaded: '2025-12-05',
  ),
  const ImageLibraryItem(
    itemName: 'Butter Chicken',
    source: 'Upload',
    uploaded: '2025-12-10',
  ),
];

// ─── MAIN SCREEN ─────────────────────────────────────────────
class ProductsServicesScreen extends StatefulWidget {
  const ProductsServicesScreen({super.key});
  @override
  State<ProductsServicesScreen> createState() => _ProductsServicesScreenState();
}

class _ProductsServicesScreenState extends State<ProductsServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  final _search = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tc.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_showSearch) _searchBar(),
          _tabBar(),
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                MenuCategoriesTab(),
                MenuItemsTab(),
                PricingChargesTab(),
                StockAvailabilityTab(),
                MediaAITab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppColors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleSpacing: 16,
    title: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products & Services',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: Icon(
          _showSearch ? Icons.search_off : Icons.search,
          color: AppColors.textSecondary,
        ),
        onPressed: () => setState(() => _showSearch = !_showSearch),
      ),
    ],
  );

  Widget _searchBar() => Container(
    color: AppColors.white,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    child: TextField(
      controller: _search,
      autofocus: true,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search items...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.greyLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );

  Widget _tabBar() => Container(
    color: AppColors.white,
    child: TabBar(
      controller: _tc,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.orange,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.orange,
      indicatorWeight: 2.5,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      tabs: const [
        Tab(text: 'Categories'),
        Tab(text: 'Menu Items'),
        Tab(text: 'Pricing'),
        Tab(text: 'Stock'),
        Tab(text: 'Media & AI'),
      ],
    ),
  );
}

// ─── SHARED WIDGETS ──────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final bool isActive;
  final String? label;
  const StatusBadge({super.key, required this.isActive, this.label});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.green : AppColors.red;
    final bg = isActive ? AppColors.greenLight : AppColors.redLight;
    final text = label ?? (isActive ? 'Active' : 'Hidden');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OrangeBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool small;
  const OrangeBtn({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed ?? () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.orange,
      foregroundColor: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(
        horizontal: small ? 12 : 14,
        vertical: small ? 7 : 9,
      ),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: small ? 14 : 15),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: small ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class GhostBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  const GhostBtn({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 14), const SizedBox(width: 5)],
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold;
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _divider() => const Divider(height: 1, color: AppColors.border);

// ─── TAB 1: MENU CATEGORIES ──────────────────────────────────
class MenuCategoriesTab extends StatelessWidget {
  const MenuCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '6 categories',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OrangeBtn(label: 'Add Category', icon: Icons.add),
          ],
        ),
        const SizedBox(height: 14),
        ...categories.map(
          (cat) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 10),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            StatusBadge(isActive: cat.isActive),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Item count
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orangeLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${cat.items} items',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat.created,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            // Actions
                            _iconBtn(
                              Icons.edit_outlined,
                              AppColors.textSecondary,
                            ),
                            _iconBtn(Icons.delete_outline, AppColors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color) => SizedBox(
    width: 32,
    height: 32,
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18, color: color),
      onPressed: () {},
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    ),
  );
}

// ─── TAB 2: MENU ITEMS ───────────────────────────────────────
class MenuItemsTab extends StatefulWidget {
  const MenuItemsTab({super.key});
  @override
  State<MenuItemsTab> createState() => _MenuItemsTabState();
}

class _MenuItemsTabState extends State<MenuItemsTab> {
  String _cat = 'All';

  static const _cats = [
    'All',
    'Biryani',
    'Starters',
    'Main Course',
    'Beverages',
  ];

  List<MenuItem> get _filtered => _cat == 'All'
      ? menuItems
      : menuItems.where((m) => m.category == _cat).toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '5 items across all categories',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OrangeBtn(label: 'Add Item', icon: Icons.add),
          ],
        ),
        const SizedBox(height: 12),
        // Action buttons row
        Row(
          children: [
            const GhostBtn(label: 'Bulk Upload', icon: Icons.upload_outlined),
            const SizedBox(width: 8),
            const GhostBtn(label: 'Export', icon: Icons.download_outlined),
          ],
        ),
        const SizedBox(height: 14),
        // Summary row
        Row(
          children: [
            _sumCard('Total', '5', AppColors.orange),
            const SizedBox(width: 8),
            _sumCard('Active', '4', AppColors.green),
            const SizedBox(width: 8),
            _sumCard('OOS', '1', AppColors.red),
            const SizedBox(width: 8),
            _sumCard('Avg', '₹278', AppColors.blue),
          ],
        ),
        const SizedBox(height: 14),
        // Category filter chips
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = _cats[i] == _cat;
              return GestureDetector(
                onTap: () => setState(() => _cat = _cats[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.orange : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.orange : AppColors.border,
                    ),
                  ),
                  child: Text(
                    _cats[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        ..._filtered.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _menuItemCard(item),
          ),
        ),
      ],
    );
  }

  Widget _sumCard(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _menuItemCard(MenuItem item) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: avatar + name + status
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  item.name[0],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            item.isOos ? _oosChip() : StatusBadge(isActive: item.isActive),
          ],
        ),
        const SizedBox(height: 10),
        // Category + stock row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.inventory_2_outlined,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 3),
            Text(
              item.stock,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 12, color: AppColors.green),
                const SizedBox(width: 3),
                Text(
                  '${item.popularity}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _priceCol('Base', '₹${item.basePrice.toInt()}'),
                  ),
                  Expanded(child: _priceCol('GST', '₹${item.gst.toInt()}')),
                  Expanded(
                    child: _priceCol('Delivery', '₹${item.delivery.toInt()}'),
                  ),
                  Expanded(child: _priceCol('Pkg', '₹${item.pkg.toInt()}')),
                  Expanded(
                    child: _priceCol(
                      'Final',
                      '₹${item.finalPrice.toInt()}',
                      color: AppColors.orange,
                      bold: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _actionBtn(Icons.edit_outlined, AppColors.textSecondary),
            const SizedBox(width: 4),
            _actionBtn(Icons.delete_outline, AppColors.red),
          ],
        ),
      ],
    ),
  );

  Widget _priceCol(
    String label,
    String value, {
    Color? color,
    bool bold = false,
  }) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    ],
  );

  Widget _oosChip() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.redLight,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.circle, size: 5, color: AppColors.red),
        SizedBox(width: 4),
        Text(
          'OOS',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _actionBtn(IconData icon, Color color) => SizedBox(
    width: 32,
    height: 32,
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18, color: color),
      onPressed: () {},
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    ),
  );
}

// ─── TAB 3: PRICING & CHARGES ────────────────────────────────
class PricingChargesTab extends StatelessWidget {
  const PricingChargesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pricing & Charges',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Default charges applied to menu items',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OrangeBtn(label: 'Add Charge', icon: Icons.add),
          ],
        ),
        const SizedBox(height: 14),
        ...charges.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.type,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(
                        isActive: c.isActive,
                        label: c.isActive ? 'Active' : 'Inactive',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _tagItem('Method', c.method)),
                      Expanded(
                        child: _tagItem('Value', c.value, highlight: true),
                      ),
                      Expanded(child: _tagItem('Applied To', c.appliedTo)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _actionBtn(Icons.edit_outlined, AppColors.textSecondary),
                      const SizedBox(width: 4),
                      _actionBtn(Icons.delete_outline, AppColors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Price calculation example
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 16,
                    color: AppColors.orange,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Price Calculation Example',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _divider(),
              const SizedBox(height: 10),
              _calcRow('Base Price', '₹249.00'),
              _calcRow('GST 5%', '+ ₹12.45'),
              _calcRow('Delivery 10%', '+ ₹24.90'),
              _calcRow('Packaging', '+ ₹15.00'),
              const SizedBox(height: 6),
              _divider(),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Final Price',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '₹301.35',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tagItem(String label, String value, {bool highlight = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.orange : AppColors.textPrimary,
            ),
          ),
        ],
      );

  Widget _calcRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _actionBtn(IconData icon, Color color) => SizedBox(
    width: 32,
    height: 32,
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18, color: color),
      onPressed: () {},
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    ),
  );
}

// ─── TAB 4: STOCK & AVAILABILITY ─────────────────────────────
class StockAvailabilityTab extends StatefulWidget {
  const StockAvailabilityTab({super.key});
  @override
  State<StockAvailabilityTab> createState() => _StockAvailabilityTabState();
}

class _StockAvailabilityTabState extends State<StockAvailabilityTab> {
  late List<StockItem> _items;

  @override
  void initState() {
    super.initState();
    _items = stockItems
        .map(
          (s) => StockItem(
            name: s.name,
            category: s.category,
            totalStock: s.totalStock,
            lowAlert: s.lowAlert,
            unit: s.unit,
            inStock: s.inStock,
            availableToday: s.availableToday,
            quickUpdate: s.quickUpdate,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock & Availability',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Manage daily stock and availability',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Reset', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Summary cards 2x2
        Row(
          children: [
            _summaryCard(
              Icons.check_circle_outline,
              AppColors.green,
              'Available',
              '4',
            ),
            const SizedBox(width: 10),
            _summaryCard(
              Icons.cancel_outlined,
              AppColors.red,
              'Out of Stock',
              '1',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _summaryCard(
              Icons.warning_amber_outlined,
              AppColors.yellow,
              'Low Stock',
              '0',
            ),
            const SizedBox(width: 10),
            _summaryCard(Icons.sync, AppColors.blue, 'Total Units', '120'),
          ],
        ),
        const SizedBox(height: 14),
        ..._items.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _stockCard(e.value, e.key),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(IconData icon, Color color, String label, String value) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _stockCard(StockItem item, int idx) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + status
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: item.inStock
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            _stockChip(item.inStock),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item.category,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        // Stats row
        Row(
          children: [
            Expanded(child: _statBox('Total Stock', item.totalStock)),
            const SizedBox(width: 8),
            Expanded(child: _statBox('Low Alert', item.lowAlert)),
            const SizedBox(width: 8),
            Expanded(child: _statBox('Unit', item.unit)),
          ],
        ),
        const SizedBox(height: 10),
        // Available today toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Available Today',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: item.availableToday,
                  onChanged: (v) =>
                      setState(() => _items[idx].availableToday = v),
                  activeColor: AppColors.orange,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        // Quick update field
        if (item.quickUpdate != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Quick Update:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                width: 80,
                height: 34,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.white,
                ),
                child: TextFormField(
                  initialValue: item.quickUpdate,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'plates',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  Widget _statBox(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.greyLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _stockChip(bool inStock) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: inStock ? AppColors.greenLight : AppColors.redLight,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      inStock ? 'In Stock' : 'Out of Stock',
      style: TextStyle(
        fontSize: 11,
        color: inStock ? AppColors.green : AppColors.red,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ─── TAB 5: MEDIA & AI GENERATOR ─────────────────────────────
class MediaAITab extends StatefulWidget {
  const MediaAITab({super.key});
  @override
  State<MediaAITab> createState() => _MediaAITabState();
}

class _MediaAITabState extends State<MediaAITab> {
  final _prompt = TextEditingController(
    text:
        'High quality restaurant style chicken biryani in bowl, food photography, studio lighting',
  );
  bool _generating = false;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media & AI Generator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Manage product images & AI photography',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OrangeBtn(label: 'Upload', icon: Icons.upload_outlined),
          ],
        ),
        const SizedBox(height: 14),
        // AI Generator card
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.orangeLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_fix_high,
                      size: 18,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Food Image Generator',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Describe the dish and style you want',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Prompt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _prompt,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Describe your dish...',
                  filled: true,
                  fillColor: AppColors.greyLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.orange),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _generating = !_generating),
                      icon: Icon(
                        _generating ? Icons.hourglass_top : Icons.auto_fix_high,
                        size: 15,
                      ),
                      label: Text(
                        _generating ? 'Generating...' : 'Generate Image',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Preview',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'AI image generation requires Lovable Cloud to be enabled.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Image library
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Image Library',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${imageLibrary.length} images',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...imageLibrary.asMap().entries.map(
                (e) => Column(
                  children: [
                    _imgRow(e.value),
                    if (e.key < imageLibrary.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _divider(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imgRow(ImageLibraryItem img) {
    final isAI = img.source == 'AI Generated';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 24,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  img.itemName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAI
                            ? AppColors.greenLight
                            : AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        img.source,
                        style: TextStyle(
                          fontSize: 10,
                          color: isAI ? AppColors.green : AppColors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      img.uploaded,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_red_eye_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColors.red,
            ),
            onPressed: () {},
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
