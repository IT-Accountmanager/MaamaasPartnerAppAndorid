
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maamaaspartner/Registration01/models/vendor_form_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Authservice.dart';
import '../../widgets_helper/Home_screen_1.dart';
import '../steps/Location.dart';
import '../steps/company_profile_step.dart';
import '../steps/contact_details_step.dart';
import '../steps/license_documents_step.dart';
import '../steps/preview_step.dart';
import '../services/vendor_api_service.dart';
import 'FoodRegistrationComplete.dart';
import 'FoodRegistrationIntro.dart';
import 'FoodVendorDashboard.dart';

// Design tokens
const Color _kOrange = Color(0xFFE66D33);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kBackground = Color(0xFFF7F8FC);
const Color _kBorder = Color(0xFFEEEFF5);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kError = Color(0xFFEF4444);
const Color _kErrorLight = Color(0xFFFEE2E2);
const Color _kGreen = Color(0xFF10B981);

class FoodRegistrationScreen01 extends StatefulWidget {
  final bool isNewVendor;
  final String? demoVendorId;
  final bool showAppBar;

  const FoodRegistrationScreen01({
    super.key,
    this.isNewVendor = false,
    this.demoVendorId,
    this.showAppBar = false,
  });

  @override
  State<FoodRegistrationScreen01> createState() =>
      _FoodRegistrationScreenState();
}

class _FoodRegistrationScreenState extends State<FoodRegistrationScreen01> {
  int _currentStep = 1;
  VendorFormData _formData = VendorFormData();
  bool _isLoading = true;
  String _vendorId = '';
  String? _errorMessage;

  // Registration flow states
  bool _showRegistration = false;
  bool _showComplete = false;
  bool _showDashboard = false;
  Map<String, dynamic>? _vendorData;
  DateTime? _registrationDate;
  bool _isNavigating = false;

