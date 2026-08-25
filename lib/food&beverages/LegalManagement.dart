import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LegalManagement extends StatefulWidget {
  final bool isMobile;

  const LegalManagement({Key? key, this.isMobile = false}) : super(key: key);

  @override
  State<LegalManagement> createState() => _LegalManagementState();
}

class _LegalManagementState extends State<LegalManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> _tabs = [
    Tab(child: Text('Privacy & Policy', style: TextStyle(fontSize: 12))),
    Tab(child: Text('Terms & Conditions', style: TextStyle(fontSize: 12))),
    Tab(child: Text('Guidelines', style: TextStyle(fontSize: 12))),
    Tab(child: Text('Compliance', style: TextStyle(fontSize: 12))),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isMobile || MediaQuery.of(context).size.width < 768;

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
          'Legal & Compliance',
          style: TextStyle(
            color: Color(0xFF2A0947),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFA055B0),
              ),
              isScrollable: true,
              padding: const EdgeInsets.all(4),
              labelPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 10,
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PrivacyPolicyTab(isMobile: isMobile),
          TermsConditionsTab(isMobile: isMobile),
          VendorGuidelinesTab(isMobile: isMobile),
          ComplianceStatusTab(isMobile: isMobile),
        ],
      ),
    );
  }
}

// Privacy Policy Tab - Fixed for mobile
class PrivacyPolicyTab extends StatelessWidget {
  final bool isMobile;

  const PrivacyPolicyTab({Key? key, required this.isMobile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed header layout
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.shieldAlt,
                  color: const Color(0xFF2e7d32),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Food & Beverages Vendor Data Protection',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2e7d32),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Food Safety & Ingredient Data Collection
          _buildContentCard(
            title: '🍽️ Food Safety & Ingredient Data Collection',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListItem(
                  'Temperature Monitoring: We collect and secure temperature logs for refrigeration and cooking equipment to ensure food safety compliance.',
                ),
                _buildListItem(
                  'Ingredient Sourcing: Detailed information about ingredient suppliers, batch numbers, and expiration dates are securely stored.',
                ),
                _buildListItem(
                  'Preparation Protocols: Food preparation methods, cooking times, and handling procedures are documented with strict access controls.',
                ),
              ],
            ),
          ),

          // Allergy & Dietary Restriction Management
          _buildContentCard(
            title: '🚫 Allergy & Dietary Restriction Management',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListItem(
                  'Customer Allergy Profiles: We implement zero-knowledge encryption for sensitive allergy information.',
                ),
                _buildListItem(
                  'Dietary Preferences: Vegan, vegetarian, gluten-free, and other dietary preferences are stored with explicit customer consent.',
                ),
                _buildListItem(
                  'Cross-Contamination Prevention: Our system tracks and logs allergen-free preparation zones with real-time monitoring.',
                ),
              ],
            ),
          ),

          // Customer Experience & Personalization
          _buildContentCard(
            title: '📊 Customer Experience & Personalization',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListItem(
                  'Menu Preferences: Customer food preferences, favorite dishes, and order history are analyzed with machine learning algorithms.',
                ),
                _buildListItem(
                  'Feedback Analysis: Customer reviews and feedback are processed to improve service quality.',
                ),
                _buildListItem(
                  'Loyalty Programs: Points, rewards, and special offers data is protected with bank-level security protocols.',
                ),
              ],
            ),
          ),

          // Payment & Transaction Security
          _buildContentCard(
            title: '💳 Payment & Transaction Security',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListItem(
                  'PCI-DSS Compliance: All payment information is tokenized and never stored on our servers.',
                ),
                _buildListItem(
                  'Transaction Analytics: Purchase patterns and transaction data are analyzed in aggregate form only.',
                ),
                _buildListItem(
                  'Fraud Prevention: Real-time fraud detection systems monitor transactions while maintaining customer privacy.',
                ),
              ],
            ),
          ),

          // Enhanced Security Measures - Fixed layout
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16, bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFe8f5e8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🛡️ Enhanced Security Measures',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1b5e20),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    _buildSecurityCard(
                      '🧪 Food Safety Data Encryption',
                      'All HACCP logs, temperature readings, and safety checks are encrypted using AES-256 encryption.',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityCard(
                      '📋 Regulatory Compliance Tracking',
                      'Automated tracking of FSSAI regulations, health department requirements, and food safety standards.',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityCard(
                      '👥 Staff Access Controls',
                      'Role-based access with biometric authentication for sensitive areas.',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityCard(
                      '🔄 Supply Chain Transparency',
                      'Blockchain-based tracking for ingredient sourcing with immutable records.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2e7d32),
            ),
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF2e7d32)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isMobile ? 12 : 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2e7d32),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// Terms & Conditions Tab - Fixed
class TermsConditionsTab extends StatefulWidget {
  final bool isMobile;

  const TermsConditionsTab({Key? key, required this.isMobile})
    : super(key: key);

  @override
  State<TermsConditionsTab> createState() => _TermsConditionsTabState();
}

