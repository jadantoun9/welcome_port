import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/phone_number.dart';
import 'package:flutter_intl_phone_field/country_picker_dialog.dart';
import 'package:flutter_intl_phone_field/countries.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneNumberField extends StatefulWidget {
  final Function(PhoneNumber) onPhoneNumberChanged;
  final String? placeholder;
  final String? errorText;
  final String? value;
  final FocusNode focusNode;
  final String? Function(PhoneNumber?)? validator;
  final bool readOnly;
  final Color? bgColor;
  final Border? border;

  const PhoneNumberField({
    super.key,
    required this.onPhoneNumberChanged,
    required this.focusNode,
    this.placeholder,
    this.bgColor,
    this.errorText,
    this.value,
    this.border,
    this.validator,
    this.readOnly = false,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  @override
  void dispose() {
    // Don't dispose the focusNode here as it's passed from parent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.bgColor ?? Colors.grey[50],
            border: widget.border,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: IntlPhoneField(
              initialValue: widget.value,
              focusNode: widget.focusNode,
              countries:
                  countries.where((country) => country.code != 'IL').toList(),
              readOnly: widget.readOnly,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
              initialCountryCode:
                  widget.value == null ? 'LB' : null, // Default country code
              pickerDialogStyle: PickerDialogStyle(
                searchFieldInputDecoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchCountry,
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[500]!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              decoration: InputDecoration(
                hintText:
                    widget.placeholder ??
                    AppLocalizations.of(context)!.phoneNumberPlaceholder,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                prefixIcon: Icon(
                  Icons.phone,
                  color:
                      widget.focusNode.hasFocus
                          ? AppColors.primaryColor
                          : Colors.grey[400],
                  size: 22,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: widget.border != null ? 1 : 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              dropdownTextStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              onChanged: (phone) {
                widget.onPhoneNumberChanged(phone);
              },
              validator: widget.validator,
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
