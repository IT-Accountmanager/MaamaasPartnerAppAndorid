import 'package:flutter/material.dart';

// ─── THEME ────────────────────────────────────────────────────────────────────
const kOrange = Color(0xFFE8641A);
const kOrangeLight = Color(0xFFFFF3EC);
const kDark = Color(0xFF1A1A1A);
const kGrey = Color(0xFF6B7280);
const kBorder = Color(0xFFE5E7EB);
const kGreen = Color(0xFF16A34A);
const kRed = Color(0xFFDC2626);
const kBlue = Color(0xFF2563EB);

// ─── MAIN SHELL ──────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedTab = 0;

  final List<String> _tabs = [
    'Menu & SOP',
    'Dashboard & KOT',
    'Catering Orders',
    'Quantity Chart',
    'Preparation Chart',
    'Chef Performance',
  ];

  final List<IconData> _icons = [
    Icons.restaurant_menu,
    Icons.dashboard,
    Icons.delivery_dining,
    Icons.bar_chart,
    Icons.assignment,
    Icons.people,
  ];

  final List<Widget> _screens = const [
    MenuSopScreen(),
    DashboardKotScreen(),
    CateringOrdersScreen(),
    QuantityChartScreen(),
    PreparationChartScreen(),
    ChefPerformanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDark,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: kOrange, size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Chef Management',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: _screens[_selectedTab],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: kDark,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: kOrange, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Chef Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            ...List.generate(_tabs.length, (i) {
              final selected = _selectedTab == i;
              return ListTile(
                leading: Icon(
                  _icons[i],
                  color: selected ? kOrange : Colors.grey[400],
                  size: 20,
                ),
                title: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: selected ? kOrange : Colors.grey[300],
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                selected: selected,
                selectedTileColor: kOrange.withOpacity(0.15),
                onTap: () {
                  setState(() => _selectedTab = i);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    // Show only first 5 tabs in bottom nav; 6th accessible via drawer
    final displayTabs = _tabs.take(5).toList();
    final displayIcons = _icons.take(5).toList();
    return BottomNavigationBar(
      currentIndex: _selectedTab < 5 ? _selectedTab : 0,
      onTap: (i) => setState(() => _selectedTab = i),
      selectedItemColor: kOrange,
      unselectedItemColor: kGrey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      unselectedFontSize: 9,
      items: List.generate(
        displayTabs.length,
        (i) => BottomNavigationBarItem(
          icon: Icon(displayIcons[i], size: 20),
          label: displayTabs[i].split(' ').first,
        ),
      ),
    );
  }
}

// ─── SHARED WIDGETS ──────────────────────────────────────────────────────────
class AIInsightBanner extends StatelessWidget {
  final String text;
  const AIInsightBanner({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kOrangeLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kOrange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy_outlined, color: kOrange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: kDark),
                children: [
                  const TextSpan(
                    text: 'AI: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kOrange,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrangeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  const OrangeButton({super.key, required this.label, this.onTap, this.icon});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const StatusBadge({super.key, required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── 1. MENU & SOP SCREEN ────────────────────────────────────────────────────
class MenuSopScreen extends StatefulWidget {
  const MenuSopScreen({super.key});
  @override
  State<MenuSopScreen> createState() => _MenuSopScreenState();
}

class _MenuSopScreenState extends State<MenuSopScreen> {
  String _activeFilter = 'All';
  final List<String> _filters = [
    'All',
    'Biryani',
    'Curries',
    'Starters',
    'Breads',
    'Desserts',
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'category': 'Biryani',
      'name': 'Chicken Biryani',
      'type': 'Non-Veg',
      'prep': '45 min',
      'chef': 'Indian Chef',
      'serves': '1 pax',
      'desc': 'Aromatic basmati rice layered...',
      'inStock': true,
    },
    {
      'category': 'Biryani',
      'name': 'Veg Biryani',
      'type': 'Veg',
      'prep': '40 min',
      'chef': 'Indian Chef',
      'serves': '1 pax',
      'desc': 'Fragrant rice with fresh vegeta...',
      'inStock': true,
    },
    {
      'category': 'Curries',
      'name': 'Paneer Butter Masala',
      'type': 'Veg',
      'prep': '25 min',
      'chef': 'North Indian Chef',
      'serves': '2 pax',
      'desc': 'Soft paneer cubes in rich tomat...',
      'inStock': true,
    },
    {
      'category': 'Starters',
      'name': 'Tandoori Chicken',
      'type': 'Non-Veg',
      'prep': '30 min',
      'chef': 'North Indian Chef',
      'serves': '2 pax',
      'desc': 'Marinated chicken roasted in ta...',
      'inStock': true,
    },
    {
      'category': 'Starters',
      'name': 'Veg Manchuria',
      'type': 'Veg',
      'prep': '15 min',
      'chef': 'Chinese Chef',
      'serves': '2 pax',
      'desc': 'Crispy vegetable balls in spicy...',
      'inStock': false,
    },
    {
      'category': 'Curries',
      'name': 'Dal Tadka',
      'type': 'Veg',
      'prep': '20 min',
      'chef': 'Indian Chef',
      'serves': '2 pax',
      'desc': 'Yellow lentils tempered with cu...',
      'inStock': true,
    },
    {
      'category': 'Breads',
      'name': 'Naan',
      'type': 'Veg',
      'prep': '5 min',
      'chef': 'North Indian Chef',
      'serves': '1 pax',
      'desc': 'Soft leavened bread baked in t...',
      'inStock': true,
    },
    {
      'category': 'Desserts',
      'name': 'Gulab Jamun',
      'type': 'Veg',
      'prep': '30 min',
      'chef': 'Indian Chef',
      'serves': '4 pax',
      'desc': 'Deep-fried milk dumplings soak...',
      'inStock': true,
    },
  ];

  List<Map<String, dynamic>> get _filtered => _activeFilter == 'All'
      ? _menuItems
      : _menuItems.where((e) => e['category'] == _activeFilter).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu & SOP',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddCategoryDialog(),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text(
                        'Add Category',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kDark,
                        side: const BorderSide(color: kBorder),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OrangeButton(
                      label: 'Add Item',
                      icon: Icons.add,
                      onTap: () => _showAddItemDialog(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        const AIInsightBanner(
          text:
              'Top sellers this week: Chicken Biryani, Paneer Butter Masala, Tandoori Chicken. Consider featuring them as specials.',
        ),
        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search menu...',
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        // Filter chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filters.length,
            itemBuilder: (ctx, i) {
              final active = _filters[i] == _activeFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    _filters[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? Colors.white : kDark,
                    ),
                  ),
                  selected: active,
                  selectedColor: kOrange,
                  backgroundColor: Colors.white,
                  onSelected: (_) =>
                      setState(() => _activeFilter = _filters[i]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // List (card-based on mobile instead of fixed-width table)
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: kBorder),
            itemBuilder: (ctx, i) {
              final item = _filtered[i];
              return _MenuItemRow(item: item);
            },
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    showDialog(context: context, builder: (_) => _AddCategoryDialog());
  }

  void _showAddItemDialog() {
    showDialog(context: context, builder: (_) => _AddMenuItemDialog());
  }
}

class _MenuItemRow extends StatefulWidget {
  final Map<String, dynamic> item;
  const _MenuItemRow({required this.item});
  @override
  State<_MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<_MenuItemRow> {
  late bool inStock;
  @override
  void initState() {
    super.initState();
    inStock = widget.item['inStock'] as bool;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: name/category + veg/non-veg badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      item['category'],
                      style: const TextStyle(fontSize: 10, color: kGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                text: item['type'],
                color: item['type'] == 'Veg' ? kGreen : kRed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom row: prep time, stock switch, SOP/Bulk actions — wraps on small screens
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 12, color: kGrey),
                  const SizedBox(width: 3),
                  Text(
                    item['prep'],
                    style: const TextStyle(fontSize: 11, color: kGrey),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: inStock,
                    onChanged: (v) => setState(() => inStock = v),
                    activeColor: kOrange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    inStock ? 'In Stock' : 'Out',
                    style: TextStyle(
                      fontSize: 10,
                      color: inStock ? kGreen : kRed,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) =>
                          _SopIngredientsDialog(itemName: item['name']),
                    ),
                    child: const Text(
                      'SOP',
                      style: TextStyle(
                        fontSize: 11,
                        color: kOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) =>
                          _BulkCalculatorDialog(itemName: item['name']),
                    ),
                    child: const Text(
                      'Bulk',
                      style: TextStyle(fontSize: 11, color: kGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddCategoryDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Add New Category',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        decoration: InputDecoration(
          labelText: 'Category Name',
          hintText: 'e.g. Tiffins',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kOrange),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: kGrey)),
        ),
        OrangeButton(label: 'Create', onTap: () => Navigator.pop(context)),
      ],
    );
  }
}

class _AddMenuItemDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Add New Menu Item',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Item Name', 'e.g. Chicken Tikka'),
            const SizedBox(height: 10),
            _field('Category', 'e.g. Starters'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _field('Type (Veg/Non-Veg)', 'Veg')),
                const SizedBox(width: 10),
                Expanded(child: _field('Prep Time (min)', '0')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _field('Chef Type Required', 'Indian Chef')),
                const SizedBox(width: 10),
                Expanded(child: _field('Serving Capacity', '1')),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kOrange),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: kGrey)),
        ),
        OrangeButton(label: 'Add Item', onTap: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _field(String label, String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kOrange),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}

