import 'package:flutter/material.dart';

class FilterOption {
  final String value;
  final String label;
  const FilterOption(this.value, this.label);
}

/// Ports the `*-filters` / `*-search` / `*-filter-select` / `*-refresh-btn`
/// blocks shared by every list screen. Stacks vertically on mobile instead
/// of the desktop flex row, per the CSS's own `@media (max-width: 767px)`
/// rule (`flex-direction: column`).
class FiltersBar extends StatelessWidget {
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final List<FilterOption>? typeOptions;
  final String? typeValue;
  final ValueChanged<String>? onTypeChanged;
  final List<FilterOption>? statusOptions;
  final String? statusValue;
  final ValueChanged<String>? onStatusChanged;
  final VoidCallback onRefresh;

  const FiltersBar({
    super.key,
    required this.searchHint,
    required this.onSearchChanged,
    this.typeOptions,
    this.typeValue,
    this.onTypeChanged,
    this.statusOptions,
    this.statusValue,
    this.onStatusChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search, size: 20),
          ),
        ),
        if (typeOptions != null || statusOptions != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (typeOptions != null)
                Expanded(
                  child: _Dropdown(
                    options: typeOptions!,
                    value: typeValue ?? typeOptions!.first.value,
                    onChanged: onTypeChanged!,
                  ),
                ),
              if (typeOptions != null && statusOptions != null)
                const SizedBox(width: 8),
              if (statusOptions != null)
                Expanded(
                  child: _Dropdown(
                    options: statusOptions!,
                    value: statusValue ?? statusOptions!.first.value,
                    onChanged: onStatusChanged!,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final List<FilterOption> options;
  final String value;
  final ValueChanged<String> onChanged;

  const _Dropdown({required this.options, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      items: options
          .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: (v) => onChanged(v ?? value),
    );
  }
}

/// Common event-type filter options, shared by every screen with the
/// "All Types / Wedding / Birthday / ..." dropdown.
const eventTypeFilterOptions = [
  FilterOption('all', 'All Types'),
  FilterOption('WEDDING', 'Wedding'),
  FilterOption('BIRTHDAY', 'Birthday'),
  FilterOption('ENGAGEMENT', 'Engagement'),
  FilterOption('ANNIVERSARY', 'Anniversary'),
  FilterOption('CORPORATE', 'Corporate'),
  FilterOption('DAILY', 'Daily'),
  FilterOption('WEEKLY', 'Weekly'),
  FilterOption('MONTHLY', 'Monthly'),
  FilterOption('FESTIVAL', 'Festival'),
  FilterOption('OTHER', 'Other'),
];
