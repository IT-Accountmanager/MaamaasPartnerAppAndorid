
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login_screen.dart';
import '../../widgets_helper/Home_screen_1.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _cBg = Color(0xFFF7F8FC);
const _cWhite = Color(0xFFFFFFFF);
const _cBorder = Color(0xFFEEEFF5);
const _cText1 = Color(0xFF111827);
const _cText2 = Color(0xFF6B7280);
const _cShadow = Color(0x0A000000);
const _cAccent = Color(0xFFE66D33);
const _cGreen = Color(0xFF10B981);
const _cBlue = Color(0xFF3B82F6);
const _cPurple = Color(0xFF8B5CF6);

class FoodVendorDashboard extends StatelessWidget {
  final Map<String, dynamic> vendorData;
  const FoodVendorDashboard({super.key, required this.vendorData});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _cBg,
      // ── AppBar handles status bar — NO SafeArea on body needed ───────────────
      appBar: AppBar(
        backgroundColor: _cWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => _navigateToHome(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cBorder),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: _cText1,
            ),
          ),
        ),
        title: const Text(
          'Vendor Dashboard',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _cText1,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _cBorder),
        ),
      ),

      // ── body: NO SafeArea needed — AppBar covers top ──────────────────────────
      body: SingleChildScrollView(
        // MediaQuery bottom padding clears home indicator on scroll end
        padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            _buildBannerSection(),
            _buildStatsSection(context),
            _buildBusinessInfoCard(),
            _buildContactInfoCard(),
            _buildDocumentsCard(),
            _buildBankInfoCard(),
          ],
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeWrapper()),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────────────
  Widget _buildBannerSection() {
    final registeredName = vendorData['registeredName'] ?? 'Vendor Name';
    final approvalRemarks = vendorData['approvalRemarks'] ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE66D33), Color(0xFFFF8A50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _cAccent.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),


          Text(
            registeredName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Approval badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _cWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: _cGreen, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'Approved',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _cGreen,
                  ),
                ),
                if (approvalRemarks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 12,
                    color: const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    approvalRemarks,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _cText2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────
  Widget _buildStatsSection(BuildContext context) {
    final createdAt = vendorData['createdAt'];
    final registeredDate = createdAt != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(createdAt))
        : 'N/A';
    final vendorType = vendorData['vendorType'] ?? 'Restaurant';
    final mobileNumber = vendorData['mobileNumber'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              icon: Icons.calendar_today_rounded,
              label: 'Registered',
              value: registeredDate,
              color: _cBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              icon: Icons.business_center_rounded,
              label: 'Type',
              value: vendorType,
              color: _cAccent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              icon: Icons.phone_rounded,
              label: 'Mobile',
              value: mobileNumber,
              color: _cGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: _cText2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Info cards ────────────────────────────────────────────────────────────────
  Widget _buildBusinessInfoCard() {
    return _infoCard(
      title: 'Business Information',
      icon: Icons.business_rounded,
      color: _cBlue,
      children: [
        _infoRow('Company Name', vendorData['companyName'] ?? 'N/A'),
        _infoRow('Registered Name', vendorData['registeredName'] ?? 'N/A'),
        _infoRow('Owner Name', vendorData['ownerName'] ?? 'N/A'),
        _infoRow('Position', vendorData['position'] ?? 'N/A'),
        _divider(),
        _infoRow('GST Number', vendorData['gstNumber'] ?? 'Not provided'),
        _infoRow('PAN Number', vendorData['panCardNumber'] ?? 'Not provided'),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return _infoCard(
      title: 'Contact Information',
      icon: Icons.contact_phone_rounded,
      color: _cGreen,
      children: [
        _infoRow('Contact Person', vendorData['holderName'] ?? 'N/A'),
        _infoRow('Mobile Number', vendorData['mobileNumber'] ?? 'N/A'),
        _infoRow('Email Address', vendorData['email'] ?? 'N/A'),
        _divider(),
        _infoRow(
          'Aadhaar Number',
          vendorData['aadharNumber'] ?? 'Not provided',
        ),
      ],
    );
  }

  Widget _buildDocumentsCard() {
    return _infoCard(
      title: 'Licenses & Documents',
      icon: Icons.description_rounded,
      color: _cAccent,
      children: [
        _infoRow(
          'FSSAI License',
          vendorData['fssaiLicenseNumber'] ?? 'Not provided',
        ),
        _infoRow('Valid From', vendorData['fssaiStartDate'] ?? 'N/A'),
        _infoRow('Valid To', vendorData['fssaiEndDate'] ?? 'N/A'),
        _divider(),
        _infoRow(
          'Trade License',
          vendorData['tradeLicenseNumber'] ?? 'Not provided',
        ),
        _infoRow(
          'Labour License',
          vendorData['labourLicenseNumber'] ?? 'Not provided',
        ),
      ],
    );
  }

  Widget _buildBankInfoCard() {
    return _infoCard(
      title: 'Bank Details',
      icon: Icons.account_balance_rounded,
      color: _cPurple,
      children: [
        _infoRow('Bank Name', vendorData['bankName'] ?? 'N/A'),
        _infoRow('Branch Name', vendorData['branchName'] ?? 'N/A'),
        _infoRow(
          'Account Number',
          _maskAccountNumber(vendorData['accountNumber'] ?? 'N/A'),
        ),
        _infoRow('IFSC Code', vendorData['ifscCode'] ?? 'N/A'),
      ],
    );
  }

  // ── Shared card shell ─────────────────────────────────────────────────────────
  Widget _infoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: color.withOpacity(0.12)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _cText1,
                  ),
                ),
              ],
            ),
          ),
          // Card body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ── Row helpers ───────────────────────────────────────────────────────────────
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: _cText2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _cText1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(height: 1, color: _cBorder),
  );

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return 'xxxx${accountNumber.substring(accountNumber.length - 4)}';
  }
}
