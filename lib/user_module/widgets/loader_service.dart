import 'package:flutter/material.dart';

class LoaderService {
  static final LoaderService _instance = LoaderService._internal();
  factory LoaderService() => _instance;
  LoaderService._internal();

  OverlayEntry? _overlayEntry;

  /// Show Loader
  void showLoader(BuildContext context) {
    if (_overlayEntry != null) return; // Already visible

    _overlayEntry = OverlayEntry(
      builder: (_) => Container(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.4),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide Loader
  void hideLoader() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
