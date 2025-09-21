import 'package:flutter/material.dart';

class BookingTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final Color? backgroundColor;
  final VoidCallback? onClick;
  final String? placeholder;
  final bool readOnly;
  final String? Function(String?)? validator;

  const BookingTextfield({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.backgroundColor,
    this.onClick,
    this.placeholder,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = onClick != null;

    // For clickable fields, use ValueListenableBuilder to ensure updates
    if (isClickable) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return FormField<String>(
            key: ValueKey('${controller.hashCode}_${value.text}'),
            initialValue: value.text,
            validator: validator,
            autovalidateMode: AutovalidateMode.disabled,
            builder: (FormFieldState<String> field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: isClickable ? onClick : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor ?? Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              field.hasError ? Colors.red : Colors.grey[200]!,
                        ),
                      ),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: keyboardType,
                        readOnly: isClickable || readOnly,
                        onChanged: (value) {
                          field.didChange(value);
                          if (!isClickable) {
                            controller.text = value;
                          }
                        },
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              isClickable && controller.text.isEmpty
                                  ? Colors.grey[500]
                                  : Colors.black87,
                        ),
                        onTap: isClickable ? onClick : null,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          labelText:
                              isClickable && controller.text.isEmpty
                                  ? (placeholder ?? label)
                                  : label,
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color:
                                field.hasError ? Colors.red : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon:
                              icon != null
                                  ? Icon(
                                    icon,
                                    color:
                                        field.hasError
                                            ? Colors.red
                                            : Colors.grey[600],
                                    size: 20,
                                  )
                                  : null,
                          suffixIcon:
                              isClickable
                                  ? Icon(
                                    Icons.arrow_drop_down,
                                    color:
                                        field.hasError
                                            ? Colors.red
                                            : Colors.grey[600],
                                    size: 20,
                                  )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
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
        },
      );
    } else {
      // For regular text fields, use simple FormField
      return FormField<String>(
        key: ValueKey(controller.hashCode),
        initialValue: controller.text,
        validator: validator,
        autovalidateMode: AutovalidateMode.disabled,
        builder: (FormFieldState<String> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: isClickable ? onClick : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: field.hasError ? Colors.red : Colors.grey[200]!,
                    ),
                  ),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    readOnly: isClickable || readOnly,
                    onChanged: (value) {
                      field.didChange(value);
                      if (!isClickable) {
                        controller.text = value;
                      }
                    },
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          isClickable && controller.text.isEmpty
                              ? Colors.grey[500]
                              : Colors.black87,
                    ),
                    onTap: isClickable ? onClick : null,
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      labelText:
                          isClickable && controller.text.isEmpty
                              ? (placeholder ?? label)
                              : label,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: field.hasError ? Colors.red : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon:
                          icon != null
                              ? Icon(
                                icon,
                                color:
                                    field.hasError
                                        ? Colors.red
                                        : Colors.grey[600],
                                size: 20,
                              )
                              : null,
                      suffixIcon:
                          isClickable
                              ? Icon(
                                Icons.arrow_drop_down,
                                color:
                                    field.hasError
                                        ? Colors.red
                                        : Colors.grey[600],
                                size: 20,
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          );
        },
      );
    }
  }
}
