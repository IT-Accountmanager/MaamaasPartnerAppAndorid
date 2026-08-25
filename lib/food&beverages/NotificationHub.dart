import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationHub extends StatefulWidget {
  final bool isMobile;

  const NotificationHub({Key? key, this.isMobile = false}) : super(key: key);

  @override
  State<NotificationHub> createState() => _NotificationHubState();
}

class _NotificationHubState extends State<NotificationHub> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isMobile || MediaQuery.of(context).size.width < 768;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2A0947), size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notification Hub',
          style: TextStyle(
            color: Color(0xFF2A0947),
            fontSize: isMobile ? 22 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(30),
                isSelected: [
                  _selectedIndex == 0,
                  _selectedIndex == 1,
                  _selectedIndex == 2,
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                color: Colors.grey[600],
                selectedColor: Colors.white,
                fillColor: Color(0xFFA055B0),
                borderColor: Colors.grey[300],
                selectedBorderColor: Color(0xFFA055B0),
                constraints: BoxConstraints(
                  minHeight: 40,
                  minWidth: isMobile ? 90 : 120,
                ),
                children: [
                  _buildToggleItem(FontAwesomeIcons.sms, 'SMS'),
                  _buildToggleItem(
                    FontAwesomeIcons.exclamationTriangle,
                    'Alerts',
                  ),
                  _buildToggleItem(FontAwesomeIcons.history, 'History'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 8),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            SMSSettingsTab(isMobile: isMobile),
            CustomAlertsTab(isMobile: isMobile),
            NotificationHistoryTab(isMobile: isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// SMS Settings Tab - COMPLETE FIXED VERSION
class SMSSettingsTab extends StatefulWidget {
  final bool isMobile;

  const SMSSettingsTab({Key? key, required this.isMobile}) : super(key: key);

  @override
  State<SMSSettingsTab> createState() => _SMSSettingsTabState();
}

class _SMSSettingsTabState extends State<SMSSettingsTab> {
  bool _enabled = true;
  bool _lowStockAlerts = true;
  bool _highValueOrders = true;
  bool _orderConfirmation = false;
  bool _paymentUpdates = true;
  bool _criticalAlerts = true;
  bool _dailySummary = false;
  String _phoneNumber = "+91 9876543210";
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = _phoneNumber;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(FontAwesomeIcons.sms, color: Color(0xFFA055B0), size: 24),
                SizedBox(width: 12),
                Text(
                  'SMS Notification Settings',
                  style: TextStyle(
                    fontSize: widget.isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A0947),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Configure SMS alerts for your business',
              style: TextStyle(
                fontSize: widget.isMobile ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),

            // SMS Toggle Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SMS Notifications',
                              style: TextStyle(
                                fontSize: widget.isMobile ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _enabled
                                  ? 'SMS alerts are currently active'
                                  : 'SMS alerts are disabled',
                              style: TextStyle(
                                fontSize: widget.isMobile ? 13 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _enabled,
                        onChanged: (value) {
                          setState(() {
                            _enabled = value;
                          });
                        },
                        activeColor: Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Phone Number Section - Only show if enabled
            if (_enabled) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.mobileAlt,
                          color: Color(0xFF2196F3),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Phone Number for SMS Alerts',
                          style: TextStyle(
                            fontSize: widget.isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFf0f8ff),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Primary Contact Number',
                            style: TextStyle(
                              fontSize: widget.isMobile ? 14 : 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  onChanged: (value) {
                                    setState(() {
                                      _phoneNumber = value;
                                    });
                                  },
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Enter phone number with country code',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(12),
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  if (_phoneNumber.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please enter a phone number',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  // Update phone number
                                  setState(() {
                                    _phoneNumber = _phoneController.text;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Phone number updated successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2196F3),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.exclamationTriangle,
                                size: 14,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Standard SMS rates may apply. For international numbers, check with your carrier.',
                                  style: TextStyle(
                                    fontSize: widget.isMobile ? 12 : 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Alert Types Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select SMS Alert Types',
                      style: TextStyle(
                        fontSize: widget.isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Choose which alerts should be sent via SMS',
                      style: TextStyle(
                        fontSize: widget.isMobile ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: [
                        _buildAlertTypeToggle(
                          'Low Stock Alerts',
                          'Get notified when inventory is running low',
                          _lowStockAlerts,
                          (value) => setState(() => _lowStockAlerts = value),
                          Color(0xFF4CAF50),
                        ),
                        SizedBox(height: 12),
                        _buildAlertTypeToggle(
                          'High-Value Orders',
                          'Alerts for orders above ₹5,000',
                          _highValueOrders,
                          (value) => setState(() => _highValueOrders = value),
                          Color(0xFF2196F3),
                        ),
                        SizedBox(height: 12),
                        _buildAlertTypeToggle(
                          'Order Confirmations',
                          'SMS for every new order received',
                          _orderConfirmation,
                          (value) => setState(() => _orderConfirmation = value),
                          Color(0xFF9C27B0),
                        ),
                        SizedBox(height: 12),
                        _buildAlertTypeToggle(
                          'Payment Updates',
                          'Payment received/failed notifications',
                          _paymentUpdates,
                          (value) => setState(() => _paymentUpdates = value),
                          Color(0xFFFF9800),
                        ),
                        SizedBox(height: 12),
                        _buildAlertTypeToggle(
                          'Critical Alerts',
                          'Emergency system notifications',
                          _criticalAlerts,
                          (value) => setState(() => _criticalAlerts = value),
                          Color(0xFFF44336),
                        ),
                        SizedBox(height: 12),
                        _buildAlertTypeToggle(
                          'Daily Summary',
                          'End-of-day business summary',
                          _dailySummary,
                          (value) => setState(() => _dailySummary = value),
                          Color(0xFF607D8B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],

            // Save Button
            Center(
              child: Container(
                width: widget.isMobile ? double.infinity : 400,
                child: ElevatedButton(
                  onPressed: () {
                    // Save all settings
                    final settings = {
                      'enabled': _enabled,
                      'phoneNumber': _phoneNumber,
                      'lowStockAlerts': _lowStockAlerts,
                      'highValueOrders': _highValueOrders,
                      'orderConfirmation': _orderConfirmation,
                      'paymentUpdates': _paymentUpdates,
                      'criticalAlerts': _criticalAlerts,
                      'dailySummary': _dailySummary,
                    };

                    print('Saving SMS settings: $settings');

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('SMS settings saved successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: widget.isMobile ? 16 : 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.checkCircle,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Save SMS Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTypeToggle(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_getIconForAlertType(title), color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: widget.isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: value ? Colors.black87 : Colors.grey[500],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: widget.isMobile ? 12 : 13,
                    color: value ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }

  IconData _getIconForAlertType(String title) {
    switch (title) {
      case 'Low Stock Alerts':
        return FontAwesomeIcons.box;
      case 'High-Value Orders':
        return FontAwesomeIcons.rupeeSign;
      case 'Order Confirmations':
        return FontAwesomeIcons.shoppingCart;
      case 'Payment Updates':
        return FontAwesomeIcons.moneyBillWave;
      case 'Critical Alerts':
        return FontAwesomeIcons.exclamationTriangle;
      case 'Daily Summary':
        return FontAwesomeIcons.chartBar;
      default:
        return FontAwesomeIcons.bell;
    }
  }
}

// Custom Alerts Tab - COMPLETELY FIXED VERSION
class CustomAlertsTab extends StatefulWidget {
  final bool isMobile;

  const CustomAlertsTab({Key? key, required this.isMobile}) : super(key: key);

  @override
  State<CustomAlertsTab> createState() => _CustomAlertsTabState();
}

class _CustomAlertsTabState extends State<CustomAlertsTab> {
  // Alert configurations
  Map<String, Map<String, dynamic>> _alerts = {
    'lowStock': {
      'enabled': true,
      'threshold': 10,
      'notifyViaSms': true,
      'notifyViaPush': true,
      'notifyViaEmail': true,
      'category': 'inventory',
      'frequency': 'immediate',
    },
    'highValueOrders': {
      'enabled': true,
      'threshold': 5000,
      'notifyViaSms': true,
      'notifyViaPush': true,
      'notifyViaEmail': false,
      'category': 'orders',
      'frequency': 'immediate',
    },
    'newOrders': {
      'enabled': false,
      'threshold': 0,
      'notifyViaSms': false,
      'notifyViaPush': true,
      'notifyViaEmail': false,
      'category': 'orders',
      'frequency': 'immediate',
    },
    'customerReviews': {
      'enabled': true,
      'ratingThreshold': 3.0,
      'notifyViaSms': false,
      'notifyViaPush': false,
      'notifyViaEmail': true,
      'category': 'reviews',
      'frequency': 'daily',
    },
    'paymentReceived': {
      'enabled': true,
      'threshold': 0,
      'notifyViaSms': true,
      'notifyViaPush': true,
      'notifyViaEmail': true,
      'category': 'payments',
      'frequency': 'immediate',
    },
  };

  void _toggleAlert(String alertType) {
    setState(() {
      _alerts[alertType]!['enabled'] = !_alerts[alertType]!['enabled'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = widget.isMobile || screenWidth < 768;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use a fixed height container with a ListView for the grid
            Container(
              height: isMobile ? 650 : 400, // Fixed height based on screen size
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isMobile ? 1.8 : 1.5, // Adjusted ratio
                  mainAxisExtent: isMobile
                      ? 180
                      : 200, // OR use this instead of childAspectRatio
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final alertsList = [
                    {
                      'id': 'lowStock',
                      'title': 'Low Stock Alert',
                      'description':
                          'Get notified when inventory is running low',
                      'icon': FontAwesomeIcons.box,
                      'color': Color(0xFF4CAF50),
                    },
                    {
                      'id': 'highValueOrders',
                      'title': 'High-Value Orders',
                      'description': 'Alerts for orders above specific value',
                      'icon': FontAwesomeIcons.rupeeSign,
                      'color': Color(0xFF2196F3),
                    },
                    {
                      'id': 'newOrders',
                      'title': 'New Orders',
                      'description': 'Alerts for every new order received',
                      'icon': FontAwesomeIcons.shoppingCart,
                      'color': Color(0xFF2196F3),
                    },
                    {
                      'id': 'customerReviews',
                      'title': 'Customer Reviews',
                      'description': 'Alerts for critical customer reviews',
                      'icon': FontAwesomeIcons.star,
                      'color': Color(0xFFFF9800),
                    },
                    {
                      'id': 'paymentReceived',
                      'title': 'Payment Received',
                      'description': 'Alerts for successful payments',
                      'icon': FontAwesomeIcons.rupeeSign,
                      'color': Color(0xFF4CAF50),
                    },
                  ][index];

                  final alertId = alertsList['id'] as String;
                  final alertData = _alerts[alertId]!;
                  final enabled = alertData['enabled'] as bool;
                  final color = alertsList['color'] as Color;

                  // SIMPLIFIED CARD WIDGET - NO COLUMN OVERFLOW
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Header section with icon and title
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    alertsList['icon'] as IconData,
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    alertsList['title'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Switch(
                                  value: enabled,
                                  onChanged: (_) => _toggleAlert(alertId),
                                  activeColor: color,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Description text positioned below header
                        Positioned(
                          top: 68, // Adjusted based on header height
                          left: 16,
                          right: 16,
                          child: Text(
                            alertsList['description'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Status indicator at bottom
                        if (enabled)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.checkCircle,
                                    size: 14,
                                    color: color,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Alert active',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Save Button - OUTSIDE the GridView container
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All alert configurations saved successfully!',
                      ),
                      backgroundColor: Color(0xFFA055B0),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA055B0),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 24 : 32,
                    vertical: widget.isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.checkCircle,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Save All Alert Configurations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Notification History Tab - Fixed
class NotificationHistoryTab extends StatelessWidget {
  final bool isMobile;

  const NotificationHistoryTab({Key? key, required this.isMobile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Summary - Horizontal scroll for mobile
          Container(
            height: isMobile ? 120 : 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatCard(
                  '12',
                  'Total Notifications',
                  Color(0xFF2e7d32),
                  Color(0xFFe8f5e9),
                ),
                SizedBox(width: 12),
                _buildStatCard(
                  '3',
                  'Unread',
                  Color(0xFFe65100),
                  Color(0xFFfff3e0),
                ),
                SizedBox(width: 12),
                _buildStatCard(
                  '8',
                  'SMS Notifications',
                  Color(0xFF1565c0),
                  Color(0xFFe3f2fd),
                ),
                SizedBox(width: 12),
                _buildStatCard(
                  '5',
                  'Stock Alerts',
                  Color(0xFF7b1fa2),
                  Color(0xFFf3e5f5),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Filters
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.filter,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Filter by:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 12),
                        child: Row(
                          children:
                              [
                                'All',
                                'Stock',
                                'Order',
                                'Payment',
                                'System',
                              ].map((type) {
                                return Container(
                                  margin: EdgeInsets.only(right: 8),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: type == 'All'
                                        ? Color(0xFFA055B0)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: type == 'All'
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.search,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search notifications...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.sortAmountDown,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Newest',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Notifications List
          Column(
            children: List.generate(6, (index) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              FontAwesomeIcons.box,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Low Stock Alert',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'HIGH',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Paneer Tikka is running low (5 items left)',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '2024-03-20 14:30:00',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Color(0xFF2196F3)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Read',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2196F3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Color(0xFFf44336)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFf44336),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    Color bgColor,
  ) {
    return Container(
      width: isMobile ? 120 : 140,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