  final List<Map<String, String>> _steps = [
    {'label': 'Company', 'icon': '🏢'},
    {'label': 'Contact', 'icon': '📞'},
    {'label': 'Documents', 'icon': '📄'},
    {'label': 'Location', 'icon': '📍'},
    {'label': 'Preview', 'icon': '👁️'},
  ];

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkRegistrationStatus() async {
    if (_isNavigating) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedVendorId = prefs.getInt('vendorId');

      if (storedVendorId == null || storedVendorId <= 0) {
        setState(() {
          _showRegistration = false;
          _showComplete = false;
          _showDashboard = false;
          _isLoading = false;
        });
        return;
      }

      setState(() => _vendorId = storedVendorId.toString());

      // Fetch vendor data from API
      final vendorData = await VendorApiService.getVendor(_vendorId);

      if (vendorData != null && mounted) {
        setState(() => _vendorData = vendorData);

        // Check if vendor is approved
        final approvalStatus = vendorData['approvalStatus'] ?? false;

        if (approvalStatus == true) {
          // Approved - Navigate to Dashboard
          if (mounted && !_isNavigating) {
            setState(() {
              _showDashboard = true;
              _showRegistration = false;
              _showComplete = false;
              _isLoading = false;
            });

            // Navigate to Dashboard after a short delay
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isNavigating) {
                _navigateToDashboard();
              }
            });
          }
        } else if (vendorData['registeredName'] != null &&
            vendorData['registeredName']!.isNotEmpty) {
          // Registration completed but not approved
          _registrationDate = DateTime.tryParse(vendorData['createdAt'] ?? '');
          if (mounted) {
            setState(() {
              _showComplete = true;
              _showRegistration = false;
              _showDashboard = false;
              _isLoading = false;
            });
          }
        } else {
          // Registration not started yet
          if (mounted) {
            setState(() {
              _showRegistration = false;
              _showComplete = false;
              _showDashboard = false;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _showRegistration = false;
            _showComplete = false;
            _showDashboard = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking registration status: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard() {
    if (_isNavigating) return;
    _isNavigating = true;

    if (_vendorData != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FoodVendorDashboard(vendorData: _vendorData!),
        ),
      );
    } else if (mounted) {
      // Fallback to HomeWrapper if no data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeWrapper()),
      );
    }
  }

  void _navigateToHome() {
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeWrapper()),
    );
  }

  void _handleBeginRegistration() {
    setState(() {
      _showRegistration = true;
      _currentStep = 1;
      _formData = VendorFormData();
    });
    _loadVendorIdAndData();
  }

  Future<void> _loadVendorIdAndData() async {
    setState(() => _isLoading = true);

    try {
      if (widget.demoVendorId != null && widget.demoVendorId!.isNotEmpty) {
        setState(() => _vendorId = widget.demoVendorId!);
        setState(() => _isLoading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final storedVendorId = prefs.getInt('vendorId');

      if (storedVendorId != null && storedVendorId > 0) {
        setState(() => _vendorId = storedVendorId.toString());

        final existingData = await VendorApiService.getVendorFormData(
          _vendorId,
        );
        if (existingData != null && mounted) {
          setState(() => _formData = existingData);
        }
        setState(() => _isLoading = false);
        return;
      }

      final vendorId = await Authservice.getVendorId();
      if (vendorId == null) {
        _errorMessage = 'Please login again';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login again'),
              backgroundColor: _kError,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _vendorId = vendorId.toString());

      if (!widget.isNewVendor) {
        final existingData = await VendorApiService.getVendorFormData(
          _vendorId,
        );
        if (existingData != null && mounted) {
          setState(() => _formData = existingData);
        }
      }
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 5) setState(() => _currentStep++);
  }

  void _backStep() {
    if (_currentStep > 1) setState(() => _currentStep--);
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _navigateToHome();
    }
  }

  void _handleRegistrationComplete() {
    // After successful registration submission, show pending approval screen
    setState(() {
      _showComplete = true;
      _showRegistration = false;
      _showDashboard = false;
    });
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _kWhite,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: _kBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: _kTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  final stepNumber = index + 1;
                  final isActive = _currentStep == stepNumber;
                  final isCompleted = _currentStep > stepNumber;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentStep = stepNumber);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive || isCompleted ? _kGreen : _kOrange,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _kGreen.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCompleted)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check_rounded,
                                color: _kWhite,
                                size: 16,
                              ),
                            ),
                          Text(
                            _steps[index]['label']!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _kWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return CompanyProfileStep(
          formData: _formData,
          onChanged: (u) => setState(() => _formData = u),
          onNext: _nextStep,
        );
      case 2:
        return ContactDetailsStep(
          formData: _formData,
          onChanged: (u) => setState(() => _formData = u),
          onNext: _nextStep,
          onBack: _backStep,
        );
      case 3:
        return LicenseDocumentsStep(
          formData: _formData,
          onChanged: (u) => setState(() => _formData = u),
          onNext: _nextStep,
          onBack: _backStep,
        );
      case 4:
        return LocationStep(
          formData: _formData,
          onChanged: (u) => setState(() => _formData = u),
          onNext: _nextStep,
          onBack: _backStep,
        );
      case 5:
        return PreviewStep(
          formData: _formData,
          onBack: _backStep,
          vendorId: _vendorId,
          isNewVendor: widget.isNewVendor,
          onRegistrationComplete: _handleRegistrationComplete,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _kBackground,
        body: const Center(child: CircularProgressIndicator(color: _kOrange)),
      );
    }

    // Don't show anything while navigating to dashboard
    if (_showDashboard) {
      return const SizedBox.shrink();
    }

    // Show pending approval screen if registration completed but not approved
    if (_showComplete) {
      return FoodRegistrationComplete(
        companyName: _vendorData?['registeredName'] ?? _formData.companyName,
        email: _vendorData?['email'] ?? _formData.email,
        registrationDate: _registrationDate,
        onGoToHome: _navigateToHome,
      );
    }

    // Show intro screen if user hasn't started registration
    if (!_showRegistration) {
      return FoodRegistrationIntro(
        onBeginRegistration: _handleBeginRegistration,
      );
    }

    // Show registration form
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: _vendorId.isEmpty && !_showRegistration
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: _kErrorLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: _kError,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Authentication Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage ?? 'Please login again',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _kTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _loadVendorIdAndData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _kOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: _kWhite,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Retry',
                                    style: TextStyle(color: _kWhite),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }
}
