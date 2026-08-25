import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Report&Analysis/screens/reports_screen.dart';
import '../SUB01/screens/main_screen.dart';
import '../food&beverages/AddEmployee.dart';
import '../login_screen.dart';
import '../food&beverages/subscrptions.dart';
import '../food&beverages/Account & History.dart';
import '../food&beverages/Company.dart';
import '../food&beverages/Inventory_management.dart';
import '../food&beverages/Menu_managemnet.dart';
import '../food&beverages/OrderManagementBasic.dart';
import '../food&beverages/PromotionsDiscounts.dart';
import '../food&beverages/Settings&Controls.dart';
import '../food&beverages/TableManagementPage.dart';
import '../food&beverages/chef_managemnet.dart';
import '../food&beverages/order_management.dart';
import '../food&beverages/waiter_managemnet.dart';
import 'Accountscreen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<BusinessModules> employeeModules = [];
  String planType = "BASIC"; // default
  String role = "ROLE_VENDOR"; // default role
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModulesAndPlan();
  }

  Future<void> _loadModulesAndPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final modulesStrings = prefs.getStringList('modules') ?? [];
    final plan = prefs.getStringList('planTypes') ?? ['BASIC'];
    final storedRole = prefs.getString('role') ?? 'ROLE_VENDOR';

    setState(() {
      planType = plan.contains('PREMIUM') ? 'PREMIUM' : 'BASIC';
      role = storedRole;
      employeeModules = modulesStrings
          .map(
            (e) => BusinessModules.values.firstWhere(
              (mod) => mod.toString().split('.').last == e,
              orElse: () => BusinessModules.subscription,
            ),
          )
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final menuItems = [
      {
        'icon': Icons.subscriptions_sharp,
        'title': 'Subscription',
        'page': const MainScreen1(),
        'module': BusinessModules.subscription,
      },
      {
        'icon': Icons.person,
        'title': 'Profile',
        'page': const Company(),
        'module': BusinessModules.Company,
      },
      {
        'icon': Icons.miscellaneous_services,
        'title': 'Settings & Control',
        'page': const SettingsAndControlsPage(),
        'module': BusinessModules.Settings_Controls,
      },
      {
        'icon': Icons.menu_book,
        'title': 'Menu Management',
        'page': const Menu_Managemnet(),
        'module': BusinessModules.Menu_Management,
      },
      {
        'icon': Icons.history,
        'title': 'Order Management',
        'page': const Order_management(),
        'module': BusinessModules.Order_Management,
      },
      {
        'icon': Icons.restaurant,
        'title': 'Chef Management',
        'page': const chef_management(),
        'module': BusinessModules.Chef_Management,
      },
      {
        'icon': Icons.room_service,
        'title': 'Waiter Management',
        'page': const waiter_management(),
        'module': BusinessModules.Waiter_Management,
      },
      {
        'icon': Icons.table_restaurant,
        'title': 'Table Management',
        'page': const TableManagementPage(),
        'module': BusinessModules.Table_Management,
      },
      {
        'icon': Icons.discount,
        'title': 'Promotions & Discounts',
        'page': const PromotionDiscountPage(),
        'module': BusinessModules.Promotions_Discounts,
      },
      {
        'icon': Icons.manage_accounts,
        'title': 'Accounts & History',
        'page': const AccountHistoryPage(),
        'module': BusinessModules.Account_History,
      },
      {
        'icon': Icons.inventory,
        'title': 'Inventory Management',
        'page': const premium_InventoryManagement(),
        'module': BusinessModules.Inventory_Management,
      },
      {
        'icon': Icons.report,
        'title': 'Reports & Analysis',
        'page': const ReportsScreen(),
        'module': BusinessModules.Report_Analysis,
      },
      // {
      //   'icon': Icons.history,
      //   'title': 'Order Management Basic',
      //   'page': const OrderManagementBasic(),
      //   'module': BusinessModules.Order_Management_Basic,
      // },
    ];
    final visibleMenuItems = menuItems.where((item) {
      final module = item['module'] as BusinessModules;

      // ----------------------------
      // VENDOR LOGIC (NO CHANGE)
      // ----------------------------
      if (role == "ROLE_VENDOR") {
        if (planType == "PREMIUM" &&
            module == BusinessModules.Order_Management_Basic)
          return false;

        if (planType == "BASIC" &&
            (module == BusinessModules.Inventory_Management ||
                module == BusinessModules.Chef_Management ||
                module == BusinessModules.Waiter_Management ||
                module == BusinessModules.Order_Management))
          return false;

        return true;
      }

      // ----------------------------
      // EMPLOYEE LOGIC (FIXED)
      // SHOW ONLY ASSIGNED MODULES
      // ----------------------------
      return employeeModules.contains(module);
    }).toList();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              itemCount: visibleMenuItems.length,
              itemBuilder: (context, index) {
                final item = visibleMenuItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: Colors.black,
                      size: 20,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    onTap: () {
                      final module = item['module'] as BusinessModules;

                      if (module == BusinessModules.Order_Management ||
                          module == BusinessModules.Order_Management_Basic) {
                        // Navigate based on plan type
                        if (planType == "PREMIUM") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Order_management(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderManagementBasic(),
                            ),
                          );
                        }
                      } else {
                        // Default navigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => item['page'] as Widget,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.restaurant_menu,
              size: 120,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A0947),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "MAAMAA'S",
                  style: TextStyle(
                    color: Color(0xFF2A0947),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Admin Panel - $planType Plan",
                  style: TextStyle(
                    color: const Color(0xFF2A0947).withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role == "ROLE_VENDOR" ? "Vendor User" : "Employee User",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "admin@maamaas.com",
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black.withOpacity(0.7)),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage1()),
            ),
          ),
        ],
      ),
    );
  }
}
