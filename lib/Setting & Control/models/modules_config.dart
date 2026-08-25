import '../models/models.dart';

const List<ModuleDef> kModulesConfig = [
  ModuleDef(backendName: 'DASHBOARD', displayName: 'Dashboard', order: 1),
  ModuleDef(
    backendName: 'BUSINESS_PROFILE',
    displayName: 'Business Profile',
    order: 2,
    subModules: [
      SubModuleDef(backendName: 'ABOUT_US', displayName: 'About Us'),
    ],
  ),
  ModuleDef(
    backendName: 'SETTINGS_CONTROLS',
    displayName: 'Settings & Controls',
    order: 3,
    subModules: [
      SubModuleDef(backendName: 'GENERAL_SETTINGS', displayName: 'General'),
      SubModuleDef(
        backendName: 'ROLES_CONTROLS',
        displayName: 'Roles & Controls',
      ),
      SubModuleDef(
        backendName: 'BILLING_SETTINGS',
        displayName: 'Billing Settings',
      ),
    ],
  ),
  ModuleDef(
    backendName: 'PRODUCTS_PRICES',
    displayName: 'Products & Prices',
    order: 4,
  ),
  ModuleDef(
    backendName: 'ORDER_MANAGEMENT',
    displayName: 'Order Management',
    order: 5,
    subModules: [
      SubModuleDef(backendName: 'MENU', displayName: 'Menu'),
      SubModuleDef(backendName: 'STOCK', displayName: 'Stock'),
      SubModuleDef(backendName: 'STATUS', displayName: 'Status'),
      SubModuleDef(backendName: 'HISTORY', displayName: 'History'),
      SubModuleDef(
        backendName: 'MENU_MANAGEMENT',
        displayName: 'Menu Management',
      ),
    ],
  ),
  ModuleDef(
    backendName: 'TEAM_MANAGEMENT',
    displayName: 'Team Management',
    order: 6,
    subModules: [
      SubModuleDef(backendName: 'DIRECTORY', displayName: 'Directory'),
    ],
  ),
  ModuleDef(
    backendName: 'FINANCE_ACCOUNTING',
    displayName: 'Finance & Accounting',
    order: 7,
    subModules: [
      SubModuleDef(backendName: 'BALANCE_SHEET', displayName: 'Balance Sheet'),
    ],
  ),
  ModuleDef(
    backendName: 'HELP_DESK',
    displayName: 'Help Desk',
    order: 8,
    subModules: [
      SubModuleDef(backendName: 'RAISE_TICKET', displayName: 'Raise Ticket'),
      SubModuleDef(backendName: 'FAQ', displayName: 'FAQ'),
    ],
  ),
  ModuleDef(
    backendName: 'LEGAL_COMPLIANCE',
    displayName: 'Legal & Compliance',
    order: 9,
  ),
  ModuleDef(
    backendName: 'REPORTS_ANALYSIS',
    displayName: 'Reports & Analysis',
    order: 18,
    subModules: [
      SubModuleDef(backendName: 'REPORTS_OVERVIEW', displayName: 'Overview'),
      SubModuleDef(backendName: 'REPORTS_REVENUE', displayName: 'Revenue'),
      SubModuleDef(backendName: 'REPORTS_ORDERS', displayName: 'Orders'),
      SubModuleDef(backendName: 'REPORT_PAYMENTS', displayName: 'Payments'),
    ],
  ),
  ModuleDef(
    backendName: 'SUBSCRIPTION_MANAGEMENT',
    displayName: 'Subscription',
    order: 19,
  ),
];

List<ModuleDef> get kVisibleModules {
  final list = kModulesConfig.where((m) => m.showInUI).toList();
  list.sort((a, b) => a.order.compareTo(b.order));
  return list;
}
