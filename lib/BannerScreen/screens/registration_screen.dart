import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/BannerScreen/screens/Theme.dart';
import '../services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // ── Controllers ────────────────────────────────────────────────────────────
  final _companyNameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _aadharCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  // Address
  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  // Bank
  final _holderCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();

  // License controllers
  final _tradeNumCtrl = TextEditingController();
  final _tradeStartCtrl = TextEditingController();
  final _tradeEndCtrl = TextEditingController();
  final _fssaiNumCtrl = TextEditingController();
  final _fssaiStartCtrl = TextEditingController();
  final _fssaiEndCtrl = TextEditingController();
  final _labourNumCtrl = TextEditingController();
  final _labourStartCtrl = TextEditingController();
  final _labourEndCtrl = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────────────
  String _businessVertical = 'FOOD_AND_BEVERAGES';
  String _verticalType = 'RESTAURANT';
  bool _loading = false;
  bool _registrationComplete = false;

  File? _aadharDoc;
  File? _tradeDoc;
  File? _fssaiDoc;
  File? _labourDoc;
  File? _passbookDoc;

  final Map<String, String> _fieldStatus = {
    'Company Name': 'Pending',
    'Business Vertical': 'Pending',
    'Position': 'Pending',
    'Vertical Type': 'Pending',
    'Address': 'Pending',
    'Contact Name': 'Pending',
    'Phone No': 'Pending',
    'Email ID': 'Pending',
    'Aadhar Card': 'Not Uploaded',
    'GST No.': 'Not Verified',
    'Trade License': 'Not Uploaded',
    'FSSAI License': 'Not Uploaded',
    'Labour License': 'Not Uploaded',
    'Bank Details': 'Pending',
  };

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    for (final c in [
      _companyNameCtrl,
      _positionCtrl,
      _contactNameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _aadharCtrl,
      _gstCtrl,
      _doorCtrl,
      _streetCtrl,
      _cityCtrl,
      _stateCtrl,
      _pincodeCtrl,
      _landmarkCtrl,
      _holderCtrl,
      _accCtrl,
      _branchCtrl,
      _ifscCtrl,
      _tradeNumCtrl,
      _tradeStartCtrl,
      _tradeEndCtrl,
      _fssaiNumCtrl,
      _fssaiStartCtrl,
      _fssaiEndCtrl,
      _labourNumCtrl,
      _labourStartCtrl,
      _labourEndCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExisting() async {
    try {
      final data = await RegistrationApi.getVendorDetails();
      if (data != null && mounted) {
        setState(() {
          _registrationComplete = true;
          _companyNameCtrl.text = data['companyName'] ?? '';
          _positionCtrl.text = data['position'] ?? '';
          _contactNameCtrl.text = data['contactName'] ?? '';
          _phoneCtrl.text = data['phoneNo'] ?? '';
          _emailCtrl.text = data['emailId'] ?? '';
          _aadharCtrl.text = data['aadharCardNo'] ?? '';
          _gstCtrl.text = data['gstNo'] ?? '';
          _verticalType = data['verticalType'] ?? 'RESTAURANT';

          final addr = data['address'] ?? {};
          _doorCtrl.text = addr['doorNo'] ?? '';
          _streetCtrl.text = addr['street'] ?? '';
          _cityCtrl.text = addr['city'] ?? '';
          _stateCtrl.text = addr['state'] ?? '';
          _pincodeCtrl.text = addr['pincode'] ?? '';
          _landmarkCtrl.text = addr['landmark'] ?? '';

          final bank = data['bankDetails'] ?? {};
          _holderCtrl.text = bank['holderName'] ?? '';
          _accCtrl.text = bank['accountNumber'] ?? '';
          _branchCtrl.text = bank['branchName'] ?? '';
          _ifscCtrl.text = bank['ifscCode'] ?? '';

          if (_companyNameCtrl.text.isNotEmpty)
            _fieldStatus['Company Name'] = 'Provided';
          if (_doorCtrl.text.isNotEmpty) _fieldStatus['Address'] = 'Provided';
          if (_holderCtrl.text.isNotEmpty)
            _fieldStatus['Bank Details'] = 'Provided';
        });
      }
    } catch (_) {}
  }

  Future<void> _submitRegistration() async {
    if (_companyNameCtrl.text.trim().isEmpty) {
      showError(context, 'Company name is required.');
      return;
    }

    setState(() => _loading = true);
    try {
      final payload = {
        'companyName': _companyNameCtrl.text.trim(),
        'businessVertical': _businessVertical,
        'position': _positionCtrl.text.trim(),
        'verticalType': _verticalType,
        'contactName': _contactNameCtrl.text.trim(),
        'phoneNo': _phoneCtrl.text.trim(),
        'emailId': _emailCtrl.text.trim(),
        'aadharCardNo': _aadharCtrl.text.trim(),
        'gstNo': _gstCtrl.text.trim(),
        'address': {
          'doorNo': _doorCtrl.text.trim(),
          'street': _streetCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'state': _stateCtrl.text.trim(),
          'pincode': _pincodeCtrl.text.trim(),
          'landmark': _landmarkCtrl.text.trim(),
        },
        'bankDetails': {
          'holderName': _holderCtrl.text.trim(),
          'accountNumber': _accCtrl.text.trim(),
          'branchName': _branchCtrl.text.trim(),
          'ifscCode': _ifscCtrl.text.trim(),
        },
      };

      final docs = <String, List<int>>{};
      if (_aadharDoc != null)
        docs['aadharFront'] = await _aadharDoc!.readAsBytes();
      if (_tradeDoc != null)
        docs['tradeLicense'] = await _tradeDoc!.readAsBytes();
      if (_fssaiDoc != null)
        docs['fssaiLicense'] = await _fssaiDoc!.readAsBytes();
      if (_labourDoc != null)
        docs['labourLicense'] = await _labourDoc!.readAsBytes();
      if (_passbookDoc != null)
        docs['passbook'] = await _passbookDoc!.readAsBytes();

      await RegistrationApi.submit(payload, docs: docs);
      setState(() => _registrationComplete = true);
      if (mounted) {
        showSuccess(context, 'Registration submitted successfully!');
      }
    } catch (e) {
      if (mounted) showError(context, 'Registration failed. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveAddress() async {
    try {
      await RegistrationApi.updateAddress({
        'doorNo': _doorCtrl.text.trim(),
        'street': _streetCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'landmark': _landmarkCtrl.text.trim(),
      });
      setState(() => _fieldStatus['Address'] = 'Provided');
      if (mounted) showSuccess(context, 'Address updated!');
    } catch (_) {
      if (mounted) showError(context, 'Failed to update address.');
    }
  }

  Future<void> _saveBank() async {
    try {
      final bytes = _passbookDoc != null
          ? await _passbookDoc!.readAsBytes()
          : null;
      await RegistrationApi.updateBankDetails({
        'holderName': _holderCtrl.text.trim(),
        'accountNumber': _accCtrl.text.trim(),
        'branchName': _branchCtrl.text.trim(),
        'ifscCode': _ifscCtrl.text.trim(),
      }, passbookBytes: bytes);
      setState(() => _fieldStatus['Bank Details'] = 'Provided');
      if (mounted) showSuccess(context, 'Bank details updated!');
    } catch (_) {
      if (mounted) showError(context, 'Failed to update bank details.');
    }
  }

  Future<File?> _pickDocument() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    return f != null ? File(f.path) : null;
  }

  bool get _canEdit => _registrationComplete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge
          if (_registrationComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kSuccess.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: kSuccess, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Registration Complete',
                    style: TextStyle(
                      color: kSuccess,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kWarning.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: kWarning, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Fill in all details to complete registration',
                    style: TextStyle(
                      color: kWarning,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // ── COMPANY DETAILS ──────────────────────────────────────────────
          _SectionCard(
            title: 'Company Details',
            icon: Icons.business_outlined,
            children: [
              FormTile(
                label: 'Company Name',
                controller: _companyNameCtrl,
                required: true,
                readOnly: _canEdit,
              ),
              const SizedBox(height: 12),
              DropdownTile(
                label: 'Business Vertical',
                value: _businessVertical,
                options: const ['FOOD_AND_BEVERAGES'],
                onChanged: _canEdit
                    ? null
                    : (v) => setState(
                        () => _businessVertical = v ?? _businessVertical,
                      ),
              ),
              const SizedBox(height: 12),
              FormTile(
                label: 'Position',
                controller: _positionCtrl,
                readOnly: _canEdit,
              ),
              const SizedBox(height: 12),
              DropdownTile(
                label: 'Vertical Type',
                value: _verticalType,
                options: const [
                  'HOTEL',
                  'RESTAURANT',
                  'CAFE',
                  'CLOUD_KITCHEN',
                  'FOOD_COURT',
                  'STREET_FOOD',
                  'BAKERY',
                ],
                onChanged: _canEdit
                    ? (v) => setState(() => _verticalType = v ?? _verticalType)
                    : null,
              ),
            ],
          ),

          // ── ADDRESS ───────────────────────────────────────────────────────
          _SectionCard(
            title: 'Address & Location',
            icon: Icons.location_on_outlined,
            actionLabel: _registrationComplete ? 'Save Address' : null,
            onAction: _registrationComplete ? _saveAddress : null,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FormTile(
                      label: 'Door No.',
                      controller: _doorCtrl,
                      hint: '12-A',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormTile(
                      label: 'Pincode',
                      controller: _pincodeCtrl,
                      keyboardType: TextInputType.number,
                      hint: '500001',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormTile(
                label: 'Street',
                controller: _streetCtrl,
                hint: 'Main Road',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FormTile(
                      label: 'City',
                      controller: _cityCtrl,
                      hint: 'Hyderabad',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormTile(
                      label: 'State',
                      controller: _stateCtrl,
                      hint: 'Telangana',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormTile(
                label: 'Landmark',
                controller: _landmarkCtrl,
                hint: 'Near bus stop',
              ),
            ],
          ),

          // ── CONTACT DETAILS ───────────────────────────────────────────────
          _SectionCard(
            title: 'Contact Details',
            icon: Icons.contact_phone_outlined,
            children: [
              FormTile(
                label: 'Contact Name',
                controller: _contactNameCtrl,
                readOnly: _canEdit,
              ),
              const SizedBox(height: 12),
              FormTile(
                label: 'Phone No.',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                readOnly: _canEdit,
              ),
              const SizedBox(height: 12),
              FormTile(
                label: 'Email ID',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                readOnly: _canEdit,
              ),
            ],
          ),

          // ── LICENSES & DOCUMENTS ──────────────────────────────────────────
          _SectionCard(
            title: 'Licenses & Documents',
            icon: Icons.description_outlined,
            children: [
              // Aadhar
              _DocUploadRow(
                label: 'Aadhar Card No.',
                controller: _aadharCtrl,
                docFile: _aadharDoc,
                status: _fieldStatus['Aadhar Card']!,
                readOnly: _canEdit,
                onUpload: () async {
                  final f = await _pickDocument();
                  if (f != null) {
                    setState(() {
                      _aadharDoc = f;
                      _fieldStatus['Aadhar Card'] = 'Uploaded';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              // GST
              _DocUploadRow(
                label: 'GST No.',
                controller: _gstCtrl,
                status: _fieldStatus['GST No.']!,
                readOnly: _canEdit,
              ),
              const SizedBox(height: 16),
              // Trade License
              _LicenseSection(
                title: 'Trade License',
                numCtrl: _tradeNumCtrl,
                startCtrl: _tradeStartCtrl,
                endCtrl: _tradeEndCtrl,
                docFile: _tradeDoc,
                status: _fieldStatus['Trade License']!,
                readOnly: _canEdit,
                onUpload: () async {
                  final f = await _pickDocument();
                  if (f != null) {
                    setState(() {
                      _tradeDoc = f;
                      _fieldStatus['Trade License'] = 'Uploaded';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              // FSSAI
              _LicenseSection(
                title: 'FSSAI License',
                numCtrl: _fssaiNumCtrl,
                startCtrl: _fssaiStartCtrl,
                endCtrl: _fssaiEndCtrl,
                docFile: _fssaiDoc,
                status: _fieldStatus['FSSAI License']!,
                readOnly: _canEdit,
                onUpload: () async {
                  final f = await _pickDocument();
                  if (f != null) {
                    setState(() {
                      _fssaiDoc = f;
                      _fieldStatus['FSSAI License'] = 'Uploaded';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              // Labour
              _LicenseSection(
                title: 'Labour License',
                numCtrl: _labourNumCtrl,
                startCtrl: _labourStartCtrl,
                endCtrl: _labourEndCtrl,
                docFile: _labourDoc,
                status: _fieldStatus['Labour License']!,
                readOnly: _canEdit,
                onUpload: () async {
                  final f = await _pickDocument();
                  if (f != null) {
                    setState(() {
                      _labourDoc = f;
                      _fieldStatus['Labour License'] = 'Uploaded';
                    });
                  }
                },
              ),
            ],
          ),

          // ── BANK DETAILS ──────────────────────────────────────────────────
          _SectionCard(
            title: 'Bank Details',
            icon: Icons.account_balance_outlined,
            actionLabel: 'Save Bank',
            onAction: _saveBank,
            children: [
              FormTile(label: 'Account Holder Name', controller: _holderCtrl),
              const SizedBox(height: 12),
              FormTile(
                label: 'Account Number',
                controller: _accCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FormTile(
                      label: 'Branch Name',
                      controller: _branchCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormTile(label: 'IFSC Code', controller: _ifscCtrl),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Passbook upload
              _DocUploadTile(
                label: 'Passbook / Cheque',
                docFile: _passbookDoc,
                status: _fieldStatus['Bank Details']!,
                onUpload: () async {
                  final f = await _pickDocument();
                  if (f != null) setState(() => _passbookDoc = f);
                },
              ),
            ],
          ),

          // ── SUBMIT ────────────────────────────────────────────────────────
          if (!_registrationComplete) ...[
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Submit Registration',
              loading: _loading,
              onPressed: _submitRegistration,
              icon: Icons.send_rounded,
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: fpCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: kPrimary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: fpText1,
                    ),
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
}

// ─── Doc Upload Row ───────────────────────────────────────────────────────────
class _DocUploadRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final File? docFile;
  final String status;
  final bool readOnly;
  final VoidCallback? onUpload;

  const _DocUploadRow({
    required this.label,
    required this.controller,
    this.docFile,
    required this.status,
    this.readOnly = false,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTile(label: label, controller: controller, readOnly: readOnly),
        const SizedBox(height: 8),
        Row(
          children: [
            StatusBadge(status: status),
            const Spacer(),
            if (onUpload != null)
              GestureDetector(
                onTap: onUpload,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: fpBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: fpBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file_outlined,
                        size: 14,
                        color: kPrimary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        docFile != null
                            ? docFile!.path.split('/').last
                            : 'Upload Doc',
                        style: const TextStyle(
                          fontSize: 11,
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── License Section ──────────────────────────────────────────────────────────
class _LicenseSection extends StatelessWidget {
  final String title;
  final TextEditingController numCtrl;
  final TextEditingController startCtrl;
  final TextEditingController endCtrl;
  final File? docFile;
  final String status;
  final bool readOnly;
  final VoidCallback onUpload;

  const _LicenseSection({
    required this.title,
    required this.numCtrl,
    required this.startCtrl,
    required this.endCtrl,
    this.docFile,
    required this.status,
    this.readOnly = false,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fpBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fpBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fpText1,
                ),
              ),
              const Spacer(),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 10),
          FormTile(
            label: 'License Number',
            controller: numCtrl,
            readOnly: readOnly,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FormTile(
                  label: 'Start Date',
                  controller: startCtrl,
                  hint: 'YYYY-MM-DD',
                  readOnly: readOnly,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormTile(
                  label: 'End Date',
                  controller: endCtrl,
                  hint: 'YYYY-MM-DD',
                  readOnly: readOnly,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onUpload,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kPrimary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.upload_file_outlined,
                    size: 15,
                    color: kPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    docFile != null
                        ? '✓ ${docFile!.path.split('/').last}'
                        : 'Upload Document',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
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
}

// ─── Doc Upload Tile ──────────────────────────────────────────────────────────
class _DocUploadTile extends StatelessWidget {
  final String label;
  final File? docFile;
  final String status;
  final VoidCallback onUpload;

  const _DocUploadTile({
    required this.label,
    this.docFile,
    required this.status,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fpText1,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(status: status),
            ],
          ),
        ),
        GestureDetector(
          onTap: onUpload,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: fpBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: fpBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.upload_file_outlined,
                  size: 14,
                  color: kPrimary,
                ),
                const SizedBox(width: 5),
                Text(
                  docFile != null ? '✓ Uploaded' : 'Upload',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
