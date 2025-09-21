import 'package:flutter/material.dart';

class BookingDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final void Function(T?) onChanged;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final String? Function(T?)? validator;

  const BookingDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: ValueKey(value.hashCode),
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.disabled,
      builder: (FormFieldState<T> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: field.hasError ? Colors.red : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  if (label.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: field.hasError ? Colors.red : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color:
                                field.hasError ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<T>(
                              value: field.value,
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              items:
                                  items.map((T item) {
                                    return DropdownMenuItem<T>(
                                      value: item,
                                      child: Text(
                                        itemBuilder(item),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (T? newValue) {
                                field.didChange(newValue);
                                onChanged(newValue);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
