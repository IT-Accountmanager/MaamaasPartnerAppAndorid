import 'package:flutter/material.dart';
import 'package:maamaaspartner/Api/food_authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────
enum BusinessVerticals {
  FOOD_AND_BEVERAGES,
  CATERINGS_SERVICES,
  LOGISTICS_SUPPLY,
  FRESH_GROCERIES,
  Unknown,
}

enum EmployeRole {
  Manager,
  Waiter,
  Chef_North,
  Chef_South,
  Chef_Continental,
  Chef_Chinese,
  Chef_All,
  Tea_stall,
  Snacks,
  Bakery,
}

enum BusinessModules {
  Home,
  Company,
  Settings_Controls,
  Account_History,
  Order_Management,
  Menu_Management,
  Inventory_Management,
  Chef_Management,
  Table_Management,
  Delivery_Management,
  Promotions_Discounts,
  Report_Analysis,
  Pay_outs,
  Care_Management,
  subscription,
  user_management,
  Payment_Transactions,
  Client_Management,
  Unknown,
  Order_Management_Basic,
  Waiter_Management,
  Menu_Management_Basic,
  Schedule_Orders,
  SupportScreen,
  CampaignListScreen,
  SettingsScreen,
  ChefKotScreen,
  TeamDirectoryScreen,
  FoodRegistrationScreen,
  Supportteam,
  StandardMenuScreen, WalletScreen, ReferScreen, MainShell, QuotationScreen, LeadManagementPage, VendorLeadsScreen,
}

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _A {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFB15DC6);
  static const accentDark = Color(0xFF8B3FA0);
  static const accentLight = Color(0xFFF5E8FA);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFFCCFBF1);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x14000000);
}

