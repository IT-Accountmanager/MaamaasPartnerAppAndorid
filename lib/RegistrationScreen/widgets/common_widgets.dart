import 'package:flutter/material.dart';

const kOrange = Color(0xFFF97316);
const kIndigo = Color(0xFF4F46E5);
const kGray = Color(0xFF6B7280);
const kBorderColor = Color(0xFFD1D5DB);
const kBgLight = Color(0xFFF9FAFB);
const kTextDark = Color(0xFF111827);
const kTextMid = Color(0xFF374151);

/// Labeled text input
class LabeledInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final TextInputType keyboardType;

  const LabeledInput({
    super.key,
    required this.label,
    required this.placeholder,
    required this.value,
    required this.onChanged,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kTextMid,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: kTextDark),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF3F4F6) : kBgLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kIndigo, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Labeled dropdown
class LabeledDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kTextMid,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value?.isEmpty ?? true ? null : value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: kTextDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: kBgLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kIndigo, width: 1.5),
            ),
          ),
          hint: const Text(
            'Select type',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Section title
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: kTextDark,
        ),
      ),
    );
  }
}

/// Divider
class FormDivider extends StatelessWidget {
  const FormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: kBorderColor, thickness: 1),
    );
  }
}

/// Preview field (read-only display)
class PreviewField extends StatelessWidget {
  final String label;
  final String value;

  const PreviewField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextMid,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: kBgLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderColor),
          ),
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 13, color: kTextDark),
          ),
        ),
      ],
    );
  }
}

/// Orange Next Button
class NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const NextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = kOrange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// Back + Next row
class NavButtonRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  const NavButtonRow({
    super.key,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next →',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: kGray,
                side: const BorderSide(color: kBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '← Back',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                nextLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
