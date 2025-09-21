// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';

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
    Key? key,
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
  }) : super(key: key);

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
            prefixIcon: Icon(
              widget.icon,
              color:
                  widget.focusNode.hasFocus
                      ? AppColors.primaryColor
                      : Colors.grey[400],
              size: 22,
            ),
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            filled: true,
            fillColor: Colors.transparent,
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
