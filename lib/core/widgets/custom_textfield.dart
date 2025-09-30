// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final FocusNode focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final String? errorText;
  final int? maxLines;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.errorText,
    this.maxLines,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines ?? 1,
          readOnly: widget.readOnly,
          onTapOutside: (event) {
            widget.focusNode.unfocus();
            setState(() {});
          },
          onTap: () => setState(() {}),
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Icon(widget.icon, color: Colors.grey[600], size: 20),
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
