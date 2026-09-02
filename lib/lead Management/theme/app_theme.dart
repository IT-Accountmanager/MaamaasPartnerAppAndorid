import 'package:flutter/material.dart';

/// Colors pulled straight from AssignedLeads.css / PaidLeads.css /
/// LeadsDashboard.css / LeadsHistory.css / Quotations.css so the Flutter
/// screens look like the original React ones.
class AppColors {
  static const primary = Color(0xFFE66D33);
  static const primaryDark = Color(0xFFD45A2A);
  static const textDark = Color(0xFF1E293B);
  static const textMuted = Color(0xFF94A3B8);
  static const textSubtle = Color(0xFF64748B);
  static const bgLight = Color(0xFFF8FAFC);
  static const border = Color(0xFFF0F0F0);
  static const borderInput = Color(0xFFE2E8F0);
  static const success = Color(0xFF198754);
  static const successBg = Color(0xFFDCFCE7);
  static const info = Color(0xFF0D6EFD);
  static const infoBg = Color(0xFFDBEAFE);
  static const warning = Color(0xFFFD7E14);
  static const warningBg = Color(0xFFFEF3C7);
  static const purple = Color(0xFF6F42C1);
  static const purpleBg = Color(0xFFF3E8FF);
  static const danger = Color(0xFFDC3545);
  static const dangerBg = Color(0xFFFEE2E2);
  static const neutral = Color(0xFF6C757D);
  static const neutralBg = Color(0xFFF3F4F6);
}

/// `getEventTypeColor()` from every JSX file — kept as one shared source
/// of truth here instead of copy-pasted per screen.
Color eventTypeColor(String? type) {
  switch (type?.toUpperCase()) {
    case 'WEDDING':
      return const Color(0xFFDC3545);
    case 'BIRTHDAY':
      return const Color(0xFFFD7E14);
    case 'ENGAGEMENT':
      return const Color(0xFFE83E8C);
    case 'ANNIVERSARY':
      return const Color(0xFF6F42C1);
    case 'CORPORATE':
      return const Color(0xFF0D6EFD);
    case 'DAILY':
      return const Color(0xFF198754);
    case 'WEEKLY':
      return const Color(0xFF0DCAF0);
    case 'MONTHLY':
      return const Color(0xFF6610F2);
    case 'FESTIVAL':
      return const Color(0xFFD63384);
    default:
      return const Color(0xFF6C757D);
  }
}

class StatusBadgeStyle {
  final String label;
  final Color color;
  final Color background;
  const StatusBadgeStyle(this.label, this.color, this.background);
}

/// `getQuotationStatusBadge()` ported from AssignedLeads.jsx / PaidLeads.jsx
/// / Quotations.jsx.
StatusBadgeStyle quotationStatusBadge(String? status) {
  switch (status?.toUpperCase()) {
    case 'SUBMITTED':
      return const StatusBadgeStyle('Submitted', AppColors.info, AppColors.infoBg);
    case 'SELECTED':
      return const StatusBadgeStyle('Selected ✅', AppColors.success, AppColors.successBg);
    case 'ACCEPTED':
      return const StatusBadgeStyle('Accepted ✅', AppColors.success, AppColors.successBg);
    case 'REJECTED':
      return const StatusBadgeStyle('Rejected', AppColors.danger, AppColors.dangerBg);
    default:
      return StatusBadgeStyle(status?.isNotEmpty == true ? status! : 'Pending', AppColors.neutral, AppColors.neutralBg);
  }
}

/// `getLeadStatusBadge()` ported from LeadsHistory.jsx.
StatusBadgeStyle leadStatusBadge(String? status) {
  switch (status?.toUpperCase()) {
    case 'NEW':
      return const StatusBadgeStyle('New', AppColors.info, AppColors.infoBg);
    case 'ASSIGNED':
      return const StatusBadgeStyle('Assigned', AppColors.warning, AppColors.warningBg);
    case 'PAYMENT_RECEIVED':
      return const StatusBadgeStyle('Payment Received', AppColors.success, AppColors.successBg);
    case 'APPROVED':
      return const StatusBadgeStyle('Approved', AppColors.success, AppColors.successBg);
    case 'CLOSED':
      return const StatusBadgeStyle('Closed', AppColors.neutral, AppColors.neutralBg);
    case 'REJECTED':
      return const StatusBadgeStyle('Rejected', AppColors.danger, AppColors.dangerBg);
    case 'CANCELLED':
      return const StatusBadgeStyle('Cancelled', AppColors.danger, AppColors.dangerBg);
    default:
      return StatusBadgeStyle(status?.isNotEmpty == true ? status! : 'Unknown', AppColors.neutral, AppColors.neutralBg);
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Segoe UI',
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textDark,
      elevation: 0.5,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderInput),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderInput),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
