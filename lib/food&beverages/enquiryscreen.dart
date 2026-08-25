import 'package:flutter/material.dart';
import '../user_module/screens/Catering&Services/customised_menu.dart';

class EnquiryFormScreen extends StatefulWidget {
  const EnquiryFormScreen({super.key});

  @override
  State<EnquiryFormScreen> createState() => _EnquiryFormScreenState();
}

class _EnquiryFormScreenState extends State<EnquiryFormScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomisedMenu();
  }
}