class _SopIngredientsDialog extends StatelessWidget {
  final String itemName;
  const _SopIngredientsDialog({required this.itemName});

  static const _ingredients = [
    {
      'name': 'Basmati Rice',
      'qty': '1',
      'unit': 'kg',
      'quality': 'Premium Sona Masuri',
      'wastage': '3%',
    },
    {
      'name': 'Chicken',
      'qty': '1.2',
      'unit': 'kg',
      'quality': 'Fresh, bone-in',
      'wastage': '5%',
    },
    {
      'name': 'Onions',
      'qty': '0.5',
      'unit': 'kg',
      'quality': 'Red onions, sliced thin',
      'wastage': '8%',
    },
    {
      'name': 'Yogurt',
      'qty': '0.3',
      'unit': 'kg',
      'quality': 'Full fat, fresh',
      'wastage': '2%',
    },
    {
      'name': 'Biryani Masala',
      'qty': '0.12',
      'unit': 'kg',
      'quality': 'House blend',
      'wastage': '1%',
    },
    {
      'name': 'Ghee',
      'qty': '0.1',
      'unit': 'kg',
      'quality': 'Pure cow ghee',
      'wastage': '1%',
    },
    {
      'name': 'Saffron',
      'qty': '0.002',
      'unit': 'kg',
      'quality': 'Kashmir grade',
      'wastage': '0%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SOP & Ingredients — $itemName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Ingredients (per 1 kg rice base)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 13),
                  label: const Text('Add', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kOrange,
                    side: const BorderSide(color: kOrange),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Scrollable ingredient cards instead of a fixed multi-column table
            Expanded(
              child: ListView.separated(
                itemCount: _ingredients.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: kBorder),
                itemBuilder: (ctx, i) {
                  final ing = _ingredients[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ing['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${ing['qty']} ${ing['unit']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ing['quality']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kGrey,
                                ),
                              ),
                            ),
                            Text(
                              'Wastage: ${ing['wastage']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: kGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkCalculatorDialog extends StatefulWidget {
  final String itemName;
  const _BulkCalculatorDialog({required this.itemName});
  @override
  State<_BulkCalculatorDialog> createState() => _BulkCalculatorDialogState();
}

class _BulkCalculatorDialogState extends State<_BulkCalculatorDialog> {
  int plates = 120;

  @override
  Widget build(BuildContext context) {
    final rice = (plates * 0.25).toStringAsFixed(1);
    final water = (plates * 0.45).toStringAsFixed(1);
    final chicken = (plates * 0.30).toStringAsFixed(1);
    final masala = (plates * 0.03).toStringAsFixed(1);
    final onions = (plates * 0.125).toStringAsFixed(1);
    final ghee = (plates * 0.025).toStringAsFixed(1);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          const Icon(Icons.calculate_outlined, color: kOrange, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Bulk Preparation Calculator',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Required Plates: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: '$plates'),
                    onChanged: (v) =>
                        setState(() => plates = int.tryParse(v) ?? plates),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kOrange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kOrange),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _CalcCard('Rice', rice, 'kg'),
                _CalcCard('Water', water, 'liters'),
                _CalcCard('Chicken', chicken, 'kg'),
                _CalcCard('Masala', masala, 'kg'),
                _CalcCard('Onions', onions, 'kg'),
                _CalcCard('Ghee', ghee, 'kg'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: kGrey)),
        ),
      ],
    );
  }
}

class _CalcCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _CalcCard(this.label, this.value, this.unit);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: kGrey),
            overflow: TextOverflow.ellipsis,
          ),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 9, color: kGrey),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── 2. DASHBOARD & KOT SCREEN ───────────────────────────────────────────────
