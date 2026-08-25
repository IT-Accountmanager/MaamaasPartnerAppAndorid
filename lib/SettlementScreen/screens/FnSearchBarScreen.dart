import 'package:flutter/material.dart';
import '../widgets/theme.dart';

class FnSearchBar extends StatelessWidget {
  final String hint, value;
  final ValueChanged<String> onChanged;
  const FnSearchBar({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: fnCardDeco(radius: 12),
    child: Row(
      children: [
        const SizedBox(width: 14),
        const Icon(Icons.search_rounded, color: fnText3, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: fnText3, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 13, color: fnText1),
          ),
        ),
        if (value.isNotEmpty)
          GestureDetector(
            onTap: () => onChanged(''),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.close_rounded, color: fnText3, size: 16),
            ),
          ),
      ],
    ),
  );
}