class _TermsConditionsTabState extends State<TermsConditionsTab> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Fixed layout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA055B0), Color(0xFF8a4b9b)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Food & Beverages Vendor Agreement',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 14 : 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Terms Sections
                _buildTermsSection(
                  '1. Acceptance of Terms',
                  'Welcome to the Maamaas platform ("the Platform", "we", "us", or "our"), owned and operated by Envision Integrated TableServices Pvt. Ltd.',
                ),

                _buildTermsSection(
                  '2. Definitions',
                  'Client: An end-user who books or purchases your TableServices through the Platform.\n\n'
                      'TableServices: The specific services you are approved to offer and list on the Platform.',
                ),

                _buildTermsSection(
                  '3. Partner Account and Subscription',
                  'Access to the Platform as a Partner requires an active paid subscription. '
                      'You agree to pay the Subscription Fee as outlined during the sign-up process.',
                ),

                // More sections can be added as needed

                // Warning Notice
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16, bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFfff3cd),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFffc107), width: 4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.exclamationTriangle,
                        color: const Color(0xFF856404),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'By agreeing to these terms, you confirm you\'ve read and understood all policies.',
                          style: TextStyle(
                            color: const Color(0xFF856404),
                            fontWeight: FontWeight.bold,
                            fontSize: widget.isMobile ? 12 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Agreement Checkbox
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value: _agreed,
                onChanged: (value) {
                  setState(() {
                    _agreed = value ?? false;
                  });
                },
                activeColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _agreed
                          ? '✓ I agree to the Terms'
                          : 'I agree to the Terms',
                      style: TextStyle(
                        fontSize: widget.isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: _agreed ? const Color(0xFF2e7d32) : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _agreed
                          ? 'You have agreed to all terms'
                          : 'You must agree before proceeding',
                      style: TextStyle(
                        color: _agreed ? const Color(0xFF4CAF50) : Colors.grey,
                        fontSize: 12,
                      ),
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

  Widget _buildTermsSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: widget.isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA055B0),
            ),
          ),
          const Divider(color: Color(0xFFA055B0), thickness: 2, height: 8),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: widget.isMobile ? 12 : 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// Vendor Guidelines Tab - Fixed
class VendorGuidelinesTab extends StatelessWidget {
  final bool isMobile;

  const VendorGuidelinesTab({Key? key, required this.isMobile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2e7d32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(FontAwesomeIcons.utensils, color: Colors.white, size: 24),
                const SizedBox(height: 12),
                Text(
                  'Food & Beverages Vendor Excellence Standards',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Food Safety & Hygiene Standards
          _buildGuidelineSection(
            title: '🍳 Food Safety & Hygiene Standards',
            color: const Color(0xFFe65100),
            children: [
              _buildSubSection(
                icon: FontAwesomeIcons.shieldAlt,
                title: 'HACCP Compliance Requirements',
                children: [
                  _buildGuidelineItem(
                    'Temperature Control: All refrigeration units must maintain temperatures below 5°C.',
                  ),
                  _buildGuidelineItem(
                    'Food Storage: Raw and cooked foods must be stored separately.',
                  ),
                  _buildGuidelineItem(
                    'Cross-Contamination Prevention: Color-coded cutting boards for different food types.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSubSection(
                icon: Icons.people,
                title: 'Staff Hygiene & Training',
                children: [
                  Column(
                    children: [
                      _buildMiniCard(
                        title: 'Personal Hygiene',
                        items: [
                          'Hand washing every 30 minutes',
                          'Clean uniforms daily',
                          'Hair restraints mandatory',
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildMiniCard(
                        title: 'Health Requirements',
                        items: [
                          'Annual medical examinations',
                          'No working with infectious diseases',
                          'Regular health declaration',
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // More sections can be added similarly...
        ],
      ),
    );
  }

  Widget _buildGuidelineSection({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFd84315), size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFd84315),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 5, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: isMobile ? 12 : 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({required String title, required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFe65100),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text('• $item', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

// Compliance Status Tab - Fixed
class ComplianceStatusTab extends StatelessWidget {
  final bool isMobile;

  const ComplianceStatusTab({Key? key, required this.isMobile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  FontAwesomeIcons.chartBar,
                  color: const Color(0xFFA055B0),
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  'Food & Beverages Compliance',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFA055B0),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: const Color(0xFFA055B0),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Overall Compliance Score - Fixed layout
          _buildComplianceCard(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.chartPie,
                          color: const Color(0xFF2e7d32),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Overall Food Safety Compliance Score',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2e7d32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on comprehensive assessment',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '94%',
                        style: TextStyle(
                          fontSize: isMobile ? 32 : 40,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const Text(
                        'Excellent Compliance',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '▲ 2% from last month',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  'Food Safety Standards',
                  96,
                  const Color(0xFF4CAF50),
                  FontAwesomeIcons.utensils,
                ),
                _buildProgressBar(
                  'Hygiene & Sanitation',
                  92,
                  const Color(0xFF2196F3),
                  FontAwesomeIcons.shieldAlt,
                ),
                _buildProgressBar(
                  'Quality Control',
                  91,
                  const Color(0xFFFF9800),
                  FontAwesomeIcons.star,
                ),
                _buildProgressBar(
                  'Operational Excellence',
                  88,
                  const Color(0xFF9C27B0),
                  FontAwesomeIcons.clipboardCheck,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProgressBar(
    String title,
    int percentage,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