class DashboardKotScreen extends StatelessWidget {
  const DashboardKotScreen({super.key});

  static const _stats = [
    {
      'label': 'Active KOT',
      'value': '6',
      'icon': Icons.receipt_long,
      'color': kOrange,
    },
    {
      'label': 'Preparing',
      'value': '2',
      'icon': Icons.restaurant,
      'color': kBlue,
    },
    {
      'label': 'Ready',
      'value': '1',
      'icon': Icons.trending_up,
      'color': kGreen,
    },
    {
      'label': 'Delayed',
      'value': '1',
      'icon': Icons.warning_amber,
      'color': kRed,
    },
    {
      'label': 'Catering Today',
      'value': '1',
      'icon': Icons.delivery_dining,
      'color': kOrange,
    },
    {
      'label': 'Scheduled Catering',
      'value': '3',
      'icon': Icons.calendar_today,
      'color': Colors.purple,
    },
    {
      'label': 'Chef Available',
      'value': '4',
      'icon': Icons.people,
      'color': kGreen,
    },
    {
      'label': 'Ingredient Alert',
      'value': '2',
      'icon': Icons.warning,
      'color': kRed,
    },
  ];

  static final _kots = [
    {
      'id': 'KOT-001',
      'type': 'Dine In',
      'typeColor': kGreen,
      'items': [
        {'name': 'Chicken Biryani', 'qty': '×2'},
        {'name': 'Raita', 'qty': '×2'},
      ],
      'time': '12:15 PM',
      'duration': '~25 min',
      'status': 'PENDING',
      'statusColor': Colors.amber,
      'action': 'pending',
    },
    {
      'id': 'KOT-002',
      'type': 'Takeaway',
      'typeColor': kBlue,
      'items': [
        {'name': 'Veg Manchuria', 'qty': '×1'},
        {'name': 'Fried Rice', 'qty': '×1'},
      ],
      'time': '12:22 PM',
      'duration': '~15 min',
      'status': 'PENDING',
      'statusColor': Colors.amber,
      'action': 'pending',
    },
    {
      'id': 'KOT-003',
      'type': 'Delivery',
      'typeColor': kOrange,
      'items': [
        {'name': 'Paneer Butter Masala', 'qty': '×3'},
        {'name': 'Naan', 'qty': '×6'},
        {'name': 'Dal Tadka', 'qty': '×2'},
      ],
      'time': '12:30 PM',
      'duration': '~30 min',
      'status': 'ACCEPTED',
      'statusColor': kBlue,
      'chef': 'Chef Priya',
      'chefType': 'Indian Chef',
      'accepted': '12:31 PM',
      'action': 'accepted',
    },
    {
      'id': 'KOT-004',
      'type': 'Table T-7',
      'typeColor': Colors.purple,
      'items': [
        {'name': 'Mutton Rogan Josh', 'qty': '×1'},
        {'name': 'Jeera Rice', 'qty': '×1'},
      ],
      'time': '12:35 PM',
      'duration': '~35 min',
      'status': 'PREPARING',
      'statusColor': kBlue,
      'chef': 'Chef Ramesh',
      'chefType': 'North Indian Chef',
      'accepted': '12:36 PM',
      'prepStart': '12:38 PM',
      'action': 'preparing',
    },
    {
      'id': 'KOT-005',
      'type': 'Dine In',
      'typeColor': kGreen,
      'items': [
        {'name': 'Tandoori Chicken', 'qty': '×1'},
      ],
      'time': '12:40 PM',
      'duration': '~20 min',
      'status': 'PENDING',
      'statusColor': Colors.amber,
      'action': 'pending',
    },
    {
      'id': 'KOT-006',
      'type': 'Delivery',
      'typeColor': kOrange,
      'items': [
        {'name': 'Chicken 65', 'qty': '×2'},
        {'name': 'Egg Fried Rice', 'qty': '×2'},
      ],
      'time': '12:45 PM',
      'duration': '~20 min',
      'status': 'READY',
      'statusColor': kGreen,
      'chef': 'Chef Suresh',
      'chefType': 'Indian Chef',
      'accepted': '12:46 PM',
      'prepStart': '12:48 PM',
      'completed': '1:05 PM',
      'action': 'ready',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats grid — 2 columns on mobile, taller cards so text never overflows
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: _stats.map((s) => _StatCard(s)).toList(),
            ),
          ),
          // AI Insights
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kOrange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.smart_toy_outlined, color: kOrange, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AI Kitchen Insights',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kOrange,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InsightChip(
                      '🔥 High demand: Chicken Biryani (+40% vs yesterday)',
                    ),
                    _InsightChip('📋 Predicted: ~35 orders in next 2 hours'),
                    _InsightChip(
                      '⚠️ Low stock: Saffron (estimated 3 batches remaining)',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.access_time, color: kOrange, size: 18),
                SizedBox(width: 8),
                Text(
                  'Live KOT Panel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _kots.length,
            itemBuilder: (ctx, i) => _KotCard(kot: _kots[i]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;
  const _StatCard(this.stat);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            stat['icon'] as IconData,
            color: stat['color'] as Color,
            size: 18,
          ),
          Text(
            stat['value'] as String,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            stat['label'] as String,
            style: const TextStyle(fontSize: 9, color: kGrey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  final String text;
  const _InsightChip(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kOrange.withOpacity(0.4)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _KotCard extends StatelessWidget {
  final Map<String, dynamic> kot;
  const _KotCard({required this.kot});
  @override
  Widget build(BuildContext context) {
    final action = kot['action'] as String;
    Color borderColor = kBorder;
    if (action == 'accepted') borderColor = kBlue;
    if (action == 'preparing') borderColor = Colors.purple;
    if (action == 'ready') borderColor = kGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                kot['id'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              StatusBadge(
                text: kot['type'] as String,
                color: kot['typeColor'] as Color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(kot['items'] as List).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'] as String,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item['qty'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: kGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${kot['time']}   ${kot['duration']}',
                  style: const TextStyle(fontSize: 11, color: kGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (kot['chef'] != null) ...[
            const SizedBox(height: 4),
            Text('Chef: ${kot['chef']}', style: const TextStyle(fontSize: 11)),
            Text(
              'Type: ${kot['chefType']}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            if (kot['accepted'] != null)
              Text(
                'Accepted: ${kot['accepted']}',
                style: const TextStyle(fontSize: 11),
              ),
            if (kot['prepStart'] != null)
              Text(
                'Prep Start: ${kot['prepStart']}',
                style: const TextStyle(fontSize: 11),
              ),
            if (kot['completed'] != null)
              Text(
                'Completed: ${kot['completed']}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                kot['status'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: kot['statusColor'] as Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (action == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          if (action == 'accepted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start Preparation'),
              ),
            ),
          if (action == 'preparing')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Mark Ready'),
              ),
            ),
          if (action == 'ready')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '✅  Ready for pickup',
                  style: TextStyle(color: kGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 3. CATERING ORDERS SCREEN ────────────────────────────────────────────────
// On mobile this becomes a single-pane master/detail flow:
// tapping an order in the list pushes a detail page instead of a side panel.
class CateringOrdersScreen extends StatefulWidget {
  const CateringOrdersScreen({super.key});
  @override
  State<CateringOrdersScreen> createState() => _CateringOrdersScreenState();
}

class _CateringOrdersScreenState extends State<CateringOrdersScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'client': 'Rajesh Corp Pvt Ltd',
      'event': 'Corporate Lunch',
      'date': '10 Mar',
      'time': '12:00 PM',
      'guests': 120,
      'status': 'accepted',
      'statusColor': kGreen,
      'menuItems': [
        'Chicken Biryani',
        'Paneer Masala',
        'Dal',
        'Naan',
        'Gulab Jamun',
      ],
      'fullDate': '10 March 2026',
    },
    {
      'client': 'Meera Sharma',
      'event': 'Birthday Party',
      'date': '12 Mar',
      'time': '7:00 PM',
      'guests': 80,
      'status': 'pending',
      'statusColor': Colors.amber,
      'menuItems': ['Veg Biryani', 'Paneer Tikka', 'Naan', 'Gulab Jamun'],
      'fullDate': '12 March 2026',
    },
    {
      'client': 'Tech Solutions Inc',
      'event': 'Team Dinner',
      'date': '15 Mar',
      'time': '8:00 PM',
      'guests': 50,
      'status': 'scheduled',
      'statusColor': kBlue,
      'menuItems': ['Dal Tadka', 'Roti', 'Raita', 'Kheer'],
      'fullDate': '15 March 2026',
    },
    {
      'client': 'Anil Kapoor',
      'event': 'Wedding Reception',
      'date': '20 Mar',
      'time': '6:00 PM',
      'guests': 300,
      'status': 'pending',
      'statusColor': Colors.amber,
      'menuItems': [
        'Chicken Biryani',
        'Paneer Butter Masala',
        'Tandoori Chicken',
        'Naan',
        'Dal Makhani',
        'Gulab Jamun',
      ],
      'fullDate': '20 March 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catering Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_today, size: 14),
                      label: const Text(
                        'Calendar',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kDark,
                        side: const BorderSide(color: kBorder),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const AIInsightBanner(
          text:
              'Wedding Reception (March 20) — recommend starting prep 6 hours before. High complexity menu with 300 guests.',
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final o = _orders[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _CateringOrderDetailPage(order: o),
                    ),
                  );
                },
                title: Text(
                  o['client'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o['event'] as String,
                      style: const TextStyle(fontSize: 11, color: kGrey),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      children: [
                        _MetaItem(Icons.calendar_today, o['date'] as String),
                        _MetaItem(Icons.access_time, o['time'] as String),
                        _MetaItem(Icons.people, '${o['guests']}'),
                      ],
                    ),
                  ],
                ),
                trailing: StatusBadge(
                  text: o['status'] as String,
                  color: o['statusColor'] as Color,
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: kGrey),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 10, color: kGrey)),
      ],
    );
  }
}

class _CateringOrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const _CateringOrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        title: const Text('Order Details', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['event'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order['client'] as String,
                        style: const TextStyle(color: kGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  text: order['status'] as String,
                  color: order['statusColor'] as Color,
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Detail cards — 2 columns on mobile instead of 4-in-a-row
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.7,
              children: [
                _DetailCard(
                  Icons.calendar_today,
                  'Date',
                  order['fullDate'] as String,
                ),
                _DetailCard(Icons.access_time, 'Time', order['time'] as String),
                _DetailCard(Icons.people, 'Guests', '${order['guests']} pax'),
                _DetailCard(
                  Icons.restaurant_menu,
                  'Menu Items',
                  '${(order['menuItems'] as List).length} items',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Menu Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (order['menuItems'] as List)
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item as String,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OrangeButton(
                    label: 'Schedule Preparation',
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OrangeButton(
                    label: 'Send to Preparation',
                    icon: Icons.send,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailCard(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kOrange, size: 18),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, color: kGrey)),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 4. QUANTITY CHART SCREEN ─────────────────────────────────────────────────
// Table rows are rewritten as cards so they never overflow a phone's width.
class QuantityChartScreen extends StatelessWidget {
  const QuantityChartScreen({super.key});

  static final _entries = [
    {
      'date': '6 Mar',
      'category': 'Biryani',
      'name': 'Chicken Biryani',
      'plates': 120,
    },
    {
      'date': '6 Mar',
      'category': 'Biryani',
      'name': 'Veg Biryani',
      'plates': 80,
    },
    {
      'date': '6 Mar',
      'category': 'Curries',
      'name': 'Paneer Butter Masala',
      'plates': 60,
    },
    {
      'date': '6 Mar',
      'category': 'Starters',
      'name': 'Tandoori Chicken',
      'plates': 40,
    },
    {
      'date': '6 Mar',
      'category': 'Curries',
      'name': 'Dal Tadka',
      'plates': 100,
    },
    {
      'date': '7 Mar',
      'category': 'Biryani',
      'name': 'Chicken Biryani',
      'plates': 150,
    },
    {'date': '7 Mar', 'category': 'Curries', 'name': 'Dal Tadka', 'plates': 90},
    {'date': '7 Mar', 'category': 'Breads', 'name': 'Naan', 'plates': 200},
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final e in _entries) {
      grouped.putIfAbsent(e['date'] as String, () => []).add(e);
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart, color: kOrange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Quantity Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OrangeButton(
                  label: '+ Add Entry',
                  onTap: () => _showAddDialog(context),
                ),
              ),
            ],
          ),
        ),
        const AIInsightBanner(
          text:
              "Based on last week's trends, predicted demand for Chicken Biryani tomorrow is ~150 plates (+25% vs today).",
        ),
        Expanded(
          child: ListView(
            children: grouped.entries.map((entry) {
              final total = entry.value.fold(
                0,
                (sum, e) => sum + (e['plates'] as int),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Fri, ${entry.key}, 2026',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          'Total: $total plates',
                          style: const TextStyle(color: kGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.map(
                    (item) => Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['category'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: kGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item['plates']} plates',
                            style: const TextStyle(
                              color: kOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: kGrey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.delete,
                              size: 16,
                              color: kRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: kBorder),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text(
          'Add Quantity Entry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: '26-06-2026',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kOrange),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today, size: 16),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        hintText: 'e.g. Biryani',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'e.g. Chicken Biryani',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Plates',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kOrange),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kGrey)),
          ),
          OrangeButton(label: 'Add Entry', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// ─── 5. PREPARATION CHART SCREEN ──────────────────────────────────────────────
// Table rows rewritten as cards; fixed-width columns removed.
class PreparationChartScreen extends StatelessWidget {
  const PreparationChartScreen({super.key});

  static final _entries = [
    {
      'date': '6 Mar',
      'category': 'Biryani',
      'name': 'Chicken Biryani',
      'orderType': 'catering',
      'qty': '120 plates',
      'chef': 'Chef Ramesh',
      'status': 'pending',
      'start': '—',
      'completion': '—',
    },
    {
      'date': '6 Mar',
      'category': 'Curries',
      'name': 'Paneer Butter Masala',
      'orderType': 'dine-in',
      'qty': '60 plates',
      'chef': 'Chef Priya',
      'status': 'preparing',
      'start': '8:00 AM',
      'completion': '—',
    },
    {
      'date': '6 Mar',
      'category': 'Curries',
      'name': 'Dal Tadka',
      'orderType': 'delivery',
      'qty': '100 plates',
      'chef': 'Chef Suresh',
      'status': 'prepared',
      'start': '7:30 AM',
      'completion': '9:15 AM',
    },
    {
      'date': '6 Mar',
      'category': 'Starters',
      'name': 'Tandoori Chicken',
      'orderType': 'takeaway',
      'qty': '40 plates',
      'chef': 'Chef Ramesh',
      'status': 'pending',
      'start': '—',
      'completion': '—',
    },
    {
      'date': '6 Mar',
      'category': 'Breads',
      'name': 'Naan',
      'orderType': 'table',
      'qty': '200 pcs',
      'chef': 'Chef Akbar',
      'status': 'preparing',
      'start': '8:30 AM',
      'completion': '—',
    },
  ];

  static const _rawMaterials = [
    {'ingredient': 'Paneer', 'qty': '15 kg'},
    {'ingredient': 'Butter', 'qty': '3 kg'},
    {'ingredient': 'Chicken', 'qty': '36 kg'},
    {'ingredient': 'Basmati Rice', 'qty': '30 kg'},
    {'ingredient': 'Dal (Yellow)', 'qty': '20 kg'},
  ];

  Color _statusColor(String s) {
    if (s == 'prepared') return kGreen;
    if (s == 'preparing') return kBlue;
    return Colors.amber;
  }

  Color _orderTypeColor(String t) {
    if (t == 'catering') return kOrange;
    if (t == 'dine-in') return kGreen;
    if (t == 'delivery') return kBlue;
    if (t == 'takeaway') return Colors.purple;
    return kGrey;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment, color: kOrange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Preparation Chart — 6 Mar 2026',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => _BulkCalculatorDialog(
                            itemName: 'Chicken Biryani',
                          ),
                        ),
                        icon: const Icon(Icons.calculate, size: 14),
                        label: const Text(
                          'Bulk Calc',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kDark,
                          side: const BorderSide(color: kBorder),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OrangeButton(
                        label: '+ Add Entry',
                        onTap: () => _showAddDialog(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._entries.map(
            (e) => Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${e['date']} • ${e['category']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: kGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            text: e['orderType']!,
                            color: _orderTypeColor(e['orderType']!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 14,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            e['qty']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Chef: ${e['chef']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(
                                text: e['status']!,
                                color: _statusColor(e['status']!),
                              ),
                              if (e['status'] == 'prepared') ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Icon(
                                    Icons.notifications,
                                    size: 14,
                                    color: kOrange,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: kBorder),
              ],
            ),
          ),
          // Raw Material
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('📦', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Raw Material Requirement (Today)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OrangeButton(
                            label: 'Send to Inventory',
                            icon: Icons.send,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: kBorder),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ingredient',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          'Required Quantity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: kBorder),
                  ..._rawMaterials.map(
                    (r) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r['ingredient']!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                r['qty']!,
                                style: const TextStyle(
                                  color: kOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: kBorder),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text(
          'Add Preparation Entry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        hintText: 'e.g. Biryani',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'e.g. Chicken Biryani',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Required Quantity',
                        hintText: 'e.g. 120 plates',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: 'dine-in',
                      decoration: InputDecoration(
                        labelText: 'Order Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'dine-in',
                          child: Text('dine-in'),
                        ),
                        DropdownMenuItem(
                          value: 'delivery',
                          child: Text('delivery'),
                        ),
                        DropdownMenuItem(
                          value: 'takeaway',
                          child: Text('takeaway'),
                        ),
                        DropdownMenuItem(
                          value: 'catering',
                          child: Text('catering'),
                        ),
                        DropdownMenuItem(value: 'table', child: Text('table')),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Assigned Chef',
                        hintText: 'e.g. Chef Ramesh',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: '06-03-2026',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kOrange),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kGrey)),
          ),
          OrangeButton(label: 'Add Entry', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// ─── 6. CHEF PERFORMANCE SCREEN ───────────────────────────────────────────────
class ChefPerformanceScreen extends StatelessWidget {
  const ChefPerformanceScreen({super.key});

  static const _chefs = [
    {
      'name': 'Chef Ramesh Kumar',
      'score': 94,
      'badge': 'Gold Chef',
      'type': 'North Indian Chef',
      'accepted': 1247,
      'completed': 1220,
      'avgTime': '22 min',
      'delays': 15,
      'cancelled': 3,
      'efficiency': '92%',
      'rating': 4.8,
    },
    {
      'name': 'Chef Priya Nair',
      'score': 97,
      'badge': 'Gold Chef',
      'type': 'Indian Chef',
      'accepted': 1089,
      'completed': 1075,
      'avgTime': '19 min',
      'delays': 8,
      'cancelled': 1,
      'efficiency': '96%',
      'rating': 4.9,
    },
    {
      'name': 'Chef Suresh Patel',
      'score': 85,
      'badge': 'Silver Chef',
      'type': 'Indian Chef',
      'accepted': 876,
      'completed': 840,
      'avgTime': '26 min',
      'delays': 22,
      'cancelled': 5,
      'efficiency': '84%',
      'rating': 4.2,
    },
    {
      'name': 'Chef Akbar Khan',
      'score': 78,
      'badge': 'Bronze Chef',
      'type': 'Tiffin Chef',
      'accepted': 654,
      'completed': 610,
      'avgTime': '28 min',
      'delays': 30,
      'cancelled': 8,
      'efficiency': '76%',
      'rating': 3.9,
    },
  ];

  Color _badgeColor(String badge) {
    if (badge.contains('Gold')) return const Color(0xFFD97706);
    if (badge.contains('Silver')) return const Color(0xFF6B7280);
    return const Color(0xFF92400E);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.people, color: kOrange, size: 20),
                SizedBox(width: 8),
                Text(
                  'Chef Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Single column chef cards on mobile (was 2-column grid, which
          // squeezed every stat row and caused the bottom overflow).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _chefs
                  .map(
                    (chef) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ChefCard(
                        chef: chef,
                        badgeColor: _badgeColor(chef['badge'] as String),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Kitchen Reports
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: kOrange, size: 18),
                SizedBox(width: 8),
                Text(
                  'Kitchen Reports',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Kitchen Production',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final entry in [
                          {'day': 'Mon', 'val': 90},
                          {'day': 'Tue', 'val': 105},
                          {'day': 'Wed', 'val': 98},
                          {'day': 'Thu', 'val': 115},
                          {'day': 'Fri', 'val': 140},
                          {'day': 'Sat', 'val': 165},
                          {'day': 'Sun', 'val': 135},
                        ])
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: (entry['val'] as int) * 0.7,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kOrange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry['day'] as String,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: kGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Pie chart placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dish-wise Production (%)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _LegendChip('Biryani', '35%', kOrange),
                      _LegendChip('Curries', '25%', kGreen),
                      _LegendChip('Starters', '20%', kBlue),
                      _LegendChip('Breads', '12%', Colors.purple),
                      _LegendChip('Desserts', '8%', const Color(0xFFD97706)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Report cards — single column on mobile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                _ReportCard('Daily Production Report'),
                SizedBox(height: 10),
                _ReportCard('Dish-wise Production'),
                SizedBox(height: 10),
                _ReportCard('Chef Productivity Report'),
                SizedBox(height: 10),
                _ReportCard('Ingredient Consumption Report'),
                SizedBox(height: 10),
                _ReportCard('Catering Preparation Report'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ChefCard extends StatelessWidget {
  final Map<String, dynamic> chef;
  final Color badgeColor;
  const _ChefCard({required this.chef, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    final rating = chef['rating'] as double;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF3F4F6),
                child: Text('👨‍🍳', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chef['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${chef['score']}',
                style: TextStyle(
                  color: kOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chef['badge'] as String,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chef['type'] as String,
                  style: const TextStyle(color: kGrey, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatRow(
            'Accepted',
            '${chef['accepted']}',
            'Completed',
            '${chef['completed']}',
          ),
          _StatRow(
            'Avg Time',
            chef['avgTime'] as String,
            'Delays',
            '${chef['delays']}',
          ),
          _StatRow(
            'Cancelled',
            '${chef['cancelled']}',
            'Efficiency',
            chef['efficiency'] as String,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Manager Rating', style: TextStyle(fontSize: 11)),
              Text(
                '$rating/5.0',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rating / 5.0,
              color: kOrange,
              backgroundColor: kBorder,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String l1, v1, l2, v2;
  const _StatRow(this.l1, this.v1, this.l2, this.v2);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '$l1 ',
                  style: const TextStyle(fontSize: 11, color: kGrey),
                ),
                Flexible(
                  child: Text(
                    v1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  '$l2 ',
                  style: const TextStyle(fontSize: 11, color: kGrey),
                ),
                Flexible(
                  child: Text(
                    v2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label, pct;
  final Color color;
  const _LegendChip(this.label, this.pct, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $pct',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  const _ReportCard(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'View detailed report →',
            style: TextStyle(fontSize: 11, color: kOrange),
          ),
        ],
      ),
    );
  }
}
