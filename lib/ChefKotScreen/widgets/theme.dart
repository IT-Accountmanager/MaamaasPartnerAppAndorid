import 'package:flutter/material.dart';
import '../models/kot_model.dart';

const kPrimary = Color(0xFFE66D33);
const kBg = Color(0xFFF5F7FA);
const kCard = Colors.white;
const kBorder = Color(0xFFE0E0E0);
const kText1 = Color(0xFF333333);
const kText2 = Color(0xFF666666);
const kText3 = Color(0xFF999999);

// ── Status colours ─────────────────────────────────────────────────────────────
const kPending = Color(0xFFFFC107);
const kAccepted = Color(0xFF17A2B8);
const kPrepare = Color(0xFF17A2B8);
const kReady = Color(0xFF28A745);
const kDeclined = Color(0xFFDC3545);

// ── Order type colours (left border) ──────────────────────────────────────────
const kDineIn = Color(0xFF1E90FF);
const kTakeaway = Color(0xFFFF6347);
const kDelivery = Color(0xFF20B2AA);
const kTable = Color(0xFF2051B2);

Color orderTypeColor(KotOrderType t) {
  switch (t) {
    case KotOrderType.dineIn:
      return kDineIn;
    case KotOrderType.takeaway:
      return kTakeaway;
    case KotOrderType.delivery:
      return kDelivery;
    case KotOrderType.table:
      return kTable;
  }
}

Color orderTypeBadgeColor(KotOrderType t) {
  switch (t) {
    case KotOrderType.dineIn:
      return const Color(0xFF1E90FF);
    case KotOrderType.takeaway:
      return const Color(0xFFFF6347);
    case KotOrderType.delivery:
      return const Color(0xFF20B2AA);
    case KotOrderType.table:
      return const Color(0xFF20C997);
  }
}

String orderTypeLabel(KotOrder o) {
  switch (o.orderType) {
    case KotOrderType.dineIn:
      return 'Dine In';
    case KotOrderType.takeaway:
      return 'Takeaway';
    case KotOrderType.delivery:
      return 'Delivery';
    case KotOrderType.table:
      return o.tableNumber.isNotEmpty ? o.tableNumber : 'Table';
  }
}

Color statusDotColor(KotStatus s) {
  switch (s) {
    case KotStatus.pending:
      return kPending;
    case KotStatus.preparing:
      return kPrepare;
    case KotStatus.ready:
      return kReady;
    case KotStatus.declined:
      return kDeclined;
  }
}

String statusLabel(KotStatus s) {
  switch (s) {
    case KotStatus.pending:
      return 'PENDING';
    case KotStatus.preparing:
      return 'PREPARING';
    case KotStatus.ready:
      return 'READY';
    case KotStatus.declined:
      return 'DECLINED';
  }
}

// ── Snackbar ───────────────────────────────────────────────────────────────────
void showToast(
  BuildContext ctx,
  String title, {
  String? desc,
  bool error = false,
}) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          if (desc != null && desc.isNotEmpty)
            Text(
              desc,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
        ],
      ),
      backgroundColor: error ? kDeclined : kReady,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}