// ─── AddEmployeePage ──────────────────────────────────────────────────────────
class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});
  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  EmployeRole employeRole = EmployeRole.Manager;
  List<BusinessVerticals> selectedVerticals = [];
  List<BusinessModules> selectedModules = [];
  bool _isSubmitting = false;
  bool _obscurePass = true;

  String planType = 'BASIC';
  String role = 'ROLE_VENDOR';
  List<BusinessModules> employeeModules = [];
  bool isLoading = true;

  // Role metadata: icon + color
  static const _roleConfig = <EmployeRole, Map<String, dynamic>>{
    EmployeRole.Manager: {
      'icon': Icons.manage_accounts_rounded,
      'color': _A.purple,
    },
    EmployeRole.Waiter: {'icon': Icons.room_service_rounded, 'color': _A.blue},
    EmployeRole.Chef_North: {
      'icon': Icons.soup_kitchen_rounded,
      'color': _A.accent,
    },
    EmployeRole.Chef_South: {'icon': Icons.rice_bowl_rounded, 'color': _A.teal},
    EmployeRole.Chef_Continental: {
      'icon': Icons.restaurant_rounded,
      'color': _A.green,
    },
    EmployeRole.Chef_Chinese: {
      'icon': Icons.ramen_dining_rounded,
      'color': _A.amber,
    },
    EmployeRole.Chef_All: {
      'icon': Icons.lunch_dining_rounded,
      'color': _A.accentDark,
    },
    EmployeRole.Tea_stall: {
      'icon': Icons.local_cafe_rounded,
      'color': _A.amber,
    },
    EmployeRole.Snacks: {'icon': Icons.fastfood_rounded, 'color': _A.red},
    EmployeRole.Bakery: {'icon': Icons.cake_rounded, 'color': _A.purple},
  };

  static const _verticalConfig = <BusinessVerticals, Map<String, dynamic>>{
    BusinessVerticals.FOOD_AND_BEVERAGES: {
      'icon': Icons.fastfood_rounded,
      'color': _A.accent,
    },
    BusinessVerticals.CATERINGS_SERVICES: {
      'icon': Icons.restaurant_rounded,
      'color': _A.blue,
    },
    BusinessVerticals.LOGISTICS_SUPPLY: {
      'icon': Icons.local_shipping_rounded,
      'color': _A.amber,
    },
    BusinessVerticals.FRESH_GROCERIES: {
      'icon': Icons.shopping_basket_rounded,
      'color': _A.green,
    },
    BusinessVerticals.Unknown: {
      'icon': Icons.help_outline_rounded,
      'color': _A.text3,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadModulesAndPlan();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
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
              (m) => m.toString().split('.').last == e,
              orElse: () => BusinessModules.subscription,
            ),
          )
          .toList();
      isLoading = false;
    });
  }

  List<BusinessModules> getAvailableModules() {
    if (planType == 'PREMIUM') {
      return [
        BusinessModules.Home,
        BusinessModules.Company,
        BusinessModules.Settings_Controls,
        BusinessModules.Account_History,
        BusinessModules.Order_Management,
        BusinessModules.Menu_Management,
        BusinessModules.Inventory_Management,
        BusinessModules.Chef_Management,
        BusinessModules.Waiter_Management,
        BusinessModules.Table_Management,
        BusinessModules.Delivery_Management,
        BusinessModules.Promotions_Discounts,
        BusinessModules.Report_Analysis,
        BusinessModules.Pay_outs,
        BusinessModules.Care_Management,
        BusinessModules.subscription,
        BusinessModules.user_management,
        BusinessModules.Payment_Transactions,
        BusinessModules.Client_Management,
      ];
    }
    return [
      BusinessModules.Home,
      BusinessModules.Company,
      BusinessModules.Settings_Controls,
      BusinessModules.Account_History,
      BusinessModules.Order_Management_Basic,
      BusinessModules.Table_Management,
      BusinessModules.Delivery_Management,
      BusinessModules.Promotions_Discounts,
      BusinessModules.Report_Analysis,
      BusinessModules.Pay_outs,
      BusinessModules.Care_Management,
      BusinessModules.subscription,
      BusinessModules.user_management,
      BusinessModules.Payment_Transactions,
      BusinessModules.Client_Management,
      BusinessModules.Menu_Management_Basic,
    ];
  }

  // Module display label
  String _moduleLabel(BusinessModules m) {
    return m.toString().split('.').last.replaceAll('_', ' ');
  }

  // Module icon + color
  Map<String, dynamic> _moduleConfig(BusinessModules m) {
    const map = <BusinessModules, Map<String, dynamic>>{
      BusinessModules.Home: {'icon': Icons.home_rounded, 'color': _A.blue},
      BusinessModules.Company: {
        'icon': Icons.business_rounded,
        'color': _A.purple,
      },
      BusinessModules.Settings_Controls: {
        'icon': Icons.settings_rounded,
        'color': _A.text2,
      },
      BusinessModules.Account_History: {
        'icon': Icons.history_rounded,
        'color': _A.amber,
      },
      BusinessModules.Order_Management: {
        'icon': Icons.receipt_long_rounded,
        'color': _A.green,
      },
      BusinessModules.Order_Management_Basic: {
        'icon': Icons.receipt_rounded,
        'color': _A.green,
      },
      BusinessModules.Menu_Management: {
        'icon': Icons.restaurant_menu_rounded,
        'color': _A.accent,
      },
      BusinessModules.Menu_Management_Basic: {
        'icon': Icons.menu_book_rounded,
        'color': _A.accent,
      },
      BusinessModules.Inventory_Management: {
        'icon': Icons.inventory_2_rounded,
        'color': _A.teal,
      },
      BusinessModules.Chef_Management: {
        'icon': Icons.soup_kitchen_rounded,
        'color': _A.accentDark,
      },
      BusinessModules.Waiter_Management: {
        'icon': Icons.room_service_rounded,
        'color': _A.blue,
      },
      BusinessModules.Table_Management: {
        'icon': Icons.table_restaurant_rounded,
        'color': _A.purple,
      },
      BusinessModules.Delivery_Management: {
        'icon': Icons.delivery_dining_rounded,
        'color': _A.blue,
      },
      BusinessModules.Promotions_Discounts: {
        'icon': Icons.local_offer_rounded,
        'color': _A.red,
      },
      BusinessModules.Report_Analysis: {
        'icon': Icons.bar_chart_rounded,
        'color': _A.blue,
      },
      BusinessModules.Pay_outs: {
        'icon': Icons.payments_rounded,
        'color': _A.green,
      },
      BusinessModules.Care_Management: {
        'icon': Icons.support_agent_rounded,
        'color': _A.amber,
      },
      BusinessModules.subscription: {
        'icon': Icons.subscriptions_rounded,
        'color': _A.accent,
      },
      BusinessModules.user_management: {
        'icon': Icons.people_rounded,
        'color': _A.purple,
      },
      BusinessModules.Payment_Transactions: {
        'icon': Icons.credit_card_rounded,
        'color': _A.green,
      },
      BusinessModules.Client_Management: {
        'icon': Icons.person_pin_rounded,
        'color': _A.teal,
      },
    };
    return map[m] ?? {'icon': Icons.apps_rounded, 'color': _A.text3};
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedVerticals.isEmpty || selectedModules.isEmpty) {
      _snack('Please select at least one vertical and one module', _A.amber);
      return;
    }

    List<BusinessModules> backendModules = List.from(selectedModules);
    if (backendModules.contains(BusinessModules.Order_Management_Basic)) {
      backendModules.remove(BusinessModules.Order_Management_Basic);
      backendModules.add(BusinessModules.Order_Management);
    }
    if (backendModules.contains(BusinessModules.Menu_Management_Basic)) {
      backendModules.remove(BusinessModules.Menu_Management_Basic);
      backendModules.add(BusinessModules.Menu_Management);
    }

    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId');

    setState(() => _isSubmitting = true);

    final employeeData = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'mobileNumber': phoneController.text.trim(),
      'parentId': vendorId,
      'enabled': true,
      'businessVerticals': selectedVerticals.map((e) => e.name).toList(),
      'employeRole': employeRole.name,
      'businessModules': backendModules.map((e) => e.name).toList(),
      'accountNonExpired': true,
      'credentialsNonExpired': true,
      'accountNonLocked': true,
    };

    final success = await food_authservice.registerVendor(employeeData);
    setState(() => _isSubmitting = false);

    if (success) {
      _snack('Employee added successfully ✅', _A.green);
      _formKey.currentState!.reset();
      setState(() {
        selectedVerticals.clear();
        selectedModules.clear();
        employeRole = EmployeRole.Manager;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, true);
    } else {
      _snack('Failed to add employee ❌', _A.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: _A.bg,
        body: Center(
          child: CircularProgressIndicator(color: _A.accent, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _A.bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildProfileAvatar(),
                      const SizedBox(height: 20),
                      _sectionLabel(
                        'Personal Information',
                        Icons.person_rounded,
                        _A.accent,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _sectionLabel(
                        'Employee Role',
                        Icons.badge_rounded,
                        _A.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildRoleSelector(),
                      const SizedBox(height: 20),
                      _sectionLabel(
                        'Business Verticals',
                        Icons.category_rounded,
                        _A.green,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select applicable service verticals',
                        style: const TextStyle(fontSize: 11, color: _A.text2),
                      ),
                      const SizedBox(height: 12),
                      _buildVerticalsGrid(),
                      const SizedBox(height: 20),
                      _buildModulesSection(),
                    ],
                  ),
                ),
              ),
              _buildSubmitBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: _A.white,
        border: Border(bottom: BorderSide(color: _A.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _A.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _A.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _A.text1,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Employee',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _A.text1,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Fill in the details below',
                  style: TextStyle(fontSize: 11, color: _A.text2),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_A.accent, _A.accentDark],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              planType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile avatar ────────────────────────────────────────────────────────────
  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_A.accent, _A.accentDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _A.accent.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _A.green,
                shape: BoxShape.circle,
                border: Border.all(color: _A.white, width: 2),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────
  Widget _sectionLabel(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _A.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _A.border),
        boxShadow: [
          const BoxShadow(
            color: _A.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _formField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            hint: 'Enter employee name',
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          _formField(
            controller: emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            hint: 'employee@example.com',
            type: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Email is required' : null,
          ),
          const SizedBox(height: 12),
          _formField(
            controller: phoneController,
            label: 'Mobile Number',
            icon: Icons.phone_outlined,
            hint: '+91 XXXXX XXXXX',
            type: TextInputType.phone,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Mobile is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _A.text2,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: type,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(
            fontSize: 13,
            color: _A.text1,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _A.text3, fontSize: 13),
            prefixIcon: Icon(icon, color: _A.text3, size: 18),
            filled: true,
            fillColor: _A.bg,
            contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _A.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _A.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _A.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _A.red),
            ),
          ),
        ),
      ],
    );
  }

  // ── Role selector ─────────────────────────────────────────────────────────────
  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: _A.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _A.border),
        boxShadow: [
          const BoxShadow(
            color: _A.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selected role display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (_roleConfig[employeRole]?['color'] as Color? ?? _A.accent)
                      .withOpacity(0.08),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        (_roleConfig[employeRole]?['color'] as Color? ??
                                _A.accent)
                            .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _roleConfig[employeRole]?['icon'] as IconData? ??
                        Icons.person_rounded,
                    color:
                        _roleConfig[employeRole]?['color'] as Color? ??
                        _A.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Role',
                        style: TextStyle(
                          fontSize: 10,
                          color: _A.text2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        employeRole.name.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _A.text1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: _A.text3),
              ],
            ),
          ),
          const Divider(color: _A.border, height: 1),
          // Role grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EmployeRole.values.map((r) {
                final isSelected = employeRole == r;
                final color = _roleConfig[r]?['color'] as Color? ?? _A.accent;
                final icon =
                    _roleConfig[r]?['icon'] as IconData? ??
                    Icons.person_rounded;
                return GestureDetector(
                  onTap: () => setState(() => employeRole = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? color : _A.bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : _A.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          color: isSelected ? Colors.white : color,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          r.name.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : _A.text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Verticals grid ────────────────────────────────────────────────────────────
  Widget _buildVerticalsGrid() {
    final verticals = BusinessVerticals.values
        .where((v) => v != BusinessVerticals.Unknown)
        .toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _A.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _A.border),
        boxShadow: [
          const BoxShadow(
            color: _A.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: verticals.map((v) {
          final isSelected = selectedVerticals.contains(v);
          final color = _verticalConfig[v]?['color'] as Color? ?? _A.accent;
          final icon =
              _verticalConfig[v]?['icon'] as IconData? ?? Icons.apps_rounded;
          final label = v.name.replaceAll('_', ' ').replaceAll('AND', '&');
          return GestureDetector(
            onTap: () => setState(() {
              isSelected
                  ? selectedVerticals.remove(v)
                  : selectedVerticals.add(v);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? color : _A.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : _A.border,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : color,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _A.text2,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Modules section ───────────────────────────────────────────────────────────
  Widget _buildModulesSection() {
    final modules = getAvailableModules();
    final selectedCount = selectedModules.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabel('Business Modules', Icons.apps_rounded, _A.purple),
            const Spacer(),
            if (selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _A.purpleLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$selectedCount selected',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _A.purple,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Grant access to specific modules',
          style: TextStyle(fontSize: 11, color: _A.text2),
        ),
        const SizedBox(height: 12),

        // Select All / Clear All
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => selectedModules = List.from(modules)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _A.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _A.purple.withOpacity(0.2)),
                ),
                child: const Text(
                  'Select All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _A.purple,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => selectedModules.clear()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _A.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _A.border),
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _A.text2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: _A.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _A.border),
            boxShadow: [
              const BoxShadow(
                color: _A.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: modules.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              final isSelected = selectedModules.contains(m);
              final cfg = _moduleConfig(m);
              final color = cfg['color'] as Color;
              final icon = cfg['icon'] as IconData;
              final isLast = i == modules.length - 1;

              return GestureDetector(
                onTap: () => setState(() {
                  isSelected
                      ? selectedModules.remove(m)
                      : selectedModules.add(m);
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.04) : null,
                    borderRadius: isLast
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(14),
                          )
                        : i == 0
                        ? const BorderRadius.vertical(top: Radius.circular(14))
                        : null,
                    border: isSelected
                        ? Border(left: BorderSide(color: color, width: 3))
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.12) : _A.bg,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? color : _A.text3,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _moduleLabel(m),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? _A.text1 : _A.text2,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected ? color : _A.bg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? color : _A.border,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 13,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Submit bar ────────────────────────────────────────────────────────────────
  Widget _buildSubmitBar() {
    final canSubmit = !_isSubmitting;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: _A.white,
        border: Border(top: BorderSide(color: _A.border)),
      ),
      child: GestureDetector(
        onTap: canSubmit ? _submitForm : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_A.accent, _A.accentDark]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _A.accent.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _isSubmitting
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add Employee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
